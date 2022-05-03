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
    tostring = tostring,
    isElement = isElement,
    getRealTime = getRealTime,
    getResourceName = getResourceName,
    getElementsByType = getElementsByType,
    setElementModel = setElementModel,
    collectgarbage = collectgarbage,
    addEvent = addEvent,
    addEventHandler = addEventHandler,
    removeEventHandler = removeEventHandler,
    getResourceRootElement = getResourceRootElement,
    triggerEvent = triggerEvent,
    triggerClientEvent = triggerClientEvent,
    triggerServerEvent = triggerServerEvent,
    triggerLatentClientEvent = triggerLatentClientEvent,
    triggerLatentServerEvent = triggerLatentServerEvent,
    loadAsset = loadAsset,
    toJSON = toJSON,
    file = file
}


-----------------------
--[[ Class: Syncer ]]--
-----------------------

syncer = {
    isLibraryLoaded = false,
    isModuleLoaded = false,
    libraryName = imports.getResourceName(resource),
    librarySerial = imports.md5(imports.getResourceName(resource)..":"..imports.tostring(resource)..":"..imports.toJSON(imports.getRealTime())),
    libraryBandwidth = 0
}
syncer.__index = syncer

imports.addEvent("onAssetifyLoad", true)
imports.addEvent("onAssetifyUnLoad", false)
imports.addEvent("onAssetifyModuleLoad", true)
syncer.execOnLoad = function(execFunc)
    local execWrapper = nil
    execWrapper = function()
        execFunc()
        imports.removeEventHandler("onAssetifyModuleLoad", root, execWrapper)
    end
    imports.addEventHandler("onAssetifyModuleLoad", root, execWrapper)
    return true
end
syncer.execOnModuleLoad = function(execFunc)
    local execWrapper = nil
    execWrapper = function()
        execFunc()
        imports.removeEventHandler("onAssetifyModuleLoad", root, execWrapper)
    end
    imports.addEventHandler("onAssetifyModuleLoad", root, execWrapper)
    return true
end
syncer.execOnLoad(function() syncer.isLibraryLoaded = true end)
syncer.execOnModuleLoad(function() syncer.isModuleLoaded = true end)

if localPlayer then
    syncer.scheduledAssets = {}
    availableAssetPacks = {}
    imports.addEvent("onAssetLoad", false)
    imports.addEvent("onAssetUnLoad", false)

    function syncer:syncElementModel(...)        
        return imports.triggerEvent("Assetify:onRecieveElementModel", localPlayer, ...)
    end

    function syncer:syncBoneAttachment(...)
        return imports.triggerEvent("Assetify:onRecieveBoneAttachment", localPlayer, ...)
    end

    function syncer:syncBoneDetachment(...)
        return imports.triggerEvent("Assetify:onRecieveBoneDetachment", localPlayer, ...)
    end

    function syncer:syncBoneRefreshment(...)
        return imports.triggerEvent("Assetify:onRecieveBoneRefreshment", localPlayer, ...)
    end

    function syncer:syncClearBoneAttachment(...)
        return imports.triggerEvent("Assetify:onRecieveClearBoneAttachment", localPlayer, ...)
    end

    imports.addEventHandler("onAssetifyLoad", root, function()
        imports.triggerServerEvent("Assetify:onRequestElementModels", localPlayer)
    end)

    imports.addEvent("Assetify:onRecieveBandwidth", true)
    imports.addEventHandler("Assetify:onRecieveBandwidth", root, function(libraryBandwidth)
        syncer.libraryBandwidth = libraryBandwidth
    end)

    imports.addEvent("Assetify:onRecieveHash", true)
    imports.addEventHandler("Assetify:onRecieveHash", root, function(assetType, assetName, hashes)
        if not syncer.scheduledAssets[assetType] then syncer.scheduledAssets[assetType] = {} end
        syncer.scheduledAssets[assetType][assetName] = syncer.scheduledAssets[assetType][assetName] or {
            assetSize = 0
        }
        thread:create(function(cThread)
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
                thread.pause()
            end
            imports.triggerLatentServerEvent("Assetify:onRecieveHash", downloadSettings.speed, false, localPlayer, assetType, assetName, fetchFiles)
            imports.collectgarbage()
        end):resume({
            executions = downloadSettings.buildRate,
            frames = 1
        })
    end)

    imports.addEvent("Assetify:onRecieveData", true)
    imports.addEventHandler("Assetify:onRecieveData", root, function(assetType, baseIndex, subIndexes, indexData)
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

    imports.addEvent("Assetify:onRecieveContent", true)
    imports.addEventHandler("Assetify:onRecieveContent", root, function(assetType, assetName, contentPath, ...)
        if assetType and assetName then
            syncer.scheduledAssets[assetType][assetName].assetSize = syncer.scheduledAssets[assetType][assetName].assetSize + availableAssetPacks[assetType].rwDatas[assetName].assetSize.file[contentPath]
            syncer.__libraryBandwidth = (syncer.__libraryBandwidth or 0) + availableAssetPacks[assetType].rwDatas[assetName].assetSize.file[contentPath]
        end
        imports.file.write(contentPath, ...)
        imports.collectgarbage()
    end)

    imports.addEvent("Assetify:onRecieveState", true)
    imports.addEventHandler("Assetify:onRecieveState", root, function(assetType, assetName)
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
                    imports.triggerServerEvent("Assetify:onRequestAssets", localPlayer)
                    thread:create(function(cThread)
                        if availableAssetPacks["module"].autoLoad and availableAssetPacks["module"].rwDatas then
                            for i, j in imports.pairs(availableAssetPacks["module"].rwDatas) do
                                if j then
                                    imports.loadAsset("module", i)
                                end
                                thread.pause()
                            end
                        end
                        imports.triggerEvent("onAssetifyModuleLoad", localPlayer)
                    end):resume({
                        executions = downloadSettings.buildRate,
                        frames = 1
                    })
                else
                    syncer.scheduledAssets = nil
                    imports.triggerEvent("onAssetifyLoad", resourceRoot)
                    thread:create(function(cThread)
                        for i, j in imports.pairs(availableAssetPacks) do
                            if i ~= "module" then
                                if j.autoLoad and j.rwDatas then
                                    for k, v in imports.pairs(j.rwDatas) do
                                        if v then
                                            imports.loadAsset(i, k)
                                        end
                                        thread.pause()
                                    end
                                end
                            end
                        end
                    end):resume({
                        executions = downloadSettings.buildRate,
                        frames = 1
                    })
                end
            end
        end
    end)

    imports.addEvent("Assetify:onRecieveElementModel", true)
    imports.addEventHandler("Assetify:onRecieveElementModel", root, function(element, assetType, assetName, assetClump, clumpMaps)
        if not element or not imports.isElement(element) then return false end
        local modelID = manager:getID(assetType, assetName, assetClump)
        if modelID then
            shader:clearElementBuffer(element, "clump")
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
        end
    end)

    imports.addEvent("Assetify:onRecieveBoneAttachment", true)
    imports.addEventHandler("Assetify:onRecieveBoneAttachment", root, function(...)
        bone:create(...)
    end)

    imports.addEvent("Assetify:onRecieveBoneDetachment", true)
    imports.addEventHandler("Assetify:onRecieveBoneDetachment", root, function(element)
        if not element or not imports.isElement(element) or not bone.buffer.element[element] then return false end
        bone.buffer.element[element]:destroy()
    end)

    imports.addEvent("Assetify:onRecieveBoneRefreshment", true)
    imports.addEventHandler("Assetify:onRecieveBoneRefreshment", root, function(element, ...)
        if not element or not imports.isElement(element) or not bone.buffer.element[element] then return false end
        bone.buffer.element[element]:refresh(...)
    end)

    imports.addEvent("Assetify:onRecieveClearBoneAttachment", true)
    imports.addEventHandler("Assetify:onRecieveClearBoneAttachment", root, function(element, ...)
        if not element or not imports.isElement(element) or not bone.buffer.element[element] then return false end
        bone.buffer.element[element]:clearElementBuffer(...)
    end)

    imports.addEventHandler("onClientElementDimensionChange", localPlayer, function(dimension) streamer:update(dimension) end)
    imports.addEventHandler("onClientElementInteriorChange", localPlayer, function(interior) streamer:update(_, interior) end)
else
    syncer.loadedClients = {}
    syncer.scheduledClients = {}
    syncer.syncedElements = {}
    syncer.syncedBoneAttachments = {}

    function syncer:syncHash(player, ...)
        return imports.triggerLatentClientEvent(player, "Assetify:onRecieveHash", downloadSettings.speed, false, player, ...)
    end

    function syncer:syncData(player, ...)
        return imports.triggerLatentClientEvent(player, "Assetify:onRecieveData", downloadSettings.speed, false, player, ...)
    end

    function syncer:syncContent(player, ...)
        return imports.triggerLatentClientEvent(player, "Assetify:onRecieveContent", downloadSettings.speed, false, player, ...)
    end

    function syncer:syncState(player, ...)
        return imports.triggerLatentClientEvent(player, "Assetify:onRecieveState", downloadSettings.speed, false, player, ...)
    end

    function syncer:syncElementModel(element, assetType, assetName, assetClump, clumpMaps, targetPlayer)
        if not targetPlayer then
            if not element or not imports.isElement(element) then return false end
            local cAsset = manager:getData(assetType, assetName)
            if not cAsset or (cAsset.manifestData.assetClumps and (not assetClump or not cAsset.manifestData.assetClumps[assetClump])) then return false end
            syncer.syncedElements[element] = {type = assetType, name = assetName, clump = assetClump, clumpMaps = clumpMaps}
            thread:create(function(cThread)
                for i, j in imports.pairs(syncer.loadedClients) do
                    syncer:syncElementModel(element, assetType, assetName, assetClump, clumpMaps, i)
                    thread.pause()
                end
            end):resume({
                executions = downloadSettings.syncRate,
                frames = 1
            })
        else
            imports.triggerClientEvent(targetPlayer, "Assetify:onRecieveElementModel", targetPlayer, element, assetType, assetName, assetClump, clumpMaps)
        end
        return true
    end

    function syncer:syncBoneAttachment(element, parent, boneData, targetPlayer)
        if not targetPlayer then
            if not element or not imports.isElement(element) or not parent or not imports.isElement(parent) or not boneData then return false end
            syncer.syncedBoneAttachments[element] = {parent = parent, boneData = boneData}
            thread:create(function(cThread)
                for i, j in imports.pairs(syncer.loadedClients) do
                    syncer:syncBoneAttachment(element, parent, boneData, j)
                    thread.pause()
                end
            end):resume({
                executions = downloadSettings.syncRate,
                frames = 1
            })
        else
            imports.triggerClientEvent(targetPlayer, "Assetify:onRecieveBoneAttachment", targetPlayer, element, parent, boneData)
        end
        return true
    end

    function syncer:syncBoneDetachment(element, targetPlayer)
        if not targetPlayer then
            if not element or not imports.isElement(element) or not syncer.syncedBoneAttachments[element] then return false end
            syncer.syncedBoneAttachments[element] = nil
            thread:create(function(cThread)
                for i, j in imports.pairs(syncer.loadedClients) do
                    syncer:syncBoneDetachment(element, j)
                    thread.pause()
                end
            end):resume({
                executions = downloadSettings.syncRate,
                frames = 1
            })
        else
            imports.triggerClientEvent(targetPlayer, "Assetify:onRecieveBoneDetachment", targetPlayer, element)
        end
        return true
    end

    function syncer:syncBoneRefreshment(element, boneData, targetPlayer)
        if not targetPlayer then
            if not element or not imports.isElement(element) or not boneData or not syncer.syncedBoneAttachments[element] then return false end
            syncer.syncedBoneAttachments[element].boneData = boneData
            thread:create(function(cThread)
                for i, j in imports.pairs(syncer.loadedClients) do
                    syncer:syncBoneRefreshment(element, boneData, j)
                    thread.pause()
                end
            end):resume({
                executions = downloadSettings.syncRate,
                frames = 1
            })
        else
            imports.triggerClientEvent(targetPlayer, "Assetify:onRecieveBoneRefreshment", targetPlayer, element, boneData)
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
            thread:create(function(cThread)
                for i, j in imports.pairs(syncer.loadedClients) do
                    syncer:syncClearBoneAttachment(element, j)
                    thread.pause()
                end
            end):resume({
                executions = downloadSettings.syncRate,
                frames = 1
            })
        else
            imports.triggerClientEvent(targetPlayer, "Assetify:onRecieveClearBoneAttachment", targetPlayer, element)
        end
        return true
    end

    function syncer:syncPack(player, assetDatas, syncModules)
        if not assetDatas then
            thread:create(function(cThread)
                if syncModules then
                    local isModuleVoid = true
                    imports.triggerClientEvent(player, "Assetify:onRecieveBandwidth", player, syncer.libraryBandwidth)
                    if availableAssetPacks["module"] and availableAssetPacks["module"].assetPack then
                        for i, j in imports.pairs(availableAssetPacks["module"].assetPack) do
                            if i ~= "rwDatas" then
                                syncer:syncData(player, "module", i, nil, j)
                            else
                                for k, v in imports.pairs(j) do
                                    isModuleVoid = false
                                    syncer:syncData(player, "module", "rwDatas", {k, "assetSize"}, v.synced.assetSize)
                                    syncer:syncHash(player, "module", k, v.unSynced.fileHash)
                                    thread.pause()
                                end
                            end
                            thread.pause()
                        end
                    end
                    if isModuleVoid then
                        imports.triggerClientEvent(player, "onAssetifyModuleLoad", player)
                        imports.triggerEvent("Assetify:onRequestAssets", player)
                    end
                else
                    local isLibraryVoid = true
                    for i, j in imports.pairs(availableAssetPacks) do
                        if i ~= "module" then
                            if j.assetPack then
                                for k, v in imports.pairs(j.assetPack) do
                                    if k ~= "rwDatas" then
                                        syncer:syncData(player, i, k, nil, v)
                                    else
                                        for m, n in imports.pairs(v) do
                                            isLibraryVoid = false
                                            syncer:syncData(player, i, "rwDatas", {m, "assetSize"}, n.synced.assetSize)
                                            syncer:syncHash(player, i, m, n.unSynced.fileHash)
                                            thread.pause()
                                        end
                                    end
                                    thread.pause()
                                end
                            end
                        end
                    end
                    if isLibraryVoid then imports.triggerClientEvent(player, "onAssetifyLoad", resourceRoot) end
                end
            end):resume({
                executions = downloadSettings.syncRate,
                frames = 1
            })
        else
            thread:create(function(cThread)
                local cAsset = availableAssetPacks[(assetDatas.type)].assetPack.rwDatas[(assetDatas.name)]
                for i, j in imports.pairs(cAsset.synced) do
                    if i ~= "assetSize" then
                        syncer:syncData(player, assetDatas.type, "rwDatas", {assetDatas.name, i}, j)
                    end
                    thread.pause()
                end
                for i, j in imports.pairs(assetDatas.hashes) do
                    syncer:syncContent(player, assetDatas.type, assetDatas.name, i, cAsset.unSynced.fileData[i])
                    thread.pause()
                end
                syncer:syncState(player, assetDatas.type, assetDatas.name)
            end):resume({
                executions = downloadSettings.syncRate,
                frames = 1
            })
        end
        return true
    end

    imports.addEvent("Assetify:onRecieveHash", true)
    imports.addEventHandler("Assetify:onRecieveHash", root, function(assetType, assetName, hashes)
        syncer:syncPack(source, {
            type = assetType,
            name = assetName,
            hashes = hashes
        })
    end)

    imports.addEvent("Assetify:onRequestAssets", true)
    imports.addEventHandler("Assetify:onRequestAssets", root, function()
        syncer:syncPack(source, _)
    end)

    imports.addEvent("Assetify:onRequestElementModels", true)
    imports.addEventHandler("Assetify:onRequestElementModels", root, function()
        thread:create(function(cThread)
            for i, j in imports.pairs(syncer.syncedElements) do
                if j then
                    syncer:syncElementModel(i, j.type, j.name, j.clump, j.clumpMaps, source)
                end
                thread.pause()
            end
            for i, j in imports.pairs(syncer.syncedBoneAttachments) do
                if j then
                    syncer:syncBoneAttachment(i, j.parent, j.boneData, source)
                end
                thread.pause()
            end
        end):resume({
            executions = downloadSettings.syncRate,
            frames = 1
        })
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

    imports.addEventHandler("onElementDestroy", root, function()
        syncer.syncedElements[source] = nil
    end)
    
    imports.addEventHandler("onPlayerQuit", root, function()
        syncer.loadedClients[source] = nil
        syncer.scheduledClients[source] = nil
        syncer.syncedElements[source] = nil
        syncer:syncClearBoneAttachment(source)
        for i, j in imports.pairs(syncer.syncedBoneAttachments) do
            if j and (j.parent == source) then
                syncer:syncClearBoneAttachment(i)
            end
        end
    end)
end