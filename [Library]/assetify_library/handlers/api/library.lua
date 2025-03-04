----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: api: library.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Library APIs ]]--
----------------------------------------------------------------


-----------------------
--[[ APIs: Library ]]--
-----------------------

manager:exportAPI("library", "isBooted", function()
    return syncer.isLibraryBooted
end)

manager:exportAPI("library", "isLoaded", function()
    return syncer.isLibraryLoaded
end)

manager:exportAPI("library", "fetchSerial", function()
    return syncer.librarySerial
end)

manager:exportAPI("library", "fetchVersion", function()
    return syncer.libraryVersion
end)

manager:exportAPI("library", "fetchWebserver", function()
    return syncer.libraryWebserver
end)

manager:exportAPI("library", "fetchAssets", function(...)
    return manager:fetchAssets(...)
end)

manager:exportAPI("library", "getAssetData", function(...)
    return manager:getAssetData(...)
end)

manager:exportAPI("library", "getAssetDep", function(...)
    return manager:getAssetDep(...)
end)

manager:exportAPI("library", "setElementAsset", function(...)
    return syncer.syncElementModel(_, ...)
end)

manager:exportAPI("library", "getElementAsset", function(element)
    if not syncer.syncedElements[element] then return false end
    return syncer.syncedElements[element].assetType, syncer.syncedElements[element].assetName, syncer.syncedElements[element].assetClump, syncer.syncedElements[element].clumpMaps
end)

manager:exportAPI("library", "setElementAsset", function(...)
    return syncer.syncElementTone(_, ...)
end)

manager:exportAPI("library", "getElementAsset", function(element, assetType, assetName, textureName, isBumpTone)
    if not syncer.syncedElementTones[element] or not syncer.syncedElementTones[element][assetType] or not syncer.syncedElementTones[element][assetType][assetName] or not syncer.syncedElementTones[element][assetType][assetName][textureName] then return false end
    if isBumpTone then
        if not syncer.syncedElementTones[element][assetType][assetName][textureName].bump then return false end
        return {syncer.syncedElementTones[element][assetType][assetName][textureName].bump[1], syncer.syncedElementTones[element][assetType][assetName][textureName].bump[2]}
    end
    return {syncer.syncedElementTones[element][assetType][assetName][textureName][1], syncer.syncedElementTones[element][assetType][assetName][textureName][2]}
end)

manager:exportAPI("library", "setGlobalData", function(...)
    return syncer.syncGlobalData(...)
end)

manager:exportAPI("library", "getGlobalData", function(data)
    return syncer.syncedGlobalDatas[data]
end)

manager:exportAPI("library", "getAllGlobalDatas", function()
    return syncer.syncedGlobalDatas
end)

manager:exportAPI("library", "setEntityData", function(...)
    return syncer.syncEntityData(table.unpack(table.pack(...), 3))
end)

manager:exportAPI("library", "getEntityData", function(element, data)
    return syncer.syncedEntityDatas[element] and syncer.syncedEntityDatas[element][data]
end)

manager:exportAPI("library", "getAllEntityDatas", function(element)
    return syncer.syncedEntityDatas[element] or {}
end)

manager:exportAPI("library", "setAttachment", function(...)
    return attacher:attachElements(...)
end)

manager:exportAPI("library", "setDetachment", function(...)
    return attacher:detachElements(...)
end)

manager:exportAPI("library", "clearAttachment", function(...)
    return attacher:clearAttachment(...)
end)

manager:exportAPI("library", "createAssetDummy", function(...)
    local cDummy = syncer.syncDummySpawn(_, ...)
    return (cDummy and cDummy.cDummy) or false
end)

manager:exportAPI("library", "setBoneAttachment", function(...)
    return syncer.syncBoneAttachment(_, ...)
end)

manager:exportAPI("library", "setBoneDetachment", function(...)
    return syncer.syncBoneDetachment(_, ...)
end)

manager:exportAPI("library", "setBoneRefreshment", function(...)
    return syncer.syncBoneRefreshment(_, ...)
end)

manager:exportAPI("library", "clearBoneAttachment", function(...)
    return syncer.syncClearBoneAttachment(_, ...)
end)

if localPlayer then
    manager:exportAPI("library", "getDownloadProgress", function(...)
        return manager:getDownloadProgress(...)
    end)

    manager:exportAPI("library", "isAssetLoaded", function(...)
        return manager:isAssetLoaded(...)
    end)

    manager:exportAPI("library", "getAssetID", function(...)
        return manager:getAssetID(...)
    end)

    manager:exportAPI("library", "loadAsset", function(...)
        return manager:loadAsset(...)
    end)

    manager:exportAPI("library", "unloadAsset", function(...)
        return manager:unloadAsset(...)
    end)

    manager:exportAPI("library", "createShader", function(...)
        local cShader = shader:create(...)
        return (cShader and cShader.cShader) or false
    end)

    manager:exportAPI("library", "isRendererVirtualRendering", function()
        return renderer.isVirtualRendering
    end)

    manager:exportAPI("library", "setRendererVirtualRendering", function(...)
        return renderer:setVirtualRendering(...)
    end)

    manager:exportAPI("library", "getRendererVirtualSource", function()
        return (renderer.isVirtualRendering and renderer.virtualSource) or false
    end)

    manager:exportAPI("library", "getRendererVirtualRTs", function()
        return (renderer.isVirtualRendering and renderer.virtualRTs) or false
    end)

    manager:exportAPI("library", "isRendererTimeSynced", function(...)
        return renderer.isTimeSynced
    end)

    manager:exportAPI("library", "setRendererTimeSync", function(...)
        return renderer:setTimeSync(...)
    end)

    manager:exportAPI("library", "setRendererServerTick", function(...)
        return renderer:setServerTick(...)
    end)

    manager:exportAPI("library", "setRendererMinuteDuration", function(...)
        return renderer:setMinuteDuration(...)
    end)

    manager:exportAPI("library", "getRendererAntiAliasing", function()
        return renderer.isAntiAliased or 0
    end)

    manager:exportAPI("library", "setRendererAntiAliasing", function(...)
        return renderer:setAntiAliasing(...)
    end)

    manager:exportAPI("library", "isRendererEmissiveMode", function()
        return renderer.isEmissiveModeEnabled
    end)

    manager:exportAPI("library", "setRendererEmissiveMode", function(...)
        return renderer:setEmissiveMode(...)
    end)

    manager:exportAPI("library", "isRendererDynamicSky", function()
        return renderer.isDynamicSkyEnabled
    end)

    manager:exportAPI("library", "setRendererDynamicSky", function(...)
        return renderer:setDynamicSky(...)
    end)

    manager:exportAPI("library", "isRendererDynamicPrelights", function()
        return renderer.isDynamicPrelightsEnabled
    end)

    manager:exportAPI("library", "setRendererDynamicPrelights", function(...)
        return renderer:setDynamicPrelights(...)
    end)

    manager:exportAPI("library", "getRendererDynamicSunColor", function()
        return renderer.isDynamicSunColor[1]*255, renderer.isDynamicSunColor[2]*255, renderer.isDynamicSunColor[3]*255
    end)

    manager:exportAPI("library", "setRendererDynamicSunColor", function(...)
        return renderer:setDynamicSunColor(...)
    end)

    manager:exportAPI("library", "isRendererDynamicStars", function()
        return renderer.isDynamicStarsEnabled
    end)

    manager:exportAPI("library", "setRendererDynamicStars", function(...)
        return renderer:setDynamicStars(...)
    end)

    manager:exportAPI("library", "getRendererDynamicCloudDensity", function()
        return renderer.isDynamicCloudDensity
    end)

    manager:exportAPI("library", "setRendererDynamicCloudDensity", function(...)
        return renderer:setDynamicCloudDensity(...)
    end)

    manager:exportAPI("library", "getRendererDynamicCloudScale", function()
        return renderer.isDynamicCloudScale
    end)

    manager:exportAPI("library", "setRendererDynamicCloudScale", function(...)
        return renderer:setDynamicCloudScale(...)
    end)

    manager:exportAPI("library", "getRendererDynamicCloudColor", function()
        return renderer.isDynamicCloudColor[1]*255, renderer.isDynamicCloudColor[2]*255, renderer.isDynamicCloudColor[3]*255
    end)

    manager:exportAPI("library", "setRendererDynamicCloudColor", function(...)
        return renderer:setDynamicCloudColor(...)
    end)

    manager:exportAPI("library", "getRendererTimeCycle", function()
        return renderer.isDynamicTimeCycle
    end)

    manager:exportAPI("library", "setRendererTimeCycle", function(...)
        return renderer:setTimeCycle(...)
    end)
else

end