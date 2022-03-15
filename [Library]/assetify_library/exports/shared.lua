----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: exports: shared.lua
     Server: -
     Author: OvileAmriam
     Developer(s): Aviril, Tron
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Shared Exports ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    isElement = isElement,
    getElementType = getElementType
}


-------------------------
--[[ Functions: APIs ]]--
-------------------------

function setElementAsset(element, ...)
    if not element or not imports.isElement(element) then return false end
    local elementType = imports.getElementType(element)
    elementType = (((elementType == "ped") or (elementType == "player")) and "character") or elementType
    if not availableAssetPacks[elementType] then return false end
    local arguments = {...}
    return syncer:syncElementModel(element, elementType, arguments[1], arguments[2], arguments[3], arguments[4])
end

function createAssetDummy(assetType, assetName, dummyData)
    if not assetType or not assetName or not availableAssetPacks[assetType] or not availableAssetPacks[assetType].rwDatas[assetName] then then return false end
    local cAsset = availableAssetPacks[assetType].rwDatas[assetName].unsyncedData.assetCache[i].cAsset
    if not cAsset then return false end
    local cModelInstance = imports.createObject(cAsset.syncedData.modelID, dummyData.position.x, dummyData.position.y, dummyData.position.z, dummyData.rotation.x, dummyData.rotation.y, dummyData.rotation.z)
    imports.setElementDoubleSided(cModelInstance, true)
    if cAsset.syncedData.collisionID then
        local cCollisionInstance = imports.createObject(cAsset.syncedData.collisionID, dummyData.position.x, dummyData.position.y, dummyData.position.z, dummyData.rotation.x, dummyData.rotation.y, dummyData.rotation.z)
        imports.setElementAlpha(cCollisionInstance, 0)
        local cStreamer = streamer:create(cModelInstance, "object", {cCollisionInstance})
    end
    return cModelInstance
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