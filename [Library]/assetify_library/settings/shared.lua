----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: settings: shared.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Shared Settings ]]--
----------------------------------------------------------------


------------------
--[[ Settings ]]--
------------------

settings = {
    GTA = {
        clearWorld = true,
        waterLevel = 0.01
    },

    library = {
        autoUpdate = true
    },

    downloader = {
        isAccessSafe = true,
        syncRate = 50,
        buildRate = 500,
        trackRate = 300
    },

    streamer = {
        syncRate = 250,
        streamRate = 75,
        cameraRate = 75,
        syncCoolDownRate = false,
        streamDelimiter = {8, 30, 5},
        unsyncDimension = 65535 
    },

    syncer = {
        persistenceDuration = 30*1000
    },

    renderer = {
        resolution = 1
    }
}