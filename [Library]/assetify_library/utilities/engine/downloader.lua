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
    sha256 = sha256,
    collectgarbage = collectgarbage,
    outputConsole = outputConsole,
    getResourceFromName = getResourceFromName,
    getLatentEventHandles = getLatentEventHandles,
    isBrowserDomainBlocked = isBrowserDomainBlocked,
    requestBrowserDomains = requestBrowserDomains,
    getPlayerSerial = getPlayerSerial
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

    local function updateStatus(pointer, rawStatus)
        if not pointer or pointer.bandwidth.isDownloaded then return false end
        local prevTotalETA, prevTotalSize = pointer.bandwidth.status.eta or 0, pointer.bandwidth.status.total or 0
        for file, status in imports.pairs(rawStatus) do
            pointer.bandwidth.status.file[file] = pointer.bandwidth.status.file[file] or {}
            local currentETA, currentSize = status.tickEnd, status.percentComplete*0.01*pointer.bandwidth.file[file]
            local prevETA, prevSize = pointer.bandwidth.status.file[file].eta or 0, pointer.bandwidth.status.file[file].size or 0
            pointer.bandwidth.status.eta = pointer.bandwidth.status.eta - prevETA + currentETA
            pointer.bandwidth.status.eta_count = pointer.bandwidth.status.eta_count + ((not pointer.bandwidth.status.file[file].eta and 1) or 0)
            pointer.bandwidth.status.total = pointer.bandwidth.status.total - prevSize + currentSize
            pointer.bandwidth.status.file[file].eta, pointer.bandwidth.status.file[file].size = currentETA, currentSize
        end
        syncer.public.libraryBandwidth.status.eta = syncer.public.libraryBandwidth.status.eta - prevTotalETA + pointer.bandwidth.status.eta
        syncer.public.libraryBandwidth.status.eta_count = syncer.public.libraryBandwidth.status.eta_count + ((not pointer.bandwidth.status.isLibraryETACounted and 1) or 0)
        syncer.public.libraryBandwidth.status.total = syncer.public.libraryBandwidth.status.total - prevTotalSize + pointer.bandwidth.status.total
        pointer.bandwidth.status.isLibraryETACounted = true
        return true
    end

    --TODO: DISABLED FOR NOW TEMPORARILY
    network:create("Assetify:Downloader:syncProgress"):on(function(status, bandwidth)
        if bandwidth then
            syncer.public.libraryBandwidth = {
                total = bandwidth,
                status = {total = 0, eta = 0, eta_count = 0}
            }
            return true
        end
        for assetType, i in imports.pairs(status) do
            for assetName, j in imports.pairs(i) do
                updateStatus(settings.assetPacks[assetType].rwDatas[assetName], j)
            end
        end
    end)

    network:create("Assetify:Downloader:syncHash"):on(function(accessTokens, assetType, assetName, hashes, bandwidth)
        syncer.private.scheduledAssets[assetType] = syncer.private.scheduledAssets[assetType] or {}
        syncer.private.scheduledAssets[assetType][assetName] = syncer.private.scheduledAssets[assetType][assetName] or {bandwidth = 0}
        thread:create(function(self)
            local cPointer = settings.assetPacks[assetType].rwDatas[assetName]
            cPointer.bandwidth.status = {total = 0, eta = 0, eta_count = 0, file = {}}
            local fetchFiles = {}
            for i, j in imports.pairs(hashes) do
                local data = file:read(i)
                if not data or (imports.sha256(data) ~= j) then
                    fetchFiles[i] = true
                else
                    cPointer.bandwidth.status.total = cPointer.bandwidth.status.total
                    cPointer.bandwidth.status.total = cPointer.bandwidth.status.total + settings.assetPacks[assetType].rwDatas[assetName].bandwidth.file[i]
                    syncer.public.libraryBandwidth.status.total = syncer.public.libraryBandwidth.status.total + settings.assetPacks[assetType].rwDatas[assetName].bandwidth.file[i]
                end
                data = nil
                thread:pause()
            end
            self.cHeartbeat = thread:createHeartbeat(function()
                if imports.isBrowserDomainBlocked(syncer.public.libraryWebserver, true) then
                    imports.requestBrowserDomains({syncer.public.libraryWebserver}, true)
                    return true
                end
                return false
            end, function()
                for i, j in pairs(fetchFiles) do
                    try({
                        exec = function(self)
                            file:write(i, string.decode(self:await(rest:get(syncer.public.libraryWebserver.."/onFetchContent?token="..accessTokens[1].."&peer="..accessTokens[2].."&path="..i)), "base64"))
                        end,
                        catch = function()
                            imports.outputConsole("Assetify: Webserver ━│  Failed to download file: "..i.."...")
                        end
                    })
                end
                network:emit("Assetify:Downloader:syncData", true, true, localPlayer, assetType, assetName, fetchFiles)
                imports.collectgarbage("step", 1)
                self.cHeartbeat = nil
            end, settings.downloader.buildRate)
        end):resume({executions = settings.downloader.buildRate, frames = 1})
    end)

    network:create("Assetify:Downloader:syncData"):on(function(assetType, baseIndex, subIndexes, indexData)
        settings.assetPacks[assetType] = settings.assetPacks[assetType] or {}
        if not subIndexes then
            settings.assetPacks[assetType][baseIndex] = indexData
        else
            if not settings.assetPacks[assetType][baseIndex] then settings.assetPacks[assetType][baseIndex] = {} end
            local totalIndexes = table.length(subIndexes)
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

    network:create("Assetify:Downloader:syncState"):on(function(assetType, assetName)
        local cPointer = settings.assetPacks[assetType].rwDatas[assetName]
        cPointer.bandwidth.isDownloaded = true
        local isPackVoid = true
        if cPointer.bandwidth.status and cPointer.bandwidth.status.isLibraryETACounted then
            syncer.public.libraryBandwidth.status.eta = syncer.public.libraryBandwidth.status.eta - cPointer.bandwidth.status.eta
            syncer.public.libraryBandwidth.status.eta_count = syncer.public.libraryBandwidth.status.eta_count - 1
        end
        cPointer.bandwidth.status = nil
        syncer.private.scheduledAssets[assetType][assetName] = nil
        for i, j in imports.pairs(syncer.private.scheduledAssets[assetType]) do
            if j then
                isPackVoid = false
                break
            end
        end
        if isPackVoid then
            local isSyncDone = true
            syncer.private.scheduledAssets[assetType] = nil
            for i, j in imports.pairs(syncer.private.scheduledAssets) do
                if j then
                    isSyncDone = false
                    break
                end
            end
            if isSyncDone then
                if assetType == "module" then
                    network:emit("Assetify:Downloader:syncPack", true, false, localPlayer)
                    thread:create(function(self)
                        bootPack("module")
                        network:emit("Assetify:onModuleLoad", false)
                    end):resume({executions = settings.downloader.buildRate, frames = 1})
                else
                    syncer.private.scheduledAssets = nil
                    syncer.public.libraryBandwidth.isDownloaded = true
                    syncer.public.libraryBandwidth.status = nil
                    thread:create(function(self)
                        for i, j in imports.pairs(settings.assetPacks) do
                            if i ~= "module" then
                                bootPack(i)
                            end
                        end
                        network:emit("Assetify:onLoad", false)
                    end):resume({executions = settings.downloader.buildRate, frames = 1})
                end
            end
        end
    end)
else
    function syncer.private:syncHash(player, ...) return network:emit("Assetify:Downloader:syncHash", true, true, player, {syncer.public.libraryToken, imports.getPlayerSerial(player)}, ...) end
    function syncer.private:syncData(player, ...) return network:emit("Assetify:Downloader:syncData", true, true, player, ...) end
    function syncer.private:syncState(player, ...) return network:emit("Assetify:Downloader:syncState", true, true, player, ...) end
    function syncer.private:syncPack(player, assetDatas, syncModules, packName)
        if packName then
            local cPack = (settings.assetPacks[packName] and settings.assetPacks[packName].assetPack) or false
            if not cPack then return false end
            local isPackVoid = true
            local isModule = packName == "module"
            for i, j in imports.pairs(cPack) do
                if i ~= "rwDatas" then
                    if isModule or syncModules then syncer.private:syncData(player, packName, i, false, j) end
                else
                    for k, v in imports.pairs(j) do
                        isPackVoid = false
                        if isModule or syncModules then syncer.private:syncData(player, packName, i, {k, "bandwidth"}, v.synced.bandwidth) end
                        if isModule or not syncModules then syncer.private:syncHash(player, packName, k, v.synced.hash) end
                        thread:pause()
                    end
                end
                thread:pause()
            end
            return not isPackVoid
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
                    network:emit("Assetify:Downloader:syncProgress", true, false, player, _, syncer.public.libraryBandwidth)
                    self:await(network:emitCallback("Assetify:Syncer:onSyncPrePool", false, player))
                    if not syncer.private:syncPack(player, _, syncModules, "module") then
                        network:emit("Assetify:onModuleLoad", true, true, player)
                        network:emit("Assetify:Downloader:syncPack", false, player)
                    end
                else
                    if isLibraryVoid then network:emit("Assetify:onLoad", true, false, player) end
                end
            end):resume({executions = settings.downloader.syncRate, frames = 1})
        else
            thread:create(function(self)
                local cAsset = settings.assetPacks[(assetDatas.type)].assetPack.rwDatas[(assetDatas.name)]
                for i, j in imports.pairs(cAsset.synced) do
                    if i ~= "bandwidth" then syncer.private:syncData(player, assetDatas.type, "rwDatas", {assetDatas.name, i}, j) end
                    thread:pause()
                end
                syncer.private:syncState(player, assetDatas.type, assetDatas.name)
            end):resume({executions = settings.downloader.syncRate, frames = 1})
        end
        return true
    end
    network:create("Assetify:Downloader:syncPack"):on(function(source) syncer.private:syncPack(source) end)
    network:create("Assetify:Downloader:syncData"):on(function(source, assetType, assetName, hashes) syncer.private:syncPack(source, {type = assetType, name = assetName, hashes = hashes}) end)
end