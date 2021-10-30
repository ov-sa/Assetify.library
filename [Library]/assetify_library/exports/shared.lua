----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: exports: shared.lua
     Server: -
     Author: OvileAmriam
     Developer(s): Aviril, Tron
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Shared Exports ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    isElement = isElement,
    getElementType = getElementType
}


--------------------------------
--[[ Functions: Entity APIs ]]--
--------------------------------

function setCharacterAsset(ped, ...)

    if not ped or not imports.isElement(ped) then return false end
    local elementType = imports.getElementType(ped)
    if (elementType ~= "ped") and (elementType ~= "player") then return false end

    return syncer:syncElementModel(ped, "character", ...)

end

function setVehicleAsset(vehicle, ...)

    if not vehicle or not imports.isElement(vehicle) or (imports.getElementType(vehicle) ~= "vehicle") then return false end

    return syncer:syncElementModel(vehicle, "vehicle", ...)

end