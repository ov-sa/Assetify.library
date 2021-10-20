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
    triggerEvent = triggerEvent
}


-------------------
--[[ Variables ]]--
-------------------

isLibraryLoaded = false
availableAssetPacks = {}
imports.addEvent("onAssetifyLoad", false)
imports.addEvent("onAssetifyUnLoad", false)


---------------------------------------------------
--[[ Events: On Client Recieve/Load Asset Pack ]]--
---------------------------------------------------

imports.addEvent("onClientRecieveAssetPack", true)
imports.addEventHandler("onClientRecieveAssetPack", root, function(assetPack, dataIndex, indexData, chunkIndex, chunkData)
    if not assetPack or not dataIndex then return false end
    if not availableAssetPacks[assetPack] then
        availableAssetPacks[assetPack] = {}
    end
    if dataIndex then
        if not chunkIndex and not chunkData then
            availableAssetPacks[assetPack][dataIndex] = indexData
        else
            availableAssetPacks[assetPack][dataIndex] = {}
            availableAssetPacks[assetPack][dataIndex][chunkIndex] = chunkData
        end
    end
end)

imports.addEvent("onClientLoadAssetPack", true)
imports.addEventHandler("onClientLoadAssetPack", root, function()
    thread:create(function(cThread)
        for i, j in imports.pairs(availableAssetPacks) do
            if j.rwDatas then
                for k, v in imports.pairs(j.rwDatas) do
                    if v then
                        if i == "scene" then
                            for x, y in imports.pairs(v.rwData.children) do
                                asset:create(i, j.type, j.base, j.transparency, y, function(cAsset)
                                    imports.setTimer(function()
                                        cThread:resume()
                                    end, 1, 1)
                                end)
                            end
                        else
                            asset:create(i, j.type, j.base, j.transparency, v, function(cAsset)
                                imports.setTimer(function()
                                    cThread:resume()
                                end, 1, 1)
                            end)
                        end
                    end
                    imports.setTimer(function()
                        cThread:resume()
                    end, 1, 1)
                    thread.pause()
                end
            end
        end
        onLibraryLoaded()
    end):resume()
end)

imports.addEventHandler("onClientResourceStop", resourceRoot, function()
    imports.triggerEvent("onAssetifyUnLoad", resourceRoot)
end)