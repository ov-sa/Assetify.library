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
syncer.public.libraryName = imports.getResourceName(syncer.public.libraryResource)
syncer.public.librarySource = "https://api.github.com/repos/ov-sa/Assetify-Library/releases/latest"
syncer.public.librarySerial = imports.md5(syncer.public.libraryName..":"..imports.tostring(syncer.public.libraryResource)..":"..table:encode(imports.getRealTime()))

network:create("Assetify:onBoot")
network:create("Assetify:onLoad")
network:create("Assetify:onUnload")
network:create("Assetify:onModuleLoad")
network:create("Assetify:onElementDestroy")
function syncer.public:import() return syncer end
imports.addEventHandler((localPlayer and "onClientResourceStart") or "onResourceStart", resourceRoot, function() network:emit("Assetify:onBoot") end)
syncer.private.execOnBoot = function(execFunc)
    local execWrapper = nil
    execWrapper = function() execFunc(); network:fetch("Assetify:onBoot"):off(execWrapper) end
    network:fetch("Assetify:onBoot"):on(execWrapper)
    return true
end
syncer.private.execOnLoad = function(execFunc)
    local execWrapper = nil
    execWrapper = function() execFunc(); network:fetch("Assetify:onLoad"):off(execWrapper) end
    network:fetch("Assetify:onLoad"):on(execWrapper)
    return true
end
syncer.private.execOnLoad = function(execFunc)
    local execWrapper = nil
    execWrapper = function() execFunc(); network:fetch("Assetify:onLoad"):off(execWrapper) end
    network:fetch("Assetify:onLoad"):on(execWrapper)
    return true
end
syncer.private.execOnModuleLoad = function(execFunc)
    local execWrapper = nil
    execWrapper = function() execFunc(); network:fetch("Assetify:onModuleLoad"):off(execWrapper) end
    network:fetch("Assetify:onModuleLoad"):on(execWrapper)
    return true
end
syncer.private.execOnBoot(function() syncer.public.isLibraryBooted = true end)
syncer.private.execOnLoad(function() syncer.public.isLibraryLoaded = true end)
syncer.private.execOnModuleLoad(function() syncer.public.isModuleLoaded = true end)

if localPlayer then
    settings.assetPacks = {}
    syncer.public.scheduledAssets = {}
    network:create("Assetify:onAssetLoad")
    network:create("Assetify:onAssetUnload")

    function syncer.public:setElementModel(element, assetType, assetName, assetClump, clumpMaps, remoteSignature)
        if not element or (not remoteSignature and not imports.isElement(element)) then return false end
        local elementType = imports.getElementType(element)
        elementType = (((elementType == "ped") or (elementType == "player")) and "ped") or elementType
        if not settings.assetPacks[assetType] or not settings.assetPacks[assetType].assetType or (settings.assetPacks[assetType].assetType ~= elementType) then return false end
        local modelID = manager:getID(assetType, assetName, assetClump)
        if not modelID then return false end
        syncer.public.syncedElements[element] = {assetType = assetType, assetName = assetName, assetClump = assetClump, clumpMaps = clumpMaps}
        thread:createHeartbeat(function()
            return not imports.isElement(element)
        end, function()
            if clumpMaps then
                shader:clearElementBuffer(element, "clump")
                local cAsset = manager:getData(assetType, assetName, syncer.public.librarySerial)
                if cAsset and cAsset.manifestData.shaderMaps and cAsset.manifestData.shaderMaps.clump then
                    for i, j in imports.pairs(clumpMaps) do
                        if cAsset.manifestData.shaderMaps.clump[i] and cAsset.manifestData.shaderMaps.clump[i][j] then
                            shader:create(element, "clump", "Assetify_TextureClumper", i, {clumpTex = cAsset.manifestData.shaderMaps.clump[i][j].clump, clumpTex_bump = cAsset.manifestData.shaderMaps.clump[i][j].bump}, {}, cAsset.unSynced.rwCache.map, cAsset.manifestData.shaderMaps.clump[i][j], cAsset.manifestData.encryptKey)
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
    syncer.public.libraryVersion = (syncer.public.libraryVersion and "v."..syncer.public.libraryVersion) or syncer.public.libraryVersion
    syncer.public.loadedClients, syncer.public.scheduledClients = {}, {}

    function syncer.public:setElementModel(element, assetType, assetName, assetClump, clumpMaps, remoteSignature, targetPlayer)
        if targetPlayer then return network:emit("Assetify:Syncer:onSyncElementIdentity", true, false, targetPlayer, element, assetType, assetName, assetClump, clumpMaps, remoteSignature) end
        if not element or not imports.isElement(element) then return false end
        local elementType = imports.getElementType(element)
        elementType = (((elementType == "ped") or (elementType == "player")) and "ped") or elementType
        if not settings.assetPacks[assetType] or not settings.assetPacks[assetType].assetType or (settings.assetPacks[assetType].assetType ~= elementType) then return false end
        local cAsset = manager:getData(assetType, assetName)
        if not cAsset or (cAsset.manifestData.assetClumps and (not assetClump or not cAsset.manifestData.assetClumps[assetClump])) then return false end
        remoteSignature = imports.getElementType(element)
        syncer.public.syncedElements[element] = {assetType = assetType, assetName = assetName, assetClump = assetClump, clumpMaps = clumpMaps}
        thread:create(function(self)
            for i, j in imports.pairs(syncer.public.loadedClients) do
                syncer.public:setElementModel(element, assetType, assetName, assetClump, clumpMaps, remoteSignature, i)
                thread:pause()
            end
        end):resume({executions = settings.downloader.syncRate, frames = 1})
        return true
    end
end


---------------------
--[[ API Syncers ]]--
---------------------

function syncer.public:syncElementModel(length, ...) return syncer.public:setElementModel(table:unpack(table:pack(...), length or 5)) end
if localPlayer then
    network:create("Assetify:Syncer:onSyncElementIdentity"):on(function(...) syncer.public:syncElementModel(6, ...) end)
    network:fetch("Assetify:onElementDestroy"):on(function(source)
        if not syncer.public.isLibraryBooted or not source then return false end
        shader:clearElementBuffer(source)
        syncer.public.syncedEntityDatas[source] = nil
        for i, j in imports.pairs(light) do
            if j and (imports.type(j) == "table") and j.clearElementBuffer then
                j:clearElementBuffer(source)
            end
        end
    end)
    imports.addEventHandler("onClientElementDestroy", root, function() network:emit("Assetify:onElementDestroy", false, source) end)
else
    imports.addEventHandler("onPlayerResourceStart", root, function(resourceElement)
        if imports.getResourceRootElement(resourceElement) == resourceRoot then
            if syncer.public.isLibraryLoaded then
                syncer.public.loadedClients[source] = true
                syncer.public:syncPack(source, _, true)
            else
                syncer.public.scheduledClients[source] = true
            end
        end
    end)
    network:create("Assetify:onRequestPreSyncPool", true):on(function(__self, source)
        local __source = source
        thread:create(function(self)
            local source = __source
            for i, j in imports.pairs(syncer.public.syncedGlobalDatas) do
                syncer.public:syncGlobalData(i, j, false, source)
                thread:pause()
            end
            for i, j in imports.pairs(syncer.public.syncedEntityDatas) do
                for k, v in imports.pairs(j) do
                    syncer.public:syncEntityData(i, k, v, false, source)
                    thread:pause()
                end
                thread:pause()
            end
            __self:resume()
        end):resume({executions = settings.downloader.syncRate, frames = 1})
        __self:pause()
        return true
    end, true)
    network:create("Assetify:Downloader:onSyncPostPool"):on(function(self, source)
        self:resume({executions = settings.downloader.syncRate, frames = 1})
        for i, j in imports.pairs(syncer.public.syncedElements) do
            if j then syncer.public:syncElementModel(i, j.assetType, j.assetName, j.assetClump, j.clumpMaps, source) end
            thread:pause()
        end
    end, true)
    imports.addEventHandler("onElementModelChange", root, function() syncer.public.syncedElements[source] = nil end)
    imports.addEventHandler("onElementDestroy", root, function()
        if not syncer.public.isLibraryBooted then return false end
        network:emit("Assetify:onElementDestroy", false, source)
        local __source = source
        thread:create(function(self)
            local source = __source
            if syncer.public.syncedEntityDatas[source] ~= nil then
                timer:create(function(source)
                    syncer.public.syncedEntityDatas[source] = nil
                end, settings.syncer.persistenceDuration, 1, source)
            end
            syncer.public.syncedElements[source] = nil
            for i, j in imports.pairs(syncer.public.loadedClients) do
                network:emit("Assetify:onElementDestroy", true, false, i, source)
                thread:pause()
            end
        end):resume({executions = settings.downloader.syncRate, frames = 1})
    end)
    imports.addEventHandler("onPlayerQuit", root, function()
        syncer.public.loadedClients[source] = nil
        syncer.public.scheduledClients[source] = nil
    end)
end