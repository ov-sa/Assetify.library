----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: engine: downloader.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Downloader Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local syncer = syncer:import()
local imports = {
    type = type,
    pairs = pairs,
    md5 = md5,
    collectgarbage = collectgarbage,
    getLatentEventHandles = getLatentEventHandles
}


---------------------------
--[[ Class: Downloader ]]--
---------------------------

if localPlayer then
    local function bootPack(packName)
        local cPointer = settings.assetPacks[packName]
        if not cPointer or not cPointer.autoLoad or not cPointer.rwDatas then return false end
        for i, j in imports.pairs(cPointer.rwDatas) do
            if j then manager:loadAsset(packName, i) end
            thread:pause()
        end
        return true
    end
    syncer.private.execOnLoad(function() network:emit("Assetify:Downloader:onPostSyncPool", true, false, localPlayer) end)

    network:create("Assetify:Downloader:onSyncProgress"):on(function(status, bandwidth)
        if bandwidth then
            syncer.public.libraryBandwidth = {
                total = bandwidth,
                status = {total = 0, eta = 0, eta_count = 0}
            }
            return true
        end
        for assetType, i in imports.pairs(status) do
            for assetName, j in imports.pairs(i) do
                local cPointer = settings.assetPacks[assetType].rwDatas[assetName]
                if cPointer.bandwidthData.isDownloaded then return false end
                for file, status in imports.pairs(j) do
                    cPointer.bandwidthData.status.file[file] = cPointer.bandwidthData.status.file[file] or {}
                    local currentETA, currentSize = status.tickEnd, status.percentComplete*0.01*cPointer.bandwidthData.file[file]
                    local prevETA, prevSize = cPointer.bandwidthData.status.file[file].eta or 0, cPointer.bandwidthData.status.file[file].size or 0
                    local prevTotalETA, prevTotalSize = cPointer.bandwidthData.status.eta or 0, cPointer.bandwidthData.status.total or 0
                    cPointer.bandwidthData.status.eta = cPointer.bandwidthData.status.eta - prevETA + currentETA
                    cPointer.bandwidthData.status.eta_count = cPointer.bandwidthData.status.eta_count + ((not cPointer.bandwidthData.status.file[file].eta and 1) or 0)
                    cPointer.bandwidthData.status.total = cPointer.bandwidthData.status.total - prevSize + currentSize
                    cPointer.bandwidthData.status.file[file].eta, cPointer.bandwidthData.status.file[file].size = currentETA, currentSize
                    syncer.public.libraryBandwidth.status.eta = syncer.public.libraryBandwidth.status.eta - prevTotalETA + cPointer.bandwidthData.status.eta
                    syncer.public.libraryBandwidth.status.eta_count = syncer.public.libraryBandwidth.status.eta_count + ((not cPointer.bandwidthData.status.isLibraryETACounted and 1) or 0)
                    syncer.public.libraryBandwidth.status.total = syncer.public.libraryBandwidth.status.total - prevTotalSize + cPointer.bandwidthData.status.total
                    cPointer.bandwidthData.status.isLibraryETACounted = true
                end
            end
        end
    end)

    network:create("Assetify:Downloader:onSyncHash"):on(function(assetType, assetName, hashes)
        syncer.private.scheduledAssets[assetType] = syncer.private.scheduledAssets[assetType] or {}
        syncer.private.scheduledAssets[assetType][assetName] = syncer.private.scheduledAssets[assetType][assetName] or {bandwidthData = 0}
        thread:create(function(self)
            local cPointer = settings.assetPacks[assetType].rwDatas[assetName]
            cPointer.bandwidthData.status = {total = 0, eta = 0, eta_count = 0, file = {}}
            local fetchFiles = {}
            for i, j in imports.pairs(hashes) do
                local fileData = file:read(i)
                if not fileData or (imports.md5(fileData) ~= j) then
                    fetchFiles[i] = true
                else
                    cPointer.bandwidthData.status.total = cPointer.bandwidthData.status.total + settings.assetPacks[assetType].rwDatas[assetName].bandwidthData.file[i]
                    syncer.public.libraryBandwidth.status.total = syncer.public.libraryBandwidth.status.total + settings.assetPacks[assetType].rwDatas[assetName].bandwidthData.file[i]
                end
                fileData = nil
                thread:pause()
            end
            network:emit("Assetify:Downloader:onSyncHash", true, true, localPlayer, assetType, assetName, fetchFiles)
            imports.collectgarbage()
        end):resume({executions = settings.downloader.buildRate, frames = 1})
    end)

    network:create("Assetify:Downloader:onSyncData"):on(function(assetType, baseIndex, subIndexes, indexData)
        settings.assetPacks[assetType] = settings.assetPacks[assetType] or {}
        if not subIndexes then
            settings.assetPacks[assetType][baseIndex] = indexData
        else
            if not settings.assetPacks[assetType][baseIndex] then settings.assetPacks[assetType][baseIndex] = {} end
            local totalIndexes = #subIndexes
            local indexPointer = settings.assetPacks[assetType][baseIndex]
            if totalIndexes > 1 then
                for i = 1, totalIndexes - 1, 1 do
                    local indexReference = subIndexes[i]
                    if not indexPointer[indexReference] then indexPointer[indexReference] = {} end
                    indexPointer = indexPointer[indexReference]
                end
            end
            indexPointer[(subIndexes[totalIndexes])] = indexData
        end
    end)

    network:create("Assetify:Downloader:onSyncContent"):on(function(assetType, assetName, contentPath, ...)
        file:write(contentPath, ...)
        imports.collectgarbage()
    end)

    network:create("Assetify:Downloader:onSyncState"):on(function(assetType, assetName)
        local isPackVoid = true
        local cPointer = settings.assetPacks[assetType].rwDatas[assetName]
        cPointer.bandwidthData.isDownloaded = true
        if cPointer.bandwidthData.status and cPointer.bandwidthData.status.isLibraryETACounted then
            syncer.public.libraryBandwidth.status.eta = syncer.public.libraryBandwidth.status.eta - cPointer.bandwidthData.status.eta
            syncer.public.libraryBandwidth.status.eta_count = syncer.public.libraryBandwidth.status.eta_count - 1
        end
        cPointer.bandwidthData.status = nil
        syncer.private.scheduledAssets[assetType][assetName] = nil
        for i, j in imports.pairs(syncer.private.scheduledAssets[assetType]) do
            if j then isPackVoid = false; break end
        end
        if isPackVoid then
            local isSyncDone = true
            syncer.private.scheduledAssets[assetType] = nil
            for i, j in imports.pairs(syncer.private.scheduledAssets) do
                if j then isSyncDone = false; break end
            end
            if isSyncDone then
                if assetType == "module" then
                    network:emit("Assetify:Downloader:onSyncPack", true, false, localPlayer)
                    thread:create(function(self)
                        bootPack("module")
                        network:emit("Assetify:onModuleLoad", false)
                    end):resume({executions = settings.downloader.buildRate, frames = 1})
                else
                    syncer.private.scheduledAssets = nil
                    syncer.public.libraryBandwidth.status = nil
                    thread:create(function(self)
                        for i, j in imports.pairs(settings.assetPacks) do
                            if i ~= "module" then bootPack(i) end
                        end
                        network:emit("Assetify:onLoad", false)
                    end):resume({executions = settings.downloader.buildRate, frames = 1})
                end
            end
        end
    end)
else
    function syncer.private:syncHash(player, ...) return network:emit("Assetify:Downloader:onSyncHash", true, true, player, ...) end
    function syncer.private:syncData(player, ...) return network:emit("Assetify:Downloader:onSyncData", true, true, player, ...) end
    function syncer.private:syncContent(player, ...) return network:emit("Assetify:Downloader:onSyncContent", true, true, player, ...) end
    function syncer.private:syncState(player, ...) return network:emit("Assetify:Downloader:onSyncState", true, true, player, ...) end
    network:create("Assetify:Downloader:onSyncHash"):on(function(source, assetType, assetName, hashes) syncer.private:syncPack(source, {type = assetType, name = assetName, hashes = hashes}) end)
    network:create("Assetify:Downloader:onSyncPack"):on(function(source) syncer.private:syncPack(source) end)

    function syncer.private:syncPack(player, assetDatas, syncModules, packName)
        if packName then
            local cPack = (settings.assetPacks[packName] and settings.assetPacks[packName].assetPack) or false
            if not cPack then return false end
            local isModule = packName == "module"
            for i, j in imports.pairs(cPack) do
                if i ~= "rwDatas" then
                    if isModule or syncModules then syncer.private:syncData(player, packName, i, false, j) end
                else
                    for k, v in imports.pairs(j) do
                        if isModule or syncModules then syncer.private:syncData(player, packName, i, {k, "bandwidthData"}, v.synced.bandwidthData) end
                        if isModule or not syncModules then syncer.private:syncHash(player, packName, k, v.unSynced.fileHash) end
                        thread:pause()
                    end
                end
                thread:pause()
            end
            return true
        end
        if not assetDatas then
            thread:create(function(self)
                local isLibraryVoid = true
                for i, j in imports.pairs(settings.assetPacks) do
                    if i ~= "module" then
                        if syncer.private:syncPack(player, _, syncModules, i) then isLibraryVoid = false end
                    end
                end
                if syncModules then
                    network:emit("Assetify:Downloader:onSyncProgress", true, false, player, _, syncer.public.libraryBandwidth)
                    self:await(network:emitCallback(self, "Assetify:Syncer:onSyncPrePool", false, player))
                    if not syncer.private:syncPack(player, _, syncModules, "module") then
                        network:emit("Assetify:onModuleLoad", true, true, player)
                        network:emit("Assetify:Downloader:onSyncPack", false, player)
                    end
                else
                    if isLibraryVoid then network:emit("Assetify:onLoad", true, false, player) end
                end
            end):resume({executions = settings.downloader.syncRate, frames = 1})
        else
            thread:create(function(self)
                local cAsset = settings.assetPacks[(assetDatas.type)].assetPack.rwDatas[(assetDatas.name)]
                for i, j in imports.pairs(cAsset.synced) do
                    if i ~= "bandwidthData" then syncer.private:syncData(player, assetDatas.type, "rwDatas", {assetDatas.name, i}, j) end
                    thread:pause()
                end
                for i, j in imports.pairs(assetDatas.hashes) do
                    syncer.private:syncContent(player, assetDatas.type, assetDatas.name, i, cAsset.unSynced.fileData[i])
                    local cQueue = imports.getLatentEventHandles(player)
                    syncer.public.libraryClients.loading[player].cQueue[(cQueue[#cQueue])] = {assetType = assetDatas.type, assetName = assetDatas.name, file = i}
                    thread:pause()
                end
                syncer.private:syncState(player, assetDatas.type, assetDatas.name)
            end):resume({executions = settings.downloader.syncRate, frames = 1})
        end
        return true
    end
end