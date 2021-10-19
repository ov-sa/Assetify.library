----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: weaponLoader.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Weapon Loader ]]--
----------------------------------------------------------------


-------------------
--[[ Variables ]]--
-------------------

local loadedClientWeapons = {
    modelIDs = {},
    models = {txd = {}, dff = {}, col = {}}
}


-----------------------------------------
--[[ Function: Retrieves Weapon's ID ]]--
-----------------------------------------

function _getWeaponID(weaponType)

    if not weaponType or not serverWeapons[weaponType] or not loadedClientWeapons.modelIDs[weaponType] then return false end

    return loadedClientWeapons.modelIDs[weaponType]

end


-----------------------------------------
--[[ Event: On Client Resource Start ]]--
-----------------------------------------

addEventHandler("onClientResourceStart", resource, function()

    for i, j in pairs(serverWeapons) do
        local generatedModelID = engineRequestModel("object")
        if generatedModelID then
            local weaponType = i
            local weaponTXDPath = ":mod_loader/files/weapons/"..weaponType.."/weapon.txd"
            local weaponDFFPath = ":mod_loader/files/weapons/"..weaponType.."/weapon.dff"
            local weaponCOLPath = ":mod_loader/files/weapons/"..weaponType.."/weapon.col"
            if weaponTXDPath and File.exists(weaponTXDPath) then
                if not loadedClientWeapons.models.txd[weaponTXDPath] then
                    loadedClientWeapons.models.txd[weaponTXDPath] = EngineTXD(weaponTXDPath)
                end
                if loadedClientWeapons.models.txd[weaponTXDPath] and isElement(loadedClientWeapons.models.txd[weaponTXDPath]) then
                    loadedClientWeapons.models.txd[weaponTXDPath]:import(generatedModelID)
                end
            end
            if weaponDFFPath and File.exists(weaponDFFPath) then
                if not loadedClientWeapons.models.dff[weaponDFFPath] then
                    loadedClientWeapons.models.dff[weaponDFFPath] = EngineDFF(weaponDFFPath)
                end
                if loadedClientWeapons.models.dff[weaponDFFPath] and isElement(loadedClientWeapons.models.dff[weaponDFFPath]) then
                    loadedClientWeapons.models.dff[weaponDFFPath]:replace(generatedModelID)
                end
            end
            if weaponCOLPath and File.exists(weaponCOLPath) then
                if not loadedClientWeapons.models.col[weaponCOLPath] then
                    loadedClientWeapons.models.col[weaponCOLPath] = EngineCOL(weaponCOLPath)
                end
                if loadedClientWeapons.models.col[weaponCOLPath] and isElement(loadedClientWeapons.models.col[weaponCOLPath]) then
                    loadedClientWeapons.models.col[weaponCOLPath]:replace(generatedModelID)
                end
            end
            loadedClientWeapons.modelIDs[weaponType] = generatedModelID
        end
    end

end)