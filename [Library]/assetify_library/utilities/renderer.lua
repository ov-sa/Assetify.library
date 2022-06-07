----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: renderer.lua
     Author: vStudio
     Developer(s): Aviril, Tron
     DOC: 19/10/2021
     Desc: Renderer Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    tonumber = tonumber,
    getTickCount = getTickCount,
    isElement = isElement,
    destroyElement = destroyElement,
    guiGetScreenSize = guiGetScreenSize,
    addEventHandler = addEventHandler,
    removeEventHandler = removeEventHandler,
    dxCreateScreenSource = dxCreateScreenSource,
    dxCreateRenderTarget = dxCreateRenderTarget,
    dxUpdateScreenSource = dxUpdateScreenSource,
    dxSetShaderValue = dxSetShaderValue
}


-------------------------
--[[ Class: Renderer ]]--
-------------------------

renderer = {
    resolution = {imports.guiGetScreenSize()},
    cache = {
        isVirtualRendering = false,
        isTimeSynced = false,
        serverTick = 60*60*12,
        minuteDuration = 60
    }
}
renderer.resolution[1], renderer.resolution[2] = renderer.resolution[1]*rendererSettings.resolution, renderer.resolution[2]*rendererSettings.resolution
renderer.__index = renderer

renderer.render = function()
    imports.dxUpdateScreenSource(renderer.cache.virtualSource)
    return true
end

function renderer:syncShader(syncShader)
    if not syncShader then return false end
    renderer:setVirtualRendering(_, _, syncShader, syncer.librarySerial)
    renderer:setTimeSync(_, syncShader, syncer.librarySerial)
    renderer:setServerTick(_, syncShader, syncer.librarySerial)
    renderer:setMinuteDuration(_, syncShader, syncer.librarySerial)
    return true
end

function renderer:setVirtualRendering(state, rtModes, syncShader, isInternal)
    if not syncShader then
        state = (state and true) or false
        rtModes = (rtModes and (imports.type(rtModes) == "table") and rtModes) or false
        if renderer.cache.isVirtualRendering == state then return false end
        renderer.cache.isVirtualRendering = state
        if renderer.cache.isVirtualRendering then
            renderer.cache.virtualSource = imports.dxCreateScreenSource(renderer.resolution[1], renderer.resolution[2])
            renderer.cache.virtualRTs = renderer.cache.virtualRTs or {}
            if rtModes.diffuse then
                renderer.cache.virtualRTs.diffuse = imports.dxCreateRenderTarget(renderer.resolution[1], renderer.resolution[2], true)
                if rtModes.emissive then
                    renderer.cache.virtualRTs.emissive = imports.dxCreateRenderTarget(renderer.resolution[1], renderer.resolution[2], false)
                end
            end
            imports.addEventHandler("onClientHUDRender", root, renderer.render)
        else
            imports.removeEventHandler("onClientHUDRender", root, renderer.render)
            if renderer.cache.virtualSource and imports.isElement(renderer.cache.virtualSource) then
                imports.destroyElement(renderer.cache.virtualSource)
            end
            renderer.cache.virtualSource = nil
            for i, j in imports.pairs(renderer.cache.virtualRTs) do
                if j and imports.isElement(j) then
                    imports.destroyElement(j)
                end
                renderer.cache.virtualRTs[i] = nil
            end
        end
        for i, j in imports.pairs(shader.buffer.shader) do
            renderer:setVirtualRendering(_, _, i, syncer.librarySerial)
        end
    else
        local isExternalResource = sourceResource and (sourceResource ~= syncer.libraryResource)
        if (not isInternal or (isInternal ~= syncer.librarySerial)) and isExternalResource then
            return false
        end
        local vSource0, vSource1, vSource2 = (renderer.cache.isVirtualRendering and renderer.cache.virtualSource) or false, (renderer.cache.isVirtualRendering and renderer.cache.virtualRTs.diffuse) or false, (renderer.cache.isVirtualRendering and renderer.cache.virtualRTs.emissive) or false
        imports.dxSetShaderValue(syncShader, "vResolution", (renderer.cache.isVirtualRendering and renderer.resolution) or false)
        imports.dxSetShaderValue(syncShader, "vRenderingEnabled", (renderer.cache.isVirtualRendering and true) or false)
        imports.dxSetShaderValue(syncShader, "vSource0", vSource0)
        imports.dxSetShaderValue(syncShader, "vSource1", vSource1)
        imports.dxSetShaderValue(syncShader, "vSource1Enabled", (vSource1 and true) or false)
        imports.dxSetShaderValue(syncShader, "vSource2", vSource2)
        imports.dxSetShaderValue(syncShader, "vSource2Enabled", (vSource2 and true) or false)
    end
    return true
end

function renderer:setTimeSync(state, syncShader, isInternal)
    if not syncShader then
        state = (state and true) or false
        if renderer.cache.isTimeSynced == state then return false end
        renderer.cache.isTimeSynced = state
        if not renderer.cache.isTimeSynced then
            renderer:setServerTick(((renderer.cache.serverTick or 0)*1000) + (imports.getTickCount() - (renderer.cache.__serverTick or 0)))
        end
        for i, j in imports.pairs(shader.buffer.shader) do
            renderer:setTimeSync(_, i, syncer.librarySerial)
        end
    else
        local isExternalResource = sourceResource and (sourceResource ~= syncer.libraryResource)
        if (not isInternal or (isInternal ~= syncer.librarySerial)) and isExternalResource then
            return false
        end
        imports.dxSetShaderValue(syncShader, "gTimeSync", renderer.cache.isTimeSynced)
    end
    return true
end

function renderer:setServerTick(serverTick, syncShader, isInternal)
    if not syncShader then
        renderer.cache.serverTick = (imports.tonumber(serverTick) or 0)*0.001
        renderer.cache.__serverTick = imports.getTickCount()
        for i, j in imports.pairs(shader.buffer.shader) do
            renderer:setServerTick(_, i, syncer.librarySerial)
        end
    else
        local isExternalResource = sourceResource and (sourceResource ~= syncer.libraryResource)
        if (not isInternal or (isInternal ~= syncer.librarySerial)) and isExternalResource then
            return false
        end
        imports.dxSetShaderValue(syncShader, "gServerTick", renderer.cache.serverTick)
    end
    return true
end

function renderer:setMinuteDuration(minuteDuration, syncShader, isInternal)
    if not syncShader then
        renderer.cache.minuteDuration = (imports.tonumber(minuteDuration) or 0)*0.001
        for i, j in imports.pairs(shader.buffer.shader) do
            renderer:setMinuteDuration(_, i, syncer.librarySerial)
        end
    else
        local isExternalResource = sourceResource and (sourceResource ~= syncer.libraryResource)
        if (not isInternal or (isInternal ~= syncer.librarySerial)) and isExternalResource then
            return false
        end
        imports.dxSetShaderValue(syncShader, "gMinuteDuration", renderer.cache.minuteDuration)
    end
    return true
end