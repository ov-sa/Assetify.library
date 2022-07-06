----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: exports: shared.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Shared Exports ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    isElement = isElement
}


-------------------------
--[[ Functions: APIs ]]--
-------------------------

function isLibraryLoaded() return syncer.isLibraryLoaded end
function isModuleLoaded() return syncer.isModuleLoaded end
function getLibraryAssets(...) return manager:fetchAssets(...) end
function getAssetData(...) return manager:getData(...) end
function getAssetDep(...) return manager:getDep(...) end
function setElementAsset(...) return syncer:syncElementModel(_, ...) end
function getElementAssetInfo(element) if not element or not imports.isElement(element) or not syncer.syncedElements[element] then return false end return syncer.syncedElements[element].type, syncer.syncedElements[element].name, syncer.syncedElements[element].clump, syncer.syncedElements[element].clumpMaps end
function setGlobalData(...) return syncer:syncGlobalData(...) end
function getGlobalData(data) return syncer.syncedGlobalDatas[data] end
function setEntityData(...) return syncer:syncEntityData(table:unpack(table:pack(...), 3)) end
function getEntityData(element, data) return syncer.syncedEntityDatas[element] and syncer.syncedEntityDatas[element][data] end
function createAssetDummy(...) local cDummy = syncer:syncDummySpawn(_, ...); return (cDummy and cDummy.cDummy) or false end
function setBoneAttachment(...) return syncer:syncBoneAttachment(_, ...) end
function setBoneDetachment(...) return syncer:syncBoneDetachment(_, ...) end
function setBoneRefreshment(...) return syncer:syncBoneRefreshment(_, ...) end
function clearBoneAttachment(element) return syncer:syncClearBoneAttachment(_, element) end