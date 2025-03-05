----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: api: world.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: World APIs ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    tonumber = tonumber,
    createWater = createWater,
    destroyElement = destroyElement,
    engineImportTXD = engineImportTXD,
    engineReplaceModel = engineReplaceModel,
    engineRestoreModel = engineRestoreModel,
    removeWorldModel = removeWorldModel,
    restoreAllWorldModels = restoreAllWorldModels,
    setOcclusionsEnabled = setOcclusionsEnabled,
    setWorldSpecialPropertyEnabled = setWorldSpecialPropertyEnabled
}


---------------------
--[[ APIs: World ]]--
---------------------

if localPlayer then
    manager:exportAPI("world", "clear", function()
        for i = 550, 19999, 1 do
            imports.removeWorldModel(i, 100000, 0, 0, 0)
        end
        if settings.GTA.waterLevel then
            streamer.waterBuffer = imports.createWater(-3000, -3000, 0, 3000, -3000, 0, -3000, 3000, 0, 3000, 3000, 0, false)
        end
        manager.API.world.toggleOcclusions(false)
        imports.setWorldSpecialPropertyEnabled("randomfoliage", false)
        return true
    end)

    manager:exportAPI("world", "restore", function()
        imports.destroyElement(streamer.waterBuffer)
        streamer.waterBuffer = nil
        imports.restoreAllWorldModels()
        manager.API.world.toggleOcclusions(true)
        imports.setWorldSpecialPropertyEnabled("randomfoliage", true)
        return true
    end)

    manager:exportAPI("world", "toggleOcclusions", function(state)
        imports.setOcclusionsEnabled((state and true) or false)
        return true
    end)

    manager:exportAPI("world", "clearModel", function(modelID)
        modelID = imports.tonumber(modelID)
        if modelID then
            imports.engineImportTXD(asset.rwAssets.void.txd, modelID)
            imports.engineReplaceModel(asset.rwAssets.void.dff, modelID, false)
            return true
        end
        return false
    end)

    manager:exportAPI("world", "restoreModel", function(modelID)
        modelID = imports.tonumber(modelID)
        if not modelID then return false end
        return imports.engineRestoreModel(modelID)
    end)
else

end