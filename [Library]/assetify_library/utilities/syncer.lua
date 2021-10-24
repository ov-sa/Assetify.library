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
    triggerLatentClientEvent = triggerLatentClientEvent,
    table = {
        clone = table.clone,
        insert = table.insert
    }
}


----------------------
--[[ Class: Syncer ]]--
----------------------

syncer = {}
syncer.__index = syncer

if localPlayer then
    
else
    syncer.scheduledClients = {}
    function syncer:syncData(player, assetType, assetName, dataIndexes, data)

        if not data then return false end

        if not dataIndexes then
            imports.triggerLatentClientEvent(player, "onClientRecieveAssetPack", downloadSettings.speed, false, player, assetType, assetName, data)
        else
            imports.triggerLatentClientEvent(player, "onClientRecieveAssetPack", downloadSettings.speed, false, player, assetType, assetName, nil, dataIndexes, data)
        end
        return true

    end

    function syncer:syncRWMap(player, assetType, assetName, dataIndexes, rwMap)

        if not rwMap then return false end

        for i, j in imports.pairs(rwMap) do
            if j and imports.type(j) == "table" then
                local clonedDataIndex = imports.table.clone(dataIndexes, false)
                imports.table.insert(clonedDataIndex, i)
                syncer:syncRWMap(player, assetType, assetName, clonedDataIndex, rwMap[i])
            else
                imports.triggerLatentClientEvent(player, "onClientRecieveAssetPack", downloadSettings.speed, false, player, assetType, assetName, nil, dataIndexes, i)
                thread.pause()
            end
        end
        return true

    end

    function syncer:syncRWData(player, assetType, assetName, dataIndexes, rwData)

        if not rwData then return false end

        for i, j in imports.pairs(rwData) do
            local clonedDataIndex = imports.table.clone(dataIndexes, false)
            imports.table.insert(clonedDataIndex, i)
            imports.triggerLatentClientEvent(player, "onClientRecieveAssetPack", downloadSettings.speed, false, player, assetType, assetName, nil, clonedDataIndex, j)
            thread.pause()
        end
        return true

    end

    function syncer:syncSceneRWData(player, assetType, assetName, dataIndexes, rwData)

        if not rwData then return false end

        for i, j in imports.pairs(rwData) do
            local clonedDataIndex = imports.table.clone(dataIndexes, false)
            imports.table.insert(clonedDataIndex, i)
            if i ~= "children" then
                syncer:syncData(player, assetType, assetName, clonedDataIndex, j)
            else
                for k, v in imports.pairs(j) do
                    imports.table.insert(clonedDataIndex, k)
                    for m, n in imports.pairs(v) do
                        local reclonedDataIndex = imports.table.clone(clonedDataIndex, false)
                        imports.table.insert(reclonedDataIndex, m)
                        if m ~= "rwData" then
                            syncer:syncData(player, assetType, assetName, reclonedDataIndex, v)
                        else
                            syncer:syncRWData(player, assetType, assetName, reclonedDataIndex, v)
                        end
                        thread.pause()
                    end
                    thread.pause()
                end
            end
            thread.pause()
        end
        return true

    end

    function syncer:syncPack(player)

        thread:create(function(cThread)
            for i, j in imports.pairs(availableAssetPacks) do
                for k, v in imports.pairs(j.assetPack) do
                    if k ~= "rwDatas" then
                        syncer:syncData(player, i, k, nil, v)
                    else
                        for m, n in imports.pairs(v) do
                            for x, y in imports.pairs(n) do
                                local syncerFunction = false
                                if x == "rwMap" then
                                    syncerFunction = syncer.syncRWMap
                                elseif x ~= "rwData" then
                                    syncerFunction = syncer.syncData
                                else
                                    if i == "scene" then
                                        syncerFunction = syncer.syncSceneRWData
                                    else
                                        syncerFunction = syncer.syncRWData
                                    end
                                end
                                syncerFunction(player, i, k, {m, x}, y)
                                thread.pause()
                            end
                            thread.pause()
                        end
                    end
                    thread.pause()
                end
            end
            imports.triggerLatentClientEvent(player, "onClientLoadAssetPack", downloadSettings.speed, false, player)
        end):resume({
            executions = downloadSettings.syncRate,
            frames = 1
        })
        return true

    end
end