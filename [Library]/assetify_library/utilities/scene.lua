----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: scene.lua
     Server: -
     Author: vStudio
     Developer(s): Aviril, Tron
     DOC: 19/10/2021
     Desc: Scene Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    tonumber = tonumber,
    isElement = isElement,
    attachElements = attachElements,
    destroyElement = destroyElement,
    setmetatable = setmetatable,
    createObject = createObject,
    setElementAlpha = setElementAlpha,
    setElementDoubleSided = setElementDoubleSided,
    setElementDimension = setElementDimension,
    setElementInterior = setElementInterior
}


----------------------
--[[ Class: Scene ]]--
----------------------

scene = {}
scene.__index = scene

function scene:create(...)
    local cScene = imports.setmetatable({}, {__index = self})
    if not cScene:load(...) then
        cScene = nil
        return false
    end
    return cScene
end

function scene:destroy(...)
    if not self or (self == scene) then return false end
    return self:unload(...)
end

function scene:load(cAsset, sceneManifest, sceneData)
    if not self or (self == scene) then return false end
    if not cAsset or not sceneManifest or not sceneData then return false end
    local instanceCoords = {sceneData.position.x + ((sceneManifest.sceneOffset and sceneManifest.sceneOffset.x) or 0), sceneData.position.y + ((sceneManifest.sceneOffset and sceneManifest.sceneOffset.y) or 0), sceneData.position.z + ((sceneManifest.sceneOffset and sceneManifest.sceneOffset.z) or 0), sceneData.rotation.x, sceneData.rotation.y, sceneData.rotation.z}
    self.cStreamerInstance = imports.createObject(cAsset.syncedData.modelID, instanceCoords[1], instanceCoords[2], instanceCoords[3], instanceCoords[4], instanceCoords[5], instanceCoords[6], (sceneManifest.enableLODs and cAsset.syncedData.collisionID and true) or false)
    imports.setElementDoubleSided(self.cStreamerInstance, true)
    if cAsset.syncedData.collisionID then
        self.cCollisionInstance = imports.createObject(cAsset.syncedData.collisionID, instanceCoords[1], instanceCoords[2], instanceCoords[3], instanceCoords[4], instanceCoords[5], instanceCoords[6])
        imports.setElementAlpha(self.cCollisionInstance, 0)
        imports.setElementDimension(self.cCollisionInstance, sceneManifest.sceneDimension)
        imports.setElementInterior(self.cCollisionInstance, sceneManifest.sceneInterior)
        if sceneManifest.enableLODs then
            self.cModelInstance = imports.createObject(cAsset.syncedData.collisionID, instanceCoords[1], instanceCoords[2], instanceCoords[3], instanceCoords[4], instanceCoords[5], instanceCoords[6], true)
            imports.attachElements(self.cModelInstance, self.cCollisionInstance)
            imports.setElementAlpha(self.cModelInstance, 0)
            imports.setElementDimension(self.cModelInstance, sceneManifest.sceneDimension)
            imports.setElementInterior(self.cModelInstance, sceneManifest.sceneInterior)
            self.cStreamer = streamer:create(self.cStreamerInstance, "scene", {self.cCollisionInstance, self.cModelInstance})
        else
            self.cModelInstance = self.cStreamerInstance
            self.cStreamer = streamer:create(self.cStreamerInstance, "scene", {self.cCollisionInstance})
        end
    end
    cAsset.cScene = self
    return true
end

function scene:unload()
    if not self or (self == scene) then return false end
    if self.cStreamer then
        self.cStreamer:destroy()
    end
    if self.cStreamerInstance and imports.isElement(self.cStreamerInstance) then
        imports.destroyElement(self.cStreamerInstance)
    end
    if self.cModelInstance and imports.isElement(self.cModelInstance) then
        imports.destroyElement(self.cModelInstance)
    end
    if self.cCollisionInstance and imports.isElement(self.cCollisionInstance) then
        imports.destroyElement(self.cCollisionInstance)
    end
    self = nil
    return true
end