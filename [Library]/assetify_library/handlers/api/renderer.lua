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
    manager:exportAPI("renderer", "isVirtualRendering", function()
        return renderer.isVirtualRendering
    end)

    manager:exportAPI("renderer", "setVirtualRendering", function(...)
        return renderer:setVirtualRendering(...)
    end)

    manager:exportAPI("renderer", "getVirtualSource", function()
        return (renderer.isVirtualRendering and renderer.virtualSource) or false
    end)

    manager:exportAPI("renderer", "getVirtualRTs", function()
        return (renderer.isVirtualRendering and renderer.virtualRTs) or false
    end)

    manager:exportAPI("renderer", "isTimeSynced", function(...)
        return renderer.isTimeSynced
    end)

    manager:exportAPI("renderer", "setTimeSync", function(...)
        return renderer:setTimeSync(...)
    end)

    manager:exportAPI("renderer", "setServerTick", function(...)
        return renderer:setServerTick(...)
    end)

    manager:exportAPI("renderer", "setMinuteDuration", function(...)
        return renderer:setMinuteDuration(...)
    end)

    manager:exportAPI("renderer", "getAntiAliasing", function()
        return renderer.isAntiAliased or 0
    end)

    manager:exportAPI("renderer", "setAntiAliasing", function(...)
        return renderer:setAntiAliasing(...)
    end)

    manager:exportAPI("renderer", "isEmissiveMode", function()
        return renderer.isEmissiveModeEnabled
    end)

    manager:exportAPI("renderer", "setEmissiveMode", function(...)
        return renderer:setEmissiveMode(...)
    end)

    manager:exportAPI("renderer", "isDynamicSky", function()
        return renderer.isDynamicSkyEnabled
    end)

    manager:exportAPI("renderer", "setDynamicSky", function(...)
        return renderer:setDynamicSky(...)
    end)

    manager:exportAPI("renderer", "isDynamicPrelights", function()
        return renderer.isDynamicPrelightsEnabled
    end)

    manager:exportAPI("renderer", "setDynamicPrelights", function(...)
        return renderer:setDynamicPrelights(...)
    end)

    manager:exportAPI("renderer", "getDynamicSunColor", function()
        return renderer.isDynamicSunColor[1]*255, renderer.isDynamicSunColor[2]*255, renderer.isDynamicSunColor[3]*255
    end)

    manager:exportAPI("renderer", "setDynamicSunColor", function(...)
        return renderer:setDynamicSunColor(...)
    end)

    manager:exportAPI("renderer", "isDynamicStars", function()
        return renderer.isDynamicStarsEnabled
    end)

    manager:exportAPI("renderer", "setDynamicStars", function(...)
        return renderer:setDynamicStars(...)
    end)

    manager:exportAPI("renderer", "getDynamicCloudDensity", function()
        return renderer.isDynamicCloudDensity
    end)

    manager:exportAPI("renderer", "setDynamicCloudDensity", function(...)
        return renderer:setDynamicCloudDensity(...)
    end)

    manager:exportAPI("renderer", "getDynamicCloudScale", function()
        return renderer.isDynamicCloudScale
    end)

    manager:exportAPI("renderer", "setDynamicCloudScale", function(...)
        return renderer:setDynamicCloudScale(...)
    end)

    manager:exportAPI("renderer", "getDynamicCloudColor", function()
        return renderer.isDynamicCloudColor[1]*255, renderer.isDynamicCloudColor[2]*255, renderer.isDynamicCloudColor[3]*255
    end)

    manager:exportAPI("renderer", "setDynamicCloudColor", function(...)
        return renderer:setDynamicCloudColor(...)
    end)

    manager:exportAPI("renderer", "getTimeCycle", function()
        return renderer.isDynamicTimeCycle
    end)

    manager:exportAPI("renderer", "setTimeCycle", function(...)
        return renderer:setTimeCycle(...)
    end)
else

end