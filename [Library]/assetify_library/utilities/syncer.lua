----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: syncer.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Syncer Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    md5 = md5,
    isElement = isElement,
    collectgarbage = collectgarbage,
    addEvent = addEvent,
    addEventHandler = addEventHandler,
    triggerLatentClientEvent = triggerLatentClientEvent,
    triggerLatentServerEvent = triggerLatentServerEvent,
    loadAsset = loadAsset,
    file = {
        read = file.read,
        write = file.write
    },
    table = {
        clone = table.clone
    }
}


-----------------------
--[[ Class: Syncer ]]--
-----------------------

syncer = {}
syncer.__index = syncer

syncer.isLibraryLoaded = false
syncer.syncedElements = {}
if localPlayer then
    syncer.scheduledAssets = {}
    availableAssetPacks = {}
    imports.addEvent("onAssetifyLoad", false)
    imports.addEvent("onAssetifyUnLoad", false)

    imports.addEvent("Assetify:onRecieveHash", true)
    imports.addEventHandler("Assetify:onRecieveHash", root, function(assetType, assetName, hashes)
        if not syncer.scheduledAssets[assetType] then syncer.scheduledAssets[assetType] = {} end
        syncer.scheduledAssets[assetType][assetName] = true
        thread:create(function(cThread)
            local fetchFiles = {}
            for i, j in imports.pairs(hashes) do
                local fileData = imports.file.read(i)
                if not fileData or (imports.md5(fileData) ~= j) then
                    fetchFiles[i] = true
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
    imports.addEventHandler("Assetify:onRecieveContent", root, function(contentPath, ...)
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
                syncer.scheduledAssets = nil
                onLibraryLoaded()
                thread:create(function(cThread)
                    for i, j in imports.pairs(availableAssetPacks) do
                        if j.autoLoad and j.rwDatas then
                            for k, v in imports.pairs(j.rwDatas) do
                                if v then
                                    imports.loadAsset(i, k)
                                end
                                thread.pause()
                            end
                        end
                    end
                end):resume({
                    executions = downloadSettings.buildRate,
                    frames = 1
                })
            end
        end
    end)
else
    syncer.scheduledClients = {}

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

    function syncer.syncModel(element, assetType, assetName)
        if not element or not imports.isElement(element) or not availableAssetPacks[assetType] or not availableAssetPacks[assetType][assetName] then return false end
        syncer.syncedElements[element] = {type = assetType, name = assetName}
        return true
    end

    function syncer:syncPack(player, assetDatas)
        if not assetDatas then
            thread:create(function(cThread)
                for i, j in imports.pairs(availableAssetPacks) do
                    for k, v in imports.pairs(j.assetPack) do
                        if k ~= "rwDatas" then
                            syncer:syncData(player, i, k, nil, v)
                        else
                            for m, n in imports.pairs(v) do
                                syncer:syncHash(player, i, m, n.unSynced.fileHash)
                                thread.pause()
                            end
                        end
                        thread.pause()
                    end
                end
            end):resume({
                executions = downloadSettings.syncRate,
                frames = 1
            })
        else
            thread:create(function(cThread)
                local assetReference = availableAssetPacks[(assetDatas.type)].assetPack.rwDatas[(assetDatas.name)]
                for i, j in imports.pairs(assetDatas.hashes) do
                    syncer:syncContent(player, i, assetReference.unSynced.fileData[i])
                    thread.pause()
                end
                for i, j in imports.pairs(assetReference.synced) do
                    syncer:syncData(player, assetDatas.type, "rwDatas", {assetDatas.name, i}, j)
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

end