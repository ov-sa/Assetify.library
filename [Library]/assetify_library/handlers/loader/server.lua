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

isLibraryLoaded = false


----------------------------------
--[[ Event: On Resource Start ]]--
----------------------------------

imports.addEventHandler("onResourceStart", resourceRoot, function()

    buildWeaponPack(function(buildData)
        isLibraryLoaded = true
    end)

end)