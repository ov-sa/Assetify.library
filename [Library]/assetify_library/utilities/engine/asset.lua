----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: engine: asset.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Asset Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    sha256 = sha256,
    tonumber = tonumber,
    tostring = tostring,
    outputServerLog = outputServerLog,
    outputDebugString = outputDebugString,
    destroyElement = destroyElement,
    engineRequestModel = engineRequestModel,
    engineSetModelLODDistance = engineSetModelLODDistance,
    engineRestreamWorld = engineRestreamWorld,
    engineFreeModel = engineFreeModel,
    engineLoadIFP = engineLoadIFP,
    engineLoadTXD = engineLoadTXD,
    engineLoadDFF = engineLoadDFF,
    engineLoadCOL = engineLoadCOL,
    engineImportTXD = engineImportTXD,
    engineReplaceModel = engineReplaceModel,
    engineReplaceCOL = engineReplaceCOL
}


----------------------
--[[ Class: Asset ]]--
----------------------

local asset = class:create("asset", {
    references = {
        root = ((settings.downloader.isAccessSafe and "@") or "").."files/assets/",
        manifest = "manifest",
        asset = "asset",
        cache = ".cache",
        scene = "scene",
        clump = "clump",
        control = "control",
        txd = "txd", dff = "dff", lod = "lod", col = "col",
        map = "map", replace = "replace", dep = "dep"
    },
    replacements = {"txd", "dff", "col"},
    ranges = {
        dimension = {-1, 65535},
        interior = {0, 255},
        stream = 170
    },
    encryptions = {
        ["tea"] = {},
        ["aes128"] = {keylength = 16, ivlength = 16}
    },
    properties = {
        reserved = {},
        whitelisted = {
            ["module"] = {},
            ["animation"] = {"assetAnimations"},
            ["sound"] = {"assetSounds"},
            ["scene"] = {"sceneBuildings", "sceneMapped", "sceneLODs", "sceneDoublesided", "sceneNativeObjects", "sceneDefaultStreamer", "sceneDimension", "sceneInterior", "sceneOffsets", "streamRange", "shaderMaps"},
            ["*"] = {"streamRange", "assetClumps", "shaderMaps"}
        }
    }
})
for i, j in imports.pairs(asset.private.properties.whitelisted) do
    for k = 1, table.length(j), 1 do
        local v = j[k]
        asset.private.properties.reserved[v] = true
        j[v] = true
        j[k] = nil
    end
end

function asset.public:readFile(filePath, encryptOptions, ...)
    if not filePath or (imports.type(filePath) ~= "string") or not file:exists(filePath) then return false end
    local rw = file:read(filePath)
    if not rw then return false end
    return (not encryptOptions and rw) or string.decode(rw, encryptOptions.mode, {key = encryptOptions.key, iv = (encryptOptions.iv and string.decode(encryptOptions.iv[imports.sha256(filePath)], "base64")) or nil}, ...) or false
end

function asset.private:validateMap(filePointer, filePath, mapPointer)
    local mapPath = ((filePointer and filePath) and filePointer..filePath) or false
    if mapPointer and mapPath then mapPointer[mapPath] = true end
    return mapPath
end

function asset.private:fetchMap(assetPath, shaderMaps)
    local cPointer, cMaps = (assetPath and assetPath..asset.public.references.map.."/") or "", {}
    for i, j in imports.pairs(shader.validTypes) do
        local mapData = shaderMaps[i] 
        if j and mapData then
            for k, v in imports.pairs(mapData) do
                if i == asset.public.references.clump then
                    for m, n in imports.pairs(v) do
                        n.clump = asset.private:validateMap(cPointer, n.clump, cMaps)
                        n.bump = asset.private:validateMap(cPointer, n.bump, cMaps)
                    end
                elseif i == asset.public.references.control then
                    for m = 1, table.length(v), 1 do
                        local n = v[m]
                        n.control = asset.private:validateMap(cPointer, n.control, cMaps)
                        n.bump = asset.private:validateMap(cPointer, n.bump, cMaps)
                        for x = 1, table.length(shader.validChannels), 1 do
                            local y = shader.validChannels[x].index
                            if n[y] then
                                n[y].map = asset.private:validateMap(cPointer, n[y].map, cMaps)
                                n[y].bump = asset.private:validateMap(cPointer, n[y].bump, cMaps)
                            end
                        end
                    end
                end
            end
        end
    end
    return cMaps
end

if localPlayer then
    asset.public.rwAssets = {
        txd = imports.engineLoadTXD("utilities/rw/mesh_void/dict.rw"),
        dff = imports.engineLoadDFF("utilities/rw/mesh_void/buffer.rw")
    }

    function asset.public:create(...)
        local cAsset = self:createInstance()
        if cAsset and not cAsset:load(...) then
            cAsset:destroyInstance()
            return false
        end
        return cAsset
    end

    function asset.public:buildShader(shaderMaps)
        return asset.private:fetchMap(_, shaderMaps)
    end

    function asset.public:createReplacement(cAsset)
        if not cAsset or not cAsset.manifest.assetReplacements then return false end
        for i, j in imports.pairs(cAsset.manifest.encryptOptions) do
            j.LODDistance = imports.tonumber(j.LODDistance)
            j.isTransparency = (j.isTransparency and true) or false
            for k = 1, table.length(asset.public.replacements) do
                local v = asset.public.replacements[k]
                if j[v] then
                    cAsset.unsynced.rwCache.replace[v] = {}
                    if v == "txd" then
                        cAsset.unsynced.rwCache.replace[v][j[v]] = cAsset.unsynced.rwCache.replace[v][j[v]] or (v and file:exists(j[v]) and imports.engineLoadTXD(asset.public:readFile(j[v], cAsset.manifest.encryptOptions))) or false
                        if cAsset.unsynced.rwCache.replace[v][j[v]] then imports.engineImportTXD(cAsset.unsynced.rwCache.replace[v][j[v]], i) end
                    elseif v == "dff" then
                        cAsset.unsynced.rwCache.replace[v][j[v]] = cAsset.unsynced.rwCache.replace[v][j[v]] or (v and file:exists(j[v]) and imports.engineLoadDFF(asset.public:readFile(j[v], cAsset.manifest.encryptOptions), j.isTransparency)) or false
                        if cAsset.unsynced.rwCache.replace[v][j[v]] then imports.engineReplaceModel(cAsset.unsynced.rwCache.replace[v][j[v]], i) end
                    elseif v == "col" then
                        cAsset.unsynced.rwCache.replace[v][j[v]] = cAsset.unsynced.rwCache.replace[v][j[v]] or (v and file:exists(j[v]) and imports.engineLoadCOL(asset.public:readFile(j[v], cAsset.manifest.encryptOptions))) or false
                        if cAsset.unsynced.rwCache.replace[v][j[v]] then imports.engineReplaceCOL(cAsset.unsynced.rwCache.replace[v][j[v]], i) end
                    end
                end
            end
            if j.LODDistance then imports.engineSetModelLODDistance(i, j.LODDistance, true) end
        end
        imports.engineRestreamWorld(true)
        return true
    end
    
    function asset.public:createDep(cAsset)
        if not cAsset or not cAsset.manifest.assetDeps then return false end
        for i, j in imports.pairs(cAsset.manifest.assetDeps) do
            cAsset.unsynced.rwCache.dep[i] = {}
            for k, v in imports.pairs(j) do
                if i == "script" then
                    cAsset.unsynced.rwCache.dep[i][k] = {}
                    if k ~= "server" then
                        for m, n in imports.pairs(v) do
                            cAsset.unsynced.rwCache.dep[i][k][m] = asset.public:readFile(n, cAsset.manifest.encryptOptions, true)
                        end
                    end
                elseif i == "texture" then
                    cAsset.unsynced.rwCache.dep[i][k] = shader:loadTex(v, cAsset.manifest.encryptOptions)
                else
                    cAsset.unsynced.rwCache.dep[i][k] = asset.public:readFile(v, cAsset.manifest.encryptOptions)
                end
            end
        end
        return true
    end

    function asset.public:destroy(...)
        if not asset.public:isInstance(self) then return false end
        return self:unload(...)
    end

    function asset.public.clearAssetBuffer(rwCache)
        if not rwCache then return false end
        for i, j in imports.pairs(rwCache) do
            if imports.type(j) == "table" then
                asset.public.clearAssetBuffer(j)
            else
                imports.destroyElement(j)
                rwCache[i] = nil
            end
        end
        return true
    end

    function asset.public:load(assetType, assetName, assetPack, rwCache, assetManifest, assetData, rwPaths, rwStreamRange)
        rwStreamRange = imports.tonumber(rwStreamRange) or assetManifest.streamRange
        if not asset.public:isInstance(self) then return false end
        if not assetType or not assetName or not assetPack or not rwCache or not assetManifest or not assetData or not rwPaths then return false end
        local result = false
        if assetType == "module" then
            assetData.cAsset = self
            self.rwPaths = rwPaths
            result = true
        elseif assetType == "animation" then
            rwCache.ifp[rwPaths.ifp] = rwCache.ifp[rwPaths.ifp] or (rwPaths.ifp and file:exists(rwPaths.ifp) and imports.engineLoadIFP(asset.public:readFile(rwPaths.ifp, assetManifest.encryptOptions), assetType.."."..assetName)) or false
            if rwCache.ifp[rwPaths.ifp] then
                assetData.cAsset = self
                self.rwPaths = rwPaths
                result = true
            end
        elseif assetType == "sound" then
            rwCache.sound[rwPaths.sound] = rwCache.sound[rwPaths.sound] or (rwPaths.sound and file:exists(rwPaths.sound) and asset.public:readFile(rwPaths.sound, assetManifest.encryptOptions)) or false
            if rwCache.sound[rwPaths.sound] then
                assetData.cAsset = self
                self.rwPaths = rwPaths
                result = true
            end
        else
            if not assetPack.assetType then return false end
            local modelID, lodID = false, false
            if rwPaths.dff then
                modelID = imports.engineRequestModel(assetPack.assetType, (assetManifest.assetBase and (imports.type(assetManifest.assetBase) == "number") and assetManifest.assetBase) or assetPack.assetBase or nil)
                if modelID then
                    rwCache.dff[rwPaths.dff] = rwCache.dff[rwPaths.dff] or (rwPaths.dff and file:exists(rwPaths.dff) and imports.engineLoadDFF(asset.public:readFile(rwPaths.dff, assetManifest.encryptOptions))) or false
                    if not rwCache.dff[rwPaths.dff] then
                        imports.engineFreeModel(modelID)
                        return false
                    else
                        if rwPaths.lod then
                            rwCache.lod[(rwPaths.lod)] = rwCache.lod[(rwPaths.lod)] or (rwPaths.lod and file:exists(rwPaths.lod) and imports.engineLoadDFF(asset.public:readFile(rwPaths.lod, assetManifest.encryptOptions))) or false
                            lodID = (rwCache.lod[(rwPaths.lod)] and imports.engineRequestModel(assetPack.assetType, assetPack.assetBase)) or false
                        end
                        rwCache.col[rwPaths.col] = rwCache.col[rwPaths.col] or (rwPaths.col and file:exists(rwPaths.col) and imports.engineLoadCOL(asset.public:readFile(rwPaths.col, assetManifest.encryptOptions))) or false
                    end
                end
            end
            if modelID then
                rwCache.txd[rwPaths.txd] = rwCache.txd[rwPaths.txd] or (rwPaths.txd and file:exists(rwPaths.txd) and imports.engineLoadTXD(asset.public:readFile(rwPaths.txd, assetManifest.encryptOptions))) or false
                if rwCache.txd[rwPaths.txd] then imports.engineImportTXD(rwCache.txd[rwPaths.txd], modelID) end
                imports.engineReplaceModel(rwCache.dff[rwPaths.dff], modelID, (assetManifest and assetManifest.assetTransparency and true) or assetPack.assetTransparency)
                if rwCache.col[rwPaths.col] then imports.engineReplaceCOL(rwCache.col[rwPaths.col], modelID) end
                imports.engineSetModelLODDistance(modelID, rwStreamRange, true)
                if lodID then
                    if rwCache.txd[rwPaths.txd] then imports.engineImportTXD(rwCache.txd[rwPaths.txd], lodID) end
                    imports.engineReplaceModel(rwCache.lod[(rwPaths.lod)], lodID, (assetManifest and assetManifest.assetTransparency and true) or assetPack.assetTransparency)
                    if rwCache.col[rwPaths.col] then imports.engineReplaceCOL(rwCache.col[rwPaths.col], lodID) end
                    imports.engineSetModelLODDistance(lodID, rwStreamRange, true)
                end
                assetData.cAsset = self
                self.rwPaths = rwPaths
                self.synced = {
                    modelID = modelID,
                    lodID = lodID
                }
                result = true
            end
        end
        return result
    end

    function asset.public:unload(rwCache)
        if not asset.public:isInstance(self) then return false end
        if not rwCache then return false end
        if self.synced then
            if self.synced.modelID then imports.engineFreeModel(self.synced.modelID) end
            if self.synced.lodID then imports.engineFreeModel(self.synced.lodID) end
        end
        if self.rwPaths then
            for i, j in imports.pairs(self.rwPaths) do
                imports.destroyElement(rwCache[i][j])
                rwCache[i][j] = nil
            end
        end
        self:destroyInstance()
        return true
    end
else
    function asset.public:buildManifest(rootPath, localPath, manifestPath)
        if not manifestPath then return false end
        localPath = localPath or rootPath
        manifestPath = localPath..manifestPath
        local result = file:read(manifestPath)
        result = (result and table.decode(result, file:parseURL(manifestPath).extension)) or false
        if result then
            for i, j in imports.pairs(result) do
                local cURL = file:parseURL(j)
                if cURL and cURL.url and cURL.extension and cURL.pointer and (cURL.extension == "vcl") then
                    local pointerPath = ((cURL.pointer == "rootDir") and rootPath) or ((cURL.pointer == "localDir") and localPath) or false
                    if pointerPath then
                        local __cURL = file:parseURL(file:resolveURL(pointerPath..(cURL.directory or "")..cURL.file, file.validPointers["localDir"]..rootPath))
                        result[i] = asset.public:buildManifest(rootPath, __cURL.directory or "", __cURL.file)
                    end
                end
            end
        end
        return result
    end

    --function asset.public:buildFile(filePath, filePointer, encryptOptions, rawPointer, skipSync, debugExistence)
    function asset.public:buildFile(cAsset, filePath, rawPointer, skipSync, debugExistence)
        if not cAsset or not filePath then return false end
        if (not skipSync and not cAsset.rw.synced.hash[filePath]) or (skipSync and rawPointer and not rawPointer[filePath]) then
            local builtFilePathHash = imports.sha256(filePath)
            local builtFileData, builtFileSize = file:read(filePath)
            if builtFileData then
                if not skipSync then
                    cAsset.rw.synced.bandwidth.file[filePath] = builtFileSize
                    cAsset.rw.synced.bandwidth.total = cAsset.rw.synced.bandwidth.total + cAsset.rw.synced.bandwidth.file[filePath]
                    syncer.libraryBandwidth = syncer.libraryBandwidth + cAsset.rw.synced.bandwidth.file[filePath]
                    cAsset.rw.unsynced.data[filePath] = (cAsset.manifest.encryptOptions and cAsset.manifest.encryptOptions.mode and cAsset.manifest.encryptOptions.key and {string.encode(builtFileData, cAsset.manifest.encryptOptions.mode, {key = cAsset.manifest.encryptOptions.key})}) or builtFileData
                    if imports.type(cAsset.rw.unsynced.data[filePath]) == "table" then
                        if cAsset.manifest.encryptOptions.iv then
                            local builtFileCachePath = cAsset.manifest.encryptOptions.path..asset.public.references.cache.."/"..builtFilePathHash..".rw"
                            cAsset.manifest.encryptOptions.iv[builtFilePathHash] = (cAsset.manifest.encryptOptions.iv[builtFilePathHash] and (not asset.public.encryptions[cAsset.manifest.encryptOptions.mode].ivlength or (#string.decode(cAsset.manifest.encryptOptions.iv[builtFilePathHash], "base64") == asset.public.encryptions[cAsset.manifest.encryptOptions.mode].ivlength)) and cAsset.manifest.encryptOptions.iv[builtFilePathHash]) or nil
                            if cAsset.manifest.encryptOptions.iv[builtFilePathHash] then
                                local builtFileCacheContent = file:read(builtFileCachePath)
                                local builtFileCacheData = string.decode(builtFileCacheContent, cAsset.manifest.encryptOptions.mode, {key = cAsset.manifest.encryptOptions.key, iv = string.decode(cAsset.manifest.encryptOptions.iv[builtFilePathHash], "base64")})
                                if not builtFileCacheData or (imports.sha256(builtFileCacheData) ~= imports.sha256(builtFileData)) then cAsset.manifest.encryptOptions.iv[builtFilePathHash] = nil end
                                cAsset.rw.unsynced.data[filePath][1] = (cAsset.manifest.encryptOptions.iv[builtFilePathHash] and builtFileCacheContent) or cAsset.rw.unsynced.data[filePath][1]
                            end
                            cAsset.manifest.encryptOptions.iv[builtFilePathHash] = cAsset.manifest.encryptOptions.iv[builtFilePathHash] or string.encode(cAsset.rw.unsynced.data[filePath][2], "base64")
                            file:write(builtFileCachePath, cAsset.rw.unsynced.data[filePath][1])
                        end
                        cAsset.rw.unsynced.data[filePath] = cAsset.rw.unsynced.data[filePath][1]
                    end
                    cAsset.rw.synced.hash[filePath] = imports.sha256(cAsset.rw.unsynced.data[filePath])
                    local builtFileContent = string.encode(cAsset.rw.unsynced.data[filePath], "base64")
                    if thread:getThread():await(rest:post(syncer.libraryWebserver.."/onVerifyContent?token="..syncer.libraryToken, {path = filePath, hash = imports.sha256(builtFileContent)})) ~= "true" then
                        thread:getThread():await(rest:post(syncer.libraryWebserver.."/onSyncContent?token="..syncer.libraryToken, {path = filePath, content = builtFileContent}))
                        imports.outputServerLog("Assetify: Webserver ━│  Syncing content: "..filePath)
                    end
                end
                if rawPointer then rawPointer[filePath] = builtFileData end
            else
                if debugExistence then imports.outputDebugString("Assetify: Invalid File ━│  "..filePath) end
            end
        end
        return true
    end

    function asset.public:buildShader(cAsset)
        if not cAsset or not cAsset.manifest.shaderMaps then return false end
        for i, j in imports.pairs(asset.private:fetchMap(assetPath, cAsset.manifest.shaderMaps)) do
            if j then
                asset.public:buildFile(cAsset, i, _, _, true)
            end
            thread:pause()
        end
        return true
    end

    function asset.public:buildReplacement(cAsset)
        if not cAsset or not cAsset.manifest.assetReplacements then return false end
        local result = {}
        for i, j in imports.pairs(cAsset.manifest.assetReplacements) do
            if j and (imports.type(j) == "table") then
                result[i] = j
                for k = 1, table.length(asset.public.replacements) do
                    local v = asset.public.replacements[k]
                    if j[v] then
                        result[i][v] = cAsset.path..asset.public.references.replace.."/"..j[v]
                        asset.public:buildFile(cAsset, result[i][v], _, _, true)
                        thread:pause()
                    end
                end
            end
            thread:pause()
        end
        cAsset.manifest.assetReplacements = result
        return true
    end

    function asset.public:buildDep(cAsset)
        if not cAsset.path or not cAsset.manifest.assetDeps then return false end
        local result = {}
        for i, j in imports.pairs(cAsset.manifest.assetDeps) do
            if j and (imports.type(j) == "table") then
                result[i] = {}
                for k, v in imports.pairs(j) do
                    result[i][k] = {}
                    if i == "script" then
                        for m, n in imports.pairs(v) do
                            v[m] = cAsset.path..asset.public.references.dep.."/"..v[m]
                            result[i][k][m] = v[m]
                            asset.public:buildFile(cAsset, result[i][k][m], cAsset.rw.unsynced.raw, k == "server", true)
                            thread:pause()
                        end
                    else
                        j[k] = cAsset.path..asset.public.references.dep.."/"..j[k]
                        result[i][k] = j[k]
                        asset.public:buildFile(cAsset, result[i][k], cAsset.rw.unsynced.raw, _, true)
                    end
                    thread:pause()
                end
            end
            thread:pause()
        end
        cAsset.manifest.assetDeps = result
        return true
    end

    function asset.public:buildPack(assetType, assetPack, callback)
        if not assetType or not assetPack or not callback or (imports.type(callback) ~= "function") then return false end
        local cAssetPack = table.clone(assetPack, true)
        local manifestPath = asset.public.references.root..string.lower(assetType).."/"..asset.public.references.manifest..".vcl"
        cAssetPack.manifest = file:read(manifestPath)
        cAssetPack.manifest = (cAssetPack.manifest and table.decode(cAssetPack.manifest, file:parseURL(manifestPath).extension)) or false
        if not cAssetPack.manifest then execFunction(callback, false, assetType); return false end
        thread:create(function(self)
            cAssetPack.rwDatas = {}
            for i = 1, table.length(cAssetPack.manifest), 1 do
                local cAsset = {}
                cAsset.name = cAssetPack.manifest[i]
                cAsset.path = asset.public.references.root..string.lower(assetType).."/"..cAsset.name.."/"
                cAsset.manifest = asset.public:buildManifest(cAsset.path, _, asset.public.references.asset..".vcl")
                if cAsset.manifest then
                    for k, v in imports.pairs(asset.private.properties.reserved) do
                        cAsset.manifest[k] = ((asset.private.properties.whitelisted[assetType] or asset.private.properties.whitelisted["*"])[k] and cAsset.manifest[k]) or false
                    end
                    cAsset.manifest.encryptMode = (cAsset.manifest.encryptKey and cAsset.manifest.encryptMode and asset.public.encryptions[cAsset.manifest.encryptMode] and cAsset.manifest.encryptMode) or false
                    cAsset.manifest.encryptKey = (cAsset.manifest.encryptMode and cAsset.manifest.encryptKey and string.sub(imports.sha256(imports.tostring(cAsset.manifest.encryptKey)), 1, asset.public.encryptions[cAsset.manifest.encryptMode].keylength or nil)) or false
                    cAsset.manifest.encryptIV = (cAsset.manifest.encryptMode and cAsset.manifest.encryptKey and asset.public.encryptions[cAsset.manifest.encryptMode].ivlength and (table.decode(string.decode(file:read(cAsset.path..asset.public.references.cache.."/"..imports.sha256("asset.iv")..".rw"), "base64")) or {})) or nil
                    cAsset.manifest.encryptOptions = (cAsset.manifest.encryptKey and {path = cAsset.path, mode = cAsset.manifest.encryptMode, key = cAsset.manifest.encryptKey, iv = cAsset.manifest.encryptIV}) or nil
                    cAsset.manifest.encryptMode, cAsset.manifest.encryptKey, cAsset.manifest.encryptIV = nil, nil, nil
                    cAsset.manifest.streamRange = imports.tonumber(cAsset.manifest.streamRange) or asset.public.ranges.stream
                    cAsset.manifest.assetClumps = (cAsset.manifest.assetClumps and (imports.type(cAsset.manifest.assetClumps) == "table") and cAsset.manifest.assetClumps) or false
                    cAsset.manifest.assetAnimations = (cAsset.manifest.assetAnimations and (imports.type(cAsset.manifest.assetAnimations) == "table") and cAsset.manifest.assetAnimations) or false
                    cAsset.manifest.assetSounds = (cAsset.manifest.assetSounds and (imports.type(cAsset.manifest.assetSounds) == "table") and cAsset.manifest.assetSounds) or false
                    cAsset.manifest.shaderMaps = (cAsset.manifest.shaderMaps and (imports.type(cAsset.manifest.shaderMaps) == "table") and cAsset.manifest.shaderMaps) or false
                    cAsset.manifest.assetReplacements = (cAsset.manifest.assetReplacements and (imports.type(cAsset.manifest.assetReplacements) == "table") and cAsset.manifest.assetReplacements) or false
                    cAsset.manifest.assetDeps = (cAsset.manifest.assetDeps and (imports.type(cAsset.manifest.assetDeps) == "table") and cAsset.manifest.assetDeps) or false
                    cAsset.rw = {
                        synced = {
                            manifest = cAsset.manifest,
                            bandwidth = {
                                total = 0,
                                file = {}
                            },
                            hash = {}
                        },
                        unsynced = {
                            raw = {},
                            data = {}
                        }
                    }
                    cAssetPack.rwDatas[cAsset.name] = cAsset.rw
                    if assetType == "module" then
                        table.insert(syncer.libraryModules, cAsset.name)
                    elseif assetType == "animation" then
                        asset.public:buildFile(cAsset, cAsset.path..asset.public.references.asset..".ifp", _, _, true)
                        thread:pause()
                    elseif assetType == "sound" then
                        if cAsset.manifest.assetSounds then
                            local assetSounds = {}
                            for i, j in imports.pairs(cAsset.manifest.assetSounds) do
                                if j and (imports.type(j) == "table") then
                                    assetSounds[i] = {}
                                    for k, v in imports.pairs(j) do
                                        if v then
                                            assetSounds[i][k] = v
                                            asset.public:buildFile(cAsset, cAsset.path.."sound/"..v, _, _, true)
                                            thread:pause()
                                        end
                                    end
                                end
                            end
                            cAsset.manifest.assetSounds = assetSounds
                        end
                        thread:pause()
                    elseif assetType == "scene" then
                        cAsset.manifest.sceneBuildings = (cAsset.manifest.sceneBuildings and true) or false
                        cAsset.manifest.sceneMapped = (cAsset.manifest.sceneMapped and true) or false
                        cAsset.manifest.sceneLODs = (cAsset.manifest.sceneLODs and true) or false
                        cAsset.manifest.sceneDoublesided = (cAsset.manifest.sceneDoublesided and true) or false
                        cAsset.manifest.sceneNativeObjects = (cAsset.manifest.sceneNativeObjects and true) or false
                        cAsset.manifest.sceneDefaultStreamer = (cAsset.manifest.sceneDefaultStreamer and true) or false
                        cAsset.manifest.sceneDimension = math.max(asset.public.ranges.dimension[1], math.min(asset.public.ranges.dimension[2], imports.tonumber(cAsset.manifest.sceneDimension) or 0))
                        cAsset.manifest.sceneInterior = math.max(asset.public.ranges.interior[1], math.min(asset.public.ranges.interior[2], imports.tonumber(cAsset.manifest.sceneInterior) or 0))
                        cAsset.manifest.sceneOffsets = (cAsset.manifest.sceneOffsets and (imports.type(cAsset.manifest.sceneOffsets) == "table") and cAsset.manifest.sceneOffsets) or false
                        if cAsset.manifest.sceneOffsets then
                            for i, j in imports.pairs(cAsset.manifest.sceneOffsets) do
                                cAsset.manifest.sceneOffsets[i] = imports.tonumber(j)
                            end
                        end
                        local sceneIPLPath = cAsset.path..asset.public.references.scene..".ipl"
                        local sceneIPLDatas = scene:parseIPL(file:read(sceneIPLPath), cAsset.manifest.sceneNativeObjects)
                        if sceneIPLDatas then
                            asset.public:buildFile(cAsset, sceneIPLPath)
                            if not cAsset.manifest.sceneMapped then
                                local debugTXDExistence = false
                                local sceneIDEPath = cAsset.path..asset.public.references.scene..".ide"
                                local sceneIDEDatas = scene:parseIDE(file:read(sceneIDEPath))
                                asset.public:buildFile(cAsset, sceneIDEPath)
                                cAsset.rw.synced.sceneIDE = (sceneIDEDatas and true) or false
                                for k = 1, table.length(sceneIPLDatas), 1 do
                                    local v = sceneIPLDatas[k]
                                    if not v.nativeID then
                                        if sceneIDEDatas and sceneIDEDatas[(v[2])] then
                                            asset.public:buildFile(cAsset, cAsset.path..asset.public.references.txd.."/"..(sceneIDEDatas[(v[2])][1])..".txd", _, _, true)
                                        else
                                            local childTXDPath = cAsset.path..asset.public.references.txd.."/"..v[2]..".txd"
                                            debugTXDExistence = (not debugTXDExistence and not file:exists(childTXDPath) and true) or debugTXDExistence
                                            asset.public:buildFile(cAsset, childTXDPath)
                                        end
                                        asset.public:buildFile(cAsset, cAsset.path..asset.public.references.dff.."/"..v[2]..".dff", _, _, true)
                                        asset.public:buildFile(cAsset, cAsset.path..asset.public.references.dff.."/"..asset.public.references.lod.."/"..v[2]..".dff")
                                        asset.public:buildFile(cAsset, cAsset.path..asset.public.references.col.."/"..v[2]..".col")
                                    end
                                    thread:pause()
                                end
                                asset.public:buildFile(cAsset, cAsset.path..asset.public.references.asset..".txd", _, _, debugTXDExistence)
                            end
                        end
                    else
                        local debugTXDExistence = false
                        if cAsset.manifest.assetClumps then
                            for i, j in imports.pairs(cAsset.manifest.assetClumps) do
                                local childTXDPath = cAsset.path..asset.public.references.clump.."/"..j.."/"..asset.public.references.asset..".txd"
                                debugTXDExistence = (not debugTXDExistence and not file:exists(childTXDPath) and true) or debugTXDExistence
                                asset.public:buildFile(cAsset, childTXDPath)
                                asset.public:buildFile(cAsset, cAsset.path..asset.public.references.clump.."/"..j.."/"..asset.public.references.asset..".dff", _, _, true)
                                asset.public:buildFile(cAsset, cAsset.path..asset.public.references.clump.."/"..j.."/"..asset.public.references.asset..".col")
                                thread:pause()
                            end
                        else
                            asset.public:buildFile(cAsset, cAsset.path..asset.public.references.asset..".dff", _, _, true)
                        end
                        asset.public:buildFile(cAsset, cAsset.path..asset.public.references.asset..".txd", _, _, debugTXDExistence)
                        asset.public:buildFile(cAsset, cAsset.path..asset.public.references.asset..".col")
                        thread:pause()
                    end
                    asset.public:buildShader(cAsset)
                    asset.public:buildReplacement(cAsset)
                    asset.public:buildDep(cAsset)
                    if cAsset.manifest.encryptOptions and cAsset.manifest.encryptOptions.iv then file:write(cAsset.path..asset.public.references.cache.."/"..imports.sha256("asset.iv")..".rw", string.encode(table.encode(cAsset.manifest.encryptOptions.iv), "base64")) end
                end
            end
            assetPack.assetPack = cAssetPack
            execFunction(callback, true, assetType)
        end):resume({executions = settings.downloader.buildRate, frames = 1})
        return true
    end
end