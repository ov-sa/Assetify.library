----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: engine: bone.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Bone Utilities ]]--
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
    setElementMatrix = setElementMatrix,
    setElementPosition = setElementPosition,
    getElementRotation = getElementRotation,
    getElementBoneMatrix = getElementBoneMatrix,
    setElementCollisionsEnabled = setElementCollisionsEnabled
}


---------------------
--[[ Class: Bone ]]--
---------------------

local bone = class:create("bone", {
    ids = {
        ped = {1, 2, 3, 4, 5, 6, 7, 8, 21, 22, 23, 24, 25, 26, 31, 32, 33, 34, 35, 36, 41, 42, 43, 44, 51, 52, 53, 54},
        vehicle = {}
    },
    buffer = {
        element = {},
        parent = {}
    }
})
for i, j in imports.pairs(bone.public.ids) do
    local indexes = {}
    for k = 1, #j, 1 do indexes[(j[k])] = true end
    bone.public.ids[i] = indexes
    indexes = nil
end

function bone.private:fetchInstance(element)
    return (element and bone.public.buffer.element[element]) or false
end

function bone.private:validateOffset(instance, boneData)
    if not bone.public:isInstance(instance) then return false end
    boneData.position, boneData.rotation = boneData.position or {}, boneData.rotation or {}
    boneData.position.x, boneData.position.y, boneData.position.z = imports.tonumber(boneData.position.x) or 0, imports.tonumber(boneData.position.y) or 0, imports.tonumber(boneData.position.z) or 0
    boneData.rotation.x, boneData.rotation.y, boneData.rotation.z = imports.tonumber(boneData.rotation.x) or 0, imports.tonumber(boneData.rotation.y) or 0, imports.tonumber(boneData.rotation.z) or 0
    if boneData.rotation.isRelative then
        local rotationData = (instance.boneData and instance.boneData.rotation) or false
        if not rotationData then
            local rotX, rotY, rotZ = {imports.getElementRotation(instance.element, "ZYX")}
            rotationData = {x = rotX, y = rotY, z = rotZ}
        end
        local rotQuat = math.quat:fromEuler(rotationData.x, rotationData.y, rotationData.z)
        local xQuat, yQuat, zQuat = math.quat:fromAxisAngle(1, 0, 0, boneData.rotation.x), math.quat:fromAxisAngle(0, 1, 0, boneData.rotation.y), math.quat:fromAxisAngle(0, 0, 1, boneData.rotation.z)
        local __rotQuat = xQuat*yQuat*zQuat
        rotQuat = __rotQuat*rotQuat
        boneData.rotation.x, boneData.rotation.y, boneData.rotation.z = rotQuat:toEuler()
        rotQuat:destroy(); xQuat:destroy(); yQuat:destroy(); zQuat:destroy()
        boneData.rotation.isRelative = false
    end
    boneData.rotationMatrix = math.matrix.fromRotation(boneData.rotation.x, boneData.rotation.y, boneData.rotation.z)
    return true
end

function bone.public:create(...)
    local cBone = self:createInstance()
    if cBone and not cBone:load(...) then
        cBone:destroyInstance()
        return false
    end
    return cBone
end

function bone.public:destroy(...)
    if not bone.public:isInstance(self) then return false end
    return self:unload(...)
end

function bone.public:clearElementBuffer(element)
    local cBone = bone.private:fetchInstance(element)
    if cBone then cBone:destroy() end
    if bone.public.buffer.parent[element] then
        for i, j in imports.pairs(bone.public.buffer.parent[element]) do
            i:destroy()
        end
    end
    bone.public.buffer.parent[element] = nil
    return true
end

if localPlayer then
    bone.public.cache = {
        element = {}
    }

    function bone.public:load(element, parent, boneData, remoteSignature)
        if not bone.public:isInstance(self) then return false end
        if not element or not parent or (not remoteSignature and (not imports.isElement(element) or not imports.isElement(parent))) or not boneData or (element == parent) or bone.public.buffer.element[element] then return false end
        self.element, self.parent = element, parent
        if not self:refresh(boneData, remoteSignature) then return false end
        self.cHeartbeat = thread:createHeartbeat(function()
            return not imports.isElement(element)
        end, function()
            imports.setElementCollisionsEnabled(element, false)
            self.cStreamer = streamer:create(element, "bone", {parent}, self.boneData.syncRate)
            self.cHeartbeat = nil
        end, settings.downloader.buildRate)
        bone.public.buffer.element[element] = self
        bone.public.buffer.parent[parent] = bone.public.buffer.parent[parent] or {}
        bone.public.buffer.parent[parent][self] = true
        return true
    end

    function bone.public:unload()
        if not bone.public:isInstance(self) then return false end
        if self.cHeartbeat then self.cHeartbeat:destroy() end
        if self.cStreamer then self.cStreamer:destroy() end
        bone.public.cache.element[(self.element)] = nil
        bone.public.buffer.element[(self.element)] = nil
        self:destroyInstance()
        return true
    end

    function bone.public:refresh(boneData, remoteSignature)
        if not bone.public:isInstance(self) then return false end
        self.parentType = self.parentType or (remoteSignature and remoteSignature.parentType) or imports.getElementType(self.parent)
        self.parentType = ((self.parentType == "player") and "ped") or self.parentType
        if not self.parentType or not bone.public.ids[(self.parentType)] then return false end
        boneData.id = imports.tonumber(boneData.id)
        if not boneData.id or not bone.public.ids[(self.parentType)][(boneData.id)] then return false end
        bone.private:validateOffset(self, boneData)
        boneData.syncRate = imports.tonumber(boneData.syncRate) or settings.streamer.boneSyncRate
        local isSyncRateModified = self.boneData and (self.boneData.syncRate ~= boneData.syncRate)
        self.boneData = boneData
        if isSyncRateModified then
            self.cStreamer.syncRate = self.boneData.syncRate
            self.cStreamer:deallocate()
            self.cStreamer:allocate()
        end
        return true
    end

    function bone.public:update()
        if not bone.public:isInstance(self) or self.cHeartbeat then return false end
        bone.public.cache.element[(self.parent)] = bone.public.cache.element[(self.parent)] or {}
        bone.public.cache.element[(self.parent)][(self.boneData.id)] = ((bone.public.cache.element[(self.parent)].streamTick == bone.public.cache.streamTick) and bone.public.cache.element[(self.parent)][(self.boneData.id)]) or imports.getElementBoneMatrix(self.parent, self.boneData.id)
        bone.public.cache.element[(self.parent)].streamTick = bone.public.cache.streamTick
        imports.setElementMatrix(self.element, math.matrix.transform(bone.public.cache.element[(self.parent)][(self.boneData.id)], self.boneData.rotationMatrix, self.boneData.position.x, self.boneData.position.y, self.boneData.position.z))
        return true
    end
else
    function bone.public:load(element, parent, boneData, targetPlayer)
        if not bone.public:isInstance(self) or self.isUnloading then return false end
        if targetPlayer then return network:emit("Assetify:Bone:onAttachment", true, false, targetPlayer, self.element, self.parent, self.boneData, self.remoteSignature) end
        if not element or not parent or not imports.isElement(element) or not imports.isElement(parent) or not boneData or (element == parent) or bone.public.buffer.element[element] then return false end
        self.element, self.parent = element, parent
        if not self:refresh(boneData, _, true) then return false end
        self.remoteSignature = {
            parentType = imports.getElementType(parent),
            elementType = imports.getElementType(element)
        }
        bone.public.buffer.element[element] = self
        bone.public.buffer.parent[parent] = bone.public.buffer.parent[parent] or {}
        bone.public.buffer.parent[parent][self] = true
        thread:create(function(__self)
            for i, j in imports.pairs(syncer.public.loadedClients) do
                self:load(_, _, _, i)
                thread:pause()
            end
        end):resume({executions = settings.downloader.syncRate, frames = 1})
        return true
    end

    function bone.public:unload(targetPlayer)
        if not bone.public:isInstance(self) then return false end
        if targetPlayer then return network:emit("Assetify:Bone:onDetachment", true, false, targetPlayer, self.element) end
        if self.isUnloading then return false end
        self.isUnloading = true
        thread:create(function(__self)
            for i, j in imports.pairs(syncer.public.loadedClients) do
                self:unload(i)
                thread:pause()
            end
            bone.public.buffer.element[(self.element)] = nil
            self:destroyInstance()
        end):resume({executions = settings.downloader.syncRate, frames = 1})
        return true
    end

    function bone.public:refresh(boneData, targetPlayer, skipSync)
        if not bone.public:isInstance(self) or self.isUnloading then return false end
        if targetPlayer and not skipSync then return network:emit("Assetify:Bone:onRefreshment", true, false, targetPlayer, self.element, self.boneData, self.remoteSignature) end
        self.parentType = self.parentType or imports.getElementType(self.parent)
        self.parentType = ((self.parentType == "player") and "ped") or self.parentType
        if not self.parentType or not bone.public.ids[(self.parentType)] then return false end
        boneData.id = imports.tonumber(boneData.id)
        if not boneData.id or not bone.public.ids[(self.parentType)][(boneData.id)] then return false end
        bone.private:validateOffset(self, boneData)
        boneData.syncRate = imports.tonumber(boneData.syncRate) or settings.streamer.boneSyncRate
        self.boneData = boneData
        if not skipSync then
            thread:create(function(__self)
                for i, j in imports.pairs(syncer.public.loadedClients) do
                    self:refresh(_, i)
                    thread:pause()
                end
            end):resume({executions = settings.downloader.syncRate, frames = 1})
        end
        return true
    end
end


---------------------
--[[ API Syncers ]]--
---------------------

function syncer.public:syncBoneAttachment(length, ...) return bone.public:create(table:unpack(table:pack(...), length or 3)) end
function syncer.public:syncBoneDetachment(length, element) local cBone = bone.private:fetchInstance(element); if not cBone then return false end; return cBone:destroy() end
function syncer.public:syncBoneRefreshment(length, element, ...) local cBone = bone.private:fetchInstance(element); if not cBone then return false end; return cBone:refresh(table:unpack(table:pack(...), length or 1)) end
function syncer.public:syncClearBoneAttachment(length, ...) return bone.public:clearElementBuffer(...) end
if localPlayer then
    network:create("Assetify:Bone:onAttachment"):on(function(...) syncer.public:syncBoneAttachment(4, ...) end)
    network:create("Assetify:Bone:onDetachment"):on(function(...) syncer.public:syncBoneDetachment(_, ...) end)
    network:create("Assetify:Bone:onRefreshment"):on(function(...) syncer.public:syncBoneRefreshment(2, ...) end)
    network:create("Assetify:Bone:onClearAttachment"):on(function(...) syncer.public:syncClearBoneAttachment(_, ...) end)
else
    network:fetch("Assetify:Downloader:onSyncPostPool"):on(function(self, source)
        self:resume({executions = settings.downloader.syncRate, frames = 1})
        for i, j in imports.pairs(bone.public.buffer.element) do
            if j and not j.isUnloading then network:emit("Assetify:Bone:onAttachment", true, false, source, self.element, self.parent, self.boneData, self.remoteSignature) end
            thread:pause()
        end
    end, true)
end
network:fetch("Assetify:onElementDestroy"):on(function(source)
    if not syncer.public.isLibraryBooted or not source then return false end
    bone.public:clearElementBuffer(source)
end)