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
    isLibraryBooted = false,
    isLibraryLoaded = false,
    isModuleLoaded = false,
    libraryBandwidth = 0,
    syncedElements = {},
    syncedElementTones = {}
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
                shader.clearElementBuffer(element, "Assetify | Clump")
                local cAsset = manager:getAssetData(assetType, assetName, syncer.public.librarySerial)
                if cAsset and cAsset.manifestData.shaderMaps and cAsset.manifestData.shaderMaps[(asset.references.clump)] then
                    for i, j in imports.pairs(clumpMaps) do
                        if cAsset.manifestData.shaderMaps[(asset.references.clump)][i] and cAsset.manifestData.shaderMaps[(asset.references.clump)][i][j] then
                            cAsset.manifestData.shaderMaps[(asset.references.clump)][i][j].prelight = cAsset.manifestData.shaderMaps[(asset.references.clump)][i].prelight
                            shader:create(element, "Assetify | Clump", "Assetify_TextureClumper", i, {clumpTex = cAsset.manifestData.shaderMaps[(asset.references.clump)][i][j].clump, clumpTex_bump = cAsset.manifestData.shaderMaps[(asset.references.clump)][i][j].bump}, {}, cAsset.unSynced.rwCache.map, cAsset.manifestData.shaderMaps[(asset.references.clump)][i][j], cAsset.manifestData.encryptKey, _, _, _, syncer.public.librarySerial)
                        end
                    end
                    if syncer.public.syncedElementTones[element] and syncer.public.syncedElementTones[element][assetType] and syncer.public.syncedElementTones[element][assetType][assetName] then
                        for i, j in imports.pairs(syncer.public.syncedElementTones[element][assetType][assetName]) do
                            if j.bump then syncer.private:setElementTone(element, assetType, assetName, i, j.bump, true) end
                            syncer.private:setElementTone(element, assetType, assetName, i, j, false)
                        end
                    end
                end
            end
            imports.setElementModel(element, modelID)
        end, settings.downloader.buildRate)
        return true
    end

    function syncer.private:setElementTone(element, assetType, assetName, textureName, tone, isBumpTone, remoteSignature)
        if not element or (not remoteSignature and not imports.isElement(element)) then return false end
        if not textureName or not tone or (imports.type(tone) ~= "table") then return false end
        local cAsset = manager:getAssetData(assetType, assetName)
        if not cAsset or not cAsset.manifestData.assetClumps or not cAsset.manifestData.shaderMaps or not cAsset.manifestData.shaderMaps[(asset.references.clump)] or not cAsset.manifestData.shaderMaps[(asset.references.clump)][textureName] then return false end
        isBumpTone = (isBumpTone and true) or false
        tone[1] = math.max(0, math.min(100, imports.tonumber(tone[1]) or 0))
        tone[2] = math.max(0, math.min(100, imports.tonumber(tone[2]) or 0))
        syncer.public.syncedElementTones[element] = syncer.public.syncedElementTones[element] or {}
        syncer.public.syncedElementTones[element][assetType] = syncer.public.syncedElementTones[element][assetType] or {}
        syncer.public.syncedElementTones[element][assetType][assetName] = syncer.public.syncedElementTones[element][assetType][assetName] or {}
        syncer.public.syncedElementTones[element][assetType][assetName][textureName] = syncer.public.syncedElementTones[element][assetType][assetName][textureName] or {}
        if isBumpTone then syncer.public.syncedElementTones[element][assetType][assetName][textureName].bump = syncer.public.syncedElementTones[element][assetType][assetName][textureName].bump or {} end
        local ref = syncer.public.syncedElementTones[element][assetType][assetName][textureName]
        ref = (isBumpTone and ref.bump) or ref
        ref[1], ref[2] = tone[1], tone[2]
        thread:createHeartbeat(function()
            return not imports.isElement(element)
        end, function()
            local cShader = shader:fetchInstance(element, asset.references.clump, textureName)
            if cShader then cShader:setValue((isBumpTone and "clumpTone_bump") or "clumpTone", {(15 + (85*tone[1]*0.01))*0.01, (25 + (25*tone[2]*0.01))*0.01}) end
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
            if j then syncer.private:setElementModel(i, j.assetType, j.assetName, j.assetClump, j.clumpMaps, j.remoteSignature, source) end
            thread:pause()
        end
        for i, j in imports.pairs(syncer.public.syncedElementTones) do
            if j then
                for k, v in imports.pairs(j) do
                    if k ~= "remoteSignature" then
                        for m, n in imports.pairs(v) do
                            for x, y in imports.pairs(n) do
                                if y.bump then syncer.private:setElementTone(i, k, m, x, y.bump, true, j.remoteSignature, source) end
                                syncer.private:setElementTone(i, k, m, x, y, false, j.remoteSignature, source)
                            end
                        end
                    end
                end
            end
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
                    catch = function() imports.outputDebugString("Assetify: Webserver ━│  Failed to whitelist Peer: "..getPlayerSerial(player).."...") end
                })
            end):resume()
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

    function syncer.private:setElementTone(element, assetType, assetName, textureName, tone, isBumpTone, remoteSignature, targetPlayer)
        if targetPlayer then return network:emit("Assetify:Syncer:onSyncElementTone", true, false, targetPlayer, element, assetType, assetName, textureName, tone, isBumpTone, remoteSignature) end
        if not element or not imports.isElement(element) then return false end
        if not textureName or not tone or (imports.type(tone) ~= "table") then return false end
        local cAsset = manager:getAssetData(assetType, assetName)
        if not cAsset or not cAsset.manifestData.assetClumps or not cAsset.manifestData.shaderMaps or not cAsset.manifestData.shaderMaps[(asset.references.clump)] or not cAsset.manifestData.shaderMaps[(asset.references.clump)][textureName] then return false end
        isBumpTone = (isBumpTone and true) or false
        tone[1] = math.max(0, math.min(100, imports.tonumber(tone[1]) or 0))
        tone[2] = math.max(0, math.min(100, imports.tonumber(tone[2]) or 0))
        remoteSignature = imports.getElementType(element)
        syncer.public.syncedElementTones[element] = syncer.public.syncedElementTones[element] or {remoteSignature = remoteSignature}
        syncer.public.syncedElementTones[element][assetType] = syncer.public.syncedElementTones[element][assetType] or {}
        syncer.public.syncedElementTones[element][assetType][assetName] = syncer.public.syncedElementTones[element][assetType][assetName] or {}
        syncer.public.syncedElementTones[element][assetType][assetName][textureName] = syncer.public.syncedElementTones[element][assetType][assetName][textureName] or {}
        if isBumpTone then syncer.public.syncedElementTones[element][assetType][assetName][textureName].bump = syncer.public.syncedElementTones[element][assetType][assetName][textureName].bump or {} end
        local ref = syncer.public.syncedElementTones[element][assetType][assetName][textureName]
        ref = (isBumpTone and ref.bump) or ref
        ref[1], ref[2] = tone[1], tone[2]
        thread:create(function(self)
            for i, j in imports.pairs(syncer.public.libraryClients.loaded) do
                syncer.private:setElementTone(element, assetType, assetName, textureName, tone, isBumpTone, remoteSignature, i)
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
function syncer.public.syncElementTone(length, ...) return syncer.private:setElementTone(table.unpack(table.pack(...), length or 6)) end
if localPlayer then
    network:create("Assetify:Syncer:onSyncElementModel"):on(function(...) syncer.public.syncElementModel(6, ...) end)
    network:create("Assetify:Syncer:onSyncElementTone"):on(function(...) syncer.public.syncElementTone(7, ...) end)
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
            syncer.public.syncedElementTones[source] = nil
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