----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: engine: light: index.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Light Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs
}


--------------------------
--[[ Namespace: Light ]]--
--------------------------

local light = namespace:create("light")


---------------------
--[[ API Syncers ]]--
---------------------

if localPlayer then
    network:fetch("Assetify:onElementDestroy"):on(function(source)
        if not syncer.isLibraryBooted or not source then return false end
        for i, j in imports.pairs(light) do
            if j and (imports.type(j) == "table") and j.clearElementBuffer then
                j.clearElementBuffer(source)
            end
        end
    end)
end