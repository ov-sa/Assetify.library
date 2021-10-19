----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: weapon: client.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Weapon Handler ]]--
----------------------------------------------------------------


-----------------------------------------
--[[ Function: Retrieves Weapon's ID ]]--
-----------------------------------------

function _getWeaponID(weaponType)

    if not weaponType or not serverWeapons[weaponType] or not createdElements.modelIDs[weaponType] then return false end

    return createdElements.modelIDs[weaponType]

end