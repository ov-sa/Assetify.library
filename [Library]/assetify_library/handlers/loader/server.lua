----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: loader: server.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Library Loader ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    addEventHandler = addEventHandler
}


-------------------
--[[ Variables ]]--
-------------------

local availablePacks = {

    {
        name = "Weapon Pack",
        builder = buildWeaponPack
    }

}


----------------------------------
--[[ Event: On Resource Start ]]--
----------------------------------
imports.addEventHandler("onResourceStart", resourceRoot, function()

    for i = 1, #availablePacks, 1 do
        local packReference = availablePacks[i]
        print("Building Pack: "..packReference.name)
        packReference.builder(function(buildState)
            print("WOW LOADED THE PACK!: "..tostring(buildState))
        end)
    end

end)