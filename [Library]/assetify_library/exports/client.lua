----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: exports: client.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Client Sided Exports ]]--
----------------------------------------------------------------


------------------------------------------
--[[ Function: Retrieves Asset's Data ]]--
------------------------------------------

function getAssetData(assetType, assetName)

    if not syncer.isLibraryLoaded then return false end
    if not assetType or not assetName then return false end

    if availableAssetPacks[assetType] then
        local assetReference = availableAssetPacks[assetType].rwDatas[assetName]
        if assetReference then
            if not sourceResource then
                return assetReference, assetReference.cAsset
            else
                if assetType == "scene" then
                    return assetReference, assetReference.cAsset
                else
                    return assetReference, assetReference.cAsset.syncedData
                end
            end
        end
    end
    return false

end


---------------------------------
--[[ Functions: Asset's APIs ]]--
---------------------------------

function isAssetLoaded(...)

    return manager:isAssetLoaded(...)

end

function loadAsset(...)

    return manager:loadAsset(...)

end

function unloadAsset(...)

    return manager:unloadAsset(...)

end