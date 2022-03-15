----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: exports: client.lua
     Server: -
     Author: OvileAmriam
     Developer(s): Aviril, Tron
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Client Sided Exports ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    isElement = isElement,
    createObject = createObject,
    setElementDoubleSided = setElementDoubleSided
}


-------------------------
--[[ Functions: APIs ]]--
-------------------------

function isLibraryLoaded()
    return syncer.isLibraryLoaded
end

function getAssetData(...)
    return manager:getData(...)
end

function getAssetID(...)
    return manager:getID(...)
end

function isAssetLoaded(...)
    return manager:isLoaded(...)
end

function loadAsset(...)
    return manager:load(...)
end

function unloadAsset(...)
    return manager:unload(...)
end