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
    pairs = pairs
}


----------------------
--[[ Class: Scene ]]--
----------------------

scene = {
    loadedScenes = {}
}
scene.__index = scene

function scene:create(assetName)

    local cState, cAsset = isAssetLoaded("scene", assetName)
    if not cState or not cAsset then return false end

    local cScene = imports.setmetatable({}, {__index = self})
    cScene.cAsset = cAsset
    if not cScene:load() then
        cScene = nil
        return false
    end
    scene.loadedScenes[assetName] = cScene
    return cScene

end

function scene:load(callback)

    if not self or (self == scene) then return false end

    --[[
    local loadState = false
    if callback and imports.type(callback) == "function" then
        callback(loadState)
    end
    return loadState]]

end

--[[
function scene:unload(callback)

    if not self or (self == scene) then return false end
    if not callback or (imports.type(callback) ~= "function") then return false end

    imports.engineFreeModel(self.syncedData.modelID)
    if self.unsyncedData.primary_rwFiles then
        for i, j in imports.pairs(self.unsyncedData.primary_rwFiles) do
            if j and imports.isElement(j) then
                imports.destroyElement(j)
            end
        end
    end
    if self.unsyncedData.secondary_rwFiles then
        for i, j in imports.pairs(self.unsyncedData.secondary_rwFiles) do
            if j and imports.isElement(j) then
                imports.destroyElement(j)
            end
        end
    end
    self.cData.cScene = nil
    self = nil
    imports.collectgarbage()
    callback(true)
    return true

end
]]