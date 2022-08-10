----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: engine: renderer.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
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
    destroyElement = destroyElement,
    guiGetScreenSize = guiGetScreenSize,
    addEventHandler = addEventHandler,
    removeEventHandler = removeEventHandler,
    dxCreateScreenSource = dxCreateScreenSource,
    dxCreateRenderTarget = dxCreateRenderTarget,
    dxUpdateScreenSource = dxUpdateScreenSource
}


-------------------------
--[[ Class: Renderer ]]--
-------------------------

local renderer = class:create("renderer", {
    isVirtualRendering = false,
    isTimeSynced = false,
    serverTick = 60*60*12,
    minuteDuration = 60
})

if localPlayer then
    renderer.public.resolution = {imports.guiGetScreenSize()}
    renderer.public.resolution[1], renderer.public.resolution[2] = renderer.public.resolution[1]*settings.renderer.resolution, renderer.public.resolution[2]*settings.renderer.resolution

    renderer.private.render = function()
        imports.dxUpdateScreenSource(renderer.public.virtualSource)
        imports.dxDrawImage(0, 0, renderer.public.resolution[1], renderer.public.resolution[2], shader.preLoaded["Assetify_TextureSampler"])
        return true
    end

    function renderer.public:syncShader(syncShader)
        if not syncShader then return false end
        renderer.public:setVirtualRendering(_, _, syncShader, syncer.librarySerial)
        renderer.public:setTimeSync(_, syncShader, syncer.librarySerial)
        renderer.public:setServerTick(_, syncShader, syncer.librarySerial)
        renderer.public:setMinuteDuration(_, syncShader, syncer.librarySerial)
        return true
    end

    function renderer.public:setVirtualRendering(state, rtModes, syncShader, isInternal)
        if not syncShader then
            state = (state and true) or false
            rtModes = (rtModes and (imports.type(rtModes) == "table") and rtModes) or false
            if renderer.public.isVirtualRendering == state then return false end
            renderer.public.isVirtualRendering = state
            if renderer.public.isVirtualRendering then
                renderer.public.virtualSource = imports.dxCreateScreenSource(renderer.public.resolution[1], renderer.public.resolution[2])
                renderer.public.virtualRTs = renderer.public.virtualRTs or {}
                if rtModes.diffuse then
                    renderer.public.virtualRTs.diffuse = imports.dxCreateRenderTarget(renderer.public.resolution[1], renderer.public.resolution[2], true)
                    if rtModes.emissive then
                        renderer.public.virtualRTs.emissive = imports.dxCreateRenderTarget(renderer.public.resolution[1], renderer.public.resolution[2], false)
                    end
                end
                imports.addEventHandler("onClientHUDRender", root, renderer.private.render)
            else
                imports.removeEventHandler("onClientHUDRender", root, renderer.private.render)
                imports.destroyElement(renderer.public.virtualSource)
                renderer.public.virtualSource = nil
                for i, j in imports.pairs(renderer.public.virtualRTs) do
                    imports.destroyElement(j)
                    renderer.public.virtualRTs[i] = nil
                end
            end
            for i, j in imports.pairs(shader.buffer.shader) do
                renderer.public:setVirtualRendering(_, _, i, syncer.librarySerial)
            end
        else
            local isExternalResource = sourceResource and (sourceResource ~= syncer.libraryResource)
            if (not isInternal or (isInternal ~= syncer.librarySerial)) and isExternalResource then return false end
            local vSource0, vSource1, vSource2 = (renderer.public.isVirtualRendering and renderer.public.virtualSource) or false, (renderer.public.isVirtualRendering and renderer.public.virtualRTs.diffuse) or false, (renderer.public.isVirtualRendering and renderer.public.virtualRTs.emissive) or false
            syncShader:setValue("vResolution", (renderer.public.isVirtualRendering and renderer.public.resolution) or false)
            syncShader:setValue("vRenderingEnabled", (renderer.public.isVirtualRendering and true) or false)
            syncShader:setValue("vSource0", vSource0)
            syncShader:setValue("vSource1", vSource1)
            syncShader:setValue("vSource1Enabled", (vSource1 and true) or false)
            syncShader:setValue("vSource2", vSource2)
            syncShader:setValue("vSource2Enabled", (vSource2 and true) or false)
        end
        return true
    end

    function renderer.public:setTimeSync(state, syncShader, isInternal)
        if not syncShader then
            state = (state and true) or false
            if renderer.public.isTimeSynced == state then return false end
            renderer.public.isTimeSynced = state
            if not renderer.public.isTimeSynced then
                renderer.public:setServerTick(((renderer.public.serverTick or 0)*1000) + (imports.getTickCount() - (renderer.public.__serverTick or 0)))
            end
            for i, j in imports.pairs(shader.buffer.shader) do
                renderer.public:setTimeSync(_, i, syncer.librarySerial)
            end
        else
            local isExternalResource = sourceResource and (sourceResource ~= syncer.libraryResource)
            if (not isInternal or (isInternal ~= syncer.librarySerial)) and isExternalResource then return false end
            syncShader:setValue("gTimeSync", renderer.public.isTimeSynced)
        end
        return true
    end

    function renderer.public:setServerTick(serverTick, syncShader, isInternal)
        if not syncShader then
            renderer.public.serverTick = (imports.tonumber(serverTick) or 0)*0.001
            renderer.public.__serverTick = imports.getTickCount()
            for i, j in imports.pairs(shader.buffer.shader) do
                renderer.public:setServerTick(_, i, syncer.librarySerial)
            end
        else
            local isExternalResource = sourceResource and (sourceResource ~= syncer.libraryResource)
            if (not isInternal or (isInternal ~= syncer.librarySerial)) and isExternalResource then return false end
            syncShader:setValue("gServerTick", renderer.public.serverTick)
        end
        return true
    end

    function renderer.public:setMinuteDuration(minuteDuration, syncShader, isInternal)
        if not syncShader then
            renderer.public.minuteDuration = (imports.tonumber(minuteDuration) or 0)*0.001
            for i, j in imports.pairs(shader.buffer.shader) do
                renderer.public:setMinuteDuration(_, i, syncer.librarySerial)
            end
        else
            local isExternalResource = sourceResource and (sourceResource ~= syncer.libraryResource)
            if (not isInternal or (isInternal ~= syncer.librarySerial)) and isExternalResource then return false end
            syncShader:setValue("gMinuteDuration", renderer.public.minuteDuration)
        end
        return true
    end

    function renderer.public:setAntiAliasing(intensity)
        renderer.public.antialiasing = imports.tonumber(intensity) or 0
        shader.preLoaded["Assetify_TextureSampler"]:setValue("sampleIntensity", renderer.public.antialiasing)
        return true
    end

    function renderer.public:getAntiAliasing()
        return renderer.public.antialiasing or 0
    end
end