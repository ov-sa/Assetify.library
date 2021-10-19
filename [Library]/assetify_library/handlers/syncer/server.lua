----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: syncer: server.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Library Syncer ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    addEventHandler = addEventHandler
}


-----------------------------------------
--[[ Event: On Player Resource Start ]]--
-----------------------------------------

imports.addEventHandler("onPlayerResourceStart", resourceRoot, function()

    --TODO:...
    if isLibraryLoaded then
        print("LIBRARY LOADED ALREADY")
    else
        print("SCHEDULE PLAYER FOR LOADING ASSETS")
    end

end)