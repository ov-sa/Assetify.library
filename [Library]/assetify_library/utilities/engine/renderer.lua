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
    setMoonSize = setMoonSize,
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
        state = false,
        cloud = {},
        star = {},
        moon = {
            emissive = {}
        },
        sun = {
            emissive = {}
        }
    }
})

if localPlayer then
    renderer.public.camera = imports.getCamera()
    renderer.public.resolution = {imports.guiGetScreenSize()}
    renderer.public.resolution[1], renderer.public.resolution[2] = renderer.public.resolution[1], renderer.public.resolution[2]
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
        if renderer.public.timecycle then
            local hours, minutes = imports.getTime()
            local current = renderer.public.timecycle[hours]
            local next = renderer.public.timecycle[((hours < 23) and (hours + 1)) or 0]
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
    addEventHandler("onClientResourceStart", resourceRoot, function() renderer.public:setRendering(settings.renderer.state) end)

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
                shader = shader:create(false, "Assetify:PreLoad", "Assetify_Tex_Bloomer", false, {["vEmissive0"] = 1, ["vEmissive1"] = 2}, {}, {texture = {[1] = intermediateRT, [2] = resultRT}}, false, shader.priority + 1, false, true)
            }
        else
            renderer.private.emissiveBuffer.shader:destroy()
            renderer.private.emissiveBuffer = nil
        end
        return true
    end
    ]]

    function renderer.public:setTimeCycle(timecycle)
        renderer.public.timecycle = timecycle or nil
        for i = 0, 23, 1 do
            renderer.public.timecycle[i] = renderer.public.timecycle[i] or {}
            for k = 1, 2, 1 do
                renderer.public.timecycle[i][k] = {stringn.parseHex(renderer.public.timecycle[i][k] or "#ffffff")}
            end
        end
        return true
    end
    if settings.renderer.timecycle.state then
        renderer.public:setTimeCycle(table.unpack(table.pack(table.decode(file:read(settings.renderer.timecycle.source))), 1))
    end

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
                }, {}, false, shader.priority + 1, false, false, syncer.librarySerial)
                renderer.private.sky.cloud.rt = imports.dxCreateRenderTarget(renderer.public.resolution[1], renderer.public.resolution[2], false)
                renderer.private.sky.rt[renderer.private.sky.cloud.rt] = true
                renderer.private.sky.cloud.object = createObject(asset.rw.sky.modelID, 0, 0, 0, 0, 0, 0, true)
                renderer.private.sky.cloud.shader = shader:create(renderer.private.sky.cloud.object, "Assetify:Sky", "Assetify_Sky_Tex_Cloud", "*", {}, {
                    ["vResolution"] = renderer.public.resolution,
                    ["cloudTex"] = renderer.private.sky.cloud.texture,
                    ["vCloud0"] = renderer.private.sky.cloud.rt
                }, {}, false, shader.priority + 1, false, false, true, syncer.librarySerial)
                setObjectScale(renderer.private.sky.cloud.object, 30)
                setElementCollisionsEnabled(renderer.private.sky.cloud.object, false)
                setElementStreamable(renderer.private.sky.cloud.object, false)
                setElementDoubleSided(renderer.private.sky.cloud.object, true)
                renderer.private.sky.moon.rt = imports.dxCreateRenderTarget(renderer.public.resolution[1], renderer.public.resolution[2], false)
                renderer.private.sky.rt[renderer.private.sky.moon.rt] = true
                renderer.private.sky.moon.shader = shader:create(false, "Assetify:Sky", "Assetify_Sky_Tex_Moon", "coronamoon", {}, {
                    ["vMoon0"] = renderer.private.sky.moon.rt
                }, {}, false, shader.priority + 1, false, false, false, syncer.librarySerial)
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
            if not manager:isInternal(isInternal) or (sync.data.category == "Assetify:Sky") then return false end
            sync:setValue("vSkyEnabled", renderer.public.sky.state or false)
            renderer.public:setDynamicCloudSpeed(false, syncer.librarySerial)
            renderer.public:setDynamicCloudScale(false, syncer.librarySerial)
            renderer.public:setDynamicCloudDirection(false, syncer.librarySerial)
            renderer.public:setDynamicCloudColor(false, syncer.librarySerial)
            renderer.public:setDynamicStarSpeed(false, syncer.librarySerial)
            renderer.public:setDynamicStarScale(false, syncer.librarySerial)
            renderer.public:setDynamicStarIntensity(false, syncer.librarySerial)
            renderer.public:setDynamicMoonScale(false, syncer.librarySerial)
            renderer.public:setDynamicMoonBrightness(false, syncer.librarySerial)
            renderer.public:setDynamicMoonEmissiveScale(false, syncer.librarySerial)
            renderer.public:setDynamicMoonEmissiveIntensity(false, syncer.librarySerial)
        end
        return true
    end
    addEventHandler("onClientResourceStart", resourceRoot, function() renderer.public:setDynamicSky(settings.renderer.sky.state) end)

    function renderer.public:setDynamicCloudSpeed(speed, isInternal)
        if isInternal and not manager:isInternal(isInternal) then return false end
        if not isInternal then
            speed = imports.tonumber(speed) or settings.renderer.sky.cloud.speed or 0
            if renderer.public.sky.cloud.speed == speed then return false end
            renderer.public.sky.cloud.speed = speed
        end
        if renderer.public.sky.state then
            renderer.private.sky.cloud.shader:setValue("cloudSpeed", renderer.public.sky.cloud.speed)
        end
        return true
    end
    renderer.public:setDynamicCloudSpeed(settings.renderer.sky.cloud.speed)

    function renderer.public:setDynamicCloudScale(scale, isInternal)
        if isInternal and not manager:isInternal(isInternal) then return false end
        if not isInternal then
            scale = imports.tonumber(scale) or settings.renderer.sky.cloud.scale or 0
            if renderer.public.sky.cloud.scale == scale then return false end
            renderer.public.sky.cloud.scale = scale
        end
        if renderer.public.sky.state then
            renderer.private.sky.cloud.shader:setValue("cloudScale", renderer.public.sky.cloud.scale)
        end
        return true
    end
    renderer.public:setDynamicCloudScale(settings.renderer.sky.cloud.scale)

    function renderer.public:setDynamicCloudDirection(direction, isInternal)
        if isInternal and not manager:isInternal(isInternal) then return false end
        if not isInternal then
            direction = (direction and (imports.type(direction) ~= "table") and direction) or settings.renderer.sky.cloud.direction or {1, 1}
            if table.encode(renderer.public.sky.cloud.direction) == table.encode(direction) then return false end
            renderer.public.sky.cloud.direction = direction
        end
        if renderer.public.sky.state then
            renderer.private.sky.cloud.shader:setValue("cloudDirection", renderer.public.sky.cloud.direction)
        end
        return true
    end
    renderer.public:setDynamicCloudDirection(settings.renderer.sky.cloud.direction)

    function renderer.public:setDynamicCloudColor(color, isInternal)
        if isInternal and not manager:isInternal(isInternal) then return false end
        if not isInternal then
            color = (color and (imports.type(color) ~= "table") and color) or settings.renderer.sky.cloud.color or {255, 255, 255, 255}
            if table.encode(renderer.public.sky.cloud.color) == table.encode(color) then return false end
            renderer.public.sky.cloud.color = color
        end
        if renderer.public.sky.state then
            renderer.private.sky.cloud.shader:setValue("cloudColor", {renderer.public.sky.cloud.color[1]/255, renderer.public.sky.cloud.color[2]/255, renderer.public.sky.cloud.color[3]/255, renderer.public.sky.cloud.color[4]/255})
        end
        return true
    end
    renderer.public:setDynamicCloudColor(settings.renderer.sky.cloud.color)

    function renderer.public:setDynamicStarSpeed(speed, isInternal)
        if isInternal and not manager:isInternal(isInternal) then return false end
        if not isInternal then
            speed = imports.tonumber(speed) or settings.renderer.sky.star.speed or 0
            if renderer.public.sky.star.speed == speed then return false end
            renderer.public.sky.star.speed = speed
        end
        if renderer.public.sky.state then
            renderer.private.sky.cloud.shader:setValue("starSpeed", renderer.public.sky.star.speed)
        end
        return true
    end
    renderer.public:setDynamicStarSpeed(settings.renderer.sky.star.speed)

    function renderer.public:setDynamicStarScale(scale, isInternal)
        if isInternal and not manager:isInternal(isInternal) then return false end
        if not isInternal then
            scale = imports.tonumber(scale) or settings.renderer.sky.star.scale or 0
            if renderer.public.sky.star.scale == scale then return false end
            renderer.public.sky.star.scale = scale
        end
        if renderer.public.sky.state then
            renderer.private.sky.cloud.shader:setValue("starScale", renderer.public.sky.star.scale)
        end
        return true
    end
    renderer.public:setDynamicStarScale(settings.renderer.sky.star.scale)

    function renderer.public:setDynamicStarIntensity(intensity, isInternal)
        if isInternal and not manager:isInternal(isInternal) then return false end
        if not isInternal then
            intensity = imports.tonumber(intensity) or settings.renderer.sky.star.intensity or 0
            if renderer.public.sky.star.intensity == intensity then return false end
            renderer.public.sky.star.intensity = intensity
        end
        if renderer.public.sky.state then
            renderer.private.sky.cloud.shader:setValue("starIntensity", renderer.public.sky.star.intensity)
        end
        return true
    end
    renderer.public:setDynamicStarIntensity(settings.renderer.sky.star.intensity)

    function renderer.public:setDynamicMoonScale(scale, isInternal)
        if isInternal and not manager:isInternal(isInternal) then return false end
        if not isInternal then
            scale = imports.tonumber(scale) or settings.renderer.sky.moon.scale or 0
            if renderer.public.sky.moon.scale == scale then return false end
            renderer.public.sky.moon.scale = scale
        end
        if renderer.public.sky.state then
            renderer.private.sky.moon.shader:setValue("moonScale", renderer.public.sky.moon.scale)
        end
        return true
    end
    renderer.public:setDynamicMoonScale(settings.renderer.sky.moon.scale)

    function renderer.public:setDynamicMoonBrightness(brightness, isInternal)
        if isInternal and not manager:isInternal(isInternal) then return false end
        if not isInternal then
            brightness = imports.tonumber(brightness) or settings.renderer.sky.moon.brightness or 0
            if renderer.public.sky.moon.brightness == brightness then return false end
            renderer.public.sky.moon.brightness = brightness
        end
        if renderer.public.sky.state then
            renderer.private.sky.moon.shader:setValue("moonBrightness", renderer.public.sky.moon.brightness)
        end
        return true
    end
    renderer.public:setDynamicMoonBrightness(settings.renderer.sky.moon.brightness)

    function renderer.public:setDynamicMoonEmissiveScale(scale, isInternal)
        if isInternal and not manager:isInternal(isInternal) then return false end
        if not isInternal then
            scale = imports.tonumber(scale) or settings.renderer.sky.moon.emissive.scale or 1
            if renderer.public.sky.moon.emissive.scale == scale then return false end
            renderer.public.sky.moon.emissive.scale = scale
        end
        if renderer.public.sky.state then
            imports.setMoonSize(renderer.public.sky.moon.emissive.scale*10)
        end
        return true
    end
    renderer.public:setDynamicMoonEmissiveScale(settings.renderer.sky.moon.emissive.scale)

    function renderer.public:setDynamicMoonEmissiveIntensity(intensity, isInternal)
        if isInternal and not manager:isInternal(isInternal) then return false end
        if not isInternal then
            intensity = imports.tonumber(intensity) or settings.renderer.sky.moon.emissive.intensity or 1
            if renderer.public.sky.moon.emissive.intensity == intensity then return false end
            renderer.public.sky.moon.emissive.intensity = intensity
        end
        if renderer.public.sky.state then
            --TODO: To be connected w emissive shader later
            --renderer.private.sky.emissive.shader:setValue("moonEmissiveIntensity", renderer.public.sky.moon.emissive.intensity)
        end
        return true
    end
    renderer.public:setDynamicMoonEmissiveIntensity(settings.renderer.sky.moon.emissive.intensity)
end