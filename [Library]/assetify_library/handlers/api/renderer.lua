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
    manager:exportAPI("renderer", "isRendering", function() return renderer.state end)
    manager:exportAPI("renderer", "setRendering", function(...) return renderer:setRendering(...) end)
    manager:exportAPI("renderer", "getVirtualSource", function() return (renderer.state and renderer.vsource) or false end)
    manager:exportAPI("renderer", "getVirtualRTs", function() return (renderer.state and renderer.vrt) or false end)
    manager:exportAPI("renderer", "isEmissiveMode", function() return renderer.isEmissiveModeEnabled end)
    manager:exportAPI("renderer", "setEmissiveMode", function(...) return renderer:setEmissiveMode(...) end)
    manager:exportAPI("renderer", "getTimeCycle", function() return renderer.timecycle end)
    manager:exportAPI("renderer", "setTimeCycle", function(...) return renderer:setTimeCycle(...) end)
    manager:exportAPI("renderer", "isDynamicSky", function(...) return renderer.sky.state end)
    manager:exportAPI("renderer", "setDynamicSky", function(...) return renderer:setDynamicSky(...) end)
    manager:exportAPI("renderer", "getDynamicCloudSpeed", function() return renderer.sky.cloud.speed end)
    manager:exportAPI("renderer", "setDynamicCloudSpeed", function(...) return renderer:setDynamicCloudSpeed(...) end)
    manager:exportAPI("renderer", "getDynamicCloudScale", function() return renderer.sky.cloud.scale end)
    manager:exportAPI("renderer", "setDynamicCloudScale", function(...) return renderer:setDynamicCloudScale(...) end)
    manager:exportAPI("renderer", "getDynamicCloudDirection", function() return renderer.sky.cloud.direction end)
    manager:exportAPI("renderer", "setDynamicCloudDirection", function(...) return renderer:setDynamicCloudDirection(...) end)
    manager:exportAPI("renderer", "getDynamicCloudColor", function() return renderer.sky.cloud.color end)
    manager:exportAPI("renderer", "setDynamicCloudColor", function(...) return renderer:setDynamicCloudColor(...) end)
    manager:exportAPI("renderer", "getDynamicStarSpeed", function() return renderer.sky.star.speed end)
    manager:exportAPI("renderer", "setDynamicStarSpeed", function(...) return renderer:setDynamicStarSpeed(...) end)
    manager:exportAPI("renderer", "getDynamicStarScale", function() return renderer.sky.star.scale end)
    manager:exportAPI("renderer", "setDynamicStarScale", function(...) return renderer:setDynamicStarScale(...) end)
    manager:exportAPI("renderer", "getDynamicStarIntensity", function() return renderer.sky.star.intensity end)
    manager:exportAPI("renderer", "setDynamicStarIntensity", function(...) return renderer:setDynamicStarIntensity(...) end)
    manager:exportAPI("renderer", "getDynamicMoonScale", function() return renderer.sky.moon.scale end)
    manager:exportAPI("renderer", "setDynamicMoonScale", function(...) return renderer:setDynamicMoonScale(...) end)
    manager:exportAPI("renderer", "getDynamicMoonBrightness", function() return renderer.sky.moon.brightness end)
    manager:exportAPI("renderer", "setDynamicMoonBrightness", function(...) return renderer:setDynamicMoonBrightness(...) end)
    manager:exportAPI("renderer", "getDynamicMoonEmissiveScale", function() return renderer.sky.moon.emissive.scale end)
    manager:exportAPI("renderer", "setDynamicMoonEmissiveScale", function(...) return renderer:setDynamicMoonEmissiveScale(...) end)
    manager:exportAPI("renderer", "getDynamicMoonEmissiveIntensity", function() return renderer.sky.moon.emissive.intensity end)
    manager:exportAPI("renderer", "setDynamicMoonEmissiveIntensity", function(...) return renderer:setDynamicMoonEmissiveIntensity(...) end)
else

end