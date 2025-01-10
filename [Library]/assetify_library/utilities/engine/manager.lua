----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: engine: manager.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Manager Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    tonumber = tonumber,
    tostring = tostring,
    loadstring = loadstring,
    collectgarbage = collectgarbage,
    isElement = isElement,
    getElementType = getElementType,
    destroyElement = destroyElement,
    addEventHandler = addEventHandler
}


------------------------
--[[ Class: Manager ]]--
------------------------

local manager = class:create("manager", {
    API = {}
})
manager.private.rwFormat = {
    assetRef = {}, assetCache = {},
    rwCache = {
        ifp = {},
        sound = {}, 
        txd = {},
        dff = {},
        lod = {},
        col = {},
        map = {},
        replace = {},
        dep = {}
    }
}
manager.private.buffer = {
    instance = {},
    scoped = {}
}

function manager.public:isInternal(serial)
    local isExternal = sourceResource and (sourceResource ~= syncer.libraryResource)
    return (not isExternal and not serial and true) or (serial and (serial == syncer.librarySerial)) or false
end

function manager.public:exportAPI(moduleName, moduleAPIs)
    if not moduleName or (imports.type(moduleName) ~= "string") or not moduleAPIs or (imports.type(moduleAPIs) ~= "table") then return false end
    manager.public.API[moduleName] = {}
    for i, j in imports.pairs(moduleAPIs) do
        if (i  == "shared") or (i == ((localPlayer and "client") or "server")) then
            for k = 1, table.length(j), 1 do
                local v = j[k]
                imports.loadstring([[
                    local ref = false
                    function ]]..v.name..[[(...)
                        ref = ref or manager.API.]]..moduleName..[[.]]..(v.API or v.name)..[[
                        return ref(...)
                    end
                ]])()
            end
        end
    end
    return true
end

function manager.public:fetchAssets(assetType)
    if not syncer.isLibraryLoaded or not assetType or not settings.assetPacks[assetType] then return false end
    local cAssets = {}
    if localPlayer then
        if settings.assetPacks[assetType].rwDatas then
            for i, j in imports.pairs(settings.assetPacks[assetType].rwDatas) do
                table.insert(cAssets, i)
            end
        end
    else
        for i, j in imports.pairs(settings.assetPacks[assetType].assetPack.manifest) do
            if settings.assetPacks[assetType].assetPack.rwDatas[j] then
                table.insert(cAssets, j)
            end
        end
    end
    return cAssets
end

function manager.public:setElementScoped(element)
    if manager.public:isInternal() then return false end
    manager.private.buffer.instance[element] = sourceResource
    manager.private.buffer.scoped[sourceResource] = manager.private.buffer.scoped[sourceResource] or {}
    manager.private.buffer.scoped[sourceResource][element] = true
    return true
end

function manager.public.clearElementBuffer(element, isResource)
    if not element then return false end
    if isResource then
        local resourceScope = manager.private.buffer.scoped[element]
        if not resourceScope then return false end
        for i, j in imports.pairs(resourceScope) do
            imports.destroyElement(i)
        end
    else
        if not imports.isElement(element) then return false end
        local elementScope = manager.private.buffer.instance[element]
        if not elementScope or not manager.private.buffer.scoped[elementScope] then return false end
        manager.private.buffer.scoped[elementScope][element] = nil
    end
    manager.private.buffer.instance[element], manager.private.buffer.scoped[element] = nil, nil
    return true
end

if localPlayer then
    function manager.private:createDep(cAsset)
        if not cAsset then return false end
        shader:createTex(cAsset.manifest.shaderMaps, cAsset.unsynced.rwCache.map, cAsset.manifest.encryptOptions)
        asset:createReplacement(cAsset.manifest.assetReplacements, cAsset.unsynced.rwCache.replace, cAsset.manifest.encryptOptions)
        asset:createDep(cAsset.manifest.assetDeps, cAsset.unsynced.rwCache.dep, cAsset.manifest.encryptOptions)
        if cAsset.manifest.shaderMaps and cAsset.manifest.shaderMaps.control then
            for i, j in imports.pairs(cAsset.manifest.shaderMaps.control) do
                local shaderTextures, shaderInputs = {}, {}
                for k = 1, table.length(j), 1 do
                    local v = j[k]
                    if v.control then shaderTextures[("controlTex_"..k)] = v.control end
                    if v.bump then shaderTextures[("controlTex_"..k.."_bump")] = v.bump end
                    for x = 1, table.length(shader.validChannels), 1 do
                        local y = shader.validChannels[x]
                        if v[(y.index)] then
                            shaderTextures[("controlTex_"..k.."_"..(y.index))] = v[(y.index)].map
                            shaderInputs[("controlScale_"..k.."_"..(y.index))] = v[(y.index)].scale
                            if v[(y.index)].bump then shaderTextures[("controlTex_"..k.."_"..(y.index).."_bump")] = v[(y.index)].bump end
                        end
                    end
                end
                shader:create(nil, "Assetify | Control", "Assetify_TextureMapper", i, shaderTextures, shaderInputs, cAsset.unsynced.rwCache.map, j, _, _, _, syncer.librarySerial)
            end
        end
        return true
    end

    function manager.private:freeAsset(cAsset)
        if not cAsset then return false end
        shader.clearAssetBuffer(cAsset.unsynced.rwCache.map)
        asset.clearAssetBuffer(cAsset.unsynced.rwCache.replace)
        asset.clearAssetBuffer(cAsset.unsynced.rwCache.dep)
        cAsset.unsynced = nil
        imports.collectgarbage("collect")
        return true
    end

    function manager.public:getDownloadProgress(assetType, assetName)
        local cDownloaded, cBandwidth, cETA = nil, nil, nil
        if assetType and assetName then
            if not settings.assetPacks[assetType] or not settings.assetPacks[assetType].rwDatas[assetName] then return false end
            local cPointer = settings.assetPacks[assetType].rwDatas[assetName]
            cBandwidth = cPointer.bandwidthData.total
            cDownloaded = (cPointer.bandwidthData.isDownloaded and cBandwidth) or (cPointer.bandwidthData.status and cPointer.bandwidthData.status.total) or 0
            cETA = (not cPointer.bandwidthData.isDownloaded and cPointer.bandwidthData.status and (cPointer.bandwidthData.status.eta/math.max(1, cPointer.bandwidthData.status.eta_count))) or false
        else
            cBandwidth = syncer.libraryBandwidth.total
            cDownloaded = ((syncer.libraryBandwidth.isDownloaded or syncer.isLibraryLoaded) and cBandwidth) or (syncer.libraryBandwidth.status and syncer.libraryBandwidth.status.total) or 0
            cETA = (not syncer.libraryBandwidth.isDownloaded and not syncer.isLibraryLoaded and syncer.libraryBandwidth.status and (syncer.libraryBandwidth.status.eta/math.max(1, syncer.libraryBandwidth.status.eta_count))) or false
        end
        return cDownloaded, cBandwidth, (cDownloaded/math.max(1, cBandwidth))*100, cETA
    end

    function manager.public:getResourceDownloadProgress()
        if manager.public:isInternal() then return false end
        return resource:getDownloadProgress(sourceResource)
    end

    function manager.public:isAssetLoaded(assetType, assetName)
        local cAsset, isLoaded = manager.public:getAssetData(assetType, assetName)
        return (cAsset and isLoaded and true) or false
    end

    function manager.public:getAssetID(assetType, assetName, assetClump)
        if (assetType == "module") or (assetType == "animation") or (assetType == "sound") then return false end
        local cAsset, isLoaded = manager.public:getAssetData(assetType, assetName, syncer.librarySerial)
        if not cAsset or not isLoaded or imports.type(cAsset.unsynced) ~= "table" then return false end
        if cAsset.manifest.assetClumps then
            return (assetClump and cAsset.manifest.assetClumps[assetClump] and cAsset.unsynced.assetCache[assetClump] and cAsset.unsynced.assetCache[assetClump].cAsset and cAsset.unsynced.assetCache[assetClump].cAsset.synced and cAsset.unsynced.assetCache[assetClump].cAsset.synced.modelID) or false
        else
            return (cAsset.unsynced.assetCache.cAsset and cAsset.unsynced.assetCache.cAsset.synced and cAsset.unsynced.assetCache.cAsset.synced.modelID) or false
        end
    end

    function manager.public:getAssetData(assetType, assetName, isInternal)
        if not assetType or not assetName then return false end
        if not settings.assetPacks[assetType] then return false end
        local cAsset = settings.assetPacks[assetType].rwDatas[assetName]
        if not cAsset then return false end
        local unsynced = cAsset.unsynced
        if not manager.public:isInternal(isInternal) then
            cAsset = table.clone(cAsset, true)
            cAsset.manifest.encryptOptions = nil
            cAsset.unsynced = nil
        end
        if cAsset.manifest.assetClumps or (assetType == "module") or (assetType == "animation") or (assetType == "sound") or (assetType == "scene") then
            return cAsset, (unsynced and true) or false
        else
            return cAsset, (unsynced and unsynced.assetCache.cAsset and unsynced.assetCache.cAsset.synced) or false
        end
    end

    function manager.public:getAssetDep(assetType, assetName, depType, depIndex, depSubIndex)
        local cAsset, isLoaded = manager.public:getAssetData(assetType, assetName, syncer.librarySerial)
        if not cAsset or not isLoaded then return false end
        if not depType or not depIndex or not cAsset.manifest.assetDeps or not cAsset.manifest.assetDeps[depType] or not cAsset.manifest.assetDeps[depType][depIndex] or ((imports.type(cAsset.manifest.assetDeps[depType][depIndex]) == "table") and (not depSubIndex or not cAsset.manifest.assetDeps[depType][depIndex][depSubIndex])) then return false end
        if depSubIndex then
            return cAsset.unsynced.rwCache.dep[depType][depIndex][depSubIndex] or false
        else
            return cAsset.unsynced.rwCache.dep[depType][depIndex] or false
        end
    end

    function manager.public:loadAsset(assetType, assetName)
        local cAsset, isLoaded = manager.public:getAssetData(assetType, assetName, syncer.librarySerial)
        if not cAsset or isLoaded then return false end
        local cAssetPack = settings.assetPacks[assetType]
        local assetPath = asset.references.root..assetType.."/"..assetName.."/"
        cAsset.unsynced = table.clone(manager.private.rwFormat, true)
        manager.private:createDep(cAsset)
        if assetType == "module" then
            if not asset:create(assetType, assetName, cAssetPack, cAsset.unsynced.rwCache, cAsset.manifest, cAsset.unsynced.assetCache, {}) then return false end
        elseif assetType == "animation" then
            if not asset:create(assetType, assetName, cAssetPack, cAsset.unsynced.rwCache, cAsset.manifest, cAsset.unsynced.assetCache, {
                ifp = assetPath..asset.references.asset..".ifp"
            }) then return false end
        elseif assetType == "sound" then
            for i, j in imports.pairs(cAsset.manifest.assetSounds) do
                cAsset.unsynced.assetCache[i] = {}
                for k, v in imports.pairs(j) do
                    cAsset.unsynced.assetCache[i][k] = {}
                    asset:create(assetType, assetName, cAssetPack, cAsset.unsynced.rwCache, cAsset.manifest, cAsset.unsynced.assetCache[i][k], {
                        sound = assetPath.."sound/"..v,
                    })
                end
            end
        elseif assetType == "scene" then
            local sceneIPLDatas = scene:parseIPL(asset:readFile(assetPath..asset.references.scene..".ipl", cAsset.manifest.encryptOptions), cAsset.manifest.sceneNativeObjects)
            if sceneIPLDatas then
                local sceneIDEDatas = scene:parseIDE(asset:readFile(assetPath..asset.references.scene..".ide", cAsset.manifest.encryptOptions))
                for i = 1, table.length(sceneIPLDatas), 1 do
                    local j = sceneIPLDatas[i]
                    local sceneData = {
                        position = {x = imports.tonumber(j[4]), y = imports.tonumber(j[5]), z = imports.tonumber(j[6])},
                        rotation = {}
                    }
                    local cQuat = math.quat(imports.tonumber(j[7]), imports.tonumber(j[8]), imports.tonumber(j[9]), imports.tonumber(j[10]))
                    sceneData.rotation.x, sceneData.rotation.y, sceneData.rotation.z = cQuat:toEuler()
                    cQuat:destroy()
                    if not cAsset.manifest.sceneMapped then
                        if not cAsset.unsynced.assetRef[(j[2])] then
                            cAsset.unsynced.assetCache[i] = {}
                            if not j.nativeID then
                                local childTXDPath = assetPath..asset.references.txd.."/"..j[2]..".txd"
                                asset:create(assetType, assetName, cAssetPack, cAsset.unsynced.rwCache, cAsset.manifest, cAsset.unsynced.assetCache[i], {
                                    txd = (sceneIDEDatas and sceneIDEDatas[(j[2])] and assetPath..asset.references.txd.."/"..(sceneIDEDatas[(j[2])][1])..".txd") or (file:exists(childTXDPath) and childTXDPath) or assetPath..asset.references.asset..".txd",
                                    dff = assetPath..asset.references.dff.."/"..j[2]..".dff",
                                    lod = assetPath..asset.references.dff.."/"..asset.references.lod.."/"..j[2]..".dff",
                                    col = assetPath..asset.references.col.."/"..j[2]..".col"
                                }, (sceneIDEDatas and sceneIDEDatas[(j[2])] and sceneIDEDatas[(j[2])][2]) or false)
                            else
                                cAsset.unsynced.assetCache[i].isNativeModel = true
                                cAsset.unsynced.assetCache[i].cAsset = {nativeID = j.nativeID, nativeLOD = j.nativeLOD}
                            end
                            cAsset.unsynced.assetRef[(j[2])] = cAsset.unsynced.assetCache[i].cAsset
                        end
                        scene:create(cAsset.unsynced.assetRef[(j[2])], cAsset.manifest, sceneData)
                    else
                        cAsset.unsynced.assetCache[i] = {}
                        sceneData.position.x, sceneData.position.y, sceneData.position.z = sceneData.position.x + ((cAsset.manifest.sceneOffsets and cAsset.manifest.sceneOffsets.x) or 0), sceneData.position.y + ((cAsset.manifest.sceneOffsets and cAsset.manifest.sceneOffsets.y) or 0), sceneData.position.z + ((cAsset.manifest.sceneOffsets and cAsset.manifest.sceneOffsets.z) or 0)
                        sceneData.dimension = cAsset.manifest.sceneDimension
                        sceneData.interior = cAsset.manifest.sceneInterior
                        --TODO: DETECT IF ITS CLUMPED OR NOT...
                        --cAsset.unsynced.assetCache[i].cDummy = dummy:create("object", j[2], _, _, SsceneData)
                    end
                end
            end
        elseif cAsset.manifest.assetClumps then
            for i, j in imports.pairs(cAsset.manifest.assetClumps) do
                cAsset.unsynced.assetCache[i] = {}
                local clumpTXD, clumpDFF, clumpCOL = assetPath..asset.references.clump.."/"..j.."/"..asset.references.asset..".txd", assetPath..asset.references.clump.."/"..j.."/"..asset.references.asset..".dff", assetPath..asset.references.clump.."/"..j.."/"..asset.references.asset..".col"
                clumpTXD = (file:exists(clumpTXD) and clumpTXD) or assetPath..asset.references.asset..".txd"
                clumpCOL = (file:exists(clumpCOL) and clumpCOL) or assetPath..asset.references.asset..".col"
                asset:create(assetType, assetName, cAssetPack, cAsset.unsynced.rwCache, cAsset.manifest, cAsset.unsynced.assetCache[i], {
                    txd = clumpTXD,
                    dff = clumpDFF,
                    col = clumpCOL
                })
            end
        else
            if not asset:create(assetType, assetName, cAssetPack, cAsset.unsynced.rwCache, cAsset.manifest, cAsset.unsynced.assetCache, {
                txd = assetPath..asset.references.asset..".txd",
                dff = assetPath..asset.references.asset..".dff",
                col = assetPath..asset.references.asset..".col"
            }) then return false end
        end
        network:emit("Assetify:onAssetLoad", false, assetType, assetName)
        return true
    end

    function manager.public:unloadAsset(assetType, assetName)
        local cAsset, isLoaded = manager.public:getAssetData(assetType, assetName, syncer.librarySerial)
        if not cAsset or not isLoaded then return false end
        if assetType == "sound" then
            for i, j in imports.pairs(cAsset.unsynced.assetCache) do
                for k, v in imports.pairs(j) do
                    if v.cAsset then v.cAsset:destroy(cAsset.unsynced.rwCache) end
                end
            end
        elseif assetType == "scene" then
            for i, j in imports.pairs(cAsset.unsynced.assetCache) do
                if j.cAsset then
                    for i, j in imports.pairs(j.cAsset.cScenes) do
                        if i and j then i:destroy() end
                    end
                    if not j.isNativeModel then j.cAsset:destroy(cAsset.unsynced.rwCache) end
                end
                if j.cDummy then j.cDummy:destroy() end
            end
        elseif cAsset.manifest.assetClumps then
            for i, j in imports.pairs(cAsset.unsynced.assetCache) do
                if j.cAsset then j.cAsset:destroy(cAsset.unsynced.rwCache) end
            end
        else
            return false
        end
        manager.private:freeAsset(cAsset)
        network:emit("Assetify:onAssetUnload", false, assetType, assetName)
        return true
    end
else
    function manager.public:getAssetData(assetType, assetName, isInternal)
        if not assetType or not assetName then return false end
        if not settings.assetPacks[assetType] then return false end
        local cAsset = settings.assetPacks[assetType].assetPack.rwDatas[assetName]
        if not cAsset then return false end
        if not manager.public:isInternal(isInternal) then
            cAsset = table.clone(cAsset.synced, true)
            cAsset.manifest.encryptOptions = nil
        end
        return cAsset, false
    end

    function manager.public:getAssetDep(assetType, assetName, depType, depIndex, depSubIndex)
        local cAsset = manager.public:getAssetData(assetType, assetName, syncer.librarySerial)
        if not cAsset then return false end
        if not depType or not depIndex or not cAsset.synced.manifest.assetDeps or not cAsset.synced.manifest.assetDeps[depType] or not cAsset.synced.manifest.assetDeps[depType][depIndex] or ((imports.type(cAsset.synced.manifest.assetDeps[depType][depIndex]) == "table") and (not depSubIndex or not cAsset.synced.manifest.assetDeps[depType][depIndex][depSubIndex])) then return false end
        return (depSubIndex and cAsset.unsynced.raw[(cAsset.synced.manifest.assetDeps[depType][depIndex][depSubIndex])]) or cAsset.unsynced.raw[(cAsset.synced.manifest.assetDeps[depType][depIndex])] or false
    end
end


---------------------
--[[ API Syncers ]]--
---------------------

network:fetch("Assetify:onResourceUnload"):on(function(_, resourceSource)
    manager.public.clearElementBuffer(resourceSource, true)
end)
network:fetch("Assetify:onElementDestroy"):on(function(source)
    if not syncer.isLibraryBooted or not source then return false end
    manager.public.clearElementBuffer(source)
end)