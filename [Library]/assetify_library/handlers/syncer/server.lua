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
                for k, v in imports.pairs(j) do
                    local clonedDataIndex = imports.table.clone(dataIndexes, false)
                    imports.table.insert(clonedDataIndex, i)
                    imports.table.insert(clonedDataIndex, k)
                    imports.triggerLatentClientEvent(player, "onClientRecieveAssetPack", downloadSettings.speed, false, player, assetType, assetName, nil, clonedDataIndex, v)
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

        syncPack = function(player)
            thread:create(function(cThread)
                for i, j in imports.pairs(availableAssetPacks) do
                    for k, v in imports.pairs(j.assetPack) do
                        if k ~= "rwDatas" then
                            CSyncer.methods.syncData(player, i, k, nil, v)
                        else
                            for m, n in imports.pairs(v) do
                                for x, y in imports.pairs(n) do
                                    if (x ~= "rwMap") and (x ~= "rwData") then
                                        CSyncer.methods.syncData(player, i, k, {m, x}, y)
                                    else
                                        if x == "rwMap" then
                                            CSyncer.methods.syncRWMap(player, i, k, {m, x}, y)
                                        else
                                            if i == "scene" then
                                                for o, p in imports.pairs(y) do
                                                    if o ~= "children" then
                                                        CSyncer.methods.syncData(player, i, k, {m, x, o}, p)
                                                    else
                                                        for a, b in imports.pairs(p) do
                                                            for c, d in imports.pairs(b) do
                                                                if c ~= "rwData" then
                                                                    CSyncer.methods.syncData(player, i, k, {m, x, o, a, c}, d)
                                                                else
                                                                    CSyncer.methods.syncRWData(player, i, k, {m, x, o, a, c}, d)
                                                                end
                                                                thread.pause()
                                                            end
                                                            thread.pause()
                                                        end
                                                    end
                                                    thread.pause()
                                                end
                                            else
                                                CSyncer.methods.syncRWData(player, i, k, {m, x}, y)
                                            end
                                        end
                                    end
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