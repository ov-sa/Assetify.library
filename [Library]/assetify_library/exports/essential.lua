----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: exports: essential.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Essential Exports ]]--
----------------------------------------------------------------


-----------------------------------
--[[ Function: Retrieves Asset ]]--
-----------------------------------

function getAsset(assetType, assetName)

    if not isLibraryLoaded then return false end

    if availableAssetPacks[assetType] and availableAssetPacks[assetType].rwDatas[assetName] then
        outputChatBox("EXISTS WEAPON ASSET...")
    else
        outputChatBox("DOESN'T EXISTS WEAPON ASSET...")
    end
    return false

end