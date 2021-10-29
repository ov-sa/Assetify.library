----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: syncer. client.lua
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
    triggerEvent = triggerEvent,
    removeWorldModel = removeWorldModel,
    restoreAllWorldModels = restoreAllWorldModels,
    createWater = createWater,
    setWaterLevel = setWaterLevel,
    setOcclusionsEnabled = setOcclusionsEnabled,
    setWorldSpecialPropertyEnabled = setWorldSpecialPropertyEnabled,
}


-----------------------------------------------
--[[ Events: On Client Resource Start/Stop ]]--
-----------------------------------------------

addEventHandler("onClientResourceStart", resourceRoot, function()

    if not GTAWorldSettings.removeWorld then
        restoreAllWorldModels()
    else
        for i = 550, 19999, 1 do
            removeWorldModel(i, 100000, 0, 0, 0)
        end
        local createdWater = createWater(-3000, -3000, 0, 3000, -3000, 0, -3000, 3000, 0, 3000, 3000, 0, false)
        setWaterLevel(createdWater, GTAWorldSettings.waterLevel)
    end
    setWaterLevel(GTAWorldSettings.waterLevel, true, true, true, true)
    setOcclusionsEnabled(not GTAWorldSettings.removeWorld)
    setWorldSpecialPropertyEnabled("randomfoliage", not GTAWorldSettings.removeWorld)

end)

addEventHandler("onClientResourceStop", resourceRoot, function()

    for i, j in pairs(availableAssetPacks) do
        if j.autoLoad and j.rwDatas then
            for k, v in pairs(j.rwDatas) do
                if v then
                    asset:refreshMaps(false, i, k, v.manifestData.shaderMaps, v.rwMap)
                end
            end
        end
    end
    triggerEvent("onAssetifyUnLoad", resourceRoot)

end)