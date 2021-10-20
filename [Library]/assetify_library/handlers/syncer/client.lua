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
}


-------------------
--[[ Variables ]]--
-------------------

isLibraryLoaded = false
availableAssetPacks = {}


---------------------------------------------------
--[[ Events: On Client Recieve/Load Asset Pack ]]--
---------------------------------------------------

imports.addEvent("onClientRecieveAssetPack", true)
imports.addEventHandler("onClientRecieveAssetPack", root, function(assetPack, dataIndex, indexData, chunkIndex, chunkData)

    if not assetPack or not dataIndex then return false end
    if not availableAssetPacks[assetPack] then
        availableAssetPacks[assetPack] = {}
    end

    if not chunkIndex and not chunkData then
        if dataIndex then
            availableAssetPacks[assetPack][dataIndex] = indexData
        end
    else
        availableAssetPacks[assetPack][dataIndex] = {}
        availableAssetPacks[assetPack][dataIndex][chunkIndex] = chunkData
    end

end)


imports.addEvent("onClientLoadAssetPack", true)
imports.addEventHandler("onClientLoadAssetPack", root, function()

    thread:create(function(cThread)
        for i, j in imports.pairs(availableAssetPacks) do
            if i ~= "map" then
                if j.rwDatas then
                    print(i.." : "..tostring(j))
                    for k, v in imports.pairs(j.rwDatas) do
                        if v then
                            asset:create(j.type, j.base, j.transparency, v, function(cAsset)
                                imports.setTimer(function()
                                    cThread:resume()
                                end, 1, 1)
                            end)
                            thread.pause()
                        end
                    end
                end
            end
        end
        isLibraryLoaded = true
        --TODO: MARK LIBRARY AS STARTED..
        --outputChatBox("Final Call")
        --getAsset("weapon", "ak47_gold")
    end):resume()

end)