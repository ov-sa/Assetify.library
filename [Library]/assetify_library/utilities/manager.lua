----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: manager.lua
     Server: -
     Author: OvileAmriam
     Developer(s): Aviril, Tron
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Manager Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    split = split,
    gettok = gettok,
    tonumber = tonumber,
    tostring = tostring,
    isElement = isElement,
    destroyElement = destroyElement,
    collectgarbage = collectgarbage,
    setTimer = setTimer,
    file = {
        read = file.read
    },
    string = {
        gsub = string.gsub
    },
    quat = {
        toEuler = quat.toEuler
    }
}


------------------------
--[[ Class: Manager ]]--
------------------------

manager = {}
manager.__index = manager

function manager:getData(assetType, assetName)
    if not syncer.isLibraryLoaded then return false end
    if not assetType or not assetName then return false end
    if availableAssetPacks[assetType] then
        local assetReference = availableAssetPacks[assetType].rwDatas[assetName]
        if assetReference then
            if assetType == "scene" then
                return assetReference, (assetReference.unsyncedData and true) or false
            else
                return assetReference, (assetReference.unsyncedData and assetReference.unsyncedData.cAsset and assetReference.unsyncedData.cAsset.syncedData) or false
            end
        end
    end
    return false
end

function manager:getID(assetType, assetName)
    if not manager:isLoaded(assetType, assetName) then return false end
    local packReference = availableAssetPacks[assetType]
    local assetReference = packReference.rwDatas[assetName]
    if assetReference.unsyncedData then
        if assetReference.unsyncedData.cAsset then
        end
    end
    if (imports.type(assetReference.unsyncedData) ~= "table") or not assetReference.unsyncedData.assetCache.cAsset then return false end
    return assetReference.unsyncedData.assetCache.cAsset.syncedData.modelID or false
end

function manager:isLoaded(assetType, assetName)
    if not syncer.isLibraryLoaded then return false end
    if not assetType or not assetName then return false end
    local packReference = availableAssetPacks[assetType]
    if packReference and packReference.rwDatas then
        local assetReference = packReference.rwDatas[assetName]
        if assetReference and assetReference.unsyncedData then
            return true
        end
    end
    return false
end

function manager:load(assetType, assetName)
    if not syncer.isLibraryLoaded then return false end
    if not assetType or not assetName then return false end
    local packReference = availableAssetPacks[assetType]
    if packReference and packReference.rwDatas then
        local assetReference = packReference.rwDatas[assetName]
        if assetReference and not assetReference.unsyncedData then
            local assetPath = (asset.references.root)..assetType.."/"..assetName.."/"
            assetReference.unsyncedData = {
                assetCache = {},
                rwCache = {
                    txd = {},
                    dff = {},
                    col = {},
                    map = {}
                }
            }
            if assetType == "scene" then
                thread:create(function(cThread)
                    local sceneManifestData = imports.file.read(assetPath..(asset.references.scene)..".ipl")
                    if sceneManifestData then
                        local unparsedDatas = imports.split(sceneManifestData, "\n")
                        for i = 1, #unparsedDatas, 1 do
                            local childName = imports.string.gsub(imports.tostring(imports.gettok(unparsedDatas[i], 2, asset.separators.IPL)), " ", "")
                            assetReference.unsyncedData.assetCache[i] = {}
                            asset:create(assetType, packReference, assetReference.unsyncedData.rwCache, assetReference.manifestData, assetReference.unsyncedData.assetCache[i], {
                                txd = assetPath..(asset.references.asset)..".txd",
                                dff = assetPath.."dff/"..childName..".dff",
                                col = assetPath.."col/"..childName..".col"
                            }, function(state)
                                if state then
                                    local sceneData = {
                                        position = {
                                            x = imports.tonumber(imports.gettok(unparsedDatas[i], 4, asset.separators.IPL)),
                                            y = imports.tonumber(imports.gettok(unparsedDatas[i], 5, asset.separators.IPL)),
                                            z = imports.tonumber(imports.gettok(unparsedDatas[i], 6, asset.separators.IPL))
                                        },
                                        rotation = {}
                                    }
                                    sceneData.rotation.x, sceneData.rotation.y, sceneData.rotation.z = imports.quat.toEuler(imports.tonumber(imports.gettok(unparsedDatas[i], 10, asset.separators.IPL)), imports.tonumber(imports.gettok(unparsedDatas[i], 7, asset.separators.IPL)), imports.tonumber(imports.gettok(unparsedDatas[i], 8, asset.separators.IPL)), imports.tonumber(imports.gettok(unparsedDatas[i], 9, asset.separators.IPL)))
                                    scene:create(assetReference.unsyncedData.assetCache[i].cAsset, assetReference.manifestData, sceneData)
                                end
                            end)
                            thread.pause()
                        end
                        asset:refreshShaderPack(assetType, assetName, assetReference.manifestData.shaderMaps, nil, assetReference.unsyncedData.rwCache.map, true)
                    end
                end):resume({
                    executions = downloadSettings.buildRate,
                    frames = 1
                })
                return true
            else
                return asset:create(assetType, packReference, assetReference.unsyncedData.rwCache, assetReference.manifestData, assetReference.unsyncedData.assetCache, {
                    txd = assetPath..(asset.references.asset)..".txd",
                    dff = assetPath..(asset.references.asset)..".dff",
                    col = assetPath..(asset.references.asset)..".col"
                })
            end
        end
    end
    return false
end

function manager:unload(assetType, assetName)
    if not syncer.isLibraryLoaded then return false end
    if not assetType or not assetName then return false end
    local packReference = availableAssetPacks[assetType]
    if packReference and packReference.rwDatas then
        local assetReference = packReference.rwDatas[assetName]
        if assetReference and assetReference.unsyncedData then
            if assetType == "scene" then
                thread:create(function(cThread)
                    for i, j in imports.pairs(assetReference.unsyncedData.assetCache) do
                        if j.cAsset then
                            if j.cAsset.cScene then
                                j.cAsset.cScene:destroy()
                            end
                            j.cAsset:destroy(assetReference.unsyncedData.rwCache)
                        end
                        thread.pause()
                    end
                    for i, j in imports.pairs(assetReference.unsyncedData.rwCache) do
                        if j and imports.isElement(j) then
                            imports.destroyElement(j)
                        end
                        thread.pause()
                    end
                    asset:refreshShaderPack(assetType, assetName, assetReference.manifestData.shaderMaps, nil, assetReference.unsyncedData.rwCache.map, false)
                    assetReference.unsyncedData = nil
                    imports.collectgarbage()
                end):resume({
                    executions = downloadSettings.buildRate,
                    frames = 1
                })
            else
                assetReference.cAsset:destroy()
            end
        end
    end
    return false

end