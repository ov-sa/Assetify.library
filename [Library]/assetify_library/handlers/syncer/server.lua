----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: syncer: server.lua
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
    type = type,
    pairs = pairs,
    addEventHandler = addEventHandler,
    triggerLatentClientEvent = triggerLatentClientEvent,
    table = {
        clone = table.clone,
        insert = table.insert
    }
}


-------------------
--[[ Variables ]]--
-------------------

isLibraryLoaded = false
CSyncer = {
    scheduled = {},
    methods = {
        syncData = function(player, assetType, assetName, dataIndexes, data)
            if not data then return false end
            if not dataIndexes then
                imports.triggerLatentClientEvent(player, "onClientRecieveAssetPack", downloadSettings.speed, false, player, assetType, assetName, data)
            else
                imports.triggerLatentClientEvent(player, "onClientRecieveAssetPack", downloadSettings.speed, false, player, assetType, assetName, nil, dataIndexes, data)
            end
            return true
        end,

        syncRWMap = function(player, assetType, assetName, dataIndexes, rwMap)
            if not rwMap then return false end
            for i, j in imports.pairs(rwMap) do
                if j and imports.type(j) == "table" then
                    local clonedDataIndex = imports.table.clone(dataIndexes, false)
                    imports.table.insert(clonedDataIndex, i)
                    CSyncer.methods.syncRWMap(player, assetType, assetName, clonedDataIndex, rwMap[i])
                else
                    imports.triggerLatentClientEvent(player, "onClientRecieveAssetPack", downloadSettings.speed, false, player, assetType, assetName, nil, dataIndexes, i)
                    thread.pause()
                end
            end
            return true
        end,

        syncRWData = function(player, assetType, assetName, dataIndexes, rwData)
            if not rwData then return false end
            for i, j in imports.pairs(rwData) do
                local clonedDataIndex = imports.table.clone(dataIndexes, false)
                imports.table.insert(clonedDataIndex, i)
                imports.triggerLatentClientEvent(player, "onClientRecieveAssetPack", downloadSettings.speed, false, player, assetType, assetName, nil, clonedDataIndex, j)
                thread.pause()
            end
            return true
        end,

        syncSceneRWData = function(player, assetType, assetName, dataIndexes, rwData)
            if not rwData then return false end
            for i, j in imports.pairs(rwData) do
                local clonedDataIndex = imports.table.clone(dataIndexes, false)
                imports.table.insert(clonedDataIndex, i)
                if i ~= "children" then
                    CSyncer.methods.syncData(player, assetType, assetName, clonedDataIndex, j)
                else
                    for k, v in imports.pairs(j) do
                        imports.table.insert(clonedDataIndex, k)
                        for m, n in imports.pairs(v) do
                            local reclonedDataIndex = imports.table.clone(clonedDataIndex, false)
                            imports.table.insert(reclonedDataIndex, m)
                            if m ~= "rwData" then
                                CSyncer.methods.syncData(player, assetType, assetName, reclonedDataIndex, v)
                            else
                                CSyncer.methods.syncRWData(player, assetType, assetName, reclonedDataIndex, v)
                            end
                            thread.pause()
                        end
                        thread.pause()
                    end
                end
                thread.pause()
            end
            return true
        end,

        syncPack = function(player)
            thread:create(function(cThread)
                for i, j in imports.pairs(availableAssetPacks) do
                    for k, v in imports.pairs(j.assetPack) do
                        if k ~= "rwDatas" then
                            CSyncer.methods.syncData(player, i, k, nil, v)
                        else
                            for m, n in imports.pairs(v) do
                                for x, y in imports.pairs(n) do
                                    local syncerFunction = false
                                    if x == "rwMap" then
                                        syncerFunction = CSyncer.methods.syncRWMap
                                    elseif x ~= "rwData" then
                                        syncerFunction = CSyncer.methods.syncData
                                    else
                                        if i == "scene" then
                                            syncerFunction = CSyncer.methods.syncSceneRWData
                                        else
                                            syncerFunction = CSyncer.methods.syncRWData
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
    }
}


-----------------------------------------------
--[[ Events: On Player Resource-Start/Quit ]]--
-----------------------------------------------

function onLibraryLoaded()

    isLibraryLoaded = true
    for i, j in imports.pairs(CSyncer.scheduled) do
        CSyncer.methods.syncPack(i)
        CSyncer.scheduled[i] = nil
    end
    
end

imports.addEventHandler("onPlayerResourceStart", root, function()

    if isLibraryLoaded then
        CSyncer.methods.syncPack(source)
    else
        CSyncer.scheduled[source] = true
    end

end)

imports.addEventHandler("onPlayerQuit", root, function()

    CSyncer.scheduled[source] = nil

end)