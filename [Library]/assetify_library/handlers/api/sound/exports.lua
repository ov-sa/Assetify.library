----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: api: sound: exports.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Sound APIs ]]--
----------------------------------------------------------------


-----------------
--[[ Exports ]]--
-----------------

manager:exportAPI("Sound", {
    shared = {},
    client = {
        {name = "playSound"},
        {name = "playSound3D"}
    },
    server = {}
})