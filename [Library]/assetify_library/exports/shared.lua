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