----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: syncer.lua
     Author: vStudio
     Developer(s): Aviril, Tron
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
    tonumber = tonumber,
    tostring = tostring,
    isElement = isElement,
    getElementType = getElementType,
    getRealTime = getRealTime,
    getThisResource = getThisResource,
    getResourceName = getResourceName,
    getResourceInfo = getResourceInfo,
    getElementsByType = getElementsByType,
    setElementModel = setElementModel,
    getElementRotation = getElementRotation,
    collectgarbage = collectgarbage,
    outputDebugString = outputDebugString,
    addEventHandler = addEventHandler,
    getResourceRootElement = getResourceRootElement,
    fetchRemote = fetchRemote,
    loadAsset = loadAsset,
    file = file,
    json = json
}


-----------------------
--[[ Class: Syncer ]]--
-----------------------

syncer = {
    libraryResource = imports.getThisResource(),
    isLibraryLoaded = false,
    isModuleLoaded = false,
    libraryBandwidth = 0,
    syncedGlobalDatas = {},
    syncedEntityDatas = {},
    syncedElements = {},
    syncedAssetDummies = {},
    syncedBoneAttachments = {},
    syncedLights = {}
}
syncer.libraryName = imports.getResourceName(syncer.libraryResource)
syncer.librarySource = "https://api.github.com/repos/ov-sa/Assetify-Library/releases/latest"
syncer.librarySerial = imports.md5(imports.getResourceName(syncer.libraryResource)..":"..imports.tostring(syncer.libraryResource)..":"..imports.json.encode(imports.getRealTime()))
syncer.__index = syncer

network:create("Assetify:onLoad")
network:create("Assetify:onUnload")
network:create("Assetify:onModuleLoad")
syncer.execOnLoad = function(execFunc)
    local execWrapper = nil
    execWrapper = function()
        execFunc()
        network:fetch("Assetify:onLoad"):off(execWrapper)
    end
    network:fetch("Assetify:onLoad"):on(execWrapper)
    return true
end
syncer.execOnModuleLoad = function(execFunc)
    local execWrapper = nil
    execWrapper = function()
        execFunc()
        network:fetch("Assetify:onModuleLoad"):off(execWrapper)
    end
    network:fetch("Assetify:onModuleLoad"):on(execWrapper)
    return true
end
syncer.execOnLoad(function() syncer.isLibraryLoaded = true end)
syncer.execOnModuleLoad(function() syncer.isModuleLoaded = true end)

if localPlayer then
    syncer.scheduledAssets = {}
    availableAssetPacks = {}
    network:create("Assetify:onAssetLoad")
    network:create("Assetify:onAssetUnload")

    function syncer:syncElementModel(...)
        return network:emit("Assetify:onRecieveSyncedElement", false, ...)
    end

    function syncer:syncAssetDummy(...)
        return dummy:create(...)
    end

    function syncer:syncGlobalData(...)
        return network:emit("Assetify:onRecieveSyncedGlobalData", false, ...)
    end

    function syncer:syncEntityData(element, data, value)
        return network:emit("Assetify:onRecieveSyncedEntityData", false, element, data, value)
    end

    function syncer:syncBoneAttachment(...)
        return bone:create(...)
    end

    function syncer:syncBoneDetachment(element, ...)
        if not element or not bone.buffer.element[element] then return false end
        return bone.buffer.element[element]:destroy()
    end

    function syncer:syncBoneRefreshment(element, ...)
        if not element or not bone.buffer.element[element] then return false end
        return bone.buffer.element[element]:refresh(...)
    end

    function syncer:syncClearBoneAttachment(...)
        return bone:clearElementBuffer(...)
    end

    network:fetch("Assetify:onLoad"):on(function()
        network:emit("Assetify:onRequestPostSyncPool", true, false, localPlayer)
    end)

    network:create("Assetify:onRecieveBandwidth"):on(function(bandwidth)
        syncer.libraryBandwidth = bandwidth
    end)

    network:create("Assetify:onRecieveHash"):on(function(assetType, assetName, hashes)
        if not syncer.scheduledAssets[assetType] then syncer.scheduledAssets[assetType] = {} end
        syncer.scheduledAssets[assetType][assetName] = syncer.scheduledAssets[assetType][assetName] or {
            assetSize = 0
        }
        thread:create(function(self)
            local fetchFiles = {}
            for i, j in imports.pairs(hashes) do
                local fileData = imports.file.read(i)
                if not fileData or (imports.md5(fileData) ~= j) then
                    fetchFiles[i] = true
                else
                    syncer.scheduledAssets[assetType][assetName].assetSize = syncer.scheduledAssets[assetType][assetName].assetSize + availableAssetPacks[assetType].rwDatas[assetName].assetSize.file[i]
                    syncer.__libraryBandwidth = (syncer.__libraryBandwidth or 0) + availableAssetPacks[assetType].rwDatas[assetName].assetSize.file[i]
                end
                fileData = nil
                thread:pause()
            end
            network:emit("Assetify:onRecieveHash", true, true, localPlayer, assetType, assetName, fetchFiles)
            imports.collectgarbage()
        end):resume({
            executions = downloadSettings.buildRate,
            frames = 1
        })
    end)

    network:create("Assetify:onRecieveData"):on(function(assetType, baseIndex, subIndexes, indexData)
        if not availableAssetPacks[assetType] then availableAssetPacks[assetType] = {} end
        if not subIndexes then
            availableAssetPacks[assetType][baseIndex] = indexData
        else
            if not availableAssetPacks[assetType][baseIndex] then availableAssetPacks[assetType][baseIndex] = {} end
            local totalIndexes = #subIndexes
            local indexPointer = availableAssetPacks[assetType][baseIndex]
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

    network:create("Assetify:onRecieveContent"):on(function(assetType, assetName, contentPath, ...)
        if assetType and assetName then
            syncer.scheduledAssets[assetType][assetName].assetSize = syncer.scheduledAssets[assetType][assetName].assetSize + availableAssetPacks[assetType].rwDatas[assetName].assetSize.file[contentPath]
            syncer.__libraryBandwidth = (syncer.__libraryBandwidth or 0) + availableAssetPacks[assetType].rwDatas[assetName].assetSize.file[contentPath]
        end
        imports.file.write(contentPath, ...)
        imports.collectgarbage()
    end)

    network:create("Assetify:onRecieveState"):on(function(assetType, assetName)
        local isTypeVoid = true
        syncer.scheduledAssets[assetType][assetName] = nil
        for i, j in imports.pairs(syncer.scheduledAssets[assetType]) do
            if j then
                isTypeVoid = false
                break
            end
        end
        if isTypeVoid then
            local isSyncDone = true
            syncer.scheduledAssets[assetType] = nil
            for i, j in imports.pairs(syncer.scheduledAssets) do
                if j then
                    isSyncDone = false
                    break
                end
            end
            if isSyncDone then
                if assetType == "module" then
                    network:emit("Assetify:onRequestSyncPack", true, false, localPlayer)
                    thread:create(function(self)
                        if availableAssetPacks["module"].autoLoad and availableAssetPacks["module"].rwDatas then
                            for i, j in imports.pairs(availableAssetPacks["module"].rwDatas) do
                                if j then
                                    imports.loadAsset("module", i)
                                end
                                thread:pause()
                            end
                        end
                        network:emit("Assetify:onModuleLoad", false)
                    end):resume({
                        executions = downloadSettings.buildRate,
                        frames = 1
                    })
                else
                    syncer.scheduledAssets = nil
                    thread:create(function(self)
                        for i, j in imports.pairs(availableAssetPacks) do
                            if i ~= "module" then
                                if j.autoLoad and j.rwDatas then
                                    for k, v in imports.pairs(j.rwDatas) do
                                        if v then
                                            imports.loadAsset(i, k)
                                        end
                                        thread:pause()
                                    end
                                end
                            end
                        end
                        network:emit("Assetify:onLoad", false)
                    end):resume({
                        executions = downloadSettings.buildRate,
                        frames = 1
                    })
                end
            end
        end
    end)

    network:create("Assetify:onGlobalDataChange")
    network:create("Assetify:onRecieveSyncedGlobalData"):on(function(data, value)
        if not data or (imports.type(data) ~= "string") then return false end
        network:emit("Assetify:onGlobalDataChange", data, syncer.syncedGlobalDatas[data], value)
        syncer.syncedGlobalDatas[data] = value
    end)

    network:create("Assetify:onEntityDataChange")
    network:create("Assetify:onRecieveSyncedEntityData"):on(function(element, data, value, remoteSignature)
        if not element or (not remoteSignature and not imports.isElement(element)) or not data or (imports.type(data) ~= "string") then return false end
        syncer.syncedEntityDatas[element] = syncer.syncedEntityDatas[element] or {}
        network:emit("Assetify:onEntityDataChange", element, data, syncer.syncedEntityDatas[element][data], value)
        syncer.syncedEntityDatas[element][data] = value
    end)

    network:create("Assetify:onRecieveSyncedElement"):on(function(element, assetType, assetName, assetClump, clumpMaps, remoteSignature)
        if not element or (not remoteSignature and not imports.isElement(element)) then return false end
        local modelID = manager:getID(assetType, assetName, assetClump)
        if modelID then
            syncer.syncedElements[element] = {type = assetType, name = assetName, clump = assetClump, clumpMaps = clumpMaps}
            shader:clearElementBuffer(element, "clump")
            thread:createHeartbeat(function()
                return not imports.isElement(element)
            end, function()
                if clumpMaps then
                    local cAsset = manager:getData(assetType, assetName)
                    if cAsset and cAsset.manifestData.shaderMaps and cAsset.manifestData.shaderMaps.clump then
                        for i, j in imports.pairs(clumpMaps) do
                            if cAsset.manifestData.shaderMaps.clump[i] and cAsset.manifestData.shaderMaps.clump[i][j] then
                                shader:create(element, "clump", "Assetify_TextureClumper", i, {clumpTex = cAsset.manifestData.shaderMaps.clump[i][j].clump, clumpTex_bump = cAsset.manifestData.shaderMaps.clump[i][j].bump}, {}, cAsset.unSynced.rwCache.map, cAsset.manifestData.shaderMaps.clump[i][j], cAsset.manifestData.encryptKey)
                            end
                        end
                    end
                end
                imports.setElementModel(element, modelID)
            end, downloadSettings.buildRate)
        end
    end)

    network:create("Assetify:onRecieveAssetDummy"):on(function(...) syncer:syncAssetDummy(...) end)
    network:create("Assetify:onRecieveBoneAttachment"):on(function(...) syncer:syncBoneAttachment(...) end)
    network:create("Assetify:onRecieveBoneDetachment"):on(function(...) syncer:syncBoneDetachment(...) end)
    network:create("Assetify:onRecieveBoneRefreshment"):on(function(...) syncer:syncBoneRefreshment(...) end)
    network:create("Assetify:onRecieveClearBoneAttachment"):on(function(...) syncer:syncClearBoneAttachment(...) end)
    imports.addEventHandler("onClientElementDimensionChange", localPlayer, function(dimension) streamer:update(dimension) end)
    imports.addEventHandler("onClientElementInteriorChange", localPlayer, function(interior) streamer:update(_, interior) end)
    network:create("Assetify:onElementDestroy"):on(function(source)
        shader:clearElementBuffer(source)
        dummy:clearElementBuffer(source)
        bone:clearElementBuffer(source)
        manager:clearElementBuffer(source)
        syncer.syncedEntityDatas[source] = nil
        for i, j in imports.pairs(light) do
            if j and (imports.type(j) == "table") and j.clearElementBuffer then
                j:clearElementBuffer(source)
            end
        end
    end)
    imports.addEventHandler("onClientElementDestroy", root, function()
        network:emit("Assetify:onElementDestroy", false, source)
    end)
else
    syncer.libraryVersion = imports.getResourceInfo(resource, "version")
    syncer.libraryVersion = (syncer.libraryVersion and "v."..syncer.libraryVersion) or syncer.libraryVersion
    syncer.loadedClients = {}
    syncer.scheduledClients = {}

    function syncer:syncHash(player, ...)
        return network:emit("Assetify:onRecieveHash", true, false, player, ...)
    end

    function syncer:syncData(player, ...)
        return network:emit("Assetify:onRecieveData", true, false, player, ...)
    end

    function syncer:syncContent(player, ...)
        return network:emit("Assetify:onRecieveContent", true, false, player, ...)
    end

    function syncer:syncState(player, ...)
        return network:emit("Assetify:onRecieveState", true, false, player, ...)
    end

    function syncer:syncGlobalData(data, value, isSync, targetPlayer)
        if not data or (imports.type(data) ~= "string") then return false end
        if not targetPlayer then
            syncer.syncedGlobalDatas[data] = value
            local execWrapper = nil
            execWrapper = function()
                for i, j in imports.pairs(syncer.loadedClients) do
                    syncer:syncGlobalData(data, value, isSync, i)
                    if not isSync then thread:pause() end
                end
                execWrapper = nil
            end
            if isSync then
                execWrapper()
            else
                thread:create(execWrapper):resume({
                    executions = downloadSettings.syncRate,
                    frames = 1
                })
            end
        else
            network:emit("Assetify:onRecieveSyncedGlobalData", true, false, targetPlayer, data, value)
        end
        return true
    end

    function syncer:syncEntityData(element, data, value, isSync, targetPlayer, remoteSignature)
        if not targetPlayer then
            if not element or not imports.isElement(element) or not data or (imports.type(data) ~= "string") then return false end
            remoteSignature = imports.getElementType(element)
            syncer.syncedEntityDatas[element] = syncer.syncedEntityDatas[element] or {}
            syncer.syncedEntityDatas[element][data] = value
            local execWrapper = nil
            execWrapper = function()
                for i, j in imports.pairs(syncer.loadedClients) do
                    syncer:syncEntityData(element, data, value, isSync, i)
                    if not isSync then thread:pause() end
                end
                execWrapper = nil
            end
            if isSync then
                execWrapper()
            else
                thread:create(execWrapper):resume({
                    executions = downloadSettings.syncRate,
                    frames = 1
                })
            end
        else
            network:emit("Assetify:onRecieveSyncedEntityData", true, false, targetPlayer, element, data, value, remoteSignature)
        end
        return true
    end

    function syncer:syncElementModel(element, assetType, assetName, assetClump, clumpMaps, targetPlayer, remoteSignature)
        if not targetPlayer then
            if not element or not imports.isElement(element) then return false end
            local cAsset = manager:getData(assetType, assetName)
            if not cAsset or (cAsset.manifestData.assetClumps and (not assetClump or not cAsset.manifestData.assetClumps[assetClump])) then return false end
            remoteSignature = imports.getElementType(element)
            syncer.syncedElements[element] = {type = assetType, name = assetName, clump = assetClump, clumpMaps = clumpMaps}
            thread:create(function(self)
                for i, j in imports.pairs(syncer.loadedClients) do
                    syncer:syncElementModel(element, assetType, assetName, assetClump, clumpMaps, i, remoteSignature)
                    thread:pause()
                end
            end):resume({
                executions = downloadSettings.syncRate,
                frames = 1
            })
        else
            network:emit("Assetify:onRecieveSyncedElement", true, false, targetPlayer, element, assetType, assetName, assetClump, clumpMaps, remoteSignature)
        end
        return true
    end

    function syncer:syncAssetDummy(assetType, assetName, assetClump, clumpMaps, dummyData, targetPlayer, targetDummy, remoteSignature)    
        if not targetPlayer then
            targetDummy = dummy:create(assetType, assetName, assetClump, clumpMaps, dummyData)
            if not targetDummy then return false end
            remoteSignature = imports.getElementType(targetDummy)
            syncer.syncedAssetDummies[targetDummy] = {type = assetType, name = assetName, clump = assetClump, clumpMaps = clumpMaps, dummyData = dummyData}
            thread:create(function(self)
                for i, j in imports.pairs(syncer.loadedClients) do
                    syncer:syncAssetDummy(assetType, assetName, assetClump, clumpMaps, dummyData, i, targetDummy, remoteSignature)
                    thread:pause()
                end
            end):resume({
                executions = downloadSettings.syncRate,
                frames = 1
            })
            return targetDummy
        else
            network:emit("Assetify:onRecieveAssetDummy", true, false, targetPlayer, assetType, assetName, assetClump, clumpMaps, dummyData, targetDummy, remoteSignature)
        end
        return true
    end

    function syncer:syncBoneAttachment(element, parent, boneData, targetPlayer, remoteSignature)
        if not targetPlayer then
            if not element or not imports.isElement(element) or not parent or not imports.isElement(parent) or not boneData then return false end
            remoteSignature = {
                parentType = imports.getElementType(parent),
                elementType = imports.getElementType(element),
                elementRotation = {imports.getElementRotation(element, "ZYX")}
            }
            syncer.syncedBoneAttachments[element] = {parent = parent, boneData = boneData}
            thread:create(function(self)
                for i, j in imports.pairs(syncer.loadedClients) do
                    syncer:syncBoneAttachment(element, parent, boneData, i, remoteSignature)
                    thread:pause()
                end
            end):resume({
                executions = downloadSettings.syncRate,
                frames = 1
            })
        else
            network:emit("Assetify:onRecieveBoneAttachment", true, false, targetPlayer, element, parent, boneData, remoteSignature)
        end
        return true
    end

    function syncer:syncBoneDetachment(element, targetPlayer)
        if not targetPlayer then
            if not element or not imports.isElement(element) or not syncer.syncedBoneAttachments[element] then return false end
            syncer.syncedBoneAttachments[element] = nil
            thread:create(function(self)
                for i, j in imports.pairs(syncer.loadedClients) do
                    syncer:syncBoneDetachment(element, i)
                    thread:pause()
                end
            end):resume({
                executions = downloadSettings.syncRate,
                frames = 1
            })
        else
            network:emit("Assetify:onRecieveBoneDetachment", true, false, targetPlayer, element)
        end
        return true
    end

    function syncer:syncBoneRefreshment(element, boneData, targetPlayer, remoteSignature)
        if not targetPlayer then
            if not element or not imports.isElement(element) or not boneData or not syncer.syncedBoneAttachments[element] then return false end
            remoteSignature = {
                elementType = imports.getElementType(element),
                elementRotation = {imports.getElementRotation(element, "ZYX")}
            }
            syncer.syncedBoneAttachments[element].boneData = boneData
            thread:create(function(self)
                for i, j in imports.pairs(syncer.loadedClients) do
                    syncer:syncBoneRefreshment(element, boneData, i, remoteSignature)
                    thread:pause()
                end
            end):resume({
                executions = downloadSettings.syncRate,
                frames = 1
            })
        else
            network:emit("Assetify:onRecieveBoneRefreshment", true, false, targetPlayer, element, boneData, remoteSignature)
        end
        return true
    end

    function syncer:syncClearBoneAttachment(element, targetPlayer)
        if not targetPlayer then
            if not element or not imports.isElement(element) then return false end
            if syncer.syncedBoneAttachments[element] then
                syncer.syncedBoneAttachments[element] = nil                                
            end
            for i, j in imports.pairs(syncer.syncedBoneAttachments) do
                if j and (j.parent == element) then
                    syncer.syncedBoneAttachments[i] = nil
                end
            end
            thread:create(function(self)
                for i, j in imports.pairs(syncer.loadedClients) do
                    syncer:syncClearBoneAttachment(element, i)
                    thread:pause()
                end
            end):resume({
                executions = downloadSettings.syncRate,
                frames = 1
            })
        else
            network:emit("Assetify:onRecieveClearBoneAttachment", true, false, targetPlayer, element)
        end
        return true
    end

    function syncer:syncPack(player, assetDatas, syncModules)
        if not assetDatas then
            thread:create(function(self)
                if syncModules then
                    local isModuleVoid = true
                    network:emit("Assetify:onRecieveBandwidth", true, false, player, syncer.libraryBandwidth)
                    self:await(network:emitCallback(self, "Assetify:onRequestPreSyncPool", false, player))
                    if availableAssetPacks["module"] and availableAssetPacks["module"].assetPack then
                        for i, j in imports.pairs(availableAssetPacks["module"].assetPack) do
                            if i ~= "rwDatas" then
                                syncer:syncData(player, "module", i, false, j)
                            else
                                for k, v in imports.pairs(j) do
                                    isModuleVoid = false
                                    syncer:syncData(player, "module", "rwDatas", {k, "assetSize"}, v.synced.assetSize)
                                    syncer:syncHash(player, "module", k, v.unSynced.fileHash)
                                    thread:pause()
                                end
                            end
                            thread:pause()
                        end
                    end
                    if isModuleVoid then
                        network:emit("Assetify:onModuleLoad", true, false, player)
                        network:emit("Assetify:onRequestSyncPack", false, player)
                    end
                else
                    local isLibraryVoid = true
                    for i, j in imports.pairs(availableAssetPacks) do
                        if i ~= "module" then
                            if j.assetPack then
                                for k, v in imports.pairs(j.assetPack) do
                                    if k ~= "rwDatas" then
                                        syncer:syncData(player, i, k, false, v)
                                    else
                                        for m, n in imports.pairs(v) do
                                            isLibraryVoid = false
                                            syncer:syncData(player, i, "rwDatas", {m, "assetSize"}, n.synced.assetSize)
                                            syncer:syncHash(player, i, m, n.unSynced.fileHash)
                                            thread:pause()
                                        end
                                    end
                                    thread:pause()
                                end
                            end
                        end
                    end
                    if isLibraryVoid then network:emit("Assetify:onLoad", true, false, player) end
                end
            end):resume({
                executions = downloadSettings.syncRate,
                frames = 1
            })
        else
            thread:create(function(self)
                local cAsset = availableAssetPacks[(assetDatas.type)].assetPack.rwDatas[(assetDatas.name)]
                for i, j in imports.pairs(cAsset.synced) do
                    if i ~= "assetSize" then
                        syncer:syncData(player, assetDatas.type, "rwDatas", {assetDatas.name, i}, j)
                    end
                    thread:pause()
                end
                for i, j in imports.pairs(assetDatas.hashes) do
                    syncer:syncContent(player, assetDatas.type, assetDatas.name, i, cAsset.unSynced.fileData[i])
                    thread:pause()
                end
                syncer:syncState(player, assetDatas.type, assetDatas.name)
            end):resume({
                executions = downloadSettings.syncRate,
                frames = 1
            })
        end
        return true
    end

    network:create("Assetify:onRecieveHash"):on(function(source, assetType, assetName, hashes)
        syncer:syncPack(source, {
            type = assetType,
            name = assetName,
            hashes = hashes
        })
    end)

    network:create("Assetify:onRequestSyncPack"):on(function(source)
        syncer:syncPack(source)
    end)

    network:create("Assetify:onRequestPreSyncPool", true):on(function(__self, source)
        local __source = source
        thread:create(function(self)
            local source = __source
            for i, j in imports.pairs(syncer.syncedGlobalDatas) do
                syncer:syncGlobalData(i, j, false, source)
                thread:pause()
            end
            for i, j in imports.pairs(syncer.syncedEntityDatas) do
                for k, v in imports.pairs(j) do
                    syncer:syncEntityData(i, k, v, false, source)
                    thread:pause()
                end
                thread:pause()
            end
            __self:resume()
        end):resume({
            executions = downloadSettings.syncRate,
            frames = 1
        })
        __self:pause()
        return true
    end, true)

    network:create("Assetify:onRequestPostSyncPool"):on(function(source)
        local __source = source
        thread:create(function(self)
            local source = __source
            for i, j in imports.pairs(syncer.syncedElements) do
                if j then
                    syncer:syncElementModel(i, j.type, j.name, j.clump, j.clumpMaps, source)
                end
                thread:pause()
            end
            for i, j in imports.pairs(syncer.syncedAssetDummies) do
                if j then
                    syncer:syncAssetDummy(j.type, j.name, j.clump, j.clumpMaps, j.dummyData, i, source)
                end
                thread:pause()
            end
            for i, j in imports.pairs(syncer.syncedBoneAttachments) do
                if j then
                    syncer:syncBoneAttachment(i, j.parent, j.boneData, source)
                end
                thread:pause()
            end
        end):resume({
            executions = downloadSettings.syncRate,
            frames = 1
        })
    end)

    imports.fetchRemote(syncer.librarySource, function(response, status)
        if not response or not status or (status ~= 0) then return false end
        response = imports.json.decode(response)
        if response and response.tag_name and (syncer.libraryVersion ~= response.tag_name) then
            imports.outputDebugString("[Assetify]: Latest version available - "..response.tag_name, 3)
        end
    end)
    imports.addEventHandler("onPlayerResourceStart", root, function(resourceElement)
        if imports.getResourceRootElement(resourceElement) == resourceRoot then
            if syncer.isLibraryLoaded then
                syncer.loadedClients[source] = true
                syncer:syncPack(source, _, true)
            else
                syncer.scheduledClients[source] = true
            end
        end
    end)
    imports.addEventHandler("onElementModelChange", root, function()
        syncer.syncedElements[source] = nil
    end)
    imports.addEventHandler("onElementDestroy", root, function()
        local __source = source
        thread:create(function(self)
            local source = __source
            syncer.syncedGlobalDatas[source] = nil
            syncer.syncedEntityDatas[source] = nil
            syncer.syncedElements[source] = nil
            syncer.syncedAssetDummies[source] = nil
            syncer.syncedLights[source] = nil
            syncer:syncClearBoneAttachment(source)
            for i, j in imports.pairs(syncer.loadedClients) do
                network:emit("Assetify:onElementDestroy", true, false, i, source)
                thread:pause()
            end
        end):resume({
            executions = downloadSettings.syncRate,
            frames = 1
        })
    end)
    imports.addEventHandler("onPlayerQuit", root, function()
        syncer.loadedClients[source] = nil
        syncer.scheduledClients[source] = nil
    end)
end