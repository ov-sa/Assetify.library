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
    addEvent = addEvent,
    addEventHandler = addEventHandler
}


-------------------
--[[ Variables ]]--
-------------------

availableAssetPacks = {}


---------------------------------------------------
--[[ Event: On Client Recieve Asset Pack Chunk ]]--
---------------------------------------------------

imports.addEvent("onClientRecieveAssetPackChunk", true)
imports.addEventHandler("onClientRecieveAssetPackChunk", root, function(assetPack, assetType, assetData, chunkIndex, chunkData)

    if not chunkIndex and not chunkData then
        outputChatBox("YOU HAVE RECIEVED SOME ASSETS! "..assetPack..", "..assetType..", "..tostring(assetData))
    else
        outputChatBox("YOU HAVE RECIEVED ASSET CHUNK! "..assetPack..", "..assetType..", "..chunkIndex)
    end

end)