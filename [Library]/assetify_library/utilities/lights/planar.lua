----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: lights: planar.lua
     Author: vStudio
     Developer(s): Aviril, Tron
     DOC: 19/10/2021
     Desc: Planar Light Utilities ]]--
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
    dxSetShaderValue = dxSetShaderValue,
    engineRequestModel = engineRequestModel,
    engineLoadTXD = engineLoadTXD,
    engineLoadDFF = engineLoadDFF,
    engineLoadCOL = engineLoadCOL,
    engineImportTXD = engineImportTXD,
    engineReplaceModel = engineReplaceModel,
    engineReplaceCOL = engineReplaceCOL,
    engineApplyShaderToWorldTexture = engineApplyShaderToWorldTexture,
    createObject = createObject,
    setElementAlpha = setElementAlpha,
    setElementDoubleSided = setElementDoubleSided,
    setElementDimension = setElementDimension,
    setElementInterior = setElementInterior,
    clearModel = clearModel,
    math = math
}


-----------------------
--[[ Class: Shader ]]--
-----------------------

light.planar = {
    cache = {
        validTypes = {
            {index = "planar_1x1", textureName = "assetify_light_planar", resolution = {1, 1}}
        }
    },
    buffer = {}
}
for i = 1, #light.planar.cache.validTypes, 1 do
    local j = light.planar.cache.validTypes[i]
    local modelPath = "utilities/rw/"..j.index.."/"
    j.modelID, j.collisionID = imports.engineRequestModel("object"), imports.engineRequestModel("object")
    imports.engineImportTXD(imports.engineLoadTXD(modelPath.."dict.rw"), j.modelID)
    imports.engineReplaceModel(imports.engineLoadDFF(modelPath.."buffer.rw"), j.modelID, true)
    imports.engineReplaceCOL(imports.engineLoadCOL(modelPath.."collision.rw"), j.modelID)
    imports.clearModel(j.collisionID)
    imports.engineReplaceCOL(imports.engineLoadCOL(modelPath.."collision.rw"), j.collisionID)
    light.planar.cache.validTypes[i] = nil
    light.planar.cache.validTypes[(j.index)] = j
    light.planar.cache.validTypes[(j.index)].index = nil
end
light.planar.__index = light.planar

function light.planar:create(...)
    local cLight = imports.setmetatable({}, {__index = self})
    if not cLight:load(...) then
        cLight = nil
        return false
    end
    return cLight
end

function light.planar:destroy(...)
    if not self or (self == light.planar) then return false end
    return self:unload(...)
end

function light.planar:clearElementBuffer(element)
    if not element or not imports.isElement(element) or not light.planar.buffer[element] then return false end
    light.planar.buffer[element]:destroy()
    return true
end

function light.planar:load(lightType, lightData, shaderInputs, isScoped)
    if not self or (self == light.planar) then return false end
    if not lightType or not lightData or not shaderInputs then return false end
    local lightCache = light.planar.cache.validTypes[lightType]
    if not lightCache then return false end
    lightData.position, lightData.rotation = lightData.position or {}, lightData.rotation or {}
    lightData.position.x, lightData.position.y, lightData.position.z = imports.tonumber(lightData.position.x) or 0, imports.tonumber(lightData.position.y) or 0, imports.tonumber(lightData.position.z) or 0
    lightData.rotation.x, lightData.rotation.y, lightData.rotation.z = imports.tonumber(lightData.rotation.x) or 0, imports.tonumber(lightData.rotation.y) or 0, imports.tonumber(lightData.rotation.z) or 0
    self.cModelInstance = imports.createObject(lightCache.modelID, lightData.position.x, lightData.position.y, lightData.position.z, lightData.rotation.x, lightData.rotation.y, lightData.rotation.z)
    self.syncRate = imports.tonumber(lightData.syncRate)
    imports.setElementDoubleSided(self.cModelInstance, true)
    imports.setElementDimension(self.cModelInstance, imports.tonumber(lightData.dimension) or 0)
    imports.setElementInterior(self.cModelInstance, imports.tonumber(lightData.interior) or 0)
    if lightCache.collisionID then
        self.cCollisionInstance = imports.createObject(lightCache.collisionID, lightData.position.x, lightData.position.y, lightData.position.z, lightData.rotation.x, lightData.rotation.y, lightData.rotation.z)
        imports.setElementAlpha(self.cCollisionInstance, 0)
        self.cStreamer = streamer:create(self.cModelInstance, "light", {self.cCollisionInstance}, self.syncRate)
    end
    self.cLight = self.cModelInstance
    self.cShader = imports.dxCreateShader(shader.rwCache["Assetify_LightPlanar"](), shader.cache.shaderPriority, shader.cache.shaderDistance, false, "all")
    renderer:syncShader(self.cShader)
    light.planar.buffer[(self.cLight)] = self
    shader.buffer.shader[(self.cShader)] = "light"
    self.lightType = lightType
    for i, j in imports.pairs(shaderInputs) do
        imports.dxSetShaderValue(self.cLight, i, j)
    end
    imports.dxSetShaderValue(self.cShader, "lightResolution", lightCache.resolution[1], lightCache.resolution[2])
    self.lightData = lightData
    self.lightData.shaderInputs = shaderInputs
    self:setColor(self.lightData.color and self.lightData.color.r, self.lightData.color and self.lightData.color.g, self.lightData.color and self.lightData.color.b, self.lightData.color and self.lightData.color.a)
    imports.engineApplyShaderToWorldTexture(self.cShader, lightCache.textureName, self.cLight)
    if isScoped then manager:setElementScoped(self.cLight) end
    return true
end

function light.planar:unload()
    if not self or (self == light.planar) or self.isUnloading then return false end
    self.isUnloading = true
    if self.cStreamer then
        self.cStreamer:destroy()
    end
    if self.cModelInstance and imports.isElement(self.cModelInstance) then
        light.planar.buffer[(self.cModelInstance)] = nil
        imports.destroyElement(self.cModelInstance)
    end
    if self.cCollisionInstance and imports.isElement(self.cCollisionInstance) then
        imports.destroyElement(self.cCollisionInstance)
    end
    if self.cShader and imports.isElement(self.cShader) then
        shader.buffer.shader[(self.cShader)] = nil
        imports.destroyElement(self.cShader)
    end
    self = nil
    return true
end

function light.planar:setTexture(texture)
    if not self or (self == light.planar) then return false end
    self.lightData.texture = (self.lightData.texture or texture) or false
    imports.dxSetShaderValue(self.cShader, "baseTexture", self.lightData.texture)
    return true
end

function light.planar:setColor(r, g, b, a)
    if not self or (self == light.planar) then return false end
    self.lightData.color = self.lightData.color or {}
    self.lightData.color[1], self.lightData.color[2], self.lightData.color[3], self.lightData.color[4] = imports.math.max(0, imports.math.min(255, imports.tonumber(r) or 255)), imports.math.max(0, imports.math.min(255, imports.tonumber(g) or 255)), imports.math.max(0, imports.math.min(255, imports.tonumber(b) or 255)), imports.math.max(0, imports.math.min(255, imports.tonumber(a) or 255))
    imports.dxSetShaderValue(self.cShader, "lightColor", self.lightData.color[1]/255, self.lightData.color[2]/255, self.lightData.color[3]/255, self.lightData.color[4]/255)
    return true
end