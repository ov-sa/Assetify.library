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
    setTime = setTime,
    setSkyGradient = setSkyGradient,
    getSkyGradient = getSkyGradient,
    setCloudsEnabled = setCloudsEnabled,
    getCloudsEnabled = getCloudsEnabled,
    getCameraMatrix = getCameraMatrix,
    getScreenFromWorldPosition = getScreenFromWorldPosition,
    addEventHandler = addEventHandler,
    removeEventHandler = removeEventHandler,
    dxCreateScreenSource = dxCreateScreenSource,
    dxCreateRenderTarget = dxCreateRenderTarget,
    dxUpdateScreenSource = dxUpdateScreenSource,
    dxGetTexturePixels = dxGetTexturePixels,
    dxGetPixelColor = dxGetPixelColor,
    dxDrawImage = dxDrawImage,
    interpolateBetween = interpolateBetween
}


-------------------------
--[[ Class: Renderer ]]--
-------------------------

local renderer = class:create("renderer", {
    isVirtualRendering = false,
    isTimeSynced = false,
    isEmissiveModeEnabled = false,
    isDynamicSkyEnabled = false
})
renderer.private.serverTick = 60*60*12*1000
renderer.private.minuteDuration = 60*1000

if localPlayer then
    renderer.public.resolution = {imports.guiGetScreenSize()}
    renderer.public.resolution[1], renderer.public.resolution[2] = renderer.public.resolution[1]*settings.renderer.resolution, renderer.public.resolution[2]*settings.renderer.resolution

    renderer.private.render = function()
        imports.dxUpdateScreenSource(renderer.public.virtualSource)
        imports.dxDrawImage(0, 0, renderer.public.resolution[1], renderer.public.resolution[2], shader.preLoaded["Assetify_TextureSampler"].cShader)
        if renderer.public.isEmissiveModeEnabled then
            outputChatBox("RENDERING EMISSIVE SHADER...")
            imports.dxDrawImage(0, 0, 0, 0, renderer.private.emissiveBuffer.shader) --TODO: IS THIS NEEDED?
            imports.dxDrawImage(0, 0, renderer.public.resolution[1], renderer.public.resolution[2], renderer.private.emissiveBuffer.rt)
        end
        if renderer.public.isDynamicSkyEnabled then
            if renderer.public.isTimeSynced then
                local currentTick = imports.getTickCount()
                if not renderer.private.serverTimeCycleTick or ((currentTick - renderer.private.serverTimeCycleTick) >= renderer.private.minuteDuration*30) then
                    renderer.private.serverTimeCycleTick = currentTick
                    renderer.private.serverNativeSkyColor, renderer.private.serverNativeTimePercent = renderer.private.serverNativeSkyColor or {}, renderer.private.serverNativeTimePercent or {}
                    local r, g, b = imports.dxGetPixelColor(imports.dxGetTexturePixels(renderer.private.skyRT, renderer.public.resolution[1]*0.5, renderer.public.resolution[2]*0.5, 1, 1), 0, 0)
                    renderer.private.serverNativeTimePercent[1] = ((renderer.private.serverNativeSkyColor[1] or r) + (renderer.private.serverNativeSkyColor[2] or g) + (renderer.private.serverNativeSkyColor[3] or b))/(3*255)
                    renderer.private.serverNativeSkyColor[1], renderer.private.serverNativeSkyColor[2], renderer.private.serverNativeSkyColor[3] = r, g, b
                    renderer.private.serverNativeTimePercent[2] = (renderer.private.serverNativeSkyColor[1] + renderer.private.serverNativeSkyColor[2] + renderer.private.serverNativeSkyColor[3])/(3*255)
                    r, g, b = r*0.5, g*0.5, b*0.5
                    imports.setSkyGradient(r, g, b, r, g, b)
                end
                if renderer.public.isDynamicPrelightsEnabled then
                    local currentTime = 12*imports.interpolateBetween(renderer.private.serverNativeTimePercent[1], 0, 0, renderer.private.serverNativeTimePercent[2], 0, 0, 0.25, "OutQuad")
                    local currentHour = math.floor(currentTime)
                    local currentMinute = (currentTime - currentHour)*30
                    imports.setTime(currentHour, currentMinute)
                end
            end
            local _, _, _, _, _, cameraLookZ = imports.getCameraMatrix()
            local sunX, sunY = imports.getScreenFromWorldPosition(0, 0, cameraLookZ + 200, 1, true)
            local isSunInView = (sunX and sunY and true) or false
            if (renderer.private.isSunInView and not isSunInView) or isSunInView then shader.preLoaded["Assetify_TextureSampler"]:setValue("vSunViewOffset", {(isSunInView and sunX) or -renderer.public.resolution[1], (isSunInView and sunY) or -renderer.public.resolution[2]}) end
            renderer.private.isSunInView = isSunInView
        end
        return true
    end

    function renderer.public:syncShader(syncShader)
        if not syncShader then return false end
        local isTexSampler = syncShader.shaderData.shaderName == "Assetify_TextureSampler"
        if isTexSampler then shader.preLoaded["Assetify_TextureSampler"] = syncShader end
        renderer.public:setVirtualRendering(_, _, syncShader, syncer.librarySerial)
        renderer.public:setTimeSync(_, syncShader, syncer.librarySerial)
        renderer.public:setServerTick(_, syncShader, syncer.librarySerial)
        renderer.public:setMinuteDuration(_, syncShader, syncer.librarySerial)
        renderer.public:setDynamicSky(_, syncShader, syncer.librarySerial)
        if isTexSampler then syncShader.isTexSamplerLoaded = true end
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
                shader:create(_, "Assetify ━ PreLoaded", "Assetify_TextureSampler", _, {}, {}, {}, _, _, shader.shaderPriority + 1, _, true, syncer.librarySerial)
                imports.addEventHandler("onClientHUDRender", root, renderer.private.render)
            else
                imports.removeEventHandler("onClientHUDRender", root, renderer.private.render)
                renderer.public:setEmissiveMode(false)
                shader.preLoaded["Assetify_TextureSampler"]:destroy(true, syncer.librarySerial)
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
                renderer.public:setServerTick((renderer.private.serverTick or 0) + (imports.getTickCount() - (renderer.private.serverTickFrame or 0)))
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
            renderer.private.serverTick = imports.tonumber(serverTick) or 0
            renderer.private.serverTickFrame = imports.getTickCount()
            for i, j in imports.pairs(shader.buffer.shader) do
                renderer.public:setServerTick(_, i, syncer.librarySerial)
            end
        else
            if not manager:isInternal(isInternal) then return false end
            syncShader:setValue("vServerTick", renderer.private.serverTick*0.001)
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

    function renderer.public:setAntiAliasing(intensity, isInternal)
        if isInternal and not manager:isInternal(isInternal) then return false end
        if not isInternal then
            intensity = imports.tonumber(intensity) or 0
            if renderer.public.isAntiAliased == intensity then return false end
            renderer.public.isAntiAliased = intensity
        end
        if shader.preLoaded["Assetify_TextureSampler"] then shader.preLoaded["Assetify_TextureSampler"]:setValue("sampleIntensity", renderer.public.isAntiAliased or false) end
        return true
    end

    function renderer.public:setEmissiveMode(state)
        state = (state and true) or false
        if not renderer.public.isVirtualRendering or not renderer.public.virtualRTs.emissive then return false end
        if renderer.public.isEmissiveModeEnabled == state then return false end
        renderer.public.isEmissiveModeEnabled = state
        if state then
            local intermediateRT = imports.dxCreateRenderTarget(renderer.public.resolution[1], renderer.public.resolution[2], true)
            local resultRT = imports.dxCreateRenderTarget(renderer.public.resolution[1], renderer.public.resolution[2], true)
            renderer.private.emissiveBuffer = {
                rt = resultRT,
                shader = shader:create(_, "Assetify ━ PreLoaded", "Assetify_TextureBloomer", _, {["vEmissive0"] = 1, ["vEmissive1"] = 2}, {}, {texture = {[1] = intermediateRT, [2] = resultRT}}, _, _, shader.shaderPriority + 1, _, true)
            }
        else
            renderer.private.emissiveBuffer.shader:destroy()
            renderer.private.emissiveBuffer = nil
        end
        return true
    end

    function renderer.public:setDynamicSky(state, syncShader, isInternal)
        if not syncShader then
            state = (state and true) or false
            if renderer.public.isDynamicSkyEnabled == state then return false end
            renderer.public.isDynamicSkyEnabled = state
            if state then
                renderer.private.prevNativeSkyGradient = table.pack(imports.getSkyGradient())
                renderer.private.prevNativeClouds = imports.getCloudsEnabled()
                renderer.private.skyRT = imports.dxCreateRenderTarget(renderer.public.resolution[1], renderer.public.resolution[2])
            else
                imports.destroyElement(renderer.private.skyRT)
                renderer.private.skyRT = nil
                imports.setSkyGradient(table.unpack(renderer.private.prevNativeSkyGradient))
            end
            imports.setCloudsEnabled((not state and renderer.private.prevNativeClouds) or false)
            for i, j in imports.pairs(shader.buffer.shader) do
                renderer.public:setDynamicSky(_, i, syncer.librarySerial)
            end
        else
            if not manager:isInternal(isInternal) then return false end
            syncShader:setValue("vDynamicSkyEnabled", renderer.public.isDynamicSkyEnabled or false)
            if shader.preLoaded["Assetify_TextureSampler"] and (shader.preLoaded["Assetify_TextureSampler"] == syncShader) then
                shader.preLoaded["Assetify_TextureSampler"]:setValue("vSky0", renderer.private.skyRT)
                if not shader.preLoaded["Assetify_TextureSampler"].isTexSamplerLoaded then
                    renderer.public:setAntiAliasing(_, syncer.librarySerial)
                    renderer.public:setDynamicSunColor(_, _, _, syncer.librarySerial)
                    renderer.public:setDynamicStars(_, syncer.librarySerial)
                    renderer.public:setDynamicCloudDensity(_, syncer.librarySerial)
                    renderer.public:setDynamicCloudScale(_, syncer.librarySerial)
                    renderer.public:setDynamicCloudColor(_, _, _, syncer.librarySerial)
                    renderer.public:setTimeCycle(_, syncer.librarySerial)
                end
            end
        end
        return true
    end

    function renderer.public:setDynamicPrelights(state)
        state = (state and true) or false
        if renderer.public.isDynamicPrelightsEnabled == state then return false end
        renderer.public.isDynamicPrelightsEnabled = state
        return true
    end

    function renderer.public:setDynamicSunColor(r, g, b, isInternal)
        if isInternal and not manager:isInternal(isInternal) then return false end
        if not isInternal then
            r, g, b = (imports.tonumber(r) or 0)/255, (imports.tonumber(g) or 0)/255, (imports.tonumber(b) or 0)/255
            renderer.public.isDynamicSunColor = renderer.public.isDynamicSunColor or {}
            if ((renderer.public.isDynamicSunColor[1] == r) and (renderer.public.isDynamicSunColor[2] == g) and (renderer.public.isDynamicSunColor[3] == b)) then return false end
            renderer.public.isDynamicSunColor[1], renderer.public.isDynamicSunColor[2], renderer.public.isDynamicSunColor[3] = r, g, b
        end
        if shader.preLoaded["Assetify_TextureSampler"] then shader.preLoaded["Assetify_TextureSampler"]:setValue("sunColor", renderer.public.isDynamicSunColor) end
        return true
    end

    function renderer.public:setDynamicStars(state, isInternal)
        if isInternal and not manager:isInternal(isInternal) then return false end
        if not isInternal then
            state = (state and true) or false
            if renderer.public.isDynamicStarsEnabled == state then return false end
            renderer.public.isDynamicStarsEnabled = state
        end
        if shader.preLoaded["Assetify_TextureSampler"] then shader.preLoaded["Assetify_TextureSampler"]:setValue("isStarsEnabled", renderer.public.isDynamicStarsEnabled) end
        return true
    end

    function renderer.public:setDynamicCloudDensity(density, isInternal)
        if isInternal and not manager:isInternal(isInternal) then return false end
        if not isInternal then
            density = imports.tonumber(density) or 0
            if renderer.public.isDynamicCloudDensity == density then return false end
            renderer.public.isDynamicCloudDensity = density
        end
        if shader.preLoaded["Assetify_TextureSampler"] then shader.preLoaded["Assetify_TextureSampler"]:setValue("cloudDensity", renderer.public.isDynamicCloudDensity) end
        return true
    end

    function renderer.public:setDynamicCloudScale(scale, isInternal)
        if isInternal and not manager:isInternal(isInternal) then return false end
        if not isInternal then
            density = imports.tonumber(scale) or 0
            if renderer.public.isDynamicCloudScale == scale then return false end
            renderer.public.isDynamicCloudScale = scale
        end
        if shader.preLoaded["Assetify_TextureSampler"] then shader.preLoaded["Assetify_TextureSampler"]:setValue("cloudScale", renderer.public.isDynamicCloudScale) end
        return true
    end

    function renderer.public:setDynamicCloudColor(r, g, b, isInternal)
        if isInternal and not manager:isInternal(isInternal) then return false end
        if not isInternal then
            r, g, b = (imports.tonumber(r) or 0)/255, (imports.tonumber(g) or 0)/255, (imports.tonumber(b) or 0)/255
            renderer.public.isDynamicCloudColor = renderer.public.isDynamicCloudColor or {}
            if ((renderer.public.isDynamicCloudColor[1] == r) and (renderer.public.isDynamicCloudColor[2] == g) and (renderer.public.isDynamicCloudColor[3] == b)) then return false end
            renderer.public.isDynamicCloudColor[1], renderer.public.isDynamicCloudColor[2], renderer.public.isDynamicCloudColor[3] = r, g, b
        end
        if shader.preLoaded["Assetify_TextureSampler"] then shader.preLoaded["Assetify_TextureSampler"]:setValue("cloudColor", renderer.public.isDynamicCloudColor) end
        return true
    end

    function renderer.private.isTimeCycleValid(cycle)
        cycle = (cycle and (imports.type(cycle) == "table") and cycle) or false
        if not cycle then return false end
        local isValid = false
        for i = 1, 24, 1 do
            cycle[i] = (cycle[i] and (imports.type(cycle[i]) == "table") and cycle[i]) or false
            if cycle[i] then
                for k = 1, 3, 1 do
                    cycle[i][k] = (cycle[i][k] and (imports.type(cycle[i][k]) == "table") and (imports.type(cycle[i][k].color) == "string") and (imports.type(cycle[i][k].position) == "number") and cycle[i][k]) or false
                    isValid = (cycle[i][k] and true) or isValid
                end
            end
        end
        return isValid
    end

    function renderer.public:setTimeCycle(cycle, isInternal)
        if isInternal and not manager:isInternal(isInternal) then return false end
        if not isInternal then
            if not renderer.private.isTimeCycleValid(cycle) then return false end
            renderer.public.isDynamicTimeCycle = cycle
        end
        for i = 1, 24, 1 do
            local vCycle, bCycle = renderer.public.isDynamicTimeCycle[i], {}
            if not vCycle then
                for k = i - 1, i - 23, -1 do
                    local v = ((k > 0) and k) or (24 + k)
                    local __vCycle = renderer.public.isDynamicTimeCycle[v]
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
            if shader.preLoaded["Assetify_TextureSampler"] then shader.preLoaded["Assetify_TextureSampler"]:setValue("timecycle_"..i, bCycle) end
        end
        return true
    end
end