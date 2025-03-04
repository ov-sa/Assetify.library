----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: api: renderer.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Renderer APIs ]]--
----------------------------------------------------------------


------------------------
--[[ APIs: Renderer ]]--
------------------------

if localPlayer then
    manager:exportAPI("renderer", "isRendererVirtualRendering", function()
        return renderer.isVirtualRendering
    end)

    manager:exportAPI("renderer", "setRendererVirtualRendering", function(...)
        return renderer:setVirtualRendering(...)
    end)

    manager:exportAPI("renderer", "getRendererVirtualSource", function()
        return (renderer.isVirtualRendering and renderer.virtualSource) or false
    end)

    manager:exportAPI("renderer", "getRendererVirtualRTs", function()
        return (renderer.isVirtualRendering and renderer.virtualRTs) or false
    end)

    manager:exportAPI("renderer", "isRendererTimeSynced", function(...)
        return renderer.isTimeSynced
    end)

    manager:exportAPI("renderer", "setRendererTimeSync", function(...)
        return renderer:setTimeSync(...)
    end)

    manager:exportAPI("renderer", "setRendererServerTick", function(...)
        return renderer:setServerTick(...)
    end)

    manager:exportAPI("renderer", "setRendererMinuteDuration", function(...)
        return renderer:setMinuteDuration(...)
    end)

    manager:exportAPI("renderer", "getRendererAntiAliasing", function()
        return renderer.isAntiAliased or 0
    end)

    manager:exportAPI("renderer", "setRendererAntiAliasing", function(...)
        return renderer:setAntiAliasing(...)
    end)

    manager:exportAPI("renderer", "isRendererEmissiveMode", function()
        return renderer.isEmissiveModeEnabled
    end)

    manager:exportAPI("renderer", "setRendererEmissiveMode", function(...)
        return renderer:setEmissiveMode(...)
    end)

    manager:exportAPI("renderer", "isRendererDynamicSky", function()
        return renderer.isDynamicSkyEnabled
    end)

    manager:exportAPI("renderer", "setRendererDynamicSky", function(...)
        return renderer:setDynamicSky(...)
    end)

    manager:exportAPI("renderer", "isRendererDynamicPrelights", function()
        return renderer.isDynamicPrelightsEnabled
    end)

    manager:exportAPI("renderer", "setRendererDynamicPrelights", function(...)
        return renderer:setDynamicPrelights(...)
    end)

    manager:exportAPI("renderer", "getRendererDynamicSunColor", function()
        return renderer.isDynamicSunColor[1]*255, renderer.isDynamicSunColor[2]*255, renderer.isDynamicSunColor[3]*255
    end)

    manager:exportAPI("renderer", "setRendererDynamicSunColor", function(...)
        return renderer:setDynamicSunColor(...)
    end)

    manager:exportAPI("renderer", "isRendererDynamicStars", function()
        return renderer.isDynamicStarsEnabled
    end)

    manager:exportAPI("renderer", "setRendererDynamicStars", function(...)
        return renderer:setDynamicStars(...)
    end)

    manager:exportAPI("renderer", "getRendererDynamicCloudDensity", function()
        return renderer.isDynamicCloudDensity
    end)

    manager:exportAPI("renderer", "setRendererDynamicCloudDensity", function(...)
        return renderer:setDynamicCloudDensity(...)
    end)

    manager:exportAPI("renderer", "getRendererDynamicCloudScale", function()
        return renderer.isDynamicCloudScale
    end)

    manager:exportAPI("renderer", "setRendererDynamicCloudScale", function(...)
        return renderer:setDynamicCloudScale(...)
    end)

    manager:exportAPI("renderer", "getRendererDynamicCloudColor", function()
        return renderer.isDynamicCloudColor[1]*255, renderer.isDynamicCloudColor[2]*255, renderer.isDynamicCloudColor[3]*255
    end)

    manager:exportAPI("renderer", "setRendererDynamicCloudColor", function(...)
        return renderer:setDynamicCloudColor(...)
    end)

    manager:exportAPI("renderer", "getRendererTimeCycle", function()
        return renderer.isDynamicTimeCycle
    end)

    manager:exportAPI("renderer", "setRendererTimeCycle", function(...)
        return renderer:setTimeCycle(...)
    end)
else

end