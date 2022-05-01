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
    isElement = isElement,
    destroyElement = destroyElement,
    addEventHandler = addEventHandler,
    engineReplaceAnimation = engineReplaceAnimation,
    engineRestoreAnimation = engineRestoreAnimation,
    playSound = playSound,
    playSound3D = playSound3D,
    setSoundVolume = setSoundVolume,
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
    manager.buffer = {
        instance = {},
        scoped = {}
    }

    function manager:clearElementBuffer(element, isResource)
        if not element then return false end
        if isResource then
            local resourceScope = manager.buffer.scoped[element]
            if not resourceScope then return false end
            manager.buffer.scoped[element] = nil
            for i, j in imports.pairs(resourceScope) do
                if i and imports.isElement(i) then
                    imports.destroyElement(i)
                end
            end
        else
            if not imports.isElement(element) then return false end
            local elementScope = manager.buffer.instance[element]
            if not elementScope or not manager.buffer.scoped[elementScope] then return false end
            manager.buffer.scoped[elementScope][element] = nil
            manager.buffer.instance[element] = nil
        end
        return true
    end

    function manager:getData(assetType, assetName, isInternal)
        if not syncer.isLibraryLoaded then return false end
        if not assetType or not assetName then return false end
        if availableAssetPacks[assetType] then
            local cAsset = availableAssetPacks[assetType].rwDatas[assetName]
            if cAsset then
                local isExternalResource = sourceResource and (sourceResource ~= resource)
                local unsyncedData = cAsset.unsyncedData
                if (not isInternal or (isInternal ~= syncer.librarySerial)) and isExternalResource then
                    cAsset = imports.table.clone(cAsset, true)
                    cAsset.manifestData.encryptKey = nil
                    cAsset.unsyncedData = nil
                end
                if cAsset.manifestData.assetClumps or (assetType == "module") or (assetType == "animation") or (assetType == "sound") or (assetType == "scene") then
                    return cAsset, (unsyncedData and true) or false
                else
                    return cAsset, (unsyncedData and unsyncedData.assetCache.cAsset and unsyncedData.assetCache.cAsset.syncedData) or false
                end
            end
        end
        return false
    end

    function manager:getID(assetType, assetName, assetClump)
        if (assetType == "module") or (assetType == "animation") or (assetType == "sound") then return false end
        local cAsset, isLoaded = manager:getData(assetType, assetName, syncer.librarySerial)
        if not cAsset or not isLoaded or imports.type(cAsset.unsyncedData) ~= "table" then return false end
        if cAsset.manifestData.assetClumps then
            return (assetClump and cAsset.manifestData.assetClumps[assetClump] and cAsset.unsyncedData.assetCache[assetClump] and cAsset.unsyncedData.assetCache[assetClump].cAsset and cAsset.unsyncedData.assetCache[assetClump].cAsset.syncedData and cAsset.unsyncedData.assetCache[assetClump].cAsset.syncedData.modelID) or false
        else
            return (cAsset.unsyncedData.assetCache.cAsset and cAsset.unsyncedData.assetCache.cAsset.syncedData and cAsset.unsyncedData.assetCache.cAsset.syncedData.modelID) or false
        end
    end

    function manager:isLoaded(assetType, assetName)
        local cAsset, isLoaded = manager:getData(assetType, assetName)
        return (cAsset and isLoaded and true) or false
    end

    function manager:getDep(assetType, assetName, depType, depIndex)
        local cAsset, isLoaded = manager:getData(assetType, assetName, syncer.librarySerial)
        if not cAsset or not isLoaded then return false end
        return (cAsset.manifestData.assetDeps and cAsset.unsyncedData.rwCache.dep[depType] and cAsset.unsyncedData.rwCache.dep[depType][depIndex]) or false
    end

    function manager:load(assetType, assetName)
        local cAsset, isLoaded = manager:getData(assetType, assetName)
        if not cAsset or isLoaded then return false end
        local cAssetPack = availableAssetPacks[assetType]
        local assetPath = (asset.references.root)..assetType.."/"..assetName.."/"
        cAsset.unsyncedData = {
            assetCache = {},
            rwCache = {
                ifp = {},
                sound = {},
                txd = {},
                dff = {},
                col = {},
                map = {},
                dep = {}
            }
        }
        shader:createTex(cAsset.manifestData.shaderMaps, cAsset.unsyncedData.rwCache.map, cAsset.manifestData.encryptKey)
        asset:createDep(cAsset.manifestData.assetDeps, cAsset.unsyncedData.rwCache.dep, cAsset.manifestData.encryptKey, true)
        if cAsset.manifestData.shaderMaps and cAsset.manifestData.shaderMaps.control then
            for i, j in imports.pairs(cAsset.manifestData.shaderMaps.control) do
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
                shader:create(nil, "control", "Assetify_TextureMapper", i, shaderTextures, shaderInputs, cAsset.unsyncedData.rwCache.map, j, cAsset.manifestData.encryptKey)
            end
        end
        if assetType == "module" then
            if asset:create(assetType, assetName, cAssetPack, cAsset.unsyncedData.rwCache, cAsset.manifestData, cAsset.unsyncedData.assetCache, {}) then
                return true
            end
        elseif assetType == "animation" then
            if asset:create(assetType, assetName, cAssetPack, cAsset.unsyncedData.rwCache, cAsset.manifestData, cAsset.unsyncedData.assetCache, {
                ifp = assetPath..(asset.references.asset)..".ifp",
            }) then
                return true
            end
        elseif assetType == "sound" then
            thread:create(function(cThread)
                for i, j in imports.pairs(cAsset.manifestData.assetSounds) do
                    cAsset.unsyncedData.assetCache[i] = {}
                    for k, v in imports.pairs(j) do
                        cAsset.unsyncedData.assetCache[i][k] = {}
                        asset:create(assetType, assetName, cAssetPack, cAsset.unsyncedData.rwCache, cAsset.manifestData, cAsset.unsyncedData.assetCache[i][k], {
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
                sceneManifestData = (cAsset.manifestData.encryptKey and imports.decodeString("tea", sceneManifestData, {key = cAsset.manifestData.encryptKey})) or sceneManifestData
                if sceneManifestData then
                    local unparsedDatas = imports.split(sceneManifestData, "\n")
                    for i = 1, #unparsedDatas, 1 do
                        cAsset.unsyncedData.assetCache[i] = {}
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
                        if not cAsset.manifestData.sceneMapped then
                            asset:create(assetType, assetName, cAssetPack, cAsset.unsyncedData.rwCache, cAsset.manifestData, cAsset.unsyncedData.assetCache[i], {
                                txd = assetPath..(asset.references.asset)..".txd",
                                dff = assetPath.."dff/"..childName..".dff",
                                col = assetPath.."col/"..childName..".col"
                            }, function(state)
                                if state then
                                    scene:create(cAsset.unsyncedData.assetCache[i].cAsset, cAsset.manifestData, sceneData)
                                end
                            end)
                        else
                            sceneData.position.x, sceneData.position.y, sceneData.position.z = sceneData.position.x + ((cAsset.manifestData.sceneOffset and cAsset.manifestData.sceneOffset.x) or 0), sceneData.position.y + ((cAsset.manifestData.sceneOffset and cAsset.manifestData.sceneOffset.y) or 0), sceneData.position.z + ((cAsset.manifestData.sceneOffset and cAsset.manifestData.sceneOffset.z) or 0)
                            sceneData.dimension = cAsset.manifestData.sceneDimension
                            sceneData.interior = cAsset.manifestData.sceneInterior
                            cAsset.unsyncedData.assetCache[i].cDummy = dummy:create("object", childName, sceneData)
                        end
                        thread.pause()
                    end
                end
            end):resume({
                executions = downloadSettings.buildRate,
                frames = 1
            })
            return true
        elseif cAsset.manifestData.assetClumps then
            thread:create(function(cThread)
                for i, j in imports.pairs(cAsset.manifestData.assetClumps) do
                    cAsset.unsyncedData.assetCache[i] = {}
                    local clumpTXD, clumpDFF, clumpCOL = assetPath.."clump/"..j.."/"..(asset.references.asset)..".txd", assetPath.."clump/"..j.."/"..(asset.references.asset)..".dff", assetPath.."clump/"..j.."/"..(asset.references.asset)..".col"
                    clumpTXD = (imports.file.exists(clumpTXD) and clumpTXD) or assetPath..(asset.references.asset)..".txd"
                    clumpCOL = (imports.file.exists(clumpCOL) and clumpCOL) or assetPath..(asset.references.asset)..".col"
                    asset:create(assetType, assetName, cAssetPack, cAsset.unsyncedData.rwCache, cAsset.manifestData, cAsset.unsyncedData.assetCache[i], {
                        txd = clumpTXD,
                        dff = clumpDFF,
                        col = clumpCOL
                    })
                    thread.pause()
                end
            end):resume({
                executions = downloadSettings.buildRate,
                frames = 1
            })
            return true
        else
            if asset:create(assetType, assetName, cAssetPack, cAsset.unsyncedData.rwCache, cAsset.manifestData, cAsset.unsyncedData.assetCache, {
                txd = assetPath..(asset.references.asset)..".txd",
                dff = assetPath..(asset.references.asset)..".dff",
                col = assetPath..(asset.references.asset)..".col"
            }) then
                return true
            end
        end
        return false
    end

    function manager:unload(assetType, assetName)
        local cAsset, isLoaded = manager:getData(assetType, assetName)
        if not cAsset or not isLoaded then return false end
        if assetType == "sound" then
            thread:create(function(cThread)
                for i, j in imports.pairs(cAsset.unsyncedData.assetCache) do
                    for k, v in imports.pairs(j) do
                        if v.cAsset then
                            v.cAsset:destroy(cAsset.unsyncedData.rwCache)
                        end
                        thread.pause()
                    end
                    thread.pause()
                end
                shader:clearAssetBuffer(cAsset.unsyncedData.rwCache.map)
                asset:clearAssetBuffer(cAsset.unsyncedData.rwCache.dep)
                cAsset.unsyncedData = nil
                imports.collectgarbage()
            end):resume({
                executions = downloadSettings.buildRate,
                frames = 1
            })
            return true
        elseif assetType == "scene" then
            thread:create(function(cThread)
                for i, j in imports.pairs(cAsset.unsyncedData.assetCache) do
                    if j.cAsset then
                        if j.cAsset.cScene then
                            j.cAsset.cScene:destroy()
                        end
                        j.cAsset:destroy(cAsset.unsyncedData.rwCache)
                    end
                    if j.cDummy then
                        j.cDummy:destroy()
                    end
                    thread.pause()
                end
                shader:clearAssetBuffer(cAsset.unsyncedData.rwCache.map)
                asset:clearAssetBuffer(cAsset.unsyncedData.rwCache.dep)
                cAsset.unsyncedData = nil
                imports.collectgarbage()
            end):resume({
                executions = downloadSettings.buildRate,
                frames = 1
            })
            return true
        elseif cAsset.manifestData.assetClumps then
            thread:create(function(cThread)
                for i, j in imports.pairs(cAsset.unsyncedData.assetCache) do
                    if j.cAsset then
                        j.cAsset:destroy(cAsset.unsyncedData.rwCache)
                    end
                    thread.pause()
                end
                shader:clearAssetBuffer(cAsset.unsyncedData.rwCache.map)
                asset:clearAssetBuffer(cAsset.unsyncedData.rwCache.dep)
                cAsset.unsyncedData = nil
                imports.collectgarbage()
            end):resume({
                executions = downloadSettings.buildRate,
                frames = 1
            })
            return true
        else
            if cAsset.cAsset then
                cAsset.cAsset:destroy(cAsset.unsyncedData.rwCache)
                
                shader:clearAssetBuffer(cAsset.unsyncedData.rwCache.map)
                cAsset.unsyncedData = nil
                imports.collectgarbage()
                return true
            end
        end
        return false
    end

    imports.addEventHandler("onClientResourceStop", root, function(stoppedResource)
        manager:clearElementBuffer(stoppedResource, true)
    end)

    imports.addEventHandler("onClientElementDestroy", root, function()
        shader:clearElementBuffer(source)
        dummy:clearElementBuffer(source)
        bone:clearElementBuffer(source)
        manager:clearElementBuffer(source)
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

    function manager:playSound(assetName, soundCategory, soundIndex, soundVolume, isScoped, ...)
        local cAsset, isLoaded = manager:getData("sound", assetName, syncer.librarySerial)
        if not cAsset or not isLoaded then return false end
        if not cAsset.manifestData.assetSounds or not cAsset.unsyncedData.assetCache[soundCategory] or not cAsset.unsyncedData.assetCache[soundCategory][soundIndex] or not cAsset.unsyncedData.assetCache[soundCategory][soundIndex].cAsset then return false end
        local cSound = imports.playSound(cAsset.unsyncedData.rwCache.sound[(cAsset.unsyncedData.assetCache[soundCategory][soundIndex].cAsset.rwPaths.sound)], ...)
        if cSound then
            if soundVolume then imports.setSoundVolume(cSound, soundVolume) end
            if isScoped and sourceResource and (sourceResource ~= resource) then
                manager.buffer.instance[cSound] = sourceResource
                manager.buffer.scoped[sourceResource] = manager.buffer.scoped[sourceResource] or {}
                manager.buffer.scoped[sourceResource][cSound] = true
            end
        end
        return cSound
    end

    function manager:playSound3D(assetName, soundCategory, soundIndex, soundVolume, isScoped, ...)
        local cAsset, isLoaded = manager:getData("sound", assetName, syncer.librarySerial)
        if not cAsset or not isLoaded then return false end
        if not cAsset.manifestData.assetSounds or not cAsset.unsyncedData.assetCache[soundCategory] or not cAsset.unsyncedData.assetCache[soundCategory][soundIndex] or not cAsset.unsyncedData.assetCache[soundCategory][soundIndex].cAsset then return false end
        local cSound = imports.playSound3D(cAsset.unsyncedData.rwCache.sound[(cAsset.unsyncedData.assetCache[soundCategory][soundIndex].cAsset.rwPaths.sound)], ...)
        if cSound then
            if soundVolume then imports.setSoundVolume(cSound, soundVolume) end
            if isScoped and sourceResource and (sourceResource ~= resource) then
                manager.buffer.instance[cSound] = sourceResource
                manager.buffer.scoped[sourceResource] = manager.buffer.scoped[sourceResource] or {}
                manager.buffer.scoped[sourceResource][cSound] = true
            end
        end
        return cSound
    end
else
    function manager:getData(assetType, assetName, isInternal)
        if not syncer.isLibraryLoaded then return false end
        if not assetType or not assetName then return false end
        if availableAssetPacks[assetType] then
            local cAsset = availableAssetPacks[assetType].assetPack.rwDatas[assetName]
            if cAsset then
                if (not isInternal or (isInternal ~= syncer.librarySerial)) and isExternalResource then
                    cAsset = cAsset.synced
                    if cAsset.manifestData.encryptKey then
                        cAsset = imports.table.clone(cAsset, true)
                        cAsset.manifestData.encryptKey = nil
                    end
                end
                return cAsset, false
            end
        end
        return false
    end

    function manager:getDep(assetType, assetName, depType, depIndex)
        local cAsset = manager:getData(assetType, assetName, syncer.librarySerial)
        if not cAsset then return false end
        return (cAsset.synced.manifestData.assetDeps and cAsset.synced.manifestData.assetDeps[depType] and cAsset.synced.manifestData.assetDeps[depType][depIndex] and cAsset.unSynced.rawData[(cAsset.synced.manifestData.assetDeps[depType][depIndex])]) or false
    end
end