----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: settings: server.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Server Sided Settings ]]--
----------------------------------------------------------------


------------------
--[[ Settings ]]--
------------------

availableAssetPacks = {

    ["scene"] = {
        reference = {
            root = "files/assets/scenes/",
            manifest = "manifest",
            asset = "asset",
            scene = "scene",
            assetType = "object",
            assetBase = 1337,
            assetTransparency = false,
            autoLoad = true
        }
    },

    ["character"] = {
        reference = {
            root = "files/assets/characters/",
            manifest = "manifest",
            asset = "asset",
            assetType = "ped",
            assetBase = 7,
            assetTransparency = false,
            autoLoad = true
        }
    },

    ["vehicle"] = {
        reference = {
            root = "files/assets/vehicles/",
            manifest = "manifest",
            asset = "asset",
            assetType = "vehicle",
            assetBase = 400 ,
            assetTransparency = false,
            autoLoad = true
        }
    },

    ["weapon"] = {
        reference = {
            root = "files/assets/weapons/",
            manifest = "manifest",
            asset = "asset",
            assetType = "object",
            assetBase = 1337,
            assetTransparency = false,
            autoLoad = true
        }
    }

}