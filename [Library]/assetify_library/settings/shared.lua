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
        restoreWorld = true,
        clearWorld = false,
        waterLevel = 0.01
    },

    library = {
        autoUpdate = true,
        webserverURL = false
    },

    discord = {
        appID = "1311797731932766248",
        logo = {asset = "logo", tooltip = "ᴏᴠ ━ ꜱᴛᴜᴅɪᴏ"},
        minAge = 3,
        details = "ovstudio",
        trackRate = 30*1000,
        buttons = {
            {name = "Download", url = "https://github.com/ov-sa/Assetify.library/releases/latest"},
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
        persistence = 30*1000
    },

    renderer = {
        state = true,
        sky = {
            state = true,
            cloud = {
                speed = 1,
                scale = 1,
                direction = {1, -1},
                color = {255, 255, 255, 255}
            },
            star = {
                intensity = 1
            }
        }
    }
}