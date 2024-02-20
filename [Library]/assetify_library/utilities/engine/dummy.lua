----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: engine: dummy.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Dummy Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local syncer = syncer:import()
local imports = {
    pairs = pairs,
    tonumber = tonumber,
    isElement = isElement,
    getElementType = getElementType,
    destroyElement = destroyElement,
    createObject = createObject,
    createPed = createPed,
    createVehicle = createVehicle,
    setElementAlpha = setElementAlpha,
    setElementModel = setElementModel,
    setElementDoubleSided = setElementDoubleSided,
    setElementCollisionsEnabled = setElementCollisionsEnabled,
    setElementDimension = setElementDimension,
    setElementInterior = setElementInterior
}


----------------------
--[[ Class: Dummy ]]--
----------------------

local dummy = class:create("dummy", {
    buffer = {}
})

function dummy.public:fetchInstance(element)
    return (element and dummy.public.buffer[element]) or false
end

function dummy.private:validateOffset(instance, dummyData)
    if not dummy.public:isInstance(instance) then return false end
    dummyData.position, dummyData.rotation = dummyData.position or {}, dummyData.rotation or {}
    dummyData.position.x, dummyData.position.y, dummyData.position.z = imports.tonumber(dummyData.position.x) or 0, imports.tonumber(dummyData.position.y) or 0, imports.tonumber(dummyData.position.z) or 0
    dummyData.rotation.x, dummyData.rotation.y, dummyData.rotation.z = imports.tonumber(dummyData.rotation.x) or 0, imports.tonumber(dummyData.rotation.y) or 0, imports.tonumber(dummyData.rotation.z) or 0
    dummyData.dimension, dummyData.interior = imports.tonumber(dummyData.dimension) or 0, imports.tonumber(dummyData.interior) or 0
    return true
end

function dummy.public:create(...)
    local cDummy = self:createInstance()
    if cDummy and not cDummy:load(...) then
        cDummy:destroyInstance()
        return false
    end
    return cDummy
end

function dummy.public:destroy(...)
    if not dummy.public:isInstance(self) then return false end
    return self:unload(...)
end

function dummy.public.clearElementBuffer(element)
    local cDummy = dummy.public:fetchInstance(element)
    if not cDummy then return false end
    cDummy:destroy()
    return true
end

if localPlayer then
    function dummy.public:load(assetType, assetName, assetClump, clumpMaps, dummyData, isScoped, remoteSignature)
        if not dummy.public:isInstance(self) then return false end
        local cAsset, cData = manager:getAssetData(assetType, assetName, syncer.librarySerial)
        if not cAsset or not dummyData or (cAsset.manifestData.assetClumps and (not assetClump or not cAsset.manifestData.assetClumps[assetClump])) then return false end
        if assetClump then cData = cAsset.unSynced.assetCache[assetClump].cAsset.synced end
        if not cAsset or not cData then return false end
        local dummyType = settings.assetPacks[assetType].assetType
        if not dummyType then return false end
        dummy.private:validateOffset(self, dummyData)
        self.assetType, self.assetName, self.assetClump, self.clumpMaps = assetType, assetName, assetClump, clumpMaps
        self.dummyData = dummyData
        if remoteSignature then
            if cData.collisionID then
                self.cCollisionInstance = remoteSignature.element
            else
                self.cModelInstance = remoteSignature.element
            end
        end
        if dummyType == "object" then
            self.cModelInstance = self.cModelInstance or imports.createObject(cData.modelID, dummyData.position.x, dummyData.position.y, dummyData.position.z, dummyData.rotation.x, dummyData.rotation.y, dummyData.rotation.z) or false
            self.cCollisionInstance = self.cCollisionInstance or (cData.collisionID and imports.createObject(cData.collisionID, dummyData.position.x, dummyData.position.y, dummyData.position.z, dummyData.rotation.x, dummyData.rotation.y, dummyData.rotation.z)) or false
        elseif dummyType == "ped" then
            self.cModelInstance = self.cModelInstance or imports.createPed(cData.modelID, dummyData.position.x, dummyData.position.y, dummyData.position.z, dummyData.rotation.z) or false
            self.cCollisionInstance = self.cCollisionInstance or (cData.collisionID and imports.createPed(cData.collisionID, dummyData.position.x, dummyData.position.y, dummyData.position.z, dummyData.rotation.z)) or false
        elseif dummyType == "vehicle" then
            self.cModelInstance = self.cModelInstance or imports.createVehicle(cData.modelID, dummyData.position.x, dummyData.position.y, dummyData.position.z, dummyData.rotation.x, dummyData.rotation.y, dummyData.rotation.z) or false
            self.cCollisionInstance = self.cCollisionInstance or (cData.collisionID and imports.createVehicle(cData.collisionID, dummyData.position.x, dummyData.position.y, dummyData.position.z, dummyData.rotation.x, dummyData.rotation.y, dummyData.rotation.z)) or false
        end
        if not self.cModelInstance then return false end
        self.cDummy = (remoteSignature and remoteSignature.element) or self.cCollisionInstance or self.cModelInstance
        dummy.public.buffer[(self.cDummy)] = self
        if isScoped then manager:setElementScoped(self.cDummy) end
        self.cHeartbeat = thread:createHeartbeat(function()
            if not self.cModelInstance then
                return false
            else
                return not imports.isElement(self.cModelInstance)
            end
        end, function()
            if dummyType == "object" then imports.setElementDoubleSided(self.cModelInstance, true) end
            network:emit("Assetify:Syncer:onSyncElementModel", false, self.cModelInstance, assetType, assetName, assetClump, clumpMaps, remoteSignature)
            imports.setElementAlpha(self.cModelInstance, 255)
            imports.setElementDimension(self.cModelInstance, dummyData.dimension)
            imports.setElementInterior(self.cModelInstance, dummyData.interior)
            if self.cCollisionInstance then
                imports.setElementAlpha(self.cCollisionInstance, 0)
                imports.setElementModel(self.cCollisionInstance, cData.collisionID)
                imports.setElementDimension(self.cCollisionInstance, dummyData.dimension)
                imports.setElementInterior(self.cCollisionInstance, dummyData.interior)
                imports.setElementCollisionsEnabled(self.cModelInstance, false)
                self.cStreamer = streamer:create(self.cModelInstance, "dummy", {self.cCollisionInstance})
            end
            self.cHeartbeat = nil
        end, settings.downloader.buildRate)
        return true
    end

    function dummy.public:unload()
        if not dummy.public:isInstance(self) then return false end
        if self.cHeartbeat then self.cHeartbeat:destroy() end
        if self.cStreamer then self.cStreamer:destroy() end
        dummy.public.buffer[(self.cDummy)] = nil
        imports.destroyElement(self.cModelInstance)
        imports.destroyElement(self.cCollisionInstance)
        self:destroyInstance()
        return true
    end
else
    function dummy.public:load(assetType, assetName, assetClump, clumpMaps, dummyData, isScoped, targetPlayer)
        if not dummy.public:isInstance(self) or self.isUnloading then return false end
        if targetPlayer then return network:emit("Assetify:Dummy:onSpawn", true, false, targetPlayer, self.assetType, self.assetName, self.assetClump, self.clumpMaps, self.dummyData, _, self.remoteSignature) end
        local cAsset = manager:getAssetData(assetType, assetName)
        if not cAsset or not dummyData or (cAsset.manifestData.assetClumps and (not assetClump or not cAsset.manifestData.assetClumps[assetClump])) then return false end
        local dummyType = settings.assetPacks[assetType].assetType
        if not dummyType then return false end
        dummy.private:validateOffset(self, dummyData)
        self.assetType, self.assetName, self.assetClump, self.clumpMaps = assetType, assetName, assetClump, clumpMaps
        self.dummyData = dummyData
        if dummyType == "object" then
            self.cModelInstance = imports.createObject(settings.assetPacks[assetType].assetBase, dummyData.position.x, dummyData.position.y, dummyData.position.z, dummyData.rotation.x, dummyData.rotation.y, dummyData.rotation.z)
        elseif dummyType == "ped" then
            self.cModelInstance = imports.createPed(settings.assetPacks[assetType].assetBase, dummyData.position.x, dummyData.position.y, dummyData.position.z, dummyData.rotation.z)
        elseif dummyType == "vehicle" then
            self.cModelInstance = imports.createVehicle(settings.assetPacks[assetType].assetBase, dummyData.position.x, dummyData.position.y, dummyData.position.z, dummyData.rotation.x, dummyData.rotation.y, dummyData.rotation.z)
        end
        if not self.cModelInstance then return false end
        self.remoteSignature = {
            element = self.cModelInstance,
            elementType = dummyType
        }
        self.cDummy = self.cModelInstance
        dummy.public.buffer[(self.cDummy)] = self
        imports.setElementAlpha(self.cModelInstance, 0)
        imports.setElementDimension(self.cModelInstance, dummyData.dimension)
        imports.setElementInterior(self.cModelInstance, dummyData.interior)
        if isScoped then manager:setElementScoped(self.cDummy) end
        thread:create(function(__self)
            for i, j in imports.pairs(syncer.public.libraryClients.loaded) do
                self:load(_, _, _, _, _, _, i)
                thread:pause()
            end
        end):resume({executions = settings.downloader.syncRate, frames = 1})
        return true
    end

    function dummy.public:unload(targetPlayer)
        if not dummy.public:isInstance(self) then return false end
        if targetPlayer then return network:emit("Assetify:Dummy:onDespawn", true, false, targetPlayer, self.element) end
        if self.isUnloading then return false end
        self.isUnloading = true
        thread:create(function(__self)
            for i, j in imports.pairs(syncer.public.libraryClients.loaded) do
                self:unload(i)
                thread:pause()
            end
            dummy.public.buffer[(self.cDummy)] = nil
            imports.destroyElement(self.cModelInstance)
            self:destroyInstance()
        end):resume({executions = settings.downloader.syncRate, frames = 1})
        return true
    end
end


---------------------
--[[ API Syncers ]]--
---------------------

function syncer.public.syncDummySpawn(length, ...) return dummy.public:create(table.unpack(table.pack(...), length or 6)) end
function syncer.public.syncDummyDespawn(length, element) local cDummy = dummy.public:fetchInstance(element); if not cDummy then return false end; return cDummy:destroy() end
if localPlayer then
    network:create("Assetify:Dummy:onSpawn"):on(function(...) syncer.public.syncDummySpawn(7, ...) end)
    network:create("Assetify:Dummy:onDespawn"):on(function(...) syncer.public.syncDummySpawn(_, ...) end)
else
    network:fetch("Assetify:Syncer:onSyncPostPool"):on(function(self, source)
        self:resume({executions = settings.downloader.syncRate, frames = 1})
        for i, j in imports.pairs(dummy.public.buffer) do
            if j and not j.isUnloading then network:emit("Assetify:Dummy:onSpawn", true, false, source, j.assetType, j.assetName, j.assetClump, j.clumpMaps, j.dummyData, _, j.remoteSignature) end
            thread:pause()
        end
    end, {isAsync = true})
end
network:fetch("Assetify:onElementDestroy"):on(function(source)
    if not syncer.public.isLibraryBooted or not source then return false end
    dummy.public.clearElementBuffer(source)
end)