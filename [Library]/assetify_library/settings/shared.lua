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

    discord = {
        appID = "1311797731932766248",
        minAge = 3,
        trackRate = 30*1000,
        logo = {asset = "logo", tooltip = "ᴏᴠ ━ ꜱᴛᴜᴅɪᴏ"},
        details = "version: 8.2.7",
        buttons = {
            {name = "Download Build", url = "https://github.com/ov-sa/Assetify.library/releases/tag/v.8.2.7"},
            {name = "Donate", url = "https://ko-fi.com/ovstudio"}
        }
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