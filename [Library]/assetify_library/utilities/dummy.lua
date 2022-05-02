----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: dummy.lua
     Author: vStudio
     Developer(s): Aviril, Tron
     DOC: 19/10/2021
     Desc: Dummy Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    tonumber = tonumber,
    isElement = isElement,
    destroyElement = destroyElement,
    setmetatable = setmetatable,
    createObject = createObject,
    setElementAlpha = setElementAlpha,
    setElementDoubleSided = setElementDoubleSided,
    setElementDimension = setElementDimension,
    setElementInterior = setElementInterior,
    triggerEvent = triggerEvent
}


----------------------
--[[ Class: Dummy ]]--
----------------------

dummy = {
    buffer = {}
}
dummy.__index = dummy

function dummy:create(...)
    local cDummy = imports.setmetatable({}, {__index = self})
    if not cDummy:load(...) then
        cDummy = nil
        return false
    end
    return cDummy
end

function dummy:destroy(...)
    if not self or (self == dummy) then return false end
    return self:unload(...)
end

function dummy:clearElementBuffer(element)
    if not element or not imports.isElement(element) then return false end
    if dummy.buffer[element] then
        dummy.buffer[element]:destroy()
    end
    return true
end

function dummy:load(assetType, assetName, assetClump, clumpMaps, dummyData)
    if not self or (self == dummy) then return false end
    if not dummyData then return false end
    local cAsset, cData = manager:getData(assetType, assetName)
    cData = (cAsset and cData and ((cAsset.manifestData.assetClumps and cAsset.unSynced.assetCache[assetClump].cAsset.synced) or cData)) or false
    if not cAsset or not cData then return false end
    dummyData.position, dummyData.rotation = dummyData.position or {}, dummyData.rotation or {}
    dummyData.position.x, dummyData.position.y, dummyData.position.z = imports.tonumber(dummyData.position.x) or 0, imports.tonumber(dummyData.position.y) or 0, imports.tonumber(dummyData.position.z) or 0
    dummyData.rotation.x, dummyData.rotation.y, dummyData.rotation.z = imports.tonumber(dummyData.rotation.x) or 0, imports.tonumber(dummyData.rotation.y) or 0, imports.tonumber(dummyData.rotation.z) or 0
    self.assetType, self.assetName = assetType, assetName
    self.cModelInstance = imports.createObject(cData.modelID, dummyData.position.x, dummyData.position.y, dummyData.position.z, dummyData.rotation.x, dummyData.rotation.y, dummyData.rotation.z)
    self.syncRate = imports.tonumber(dummyData.syncRate)
    imports.setElementDoubleSided(self.cModelInstance, true)
    imports.setElementDimension(self.cModelInstance, imports.tonumber(dummyData.dimension) or 0)
    imports.setElementInterior(self.cModelInstance, imports.tonumber(dummyData.interior) or 0)
    imports.triggerEvent("Assetify:onRecieveElementModel", localPlayer, self.cModelInstance, assetType, assetName, assetClump, clumpMaps)
    if cData.collisionID then
        self.cCollisionInstance = imports.createObject(cData.collisionID, dummyData.position.x, dummyData.position.y, dummyData.position.z, dummyData.rotation.x, dummyData.rotation.y, dummyData.rotation.z)
        imports.setElementAlpha(self.cCollisionInstance, 0)
        self.cStreamer = streamer:create(self.cModelInstance, "dummy", {self.cCollisionInstance}, self.syncRate)
    end
    self.cDummy = self.cCollisionInstance or self.cModelInstance
    dummy.buffer[(self.cDummy)] = self
    return true
end

function dummy:unload()
    if not self or (self == dummy) then return false end
    if self.cStreamer then
        self.cStreamer:destroy()
    end
    if self.cModelInstance and imports.isElement(self.cModelInstance) then
        imports.destroyElement(self.cModelInstance)
    end
    if self.cCollisionInstance and imports.isElement(self.cCollisionInstance) then
        imports.destroyElement(self.cCollisionInstance)
    end
    dummy.buffer[self] = nil
    self = nil
    return true
end

function dummy:stream()
    if not self or (self == dummy) then return false end
    if self.cStreamer or not self.cModelInstance or not self.cCollisionInstance then return false end
    self.cStreamer = streamer:create(self.cModelInstance, "dummy", {self.cCollisionInstance})
    return true
end