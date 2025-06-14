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
    sha256 = sha256,
    tonumber = tonumber,
    tostring = tostring,
    collectgarbage = collectgarbage,
    outputDebugString = outputDebugString,
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
    libraryBandwidth = 0,
    isLibraryBooted = false,
    isLibraryLoaded = false,
    isModuleLoaded = false,
    syncedElements = {}
})
function syncer.public:import() return syncer end
syncer.public.libraryName = imports.getResourceName(syncer.public.libraryResource)
syncer.public.librarySource = "https://api.github.com/repos/ov-sa/Assetify.library/releases/latest"
syncer.public.librarySerial = imports.sha256(syncer.public.libraryName..":"..imports.tostring(syncer.public.libraryResource)..":"..table.encode(imports.getRealTime()))
syncer.public.libraryWebserver = settings.library.webserverURL or "http://localhost:33022"

network:create("Assetify:onBoot"):on(function() syncer.public.isLibraryBooted = true end, {isPrioritized = true})
network:create("Assetify:onLoad"):on(function() syncer.public.isLibraryLoaded = true end, {isPrioritized = true})
network:create("Assetify:onUnload"):on(function() syncer.public.isLibraryLoaded = false end, {isPrioritized = true})
network:create("Assetify:onModuleLoad"):on(function() syncer.public.isModuleLoaded = true end, {isPrioritized = true})
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

if localPlayer then
    settings.assetPacks = {}
    syncer.private.scheduledAssets = {}
    network:create("Assetify:onAssetLoad")
    network:create("Assetify:onAssetUnload")
    syncer.private.execOnLoad(function() network:emit("Assetify:Syncer:onLoadClient", true, false, localPlayer) end)

    function syncer.private:setElementModel(element, assetType, assetName, assetClump, clumpMaps, remotesign)
        if not element or (not remotesign and not imports.isElement(element)) then return false end
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
                shader.clearElementBuffer(element, "Assetify | Clump")
                local cAsset = manager:getAssetData(assetType, assetName, syncer.public.librarySerial)
                if cAsset and cAsset.manifest.shaderMaps and cAsset.manifest.shaderMaps[asset.reference.clump] then
                    for i, j in imports.pairs(clumpMaps) do
                        if cAsset.manifest.shaderMaps[asset.reference.clump][i] and cAsset.manifest.shaderMaps[asset.reference.clump][i][j] then
                            cAsset.manifest.shaderMaps[asset.reference.clump][i][j].prelight = cAsset.manifest.shaderMaps[asset.reference.clump][i].prelight
                            shader:create(element, "Assetify | Clump", "Assetify_Tex_Clump", i, {clumpTex = cAsset.manifest.shaderMaps[asset.reference.clump][i][j].clump, clumpTex_bump = cAsset.manifest.shaderMaps[asset.reference.clump][i][j].bump}, {}, cAsset.unsynced.raw.map, cAsset.manifest.shaderMaps[asset.reference.clump][i][j], _, _, _, syncer.public.librarySerial)
                        end
                    end
                end
            end
            imports.setElementModel(element, modelID)
        end, settings.downloader.buildRate)
        return true
    end
else
    syncer.public.libraryVersion = imports.getResourceInfo(syncer.public.libraryResource, "version")
    syncer.public.libraryVersion = (syncer.public.libraryVersion and "v."..syncer.public.libraryVersion) or false
    syncer.public.libraryModules = {}
    syncer.public.libraryClients = {loaded = {}, scheduled = {}}
    network:create("Assetify:Syncer:onLoadClient"):on(function(source)
        syncer.public.libraryClients.loaded[source] = true
        network:emit("Assetify:Syncer:onSyncPostPool", false, source)
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
            if j then syncer.private:setElementModel(i, j.assetType, j.assetName, j.assetClump, j.clumpMaps, j.remotesign, source) end
            thread:pause()
        end
    end, {isAsync = true})

    function syncer.private:loadClient(player)
        if syncer.public.libraryClients.loaded[player] then return false end
        if not syncer.public.isLibraryLoaded then
            syncer.public.libraryClients.scheduled[player] = true
        else
            syncer.public.libraryClients.scheduled[player] = nil
            thread:create(function()
                try({
                    exec = function(self)
                        self:await(rest:post(syncer.public.libraryWebserver.."/onSyncPeer?token="..syncer.public.libraryToken, {peer = getPlayerSerial(player), state = true}))
                        syncer.private:syncPack(player, _, true)
                    end,
                    catch = function()
                        imports.outputDebugString("Assetify: Webserver ━│  Failed to whitelist Peer: "..getPlayerSerial(player).."...")
                    end
                })
            end):resume()
        end
        return true
    end

    function syncer.private:setElementModel(element, assetType, assetName, assetClump, clumpMaps, remotesign, targetPlayer)
        if targetPlayer then return network:emit("Assetify:Syncer:onSyncElementModel", true, false, targetPlayer, element, assetType, assetName, assetClump, clumpMaps, remotesign) end
        if not element or not imports.isElement(element) then return false end
        local elementType = imports.getElementType(element)
        elementType = (((elementType == "ped") or (elementType == "player")) and "ped") or elementType
        if not settings.assetPacks[assetType] or not settings.assetPacks[assetType].assetType or (settings.assetPacks[assetType].assetType ~= elementType) then return false end
        local cAsset = manager:getAssetData(assetType, assetName)
        if not cAsset or (cAsset.manifest.assetClumps and (not assetClump or not cAsset.manifest.assetClumps[assetClump])) then return false end
        remotesign = imports.getElementType(element)
        syncer.public.syncedElements[element] = {assetType = assetType, assetName = assetName, assetClump = assetClump, clumpMaps = clumpMaps, remotesign = remotesign}
        thread:create(function(self)
            for i, j in imports.pairs(syncer.public.libraryClients.loaded) do
                syncer.private:setElementModel(element, assetType, assetName, assetClump, clumpMaps, remotesign, i)
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
        if not syncer.public.isLibraryLoaded then return false end
        rest:post(syncer.public.libraryWebserver.."/onSyncPeer?token="..syncer.public.libraryToken, {peer = getPlayerSerial(source), state = false})
        syncer.public.libraryClients.loaded[source] = nil
        syncer.public.libraryClients.scheduled[source] = nil
    end)
end