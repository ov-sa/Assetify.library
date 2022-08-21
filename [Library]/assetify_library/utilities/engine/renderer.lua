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
    tostring = tostring,
    tonumber = tonumber,
    getTickCount = getTickCount,
    destroyElement = destroyElement,
    guiGetScreenSize = guiGetScreenSize,
    setSkyGradient = setSkyGradient,
    getSkyGradient = getSkyGradient,
    setCloudsEnabled = setCloudsEnabled,
    getCloudsEnabled = getCloudsEnabled,
    addEventHandler = addEventHandler,
    removeEventHandler = removeEventHandler,
    dxCreateScreenSource = dxCreateScreenSource,
    dxCreateRenderTarget = dxCreateRenderTarget,
    dxUpdateScreenSource = dxUpdateScreenSource,
    dxDrawImage = dxDrawImage
}


-------------------------
--[[ Class: Renderer ]]--
-------------------------

local renderer = class:create("renderer", {
    isVirtualRendering = false,
    isTimeSynced = false,
    isDynamicSkyEnabled = false
})
renderer.private.serverTick = 60*60*12
renderer.private.minuteDuration = 60

if localPlayer then
    renderer.public.resolution = {imports.guiGetScreenSize()}
    renderer.public.resolution[1], renderer.public.resolution[2] = renderer.public.resolution[1]*settings.renderer.resolution, renderer.public.resolution[2]*settings.renderer.resolution

    renderer.private.render = function()
        imports.dxUpdateScreenSource(renderer.public.virtualSource)
        imports.dxDrawImage(0, 0, renderer.public.resolution[1], renderer.public.resolution[2], shader.preLoaded["Assetify_TextureSampler"].cShader)
        --TODO: IT SHOULD BE DYNAMIC LATER
        local cameraX, cameraY, cameraZ, cameraLookX, cameraLookY, cameraLookZ = getCameraMatrix()
        local sunX, sunY = getScreenFromWorldPosition(0, 0, cameraLookZ + 200, 1, true)
        if sunX and sunY then shader.preLoaded["Assetify_TextureSampler"]:setValue("vSunViewOffset", {sunX, sunY}) end
        return true
    end

    function renderer.public:syncShader(syncShader)
        if not syncShader then return false end
        renderer.public:setVirtualRendering(_, _, syncShader, syncer.librarySerial)
        renderer.public:setTimeSync(_, syncShader, syncer.librarySerial)
        renderer.public:setServerTick(_, syncShader, syncer.librarySerial)
        renderer.public:setMinuteDuration(_, syncShader, syncer.librarySerial)
        renderer.public:setDynamicSky(_, syncShader, syncer.librarySerial)
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
                if rtModes and rtModes.diffuse then
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
            if not manager:isInternal(isInternal) then return false end
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
                renderer.public:setServerTick(((renderer.private.serverTick or 0)*1000) + (imports.getTickCount() - (renderer.public.__serverTick or 0)))
            end
            for i, j in imports.pairs(shader.buffer.shader) do
                renderer.public:setTimeSync(_, i, syncer.librarySerial)
            end
        else
            if not manager:isInternal(isInternal) then return false end
            syncShader:setValue("vTimeSync", renderer.public.isTimeSynced)
        end
        return true
    end

    function renderer.public:setServerTick(serverTick, syncShader, isInternal)
        if not syncShader then
            renderer.private.serverTick = (imports.tonumber(serverTick) or 0)*0.001
            renderer.public.__serverTick = imports.getTickCount()
            for i, j in imports.pairs(shader.buffer.shader) do
                renderer.public:setServerTick(_, i, syncer.librarySerial)
            end
        else
            if not manager:isInternal(isInternal) then return false end
            syncShader:setValue("vServerTick", renderer.private.serverTick)
        end
        return true
    end

    function renderer.public:setMinuteDuration(minuteDuration, syncShader, isInternal)
        if not syncShader then
            renderer.private.minuteDuration = imports.tonumber(minuteDuration) or 0
            for i, j in imports.pairs(shader.buffer.shader) do
                renderer.public:setMinuteDuration(_, i, syncer.librarySerial)
            end
        else
            if not manager:isInternal(isInternal) then return false end
            syncShader:setValue("vMinuteDuration", renderer.private.minuteDuration*0.001)
        end
        return true
    end

    function renderer.public:setAntiAliasing(intensity)
        intensity = imports.tonumber(intensity) or 0
        if renderer.public.isAntiAliased == intensity then return false end
        renderer.public.isAntiAliased = intensity
        shader.preLoaded["Assetify_TextureSampler"]:setValue("sampleIntensity", renderer.public.isAntiAliased)
        return true
    end

    function renderer.public:setDynamicSky(state, syncShader, isInternal)
        if not syncShader then
            state = (state and true) or false
            if renderer.public.isDynamicSkyEnabled == state then return false end
            renderer.public.isDynamicSkyEnabled = state
            renderer.public:setTimeCycle(renderer.public.timecycle)
            if state then
                renderer.private.prevNativeSkyGradient = table.pack(imports.getSkyGradient())
                renderer.private.prevNativeClouds = imports.getCloudsEnabled()
            end
            imports.setSkyGradient(table.unpack((not state and renderer.private.prevNativeSkyGradient) or {50, 50, 50, 50, 50, 50}))
            imports.setCloudsEnabled((not state and renderer.private.prevNativeClouds) or false)
            for i, j in imports.pairs(shader.buffer.shader) do
                renderer.public:setDynamicSky(_, i, syncer.librarySerial)
            end
        else
            if not manager:isInternal(isInternal) then return false end
            syncShader:setValue("vDynamicSkyEnabled", renderer.public.isDynamicSkyEnabled or false)
        end
        return true
    end

    function renderer.public:setDynamicSunColor(r, g, b)
        r, g, b = (imports.tonumber(r) or 0)/255, (imports.tonumber(g) or 0)/255, (imports.tonumber(b) or 0)/255
        renderer.public.isDynamicSunColor = renderer.public.isDynamicSunColor or {}
        if ((renderer.public.isDynamicSunColor[1] == r) and (renderer.public.isDynamicSunColor[2] == g) and (renderer.public.isDynamicSunColor[3] == b)) then return false end
        renderer.public.isDynamicSunColor[1], renderer.public.isDynamicSunColor[2], renderer.public.isDynamicSunColor[3] = r, g, b
        shader.preLoaded["Assetify_TextureSampler"]:setValue("sunColor", renderer.public.isDynamicSunColor)
        return true
    end

    function renderer.public:setDynamicStars(state)
        state = (state and true) or false
        if renderer.public.isDynamicStarsEnabled == state then return false end
        renderer.public.isDynamicStarsEnabled = state
        shader.preLoaded["Assetify_TextureSampler"]:setValue("isStarsEnabled", renderer.public.isDynamicStarsEnabled)
        return true
    end

    function renderer.public:setDynamicCloudDensity(density)
        density = imports.tonumber(density) or 0
        if renderer.public.isDynamicCloudDensity == density then return false end
        renderer.public.isDynamicCloudDensity = density
        shader.preLoaded["Assetify_TextureSampler"]:setValue("cloudDensity", renderer.public.isDynamicCloudDensity)
        return true
    end

    function renderer.public:setDynamicCloudScale(scale)
        density = imports.tonumber(scale) or 0
        if renderer.public.isDynamicCloudScale == scale then return false end
        renderer.public.isDynamicCloudScale = scale
        shader.preLoaded["Assetify_TextureSampler"]:setValue("cloudScale", renderer.public.isDynamicCloudScale)
        return true
    end

    function renderer.public:setDynamicCloudColor(r, g, b)
        r, g, b = (imports.tonumber(r) or 0)/255, (imports.tonumber(g) or 0)/255, (imports.tonumber(b) or 0)/255
        renderer.public.isDynamicCloudColor = renderer.public.isDynamicCloudColor or {}
        if ((renderer.public.isDynamicCloudColor[1] == r) and (renderer.public.isDynamicCloudColor[2] == g) and (renderer.public.isDynamicCloudColor[3] == b)) then return false end
        renderer.public.isDynamicCloudColor[1], renderer.public.isDynamicCloudColor[2], renderer.public.isDynamicCloudColor[3] = r, g, b
        iprint(renderer.public.isDynamicCloudColor)
        shader.preLoaded["Assetify_TextureSampler"]:setValue("cloudColor", renderer.public.isDynamicCloudColor)
        return true
    end

    function renderer.private.isTimeCycleValid(cycle)
        cycle = (cycle and (imports.type(cycle) == "table") and cycle) or false
        if not cycle then return false end
        local isValid = false
        for i = 1, 24, 1 do
            local j = imports.tostring(i)
            cycle[j] = (cycle[j] and (imports.type(cycle[j]) == "table") and cycle[j]) or false
            if cycle[j] then
                for k = 1, 3, 1 do
                    cycle[j][k] = (cycle[j][k] and (imports.type(cycle[j][k]) == "table") and (imports.type(cycle[j][k].color) == "string") and (imports.type(cycle[j][k].position) == "number") and cycle[j][k]) or false
                    isValid = (cycle[j][k] and true) or isValid
                end
            end
        end
        return isValid
    end

    function renderer.public:setTimeCycle(cycle)
        state = (state and true) or false
        if not renderer.private.isTimeCycleValid(cycle) then return false end
        for i = 1, 24, 1 do
            local j = imports.tostring(i)
            local vCycle, bCycle = cycle[j], {}
            if not vCycle then
                for k = i - 1, i - 23, -1 do
                    local v = ((k > 0) and k) or (24 + k)
                    local __vCycle = cycle[(imports.tostring(v))]
                    if __vCycle then
                        vCycle = __vCycle
                        break
                    end
                end
            end
            for k = 1, 3, 1 do
                local v = vCycle[k]
                local color = (v and {string.parseHex(v.color)}) or false
                local position = (v and v.position) or false
                table.insert(bCycle, (color and color[1]/255) or -1)
                table.insert(bCycle, (color and color[2]/255) or -1)
                table.insert(bCycle, (color and color[3]/255) or -1)
                table.insert(bCycle, (position and position/100) or -1)
            end
            shader.preLoaded["Assetify_TextureSampler"]:setValue("timecycle_"..i, bCycle)
        end
        renderer.public.isDynamicTimeCycle = cycle
        return true
    end
end