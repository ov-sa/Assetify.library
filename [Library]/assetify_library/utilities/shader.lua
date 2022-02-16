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
    tonumber = tonumber,
    isElement = isElement,
    destroyElement = destroyElement,
    setmetatable = setmetatable,
    dxCreateShader = dxCreateShader,
    dxCreateTexture = dxCreateTexture,
    dxSetShaderValue = dxSetShaderValue,
    engineApplyShaderToWorldTexture = engineApplyShaderToWorldTexture,
    engineRemoveShaderFromWorldTexture = engineRemoveShaderFromWorldTexture
}


-----------------------
--[[ Class: Shader ]]--
-----------------------

shader = {
    defaultData = {
        shaderPriority = 10000,
        shaderDistance = 0
    },
    preLoadedTextures = {
        invisibleMap = imports.dxCreateTexture(2, 2, "dxt5", "clamp")
    },
    rwCache = shaderRW
}
shaderRW = nil
shader.preLoaded = {
    ["Assetify_TextureClearer"] = imports.dxCreateShader(shader.rwCache["Assetify_TextureChanger"], shader.defaultData.shaderPriority, shader.defaultData.shaderDistance, false, "all")
}
imports.dxSetShaderValue(shader.preLoaded["Assetify_TextureClearer"], "baseTexture", shader.preLoadedTextures.invisibleMap)
shader.__index = shader

function shader:create(...)
    local cShader = imports.setmetatable({}, {__index = self})
    if not cShader:load(...) then
        cShader = nil
        return false
    end
    return cShader
end

function shader:destroy(...)
    if not self or (self == shader) then return false end
    return self:unload(...)
end

function shader:load(shaderName, textureName, textureElement, shaderPriority, shaderDistance)
    if not self or (self == shader) then return false end
    if not shaderName or not shader.rwCache[shaderName] or not textureName or not textureElement or not imports.isElement(textureElement) then return false end
    self.isPreLoaded = (shader.preLoaded[shaderName] and true) or false
    shaderPriority = imports.tonumber(shaderPriority) or shader.defaultData.shaderPriority
    shaderDistance = imports.tonumber(shaderDistance) or shader.defaultData.shaderDistance
    self.cShader = (self.isPreLoaded and shader.preLoaded[shaderName]) or imports.dxCreateShader(shader.rwCache[shaderName], shaderPriority, shaderDistance, false, "all")
    self.shaderData = {
        shaderName = shaderName,
        textureName = textureName,
        textureElement = textureElement,
        shaderPriority = shaderPriority,
        shaderDistance = shaderDistance
    }
    imports.engineApplyShaderToWorldTexture(self.cShader, textureName, textureElement)
    return true
end

function shader:unload()
    if not self or (self == shader) then return false end
    if not self.preLoaded then
        if imports.isElement(self.cShader) then
            imports.destroyElement(self.cShader)
        end
    else
        imports.engineRemoveShaderFromWorldTexture(self.cShader, self.shaderData.textureName, self.shaderData.textureElement)
    end
    self = nil
    return true
end