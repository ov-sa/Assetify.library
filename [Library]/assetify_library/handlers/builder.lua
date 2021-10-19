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
    addEventHandler = addEventHandler,
    buildAssetPack = buildAssetPack
}


-------------------
--[[ Variables ]]--
-------------------

isLibraryLoaded = false

availableAssetPacks = {

    ["weapon"] = {
        reference = {
            root = "files/assets/weapons/",
            manifest = "manifest",
            asset = "asset"
        }
    }

}


----------------------------------
--[[ Event: On Resource Start ]]--
----------------------------------

imports.addEventHandler("onResourceStart", resourceRoot, function()

    thread:create(function(cThread)
        for i, j in imports.pairs(availableAssetPacks) do
            imports.buildAssetPack(j, function(assetPack)
                j.assetPack = assetPack
                cThread:resume()
            end)
            thread.pause()
        end
    end):resume()
    isLibraryLoaded = true

end)