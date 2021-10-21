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
            autoLoad = true,
            assetType = "object",
            assetBase = 1337,
            assetTransparency = false
        }
    },

    ["character"] = {
        reference = {
            autoLoad = true,
            assetType = "ped",
            assetBase = 7,
            assetTransparency = false
        }
    },

    ["vehicle"] = {
        reference = {
            autoLoad = true,
            assetType = "vehicle",
            assetBase = 400 ,
            assetTransparency = false
        }
    },

    ["weapon"] = {
        reference = {
            autoLoad = true,
            assetType = "object",
            assetBase = 1337,
            assetTransparency = false
        }
    }

}