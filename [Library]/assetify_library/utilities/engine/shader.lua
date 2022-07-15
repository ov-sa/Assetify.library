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
    validChannels = {
        {index = "red", channel = "r"},
        {index = "green", channel = "g"},
        {index = "blue", channel = "b"}
    },
    validLayers = {
        {index = "diffuse", alpha = true},
        {index = "emissive", alpha = false}
    },
    remoteBlacklist = {}
})
shader.private.__remoteBlacklist = {}
for i = 1, #shader.public.remoteBlacklist, 1 do
    local j = shader.public.remoteBlacklist[i]
    shader.private.__remoteBlacklist[j] = true
end
shader.public.remoteBlacklist = shader.private.__remoteBlacklist
shader.private.__remoteBlacklist = nil

if localPlayer then
    shader.public.preLoaded, shader.public.preLoadedTex = {}, {
        invisibleMap = imports.dxCreateTexture(2, 2, "dxt5", "clamp")
    }
    shader.public.buffer = {
        element = {},
        shader = {}
    }
    shader.public.rwCache = shaderRW
    shaderRW = nil

    function shader.public:create(...)
        local cShader = self:createInstance()
        if cShader and not cShader:load(...) then
            cShader:destroyInstance()
            return false
        end
        return cShader
    end

    function shader.public:createTex(shaderMaps, rwCache, encryptKey)
        if not shaderMaps or not rwCache then return false end
        rwCache.shader = {}
        rwCache.texture = {}
        for i, j in imports.pairs(shaderMaps) do
            if i == "clump" then
                for k, v in imports.pairs(j) do
                    for m = 1, #v, 1 do
                        local n = v[m]
                        if n.clump then rwCache.texture[(n.clump)] = shader.public:loadTex(n.clump, encryptKey) end
                        if n.bump then rwCache.texture[(n.bump)] = shader.public:loadTex(n.bump, encryptKey) end
                    end
                end
            elseif i == "control" then
                for k, v in imports.pairs(j) do
                    for m = 1, #v, 1 do
                        local n = v[m]
                        if n.control then rwCache.texture[(n.control)] = shader.public:loadTex(n.control, encryptKey) end
                        if n.bump then rwCache.texture[(n.bump)] = shader.public:loadTex(n.bump, encryptKey) end
                        for x = 1, #shader.public.validChannels, 1 do
                            local y = n[(shader.public.validChannels[x].index)]
                            if y and y.map then
                                rwCache.texture[(y.map)] = shader.public:loadTex(y.map, encryptKey)
                                if y.bump then rwCache.texture[(y.bump)] = shader.public:loadTex(y.bump, encryptKey) end
                            end
                        end
                    end
                end
            end
        end
        return true
    end

    function shader.public:destroy(...)
        if not shader.public:isInstance(self) then return false end
        return self:unload(...)
    end

    function shader.public.clearAssetBuffer(rwCache)
        if not rwCache then return false end
        if rwCache.shader then
            for i, j in imports.pairs(rwCache.shader) do
                imports.destroyElement(j)
                rwCache.shader[i] = nil
            end
        end
        if rwCache.texture then
            for i, j in imports.pairs(rwCache.texture) do
                imports.destroyElement(j)
                rwCache.texture[i] = nil
            end
        end
        return true
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

    function shader.public:loadTex(texturePath, encryptKey)
        if texturePath then
            if encryptKey then
                local cTexturePath = texturePath..".tmp"
                if file:write(cTexturePath, asset:readFile(texturePath, encryptKey)) then
                    local cTexture = imports.dxCreateTexture(cTexturePath, "dxt5", true)
                    file:delete(cTexturePath)
                    return cTexture
                end
            else
                return imports.dxCreateTexture(texturePath, "dxt5", true)
            end
        end
        return false
    end

    function shader.public:load(element, shaderCategory, shaderName, textureName, shaderTextures, shaderInputs, rwCache, shaderMaps, encryptKey, shaderPriority, shaderDistance, isStandalone)
        if not shader.public:isInstance(self) then return false end
        local isExternalResource = sourceResource and (sourceResource ~= syncer.libraryResource)
        if not shaderCategory or not shaderName or (isExternalResource and shader.public.remoteBlacklist[shaderName]) or (not shader.public.preLoaded[shaderName] and not shader.public.rwCache[shaderName]) or (not isStandalone and not textureName) or not shaderTextures or not shaderInputs or not rwCache then return false end
        element = ((element and imports.isElement(element)) and element) or false
        textureName = textureName or false
        shaderPriority = imports.tonumber(shaderPriority) or shader.public.shaderPriority
        shaderDistance = imports.tonumber(shaderDistance) or shader.public.shaderDistance
        isStandalone = (isStandalone and true) or false
        self.isPreLoaded = (shader.public.preLoaded[shaderName] and true) or false
        self.cShader = (self.isPreLoaded and shader.public.preLoaded[shaderName]) or imports.dxCreateShader(shader.public.rwCache[shaderName].exec(shaderMaps), shaderPriority, shaderDistance, false, "all")
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
            if not isStandalone then rwCache.shader[textureName] = self.cShader end
            renderer:syncShader(self)
        end
        for i, j in imports.pairs(shaderTextures) do
            if rwCache.texture then
                if j and imports.isElement(rwCache.texture[j]) then
                    self:setValue(i, rwCache.texture[j])
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

    function shader.public:unload()
        if not shader.public:isInstance(self) then return false end
        if not self.preLoaded then
            imports.destroyElement(self.cShader)
        else
            if not self.shaderData.isStandalone then imports.engineRemoveShaderFromWorldTexture(self.cShader, self.shaderData.textureName, self.shaderData.element) end
        end
        if self.shaderData.element then
            if not self.shaderData.isStandalone then 
                shader.public.buffer.element[(self.shaderData.element)][(self.shaderData.shaderCategory)].textured[(self.shaderData.textureName)] = nil
            else
                shader.public.buffer.element[(self.shaderData.element)][(self.shaderData.shaderCategory)].untextured[self] = nil
            end
        end
        shader.public.buffer.shader[self] = nil
        self:destroyInstance()
        return true
    end

    function shader.public:setValue(i, j)
        if not shader.public:isInstance(self) or not i or (shader.public.rwCache[(self.shaderData.shaderName)].properties.disabled[i]) then return false end
        return imports.dxSetShaderValue(self.cShader, i, j)
    end

    shader.public.preLoaded["Assetify_TextureClearer"] = shader.public:create(_, "Assetify-PreLoaded", "Assetify_TextureClearer", _, {baseTexture = 1}, {}, {texture = {[1] = shader.public.preLoadedTex.invisibleMap}}, _, _, shader.public.shaderPriority + 1, shader.public.shaderDistance, true)
end