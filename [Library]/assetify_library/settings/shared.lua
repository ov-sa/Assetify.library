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
        clearWorld = false,
        disableOcclusions = false,
        waterLevel = 0.01
    },

    library = {
        autoUpdate = true,
        webserverURL = false
    },

    downloader = {
        isAccessSafe = true,
        syncRate = 100,
        buildRate = 1000,
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