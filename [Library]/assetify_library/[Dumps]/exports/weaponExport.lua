----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: exports: weaponExport.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Weapon Exports ]]--
----------------------------------------------------------------


-----------------------------------------
--[[ Function: Retrieves Weapon's ID ]]--
-----------------------------------------

function getWeaponID(...)

    return _getWeaponID(unpack({...}))

end