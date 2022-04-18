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
    addEventHandler = addEventHandler,
    engineReplaceAnimation = engineReplaceAnimation,
    engineRestoreAnimation = engineRestoreAnimation,
    playSound = playSound,
    playSound3D = playSound3D,
    collectgarbage = collectgarbage,
    file = file,
    table = table,
    string = string,
    quat = quat
}


------------------------
--[[ Class: Manager ]]--
------------------------

manager = {}
manager.__index = manager

if localPlayer then
    function manager:getData(assetType, assetName)
        if not syncer.isLibraryLoaded then return false end
        if not assetType or not assetName then return false end
        if availableAssetPacks[assetType] then
            local assetReference = availableAssetPacks[assetType].rwDatas[assetName]
            if assetReference then
                local isExternalResource = sourceResource and (sourceResource ~= resource)
                local unsyncedData = assetReference.unsyncedData
                if isExternalResource then
                    assetReference = imports.table.clone(assetReference, true)
                    assetReference.manifestData.encryptKey = nil
                    assetReference.unsyncedData = nil
                end
                if (assetType == "animation") or (assetType == "sound") or (assetType == "scene") then
                    return assetReference, (unsyncedData and true) or false
                else
                    return assetReference, (unsyncedData and unsyncedData.assetCache.cAsset and unsyncedData.assetCache.cAsset.syncedData) or false
                end
            end
        end
        return false
    end

    function manager:getID(assetType, assetName, assetClump)
        if (assetType == "animation") or (assetType == "sound") then return false end
        if not manager:isLoaded(assetType, assetName) then return false end
        local packReference = availableAssetPacks[assetType]
        local assetReference = packReference.rwDatas[assetName]
        if imports.type(assetReference.unsyncedData) ~= "table" then return false end
        if assetReference.manifestData.assetClumps then
            return (assetClump and assetReference.manifestData.assetClumps[assetClump] and assetReference.unsyncedData.assetCache[assetClump] and assetReference.unsyncedData.assetCache[assetClump].cAsset and assetReference.unsyncedData.assetCache[assetClump].cAsset.syncedData and assetReference.unsyncedData.assetCache[assetClump].cAsset.syncedData.modelID) or false
        else
            return (assetReference.unsyncedData.assetCache.cAsset and assetReference.unsyncedData.assetCache.cAsset.syncedData and assetReference.unsyncedData.assetCache.cAsset.syncedData.modelID) or false
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
                        ifp = {},
                        sound = {},
                        txd = {},
                        dff = {},
                        col = {},
                        map = {}
                    }
                }
                shader:createTex(assetReference.manifestData.shaderMaps, assetReference.unsyncedData.rwCache.map, assetReference.manifestData.encryptKey)
                if assetReference.manifestData.shaderMaps and assetReference.manifestData.shaderMaps.control then
                    for i, j in imports.pairs(assetReference.manifestData.shaderMaps.control) do
                        local shaderTextures, shaderInputs = {}, {}
                        for k = 1, #j, 1 do
                            local v = j[k]
                            if v.control then
                                shaderTextures[("controlTex_"..k)] = v.control
                            end
                            if v.bump then
                                shaderTextures[("controlTex_"..k.."_bump")] = v.bump
                            end
                            for x = 1, #shader.defaultData.shaderChannels, 1 do
                                local y = shader.defaultData.shaderChannels[x]
                                if v[(y.index)] then
                                    shaderTextures[("controlTex_"..k.."_"..(y.index))] = v[(y.index)].map
                                    shaderInputs[("controlScale_"..k.."_"..(y.index))] = v[(y.index)].scale
                                    if v[(y.index)].bump then
                                        shaderTextures[("controlTex_"..k.."_"..(y.index).."_bump")] = v[(y.index)].bump
                                    end
                                end
                            end
                        end
                        shader:create(nil, "control", "Assetify_TextureMapper", i, shaderTextures, shaderInputs, assetReference.unsyncedData.rwCache.map, j, assetReference.manifestData.encryptKey)
                    end
                end
                if assetType == "animation" then
                    if asset:create(assetType, assetName, packReference, assetReference.unsyncedData.rwCache, assetReference.manifestData, assetReference.unsyncedData.assetCache, {
                        ifp = assetPath..(asset.references.asset)..".ifp",
                    }) then
                        return true
                    end
                elseif assetType == "sound" then
                    thread:create(function(cThread)
                        for i, j in imports.pairs(assetReference.manifestData.assetSounds) do
                            assetReference.unsyncedData.assetCache[i] = {}
                            for k, v in imports.pairs(j) do
                                assetReference.unsyncedData.assetCache[i][k] = {}
                                asset:create(assetType, assetName, packReference, assetReference.unsyncedData.rwCache, assetReference.manifestData, assetReference.unsyncedData.assetCache[i][k], {
                                    sound = assetPath.."sound/"..v,
                                })
                                thread.pause()
                            end
                            thread.pause()
                        end
                    end):resume({
                        executions = downloadSettings.buildRate,
                        frames = 1
                    })
                    return true
                elseif assetType == "scene" then
                    thread:create(function(cThread)
                        local sceneManifestData = imports.file.read(assetPath..(asset.references.scene)..".ipl")
                        sceneManifestData = (assetReference.manifestData.encryptKey and imports.decodeString("tea", sceneManifestData, {key = assetReference.manifestData.encryptKey})) or sceneManifestData
                        if sceneManifestData then
                            local unparsedDatas = imports.split(sceneManifestData, "\n")
                            for i = 1, #unparsedDatas, 1 do
                                assetReference.unsyncedData.assetCache[i] = {}
                                local childName = imports.string.gsub(imports.tostring(imports.gettok(unparsedDatas[i], 2, asset.separators.IPL)), " ", "")
                                local sceneData = {
                                    position = {
                                        x = imports.tonumber(imports.gettok(unparsedDatas[i], 4, asset.separators.IPL)),
                                        y = imports.tonumber(imports.gettok(unparsedDatas[i], 5, asset.separators.IPL)),
                                        z = imports.tonumber(imports.gettok(unparsedDatas[i], 6, asset.separators.IPL))
                                    },
                                    rotation = {}
                                }
                                sceneData.rotation.x, sceneData.rotation.y, sceneData.rotation.z = imports.quat.toEuler(imports.tonumber(imports.gettok(unparsedDatas[i], 10, asset.separators.IPL)), imports.tonumber(imports.gettok(unparsedDatas[i], 7, asset.separators.IPL)), imports.tonumber(imports.gettok(unparsedDatas[i], 8, asset.separators.IPL)), imports.tonumber(imports.gettok(unparsedDatas[i], 9, asset.separators.IPL)))
                                if not assetReference.manifestData.sceneMapped then
                                    asset:create(assetType, assetName, packReference, assetReference.unsyncedData.rwCache, assetReference.manifestData, assetReference.unsyncedData.assetCache[i], {
                                        txd = assetPath..(asset.references.asset)..".txd",
                                        dff = assetPath.."dff/"..childName..".dff",
                                        col = assetPath.."col/"..childName..".col"
                                    }, function(state)
                                        if state then
                                            scene:create(assetReference.unsyncedData.assetCache[i].cAsset, assetReference.manifestData, sceneData)
                                        end
                                    end)
                                else
                                    sceneData.position.x, sceneData.position.y, sceneData.position.z = sceneData.position.x + ((assetReference.manifestData.sceneOffset and assetReference.manifestData.sceneOffset.x) or 0), sceneData.position.y + ((assetReference.manifestData.sceneOffset and assetReference.manifestData.sceneOffset.y) or 0), sceneData.position.z + ((assetReference.manifestData.sceneOffset and assetReference.manifestData.sceneOffset.z) or 0)
                                    sceneData.dimension = assetReference.manifestData.sceneDimension
                                    sceneData.interior = assetReference.manifestData.sceneInterior
                                    assetReference.unsyncedData.assetCache[i].cDummy = dummy:create("object", childName, sceneData)
                                end
                                thread.pause()
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
                            asset:create(assetType, assetName, packReference, assetReference.unsyncedData.rwCache, assetReference.manifestData, assetReference.unsyncedData.assetCache[i], {
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
                    if asset:create(assetType, assetName, packReference, assetReference.unsyncedData.rwCache, assetReference.manifestData, assetReference.unsyncedData.assetCache, {
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
                if assetType == "sound" then
                    thread:create(function(cThread)
                        for i, j in imports.pairs(assetReference.unsyncedData.assetCache) do
                            for k, v in imports.pairs(j) do
                                if v.cAsset then
                                    v.cAsset:destroy(assetReference.unsyncedData.rwCache)
                                end
                                thread.pause()
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
                elseif assetType == "scene" then
                    thread:create(function(cThread)
                        for i, j in imports.pairs(assetReference.unsyncedData.assetCache) do
                            if j.cAsset then
                                if j.cAsset.cScene then
                                    j.cAsset.cScene:destroy()
                                end
                                j.cAsset:destroy(assetReference.unsyncedData.rwCache)
                            end
                            if j.cDummy then
                                j.cDummy:destroy()
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

    function manager:loadAnim(element, assetName)
        if not syncer.isLibraryLoaded then return false end
        if not element then return false end
        local cAsset, isLoaded = manager:getData("animation", assetName)
        if not cAsset or not isLoaded then return false end
        if cAsset.manifestData.assetAnimations then
            for i = 1, #cAsset.manifestData.assetAnimations, 1 do
                local j = cAsset.manifestData.assetAnimations[i]
                imports.engineReplaceAnimation(element, j.defaultBlock, j.defaultAnim, "animation."..assetName, j.assetAnim)
            end
        end
        return true
    end

    function manager:unloadAnim(element, assetName)
        if not syncer.isLibraryLoaded then return false end
        if not element then return false end
        local cAsset, isLoaded = manager:getData("animation", assetName)
        if not cAsset or not isLoaded then return false end
        if cAsset.manifestData.assetAnimations then
            for i = 1, #cAsset.manifestData.assetAnimations, 1 do
                local j = cAsset.manifestData.assetAnimations[i]
                imports.engineRestoreAnimation(element, j.defaultBlock, j.defaultAnim)
            end
        end
        return true
    end

    function manager:playSound(assetName, soundCategory, soundIndex, ...)
        if not syncer.isLibraryLoaded then return false end
        if not manager:isLoaded("sound", assetName) then return false end
        local assetReference = availableAssetPacks["sound"].rwDatas[assetName]
        if not assetReference.manifestData.assetSounds or not assetReference.unsyncedData.assetCache[soundCategory] or not assetReference.unsyncedData.assetCache[soundCategory][soundIndex] or not assetReference.unsyncedData.assetCache[soundCategory][soundIndex].cAsset then return false end
        return imports.playSound(assetReference.unsyncedData.rwCache.sound[(assetReference.unsyncedData.assetCache[soundCategory][soundIndex].cAsset.rwPaths.sound)], ...)
    end

    function manager:playSound3D(assetName, soundCategory, soundIndex, ...)
        if not syncer.isLibraryLoaded then return false end
        if not manager:isLoaded("sound", assetName) then return false end
        local assetReference = availableAssetPacks["sound"].rwDatas[assetName]
        if not assetReference.manifestData.assetSounds or not assetReference.unsyncedData.assetCache[soundCategory] or not assetReference.unsyncedData.assetCache[soundCategory][soundIndex] or not assetReference.unsyncedData.assetCache[soundCategory][soundIndex].cAsset then return false end
        return imports.playSound3D(assetReference.unsyncedData.rwCache.sound[(assetReference.unsyncedData.assetCache[soundCategory][soundIndex].cAsset.rwPaths.sound)], ...)
    end
else
    function manager:getData(assetType, assetName)
        if not syncer.isLibraryLoaded then return false end
        if not assetType or not assetName then return false end
        if availableAssetPacks[assetType] then
            local assetReference = availableAssetPacks[assetType].assetPack.rwDatas[assetName]
            if assetReference then
                assetReference = assetReference.synced
                if assetReference.manifestData.encryptKey then
                    assetReference = imports.table.clone(assetReference, true)
                    assetReference.manifestData.encryptKey = nil
                end
                if assetType == "scene" then
                    return assetReference, false
                else
                    return assetReference, false
                end
            end
        end
        return false
    end
end