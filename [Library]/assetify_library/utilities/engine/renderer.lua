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
    getCamera = getCamera,
    getTickCount = getTickCount,
    destroyElement = destroyElement,
    guiGetScreenSize = guiGetScreenSize,
    setTime = setTime,
    setSkyGradient = setSkyGradient,
    getSkyGradient = getSkyGradient,
    getCloudsEnabled = getCloudsEnabled,
    getCameraMatrix = getCameraMatrix,
    getScreenFromWorldPosition = getScreenFromWorldPosition,
    addEventHandler = addEventHandler,
    removeEventHandler = removeEventHandler,
    dxCreateTexture = dxCreateTexture,
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
    state = false,
    isTimeSynced = false,
    sky = {state = false}
})
renderer.private.serverTick = 60*60*12*1000
renderer.private.minuteDuration = 60*1000
renderer.private.sky = {
    depth = {
        value = 300
    },
    cloud = {
        height = 300
    }
}

if localPlayer then
    renderer.public.camera = imports.getCamera()
    renderer.public.resolution = {imports.guiGetScreenSize()}
    renderer.public.resolution[1], renderer.public.resolution[2] = renderer.public.resolution[1]*settings.renderer.resolution, renderer.public.resolution[2]*settings.renderer.resolution
    renderer.private.sky.cloud.texture = imports.dxCreateTexture("utilities/rw/mesh_sky/textures/cloud.rw", "dxt3")

    renderer.private.render = function()
        imports.dxUpdateScreenSource(renderer.public.vsource)
        --imports.dxDrawImage(0, 0, renderer.public.resolution[1], renderer.public.resolution[2], shader.preLoaded["Assetify_Tex_Sky"].cShader)
        if renderer.public.isEmissiveModeEnabled then
            --[[
            outputChatBox("RENDERING EMISSIVE SHADER...")
            imports.dxDrawImage(0, 0, 0, 0, renderer.private.emissiveBuffer.shader) --TODO: IS THIS NEEDED?
            imports.dxDrawImage(0, 0, renderer.public.resolution[1], renderer.public.resolution[2], renderer.private.emissiveBuffer.rt)
            ]]
        end
        if renderer.public.sky.state then
            --setElementPosition(renderer.private.sky.cloud.object, cameraX, cameraY, math.max(cameraZ + renderer.private.sky.cloud.height, renderer.private.sky.cloud.height))
            --setElementPosition(CBuffer.sun.object, cameraX, cameraY, cameraZ)
            --dxSetShaderValue(CBuffer.sun.shader, "entityPosition", sunX, sunY, sunZ)
            --dxDrawLine3D(cameraLookX, cameraLookY, cameraLookZ, sunX, sunY, sunZ, tocolor(255, 255, 0, 255), 4, true)
            --for i, j in pairs(CBuffer.emissive.rt) do
              --  dxSetRenderTarget(j, true)
            --end
            --dxSetRenderTarget()
            --[[
            if renderer.public.isTimeSynced then
                local currentTick = interface.tick
                if not renderer.private.serverTimeCycleTick or ((currentTick - renderer.private.serverTimeCycleTick) >= renderer.private.minuteDuration*30) then
                    renderer.private.serverTimeCycleTick = currentTick
                    renderer.private.serverNativeSkyColor, renderer.private.serverNativeTimePercent = renderer.private.serverNativeSkyColor or {}, renderer.private.serverNativeTimePercent or {}
                    local r, g, b = imports.dxGetPixelColor(imports.dxGetTexturePixels(renderer.private.sky.depth.rt, renderer.public.resolution[1]*0.5, renderer.public.resolution[2]*0.5, 1, 1), 0, 0)
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
            ]]
            local _, _, _, _, _, cameraLookZ = imports.getCameraMatrix()
            local sunX, sunY = imports.getScreenFromWorldPosition(0, 0, cameraLookZ + 200, 1, true)
            local isSunInView = (sunX and sunY and true) or false
            --if (renderer.private.isSunInView and not isSunInView) or isSunInView then shader.preLoaded["Assetify_Tex_Sky"]:setValue("vSunViewOffset", {(isSunInView and sunX) or -renderer.public.resolution[1], (isSunInView and sunY) or -renderer.public.resolution[2]}) end
            renderer.private.isSunInView = isSunInView
        end
        return true
    end

    renderer.private.prerender = function()
        if renderer.public.sky.state then
            --local dayPercent, dayTransitionPercent = renderer.private.sky.cloud.getDayPercent()
            local cameraX, cameraY, cameraZ, cameraLookX, cameraLookY, cameraLookZ = getCameraMatrix()
            local depthX, depthY, depthZ = cameraLookX, cameraLookY, cameraLookZ
            local depthScreenX, depthScreenY = getScreenFromWorldPosition(depthX, depthY, depthZ, renderer.public.resolution[1])
            if depthScreenX and depthScreenY then depthX, depthY, depthZ = getWorldFromScreenPosition(depthScreenX, depthScreenY, renderer.private.sky.depth.value)
            else depthX, depthY, depthZ = cameraX, cameraY, cameraZ - 10000 end
            --local sunX, sunY, sunZ = CBuffer.sun.getPosition(cameraLookX, cameraLookY, cameraLookZ, dayPercent, dayTransitionPercent)
            --local sunScreenX, sunScreenY = getScreenFromWorldPosition(sunX, sunY, sunZ, renderer.public.resolution[1])
            --if sunScreenX and sunScreenY then sunX, sunY, sunZ = getWorldFromScreenPosition(sunScreenX, sunScreenY, renderer.private.sky.depth.value)
            --else sunX, sunY, sunZ = cameraX, cameraY, cameraZ - 10000 end
            setElementPosition(renderer.private.sky.depth.object, cameraX, cameraY, cameraZ)
            dxSetShaderValue(renderer.private.sky.depth.shader.cShader, "position", depthX, depthY, depthZ)
            dxSetRenderTarget(renderer.private.sky.depth.rt, true)
            dxSetRenderTarget()
            setElementPosition(renderer.private.sky.cloud.object, cameraX, cameraY, math.max(cameraZ + renderer.private.sky.cloud.height, renderer.private.sky.cloud.height))
            --setElementPosition(CBuffer.sun.object, cameraX, cameraY, cameraZ)
            --dxSetShaderValue(CBuffer.sun.shader, "entityPosition", sunX, sunY, sunZ)
            --dxDrawLine3D(cameraLookX, cameraLookY, cameraLookZ, sunX, sunY, sunZ, tocolor(255, 255, 0, 255), 4, true)
        end
        return true
    end

    function renderer.public:syncShader(syncShader)
        if not syncShader then return false end
        local isTexSampler = syncShader.shaderData.shaderName == "Assetify_Tex_Sky"
        if isTexSampler then shader.preLoaded["Assetify_Tex_Sky"] = syncShader end
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
            if renderer.public.state == state then return false end
            renderer.public.state = state
            if renderer.public.state then
                renderer.public.vsource = imports.dxCreateScreenSource(renderer.public.resolution[1], renderer.public.resolution[2])
                renderer.public.vrt = renderer.public.vrt or {}
                if rtModes and rtModes.diffuse then
                    renderer.public.vrt.diffuse = imports.dxCreateRenderTarget(renderer.public.resolution[1], renderer.public.resolution[2], true)
                    if rtModes.emissive then
                        renderer.public.vrt.emissive = imports.dxCreateRenderTarget(renderer.public.resolution[1], renderer.public.resolution[2], false)
                    end
                end
                imports.addEventHandler("onClientHUDRender", root, renderer.private.render)
                imports.addEventHandler("onClientPreRender", root, renderer.private.prerender)
            else
                imports.removeEventHandler("onClientHUDRender", root, renderer.private.render)
                imports.addEventHandler("onClientPreRender", root, renderer.private.prerender)
                renderer.public:setEmissiveMode(false)
                imports.destroyElement(renderer.public.vsource)
                renderer.public.vsource = nil
                for i, j in imports.pairs(renderer.public.vrt) do
                    imports.destroyElement(j)
                    renderer.public.vrt[i] = nil
                end
            end
            for i, j in imports.pairs(shader.buffer.shader) do
                renderer.public:setVirtualRendering(_, _, i, syncer.librarySerial)
            end
        else
            if not manager:isInternal(isInternal) then return false end
            local vSource0, vSource1, vSource2 = (renderer.public.state and renderer.public.vsource) or false, (renderer.public.state and renderer.public.vrt.diffuse) or false, (renderer.public.state and renderer.public.vrt.emissive) or false
            syncShader:setValue("vResolution", (renderer.public.state and renderer.public.resolution) or false)
            syncShader:setValue("vRenderingEnabled", (renderer.public.state and true) or false)
            syncShader:setValue("vSource0", vSource0)
            syncShader:setValue("vSource1", vSource1)
            syncShader:setValue("vSource1Enabled", (vSource1 and true) or false)
        end
        return true
    end

    function renderer.public:setTimeSync(state, syncShader, isInternal)
        if not syncShader then
            state = (state and true) or false
            if renderer.public.isTimeSynced == state then return false end
            renderer.public.isTimeSynced = state
            if not renderer.public.isTimeSynced then
                renderer.public:setServerTick((renderer.private.serverTick or 0) + (interface.tick - (renderer.private.serverTickFrame or 0)))
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
            renderer.private.serverTickFrame = interface.tick
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

    --[[
    function renderer.public:setEmissiveMode(state)
        state = (state and true) or false
        if not renderer.public.state or not renderer.public.vrt.emissive then return false end
        if renderer.public.isEmissiveModeEnabled == state then return false end
        renderer.public.isEmissiveModeEnabled = state
        if state then
            local intermediateRT = imports.dxCreateRenderTarget(renderer.public.resolution[1], renderer.public.resolution[2], true)
            local resultRT = imports.dxCreateRenderTarget(renderer.public.resolution[1], renderer.public.resolution[2], true)
            renderer.private.emissiveBuffer = {
                rt = resultRT,
                shader = shader:create(_, "Assetify ━ PreLoaded", "Assetify_Tex_Bloomer", _, {["vEmissive0"] = 1, ["vEmissive1"] = 2}, {}, {texture = {[1] = intermediateRT, [2] = resultRT}}, _, shader.shaderPriority + 1, _, true)
            }
        else
            renderer.private.emissiveBuffer.shader:destroy()
            renderer.private.emissiveBuffer = nil
        end
        return true
    end
    ]]
    
    function renderer.public:setDynamicSky(state, syncShader, isInternal)
        if not syncShader then
            state = (state and true) or false
            if renderer.public.sky.state == state then return false end
            renderer.public.sky.state = state
            if state then
                renderer.private.prevNativeSkyGradient = table.pack(imports.getSkyGradient())
                renderer.private.prevNativeClouds = imports.getCloudsEnabled()
                renderer.private.sky.depth.object = createObject(asset.rw.plane.modelID, 0, 0, 0, 0, 0, 0, true)
                setElementCollisionsEnabled(renderer.private.sky.depth.object, false)
                setElementStreamable(renderer.private.sky.depth.object, false)
                setElementDoubleSided(renderer.private.sky.depth.object, true)
                renderer.private.sky.depth.rt = imports.dxCreateRenderTarget(renderer.public.resolution[1], renderer.public.resolution[2], false)
                renderer.private.sky.depth.shader = shader:create(renderer.private.sky.depth.object, "Assetify:Sky", "Assetify_Sky_Tex_Depth", "*", {}, {
                    ["vDepth0"] = renderer.private.sky.depth.rt
                }, {}, false, shader.shaderPriority + 1, false, false, syncer.librarySerial)
                renderer.private.sky.cloud.object = createObject(asset.rw.sky.modelID, 0, 0, 0, 0, 0, 0, true)
                renderer.private.sky.cloud.shader = shader:create(renderer.private.sky.cloud.object, "Assetify:Sky", "Assetify_Sky_Tex_Cloud", "*", {}, {
                    ["vResolution"] = renderer.public.resolution,
                    ["cloudTex"] = renderer.private.sky.cloud.texture
                }, {}, false, shader.shaderPriority + 1, false, false, true, syncer.librarySerial)
                setObjectScale(renderer.private.sky.cloud.object, 30)
                setElementCollisionsEnabled(renderer.private.sky.cloud.object, false)
                setElementStreamable(renderer.private.sky.cloud.object, false)
                setElementDoubleSided(renderer.private.sky.cloud.object, true)
            else
                imports.destroyElement(renderer.private.sky.depth.object)
                imports.destroyElement(renderer.private.sky.depth.rt)
                renderer.private.sky.depth.shader:destroy(true, syncer.librarySerial)
                imports.destroyElement(renderer.private.sky.cloud.object)
                imports.destroyElement(renderer.private.sky.cloud.rt)
                renderer.private.sky.cloud.shader:destroy(true, syncer.librarySerial)
                imports.setSkyGradient(table.unpack(renderer.private.prevNativeSkyGradient))
            end
            --for i, j in imports.pairs(shader.buffer.shader) do
                --renderer.public:setDynamicSky(_, i, syncer.librarySerial)
            --end
        else
            if not manager:isInternal(isInternal) then return false end
            syncShader:setValue("vDynamicSkyEnabled", renderer.public.sky.state or false)
            if shader.preLoaded["Assetify_Tex_Sky"] and (shader.preLoaded["Assetify_Tex_Sky"] == syncShader) then
                shader.preLoaded["Assetify_Tex_Sky"]:setValue("vSky0", renderer.private.sky.depth.rt)
                if not shader.preLoaded["Assetify_Tex_Sky"].isTexSamplerLoaded then
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
        if shader.preLoaded["Assetify_Tex_Sky"] then shader.preLoaded["Assetify_Tex_Sky"]:setValue("sunColor", renderer.public.isDynamicSunColor) end
        return true
    end

    function renderer.public:setDynamicStars(state, isInternal)
        if isInternal and not manager:isInternal(isInternal) then return false end
        if not isInternal then
            state = (state and true) or false
            if renderer.public.isDynamicStarsEnabled == state then return false end
            renderer.public.isDynamicStarsEnabled = state
        end
        if shader.preLoaded["Assetify_Tex_Sky"] then shader.preLoaded["Assetify_Tex_Sky"]:setValue("isStarsEnabled", renderer.public.isDynamicStarsEnabled) end
        return true
    end

    function renderer.public:setDynamicCloudDensity(density, isInternal)
        if isInternal and not manager:isInternal(isInternal) then return false end
        if not isInternal then
            density = imports.tonumber(density) or 0
            if renderer.public.isDynamicCloudDensity == density then return false end
            renderer.public.isDynamicCloudDensity = density
        end
        if shader.preLoaded["Assetify_Tex_Sky"] then shader.preLoaded["Assetify_Tex_Sky"]:setValue("cloudDensity", renderer.public.isDynamicCloudDensity) end
        return true
    end

    function renderer.public:setDynamicCloudScale(scale, isInternal)
        if isInternal and not manager:isInternal(isInternal) then return false end
        if not isInternal then
            density = imports.tonumber(scale) or 0
            if renderer.public.isDynamicCloudScale == scale then return false end
            renderer.public.isDynamicCloudScale = scale
        end
        if shader.preLoaded["Assetify_Tex_Sky"] then shader.preLoaded["Assetify_Tex_Sky"]:setValue("cloudScale", renderer.public.isDynamicCloudScale) end
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
        if shader.preLoaded["Assetify_Tex_Sky"] then shader.preLoaded["Assetify_Tex_Sky"]:setValue("cloudColor", renderer.public.isDynamicCloudColor) end
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
            if shader.preLoaded["Assetify_Tex_Sky"] then shader.preLoaded["Assetify_Tex_Sky"]:setValue("timecycle_"..i, bCycle) end
        end
        return true
    end
end