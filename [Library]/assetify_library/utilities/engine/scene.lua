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
    tonumber = tonumber,
    loadstring = loadstring,
    addEventHandler = addEventHandler,
    destroyElement = destroyElement,
    createObject = createObject,
    createBuilding = createBuilding,
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
scene.private.native = {
    buffer = imports.loadstring(file:read("utilities/rw/native/buffer.rw"))(),
    buffer_lod = imports.loadstring(file:read("utilities/rw/native/buffer_lod.rw"))()
}

function scene.private:fetchNativeID(modelName)
    return scene.private.native.buffer[modelName] or false
end

function scene.private:fetchNativeLOD(modelName)
    return scene.private.native.buffer_lod[modelName] or false
end

function scene.private:createEntity(...)
    local cArgs = table.pack(...)
    return ((cArgs[9] and imports.createBuilding) or imports.createObject)(table.unpack(cArgs, (cArgs[9] and 7) or 8))
end

function scene.public:parseIDE(rw)
    rw = (rw and string.split(rw, "\n")) or rw
    if not rw then return false end
    local result = {}
    for i = 1, table.length(rw), 1 do
        local data = string.split(rw[i], ",")
        for k = 1, table.length(data), 1 do
            data[k] = string.gsub(data[k], "%s", "")
        end
        if data[2] then
            result[(data[2])] = {
                data[3] or false,
                imports.tonumber(data[4])
            }
        end
    end
    return result
end

function scene.public:parseIPL(rw, isNativeModelsEnabled)
    rw = (rw and string.split(rw, "\n")) or rw
    if not rw then return false end
    local result = {}
    for i = 1, table.length(rw), 1 do
        local data = string.split(rw[i], ",")
        for k = 1, table.length(data), 1 do
            data[k] = string.gsub(data[k], "%s", "")
        end
        if data[2] then
            local validated = true
            for k = 4, 10, 1 do
                data[k] = imports.tonumber(data[k])
                if not data[k] then
                    validated = false
                    break
                end
            end
            if validated then
                data.nativeID = (isNativeModelsEnabled and scene.private:fetchNativeID(data[2])) or nil
                data.nativeLOD = (data.nativeID and scene.private:fetchNativeLOD(data[2])) or nil
                table.insert(result, data)
            end
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

    function scene.public:load(cAsset, sceneManifest, sceneData)
        if not scene.public:isInstance(self) then return false end
        if not cAsset or (not cAsset.nativeID and not cAsset.synced) or not sceneManifest or not sceneData then return false end
        local posX, posY, posZ, rotX, rotY, rotZ = sceneData.position.x + ((sceneManifest.sceneOffsets and sceneManifest.sceneOffsets.x) or 0), sceneData.position.y + ((sceneManifest.sceneOffsets and sceneManifest.sceneOffsets.y) or 0), sceneData.position.z + ((sceneManifest.sceneOffsets and sceneManifest.sceneOffsets.z) or 0), sceneData.rotation.x, sceneData.rotation.y, sceneData.rotation.z
        self.cModelInstance = scene.private:createEntity(cAsset.nativeID or cAsset.synced.modelID, posX, posY, posZ, rotX, rotY, rotZ, false, sceneManifest.sceneBuildings)
        if not self.cModelInstance then return false end
        imports.setElementDoubleSided(self.cModelInstance, sceneManifest.sceneDoublesided)
        imports.setElementDimension(self.cModelInstance, sceneManifest.sceneDimension)
        imports.setElementInterior(self.cModelInstance, sceneManifest.sceneInterior)
        self.cLODInstance = sceneManifest.sceneLODs and (
            (cAsset.nativeID and scene.private:createEntity(cAsset.nativeLOD or cAsset.nativeID, posX, posY, posZ, rotX, rotY, rotZ, true, false)) or 
            (not cAsset.nativeID and scene.private:createEntity(cAsset.synced.lodID or cAsset.synced.modelID, posX, posY, posZ, rotX, rotY, rotZ, true, false))
        ) or false
        if self.cLODInstance then
            imports.setElementDoubleSided(self.cLODInstance, sceneManifest.sceneDoublesided)
            imports.setElementDimension(self.cLODInstance, sceneManifest.sceneDimension)
            imports.setElementInterior(self.cLODInstance, sceneManifest.sceneInterior)
            imports.setLowLODElement(self.cModelInstance, self.cLODInstance)
            attacher:attachElements(self.cLODInstance, self.cModelInstance)
        end
        cAsset.cScenes = cAsset.cScenes or {}
        cAsset.cScenes[self] = true
        return true
    end

    function scene.public:unload()
        if not scene.public:isInstance(self) then return false end
        imports.destroyElement(self.cModelInstance)
        imports.destroyElement(self.cLODInstance)
        self:destroyInstance()
        return true
    end
end