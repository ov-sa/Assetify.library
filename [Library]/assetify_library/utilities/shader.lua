----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shader.lua
     Server: -
     Author: OvileAmriam
     Developer(s): Aviril, Tron
     DOC: 19/10/2021 (OvileAmriam)
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
    addEventHandler = addEventHandler,
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
    defaultData = {
        shaderPriority = 10000,
        shaderDistance = 0
    },
    preLoadedTex = {
        invisibleMap = imports.dxCreateTexture(2, 2, "dxt5", "clamp")
    },
    buffer = {
        element = {}
    },
    rwCache = shaderRW
}
shaderRW = nil
shader.preLoaded = {
    ["Assetify_TextureClearer"] = imports.dxCreateShader(shader.rwCache["Assetify_TextureChanger"], shader.defaultData.shaderPriority, shader.defaultData.shaderDistance, false, "all")
}
imports.dxSetShaderValue(shader.preLoaded["Assetify_TextureClearer"], "baseTexture", shader.preLoadedTex.invisibleMap)
shader.__index = shader

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
                    if encryptKey then
                        local cTexturePath = n..".tmp"
                        if imports.file.write(cTexturePath, imports.decodeString("tea", imports.file.read(n), {key = encryptKey})) then
                            rwCache.texture[(n)] = imports.dxCreateTexture(cTexturePath, "dxt5", true)
                            imports.file.delete(cTexturePath)
                        end
                    else
                        rwCache.texture[(n)] = imports.dxCreateTexture(n, "dxt5", true)
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
    for i, j in imports.pairs(rwCache.shader) do
        if j and imports.isElement(j) then
            imports.destroyElement(j)
        end
    end
    for i, j in imports.pairs(rwCache.texture) do
        if j and imports.isElement(j) then
            imports.destroyElement(j)
        end
    end
    return true
end

function shader:clearElementBuffer(element, shaderCategory)
    if not element or not imports.isElement(element) or not shader.buffer.element[element] or (shaderCategory and not shader.buffer.element[element][shaderCategory]) then return false end
    if not shaderCategory then
        for i, j in imports.pairs(shader.buffer.element[element]) do
            for k, v in imports.pairs(j) do
                if v and imports.isElement(v) then
                    v:destroy()
                end
            end
        end
        shader.buffer.element[element] = nil
    else
        for i, j in imports.pairs(shader.buffer.element[element][shaderCategory]) do
            if j then
                j:destroy()
            end
        end
        shader.buffer.element[element][shaderCategory] = nil
    end
    return true
end
imports.addEventHandler("onClientElementDestroy", resourceRoot, function() shader:clearElementBuffer(source) end)

function shader:load(element, shaderCategory, shaderName, textureName, shaderTextures, rwCache, encryptKey, shaderPriority, shaderDistance)
    if not self or (self == shader) then return false end
    if not element or not imports.isElement(element) or not shaderCategory or not shaderName or (not shader.preLoaded[shaderName] and not shader.rwCache[shaderName]) or not textureName or not shaderTextures or not rwCache then return false end
    shaderPriority = imports.tonumber(shaderPriority) or shader.defaultData.shaderPriority
    shaderDistance = imports.tonumber(shaderDistance) or shader.defaultData.shaderDistance
    self.isPreLoaded = (shader.preLoaded[shaderName] and true) or false
    self.cShader = (self.isPreLoaded and shader.preLoaded[shaderName]) or imports.dxCreateShader(shader.rwCache[shaderName], shaderPriority, shaderDistance, false, "all")
    if not self.isPreLoaded then rwCache.shader[shaderName] = self.cShader end
    for i, j in imports.pairs(shaderTextures) do
        if j and imports.isElement(rwCache.texture[j]) then
            imports.dxSetShaderValue(self.cShader, i, rwCache.texture[j])
        end
    end
    self.shaderData = {
        element = element,
        shaderCategory = shaderCategory,
        shaderName = shaderName,
        textureName = textureName,
        shaderTextures = shaderTextures,
        shaderPriority = shaderPriority,
        shaderDistance = shaderDistance
    }
    shader.buffer.element[element] = shader.buffer.element[element] or {}
    shader.buffer.element[element][shaderCategory] = shader.buffer.element[element][shaderCategory] or {}
    shader.buffer.element[element][shaderCategory][textureName] = self
    imports.engineApplyShaderToWorldTexture(self.cShader, textureName, element)
    return true
end

function shader:unload()
    if not self or (self == shader) then return false end
    if not self.preLoaded then
        if self.cShader and imports.isElement(self.cShader) then
            imports.destroyElement(self.cShader)
        end
    else
        imports.engineRemoveShaderFromWorldTexture(self.cShader, self.shaderData.textureName, self.shaderData.element)
    end
    shader.buffer.element[(self.shaderData.element)][(self.shaderData.shaderCategory)][(self.shaderData.textureName)] = nil
    self = nil
    return true
end