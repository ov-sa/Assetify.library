----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shader.lua
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
    decodeString = decodeString,
    tonumber = tonumber,
    isElement = isElement,
    destroyElement = destroyElement,
    setmetatable = setmetatable,
    dxCreateShader = dxCreateShader,
    dxCreateTexture = dxCreateTexture,
    dxSetShaderValue = dxSetShaderValue,
    engineApplyShaderToWorldTexture = engineApplyShaderToWorldTexture,
    engineRemoveShaderFromWorldTexture = engineRemoveShaderFromWorldTexture,
    file = file
}


-----------------------
--[[ Class: Shader ]]--
-----------------------

shader = {
    cache = {
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
    }
}
shader.cache.__remoteBlacklist = {}
for i, j in imports.pairs(shader.cache.remoteBlacklist) do
    shader.cache.__remoteBlacklist[j] = true
end
shader.cache.remoteBlacklist = shader.cache.__remoteBlacklist
shader.__index = shader

if localPlayer then
    shader.cache.shaderPriority = 10000
    shader.cache.shaderDistance = 0
    shader.preLoadedTex = {
        invisibleMap = imports.dxCreateTexture(2, 2, "dxt5", "clamp")
    }
    shader.buffer = {
        element = {},
        shader = {}
    }
    shader.rwCache = shaderRW
    shaderRW = nil
    shader.preLoaded = {}

    function shader:create(...)
        local cShader = imports.setmetatable({}, {__index = self})
        if not cShader:load(...) then
            cShader = nil
            return false
        end
        return cShader
    end

    function shader:createTex(shaderMaps, rwCache, encryptKey)
        if not shaderMaps or not rwCache then return false end
        rwCache.shader = {}
        rwCache.texture = {}
        for i, j in imports.pairs(shaderMaps) do
            if i == "clump" then
                for k, v in imports.pairs(j) do
                    for m = 1, #v, 1 do
                        local n = v[m]
                        if n.clump then
                            rwCache.texture[(n.clump)] = shader:loadTex(n.clump, encryptKey)
                        end
                        if n.bump then
                            rwCache.texture[(n.bump)] = shader:loadTex(n.bump, encryptKey)
                        end
                    end
                end
            elseif i == "control" then
                for k, v in imports.pairs(j) do
                    for m = 1, #v, 1 do
                        local n = v[m]
                        if n.control then
                            rwCache.texture[(n.control)] = shader:loadTex(n.control, encryptKey)
                        end
                        if n.bump then
                            rwCache.texture[(n.bump)] = shader:loadTex(n.bump, encryptKey)
                        end
                        for x = 1, #shader.cache.validChannels, 1 do
                            local y = n[(shader.cache.validChannels[x].index)]
                            if y and y.map then
                                rwCache.texture[(y.map)] = shader:loadTex(y.map, encryptKey)
                                if y.bump then
                                    rwCache.texture[(y.bump)] = shader:loadTex(y.bump, encryptKey)
                                end
                            end
                        end
                    end
                end
            end
        end
        return true
    end

    function shader:destroy(...)
        if not self or (self == shader) then return false end
        return self:unload(...)
    end

    function shader:clearAssetBuffer(rwCache)
        if not rwCache then return false end
        if rwCache.shader then
            for i, j in imports.pairs(rwCache.shader) do
                if j and imports.isElement(j) then
                    imports.destroyElement(j)
                end
            end
        end
        if rwCache.texture then
            for i, j in imports.pairs(rwCache.texture) do
                if j and imports.isElement(j) then
                    imports.destroyElement(j)
                end
            end
        end
        return true
    end

    function shader:clearElementBuffer(element, shaderCategory)
        if not element or not shader.buffer.element[element] or (shaderCategory and not shader.buffer.element[element][shaderCategory]) then return false end
        if not shaderCategory then
            for i, j in imports.pairs(shader.buffer.element[element]) do
                shader:clearElementBuffer(element, i)
            end
            shader.buffer.element[element] = nil
        else
            for i, j in imports.pairs(shader.buffer.element[element][shaderCategory].textured) do
                if j then
                    j:destroy()
                end
            end
            for i, j in imports.pairs(shader.buffer.element[element][shaderCategory].untextured) do
                if i then
                    i:destroy()
                end
            end
            shader.buffer.element[element][shaderCategory] = nil
        end
        return true
    end

    function shader:loadTex(texturePath, encryptKey)
        if texturePath then
            if encryptKey then
                local cTexturePath = texturePath..".tmp"
                if imports.file.write(cTexturePath, imports.decodeString("tea", imports.file.read(texturePath), {key = encryptKey})) then
                    local cTexture = imports.dxCreateTexture(cTexturePath, "dxt5", true)
                    imports.file.delete(cTexturePath)
                    return cTexture
                end
            else
                return imports.dxCreateTexture(texturePath, "dxt5", true)
            end
        end
        return false
    end

    function shader:load(element, shaderCategory, shaderName, textureName, shaderTextures, shaderInputs, rwCache, shaderMaps, encryptKey, shaderPriority, shaderDistance, isStandalone)
        if not self or (self == shader) then return false end
        local isExternalResource = sourceResource and (sourceResource ~= syncer.libraryResource)
        if not shaderCategory or not shaderName or (isExternalResource and shader.cache.remoteBlacklist[shaderName]) or (not shader.preLoaded[shaderName] and not shader.rwCache[shaderName]) or (not isStandalone and not textureName) or not shaderTextures or not shaderInputs or not rwCache then return false end
        element = ((element and imports.isElement(element)) and element) or false
        textureName = textureName or false
        shaderPriority = imports.tonumber(shaderPriority) or shader.cache.shaderPriority
        shaderDistance = imports.tonumber(shaderDistance) or shader.cache.shaderDistance
        isStandalone = (isStandalone and true) or false
        self.isPreLoaded = (shader.preLoaded[shaderName] and true) or false
        self.cShader = (self.isPreLoaded and shader.preLoaded[shaderName]) or imports.dxCreateShader(shader.rwCache[shaderName].exec(shaderMaps), shaderPriority, shaderDistance, false, "all")
        shader.buffer.shader[self] = true
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
            if not isStandalone then
                rwCache.shader[textureName] = self.cShader
            end
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
            shader.buffer.element[(self.shaderData.element)] = shader.buffer.element[(self.shaderData.element)] or {}
            local bufferCache = shader.buffer.element[(self.shaderData.element)]
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

    function shader:unload()
        if not self or (self == shader) or self.isUnloading then return false end
        self.isUnloading = true
        if not self.preLoaded then
            if self.cShader and imports.isElement(self.cShader) then
                imports.destroyElement(self.cShader)
            end
        else
            if not self.shaderData.isStandalone then imports.engineRemoveShaderFromWorldTexture(self.cShader, self.shaderData.textureName, self.shaderData.element) end
        end
        if self.shaderData.element then
            if not self.shaderData.isStandalone then 
                shader.buffer.element[(self.shaderData.element)][(self.shaderData.shaderCategory)].textured[(self.shaderData.textureName)] = nil
            else
                shader.buffer.element[(self.shaderData.element)][(self.shaderData.shaderCategory)].untextured[self] = nil
            end
        end
        shader.buffer.shader[self] = nil
        self = nil
        return true
    end

    function shader:setValue(i, j)
        if not self or (self == shader) or not i or (shader.rwCache[(self.shaderData.shaderName)].properties.disabled[i]) then return false end
        return imports.dxSetShaderValue(self.cShader, i, j)
    end

    shader.preLoaded["Assetify_TextureClearer"] = shader:create(_, "Assetify-PreLoaded", "Assetify_TextureClearer", _, {baseTexture = 1}, {}, {texture = {[1] = shader.preLoadedTex.invisibleMap}}, _, _, shader.cache.shaderPriority + 1, shader.cache.shaderDistance, true)
end