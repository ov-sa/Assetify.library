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

manager:exportAPI("library", {name = "isBooted"}, function()
    return syncer.isLibraryBooted
end)

manager:exportAPI("library", {name = "isLoaded"}, function()
    return syncer.isLibraryLoaded
end)

manager:exportAPI("library", {name = "fetchSerial"}, function()
    return syncer.librarySerial
end)

manager:exportAPI("library", {name = "fetchVersion"}, function()
    return syncer.libraryVersion
end)

manager:exportAPI("library", {name = "fetchWebserver"}, function()
    return syncer.libraryWebserver
end)

manager:exportAPI("library", {name = "fetchAssets"}, function(...)
    return manager:fetchAssets(...)
end)

manager:exportAPI("library", {name = "getAssetData"}, function(...)
    return manager:getAssetData(...)
end)

manager:exportAPI("library", {name = "getAssetDep"}, function(...)
    return manager:getAssetDep(...)
end)

manager:exportAPI("library", {name = "setElementAsset"}, function(...)
    return syncer.syncElementModel(_, ...)
end)

manager:exportAPI("library", {name = "getElementAsset"}, function(element)
    if not syncer.syncedElements[element] then return false end
    return syncer.syncedElements[element].assetType, syncer.syncedElements[element].assetName, syncer.syncedElements[element].assetClump, syncer.syncedElements[element].clumpMaps
end)

manager:exportAPI("library", {name = "setElementAsset"}, functionTone(...)
    return syncer.syncElementTone(_, ...)
end)

manager:exportAPI("library", {name = "getElementAsset"}, functionTone(element, assetType, assetName, textureName, isBumpTone)
    if not syncer.syncedElementTones[element] or not syncer.syncedElementTones[element][assetType] or not syncer.syncedElementTones[element][assetType][assetName] or not syncer.syncedElementTones[element][assetType][assetName][textureName] then return false end
    if isBumpTone then
        if not syncer.syncedElementTones[element][assetType][assetName][textureName].bump then return false end
        return {syncer.syncedElementTones[element][assetType][assetName][textureName].bump[1], syncer.syncedElementTones[element][assetType][assetName][textureName].bump[2]}
    end
    return {syncer.syncedElementTones[element][assetType][assetName][textureName][1], syncer.syncedElementTones[element][assetType][assetName][textureName][2]}
end)

manager:exportAPI("library", {name = "setGlobalData"}, function(...)
    return syncer.syncGlobalData(...)
end)

manager:exportAPI("library", {name = "getGlobalData"}, function(data)
    return syncer.syncedGlobalDatas[data]
end)

manager:exportAPI("library", {name = "getAllGlobalDatas"}, function()
    return syncer.syncedGlobalDatas
end)

manager:exportAPI("library", {name = "setEntityData"}, function(...)
    return syncer.syncEntityData(table.unpack(table.pack(...), 3))
end)

manager:exportAPI("library", {name = "getEntityData"}, function(element, data)
    return syncer.syncedEntityDatas[element] and syncer.syncedEntityDatas[element][data]
end)

manager:exportAPI("library", {name = "getAllEntityDatas"}, function(element)
    return syncer.syncedEntityDatas[element] or {}
end)

manager:exportAPI("library", {name = "setAttachment"}, function(...)
    return attacher:attachElements(...)
end)

manager:exportAPI("library", {name = "setDetachment"}, function(...)
    return attacher:detachElements(...)
end)

manager:exportAPI("library", {name = "clearAttachment"}, function(...)
    return attacher:clearAttachment(...)
end)

manager:exportAPI("library", {name = "createAssetDummy"}, function(...)
    local cDummy = syncer.syncDummySpawn(_, ...)
    return (cDummy and cDummy.cDummy) or false
end)

manager:exportAPI("library", {name = "setBoneAttachment"}, function(...)
    return syncer.syncBoneAttachment(_, ...)
end)

manager:exportAPI("library", {name = "setBoneDetachment"}, function(...)
    return syncer.syncBoneDetachment(_, ...)
end)

manager:exportAPI("library", {name = "setBoneRefreshment"}, function(...)
    return syncer.syncBoneRefreshment(_, ...)
end)

manager:exportAPI("library", {name = "clearBoneAttachment"}, function(...)
    return syncer.syncClearBoneAttachment(_, ...)
end)

if localPlayer then
    manager:exportAPI("library", {name = "getDownloadProgress"}, function(...)
        return manager:getDownloadProgress(...)
    end)

    manager:exportAPI("library", {name = "isAssetLoaded"}, function(...)
        return manager:isAssetLoaded(...)
    end)

    manager:exportAPI("library", {name = "getAssetID"}, function(...)
        return manager:getAssetID(...)
    end)

    manager:exportAPI("library", {name = "loadAsset"}, function(...)
        return manager:loadAsset(...)
    end)

    manager:exportAPI("library", {name = "unloadAsset"}, function(...)
        return manager:unloadAsset(...)
    end)

    manager:exportAPI("library", {name = "createShader"}, function(...)
        local cShader = shader:create(...)
        return (cShader and cShader.cShader) or false
    end)

    manager:exportAPI("library", {name = "isRendererVirtualRendering"}, function()
        return renderer.isVirtualRendering
    end)

    manager:exportAPI("library", {name = "setRendererVirtualRendering"}, function(...)
        return renderer:setVirtualRendering(...)
    end)

    manager:exportAPI("library", {name = "getRendererVirtualSource"}, function()
        return (renderer.isVirtualRendering and renderer.virtualSource) or false
    end)

    manager:exportAPI("library", {name = "getRendererVirtualRTs"}, function()
        return (renderer.isVirtualRendering and renderer.virtualRTs) or false
    end)

    manager:exportAPI("library", {name = "isRendererTimeSynced"}, function(...)
        return renderer.isTimeSynced
    end)

    manager:exportAPI("library", {name = "setRendererTimeSync"}, function(...)
        return renderer:setTimeSync(...)
    end)

    manager:exportAPI("library", {name = "setRendererServerTick"}, function(...)
        return renderer:setServerTick(...)
    end)

    manager:exportAPI("library", {name = "setRendererMinuteDuration"}, function(...)
        return renderer:setMinuteDuration(...)
    end)

    manager:exportAPI("library", {name = "getRendererAntiAliasing"}, function()
        return renderer.isAntiAliased or 0
    end)

    manager:exportAPI("library", {name = "setRendererAntiAliasing"}, function(...)
        return renderer:setAntiAliasing(...)
    end)

    manager:exportAPI("library", {name = "isRendererEmissiveMode"}, function()
        return renderer.isEmissiveModeEnabled
    end)

    manager:exportAPI("library", {name = "setRendererEmissiveMode"}, function(...)
        return renderer:setEmissiveMode(...)
    end)

    manager:exportAPI("library", {name = "isRendererDynamicSky"}, function()
        return renderer.isDynamicSkyEnabled
    end)

    manager:exportAPI("library", {name = "setRendererDynamicSky"}, function(...)
        return renderer:setDynamicSky(...)
    end)

    manager:exportAPI("library", {name = "isRendererDynamicPrelights"}, function()
        return renderer.isDynamicPrelightsEnabled
    end)

    manager:exportAPI("library", {name = "setRendererDynamicPrelights"}, function(...)
        return renderer:setDynamicPrelights(...)
    end)

    manager:exportAPI("library", {name = "getRendererDynamicSunColor"}, function()
        return renderer.isDynamicSunColor[1]*255, renderer.isDynamicSunColor[2]*255, renderer.isDynamicSunColor[3]*255
    end)

    manager:exportAPI("library", {name = "setRendererDynamicSunColor"}, function(...)
        return renderer:setDynamicSunColor(...)
    end)

    manager:exportAPI("library", {name = "isRendererDynamicStars"}, function()
        return renderer.isDynamicStarsEnabled
    end)

    manager:exportAPI("library", {name = "setRendererDynamicStars"}, function(...)
        return renderer:setDynamicStars(...)
    end)

    manager:exportAPI("library", {name = "getRendererDynamicCloudDensity"}, function()
        return renderer.isDynamicCloudDensity
    end)

    manager:exportAPI("library", {name = "setRendererDynamicCloudDensity"}, function(...)
        return renderer:setDynamicCloudDensity(...)
    end)

    manager:exportAPI("library", {name = "getRendererDynamicCloudScale"}, function()
        return renderer.isDynamicCloudScale
    end)

    manager:exportAPI("library", {name = "setRendererDynamicCloudScale"}, function(...)
        return renderer:setDynamicCloudScale(...)
    end)

    manager:exportAPI("library", {name = "getRendererDynamicCloudColor"}, function()
        return renderer.isDynamicCloudColor[1]*255, renderer.isDynamicCloudColor[2]*255, renderer.isDynamicCloudColor[3]*255
    end)

    manager:exportAPI("library", {name = "setRendererDynamicCloudColor"}, function(...)
        return renderer:setDynamicCloudColor(...)
    end)

    manager:exportAPI("library", {name = "getRendererTimeCycle"}, function()
        return renderer.isDynamicTimeCycle
    end)

    manager:exportAPI("library", {name = "setRendererTimeCycle"}, function(...)
        return renderer:setTimeCycle(...)
    end)
else

end