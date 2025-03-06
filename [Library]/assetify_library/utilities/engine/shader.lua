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
    priority = 10000,
    distance = 0,
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
        "Assetify_Tex_Clear",
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

    function shader.public:fetchInstance(element, category, textureName)
        if element and category and textureName then
            if shader.public.buffer.element[element] and shader.public.buffer.element[element][category] and shader.public.buffer.element[element][category].textured[textureName] then
                return shader.public.buffer.element[element][category].textured[textureName]
            end
        end
        return false
    end

    function shader.public.clearElementBuffer(element, category)
        if not element or not shader.public.buffer.element[element] or (category and not shader.public.buffer.element[element][category]) then return false end
        if not category then
            for i, j in imports.pairs(shader.public.buffer.element[element]) do
                shader.public.clearElementBuffer(element, i)
            end
            shader.public.buffer.element[element] = nil
        else
            for i, j in imports.pairs(shader.public.buffer.element[element][category].textured) do
                if j then j:destroy() end
            end
            for i, j in imports.pairs(shader.public.buffer.element[element][category].untextured) do
                if i then i:destroy() end
            end
            shader.public.buffer.element[element][category] = nil
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

    function shader.public:load(element, category, name, textureName, textures, inputs, raw, maps, priority, distance, standalone, overlay, isInternal)
        if not shader.public:isInstance(self) then return false end
        if not category or not name or (not manager:isInternal(isInternal) and not shader.public.remoteWhitelist[name]) or (not shader.public.preLoaded[name] and not shaderRW.buffer[name]) or (not standalone and not textureName) or not textures or not inputs or not raw then return false end
        element = ((element and imports.isElement(element)) and element) or false
        textureName = textureName or false
        priority = imports.tonumber(priority) or shader.public.priority
        distance = imports.tonumber(distance) or shader.public.distance
        standalone = (standalone and true) or false
        overlay = (overlay and true) or false
        self.isPreLoaded = (shader.public.preLoaded[name] and true) or false
        self.cShader = (self.isPreLoaded and shader.public.preLoaded[name]) or imports.dxCreateShader(shaderRW.buffer[name].exec(maps), priority, distance, overlay, "all")
        shader.public.buffer.shader[self] = true
        self.data = {
            element = element,
            category = category,
            name = name,
            textureName = textureName,
            textures = textures,
            inputs = inputs,
            priority = priority,
            distance = distance,
            standalone = standalone,
            overlay = overlay
        }
        if not self.isPreLoaded then
            if not standalone and raw.shader then
                raw.shader[textureName] = self.cShader
            end
            renderer:sync(self)
        end
        for i, j in imports.pairs(textures) do
            if raw.texture then
                if j and imports.isElement(raw.texture[j]) then
                    self:setValue(i, raw.texture[j])
                end
            end
        end
        for i, j in imports.pairs(inputs) do
            self:setValue(i, j)
        end
        if self.data.element then
            shader.public.buffer.element[(self.data.element)] = shader.public.buffer.element[(self.data.element)] or {}
            local bufferCache = shader.public.buffer.element[(self.data.element)]
            bufferCache[category] = bufferCache[category] or {textured = {}, untextured = {}}
            if not standalone then 
                bufferCache[category].textured[textureName] = self
            else
                bufferCache[category].untextured[self] = true
            end
        end
        if not standalone then imports.engineApplyShaderToWorldTexture(self.cShader, textureName, element) end
        return true
    end

    function shader.public:unload(isForced, isInternal)
        if not shader.public:isInstance(self) then return false end
        local isToBeUnloaded = (isForced and isInternal and manager:isInternal(isInternal) and true) or not self.preLoaded
        if not self.data.standalone then imports.engineRemoveShaderFromWorldTexture(self.cShader, self.data.textureName, self.data.element) end
        if isToBeUnloaded then
            shader.public.preLoaded[(self.data.name)] = nil
            if self.data.element then
                if not self.data.standalone then 
                    shader.public.buffer.element[(self.data.element)][(self.data.category)].textured[(self.data.textureName)] = nil
                else
                    shader.public.buffer.element[(self.data.element)][(self.data.category)].untextured[self] = nil
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

    shader.public.preLoaded["Assetify_Tex_Clear"] = shader.public:create(_, "Assetify:PreLoad", "Assetify_Tex_Clear", _, {}, {baseTexture = shader.public.preLoadedTex.invisibleMap}, {}, _, _, shader.public.priority + 1, shader.public.distance, true)
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