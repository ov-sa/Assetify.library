----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: engine: syncer.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Syncer Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    md5 = md5,
    tostring = tostring,
    isElement = isElement,
    getElementType = getElementType,
    getRealTime = getRealTime,
    getThisResource = getThisResource,
    getResourceName = getResourceName,
    getResourceInfo = getResourceInfo,
    setElementModel = setElementModel,
    addEventHandler = addEventHandler,
    getLatentEventStatus = getLatentEventStatus,
    getResourceRootElement = getResourceRootElement
}


-----------------------
--[[ Class: Syncer ]]--
-----------------------

local syncer = class:create("syncer", {
    libraryResource = imports.getThisResource(),
    isLibraryBooted = false,
    isLibraryLoaded = false,
    isModuleLoaded = false,
    libraryBandwidth = 0,
    syncedElements = {}
})
function syncer.public:import() return syncer end
syncer.public.libraryName = imports.getResourceName(syncer.public.libraryResource)
syncer.public.librarySource = "https://api.github.com/repos/ov-sa/Assetify-Library/releases/latest"
syncer.public.librarySerial = imports.md5(syncer.public.libraryName..":"..imports.tostring(syncer.public.libraryResource)..":"..table.encode(imports.getRealTime()))

network:create("Assetify:onBoot")
network:create("Assetify:onLoad")
network:create("Assetify:onUnload")
network:create("Assetify:onModuleLoad")
network:create("Assetify:onElementDestroy")
syncer.private.execOnBoot = function(execFunc)
    if not execFunc or (imports.type(execFunc) ~= "function") then return false end
    if syncer.public.isLibraryBooted then execFunc()
    else network:fetch("Assetify:onBoot"):on(execFunc, {subscriptionLimit = 1}) end
    return true
end
syncer.private.execOnLoad = function(execFunc)
    if not execFunc or (imports.type(execFunc) ~= "function") then return false end
    if syncer.public.isLibraryLoaded then execFunc()
    else network:fetch("Assetify:onLoad"):on(execFunc, {subscriptionLimit = 1}) end
    return true
end
syncer.private.execOnModuleLoad = function(execFunc)
    if not execFunc or (imports.type(execFunc) ~= "function") then return false end
    if syncer.public.isModuleLoaded then execFunc()
    else network:fetch("Assetify:onModuleLoad"):on(execFunc, {subscriptionLimit = 1}) end
    return true
end
imports.addEventHandler((localPlayer and "onClientResourceStart") or "onResourceStart", resourceRoot, function() network:emit("Assetify:onBoot") end)
syncer.private.execOnBoot(function() syncer.public.isLibraryBooted = true end)
syncer.private.execOnLoad(function() syncer.public.isLibraryLoaded = true end)
syncer.private.execOnModuleLoad(function() syncer.public.isModuleLoaded = true end)

if localPlayer then
    settings.assetPacks = {}
    syncer.private.scheduledAssets = {}
    network:create("Assetify:onAssetLoad")
    network:create("Assetify:onAssetUnload")
    syncer.private.execOnLoad(function() network:emit("Assetify:onLoadClient", true, false, localPlayer) end)

    function syncer.private:setElementModel(element, assetType, assetName, assetClump, clumpMaps, remoteSignature)
        if not element or (not remoteSignature and not imports.isElement(element)) then return false end
        local elementType = imports.getElementType(element)
        elementType = (((elementType == "ped") or (elementType == "player")) and "ped") or elementType
        if not settings.assetPacks[assetType] or not settings.assetPacks[assetType].assetType or (settings.assetPacks[assetType].assetType ~= elementType) then return false end
        local modelID = manager:getAssetID(assetType, assetName, assetClump)
        if not modelID then return false end
        syncer.public.syncedElements[element] = {assetType = assetType, assetName = assetName, assetClump = assetClump, clumpMaps = clumpMaps}
        thread:createHeartbeat(function()
            return not imports.isElement(element)
        end, function()
            if clumpMaps then
                shader.clearElementBuffer(element, asset.references.clump)
                local cAsset = manager:getAssetData(assetType, assetName, syncer.public.librarySerial)
                if cAsset and cAsset.manifestData.shaderMaps and cAsset.manifestData.shaderMaps[(asset.references.clump)] then
                    for i, j in imports.pairs(clumpMaps) do
                        if cAsset.manifestData.shaderMaps[(asset.references.clump)][i] and cAsset.manifestData.shaderMaps[(asset.references.clump)][i][j] then
                            shader:create(element, asset.references.clump, "Assetify_TextureClumper", i, {clumpTex = cAsset.manifestData.shaderMaps[(asset.references.clump)][i][j].clump, clumpTex_bump = cAsset.manifestData.shaderMaps[(asset.references.clump)][i][j].bump}, {}, cAsset.unSynced.rwCache.map, cAsset.manifestData.shaderMaps[(asset.references.clump)][i][j], cAsset.manifestData.encryptKey)
                        end
                    end
                end
            end
            imports.setElementModel(element, modelID)
        end, settings.downloader.buildRate)
        return true
    end
else
    syncer.public.libraryVersion = imports.getResourceInfo(resource, "version")
    syncer.public.libraryVersion = (syncer.public.libraryVersion and "v."..syncer.public.libraryVersion) or false
    syncer.public.libraryModules = {}
    syncer.public.libraryClients = {loaded = {}, loading = {}, scheduled = {}}
    network:create("Assetify:onLoadClient"):on(function(player)
        syncer.public.libraryClients.loaded[player] = true
        network:emit("Assetify:Syncer:onSyncPostPool", false, player)
    end)
    syncer.private.execOnLoad(function()
        for i, j in imports.pairs(syncer.public.libraryClients.scheduled) do
            syncer.private:loadClient(i)
        end
    end)

    network:create("Assetify:Syncer:onSyncPrePool", true):on(function(__self, source)
        local __source = source
        thread:create(function(self)
            local source = __source
            for i, j in imports.pairs(syncer.public.syncedGlobalDatas) do
                syncer.public.syncGlobalData(i, j, false, source)
                thread:pause()
            end
            for i, j in imports.pairs(syncer.public.syncedEntityDatas) do
                for k, v in imports.pairs(j) do
                    syncer.public.syncEntityData(i, k, v, false, source)
                    thread:pause()
                end
                thread:pause()
            end
            __self:resume()
        end):resume({executions = settings.downloader.syncRate, frames = 1})
        __self:pause()
        return true
    end, {isAsync = true})

    network:create("Assetify:Syncer:onSyncPostPool"):on(function(self, source)
        self:resume({executions = settings.downloader.syncRate, frames = 1})
        for i, j in imports.pairs(syncer.public.syncedElements) do
            if j then syncer.private:setElementModel(i, j.assetType, j.assetName, j.assetClump, j.clumpMaps, j.remoteSignature, source) end
            thread:pause()
        end
    end, {isAsync = true})

    function syncer.private:loadClient(player)
        if syncer.public.libraryClients.loaded[player] then return false end
        if not syncer.public.isLibraryLoaded then
            syncer.public.libraryClients.scheduled[player] = true
        else
            syncer.public.libraryClients.scheduled[player] = nil
            syncer.public.libraryClients.loading[player] = thread:createHeartbeat(function()
                local self = syncer.public.libraryClients.loading[player]
                if self and not syncer.public.libraryClients.loaded[player] and thread:isInstance(self) then
                    self.cStatus, self.cQueue = self.cStatus or {}, self.cQueue or {}
                    for i, j in imports.pairs(self.cQueue) do
                        local queueStatus = imports.getLatentEventStatus(player, i)
                        if queueStatus then
                            self.cStatus[(j.assetType)] = self.cStatus[(j.assetType)] or {}
                            self.cStatus[(j.assetType)][(j.assetName)] = self.cStatus[(j.assetType)][(j.assetName)] or {}
                            self.cStatus[(j.assetType)][(j.assetName)][(j.file)] = queueStatus
                        else
                            self.cQueue[i] = nil
                            if self.cStatus[(j.assetType)] and self.cStatus[(j.assetType)][(j.assetName)] then
                                self.cStatus[(j.assetType)][(j.assetName)][(j.file)] = (self.cStatus[(j.assetType)][(j.assetName)][(j.file)] and {tickEnd = 0, percentComplete = 100}) or nil
                            end
                        end
                    end
                    network:emit("Assetify:Downloader:onSyncProgress", true, false, player, self.cStatus)
                    return true
                end
                return false
            end, function() syncer.public.libraryClients.loading[player] = nil end, settings.downloader.trackRate)
            syncer.private:syncPack(player, _, true)
        end
        return true
    end

    function syncer.private:setElementModel(element, assetType, assetName, assetClump, clumpMaps, remoteSignature, targetPlayer)
        if targetPlayer then return network:emit("Assetify:Syncer:onSyncElementModel", true, false, targetPlayer, element, assetType, assetName, assetClump, clumpMaps, remoteSignature) end
        if not element or not imports.isElement(element) then return false end
        local elementType = imports.getElementType(element)
        elementType = (((elementType == "ped") or (elementType == "player")) and "ped") or elementType
        if not settings.assetPacks[assetType] or not settings.assetPacks[assetType].assetType or (settings.assetPacks[assetType].assetType ~= elementType) then return false end
        local cAsset = manager:getAssetData(assetType, assetName)
        if not cAsset or (cAsset.manifestData.assetClumps and (not assetClump or not cAsset.manifestData.assetClumps[assetClump])) then return false end
        remoteSignature = imports.getElementType(element)
        syncer.public.syncedElements[element] = {assetType = assetType, assetName = assetName, assetClump = assetClump, clumpMaps = clumpMaps, remoteSignature = remoteSignature}
        thread:create(function(self)
            for i, j in imports.pairs(syncer.public.libraryClients.loaded) do
                syncer.private:setElementModel(element, assetType, assetName, assetClump, clumpMaps, remoteSignature, i)
                thread:pause()
            end
        end):resume({executions = settings.downloader.syncRate, frames = 1})
        return true
    end
end


---------------------
--[[ API Syncers ]]--
---------------------

function syncer.public.syncElementModel(length, ...) return syncer.private:setElementModel(table.unpack(table.pack(...), length or 5)) end
if localPlayer then
    network:create("Assetify:Syncer:onSyncElementModel"):on(function(...) syncer.public.syncElementModel(6, ...) end)
    imports.addEventHandler("onClientElementDestroy", root, function() network:emit("Assetify:onElementDestroy", false, source) end)
else
    imports.addEventHandler("onPlayerResourceStart", root, function(resourceElement)
        if imports.getResourceRootElement(resourceElement) ~= resourceRoot then return false end
        syncer.private:loadClient(source)
    end)
    imports.addEventHandler("onElementModelChange", root, function() syncer.public.syncedElements[source] = nil end)
    imports.addEventHandler("onElementDestroy", root, function()
        if not syncer.public.isLibraryBooted then return false end
        local __source = source
        network:emit("Assetify:onElementDestroy", false, source)
        thread:create(function(self)
            local source = __source
            syncer.public.syncedElements[source] = nil
            for i, j in imports.pairs(syncer.public.libraryClients.loaded) do
                network:emit("Assetify:onElementDestroy", true, false, i, source)
                thread:pause()
            end
        end):resume({executions = settings.downloader.syncRate, frames = 1})
    end)
    imports.addEventHandler("onPlayerQuit", root, function()
        if syncer.public.libraryClients.loading[source] then syncer.public.libraryClients.loading[source]:destroy() end
        syncer.public.libraryClients.loaded[source] = nil
        syncer.public.libraryClients.loading[source] = nil
        syncer.public.libraryClients.scheduled[source] = nil
    end)
end