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
    reference = {
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
    rw = {
        void = {txd = "mesh_void/dict.rw", dff = "mesh_void/buffer.rw"},
        plane = {modelID = true, txd = "mesh_plane/dict.rw", dff = "mesh_plane/buffer.rw"},
        sky = {modelID = true, txd = "mesh_sky/dict.rw", dff = "mesh_sky/buffer.rw", col = "mesh_sky/physics.rw"}
    },
    replacement = {"txd", "dff", "col"},
    range = {
        dimension = {-1, 65535},
        interior = {0, 255},
        stream = 170
    },
    encryption = {
        ["tea"] = {},
        ["aes128"] = {keylength = 16, ivlength = 16}
    },
    property = {
        reserved = {},
        whitelist = {
            ["module"] = {},
            ["animation"] = {"assetAnimations"},
            ["sound"] = {"assetSounds"},
            ["scene"] = {"sceneBuildings", "sceneMapped", "sceneLODs", "sceneDoublesided", "sceneNativeObjects", "sceneDefaultStreamer", "sceneDimension", "sceneInterior", "sceneOffsets", "streamRange", "shaderMaps"},
            ["*"] = {"streamRange", "assetClumps", "shaderMaps"}
        }
    }
})
for i, j in imports.pairs(asset.private.property.whitelist) do
    for k = 1, table.length(j), 1 do
        local v = j[k]
        asset.private.property.reserved[v] = true
        j[v] = true
        j[k] = nil
    end
end

function asset.public:readFile(cAsset, path, ...)
    if not cAsset or not path or (imports.type(path) ~= "string") or not cAsset.hash[path] or not file:exists(path) then return false end
    local rw = file:read(path)
    if not rw then return false end
    return (not cAsset.manifest.encryptOptions and rw) or string.decode(rw, cAsset.manifest.encryptOptions.mode, {key = cAsset.manifest.encryptOptions.key, iv = (cAsset.manifest.encryptOptions.iv and string.decode(cAsset.manifest.encryptOptions.iv[imports.sha256(path)], "base64")) or nil}, ...) or false
end

function asset.private:validateMap(filePointer, filePath, mapPointer)
    local mapPath = ((filePointer and filePath) and filePointer..filePath) or false
    if mapPointer and mapPath then mapPointer[mapPath] = true end
    return mapPath
end

function asset.private:fetchMap(assetPath, shaderMaps)
    local cPointer, cMaps = (assetPath and assetPath..asset.public.reference.map.."/") or "", {}
    for i, j in imports.pairs(shader.validTypes) do
        local mapData = shaderMaps[i] 
        if j and mapData then
            for k, v in imports.pairs(mapData) do
                if i == asset.public.reference.clump then
                    for m, n in imports.pairs(v) do
                        n.clump = asset.private:validateMap(cPointer, n.clump, cMaps)
                        n.bump = asset.private:validateMap(cPointer, n.bump, cMaps)
                    end
                elseif i == asset.public.reference.control then
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
    for i, j in imports.pairs(asset.public.rw) do
        j.modelID = (j.modelID and imports.engineRequestModel("object")) or false
        for k = 1, table.length(asset.public.replacement) do
            local v = asset.public.replacement[k]
            if j[v] then
                j[v] = "utilities/rw/"..j[v]
                if v == "txd" then
                    j[v] = imports.engineLoadTXD(j[v])
                    if j.modelID then imports.engineImportTXD(j[v], j.modelID) end
                elseif v == "dff" then
                    j[v] = imports.engineLoadDFF(j[v])
                    if j.modelID then imports.engineReplaceModel(j[v], j.modelID, true) end
                elseif v == "col" then
                    j[v] = imports.engineLoadCOL(j[v])
                    if j.modelID then imports.engineReplaceCOL(j[v], j.modelID) end
                end
            end
        end
    end

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
        for i, j in imports.pairs(cAsset.manifest.assetReplacements) do
            j.LODDistance = imports.tonumber(j.LODDistance)
            j.isTransparency = (j.isTransparency and true) or false
            for k = 1, table.length(asset.public.replacement) do
                local v = asset.public.replacement[k]
                if j[v] then
                    cAsset.unsynced.raw.replace[v] = {}
                    if v == "txd" then
                        cAsset.unsynced.raw.replace[v][j[v]] = cAsset.unsynced.raw.replace[v][j[v]] or (v and file:exists(j[v]) and imports.engineLoadTXD(asset.public:readFile(cAsset, j[v]))) or false
                        if cAsset.unsynced.raw.replace[v][j[v]] then imports.engineImportTXD(cAsset.unsynced.raw.replace[v][j[v]], i) end
                    elseif v == "dff" then
                        cAsset.unsynced.raw.replace[v][j[v]] = cAsset.unsynced.raw.replace[v][j[v]] or (v and file:exists(j[v]) and imports.engineLoadDFF(asset.public:readFile(cAsset, j[v]), j.isTransparency)) or false
                        if cAsset.unsynced.raw.replace[v][j[v]] then imports.engineReplaceModel(cAsset.unsynced.raw.replace[v][j[v]], i) end
                    elseif v == "col" then
                        cAsset.unsynced.raw.replace[v][j[v]] = cAsset.unsynced.raw.replace[v][j[v]] or (v and file:exists(j[v]) and imports.engineLoadCOL(asset.public:readFile(cAsset, j[v]))) or false
                        if cAsset.unsynced.raw.replace[v][j[v]] then imports.engineReplaceCOL(cAsset.unsynced.raw.replace[v][j[v]], i) end
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
            cAsset.unsynced.raw.dep[i] = {}
            for k, v in imports.pairs(j) do
                if i == "script" then
                    cAsset.unsynced.raw.dep[i][k] = {}
                    if k ~= "server" then
                        for m, n in imports.pairs(v) do
                            cAsset.unsynced.raw.dep[i][k][m] = asset.public:readFile(cAsset, n, true)
                        end
                    end
                elseif i == "texture" then
                    cAsset.unsynced.raw.dep[i][k] = shader:loadTex(cAsset, v)
                else
                    cAsset.unsynced.raw.dep[i][k] = asset.public:readFile(cAsset, v)
                end
            end
        end
        return true
    end

    function asset.public:destroy(...)
        if not asset.public:isInstance(self) then return false end
        return self:unload(...)
    end

    function asset.public.clearAssetBuffer(raw)
        if not raw then return false end
        for i, j in imports.pairs(raw) do
            if imports.type(j) == "table" then
                asset.public.clearAssetBuffer(j)
            else
                imports.destroyElement(j)
                raw[i] = nil
            end
        end
        return true
    end

    function asset.public:load(cAssetPack, cAsset, assetType, assetName, assetCache, rwPaths, streamRange)
        streamRange = imports.tonumber(streamRange) or cAsset.manifest.streamRange
        if not asset.public:isInstance(self) then return false end
        if not cAssetPack or not cAsset or not assetType or not assetName or not assetCache or not rwPaths then return false end
        local result = false
        if assetType == "module" then
            assetCache.cAsset = self
            self.rwPaths = rwPaths
            result = true
        elseif assetType == "animation" then
            cAsset.unsynced.raw.ifp[rwPaths.ifp] = cAsset.unsynced.raw.ifp[rwPaths.ifp] or (rwPaths.ifp and file:exists(rwPaths.ifp) and imports.engineLoadIFP(asset.public:readFile(cAsset, rwPaths.ifp), assetType.."."..assetName)) or false
            if cAsset.unsynced.raw.ifp[rwPaths.ifp] then
                assetCache.cAsset = self
                self.rwPaths = rwPaths
                result = true
            end
        elseif assetType == "sound" then
            cAsset.unsynced.raw.sound[rwPaths.sound] = cAsset.unsynced.raw.sound[rwPaths.sound] or (rwPaths.sound and file:exists(rwPaths.sound) and asset.public:readFile(cAsset, rwPaths.sound)) or false
            if cAsset.unsynced.raw.sound[rwPaths.sound] then
                assetCache.cAsset = self
                self.rwPaths = rwPaths
                result = true
            end
        else
            if not cAssetPack.assetType then return false end
            local modelID, lodID = false, false
            if rwPaths.dff then
                modelID = imports.engineRequestModel(cAssetPack.assetType, (cAsset.manifest.assetBase and (imports.type(cAsset.manifest.assetBase) == "number") and cAsset.manifest.assetBase) or cAssetPack.assetBase or nil)
                if modelID then
                    cAsset.unsynced.raw.dff[rwPaths.dff] = cAsset.unsynced.raw.dff[rwPaths.dff] or (rwPaths.dff and file:exists(rwPaths.dff) and imports.engineLoadDFF(asset.public:readFile(cAsset, rwPaths.dff))) or false
                    if not cAsset.unsynced.raw.dff[rwPaths.dff] then
                        imports.engineFreeModel(modelID)
                        return false
                    else
                        if rwPaths.lod then
                            cAsset.unsynced.raw.lod[rwPaths.lod] = cAsset.unsynced.raw.lod[rwPaths.lod] or (rwPaths.lod and file:exists(rwPaths.lod) and imports.engineLoadDFF(asset.public:readFile(cAsset, rwPaths.lod))) or false
                            lodID = (cAsset.unsynced.raw.lod[rwPaths.lod] and imports.engineRequestModel(cAssetPack.assetType, cAssetPack.assetBase)) or false
                        end
                        cAsset.unsynced.raw.col[rwPaths.col] = cAsset.unsynced.raw.col[rwPaths.col] or (rwPaths.col and file:exists(rwPaths.col) and imports.engineLoadCOL(asset.public:readFile(cAsset, rwPaths.col))) or false
                    end
                end
            end
            if modelID then
                cAsset.unsynced.raw.txd[rwPaths.txd] = cAsset.unsynced.raw.txd[rwPaths.txd] or (rwPaths.txd and file:exists(rwPaths.txd) and imports.engineLoadTXD(asset.public:readFile(cAsset, rwPaths.txd))) or false
                if cAsset.unsynced.raw.txd[rwPaths.txd] then imports.engineImportTXD(cAsset.unsynced.raw.txd[rwPaths.txd], modelID) end
                imports.engineReplaceModel(cAsset.unsynced.raw.dff[rwPaths.dff], modelID, (cAsset.manifest and cAsset.manifest.assetTransparency and true) or cAssetPack.assetTransparency)
                if cAsset.unsynced.raw.col[rwPaths.col] then imports.engineReplaceCOL(cAsset.unsynced.raw.col[rwPaths.col], modelID) end
                imports.engineSetModelLODDistance(modelID, streamRange, true)
                if lodID then
                    if cAsset.unsynced.raw.txd[rwPaths.txd] then imports.engineImportTXD(cAsset.unsynced.raw.txd[rwPaths.txd], lodID) end
                    imports.engineReplaceModel(cAsset.unsynced.raw.lod[rwPaths.lod], lodID, (cAsset.manifest and cAsset.manifest.assetTransparency and true) or cAssetPack.assetTransparency)
                    if cAsset.unsynced.raw.col[rwPaths.col] then imports.engineReplaceCOL(cAsset.unsynced.raw.col[rwPaths.col], lodID) end
                    imports.engineSetModelLODDistance(lodID, streamRange, true)
                end
                assetCache.cAsset = self
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

    function asset.public:unload(raw)
        if not asset.public:isInstance(self) then return false end
        if not raw then return false end
        if self.synced then
            if self.synced.modelID then imports.engineFreeModel(self.synced.modelID) end
            if self.synced.lodID then imports.engineFreeModel(self.synced.lodID) end
        end
        if self.rwPaths then
            for i, j in imports.pairs(self.rwPaths) do
                imports.destroyElement(raw[i][j])
                raw[i][j] = nil
            end
        end
        self:destroyInstance()
        return true
    end
else
    function asset.public:buildManifest(rooturl, localurl, path)
        if not path then return false end
        localurl = localurl or rooturl
        path = localurl..path
        local result = file:read(path)
        result = (result and table.decode(result)) or false
        if result then
            for i, j in imports.pairs(result) do
                local cURL = file:parseURL(j)
                if cURL and cURL.url and cURL.extension and cURL.pointer and (cURL.extension == "vcl") then
                    local pointerPath = ((cURL.pointer == "rootDir") and rooturl) or ((cURL.pointer == "localDir") and localurl) or false
                    if pointerPath then
                        local __cURL = file:parseURL(file:resolveURL(pointerPath..(cURL.directory or "")..cURL.file, file.validPointers["localDir"]..rooturl))
                        result[i] = asset.public:buildManifest(rooturl, __cURL.directory or "", __cURL.file)
                    end
                end
            end
        end
        return result
    end

    function asset.public:buildFile(cAsset, path, skipSync, syncRaw, debugExistence)
        if not cAsset or not path then return false end
        if (not skipSync and not cAsset.rw.synced.hash[path]) or (skipSync and syncRaw and not cAsset.rw.unsynced.raw[path]) then
            local builtPathHash = imports.sha256(path)
            local builtData, builtSize = file:read(path)
            if builtData then
                if not skipSync then
                    cAsset.rw.synced.bandwidth.file[path] = builtSize
                    cAsset.rw.synced.bandwidth.total = cAsset.rw.synced.bandwidth.total + cAsset.rw.synced.bandwidth.file[path]
                    syncer.libraryBandwidth = syncer.libraryBandwidth + cAsset.rw.synced.bandwidth.file[path]
                    cAsset.rw.unsynced.data[path] = (cAsset.manifest.encryptOptions and cAsset.manifest.encryptOptions.mode and cAsset.manifest.encryptOptions.key and {string.encode(builtData, cAsset.manifest.encryptOptions.mode, {key = cAsset.manifest.encryptOptions.key})}) or builtData
                    if imports.type(cAsset.rw.unsynced.data[path]) == "table" then
                        if cAsset.manifest.encryptOptions.iv then
                            local builtCachePath = cAsset.manifest.encryptOptions.path..asset.public.reference.cache.."/"..builtPathHash..".rw"
                            cAsset.manifest.encryptOptions.iv[builtPathHash] = (cAsset.manifest.encryptOptions.iv[builtPathHash] and (not asset.public.encryption[cAsset.manifest.encryptOptions.mode].ivlength or (#string.decode(cAsset.manifest.encryptOptions.iv[builtPathHash], "base64") == asset.public.encryption[cAsset.manifest.encryptOptions.mode].ivlength)) and cAsset.manifest.encryptOptions.iv[builtPathHash]) or nil
                            if cAsset.manifest.encryptOptions.iv[builtPathHash] then
                                local builtCacheContent = file:read(builtCachePath)
                                local builtCacheData = string.decode(builtCacheContent, cAsset.manifest.encryptOptions.mode, {key = cAsset.manifest.encryptOptions.key, iv = string.decode(cAsset.manifest.encryptOptions.iv[builtPathHash], "base64")})
                                if not builtCacheData or (imports.sha256(builtCacheData) ~= imports.sha256(builtData)) then cAsset.manifest.encryptOptions.iv[builtPathHash] = nil end
                                cAsset.rw.unsynced.data[path][1] = (cAsset.manifest.encryptOptions.iv[builtPathHash] and builtCacheContent) or cAsset.rw.unsynced.data[path][1]
                            end
                            cAsset.manifest.encryptOptions.iv[builtPathHash] = cAsset.manifest.encryptOptions.iv[builtPathHash] or string.encode(cAsset.rw.unsynced.data[path][2], "base64")
                            file:write(builtCachePath, cAsset.rw.unsynced.data[path][1])
                        end
                        cAsset.rw.unsynced.data[path] = cAsset.rw.unsynced.data[path][1]
                    end
                    cAsset.rw.synced.hash[path] = imports.sha256(cAsset.rw.unsynced.data[path])
                    local builtContent = string.encode(cAsset.rw.unsynced.data[path], "base64")
                    if thread:getThread():await(rest:post(syncer.libraryWebserver.."/onVerifyContent?token="..syncer.libraryToken, {path = path, hash = imports.sha256(builtContent)})) ~= "true" then
                        thread:getThread():await(rest:post(syncer.libraryWebserver.."/onSyncContent?token="..syncer.libraryToken, {path = path, content = builtContent}))
                        imports.outputServerLog("Assetify: Webserver ━│  Syncing content: "..path)
                    end
                end
                if syncRaw then cAsset.rw.unsynced.raw[path] = builtData end
            elseif debugExistence then 
                imports.outputDebugString("Assetify: Invalid File ━│  "..path)
            end
        end
        return true
    end

    function asset.public:buildShader(cAsset)
        if not cAsset or not cAsset.manifest.shaderMaps then return false end
        for i, j in imports.pairs(asset.private:fetchMap(cAsset.path, cAsset.manifest.shaderMaps)) do
            if j then
                asset.public:buildFile(cAsset, i, false, false, true)
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
                for k = 1, table.length(asset.public.replacement) do
                    local v = asset.public.replacement[k]
                    if j[v] then
                        result[i][v] = cAsset.path..asset.public.reference.replace.."/"..j[v]
                        asset.public:buildFile(cAsset, result[i][v], false, false, true)
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
                            v[m] = cAsset.path..asset.public.reference.dep.."/"..v[m]
                            result[i][k][m] = v[m]
                            asset.public:buildFile(cAsset, result[i][k][m], k == "server", cAsset.rw.unsynced.raw, true)
                            thread:pause()
                        end
                    else
                        j[k] = cAsset.path..asset.public.reference.dep.."/"..j[k]
                        result[i][k] = j[k]
                        asset.public:buildFile(cAsset, result[i][k], false, cAsset.rw.unsynced.raw, true)
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
        local manifestPath = asset.public.reference.root..string.lower(assetType).."/"..asset.public.reference.manifest..".vcl"
        cAssetPack.manifest = file:read(manifestPath)
        cAssetPack.manifest = (cAssetPack.manifest and table.decode(cAssetPack.manifest)) or {}
        thread:create(function(self)
            cAssetPack.rwDatas = {}
            for i = 1, table.length(cAssetPack.manifest), 1 do
                local cAsset = {}
                cAsset.name = cAssetPack.manifest[i]
                cAsset.path = asset.public.reference.root..string.lower(assetType).."/"..cAsset.name.."/"
                cAsset.manifest = asset.public:buildManifest(cAsset.path, _, asset.public.reference.asset..".vcl")
                if cAsset.manifest then
                    for k, v in imports.pairs(asset.private.property.reserved) do
                        cAsset.manifest[k] = ((asset.private.property.whitelist[assetType] or asset.private.property.whitelist["*"])[k] and cAsset.manifest[k]) or false
                    end
                    cAsset.manifest.encryptMode = (cAsset.manifest.encryptKey and cAsset.manifest.encryptMode and asset.public.encryption[cAsset.manifest.encryptMode] and cAsset.manifest.encryptMode) or false
                    cAsset.manifest.encryptKey = (cAsset.manifest.encryptMode and cAsset.manifest.encryptKey and string.sub(imports.sha256(imports.tostring(cAsset.manifest.encryptKey)), 1, asset.public.encryption[cAsset.manifest.encryptMode].keylength or nil)) or false
                    cAsset.manifest.encryptIV = (cAsset.manifest.encryptMode and cAsset.manifest.encryptKey and asset.public.encryption[cAsset.manifest.encryptMode].ivlength and (table.decode(string.decode(file:read(cAsset.path..asset.public.reference.cache.."/"..imports.sha256("asset.iv")..".rw"), "base64")) or {})) or nil
                    cAsset.manifest.encryptOptions = (cAsset.manifest.encryptKey and {path = cAsset.path, mode = cAsset.manifest.encryptMode, key = cAsset.manifest.encryptKey, iv = cAsset.manifest.encryptIV}) or nil
                    cAsset.manifest.encryptMode, cAsset.manifest.encryptKey, cAsset.manifest.encryptIV = nil, nil, nil
                    cAsset.manifest.streamRange = imports.tonumber(cAsset.manifest.streamRange) or asset.public.range.stream
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
                        asset.public:buildFile(cAsset, cAsset.path..asset.public.reference.asset..".ifp", false, false, true)
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
                                            asset.public:buildFile(cAsset, cAsset.path.."sound/"..v, false, false, true)
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
                        cAsset.manifest.sceneDimension = math.max(asset.public.range.dimension[1], math.min(asset.public.range.dimension[2], imports.tonumber(cAsset.manifest.sceneDimension) or 0))
                        cAsset.manifest.sceneInterior = math.max(asset.public.range.interior[1], math.min(asset.public.range.interior[2], imports.tonumber(cAsset.manifest.sceneInterior) or 0))
                        cAsset.manifest.sceneOffsets = (cAsset.manifest.sceneOffsets and (imports.type(cAsset.manifest.sceneOffsets) == "table") and cAsset.manifest.sceneOffsets) or false
                        if cAsset.manifest.sceneOffsets then
                            for i, j in imports.pairs(cAsset.manifest.sceneOffsets) do
                                cAsset.manifest.sceneOffsets[i] = imports.tonumber(j)
                            end
                        end
                        local sceneIPLPath = cAsset.path..asset.public.reference.scene..".ipl"
                        local sceneIPLDatas = scene:parseIPL(file:read(sceneIPLPath), cAsset.manifest.sceneNativeObjects)
                        if sceneIPLDatas then
                            asset.public:buildFile(cAsset, sceneIPLPath)
                            if not cAsset.manifest.sceneMapped then
                                local debugTXDExistence = false
                                local sceneIDEPath = cAsset.path..asset.public.reference.scene..".ide"
                                local sceneIDEDatas = scene:parseIDE(file:read(sceneIDEPath))
                                asset.public:buildFile(cAsset, sceneIDEPath)
                                cAsset.rw.synced.sceneIDE = (sceneIDEDatas and true) or false
                                for k = 1, table.length(sceneIPLDatas), 1 do
                                    local v = sceneIPLDatas[k]
                                    if not v.nativeID then
                                        if sceneIDEDatas and sceneIDEDatas[(v[2])] then
                                            asset.public:buildFile(cAsset, cAsset.path..asset.public.reference.txd.."/"..(sceneIDEDatas[(v[2])][1])..".txd", false, false, true)
                                        else
                                            local childTXDPath = cAsset.path..asset.public.reference.txd.."/"..v[2]..".txd"
                                            debugTXDExistence = (not debugTXDExistence and not file:exists(childTXDPath) and true) or debugTXDExistence
                                            asset.public:buildFile(cAsset, childTXDPath)
                                        end
                                        asset.public:buildFile(cAsset, cAsset.path..asset.public.reference.dff.."/"..v[2]..".dff", false, false, true)
                                        asset.public:buildFile(cAsset, cAsset.path..asset.public.reference.dff.."/"..asset.public.reference.lod.."/"..v[2]..".dff")
                                        asset.public:buildFile(cAsset, cAsset.path..asset.public.reference.col.."/"..v[2]..".col")
                                    end
                                    thread:pause()
                                end
                                asset.public:buildFile(cAsset, cAsset.path..asset.public.reference.asset..".txd", false, false, debugTXDExistence)
                            end
                        end
                    else
                        local debugTXDExistence = false
                        if cAsset.manifest.assetClumps then
                            for i, j in imports.pairs(cAsset.manifest.assetClumps) do
                                local childTXDPath = cAsset.path..asset.public.reference.clump.."/"..j.."/"..asset.public.reference.asset..".txd"
                                debugTXDExistence = (not debugTXDExistence and not file:exists(childTXDPath) and true) or debugTXDExistence
                                asset.public:buildFile(cAsset, childTXDPath)
                                asset.public:buildFile(cAsset, cAsset.path..asset.public.reference.clump.."/"..j.."/"..asset.public.reference.asset..".dff", false, false, true)
                                asset.public:buildFile(cAsset, cAsset.path..asset.public.reference.clump.."/"..j.."/"..asset.public.reference.asset..".col")
                                thread:pause()
                            end
                        else
                            asset.public:buildFile(cAsset, cAsset.path..asset.public.reference.asset..".dff", false, false, true)
                        end
                        asset.public:buildFile(cAsset, cAsset.path..asset.public.reference.asset..".txd", false, false, debugTXDExistence)
                        asset.public:buildFile(cAsset, cAsset.path..asset.public.reference.asset..".col")
                        thread:pause()
                    end
                    asset.public:buildShader(cAsset)
                    asset.public:buildReplacement(cAsset)
                    asset.public:buildDep(cAsset)
                    if cAsset.manifest.encryptOptions and cAsset.manifest.encryptOptions.iv then file:write(cAsset.path..asset.public.reference.cache.."/"..imports.sha256("asset.iv")..".rw", string.encode(table.encode(cAsset.manifest.encryptOptions.iv), "base64")) end
                end
            end
            assetPack.assetPack = cAssetPack
            execFunction(callback)
        end):resume({executions = settings.downloader.buildRate, frames = 1})
        return true
    end
end