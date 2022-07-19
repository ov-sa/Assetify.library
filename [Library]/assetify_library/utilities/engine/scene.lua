----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: engine: scene.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Scene Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    destroyElement = destroyElement,
    createObject = createObject,
    setElementAlpha = setElementAlpha,
    setElementDoubleSided = setElementDoubleSided,
    setElementCollisionsEnabled = setElementCollisionsEnabled,
    setLowLODElement = setLowLODElement,
    setElementDimension = setElementDimension,
    setElementInterior = setElementInterior
}


----------------------
--[[ Class: Scene ]]--
----------------------

local scene = class:create("scene")
scene.private.separators = {IPL = ", ", IDE = ", "}
scene.private.native = {
    buffer = loadstring(file:read("utilities/rw/native/buffer.rw"))(),
    buffer_lod = loadstring(file:read("utilities/rw/native/buffer_lod.rw"))()
}

function scene.private:fetchNativeID(modelName)
    return scene.private.native.buffer[modelName] or false
end

function scene.private:fetchNativeLOD(modelName)
    return scene.private.native.buffer_lod[modelName] or false
end

function scene.public:parseIDE(rw)
    rw = (rw and string.split(rw, "\n")) or rw
    if not rw then return false end
    local result = {}
    for i = 1, #rw, 1 do
        local data = string.split(rw[i], scene.private.separators.IDE)
        data[2] = (data[2] and string.gsub(data[2], "%s", "")) or data[2]
        if data[2] then
            result[(data[2])] = {
                (data[3] and string.gsub(data[3], "%s", "")) or false
            }
        end
    end
    return result
end

function scene.public:parseIPL(rw, isNativeModelsEnabled)
    rw = (rw and string.split(rw, "\n")) or rw
    if not rw then return false end
    local result = {}
    for i = 1, #rw, 1 do
        local data = string.split(rw[i], scene.private.separators.IPL)
        data[2] = (data[2] and string.gsub(data[2], "%s", "")) or data[2]
        if data[2] then
            data.nativeID = (isNativeModelsEnabled and scene.private:fetchNativeID(data[2])) or nil
            data.nativeLOD = (data.nativeID and scene.private:fetchNativeLOD(data[2])) or nil
            table.insert(result, data)
        end
    end
    return result
end

if localPlayer then
    function scene.public:create(...)
        local cScene = self:createInstance()
        if cScene and not cScene:load(...) then
            cScene:destroyInstance()
            return false
        end
        return cScene
    end

    function scene.public:destroy(...)
        if not scene.public:isInstance(self) then return false end
        return self:unload(...)
    end

    function scene.public:load(cAsset, sceneManifest, sceneData, nativeID, nativeLOD)
        if not scene.public:isInstance(self) then return false end
        if not sceneManifest or not sceneData or (not nativeID and (not cAsset or not cAsset.synced)) then return false end
        local posX, posY, posZ, rotX, rotY, rotZ = sceneData.position.x + ((sceneManifest.sceneOffsets and sceneManifest.sceneOffsets.x) or 0), sceneData.position.y + ((sceneManifest.sceneOffsets and sceneManifest.sceneOffsets.y) or 0), sceneData.position.z + ((sceneManifest.sceneOffsets and sceneManifest.sceneOffsets.z) or 0), sceneData.rotation.x, sceneData.rotation.y, sceneData.rotation.z
        self.cStreamerInstance = imports.createObject(nativeID or cAsset.synced.modelID, posX, posY, posZ, rotX, rotY, rotZ, (sceneManifest.enableLODs and not nativeID and not cAsset.synced.lodID and cAsset.synced.collisionID and true) or false) or false
        if not self.cStreamerInstance then return false end
        imports.setElementDoubleSided(self.cStreamerInstance, true)
        if not nativeID then
            imports.setElementCollisionsEnabled(self.cStreamerInstance, false)
            self.cCollisionInstance = (cAsset.synced.collisionID and imports.createObject(cAsset.synced.collisionID, posX, posY, posZ, rotX, rotY, rotZ)) or false
            if self.cCollisionInstance then
                imports.setElementAlpha(self.cCollisionInstance, 0)
                imports.setElementDimension(self.cCollisionInstance, sceneManifest.sceneDimension)
                imports.setElementInterior(self.cCollisionInstance, sceneManifest.sceneInterior)
                if sceneManifest.enableLODs then
                    self.cModelInstance = imports.createObject(cAsset.synced.collisionID, posX, posY, posZ, rotX, rotY, rotZ, true) or false
                    self.cLODInstance = (cAsset.synced.lodID and imports.createObject(cAsset.synced.lodID, posX, posY, posZ, rotX, rotY, rotZ, true)) or false
                    attacher:attachElements(self.cModelInstance, self.cCollisionInstance)
                    imports.setElementAlpha(self.cModelInstance, 0)
                    imports.setElementDimension(self.cModelInstance, sceneManifest.sceneDimension)
                    imports.setElementInterior(self.cModelInstance, sceneManifest.sceneInterior)
                    if self.cLODInstance then
                        imports.setElementDoubleSided(self.cLODInstance, true)
                        imports.setLowLODElement(self.cStreamerInstance, self.cLODInstance)
                        attacher:attachElements(self.cLODInstance, self.cCollisionInstance)
                        imports.setElementDimension(self.cLODInstance, sceneManifest.sceneDimension)
                        imports.setElementInterior(self.cLODInstance, sceneManifest.sceneInterior)
                    end
                    self.cStreamer = streamer:create(self.cStreamerInstance, "scene", {self.cCollisionInstance, self.cModelInstance})
                else
                    self.cStreamer = streamer:create(self.cStreamerInstance, "scene", {self.cCollisionInstance})
                end
            end
        else
            self.cLODInstance = (sceneManifest.enableLODs and imports.createObject(nativeLOD or nativeID, posX, posY, posZ, rotX, rotY, rotZ, true)) or false
            self.cCollisionInstance = self.cStreamerInstance
            if self.cLODInstance then
                imports.setElementDoubleSided(self.cLODInstance, true)
                imports.setLowLODElement(self.cStreamerInstance, self.cLODInstance)
                attacher:attachElements(self.cLODInstance, self.cStreamerInstance)
                imports.setElementDimension(self.cLODInstance, sceneManifest.sceneDimension)
                imports.setElementInterior(self.cLODInstance, sceneManifest.sceneInterior)
            end
        end
        self.cModelInstance = (self.cModelInstance or self.cStreamerInstance) or false
        self.cLODInstance = self.cLODInstance or false
        self.cCollisionInstance = self.cCollisionInstance or false
        cAsset.cScenes = cAsset.cScenes or {}
        cAsset.cScenes[self] = true
        return true
    end

    function scene.public:unload()
        if not scene.public:isInstance(self) then return false end
        if self.cStreamer then self.cStreamer:destroy() end
        imports.destroyElement(self.cStreamerInstance)
        imports.destroyElement(self.cModelInstance)
        imports.destroyElement(self.cLODInstance)
        imports.destroyElement(self.cCollisionInstance)
        self:destroyInstance()
        return true
    end
end