----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: exports: client.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Client Sided Exports ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    isElement = isElement,
    getElementType = getElementType
}


---------------------------------
--[[ Functions: Asset's APIs ]]--
---------------------------------

function getAssetData(...)

    return manager:getData(...)

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


-------------------------------------
--[[ Functions: Replication APIs ]]--
-------------------------------------

function setCharacter(ped, characterName)

    if not ped or not imports.isElement(ped) then return false end
    local elementType = imports.getElementType(ped)
    if (elementType ~= "ped") and (elementType ~= "player") or not availableAssetPacks["characters"][assetName] then return false end
    syncer.syncedElements[ped] = assetName
    return true
    syncer.syncModel(ped, "character", characterName)

end