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

downloadSettings = {
    speed = 1250000,
    syncRate = 50
}

availableAssetPacks = {
    ["scene"] = {
        autoLoad = true,
        assetType = "object",
        assetBase = 1337,
        assetTransparency = false
    },

    ["character"] = {
        autoLoad = true,
        assetType = "ped",
        assetBase = 7,
        assetTransparency = false
    },

    ["vehicle"] = {
        autoLoad = true,
        assetType = "vehicle",
        assetBase = 400,
        assetTransparency = false
    },

    ["weapon"] = {
        autoLoad = true,
        assetType = "object",
        assetBase = 1337,
        assetTransparency = false
    }
}