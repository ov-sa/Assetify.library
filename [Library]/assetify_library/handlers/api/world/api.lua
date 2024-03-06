----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: api: world: api.lua
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
    function manager.API.World.clearWorld()
        for i = 550, 19999, 1 do
            imports.removeWorldModel(i, 100000, 0, 0, 0)
        end
        if settings.GTA.waterLevel then
            streamer.waterBuffer = imports.createWater(-3000, -3000, 0, 3000, -3000, 0, -3000, 3000, 0, 3000, 3000, 0, false)
        end
        manager.API.World.toggleOcclusions(false)
        imports.setWorldSpecialPropertyEnabled("randomfoliage", false)
        return true
    end

    function manager.API.World.restoreWorld()
        imports.destroyElement(streamer.waterBuffer)
        streamer.waterBuffer = nil
        imports.restoreAllWorldModels()
        manager.API.World.toggleOcclusions((not settings.GTA.disableOcclusions and true) or false)
        imports.setWorldSpecialPropertyEnabled("randomfoliage", true)
        return true
    end

    function manager.API.World.toggleOcclusions(state)
        imports.setOcclusionsEnabled((state and true) or false)
        return true
    end

    function manager.API.World.clearModel(modelID)
        modelID = imports.tonumber(modelID)
        if modelID then
            imports.engineImportTXD(asset.rwAssets.txd, modelID)
            imports.engineReplaceModel(asset.rwAssets.dff, modelID, false)
            return true
        end
        return false
    end

    function manager.API.World.restoreModel(modelID)
        modelID = imports.tonumber(modelID)
        if not modelID then return false end
        return imports.engineRestoreModel(modelID)
    end
else


end