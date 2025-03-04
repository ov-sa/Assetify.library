----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: engine: shader.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Shader Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    tonumber = tonumber,
    isElement = isElement,
    destroyElement = destroyElement,
    dxCreateShader = dxCreateShader,
    dxCreateTexture = dxCreateTexture,
    dxSetShaderValue = dxSetShaderValue,
    engineApplyShaderToWorldTexture = engineApplyShaderToWorldTexture,
    engineRemoveShaderFromWorldTexture = engineRemoveShaderFromWorldTexture
}


-----------------------
--[[ Class: Shader ]]--
-----------------------

local shader = class:create("shader", {
    shaderPriority = 10000,
    shaderDistance = 0,
    validTypes = {
        [asset.reference.clump] = true,
        [asset.reference.control] = true
    },
    validChannels = {
        {index = "red", channel = "r"},
        {index = "green", channel = "g"},
        {index = "blue", channel = "b"}
    },
    validLayers = {
        {index = "diffuse", alpha = true},
        {index = "emissive", alpha = false}
    },
    remoteWhitelist = {
        "Assetify_Tex_Clearer",
        "Assetify_Tex_Change",
        "Assetify_Tex_Export"
    }
})
shader.private.__remoteWhitelist = {}
for i = 1, table.length(shader.public.remoteWhitelist), 1 do
    local j = shader.public.remoteWhitelist[i]
    shader.private.__remoteWhitelist[j] = true
end
shader.public.remoteWhitelist = shader.private.__remoteWhitelist
shader.private.__remoteWhitelist = nil

if localPlayer then
    shader.public.preLoaded, shader.public.preLoadedTex = {}, {
        invisibleMap = imports.dxCreateTexture(2, 2, "dxt5", "clamp")
    }
    shader.public.buffer = {
        element = {},
        shader = {}
    }

    function shader.public:create(...)
        local cShader = self:createInstance()
        if cShader and not cShader:load(...) then
            cShader:destroyInstance()
            return false
        end
        return cShader
    end

    function shader.public:createTex(cAsset)
        if not cAsset or not cAsset.manifest.shaderMaps then return false end
        cAsset.unsynced.raw.map.shader, cAsset.unsynced.raw.map.texture = {}, {}
        for i, j in imports.pairs(asset:buildShader(cAsset.manifest.shaderMaps)) do
            if j then
                cAsset.unsynced.raw.map.texture[i] = shader.public:loadTex(cAsset, i)
            end
        end
        return true
    end

    function shader.public:destroy(...)
        if not shader.public:isInstance(self) then return false end
        return self:unload(...)
    end

    function shader.public.clearAssetBuffer(raw)
        if not raw then return false end
        if raw.shader then
            for i, j in imports.pairs(raw.shader) do
                imports.destroyElement(j)
                raw.shader[i] = nil
            end
        end
        if raw.texture then
            for i, j in imports.pairs(raw.texture) do
                imports.destroyElement(j)
                raw.texture[i] = nil
            end
        end
        return true
    end

    function shader.public:fetchInstance(element, shaderCategory, textureName)
        if element and shaderCategory and textureName then
            if shader.public.buffer.element[element] and shader.public.buffer.element[element][shaderCategory] and shader.public.buffer.element[element][shaderCategory].textured[textureName] then
                return shader.public.buffer.element[element][shaderCategory].textured[textureName]
            end
        end
        return false
    end

    function shader.public.clearElementBuffer(element, shaderCategory)
        if not element or not shader.public.buffer.element[element] or (shaderCategory and not shader.public.buffer.element[element][shaderCategory]) then return false end
        if not shaderCategory then
            for i, j in imports.pairs(shader.public.buffer.element[element]) do
                shader.public.clearElementBuffer(element, i)
            end
            shader.public.buffer.element[element] = nil
        else
            for i, j in imports.pairs(shader.public.buffer.element[element][shaderCategory].textured) do
                if j then j:destroy() end
            end
            for i, j in imports.pairs(shader.public.buffer.element[element][shaderCategory].untextured) do
                if i then i:destroy() end
            end
            shader.public.buffer.element[element][shaderCategory] = nil
        end
        return true
    end

    function shader.public:loadTex(cAsset, path)
        if not cAsset or not path then return false end
        if cAsset.manifest.encryptOptions then
            local temp = path..".tmp"
            if file:write(temp, asset:readFile(cAsset, path)) then
                local texture = imports.dxCreateTexture(temp, "dxt5", true)
                file:delete(temp)
                return texture
            end
        else
            return imports.dxCreateTexture(path, "dxt5", true)
        end
        return false
    end

    function shader.public:load(element, shaderCategory, shaderName, textureName, shaderTextures, shaderInputs, raw, shaderMaps, shaderPriority, shaderDistance, isStandalone, isOverlay, isInternal)
        if not shader.public:isInstance(self) then return false end
        if not shaderCategory or not shaderName or (not manager:isInternal(isInternal) and not shader.public.remoteWhitelist[shaderName]) or (not shader.public.preLoaded[shaderName] and not shaderRW.buffer[shaderName]) or (not isStandalone and not textureName) or not shaderTextures or not shaderInputs or not raw then return false end
        element = ((element and imports.isElement(element)) and element) or false
        textureName = textureName or false
        shaderPriority = imports.tonumber(shaderPriority) or shader.public.shaderPriority
        shaderDistance = imports.tonumber(shaderDistance) or shader.public.shaderDistance
        isStandalone = (isStandalone and true) or false
        isOverlay = (isOverlay and true) or false
        self.isPreLoaded = (shader.public.preLoaded[shaderName] and true) or false
        self.cShader = (self.isPreLoaded and shader.public.preLoaded[shaderName]) or imports.dxCreateShader(shaderRW.buffer[shaderName].exec(shaderMaps), shaderPriority, shaderDistance, isOverlay, "all")
        shader.public.buffer.shader[self] = true
        self.shaderData = {
            element = element,
            shaderCategory = shaderCategory,
            shaderName = shaderName,
            textureName = textureName,
            shaderTextures = shaderTextures,
            shaderInputs = shaderInputs,
            shaderPriority = shaderPriority,
            shaderDistance = shaderDistance,
            isStandalone = isStandalone
        }
        if not self.isPreLoaded then
            if not isStandalone and raw.shader then
                raw.shader[textureName] = self.cShader
            end
            renderer:sync(self)
        end
        for i, j in imports.pairs(shaderTextures) do
            if raw.texture then
                if j and imports.isElement(raw.texture[j]) then
                    self:setValue(i, raw.texture[j])
                end
            end
        end
        for i, j in imports.pairs(shaderInputs) do
            self:setValue(i, j)
        end
        if self.shaderData.element then
            shader.public.buffer.element[(self.shaderData.element)] = shader.public.buffer.element[(self.shaderData.element)] or {}
            local bufferCache = shader.public.buffer.element[(self.shaderData.element)]
            bufferCache[shaderCategory] = bufferCache[shaderCategory] or {textured = {}, untextured = {}}
            if not isStandalone then 
                bufferCache[shaderCategory].textured[textureName] = self
            else
                bufferCache[shaderCategory].untextured[self] = true
            end
        end
        if not isStandalone then imports.engineApplyShaderToWorldTexture(self.cShader, textureName, element) end
        return true
    end

    function shader.public:unload(isForced, isInternal)
        if not shader.public:isInstance(self) then return false end
        local isToBeUnloaded = (isForced and isInternal and manager:isInternal(isInternal) and true) or not self.preLoaded
        if not self.shaderData.isStandalone then imports.engineRemoveShaderFromWorldTexture(self.cShader, self.shaderData.textureName, self.shaderData.element) end
        if isToBeUnloaded then
            shader.public.preLoaded[(self.shaderData.shaderName)] = nil
            if self.shaderData.element then
                if not self.shaderData.isStandalone then 
                    shader.public.buffer.element[(self.shaderData.element)][(self.shaderData.shaderCategory)].textured[(self.shaderData.textureName)] = nil
                else
                    shader.public.buffer.element[(self.shaderData.element)][(self.shaderData.shaderCategory)].untextured[self] = nil
                end
            end
            shader.public.buffer.shader[self] = nil
            imports.destroyElement(self.cShader)
            self:destroyInstance()
        end
        return true
    end

    function shader.public:setValue(i, j)
        if not shader.public:isInstance(self) or not i then return false end
        return imports.dxSetShaderValue(self.cShader, i, j or false)
    end

    shader.public.preLoaded["Assetify_Tex_Clearer"] = shader.public:create(_, "Assetify ━ PreLoaded", "Assetify_Tex_Clearer", _, {baseTexture = 1}, {}, {texture = {[1] = shader.public.preLoadedTex.invisibleMap}}, _, _, shader.public.shaderPriority + 1, shader.public.shaderDistance, true)
    renderer:setDynamicSunColor(1*255, 0.7*255, 0.4*255)
    renderer:setDynamicStars(true)
    renderer:setDynamicCloudDensity(18)
    renderer:setDynamicCloudScale(13)
    renderer:setDynamicCloudColor(0.75*255, 0.75*255, 0.75*255)
    renderer:setTimeCycle(table.unpack(table.pack(table.decode(file:read("utilities/rw/timecycle.vcl"))), 1))

    renderer:setVirtualRendering(settings.renderer.state)
    renderer:setDynamicSky(settings.renderer.sky.state)
end


---------------------
--[[ API Syncers ]]--
---------------------

if localPlayer then
    network:fetch("Assetify:onElementDestroy"):on(function(source)
        if not syncer.isLibraryBooted or not source then return false end
        shader.public.clearElementBuffer(source)
    end)
end