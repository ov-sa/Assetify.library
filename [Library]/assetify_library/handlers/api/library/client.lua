----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: api: library: client.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Library APIs ]]--
----------------------------------------------------------------


-----------------------
--[[ APIs: Library ]]--
-----------------------

function manager.API.Library.getDownloadProgress(...)
    return manager:getDownloadProgress(...)
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

function manager.API.Library.isRendererDynamicSky()
    return renderer.isDynamicSkyEnabled
end

function manager.API.Library.setRendererDynamicSky(...)
    return renderer:setDynamicSky(...)
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