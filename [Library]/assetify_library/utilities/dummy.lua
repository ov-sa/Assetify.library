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
    createPed = createPed,
    createVehicle = createVehicle,
    setElementModel = setElementModel,
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

if localPlayer then
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
        if not element or not imports.isElement(element) or not dummy.buffer[element] then return false end
        dummy.buffer[element]:destroy()
        return true
    end

    function dummy:load(assetType, assetName, assetClump, clumpMaps, dummyData, targetDummy)
        if not self or (self == dummy) then return false end
        if not dummyData then return false end
        targetDummy = (targetDummy and imports.isElement(targetDummy) and targetDummy) or false
        local cAsset, cData = manager:getData(assetType, assetName, syncer.librarySerial)
        if not cAsset or (cAsset.manifestData.assetClumps and (not assetClump or not cAsset.manifestData.assetClumps[assetClump])) then return false end
        if assetClump then cData = cAsset.unSynced.assetCache[assetClump].cAsset.synced end
        if not cAsset or not cData then return false end
        local dummyType = availableAssetPacks[assetType].assetType
        if not dummyType then return false end
        if not targetDummy then
            dummyData.position, dummyData.rotation = dummyData.position or {}, dummyData.rotation or {}
            dummyData.position.x, dummyData.position.y, dummyData.position.z = imports.tonumber(dummyData.position.x) or 0, imports.tonumber(dummyData.position.y) or 0, imports.tonumber(dummyData.position.z) or 0
            dummyData.rotation.x, dummyData.rotation.y, dummyData.rotation.z = imports.tonumber(dummyData.rotation.x) or 0, imports.tonumber(dummyData.rotation.y) or 0, imports.tonumber(dummyData.rotation.z) or 0
        end
        self.assetType, self.assetName = assetType, assetName
        self.syncRate = imports.tonumber(dummyData.syncRate)
        if dummyType == "object" then
            self.cModelInstance = targetDummy or imports.createObject(cData.modelID, dummyData.position.x, dummyData.position.y, dummyData.position.z, dummyData.rotation.x, dummyData.rotation.y, dummyData.rotation.z)
            imports.setElementDoubleSided(self.cModelInstance, true)
            network:emit("Assetify:onRecieveElementModel", false, self.cModelInstance, assetType, assetName, assetClump, clumpMaps)
            if cData.collisionID then
                self.cCollisionInstance = imports.createObject(cData.collisionID, dummyData.position.x, dummyData.position.y, dummyData.position.z, dummyData.rotation.x, dummyData.rotation.y, dummyData.rotation.z)
            end
        elseif dummyType == "ped" then
            self.cModelInstance = targetDummy or imports.createPed(cData.modelID, dummyData.position.x, dummyData.position.y, dummyData.position.z, dummyData.rotation.z)
            if cData.collisionID then
                self.cCollisionInstance = imports.createPed(cData.collisionID, dummyData.position.x, dummyData.position.y, dummyData.position.z, dummyData.rotation.z)
            end
        elseif dummyType == "vehicle" then
            self.cModelInstance = targetDummy or imports.createVehicle(cData.modelID, dummyData.position.x, dummyData.position.y, dummyData.position.z, dummyData.rotation.x, dummyData.rotation.y, dummyData.rotation.z)
            if cData.collisionID then
                self.cCollisionInstance = imports.createVehicle(cData.collisionID, dummyData.position.x, dummyData.position.y, dummyData.position.z, dummyData.rotation.x, dummyData.rotation.y, dummyData.rotation.z)
            end
        end
        if not self.cModelInstance then return false end
        if targetDummy then
            imports.setElementModel(self.cModelInstance, cData.modelID)
            imports.setElementAlpha(self.cModelInstance, 255)
        else
            imports.setElementDimension(self.cModelInstance, imports.tonumber(dummyData.dimension) or 0)
            imports.setElementInterior(self.cModelInstance, imports.tonumber(dummyData.interior) or 0)
        end
        if self.cCollisionInstance then
            imports.setElementAlpha(self.cCollisionInstance, 0)
            self.cStreamer = streamer:create(self.cModelInstance, "dummy", {self.cCollisionInstance}, self.syncRate)
        end
        self.cDummy = self.cCollisionInstance or self.cModelInstance
        dummy.buffer[(self.cDummy)] = self
        return true
    end

    function dummy:unload()
        if not self or (self == dummy) or self.isUnloading then return false end
        self.isUnloading = true
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
else
    function dummy:create(assetType, assetName, assetClump, clumpMaps, dummyData)
        local cAsset = manager:getData(assetType, assetName)
        if not cAsset or (cAsset.manifestData.assetClumps and (not assetClump or not cAsset.manifestData.assetClumps[assetClump])) then return false end
        local dummyType = availableAssetPacks[assetType].assetType
        if not dummyType then return false end
        local cDummy = false
        dummyData.position, dummyData.rotation = dummyData.position or {}, dummyData.rotation or {}
        dummyData.position.x, dummyData.position.y, dummyData.position.z = imports.tonumber(dummyData.position.x) or 0, imports.tonumber(dummyData.position.y) or 0, imports.tonumber(dummyData.position.z) or 0
        dummyData.rotation.x, dummyData.rotation.y, dummyData.rotation.z = imports.tonumber(dummyData.rotation.x) or 0, imports.tonumber(dummyData.rotation.y) or 0, imports.tonumber(dummyData.rotation.z) or 0
        if dummyType == "object" then
            cDummy = imports.createObject(availableAssetPacks[assetType].assetBase, dummyData.position.x, dummyData.position.y, dummyData.position.z, dummyData.rotation.x, dummyData.rotation.y, dummyData.rotation.z)
        elseif dummyType == "ped" then
            cDummy = imports.createPed(availableAssetPacks[assetType].assetBase, dummyData.position.x, dummyData.position.y, dummyData.position.z, dummyData.rotation.z)
        elseif dummyType == "vehicle" then
            cDummy = imports.createVehicle(availableAssetPacks[assetType].assetBase, dummyData.position.x, dummyData.position.y, dummyData.position.z, dummyData.rotation.x, dummyData.rotation.y, dummyData.rotation.z)
        end
        if not cDummy then return false end
        imports.setElementAlpha(cDummy, 0)
        imports.setElementDimension(cDummy, imports.tonumber(dummyData.dimension) or 0)
        imports.setElementInterior(cDummy, imports.tonumber(dummyData.interior) or 0)
        return cDummy
    end
end