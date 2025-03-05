----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: api: syncer.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Syncer APIs ]]--
----------------------------------------------------------------


----------------------
--[[ APIs: Syncer ]]--
----------------------

if localPlayer then
    manager:exportAPI("syncer", "setGlobalData", function(...) return syncer.syncGlobalData(...) end)
    manager:exportAPI("syncer", "getGlobalData", function(data) return syncer.syncedGlobalDatas[data] end)
    manager:exportAPI("syncer", "getAllGlobalDatas", function() return syncer.syncedGlobalDatas end)
    manager:exportAPI("syncer", "setEntityData", function(...) return syncer.syncEntityData(table.unpack(table.pack(...), 3)) end)
    manager:exportAPI("syncer", "getEntityData", function(element, data) return syncer.syncedEntityDatas[element] and syncer.syncedEntityDatas[element][data] end)
    manager:exportAPI("syncer", "getAllEntityDatas", function(element) return syncer.syncedEntityDatas[element] or {} end)
else

end