----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: dummy.lua
     Server: -
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
    setmetatable = setmetatable,
    createObject = createObject,
    setElementAlpha = setElementAlpha,
    setElementDoubleSided = setElementDoubleSided,
    setElementDimension = setElementDimension,
    setElementInterior = setElementInterior
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

function dummy:load(assetType, assetName, dummyData)
    if not self or (self == dummy) then return false end
    if not assetType or not assetName or not dummyData or not dummyData.position or not dummyData.rotation or not availableAssetPacks[assetType] or not availableAssetPacks[assetType].rwDatas[assetName] then return false end
    local cAsset = availableAssetPacks[assetType].rwDatas[assetName].cAsset
    if not cAsset then return false end
    dummyData.position.x, dummyData.position.y, dummyData.position.z = imports.tonumber(dummyData.position.x) or 0, imports.tonumber(dummyData.position.y) or 0, imports.tonumber(dummyData.position.z) or 0
    dummyData.rotation.x, dummyData.rotation.y, dummyData.rotation.z = imports.tonumber(dummyData.position.x) or 0, imports.tonumber(dummyData.position.y) or 0, imports.tonumber(dummyData.position.z) or 0
    self.assetType, self.assetName = assetType, assetName
    self.cModelInstance = imports.createObject(cAsset.syncedData.modelID, dummyData.position.x, dummyData.position.y, dummyData.position.z, dummyData.rotation.x, dummyData.rotation.y, dummyData.rotation.z)
    imports.setElementDoubleSided(self.cModelInstance, true)
    imports.setElementDimension(self.cModelInstance, imports.tonumber(dummyData.dimension) or 0)
    imports.setElementInterior(self.cModelInstance, imports.tonumber(dummyData.interior) or 0)
    if cAsset.syncedData.collisionID then
        self.cCollisionInstance = imports.createObject(cAsset.syncedData.collisionID, dummyData.position.x, dummyData.position.y, dummyData.position.z, dummyData.rotation.x, dummyData.rotation.y, dummyData.rotation.z)
        imports.setElementAlpha(self.cCollisionInstance, 0)
        self.cStreamer = streamer:create(self.cModelInstance, "dummy", {self.cCollisionInstance})
    end
    dummy.buffer[(self.cModelInstance)] = self
    return self.cModelInstance
end

function dummy:unload()
    if not self or (self == dummy) then return false end
    if self.cStreamer then
        self.cStreamer:destroy()
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