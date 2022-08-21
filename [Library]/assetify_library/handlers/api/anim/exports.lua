----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: api: anim: exports.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Anim APIs ]]--
----------------------------------------------------------------


-----------------
--[[ Exports ]]--
-----------------

manager:exportAPI("Anim", {
    shared = {},
    client = {
        {name = "loadAnim"},
        {name = "unloadAnim"}
    },
    server = {}
})