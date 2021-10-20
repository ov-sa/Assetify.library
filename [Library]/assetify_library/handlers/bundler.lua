----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: bundler.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Library Bundler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {}

--[[
local fetchedAsset, SyncedData = getAssetData("weapon", "ak47_gold")
if fetchedAsset and SyncedData then
    if SyncedData then
        outputChatBox("WOW HAHA: "..tostring(SyncedData.modelID))
    end
end
]]