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
    type = type,
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


------------------------------------------------
--[[ Function: Retrieves Asset's Load State ]]--
------------------------------------------------

function isAssetLoaded(assetType, assetName)

    if not isLibraryLoaded then return false end
    if not assetType or not assetName then return false end

    local packReference = availableAssetPacks[assetType]
    if packReference then
        local assetReference = packReference.rwDatas[assetName]
        if assetReference and assetReference.cAsset then
            return true
        end
    end
    return false

end


----------------------------------------
--[[ Functions: Loads/Unloads Asset ]]--
----------------------------------------

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
                        asset:create(assetType, packReference, j, assetReference, function(cAsset)
                            scene:create(j.cAsset, assetReference.manifestData)
                            imports.setTimer(function()
                                cThread:resume()
                            end, 1, 1)
                        end)
                    end
                    asset:refreshMaps(true, assetReference.manifestData.shaderMaps, assetReference.rwMap)
                    assetReference.cAsset = true
                    if callback and (imports.type(callback) == "function") then
                        callback(true)
                    end
                end):resume()
                return true
            else
                return asset:create(assetType, packReference, assetReference, nil, callback)
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
            if assetType == "scene" then
                thread:create(function(cThread)
                    for i, j in imports.pairs(assetReference.rwData.children) do
                        if j.cScene then
                            j.cScene:destroy()
                        end
                        if j.cAsset then
                            j.cAsset:destroy(function()
                                imports.setTimer(function()
                                    cThread:resume()
                                end, 1, 1)
                            end)
                        end
                    end
                    asset:refreshMaps(false, assetReference.manifestData.shaderMaps)
                    assetReference.cAsset = false
                    if callback and (imports.type(callback) == "function") then
                        callback(true)
                    end
                end):resume()
                return true
            else
                return assetReference.cAsset:destroy(callback)
            end
        end
    end
    return false

end