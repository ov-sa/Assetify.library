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
    setTime = setTime,
    getTime = getTime,
    getCamera = getCamera,
    getMoonSize = getMoonSize,
    getRealTime = getRealTime,
    destroyElement = destroyElement,
    guiGetScreenSize = guiGetScreenSize,
    setSkyGradient = setSkyGradient,
    getSkyGradient = getSkyGradient,
    setFarClipDistance = setFarClipDistance,
    getFarClipDistance = getFarClipDistance,
    getCameraMatrix = getCameraMatrix,
    setElementPosition = setElementPosition,
    getScreenFromWorldPosition = getScreenFromWorldPosition,
    getWorldFromScreenPosition = getWorldFromScreenPosition,
    addEventHandler = addEventHandler,
    removeEventHandler = removeEventHandler,
    dxCreateTexture = dxCreateTexture,
    dxCreateScreenSource = dxCreateScreenSource,
    dxCreateRenderTarget = dxCreateRenderTarget,
    dxUpdateScreenSource = dxUpdateScreenSource,
    dxSetRenderTarget = dxSetRenderTarget,
    dxDrawImage = dxDrawImage
}


-------------------------
--[[ Class: Renderer ]]--
-------------------------

local renderer = class:create("renderer", {
    state = false,
    sky = {
        state = false
    }
})

if localPlayer then
    renderer.public.camera = imports.getCamera()
    renderer.public.resolution = {imports.guiGetScreenSize()}
    renderer.public.resolution[1], renderer.public.resolution[2] = renderer.public.resolution[1]*settings.renderer.resolution, renderer.public.resolution[2]*settings.renderer.resolution
    renderer.private.sky = {
        farclip = 1000,
        depth = {
            value = 300
        },
        cloud = {
            height = 300,
            texture = imports.dxCreateTexture("utilities/rw/mesh_sky/textures/cloud.rw", "dxt5")
        },
        moon = {
            texture = {}
        }
    }    
    for i = 0, 20, 1 do
        renderer.private.sky.moon.texture[i] = imports.dxCreateTexture("utilities/rw/mesh_sky/textures/moon/"..i..".rw", "dxt1")
    end

    renderer.private.getMoonPhase = function()
        local time = imports.getRealTime()
        local year = time.year + 1900
        local month = time.month + 1
        local day = time.monthday
        local hour = time.hour
        local minute = time.minute
        local second = time.second
        local phase = 0
        if month < 3 then
            year = year - 1
            month = month + 12
        end
        local k = math.floor(365.25*(year + 4716)) + math.floor(30.6*(month + 1)) + day - 152.25
        phase = 67*k/4000
        phase = phase - math.floor(phase)
        return math.floor(phase*table.length(renderer.private.sky.moon.texture))
    end

    renderer.private.getTime = function()
        local hours, minutes = imports.getTime()
        local time = {
            day = {
                percent = 0,
                transition = 0
            },
            night = {
                percent = 0,
                transition = 0,
                moon = 0
            }
        }
        local totalMinutes = hours*60 + minutes
        if (totalMinutes >= 5*60) and (totalMinutes <= 22*60) then
            time.day.percent = (totalMinutes - (5*60))/((22 -  5)*60)
            time.day.transition = ((time.day.percent <= 0.5) and (time.day.percent*2)) or (1 - (time.day.percent - 0.5)*2)
        end
        if hours <= 5 then
            hours = hours + 24
            totalMinutes = hours*60 + minutes
        end
        if (totalMinutes >= 22*60) and (totalMinutes <= (24 + 5)*60) then
            time.night.percent = (totalMinutes - (22*60))/((24 + 5 - 22)*60)
            time.night.transition = ((time.night.percent <= 0.5) and (time.night.percent*2)) or (1 - (time.night.percent - 0.5)*2)
        end
        if (totalMinutes >= 24*60) and (totalMinutes <= (24 + 5)*60) then
            time.night.moon = (totalMinutes - (24*60))/((24 + 5 - 24)*60)
            time.night.moon = ((time.night.moon <= 0.5) and (time.night.moon*2)) or (1 - (time.night.moon - 0.5)*2)
        end
        return time
    end

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
        return true
    end

    renderer.private.prerender = function()
        if renderer.public.isDynamicTimeCycle then
            local hours, minutes = imports.getTime()
            local current = renderer.public.isDynamicTimeCycle[hours]
            local next = renderer.public.isDynamicTimeCycle[((hours < 23) and (hours + 1)) or 0]
            local percent = minutes/60
            renderer.public.timecyclegrad = renderer.public.timecyclegrad or {}
            renderer.public.timecyclegrad[1], renderer.public.timecyclegrad[2], renderer.public.timecyclegrad[3] = interpolateBetween(current[1][1], current[1][2], current[1][3], next[1][1], next[1][2], next[1][3], percent, "InQuad")
            renderer.public.timecyclegrad[4], renderer.public.timecyclegrad[5], renderer.public.timecyclegrad[6] = interpolateBetween(current[2][1], current[2][2], current[2][3], next[2][1], next[2][2], next[2][3], percent, "InQuad")
            imports.setSkyGradient(renderer.public.timecyclegrad[1], renderer.public.timecyclegrad[2], renderer.public.timecyclegrad[3], renderer.public.timecyclegrad[4], renderer.public.timecyclegrad[5], renderer.public.timecyclegrad[6])
        end
        if renderer.public.sky.state then
            local time = renderer.private.getTime()
            local farclip = imports.getFarClipDistance()
            local cameraX, cameraY, cameraZ, cameraLookX, cameraLookY, cameraLookZ = imports.getCameraMatrix()
            local depthX, depthY, depthZ = cameraLookX, cameraLookY, cameraLookZ
            local depthScreenX, depthScreenY = imports.getScreenFromWorldPosition(depthX, depthY, depthZ, renderer.public.resolution[1])
            local skyGradient = {imports.getSkyGradient()}
            if depthScreenX and depthScreenY then depthX, depthY, depthZ = imports.getWorldFromScreenPosition(depthScreenX, depthScreenY, renderer.private.sky.depth.value)
            else depthX, depthY, depthZ = cameraX, cameraY, cameraZ - 10000 end
            --local sunX, sunY, sunZ = CBuffer.sun.getPosition(cameraLookX, cameraLookY, cameraLookZ, time.day.percent, time.day.transition)
            --local sunScreenX, sunScreenY = getScreenFromWorldPosition(sunX, sunY, sunZ, renderer.public.resolution[1])
            --if sunScreenX and sunScreenY then sunX, sunY, sunZ = getWorldFromScreenPosition(sunScreenX, sunScreenY, renderer.private.sky.depth.value)
            --else sunX, sunY, sunZ = cameraX, cameraY, cameraZ - 10000 end
            imports.setFarClipDistance(math.max(farclip, renderer.private.sky.farclip))
            imports.setElementPosition(renderer.private.sky.depth.object, cameraX, cameraY, cameraZ)
            renderer.private.sky.depth.shader:setValue("depthLocation", depthX, depthY, depthZ)
            imports.setElementPosition(renderer.private.sky.cloud.object, cameraX, cameraY, math.max(cameraZ + renderer.private.sky.cloud.height, renderer.private.sky.cloud.height))
            renderer.private.sky.cloud.shader:setValue("skyColor", {skyGradient[1]/255, skyGradient[2]/255, skyGradient[3]/255, skyGradient[4]/255, skyGradient[5]/255, skyGradient[6]/255})
            renderer.private.sky.cloud.shader:setValue("starsVisibility", time.night.transition)
            renderer.private.sky.moon.shader:setValue("moonTex", renderer.private.sky.moon.texture[renderer.private.getMoonPhase()])
            renderer.private.sky.moon.shader:setValue("moonNativeScale", imports.getMoonSize())
            renderer.private.sky.moon.shader:setValue("moonVisibility", time.night.moon)
            --imports.setElementPosition(CBuffer.sun.object, cameraX, cameraY, cameraZ)
            --dxSetShaderValue(CBuffer.sun.shader, "entityPosition", sunX, sunY, sunZ)
            --dxDrawLine3D(cameraLookX, cameraLookY, cameraLookZ, sunX, sunY, sunZ, tocolor(255, 255, 0, 255), 4, true)
            for i, j in imports.pairs(renderer.private.sky.rt) do
                imports.dxSetRenderTarget(i, true)
                imports.dxSetRenderTarget()
            end
        end
        return true
    end

    function renderer.public:sync(sync)
        if not sync then return false end
        renderer.public:setRendering(false, false, sync, syncer.librarySerial)
        renderer.public:setDynamicSky(false, sync, syncer.librarySerial)
        return true
    end

    function renderer.public:setRendering(state, modes, sync, isInternal)
        if not sync then
            state = (state and true) or false
            modes = (modes and (imports.type(modes) == "table") and modes) or false
            if renderer.public.state == state then return false end
            renderer.public.state = state
            if renderer.public.state then
                renderer.public.vsource = imports.dxCreateScreenSource(renderer.public.resolution[1], renderer.public.resolution[2])
                renderer.public.vrt = renderer.public.vrt or {}
                if modes and modes.diffuse then
                    renderer.public.vrt.diffuse = imports.dxCreateRenderTarget(renderer.public.resolution[1], renderer.public.resolution[2], true)
                    if modes.emissive then
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
                renderer.public:setRendering(false, false, i, syncer.librarySerial)
            end
        else
            if not manager:isInternal(isInternal) then return false end
            local vSource0, vSource1, vSource2 = (renderer.public.state and renderer.public.vsource) or false, (renderer.public.state and renderer.public.vrt.diffuse) or false, (renderer.public.state and renderer.public.vrt.emissive) or false
            sync:setValue("vResolution", (renderer.public.state and renderer.public.resolution) or false)
            sync:setValue("vRenderingEnabled", (renderer.public.state and true) or false)
            sync:setValue("vSource0", vSource0)
            sync:setValue("vSource1", vSource1)
            sync:setValue("vSource1Enabled", (vSource1 and true) or false)
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
                shader = shader:create(false, "Assetify ━ PreLoaded", "Assetify_Tex_Bloomer", false, {["vEmissive0"] = 1, ["vEmissive1"] = 2}, {}, {texture = {[1] = intermediateRT, [2] = resultRT}}, false, shader.shaderPriority + 1, false, true)
            }
        else
            renderer.private.emissiveBuffer.shader:destroy()
            renderer.private.emissiveBuffer = nil
        end
        return true
    end
    ]]

    function renderer.public:setDynamicSky(state, sync, isInternal)
        if not sync then
            state = (state and true) or false
            if renderer.public.sky.state == state then return false end
            renderer.public.sky.state = state
            if state then
                renderer.private.sky.rt = {}
                renderer.private.sky.depth.object = createObject(asset.rw.plane.modelID, 0, 0, 0, 0, 0, 0, true)
                setElementCollisionsEnabled(renderer.private.sky.depth.object, false)
                setElementStreamable(renderer.private.sky.depth.object, false)
                setElementDoubleSided(renderer.private.sky.depth.object, true)
                renderer.private.sky.depth.rt = imports.dxCreateRenderTarget(renderer.public.resolution[1], renderer.public.resolution[2], false)
                renderer.private.sky.rt[renderer.private.sky.depth.rt] = true
                renderer.private.sky.depth.shader = shader:create(renderer.private.sky.depth.object, "Assetify:Sky", "Assetify_Sky_Tex_Depth", "*", {}, {
                    ["vDepth0"] = renderer.private.sky.depth.rt
                }, {}, false, shader.shaderPriority + 1, false, false, syncer.librarySerial)
                renderer.private.sky.cloud.rt = imports.dxCreateRenderTarget(renderer.public.resolution[1], renderer.public.resolution[2], false)
                renderer.private.sky.rt[renderer.private.sky.cloud.rt] = true
                renderer.private.sky.cloud.object = createObject(asset.rw.sky.modelID, 0, 0, 0, 0, 0, 0, true)
                renderer.private.sky.cloud.shader = shader:create(renderer.private.sky.cloud.object, "Assetify:Sky", "Assetify_Sky_Tex_Cloud", "*", {}, {
                    ["vResolution"] = renderer.public.resolution,
                    ["cloudTex"] = renderer.private.sky.cloud.texture,
                    ["vCloud0"] = renderer.private.sky.cloud.rt
                }, {}, false, shader.shaderPriority + 1, false, false, true, syncer.librarySerial)
                setObjectScale(renderer.private.sky.cloud.object, 30)
                setElementCollisionsEnabled(renderer.private.sky.cloud.object, false)
                setElementStreamable(renderer.private.sky.cloud.object, false)
                setElementDoubleSided(renderer.private.sky.cloud.object, true)
                renderer.private.sky.moon.shader = shader:create(false, "Assetify:Sky", "Assetify_Sky_Tex_Moon", "coronamoon", {}, {}, {}, false, shader.shaderPriority + 1, false, false, false, syncer.librarySerial)
            else
                imports.destroyElement(renderer.private.sky.depth.object)
                renderer.private.sky.depth.shader:destroy(true, syncer.librarySerial)
                imports.destroyElement(renderer.private.sky.cloud.object)
                renderer.private.sky.cloud.shader:destroy(true, syncer.librarySerial)
                renderer.private.sky.moon.shader:destroy(true, syncer.librarySerial)
                for i, j in imports.pairs(renderer.private.sky.rt) do
                    imports.destroyElement(i)
                end
                renderer.private.sky.rt = nil
            end
            for i, j in imports.pairs(shader.buffer.shader) do
                renderer.public:setDynamicSky(false, i, syncer.librarySerial)
            end
        else
            if not manager:isInternal(isInternal) then return false end
            sync:setValue("vSkyEnabled", renderer.public.sky.state or false)
            renderer.public:setDynamicSunColor(false, false, false, syncer.librarySerial)
            renderer.public:setDynamicStars(false, syncer.librarySerial)
            renderer.public:setDynamicCloudDensity(false, syncer.librarySerial)
            renderer.public:setDynamicCloudScale(false, syncer.librarySerial)
            renderer.public:setDynamicCloudColor(false, false, false, syncer.librarySerial)
        end
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

    function renderer.public:setTimeCycle(cycle, isInternal)
        if isInternal and not manager:isInternal(isInternal) then return false end
        if not isInternal then
            renderer.public.isDynamicTimeCycle = cycle
        end
        for i = 0, 23, 1 do
            renderer.public.isDynamicTimeCycle[i] = renderer.public.isDynamicTimeCycle[i] or {}
            for k = 1, 2, 1 do
                renderer.public.isDynamicTimeCycle[i][k] = {string.parseHex(renderer.public.isDynamicTimeCycle[i][k] or "#ffffff")}
            end
        end
        return true
    end


    --[[
    function setCloudSpeed(speed)
        if not CBuffer.state then return false end
        dxSetShaderValue(CBuffer.cloud.shader, "cloudSpeed", tonumber(speed) or 1)
        return true
    end
    
    function setCloudScale(scale)
        if not CBuffer.state then return false end
        dxSetShaderValue(CBuffer.cloud.shader, "cloudScale", tonumber(scale) or 1)
        return true
    end
    
    function setCloudDirection(direction)
        if not CBuffer.state or not direction or (type(direction) ~= "table") then return false end
        dxSetShaderValue(CBuffer.cloud.shader, "cloudDirection", {tonumber(direction[1]) or 1, tonumber(direction[2]) or 1})
        return true
    end
    
    function setCloudColor(color)
        if not CBuffer.state or not color or (type(color) ~= "table") then return false end
        dxSetShaderValue(CBuffer.cloud.shader, "cloudColor", {(tonumber(color[1]) or 255)/255, (tonumber(color[2]) or 255)/255, (tonumber(color[3]) or 255)/255, (tonumber(color[4]) or 255)/255})
        return true
    end
    
    function setStarSpeed(speed)
        if not CBuffer.state then return false end
        dxSetShaderValue(CBuffer.cloud.shader, "starSpeed", {0, (tonumber(speed) or 1)*3})
        return true
    end
    
    function setStarScale(scale)
        if not CBuffer.state then return false end
        dxSetShaderValue(CBuffer.cloud.shader, "starScale", tonumber(scale) or 1)
        return true
    end
    
    function setStarIntensity(intensity)
        if not CBuffer.state then return false end
        dxSetShaderValue(CBuffer.cloud.shader, "starIntensity", (tonumber(intensity) or 1)*0.6)
        return true
    end
    
    function setMoonScale(scale)
        if not CBuffer.state then return false end
        dxSetShaderValue(CBuffer.moon.shader, "moonScale", (tonumber(scale) or 1)*0.5)
        return true
    end
    
    function setMoonEmissiveScale(scale)
        if not CBuffer.state then return false end
        setMoonSize((tonumber(scale) or 1)*10)
        return true
    end
    
    function setMoonEmissiveIntensity(intensity)
        if not CBuffer.state then return false end
        dxSetShaderValue(CBuffer.emissive.shader, "moonEmissiveIntensity", tonumber(intensity) or 1)
        return true
    end
    
    function setMoonBrightness(brightness)
        if not CBuffer.state then return false end
        dxSetShaderValue(CBuffer.moon.shader, "moonBrightness", (tonumber(brightness) or 1)*1.6)
        return true
    end
    
    function setSunScale(scale)
        if not CBuffer.state then return false end
        dxSetShaderValue(CBuffer.sun.shader, "sunScale", tonumber(scale) or 1)
        return true
    end
    
    function setSunEmissiveScale(scale)
        if not CBuffer.state then return false end
        dxSetShaderValue(CBuffer.sun.shader, "sunNativeScale", (tonumber(scale) or 1)*10000)
        return true
    end
    
    function setSunEmissiveIntensity(intensity)
        if not CBuffer.state then return false end
        dxSetShaderValue(CBuffer.emissive.shader, "sunEmissiveIntensity", tonumber(intensity) or 1)
        return true
    end
    ]]
end