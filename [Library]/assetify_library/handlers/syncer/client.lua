----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: syncer. client.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Library Syncer ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    collectgarbage = collectgarbage,
    setTimer = setTimer,
    addEvent = addEvent,
    addEventHandler = addEventHandler,
    triggerEvent = triggerEvent,
    triggerLatentServerEvent = triggerLatentServerEvent,
    loadAsset = loadAsset,
    removeWorldModel = removeWorldModel,
    restoreAllWorldModels = restoreAllWorldModels,
    createWater = createWater,
    setWaterLevel = setWaterLevel,
    setOcclusionsEnabled = setOcclusionsEnabled,
    setWorldSpecialPropertyEnabled = setWorldSpecialPropertyEnabled,
    fetchFileData = fetchFileData,
    table = {
        insert = table.insert
    }
}


-------------------
--[[ Variables ]]--
-------------------

isLibraryLoaded = false
availableAssetPacks = {}


---------------------------------------------------
--[[ Events: On Client Recieve/Load Asset Pack ]]--
---------------------------------------------------

imports.addEvent("onAssetifyLoad", false)
imports.addEvent("onAssetifyUnLoad", false)

imports.addEvent("onClientVerifyAssetHash", true)
imports.addEventHandler("onClientVerifyAssetHash", root, function(assetType, assetName, rwHash)

    if not assetType or not assetName or not rwHash then return false end

    if rwHash then
        thread:create(function(cThread)
            local fetchFiles = {}
            for i, j in imports.pairs(rwHash) do
                local fileData = imports.fetchFileData(i)
                if not fileData or (md5(fileData) ~= j) then
                    imports.table.insert(fetchFiles, i)
                end
                fileData = nil
                thread.pause()
            end
            imports.triggerLatentServerEvent("onClientRequestAssetFiles", downloadSettings.speed, false, localPlayer, assetType, assetName, fetchFiles)
            imports.collectgarbage()
        end):resume({
            executions = downloadSettings.buildRate,
            frames = 1
        })
    end

end)

imports.addEvent("onClientRecieveAssetPack", true)
imports.addEventHandler("onClientRecieveAssetPack", root, function(assetType, dataIndex, indexData, dataIndexes, subIndexData)
    
    if not assetType or not dataIndex then return false end

    if not availableAssetPacks[assetType] then
        availableAssetPacks[assetType] = {}
    end
    if dataIndex then
        if not dataIndexes then
            availableAssetPacks[assetType][dataIndex] = indexData
        else
            if not availableAssetPacks[assetType][dataIndex] then
                availableAssetPacks[assetType][dataIndex] = {}
            end
            local totalIndexes = #dataIndexes
            local indexPointer = availableAssetPacks[assetType][dataIndex]
            if totalIndexes > 1 then
                for i = 1, totalIndexes - 1, 1 do
                    local indexReference = dataIndexes[i]
                    if not indexPointer[indexReference] then
                        indexPointer[indexReference] = {}
                    end
                    indexPointer = indexPointer[indexReference]
                end
            end
            indexPointer[(dataIndexes[totalIndexes])] = subIndexData
        end
    end

end)

imports.addEvent("onClientLoadAssetPack", true)
imports.addEventHandler("onClientLoadAssetPack", root, function()

    thread:create(function(cThread)
        onLibraryLoaded()
        for i, j in imports.pairs(availableAssetPacks) do
            if j.autoLoad and j.rwDatas then
                for k, v in imports.pairs(j.rwDatas) do
                    if v then
                        print("[Loading "..i.."] : "..k)
                        imports.loadAsset(i, k, function(cAsset)
                            imports.setTimer(function()
                                cThread:resume()
                            end, 1, 1)
                        end)
                    end
                    imports.setTimer(function()
                        cThread:resume()
                    end, 1, 1)
                    thread.pause()
                end
            end
        end
    end):resume()

end)


-----------------------------------------------
--[[ Events: On Client Resource Start/Stop ]]--
-----------------------------------------------

imports.addEventHandler("onClientResourceStart", resourceRoot, function()

    if not GTAWorldSettings.removeWorld then
        imports.restoreAllWorldModels()
    else
        for i = 550, 19999, 1 do
            imports.removeWorldModel(i, 100000, 0, 0, 0)
        end
        local createdWater = imports.createWater(-3000, -3000, 0, 3000, -3000, 0, -3000, 3000, 0, 3000, 3000, 0, false)
        imports.setWaterLevel(createdWater, GTAWorldSettings.waterLevel)
    end
    imports.setWaterLevel(GTAWorldSettings.waterLevel, true, true, true, true)
    imports.setOcclusionsEnabled(not GTAWorldSettings.removeWorld)
    imports.setWorldSpecialPropertyEnabled("randomfoliage", not GTAWorldSettings.removeWorld)

end)

imports.addEventHandler("onClientResourceStop", resourceRoot, function()

    for i, j in imports.pairs(availableAssetPacks) do
        if j.autoLoad and j.rwDatas then
            for k, v in imports.pairs(j.rwDatas) do
                if v then
                    asset:refreshMaps(false, i, k, v.manifestData.shaderMaps, v.rwMap)
                end
            end
        end
    end
    imports.triggerEvent("onAssetifyUnLoad", resourceRoot)

end)