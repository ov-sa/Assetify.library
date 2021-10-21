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
            type = "object",
            base = 1337,
            transparency = false,
            autoLoad = true
        }
    },

    ["character"] = {
        reference = {
            root = "files/assets/characters/",
            manifest = "manifest",
            asset = "asset",
            type = "ped",
            base = 7,
            transparency = false,
            autoLoad = true
        }
    },

    ["vehicle"] = {
        reference = {
            root = "files/assets/vehicles/",
            manifest = "manifest",
            asset = "asset",
            type = "vehicle",
            base = 400 ,
            transparency = false,
            autoLoad = true
        }
    },

    ["weapon"] = {
        reference = {
            root = "files/assets/weapons/",
            manifest = "manifest",
            asset = "asset",
            type = "object",
            base = 1337,
            transparency = false,
            autoLoad = true
        }
    }

}