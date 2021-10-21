----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: exports: client.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Client Sided Exports ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    setTimer = setTimer
}


------------------------------------------
--[[ Function: Retrieves Asset's Data ]]--
------------------------------------------

function getAssetData(assetType, assetName)

    if not isLibraryLoaded then return false end
    if not assetType or not assetName then return false end

    if availableAssetPacks[assetType] then
        local assetReference = availableAssetPacks[assetType].rwDatas[assetName]
        if assetReference then
            if not sourceResource then
                return assetReference, assetReference.cAsset
            else
                return assetReference, assetReference.cAsset.syncedData
            end
        end
    end
    return false

end


----------------------------------------------
--[[ Functions: Laods/Unloads Scene Asset ]]--
----------------------------------------------

function loadAsset(assetType, assetName, callback)

    if not isLibraryLoaded then return false end
    if not assetType or not assetName then return false end

    local packReference = availableAssetPacks[assetType]
    if packReference then
        local assetReference = packReference.rwDatas[assetName]
        if assetReference and not assetReference.cAsset then
            if assetType == "scene" then
                thread:create(function(cThread)
                    for i, j in imports.pairs(assetReference.rwData.children) do
                        asset:create(assetType, packReference.assetType, packReference.assetBase, packReference.assetTransparency, j, assetReference.rwData, function(cAsset)
                            imports.setTimer(function()
                                cThread:resume()
                            end, 1, 1)
                        end)
                    end
                end):resume()
            else
                return asset:create(assetType, packReference.assetType, packReference.assetBase, packReference.assetTransparency, assetReference, nil, callback)
            end
        end
    end
    return false

end

function unloadAsset(assetType, assetName, callback)

    if not isLibraryLoaded then return false end
    if not assetType or not assetName then return false end

    local packReference = availableAssetPacks[assetType]
    if packReference then
        local assetReference = packReference.rwDatas[assetName]
        if assetReference and assetReference.cAsset then
            return assetReference.cAsset:destroy(callback)
        end
    end
    return false

end