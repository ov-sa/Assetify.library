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

    downloader = {
        isAccessSafe = true,
        syncRate = 50,
        buildRate = 500
    },

    streamer = {
        syncRate = 250,
        cameraSyncRate = 75,
        boneSyncRate = 25,
        unsyncDimension = 65535 
    },

    syncer = {
        persistenceDuration = 30*1000
    },

    renderer = {
        resolution = 1
    }
}