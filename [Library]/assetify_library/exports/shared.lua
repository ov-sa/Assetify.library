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
    pairs = pairs,
    isElement = isElement,
    getElementType = getElementType,
    table = table
}


-------------------------
--[[ Functions: APIs ]]--
-------------------------

function getLibraryAssets(assetType)
    if not syncer.isLibraryLoaded or not assetType or not availableAssetPacks[assetType] then return false end
    local packAssets = {}
    for i, j in imports.pairs((localPlayer and availableAssetPacks[assetType].rwDatas) or availableAssetPacks[assetType].assetPack.rwDatas) do
        imports.table.insert(packAssets, i)
    end
    return packAssets
end

function getAssetData(...)
    return manager:getData(...)
end

function setElementAsset(element, ...)
    if not element or not imports.isElement(element) then return false end
    local elementType = imports.getElementType(element)
    elementType = (((elementType == "ped") or (elementType == "player")) and "character") or elementType
    if not availableAssetPacks[elementType] then return false end
    local arguments = {...}
    return syncer:syncElementModel(element, elementType, arguments[1], arguments[2], arguments[3], arguments[4])
end

function setBoneAttachment(element, parent, ...)
    if not element or not imports.isElement(element) or not parent or not imports.isElement(parent) then return false end
    local arguments = {...}
    return syncer:syncBoneAttachment(element, parent, arguments[1])
end

function setBoneDetachment(element)
    if not element or not imports.isElement(element) then return false end
    return syncer:syncBoneDetachment(element)
end

function setBoneRefreshment(element, ...)
    if not element or not imports.isElement(element) then return false end
    local arguments = {...}
    return syncer:syncBoneRefreshment(element, arguments[1])
end

function clearBoneAttachment(element, ...)
    if not element or not imports.isElement(element) then return false end
    return syncer:syncClearBoneAttachment(element)
end