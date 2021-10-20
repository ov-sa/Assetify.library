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
    addEventHandler = addEventHandler,
    loadAssetPackChunk = loadAssetPackChunk
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

    thread:create(function(cThread)
        for i, j in imports.pairs(availableAssetPacks) do
            if i ~= "map" then
                for k, v in imports.pairs(j.rwDatas) do
                    --TODO: ADD CALLBACK AND RESUME THREAD...
                    imports.loadAssetPackChunk({
                        type = "object",
                        id = nil,
                        rwData = v.rwData
                    })
                    thread.pause()
                end
            end
        end
    end):resume()

end)
