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

function manager.API.Library.setRendererTimeSync(...)
    return renderer:setTimeSync(...)
end

function manager.API.Library.setRendererServerTick(...)
    return renderer:setServerTick(...)
end

function manager.API.Library.setRendererMinuteDuration(...)
    return renderer:setMinuteDuration(...)
end

function manager.API.Library.setRendererAntiAliasing(...)
    return renderer:setAntiAliasing(...)
end

function manager.API.Library.getRendererAntiAliasing(...)
    return renderer:getAntiAliasing(...)
end

function manager.API.Library.isRendererDynamicSky(...)
    return renderer:isDynamicSky(...)
end

function manager.API.Library.setRendererDynamicSky(...)
    return renderer:setDynamicSky(...)
end

function manager.API.Library.getRendererTimeCycle(...)
    return renderer:getTimeCycle(...)
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