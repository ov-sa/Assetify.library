----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: engine: light: planar.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Planar Light Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    tonumber = tonumber,
    destroyElement = destroyElement,
    engineRequestModel = engineRequestModel,
    engineLoadTXD = engineLoadTXD,
    engineLoadDFF = engineLoadDFF,
    engineLoadCOL = engineLoadCOL,
    engineImportTXD = engineImportTXD,
    engineReplaceModel = engineReplaceModel,
    engineReplaceCOL = engineReplaceCOL,
    createObject = createObject,
    setElementAlpha = setElementAlpha,
    setElementDimension = setElementDimension,
    setElementInterior = setElementInterior
}


-----------------------
--[[ Class: Shader ]]--
-----------------------

local syncer = syncer:import()
local planar = class:create("planar", {
    cache = {
        validTypes = {
            {index = "planar_1x1", textureName = "assetify_light_planar"}
        }
    },
    buffer = {}
}, "light")
syncer.private.execOnBoot(function()
    for i = 1, #planar.private.cache.validTypes, 1 do
        local j = planar.private.cache.validTypes[i]
        local modelPath = "utilities/rw/"..j.index.."/"
        j.modelID, j.collisionID = imports.engineRequestModel("object"), imports.engineRequestModel("object")
        imports.engineImportTXD(imports.engineLoadTXD(modelPath.."dict.rw"), j.modelID)
        imports.engineReplaceModel(imports.engineLoadDFF(modelPath.."buffer.rw"), j.modelID, true)
        imports.engineReplaceCOL(imports.engineLoadCOL(modelPath.."collision.rw"), j.modelID)
        manager.API.World.clearModel(j.collisionID)
        imports.engineReplaceCOL(imports.engineLoadCOL(modelPath.."collision.rw"), j.collisionID)
        planar.private.cache.validTypes[i] = nil
        planar.private.cache.validTypes[(j.index)] = j
        planar.private.cache.validTypes[(j.index)].index = nil
    end
end)

function planar.public:create(...)
    local cLight = self:createInstance()
    if cLight and not cLight:load(...) then
        cLight:destroyInstance()
        return false
    end
    return cLight
end

function planar.public:destroy(...)
    if not self or (self == planar.public) then return false end
    return self:unload(...)
end

function planar.public.clearElementBuffer(element)
    if not element or not planar.public.buffer[element] then return false end
    planar.public.buffer[element]:destroy()
    return true
end

function planar.public:load(lightType, lightData, shaderInputs, isScoped, isDefaultStreamer)
    if not self or (self == planar.public) then return false end
    if not lightType or not lightData or not shaderInputs then return false end
    local lightCache = planar.private.cache.validTypes[lightType]
    if not lightCache then return false end
    lightData.position, lightData.rotation = lightData.position or {}, lightData.rotation or {}
    lightData.position.x, lightData.position.y, lightData.position.z = imports.tonumber(lightData.position.x) or 0, imports.tonumber(lightData.position.y) or 0, imports.tonumber(lightData.position.z) or 0
    lightData.rotation.x, lightData.rotation.y, lightData.rotation.z = imports.tonumber(lightData.rotation.x) or 0, imports.tonumber(lightData.rotation.y) or 0, imports.tonumber(lightData.rotation.z) or 0
    self.cModelInstance = imports.createObject(lightCache.modelID, lightData.position.x, lightData.position.y, lightData.position.z, lightData.rotation.x, lightData.rotation.y, lightData.rotation.z)
    self.syncRate = imports.tonumber(lightData.syncRate)
    imports.setElementDimension(self.cModelInstance, imports.tonumber(lightData.dimension) or 0)
    imports.setElementInterior(self.cModelInstance, imports.tonumber(lightData.interior) or 0)
    if not isDefaultStreamer and lightCache.collisionID then
        self.cCollisionInstance = imports.createObject(lightCache.collisionID, lightData.position.x, lightData.position.y, lightData.position.z, lightData.rotation.x, lightData.rotation.y, lightData.rotation.z)
        imports.setElementAlpha(self.cCollisionInstance, 0)
        self.cStreamer = streamer:create(self.cModelInstance, "light", {self.cCollisionInstance}, self.syncRate)
    end
    self.cLight = self.cModelInstance
    self.cShader = shader:create(self.cLight, "Assetify-Planar-Light", "Assetify_LightPlanar", lightCache.textureName, {}, shaderInputs, {})
    planar.public.buffer[(self.cLight)] = self
    self.lightType = lightType
    self.lightData = lightData
    self:setResolution(self.lightData.resolution)
    self:setColor(self.lightData.color and self.lightData.color.r, self.lightData.color and self.lightData.color.g, self.lightData.color and self.lightData.color.b, self.lightData.color and self.lightData.color.a)
    if isScoped then manager:setElementScoped(self.cLight) end
    return true
end

function planar.public:unload()
    if not self or (self == planar.public) then return false end
    if self.cStreamer then self.cStreamer:destroy() end
    planar.public.buffer[(self.cModelInstance)] = nil
    imports.destroyElement(self.cModelInstance)
    imports.destroyElement(self.cCollisionInstance)
    self:destroyInstance()
    return true
end

function planar.public:setResolution(resolution)
    if not self or (self == planar.public) then return false end
    self.lightData.resolution = math.max(0, imports.tonumber(resolution) or 1)
    self.cShader:setValue("lightResolution", self.lightData.resolution)
    return true
end

function planar.public:setTexture(texture)
    if not self or (self == planar.public) then return false end
    self.lightData.texture = (self.lightData.texture or texture) or false
    self.cShader:setValue("baseTexture", self.lightData.texture)
    return true
end

function planar.public:setColor(r, g, b, a)
    if not self or (self == planar.public) then return false end
    self.lightData.color = self.lightData.color or {}
    self.lightData.color[1], self.lightData.color[2], self.lightData.color[3], self.lightData.color[4] = math.max(0, math.min(255, imports.tonumber(r) or 255)), math.max(0, math.min(255, imports.tonumber(g) or 255)), math.max(0, math.min(255, imports.tonumber(b) or 255)), math.max(0, math.min(255, imports.tonumber(a) or 255))
    self.cShader:setValue("lightColor", self.lightData.color[1]/255, self.lightData.color[2]/255, self.lightData.color[3]/255, self.lightData.color[4]/255)
    return true
end