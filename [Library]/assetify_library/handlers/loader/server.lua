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
    pairs = pairs,
    addEventHandler = addEventHandler
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
        },
    
        datas = {
            manifestData = false,
            rwDatas = {}
        }
    }
}
builtAssetPacks = {}


----------------------------------
--[[ Event: On Resource Start ]]--
----------------------------------

imports.addEventHandler("onResourceStart", resourceRoot, function()

    for i, j in imports.pairs(availableAssetPacks) do
        buildPack(j, function(buildState)
            print("LOADED?")
            builtAssetPacks["weapon"] = buildData
        end)
        isLibraryLoaded = true
    end

end)