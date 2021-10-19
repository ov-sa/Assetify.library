----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: weapon: client.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Weapon Handler ]]--
----------------------------------------------------------------


-------------------
--[[ Variables ]]--
-------------------

local createdElements = {
    modelIDs = {},
    models = {txd = {}, dff = {}, col = {}}
}


-----------------------------------------
--[[ Function: Retrieves Weapon's ID ]]--
-----------------------------------------

function _getWeaponID(weaponType)

    if not weaponType or not serverWeapons[weaponType] or not createdElements.modelIDs[weaponType] then return false end

    return createdElements.modelIDs[weaponType]

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
                if not createdElements.models.txd[weaponTXDPath] then
                    createdElements.models.txd[weaponTXDPath] = EngineTXD(weaponTXDPath)
                end
                if createdElements.models.txd[weaponTXDPath] and isElement(createdElements.models.txd[weaponTXDPath]) then
                    createdElements.models.txd[weaponTXDPath]:import(generatedModelID)
                end
            end
            if weaponDFFPath and File.exists(weaponDFFPath) then
                if not createdElements.models.dff[weaponDFFPath] then
                    createdElements.models.dff[weaponDFFPath] = EngineDFF(weaponDFFPath)
                end
                if createdElements.models.dff[weaponDFFPath] and isElement(createdElements.models.dff[weaponDFFPath]) then
                    createdElements.models.dff[weaponDFFPath]:replace(generatedModelID)
                end
            end
            if weaponCOLPath and File.exists(weaponCOLPath) then
                if not createdElements.models.col[weaponCOLPath] then
                    createdElements.models.col[weaponCOLPath] = EngineCOL(weaponCOLPath)
                end
                if createdElements.models.col[weaponCOLPath] and isElement(createdElements.models.col[weaponCOLPath]) then
                    createdElements.models.col[weaponCOLPath]:replace(generatedModelID)
                end
            end
            createdElements.modelIDs[weaponType] = generatedModelID
        end
    end

end)