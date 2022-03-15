----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers. loader.lua
     Server: -
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
    removeWorldModel = removeWorldModel,
    restoreAllWorldModels = restoreAllWorldModels,
    createWater = createWater,
    setWaterLevel = setWaterLevel,
    setOcclusionsEnabled = setOcclusionsEnabled,
    setWorldSpecialPropertyEnabled = setWorldSpecialPropertyEnabled
}


-----------------------------------------------
--[[ Events: On Client Resource Start/Stop ]]--
-----------------------------------------------

imports.addEventHandler("onClientResourceStart", resourceRoot, function()
    if not GTAWorldSettings.removeWorld then
        imports.restoreAllWorldModels()
    else
        for i = 550, 19999, 1 do
            imports.removeWorldModel(i, 100000, 0, 0, 0)
        end
        streamer.waterBuffer = imports.createWater(-3000, -3000, 0, 3000, -3000, 0, -3000, 3000, 0, 3000, 3000, 0, false)
        imports.setWaterLevel(streamer.waterBuffer, GTAWorldSettings.waterLevel)
    end
    imports.setWaterLevel(GTAWorldSettings.waterLevel, true, true, true, true)
    imports.setOcclusionsEnabled(not GTAWorldSettings.removeWorld)
    imports.setWorldSpecialPropertyEnabled("randomfoliage", not GTAWorldSettings.removeWorld)
end)

imports.addEventHandler("onClientResourceStop", resourceRoot, function()
    imports.triggerEvent("onAssetifyUnLoad", resourceRoot)
end)