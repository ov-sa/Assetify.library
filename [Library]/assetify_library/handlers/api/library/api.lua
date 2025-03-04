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

function manager.API.library.isBooted()
    return syncer.isLibraryBooted
end

function manager.API.library.isLoaded()
    return syncer.isLibraryLoaded
end

function manager.API.library.isModuleLoaded()
    return syncer.isModuleLoaded
end

function manager.API.library.fetchSerial()
    return syncer.librarySerial
end

function manager.API.library.fetchVersion()
    return syncer.libraryVersion
end

function manager.API.library.fetchWebserver()
    return syncer.libraryWebserver
end

function manager.API.library.fetchAssets(...)
    return manager:fetchAssets(...)
end

function manager.API.library.getAssetData(...)
    return manager:getAssetData(...)
end

function manager.API.library.getAssetDep(...)
    return manager:getAssetDep(...)
end

function manager.API.library.setElementAsset(...)
    return syncer.syncElementModel(_, ...)
end

function manager.API.library.getElementAsset(element)
    if not syncer.syncedElements[element] then return false end
    return syncer.syncedElements[element].assetType, syncer.syncedElements[element].assetName, syncer.syncedElements[element].assetClump, syncer.syncedElements[element].clumpMaps
end

function manager.API.library.setElementAssetTone(...)
    return syncer.syncElementTone(_, ...)
end

function manager.API.library.getElementAssetTone(element, assetType, assetName, textureName, isBumpTone)
    if not syncer.syncedElementTones[element] or not syncer.syncedElementTones[element][assetType] or not syncer.syncedElementTones[element][assetType][assetName] or not syncer.syncedElementTones[element][assetType][assetName][textureName] then return false end
    if isBumpTone then
        if not syncer.syncedElementTones[element][assetType][assetName][textureName].bump then return false end
        return {syncer.syncedElementTones[element][assetType][assetName][textureName].bump[1], syncer.syncedElementTones[element][assetType][assetName][textureName].bump[2]}
    end
    return {syncer.syncedElementTones[element][assetType][assetName][textureName][1], syncer.syncedElementTones[element][assetType][assetName][textureName][2]}
end

function manager.API.library.setGlobalData(...)
    return syncer.syncGlobalData(...)
end

function manager.API.library.getGlobalData(data)
    return syncer.syncedGlobalDatas[data]
end

function manager.API.library.getAllGlobalDatas()
    return syncer.syncedGlobalDatas
end

function manager.API.library.setEntityData(...)
    return syncer.syncEntityData(table.unpack(table.pack(...), 3))
end

function manager.API.library.getEntityData(element, data)
    return syncer.syncedEntityDatas[element] and syncer.syncedEntityDatas[element][data]
end

function manager.API.library.getAllEntityDatas(element)
    return syncer.syncedEntityDatas[element] or {}
end

function manager.API.library.setAttachment(...)
    return attacher:attachElements(...)
end

function manager.API.library.setDetachment(...)
    return attacher:detachElements(...)
end

function manager.API.library.clearAttachment(...)
    return attacher:clearAttachment(...)
end

function manager.API.library.createAssetDummy(...)
    local cDummy = syncer.syncDummySpawn(_, ...)
    return (cDummy and cDummy.cDummy) or false
end

function manager.API.library.setBoneAttachment(...)
    return syncer.syncBoneAttachment(_, ...)
end

function manager.API.library.setBoneDetachment(...)
    return syncer.syncBoneDetachment(_, ...)
end

function manager.API.library.setBoneRefreshment(...)
    return syncer.syncBoneRefreshment(_, ...)
end

function manager.API.library.clearBoneAttachment(...)
    return syncer.syncClearBoneAttachment(_, ...)
end

if localPlayer then
    function manager.API.library.getDownloadProgress(...)
        return manager:getDownloadProgress(...)
    end

    function manager.API.library.isAssetLoaded(...)
        return manager:isAssetLoaded(...)
    end

    function manager.API.library.getAssetID(...)
        return manager:getAssetID(...)
    end

    function manager.API.library.loadAsset(...)
        return manager:loadAsset(...)
    end

    function manager.API.library.unloadAsset(...)
        return manager:unloadAsset(...)
    end

    function manager.API.library.createShader(...)
        local cShader = shader:create(...)
        return (cShader and cShader.cShader) or false
    end

    function manager.API.library.isRendererVirtualRendering()
        return renderer.isVirtualRendering
    end

    function manager.API.library.setRendererVirtualRendering(...)
        return renderer:setVirtualRendering(...)
    end

    function manager.API.library.getRendererVirtualSource()
        return (renderer.isVirtualRendering and renderer.virtualSource) or false
    end

    function manager.API.library.getRendererVirtualRTs()
        return (renderer.isVirtualRendering and renderer.virtualRTs) or false
    end

    function manager.API.library.isRendererTimeSynced(...)
        return renderer.isTimeSynced
    end

    function manager.API.library.setRendererTimeSync(...)
        return renderer:setTimeSync(...)
    end

    function manager.API.library.setRendererServerTick(...)
        return renderer:setServerTick(...)
    end

    function manager.API.library.setRendererMinuteDuration(...)
        return renderer:setMinuteDuration(...)
    end

    function manager.API.library.getRendererAntiAliasing()
        return renderer.isAntiAliased or 0
    end

    function manager.API.library.setRendererAntiAliasing(...)
        return renderer:setAntiAliasing(...)
    end

    function manager.API.library.isRendererEmissiveMode()
        return renderer.isEmissiveModeEnabled
    end

    function manager.API.library.setRendererEmissiveMode(...)
        return renderer:setEmissiveMode(...)
    end

    function manager.API.library.isRendererDynamicSky()
        return renderer.isDynamicSkyEnabled
    end

    function manager.API.library.setRendererDynamicSky(...)
        return renderer:setDynamicSky(...)
    end

    function manager.API.library.isRendererDynamicPrelights()
        return renderer.isDynamicPrelightsEnabled
    end

    function manager.API.library.setRendererDynamicPrelights(...)
        return renderer:setDynamicPrelights(...)
    end

    function manager.API.library.getRendererDynamicSunColor()
        return renderer.isDynamicSunColor[1]*255, renderer.isDynamicSunColor[2]*255, renderer.isDynamicSunColor[3]*255
    end

    function manager.API.library.setRendererDynamicSunColor(...)
        return renderer:setDynamicSunColor(...)
    end

    function manager.API.library.isRendererDynamicStars()
        return renderer.isDynamicStarsEnabled
    end

    function manager.API.library.setRendererDynamicStars(...)
        return renderer:setDynamicStars(...)
    end

    function manager.API.library.getRendererDynamicCloudDensity()
        return renderer.isDynamicCloudDensity
    end

    function manager.API.library.setRendererDynamicCloudDensity(...)
        return renderer:setDynamicCloudDensity(...)
    end

    function manager.API.library.getRendererDynamicCloudScale()
        return renderer.isDynamicCloudScale
    end

    function manager.API.library.setRendererDynamicCloudScale(...)
        return renderer:setDynamicCloudScale(...)
    end

    function manager.API.library.getRendererDynamicCloudColor()
        return renderer.isDynamicCloudColor[1]*255, renderer.isDynamicCloudColor[2]*255, renderer.isDynamicCloudColor[3]*255
    end

    function manager.API.library.setRendererDynamicCloudColor(...)
        return renderer:setDynamicCloudColor(...)
    end

    function manager.API.library.getRendererTimeCycle()
        return renderer.isDynamicTimeCycle
    end

    function manager.API.library.setRendererTimeCycle(...)
        return renderer:setTimeCycle(...)
    end

    function manager.API.library.createPlanarLight(...)
        local cLight = light.planar:create(...)
        return (cLight and cLight.cLight) or false
    end

    function manager.API.library.setPlanarLightResolution(...)
        if not light.planar.buffer[cLight] then return false end
        return light.planar.buffer[cLight]:setResolution(...)
    end

    function manager.API.library.setPlanarLightTexture(...)
        if not light.planar.buffer[cLight] then return false end
        return light.planar.buffer[cLight]:setTexture(...)
    end

    function manager.API.library.setPlanarLightColor(...)
        if not light.planar.buffer[cLight] then return false end
        return light.planar.buffer[cLight]:setColor(...)
    end
else

end