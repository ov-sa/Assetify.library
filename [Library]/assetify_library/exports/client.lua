----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: exports: client.lua
     Author: vStudio
     Developer(s): Aviril, Tron
     DOC: 19/10/2021
     Desc: Client Sided Exports ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    isElement = isElement,
    triggerEvent = triggerEvent
}


-------------------------
--[[ Functions: APIs ]]--
-------------------------

function isLibraryLoaded()
    return syncer.isLibraryLoaded
end

function createShader(...)
    local cShader = shader:create(...)
    return cShader
end

function getAssetID(...)
    return manager:getID(...)
end

function isAssetLoaded(...)
    return manager:isLoaded(...)
end

function getAssetDep(...)
    return manager:getDep(...)
end

function loadAsset(assetType, assetName, ...)
    local state = manager:load(assetType, assetName, ...)
    if state then
        imports.triggerEvent("onAssetLoad", localPlayer, assetType, assetName)
    end
    return state
end

function unloadAsset(assetType, assetName, ...)
    local state = manager:unload(assetType, assetName, ...)
    if state then
        imports.triggerEvent("onAssetUnLoad", localPlayer, assetType, assetName)
    end
    return state
end

function loadAnim(element, ...)
    if not element or not imports.isElement(element) then return false end
    return manager:loadAnim(element, ...)
end

function unloadAnim(element, ...)
    if not element or not imports.isElement(element) then return false end
    return manager:unloadAnim(element, ...)
end

function playSoundAsset(...)
    return manager:playSound(...)
end

function playSoundAsset3D(...)
    return manager:playSound3D(...)
end

function createAssetDummy(...)
    local cDummy = dummy:create(...)
    return (cDummy and cDummy.cDummy) or false
end