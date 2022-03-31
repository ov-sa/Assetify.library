----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: manager.lua
     Author: vStudio
     Developer(s): Aviril, Tron
     DOC: 19/10/2021
     Desc: Manager Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    decodeString = decodeString,
    split = split,
    gettok = gettok,
    tonumber = tonumber,
    tostring = tostring,
    destroyElement = destroyElement,
    addEventHandler = addEventHandler,
    collectgarbage = collectgarbage,
    setTimer = setTimer,
    file = file,
    string = string,
    quat = quat
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

function manager:getID(assetType, assetName, assetClump)
    if not manager:isLoaded(assetType, assetName) then return false end
    local packReference = availableAssetPacks[assetType]
    local assetReference = packReference.rwDatas[assetName]
    if imports.type(assetReference.unsyncedData) ~= "table" then return false end
    if assetReference.manifestData.assetClumps then
        return (assetClump and assetReference.manifestData.assetClumps[assetClump] and assetReference.unsyncedData.assetCache[assetClump] and assetReference.unsyncedData.assetCache[assetClump].cAsset and assetReference.unsyncedData.assetCache[assetClump].cAsset.syncedData.modelID) or false
    else
        return (assetReference.unsyncedData.assetCache.cAsset and assetReference.unsyncedData.assetCache.cAsset.syncedData.modelID) or false
    end
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
            shader:createTex(assetReference.manifestData.shaderMaps, assetReference.unsyncedData.rwCache.map, assetReference.manifestData.encryptKey)
            if assetType == "scene" then
                thread:create(function(cThread)
                    local sceneManifestData = imports.file.read(assetPath..(asset.references.scene)..".ipl")
                    sceneManifestData = (assetReference.manifestData.encryptKey and imports.decodeString("tea", sceneManifestData, {key = assetReference.manifestData.encryptKey})) or sceneManifestData
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
                        if  assetReference.manifestData.shaderMaps and assetReference.manifestData.shaderMaps.control then
                            for k, v in imports.pairs(assetReference.manifestData.shaderMaps.control) do
                                local shaderTextures, shaderInputs = {}, {}
                                for m = 1, #v, 1 do
                                    local n = v[m]
                                    if n.control then
                                        shaderTextures[("controlTex_"..m)] = n.control
                                    end
                                    if n.bump then
                                        shaderTextures[("controlTex_"..m.."_bump")] = n.bump
                                    end
                                    for x = 1, #shader.defaultData.shaderChannels, 1 do
                                        local y = shader.defaultData.shaderChannels[x]
                                        if n[(y.index)] then
                                            shaderTextures[("controlTex_"..m.."_"..(y.index))] = n[(y.index)].map
                                            shaderInputs[("controlScale_"..m.."_"..(y.index))] = n[(y.index)].scale
                                            if n[(y.index)].bump then
                                                shaderTextures[("controlTex_"..m.."_"..(y.index).."_bump")] = n[(y.index)].bump
                                            end
                                        end
                                    end
                                end
                                shader:create(nil, "control", "Assetify_TextureMapper", k, shaderTextures, shaderInputs, assetReference.unsyncedData.rwCache.map, v, assetReference.manifestData.encryptKey)
                            end
                        end
                    end
                end):resume({
                    executions = downloadSettings.buildRate,
                    frames = 1
                })
                return true
            elseif assetReference.manifestData.assetClumps then
                thread:create(function(cThread)
                    for i, j in imports.pairs(assetReference.manifestData.assetClumps) do
                        assetReference.unsyncedData.assetCache[i] = {}
                        asset:create(assetType, packReference, assetReference.unsyncedData.rwCache, assetReference.manifestData, assetReference.unsyncedData.assetCache[i], {
                            txd = assetPath..(asset.references.asset)..".txd",
                            dff = assetPath.."clump/"..j..".dff",
                            col = assetPath..(asset.references.asset)..".col"
                        })
                        thread.pause()
                    end
                end):resume({
                    executions = downloadSettings.buildRate,
                    frames = 1
                })
                return true
            else
                if asset:create(assetType, packReference, assetReference.unsyncedData.rwCache, assetReference.manifestData, assetReference.unsyncedData.assetCache, {
                    txd = assetPath..(asset.references.asset)..".txd",
                    dff = assetPath..(asset.references.asset)..".dff",
                    col = assetPath..(asset.references.asset)..".col"
                }) then
                    return true
                end
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
                    shader:clearAssetBuffer(assetReference.unsyncedData.rwCache.map)
                    assetReference.unsyncedData = nil
                    imports.collectgarbage()
                end):resume({
                    executions = downloadSettings.buildRate,
                    frames = 1
                })
                return true
            elseif assetReference.manifestData.assetClumps then
                thread:create(function(cThread)
                    for i, j in imports.pairs(assetReference.unsyncedData.assetCache) do
                        if j.cAsset then
                            j.cAsset:destroy(assetReference.unsyncedData.rwCache)
                        end
                        thread.pause()
                    end
                    shader:clearAssetBuffer(assetReference.unsyncedData.rwCache.map)
                    assetReference.unsyncedData = nil
                    imports.collectgarbage()
                end):resume({
                    executions = downloadSettings.buildRate,
                    frames = 1
                })
                return true
            else
                if assetReference.cAsset then
                    assetReference.cAsset:destroy(assetReference.unsyncedData.rwCache)
                    shader:clearAssetBuffer(assetReference.unsyncedData.rwCache.map)
                    assetReference.unsyncedData = nil
                    imports.collectgarbage()
                    return true
                end
            end
        end
    end
    return false
end

imports.addEventHandler("onClientElementDestroy", root, function()
    shader:clearElementBuffer(source)
    dummy:clearElementBuffer(source)
    bone:clearElementBuffer(source)
end)
