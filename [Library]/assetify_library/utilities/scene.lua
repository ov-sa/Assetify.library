----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: scene.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Scene Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    isElement = isElement,
    destroyElement = destroyElement,
    setmetatable = setmetatable,
    collectgarbage = collectgarbage,
    createObject = createObject,
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

function scene:load(cAsset, sceneDimension, sceneInterior)

    if not self or (self == scene) then return false end
    if not cAsset or not sceneDimension or not sceneInterior then return false end

    self.cObject = imports.createObject(cAsset.syncedData.modelID, cAsset.cData.position.x, cAsset.cData.position.y, cAsset.cData.position.z, cAsset.cData.rotation.x, cAsset.cData.rotation.y, cAsset.cData.rotation.z)
    self.cLODObject = imports.createObject(cAsset.syncedData.modelID, cAsset.cData.position.x, cAsset.cData.position.y, cAsset.cData.position.z, cAsset.cData.rotation.x, cAsset.cData.rotation.y, cAsset.cData.rotation.z, true)
    --TODO: Add config for LODs
    imports.setElementDoubleSided(self.cObject, true)
    imports.setElementDoubleSided(self.cLODObject, true)
    imports.setElementDimension(self.cObject, sceneDimension)
    imports.setElementInterior(self.cObject, sceneInterior)
    imports.setElementDimension(self.cLODObject, sceneDimension)
    imports.setElementInterior(self.cLODObject, sceneInterior)
    return true

end

function scene:unload(cAsset)

    if not self or (self == scene) then return false end
    if not cAsset then return false end

    if imports.isElement(self.cObject) then
        imports.destroyElement(self.cObject)
    end
    if imports.isElement(self.cLODObject) then
        imports.destroyElement(self.cLODObject)
    end
    self = nil
    imports.collectgarbage()
    return true

end