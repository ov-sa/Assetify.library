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


----------------------------------
--[[ Event: On Resource Start ]]--
----------------------------------
imports.addEventHandler("onResourceStart", resourceRoot, function()

    buildWeaponPack(function(buildState)
        print("WOW LOADED THE PACK!: "..tostring(buildState))
    end)

end)