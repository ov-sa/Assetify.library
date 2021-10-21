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
    createObject = createObject
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

function scene:load(cAsset)

    if not self or (self == scene) then return false end
    if not cAsset then return false end

    self.cObject = imports.createObject(cAsset.syncedData.modelID, cAsset.cData.position.x, cAsset.cData.position.y, cAsset.cData.position.z, cAsset.cData.rotation.x, cAsset.cData.rotation.y, cAsset.cData.rotation.z)
    return true

end

function scene:unload(cAsset)

    if not self or (self == scene) then return false end
    if not cAsset then return false end

    if imports.isElement(self.cObject) then
        imports.destroyElement(self.cObject)
    end
    self = nil
    imports.collectgarbage()
    return true

end