----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: api: library: api.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Library APIs ]]--
----------------------------------------------------------------


-----------------------
--[[ APIs: Library ]]--
-----------------------

function manager.API.Library.isBooted()
    return syncer.isLibraryBooted
end

function manager.API.Library.isLoaded()
    return syncer.isLibraryLoaded
end

function manager.API.Library.isModuleLoaded()
    return syncer.isModuleLoaded
end

function manager.API.Library.isResourceLoaded()
    return resource.isResourceLoaded()
end

function manager.API.Library.isResourceFlushed()
    return resource.isResourceFlushed()
end

function manager.API.Library.isResourceUnloaded()
    return resource.isResourceUnloaded()
end

function manager.API.Library.fetchAssets(...)
    return manager:fetchAssets(...)
end

function manager.API.Library.getAssetData(...)
    return manager:getAssetData(...)
end

function manager.API.Library.getAssetDep(...)
    return manager:getAssetDep(...)
end

function manager.API.Library.setElementAsset(...)
    return syncer.syncElementModel(_, ...)
end

function manager.API.Library.getElementAsset(element)
    if not syncer.syncedElements[element] then return false end
    return syncer.syncedElements[element].assetType, syncer.syncedElements[element].assetName, syncer.syncedElements[element].assetClump, syncer.syncedElements[element].clumpMaps
end

function manager.API.Library.setElementAssetTone(...)
    return syncer.syncElementTone(_, ...)
end

function manager.API.Library.getElementAssetTone(element, assetType, assetName, textureName, isBumpTone)
    if not syncer.syncedElementTones[element] or not syncer.syncedElementTones[element][assetType] or not syncer.syncedElementTones[element][assetType][assetName] or not syncer.syncedElementTones[element][assetType][assetName][textureName] then return false end
    if isBumpTone then
        if not syncer.syncedElementTones[element][assetType][assetName][textureName].bump then return false end
        return {syncer.syncedElementTones[element][assetType][assetName][textureName].bump[1], syncer.syncedElementTones[element][assetType][assetName][textureName].bump[2]}
    end
    return {syncer.syncedElementTones[element][assetType][assetName][textureName][1], syncer.syncedElementTones[element][assetType][assetName][textureName][2]}
end

function manager.API.Library.setGlobalData(...)
    return syncer.syncGlobalData(...)
end

function manager.API.Library.getGlobalData(data)
    return syncer.syncedGlobalDatas[data]
end

function manager.API.Library.getAllGlobalDatas()
    return syncer.syncedGlobalDatas
end

function manager.API.Library.setEntityData(...)
    return syncer.syncEntityData(table.unpack(table.pack(...), 3))
end

function manager.API.Library.getEntityData(element, data)
    return syncer.syncedEntityDatas[element] and syncer.syncedEntityDatas[element][data]
end

function manager.API.Library.getAllEntityDatas(element)
    return syncer.syncedEntityDatas[element] or {}
end

function manager.API.Library.setAttachment(...)
    return attacher:attachElements(...)
end

function manager.API.Library.setDetachment(...)
    return attacher:detachElements(...)
end

function manager.API.Library.clearAttachment(...)
    return attacher:clearAttachment(...)
end

function manager.API.Library.createAssetDummy(...)
    local cDummy = syncer.syncDummySpawn(_, ...)
    return (cDummy and cDummy.cDummy) or false
end

function manager.API.Library.setBoneAttachment(...)
    return syncer.syncBoneAttachment(_, ...)
end

function manager.API.Library.setBoneDetachment(...)
    return syncer.syncBoneDetachment(_, ...)
end

function manager.API.Library.setBoneRefreshment(...)
    return syncer.syncBoneRefreshment(_, ...)
end

function manager.API.Library.clearBoneAttachment(...)
    return syncer.syncClearBoneAttachment(_, ...)
end

if localPlayer then
    function manager.API.Library.getDownloadProgress(...)
        return manager:getDownloadProgress(...)
    end

    function manager.API.Library.getResourceDownloadProgress(...)
        return manager:getResourceDownloadProgress(...)
    end

    function manager.API.Library.isAssetLoaded(...)
        return manager:isAssetLoaded(...)
    end

    function manager.API.Library.getAssetID(...)
        return manager:getAssetID(...)
    end

    function manager.API.Library.loadAsset(...)
        return manager:loadAsset(...)
    end

    function manager.API.Library.unloadAsset(...)
        return manager:unloadAsset(...)
    end

    function manager.API.Library.createShader(...)
        local cShader = shader:create(...)
        return (cShader and cShader.cShader) or false
    end

    function manager.API.Library.isRendererVirtualRendering()
        return renderer.isVirtualRendering
    end

    function manager.API.Library.setRendererVirtualRendering(...)
        return renderer:setVirtualRendering(...)
    end

    function manager.API.Library.getRendererVirtualSource()
        return (renderer.isVirtualRendering and renderer.virtualSource) or false
    end

    function manager.API.Library.getRendererVirtualRTs()
        return (renderer.isVirtualRendering and renderer.virtualRTs) or false
    end

    function manager.API.Library.isRendererTimeSynced(...)
        return renderer.isTimeSynced
    end

    function manager.API.Library.setRendererTimeSync(...)
        return renderer:setTimeSync(...)
    end

    function manager.API.Library.setRendererServerTick(...)
        return renderer:setServerTick(...)
    end

    function manager.API.Library.setRendererMinuteDuration(...)
        return renderer:setMinuteDuration(...)
    end

    function manager.API.Library.getRendererAntiAliasing()
        return renderer.isAntiAliased or 0
    end

    function manager.API.Library.setRendererAntiAliasing(...)
        return renderer:setAntiAliasing(...)
    end

    function manager.API.Library.isRendererEmissiveMode()
        return renderer.isEmissiveModeEnabled
    end

    function manager.API.Library.setRendererEmissiveMode(...)
        return renderer:setEmissiveMode(...)
    end

    function manager.API.Library.isRendererDynamicSky()
        return renderer.isDynamicSkyEnabled
    end

    function manager.API.Library.setRendererDynamicSky(...)
        return renderer:setDynamicSky(...)
    end

    function manager.API.Library.isRendererDynamicPrelights()
        return renderer.isDynamicPrelightsEnabled
    end

    function manager.API.Library.setRendererDynamicPrelights(...)
        return renderer:setDynamicPrelights(...)
    end

    function manager.API.Library.getRendererDynamicSunColor()
        return renderer.isDynamicSunColor[1]*255, renderer.isDynamicSunColor[2]*255, renderer.isDynamicSunColor[3]*255
    end

    function manager.API.Library.setRendererDynamicSunColor(...)
        return renderer:setDynamicSunColor(...)
    end

    function manager.API.Library.isRendererDynamicStars()
        return renderer.isDynamicStarsEnabled
    end

    function manager.API.Library.setRendererDynamicStars(...)
        return renderer:setDynamicStars(...)
    end

    function manager.API.Library.getRendererDynamicCloudDensity()
        return renderer.isDynamicCloudDensity
    end

    function manager.API.Library.setRendererDynamicCloudDensity(...)
        return renderer:setDynamicCloudDensity(...)
    end

    function manager.API.Library.getRendererDynamicCloudScale()
        return renderer.isDynamicCloudScale
    end

    function manager.API.Library.setRendererDynamicCloudScale(...)
        return renderer:setDynamicCloudScale(...)
    end

    function manager.API.Library.getRendererDynamicCloudColor()
        return renderer.isDynamicCloudColor[1]*255, renderer.isDynamicCloudColor[2]*255, renderer.isDynamicCloudColor[3]*255
    end

    function manager.API.Library.setRendererDynamicCloudColor(...)
        return renderer:setDynamicCloudColor(...)
    end

    function manager.API.Library.getRendererTimeCycle()
        return renderer.isDynamicTimeCycle
    end

    function manager.API.Library.setRendererTimeCycle(...)
        return renderer:setTimeCycle(...)
    end

    function manager.API.Library.createPlanarLight(...)
        local cLight = light.planar:create(...)
        return (cLight and cLight.cLight) or false
    end

    function manager.API.Library.setPlanarLightResolution(...)
        if not light.planar.buffer[cLight] then return false end
        return light.planar.buffer[cLight]:setResolution(...)
    end

    function manager.API.Library.setPlanarLightTexture(...)
        if not light.planar.buffer[cLight] then return false end
        return light.planar.buffer[cLight]:setTexture(...)
    end

    function manager.API.Library.setPlanarLightColor(...)
        if not light.planar.buffer[cLight] then return false end
        return light.planar.buffer[cLight]:setColor(...)
    end
else
    function manager.API.Library.loadResource(...)
        return manager:loadResource(...)
    end
end