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
local resource = resource:import()
local imports = {
    type = type,
    pairs = pairs,
    sha256 = sha256,
    base64Decode = base64Decode,
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
    syncer.private.execOnLoad(function() network:emit("Assetify:Downloader:onPostSyncPool", true, false, localPlayer) end)

    local function updateStatus(pointer, rawStatus, isResource)
        if not pointer or pointer.bandwidthData.isDownloaded then return false end
        local prevTotalETA, prevTotalSize = pointer.bandwidthData.status.eta or 0, pointer.bandwidthData.status.total or 0
        for file, status in imports.pairs(rawStatus) do
            pointer.bandwidthData.status.file[file] = pointer.bandwidthData.status.file[file] or {}
            local currentETA, currentSize = status.tickEnd, status.percentComplete*0.01*pointer.bandwidthData.file[file]
            local prevETA, prevSize = pointer.bandwidthData.status.file[file].eta or 0, pointer.bandwidthData.status.file[file].size or 0
            pointer.bandwidthData.status.eta = pointer.bandwidthData.status.eta - prevETA + currentETA
            pointer.bandwidthData.status.eta_count = pointer.bandwidthData.status.eta_count + ((not pointer.bandwidthData.status.file[file].eta and 1) or 0)
            pointer.bandwidthData.status.total = pointer.bandwidthData.status.total - prevSize + currentSize
            pointer.bandwidthData.status.file[file].eta, pointer.bandwidthData.status.file[file].size = currentETA, currentSize
        end
        if not isResource then
            syncer.public.libraryBandwidth.status.eta = syncer.public.libraryBandwidth.status.eta - prevTotalETA + pointer.bandwidthData.status.eta
            syncer.public.libraryBandwidth.status.eta_count = syncer.public.libraryBandwidth.status.eta_count + ((not pointer.bandwidthData.status.isLibraryETACounted and 1) or 0)
            syncer.public.libraryBandwidth.status.total = syncer.public.libraryBandwidth.status.total - prevTotalSize + pointer.bandwidthData.status.total
            pointer.bandwidthData.status.isLibraryETACounted = true
        end
        return true
    end

    --TODO: DISABLED FOR NOW TEMPORARILY
    network:create("Assetify:Downloader:onSyncProgress"):on(function(status, bandwidth, isResource)
        if not isResource then
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
        else
            for resourceName, i in imports.pairs(status) do
                updateStatus(resource.private.buffer.name[resourceName], i, true)
            end
        end
    end)

    network:create("Assetify:Downloader:onSyncHash"):on(function(accessTokens, assetType, assetName, hashes, bandwidth, remoteResource)
        if not remoteResource then
            syncer.private.scheduledAssets[assetType] = syncer.private.scheduledAssets[assetType] or {}
            syncer.private.scheduledAssets[assetType][assetName] = syncer.private.scheduledAssets[assetType][assetName] or {bandwidthData = 0}
        else
            resource.public:create(imports.getResourceFromName(remoteResource), bandwidth)
        end
        thread:create(function(self)
            local cPointer = nil
            if not remoteResource then cPointer = settings.assetPacks[assetType].rwDatas[assetName]
            else cPointer = resource.private.buffer.name[remoteResource] end
            cPointer.bandwidthData.status = {total = 0, eta = 0, eta_count = 0, file = {}}
            local fetchFiles = {}
            for i, j in imports.pairs(hashes) do
                local fileData = file:read(i)
                if not fileData or (imports.sha256(fileData) ~= j) then
                    fetchFiles[i] = true
                else
                    cPointer.bandwidthData.status.total = cPointer.bandwidthData.status.total
                    if not remoteResource then
                        cPointer.bandwidthData.status.total = cPointer.bandwidthData.status.total + settings.assetPacks[assetType].rwDatas[assetName].bandwidthData.file[i]
                        syncer.public.libraryBandwidth.status.total = syncer.public.libraryBandwidth.status.total + settings.assetPacks[assetType].rwDatas[assetName].bandwidthData.file[i]
                    else cPointer.bandwidthData.status.total = cPointer.bandwidthData.status.total + cPointer.bandwidthData.file[i] end
                end
                fileData = nil
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
                        exec = function(self) file:write(i, imports.base64Decode(self:await(rest:get(syncer.public.libraryWebserver.."/onFetchContent?token="..accessTokens[1].."&peer="..accessTokens[2].."&path="..i)))) end,
                        catch = function() imports.outputConsole("Assetify: Webserver ━│  Failed to download file: "..i.."...") end
                    })
                end
                --TODO: RENAME APPROPRIATELY
                network:emit("Assetify:Downloader:onSyncData", true, true, localPlayer, assetType, assetName, fetchFiles, remoteResource)
                imports.collectgarbage()
                self.cHeartbeat = nil
            end, settings.downloader.buildRate)
        end):resume({executions = settings.downloader.buildRate, frames = 1})
    end)

    network:create("Assetify:Downloader:onSyncData"):on(function(assetType, baseIndex, subIndexes, indexData)
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

    network:create("Assetify:Downloader:onSyncState"):on(function(assetType, assetName, remoteResource)
        local cPointer = nil
        if not remoteResource then cPointer = settings.assetPacks[assetType].rwDatas[assetName]
        else cPointer = resource.private.buffer.name[remoteResource] end
        cPointer.bandwidthData.isDownloaded = true
        if not remoteResource then
            local isPackVoid = true
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
        else
            cPointer.bandwidthData.status = nil
            resource.private.buffer.name[remoteResource].isLoaded = true
            network:emit("Assetify:onResourceLoad", false, remoteResource, resource.private.buffer.name[remoteResource].resource)
        end
    end)
else
    function syncer.private:syncHash(player, ...) return network:emit("Assetify:Downloader:onSyncHash", true, true, player, {syncer.public.libraryToken, imports.getPlayerSerial(player)}, ...) end
    function syncer.private:syncData(player, ...) return network:emit("Assetify:Downloader:onSyncData", true, true, player, ...) end
    function syncer.private:syncState(player, ...) return network:emit("Assetify:Downloader:onSyncState", true, true, player, ...) end
    network:create("Assetify:Downloader:onSyncData"):on(function(source, assetType, assetName, hashes, remoteResource)
        if not remoteResource then syncer.private:syncPack(source, {type = assetType, name = assetName, hashes = hashes})
        else syncer.private:syncResource(source, remoteResource, hashes) end
    end)
    network:create("Assetify:Downloader:onSyncPack"):on(function(source) syncer.private:syncPack(source) end)

    function syncer.private:syncResource(player, resourceName, hashes)
        if not resourceName then
            thread:create(function(self)
                for i, j in imports.pairs(resource.private.buffer.name) do
                    if not j.isSilent then syncer.private:syncResource(player, i) end
                    thread:pause()
                end
            end):resume({executions = settings.downloader.syncRate, frames = 1})
            return true
        end
        if not resource.private.buffer.name[resourceName] then return false end
        if not hashes then
            syncer.private:syncHash(player, _, _, resource.private.buffer.name[resourceName].unSynced.fileHash, resource.private.buffer.name[resourceName].bandwidthData, resourceName)
        else
            --TODO: DISABLED TEMPORARILY
            --resource.private:loadClient(player, resourceName)
            thread:create(function(self)
                syncer.private:syncState(player, _, _, resourceName)
            end):resume({executions = settings.downloader.syncRate, frames = 1})
        end
        return true
    end
    function syncer.public:syncResource(player, resourceSource, ...)
        if player then
            if not resource.private.buffer.source[resourceSource] or (not syncer.public.isLibraryLoaded and not resource.private.resourceSchedules.resource[resourceSource]) then return false end
            if not syncer.public.libraryClients.loaded[player] then
                resource.private.resourceSchedules.client[player] = resource.private.resourceSchedules.client[player] or {}
                resource.private.resourceSchedules.client[player][resourceSource] = true
                return false
            end
            return syncer.private:syncResource(player, resource.private.buffer.source[resourceSource].name)
        end
        if syncer.public.isLibraryLoaded then return resource.public:create(resourceSource, ...) end
        resource.private.resourceSchedules.resource[resourceSource] = table.pack(...)
        return true
    end

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
                        if isModule or syncModules then syncer.private:syncData(player, packName, i, {k, "bandwidthData"}, v.synced.bandwidthData) end
                        if isModule or not syncModules then syncer.private:syncHash(player, packName, k, v.unSynced.fileHash) end
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
                    network:emit("Assetify:Downloader:onSyncProgress", true, false, player, _, syncer.public.libraryBandwidth)
                    self:await(network:emitCallback("Assetify:Syncer:onSyncPrePool", false, player))
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
                syncer.private:syncState(player, assetDatas.type, assetDatas.name)
            end):resume({executions = settings.downloader.syncRate, frames = 1})
        end
        return true
    end
end