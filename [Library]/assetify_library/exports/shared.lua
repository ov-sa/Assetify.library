----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: exports: shared.lua
     Author: vStudio
     Developer(s): Aviril, Tron
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
    getElementType = getElementType,
    table = table
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
    if not syncer.isLibraryLoaded or not assetType or not availableAssetPacks[assetType] then return false end
    local packAssets = {}
    if localPlayer then
        for i, j in imports.pairs(localPlayer and availableAssetPacks[assetType].rwDatas) do
            imports.table.insert(packAssets, i)
        end
    else
        for i, j in imports.pairs(availableAssetPacks[assetType].assetPack.manifestData) do
            if availableAssetPacks[assetType].assetPack.rwDatas[j] then
                imports.table.insert(packAssets, j)
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
    if not availableAssetPacks[assetType] or not availableAssetPacks[assetType].assetType or (availableAssetPacks[assetType].assetType ~= elementType) then return false end
    local arguments = {...}
    return syncer:syncElementModel(element, assetType, arguments[1], arguments[2], arguments[3], arguments[4])
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
    local arguments = {...}
    return syncer:syncAssetDummy(arguments[1], arguments[2], arguments[3], arguments[4], arguments[5])
end

function setBoneAttachment(...)
    local arguments = {...}
    return syncer:syncBoneAttachment(arguments[1], arguments[2], arguments[3])
end

function setBoneDetachment(element)
    return syncer:syncBoneDetachment(element)
end

function setBoneRefreshment(...)
    local arguments = {...}
    return syncer:syncBoneRefreshment(arguments[1], arguments[2])
end

function clearBoneAttachment(element)
    return syncer:syncClearBoneAttachment(element)
end