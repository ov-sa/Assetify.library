----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: api: library: shared.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Library APIs ]]--
----------------------------------------------------------------


-----------------------
--[[ APIs: Library ]]--
-----------------------

manager.API.Library = {}

function manager.API.Library.isBooted()
    return syncer.isLibraryBooted
end

function manager.API.Library.isLoaded()
    return syncer.isLibraryLoaded
end

function manager.API.Library.isModuleLoaded()
    return syncer.isModuleLoaded
end

function manager.API.Library.fetchAssets(...)
    return manager:fetchAssets(...)
end

function manager.API.Library.getAssetData(...)
    return manager:getAssetData(...)
end

function manager.API.Library.getAssetDep(...)
    return manager:getAssetDep(...)
end

function manager.API.Library.setElementAsset(...)
    return syncer.syncElementModel(_, ...)
end

function manager.API.Library.getElementAssetInfo(element)
    if not syncer.syncedElements[element] then return false end
    return syncer.syncedElements[element].assetType, syncer.syncedElements[element].assetName, syncer.syncedElements[element].assetClump, syncer.syncedElements[element].clumpMaps
end

function manager.API.Library.setGlobalData(...)
    return syncer.syncGlobalData(...)
end

function manager.API.Library.getGlobalData(data)
    return syncer.syncedGlobalDatas[data]
end

function manager.API.Library.setEntityData(...)
    return syncer.syncEntityData(table.unpack(table.pack(...), 3))
end

function manager.API.Library.getEntityData(element, data)
    return syncer.syncedEntityDatas[element] and syncer.syncedEntityDatas[element][data]
end

function manager.API.Library.setAttachment(...)
    return attacher:attachElements(...)
end

function manager.API.Library.setDetachment(...)
    return attacher:detachElements(...)
end

function manager.API.Library.clearAttachment(...)
    return attacher:clearAttachment(...)
end

function manager.API.Library.createAssetDummy(...)
    local cDummy = syncer.syncDummySpawn(_, ...)
    return (cDummy and cDummy.cDummy) or false
end

function manager.API.Library.setBoneAttachment(...)
    return syncer.syncBoneAttachment(_, ...)
end

function manager.API.Library.syncBoneDetachment(...)
    return syncer.syncBoneDetachment(_, ...)
end

function manager.API.Library.setBoneRefreshment(...)
    return syncer:setBoneRefreshment(_, ...)
end

function manager.API.Library.clearBoneAttachment(...)
    return syncer.syncClearBoneAttachment(_, ...)
end