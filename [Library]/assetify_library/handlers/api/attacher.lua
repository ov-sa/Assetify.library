----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: api: attacher.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Attacher APIs ]]--
----------------------------------------------------------------


------------------------
--[[ APIs: Attacher ]]--
------------------------

manager:exportAPI("attacher", "setAttachment", function(...) return attacher:attachElements(...) end)
manager:exportAPI("attacher", "setDetachment", function(...) return attacher:detachElements(...) end)
manager:exportAPI("attacher", "clearAttachment", function(...) return attacher:clearAttachment(...) end)
manager:exportAPI("attacher", "setBoneAttachment", function(...) return syncer.syncBoneAttachment(_, ...) end)
manager:exportAPI("attacher", "setBoneDetachment", function(...) return syncer.syncBoneDetachment(_, ...) end)
manager:exportAPI("attacher", "setBoneRefreshment", function(...) return syncer.syncBoneRefreshment(_, ...) end)
manager:exportAPI("attacher", "clearBoneAttachment", function(...) return syncer.syncClearBoneAttachment(_, ...) end)