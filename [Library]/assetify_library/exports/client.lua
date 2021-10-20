----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: exports: client.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Client Sided Exports ]]--
----------------------------------------------------------------


---------------------------------------------
--[[ Function: Retrieves Library's State ]]--
---------------------------------------------

function getLibraryState()

    return isLibraryLoaded

end


------------------------------------------
--[[ Function: Retrieves Asset's Data ]]--
------------------------------------------

function getAssetData(assetType, assetName)

    if not isLibraryLoaded then return false end

    if availableAssetPacks[assetType] and availableAssetPacks[assetType].rwDatas[assetName] then
        if not sourceResource then
            return availableAssetPacks[assetType].rwDatas[assetName], availableAssetPacks[assetType].rwDatas[assetName].cAsset
        else
            return availableAssetPacks[assetType].rwDatas[assetName], availableAssetPacks[assetType].rwDatas[assetName].cAsset.syncedData
        end
    end
    return false

end