----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: builder: client.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Builder Handler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    addEventHandler = addEventHandler,
    setWaterLevel = setWaterLevel
}


--------------------------
--[[ Builder Handlers ]]--
--------------------------

imports.addEventHandler("onClientResourceStart", resourceRoot, function()
    if settings.GTA.clearWorld then manager.API.World:clearWorld()
    else manager.API.World:restoreWorld() end
    if settings.GTA.waterLevel then
        if streamer.waterBuffer then imports.setWaterLevel(streamer.waterBuffer, settings.GTA.waterLevel) end
        imports.setWaterLevel(settings.GTA.waterLevel, true, true, true, true)
    end
end)

imports.addEventHandler("onClientResourceStop", resourceRoot, function()
    network:emit("Assetify:onUnload", false)
end)