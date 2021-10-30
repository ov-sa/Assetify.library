----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: manager.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Manager Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
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
    }
}


------------------------
--[[ Class: Manager ]]--
------------------------

manager = {}
manager.__index = manager

function manager:isAssetLoaded(assetType, assetName)

    if not syncer.isLibraryLoaded then return false end
    if not assetType or not assetName then return false end

    local packReference = availableAssetPacks[assetType]
    if packReference then
        local assetReference = packReference.rwDatas[assetName]
        if assetReference and assetReference.unsyncedData then
            return true
        end
    end
    return false

end

function manager:loadAsset(assetType, assetName)
    if not syncer.isLibraryLoaded then return false end
    if not assetType or not assetName then return false end
    local packReference = availableAssetPacks[assetType]
    if packReference then
        local assetReference = packReference.rwDatas[assetName]
        if assetReference and not assetReference.unsyncedData then
            local assetPath = (asset.references.root)..assetType.."/"..assetName.."/"
            if assetType == "scene" then
                thread:create(function(cThread)
                    assetReference.unsyncedData = {
                        assetCache = {},
                        rwCache = {
                            txd = {},
                            dff = {},
                            col = {}
                        }
                    }
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
                                    scene:create(assetReference.unsyncedData.assetCache[i].cAsset, assetReference.manifestData, {
                                        position = {
                                            x = imports.tonumber(imports.gettok(unparsedDatas[i], 4, asset.separators.IPL)),
                                            y = imports.tonumber(imports.gettok(unparsedDatas[i], 5, asset.separators.IPL)),
                                            z = imports.tonumber(imports.gettok(unparsedDatas[i], 6, asset.separators.IPL))
                                        },
                                        rotation = {
                                            x = imports.tonumber(imports.gettok(unparsedDatas[i], 7, asset.separators.IPL)),
                                            y = imports.tonumber(imports.gettok(unparsedDatas[i], 8, asset.separators.IPL)),
                                            z = imports.tonumber(imports.gettok(unparsedDatas[i], 9, asset.separators.IPL))
                                        }
                                    })
                                end
                            end)
                            thread.pause()
                        end
                        --TODO: LOAD SHADERS
                        --asset:refreshMaps(true, assetType, assetName, assetReference.manifestData.shaderMaps, assetReference.rwMap)
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

function manager:unloadAsset(assetType, assetName)
    if not syncer.isLibraryLoaded then return false end
    if not assetType or not assetName then return false end
    local packReference = availableAssetPacks[assetType]
    if packReference then
        local assetReference = packReference.rwDatas[assetName]
        if assetReference and assetReference.unsyncedData then
            if assetType == "scene" then
                thread:create(function(cThread)
                    for i, j in imports.pairs(assetReference.unsyncedData.assetCache) do
                        if j.cAsset then
                            if j.cAsset.cScene then
                                j.cAsset.cScene:destroy()
                            end
                            j.cAsset:destroy()
                        end
                        thread.pause()
                    end
                    for i, j in imports.pairs(assetReference.unsyncedData.rwCache) do
                        if j and imports.isElement(j) then
                            imports.destroyElement(j)
                        end
                        thread.pause()
                    end
                    --asset:refreshMaps(false, assetType, assetName, assetReference.manifestData.shaderMaps)
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