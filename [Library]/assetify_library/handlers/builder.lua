----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: builder.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Library Builder ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    setTimer = setTimer,
    addEventHandler = addEventHandler
}


-------------------
--[[ Variables ]]--
-------------------

isLibraryLoaded = false
availableAssetPacks = {
    ["character"] = {
        reference = {
            root = "files/assets/characters/",
            manifest = "manifest",
            asset = "asset",
            type = "ped",
            base = 7,
            transparency = false
        }
    },

    ["vehicle"] = {
        reference = {
            root = "files/assets/vehicles/",
            manifest = "manifest",
            asset = "asset",
            type = "vehicle",
            base = 400 ,
            transparency = false
        }
    },

    ["weapon"] = {
        reference = {
            root = "files/assets/weapons/",
            manifest = "manifest",
            asset = "asset",
            type = "object",
            base = 1337,
            transparency = false
        }
    }
}


----------------------------------
--[[ Event: On Resource Start ]]--
----------------------------------

imports.addEventHandler("onResourceStart", resourceRoot, function()

    thread:create(function(cThread)
        for i, j in imports.pairs(availableAssetPacks) do
            asset:buildPack(j, function(assetPack)
                j.assetPack = assetPack
                imports.setTimer(function()
                    cThread:resume()
                end, 1, 1)
            end)
            thread.pause()
        end
        onLibraryLoaded()
    end):resume()

end)