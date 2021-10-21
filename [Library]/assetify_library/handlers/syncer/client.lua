----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: syncer: client.lua
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
    setTimer = setTimer,
    addEvent = addEvent,
    addEventHandler = addEventHandler,
    triggerEvent = triggerEvent,
    loadAsset = loadAsset
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

imports.addEvent("onClientRecieveAssetPack", true)
imports.addEventHandler("onClientRecieveAssetPack", root, function(assetPack, dataIndex, indexData, dataIndexes, subIndexData)
    
    if not assetPack or not dataIndex then return false end

    if not availableAssetPacks[assetPack] then
        availableAssetPacks[assetPack] = {}
    end
    if dataIndex then
        if not dataIndexes then
            availableAssetPacks[assetPack][dataIndex] = indexData
        else
            if not availableAssetPacks[assetPack][dataIndex] then
                availableAssetPacks[assetPack][dataIndex] = {}
            end
            local totalIndexes = #dataIndexes
            local indexPointer = availableAssetPacks[assetPack][dataIndex]
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
        print("LOADED...")
        onLibraryLoaded()
        for i, j in imports.pairs(availableAssetPacks) do
            if j.autoLoad and j.rwDatas then
                for k, v in imports.pairs(j.rwDatas) do
                    if v then
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

imports.addEventHandler("onClientResourceStop", resourceRoot, function()

    imports.triggerEvent("onAssetifyUnLoad", resourceRoot)

end)