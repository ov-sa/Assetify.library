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
    type = type,
    pairs = pairs,
    isElement = isElement,
    getElementType = getElementType
}


-------------------------
--[[ Functions: APIs ]]--
-------------------------

function isLibraryLoaded()
    return syncer.isLibraryLoaded
end

function isModuleLoaded()
    return syncer.isModuleLoaded
end

function getLibraryAssets(assetType)
    if not syncer.isLibraryLoaded or not assetType or not settings.assetPacks[assetType] then return false end
    local packAssets = {}
    if localPlayer then
        if settings.assetPacks[assetType].rwDatas then
            for i, j in imports.pairs(settings.assetPacks[assetType].rwDatas) do
                table:insert(packAssets, i)
            end
        end
    else
        for i, j in imports.pairs(settings.assetPacks[assetType].assetPack.manifestData) do
            if settings.assetPacks[assetType].assetPack.rwDatas[j] then
                table:insert(packAssets, j)
            end
        end
    end
    return packAssets
end

function getAssetData(...)
    return manager:getData(...)
end

function getAssetDep(...)
    return manager:getDep(...)
end

function setElementAsset(element, assetType, ...)
    if not element or not imports.isElement(element) then return false end
    local elementType = imports.getElementType(element)
    elementType = (((elementType == "ped") or (elementType == "player")) and "ped") or elementType
    if not settings.assetPacks[assetType] or not settings.assetPacks[assetType].assetType or (settings.assetPacks[assetType].assetType ~= elementType) then return false end
    local cArgs = table:pack(...)
    return syncer:syncElementModel(element, assetType, cArgs[1], cArgs[2], cArgs[3], cArgs[4])
end

function getElementAssetInfo(element)
    if not element or not imports.isElement(element) then return false end
    if not syncer.syncedElements[element] then return false end
    return syncer.syncedElements[element].type, syncer.syncedElements[element].name, syncer.syncedElements[element].clump, syncer.syncedElements[element].clumpMaps
end

function setGlobalData(...)
    return syncer:syncGlobalData(...)
end

function getGlobalData(data)
    if not data or (imports.type(data) ~= "string") then return false end
    return syncer.syncedGlobalDatas[data]
end

function setEntityData(...)
    return syncer:syncEntityData(...)
end

function getEntityData(element, data)
    if not element or not data or (imports.type(data) ~= "string") then return false end
    return syncer.syncedEntityDatas[element] and syncer.syncedEntityDatas[element][data]
end

function createAssetDummy(...)
    local cArgs = table:pack(...)
    return syncer:syncAssetDummy(cArgs[1], cArgs[2], cArgs[3], cArgs[4], cArgs[5])
end

function setBoneAttachment(...)
    local cArgs = table:pack(...)
    return syncer:syncBoneAttachment(cArgs[1], cArgs[2], cArgs[3])
end

function setBoneDetachment(element)
    return syncer:syncBoneDetachment(element)
end

function setBoneRefreshment(...)
    local cArgs = table:pack(...)
    return syncer:syncBoneRefreshment(cArgs[1], cArgs[2])
end

function clearBoneAttachment(element)
    return syncer:syncClearBoneAttachment(element)
end