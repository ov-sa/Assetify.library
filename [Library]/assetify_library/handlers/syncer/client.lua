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
    addEvent = addEvent,
    addEventHandler = addEventHandler
}


-------------------
--[[ Variables ]]--
-------------------

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

    --print(chunkData.rwData.txd)
    thread:create(function(cThread)
        for i, j in imports.pairs(availableAssetPacks) do
            if i ~= "map" then
                loadAssetPack(j, function()
                    outputChatBox("LOADED A PACK FOR NOW!")
                end)
                    --[[
                    if i ~= "rwDatas" then
                        imports.triggerLatentClientEvent(player, "onClientRecieveAssetPack", 125000, false, player, i, i, v)
                    else
                        for k, v in imports.pairs(v) do
                            imports.triggerLatentClientEvent(player, "onClientRecieveAssetPack", 125000, false, player, i, i, _, k, v)
                            thread.pause()
                        end
                    end
                    ]]
                thread.pause()
            end
        end
    end):resume()

end)
