----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers. loader.lua
     Author: vStudio
     Developer(s): Aviril, Tron
     DOC: 19/10/2021
     Desc: Laoder Handler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    addEventHandler = addEventHandler,
    triggerEvent = triggerEvent,
    setWaterLevel = setWaterLevel
}


-----------------------------------------------
--[[ Events: On Client Resource Start/Stop ]]--
-----------------------------------------------

imports.addEventHandler("onClientResourceStart", resourceRoot, function()
    if GTAWorldSettings.clearWorld then
        clearWorld()
    else
        restoreWorld()
    end
    if GTAWorldSettings.waterLevel then
        if streamer.waterBuffer then
            imports.setWaterLevel(streamer.waterBuffer, GTAWorldSettings.waterLevel)
        end
        imports.setWaterLevel(GTAWorldSettings.waterLevel, true, true, true, true)
    end
end)

imports.addEventHandler("onClientResourceStop", resourceRoot, function()
    network:emit("Assetify:onUnload", false)
end)