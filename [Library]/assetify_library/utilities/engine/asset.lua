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
    base64Encode = base64Encode,
    outputServerLog = outputServerLog,
    outputDebugString = outputDebugString,
    destroyElement = destroyElement,
    engineRequestModel = engineRequestModel,
    engineSetModelLODDistance = engineSetModelLODDistance,
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
        scene = "scene",
        clump = "clump",
        control = "control",
        txd = "txd", dff = "dff", lod = "lod", col = "col",
        map = "map", dep = "dep"
    },
    ranges = {
        dimension = {-1, 65535},
        interior = {0, 255},
        stream = 170
    },
    properties = {
        reserved = {"enableLODs", "enableDoublefaces", "streamRange", "assetClumps", "assetAnimations", "assetSounds", "shaderMaps", "sceneDimension", "sceneInterior", "sceneOffsets", "sceneMapped", "sceneNativeObjects", "sceneDefaultStreamer"},
        whitelisted = {
            ["module"] = {},
            ["animation"] = {"assetAnimations"},
            ["sound"] = {"assetSounds"},
            ["scene"] = {"enableLODs", "enableDoublefaces", "streamRange", "shaderMaps", "sceneDimension", "sceneInterior", "sceneOffsets", "sceneMapped", "sceneNativeObjects", "sceneDefaultStreamer"},
            ["*"] = {"enableLODs", "enableDoublefaces", "streamRange", "assetClumps", "shaderMaps"}
        }
    }
})
for i, j in imports.pairs(asset.private.properties.whitelisted) do
    for k = 1, table.length(j), 1 do
        local v = j[k]
        j[v] = true
        j[k] = nil
    end
end

function asset.public:readFile(filePath, encryptKey, ...)
    if not filePath or (imports.type(filePath) ~= "string") or not file:exists(filePath) then return false end
    local rw = file:read(filePath)
    if not encryptKey then return rw end
    return (rw and string.decode(rw, "tea", {key = encryptKey}, ...)) or false
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

    function asset.public:createDep(assetDeps, rwCache, encryptKey)
        if not assetDeps or not rwCache then return false end
        for i, j in imports.pairs(assetDeps) do
            rwCache[i] = {}
            for k, v in imports.pairs(j) do
                if i == "script" then
                    rwCache[i][k] = {}
                    if k ~= "server" then
                        for m, n in imports.pairs(v) do
                            rwCache[i][k][m] = asset.public:readFile(n, encryptKey, true)
                        end
                    end
                elseif i == "texture" then
                    rwCache[i][k] = shader:loadTex(v, encryptKey)
                else
                    rwCache[i][k] = asset.public:readFile(v, encryptKey)
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
            imports.destroyElement(j)
            rwCache[i] = nil
        end
        return true
    end

    function asset.public:load(assetType, assetName, assetPack, rwCache, assetManifest, assetData, rwPaths, rwStreamRange)
        rwStreamRange = imports.tonumber(rwStreamRange) or assetManifest.streamRange
        if not asset.public:isInstance(self) then return false end
        if not assetType or not assetName or not assetPack or not rwCache or not assetManifest or not assetData or not rwPaths then return false end
        local loadState = false
        if assetType == "module" then
            assetData.cAsset = self
            self.rwPaths = rwPaths
            loadState = true
        elseif assetType == "animation" then
            rwCache.ifp[(rwPaths.ifp)] = rwCache.ifp[(rwPaths.ifp)] or (rwPaths.ifp and file:exists(rwPaths.ifp) and imports.engineLoadIFP(asset.public:readFile(rwPaths.ifp, assetManifest.encryptKey), assetType.."."..assetName)) or false
            if rwCache.ifp[(rwPaths.ifp)] then
                assetData.cAsset = self
                self.rwPaths = rwPaths
                loadState = true
            end
        elseif assetType == "sound" then
            rwCache.sound[(rwPaths.sound)] = rwCache.sound[(rwPaths.sound)] or (rwPaths.sound and file:exists(rwPaths.sound) and asset.public:readFile(rwPaths.sound, assetManifest.encryptKey)) or false
            if rwCache.sound[(rwPaths.sound)] then
                assetData.cAsset = self
                self.rwPaths = rwPaths
                loadState = true
            end
        else
            if not assetPack.assetType then return false end
            local modelID, lodID, collisionID = false, false, false
            if rwPaths.dff then
                modelID = imports.engineRequestModel(assetPack.assetType, (assetManifest.assetBase and (imports.type(assetManifest.assetBase) == "number") and assetManifest.assetBase) or assetPack.assetBase or nil)
                if modelID then
                    rwCache.dff[(rwPaths.dff)] = rwCache.dff[(rwPaths.dff)] or (rwPaths.dff and file:exists(rwPaths.dff) and imports.engineLoadDFF(asset.public:readFile(rwPaths.dff, assetManifest.encryptKey))) or false
                    if not rwCache.dff[(rwPaths.dff)] then
                        imports.engineFreeModel(modelID)
                        return false
                    else
                        if rwPaths.lod then
                            rwCache.lod[(rwPaths.lod)] = rwCache.lod[(rwPaths.lod)] or (rwPaths.lod and file:exists(rwPaths.lod) and imports.engineLoadDFF(asset.public:readFile(rwPaths.lod, assetManifest.encryptKey))) or false
                            lodID = (rwCache.lod[(rwPaths.lod)] and imports.engineRequestModel(assetPack.assetType, assetPack.assetBase)) or false
                        end
                        rwCache.col[(rwPaths.col)] = rwCache.col[(rwPaths.col)] or (rwPaths.col and file:exists(rwPaths.col) and imports.engineLoadCOL(asset.public:readFile(rwPaths.col, assetManifest.encryptKey))) or false
                        collisionID = (rwCache.col[(rwPaths.col)] and imports.engineRequestModel(assetPack.assetType, assetPack.assetBase)) or false
                        imports.engineSetModelLODDistance(modelID, rwStreamRange)
                        if lodID then imports.engineSetModelLODDistance(lodID, rwStreamRange) end
                        if collisionID then imports.engineSetModelLODDistance(collisionID, rwStreamRange) end
                    end
                end
            end
            if modelID then
                rwCache.txd[(rwPaths.txd)] = rwCache.txd[(rwPaths.txd)] or (rwPaths.txd and file:exists(rwPaths.txd) and imports.engineLoadTXD(asset.public:readFile(rwPaths.txd, assetManifest.encryptKey))) or false
                if rwCache.txd[(rwPaths.txd)] then
                    imports.engineImportTXD(rwCache.txd[(rwPaths.txd)], modelID)
                    if lodID then imports.engineImportTXD(rwCache.txd[(rwPaths.txd)], lodID) end
                end
                imports.engineReplaceModel(rwCache.dff[(rwPaths.dff)], modelID, (assetManifest and assetManifest.assetTransparency and true) or assetPack.assetTransparency)
                if lodID then imports.engineReplaceModel(rwCache.lod[(rwPaths.lod)], lodID, (assetManifest and assetManifest.assetTransparency and true) or assetPack.assetTransparency) end
                if collisionID then
                    imports.engineReplaceCOL(rwCache.col[(rwPaths.col)], modelID)
                    if lodID then imports.engineReplaceCOL(rwCache.col[(rwPaths.col)], lodID) end
                    manager.API.World.clearModel(collisionID)
                    imports.engineReplaceCOL(rwCache.col[(rwPaths.col)], collisionID)
                end
                assetData.cAsset = self
                self.rwPaths = rwPaths
                self.synced = {
                    modelID = modelID,
                    lodID = lodID,
                    collisionID = collisionID
                }
                loadState = true
            end
        end
        return loadState
    end

    function asset.public:unload(rwCache)
        if not asset.public:isInstance(self) then return false end
        if not rwCache then return false end
        if self.synced then
            if self.synced.modelID then imports.engineFreeModel(self.synced.modelID) end
            if self.synced.lodID then imports.engineFreeModel(self.synced.lodID) end
            if self.synced.collisionID then imports.engineFreeModel(self.synced.collisionID) end
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
        local manifestData = file:read(manifestPath)
        manifestData = (manifestData and table.decode(manifestData, file:parseURL(manifestPath).extension)) or false
        if manifestData then
            for i, j in imports.pairs(manifestData) do
                local cURL = file:parseURL(j)
                if cURL and cURL.url and cURL.extension and cURL.pointer and ((cURL.extension == "vcl") or (cURL.extension == "json")) then
                    local pointerPath = ((cURL.pointer == "rootDir") and rootPath) or ((cURL.pointer == "localDir") and localPath) or false
                    if pointerPath then
                        local __cURL = file:parseURL(file:resolveURL(pointerPath..(cURL.directory or "")..cURL.file, file.validPointers["localDir"]..rootPath))
                        manifestData[i] = asset.public:buildManifest(rootPath, __cURL.directory or "", __cURL.file)
                    end
                end
            end
        end
        return manifestData
    end

    function asset.public:buildFile(filePath, filePointer, encryptKey, rawPointer, skipSync, debugExistence)
        if not filePath or not filePointer then return false end
        if (not skipSync and not filePointer.unSynced.fileHash[filePath]) or (skipSync and rawPointer and not rawPointer[filePath]) then
            local builtFileData, builtFileSize = file:read(filePath)
            if builtFileData then
                if not skipSync then
                    filePointer.synced.bandwidthData.file[filePath] = builtFileSize
                    filePointer.synced.bandwidthData.total = filePointer.synced.bandwidthData.total + filePointer.synced.bandwidthData.file[filePath]
                    syncer.libraryBandwidth = syncer.libraryBandwidth + filePointer.synced.bandwidthData.file[filePath]
                    filePointer.unSynced.fileData[filePath] = (encryptKey and string.encode(builtFileData, "tea", {key = encryptKey})) or builtFileData
                    filePointer.unSynced.fileHash[filePath] = imports.sha256(filePointer.unSynced.fileData[filePath])
                    local builtFileContent = imports.base64Encode(filePointer.unSynced.fileData[filePath])
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

    function asset.public:buildShader(assetPath, shaderMaps, filePointer, encryptKey)
        if not assetPath or not shaderMaps or not filePointer then return false end
        for i, j in imports.pairs(asset.private:fetchMap(assetPath, shaderMaps)) do
            if j then
                asset.public:buildFile(i, filePointer, encryptKey, _, _, true)
            end
            thread:pause()
        end
        return true
    end

    function asset.public:buildDep(assetPath, assetDeps, filePointer, encryptKey)
        if not assetPath or not assetDeps or not filePointer then return false end
        local cAssetDeps = {}
        for i, j in imports.pairs(assetDeps) do
            if j and (imports.type(j) == "table") then
                cAssetDeps[i] = {}
                for k, v in imports.pairs(j) do
                    cAssetDeps[i][k] = {}
                    if i == "script" then
                        for m, n in imports.pairs(v) do
                            v[m] = assetPath..(asset.public.references.dep).."/"..v[m]
                            cAssetDeps[i][k][m] = v[m]
                            asset.public:buildFile(cAssetDeps[i][k][m], filePointer, encryptKey, filePointer.unSynced.rawData, k == "server", true)
                            thread:pause()
                        end
                    else
                        j[k] = assetPath..(asset.public.references.dep).."/"..j[k]
                        cAssetDeps[i][k] = j[k]
                        asset.public:buildFile(cAssetDeps[i][k], filePointer, encryptKey, filePointer.unSynced.rawData, _, true)
                    end
                    thread:pause()
                end
            end
            thread:pause()
        end
        return cAssetDeps
    end

    function asset.public:buildPack(assetType, assetPack, callback)
        if not assetType or not assetPack or not callback or (imports.type(callback) ~= "function") then return false end
        local cAssetPack = table.clone(assetPack, true)
        local manifestPath = (asset.public.references.root)..string.lower(assetType).."/"..(asset.public.references.manifest)
        manifestPath = manifestPath..((file:exists(manifestPath..".json") and ".json") or ".vcl")
        cAssetPack.manifestData = file:read(manifestPath)
        cAssetPack.manifestData = (cAssetPack.manifestData and table.decode(cAssetPack.manifestData, file:parseURL(manifestPath).extension)) or false
        if not cAssetPack.manifestData then execFunction(callback, false, assetType); return false end
        thread:create(function(self)
            cAssetPack.rwDatas = {}
            for i = 1, table.length(cAssetPack.manifestData), 1 do
                local assetName = cAssetPack.manifestData[i]
                local assetPath = (asset.public.references.root)..string.lower(assetType).."/"..assetName.."/"
                local assetManifest = asset.public:buildManifest(assetPath, _, asset.public.references.asset..((file:exists(assetPath..(asset.public.references.asset)..".json") and ".json") or ".vcl"))
                if assetManifest then
                    local assetProperties = asset.private.properties.whitelisted[assetType] or asset.private.properties.whitelisted["*"]
                    for k = 1, table.length(asset.private.properties.reserved), 1 do
                        local v = asset.private.properties.reserved[k]
                        assetManifest[v] = (assetProperties[v] and assetManifest[v]) or false
                    end
                    assetManifest.encryptKey = (assetManifest.encryptKey and imports.sha256(imports.tostring(assetManifest.encryptKey))) or false
                    assetManifest.enableLODs = (assetManifest.enableLODs and true) or false
                    assetManifest.enableDoublefaces = (assetManifest.enableDoublefaces and true) or false
                    assetManifest.streamRange = imports.tonumber(assetManifest.streamRange) or asset.public.ranges.stream
                    assetManifest.assetClumps = (assetManifest.assetClumps and (imports.type(assetManifest.assetClumps) == "table") and assetManifest.assetClumps) or false
                    assetManifest.assetAnimations = (assetManifest.assetAnimations and (imports.type(assetManifest.assetAnimations) == "table") and assetManifest.assetAnimations) or false
                    assetManifest.assetSounds = (assetManifest.assetSounds and (imports.type(assetManifest.assetSounds) == "table") and assetManifest.assetSounds) or false
                    assetManifest.shaderMaps = (assetManifest.shaderMaps and (imports.type(assetManifest.shaderMaps) == "table") and assetManifest.shaderMaps) or false
                    assetManifest.assetDeps = (assetManifest.assetDeps and (imports.type(assetManifest.assetDeps) == "table") and assetManifest.assetDeps) or false
                    cAssetPack.rwDatas[assetName] = {
                        synced = {
                            manifestData = assetManifest,
                            bandwidthData = {total = 0, file = {}}
                        },
                        unSynced = {
                            rawData = {},
                            fileData = {},
                            fileHash = {}
                        }
                    }
                    if assetType == "module" then
                        table.insert(syncer.libraryModules, assetName)
                    elseif assetType == "animation" then
                        asset.public:buildFile(assetPath..(asset.public.references.asset)..".ifp", cAssetPack.rwDatas[assetName], assetManifest.encryptKey, _, _, true)
                        thread:pause()
                    elseif assetType == "sound" then
                        if assetManifest.assetSounds then
                            local assetSounds = {}
                            for i, j in imports.pairs(assetManifest.assetSounds) do
                                if j and (imports.type(j) == "table") then
                                    assetSounds[i] = {}
                                    for k, v in imports.pairs(j) do
                                        if v then
                                            assetSounds[i][k] = v
                                            asset.public:buildFile(assetPath.."sound/"..v, cAssetPack.rwDatas[assetName], assetManifest.encryptKey, _, _, true)
                                            thread:pause()
                                        end
                                    end
                                end
                            end
                            assetManifest.assetSounds = assetSounds
                        end
                        thread:pause()
                    elseif assetType == "scene" then
                        assetManifest.sceneDimension = math.max(asset.public.ranges.dimension[1], math.min(asset.public.ranges.dimension[2], imports.tonumber(assetManifest.sceneDimension) or 0))
                        assetManifest.sceneInterior = math.max(asset.public.ranges.interior[1], math.min(asset.public.ranges.interior[2], imports.tonumber(assetManifest.sceneInterior) or 0))
                        assetManifest.sceneOffsets = (assetManifest.sceneOffsets and (imports.type(assetManifest.sceneOffsets) == "table") and assetManifest.sceneOffsets) or false
                        assetManifest.sceneMapped = (assetManifest.sceneMapped and true) or false
                        assetManifest.sceneNativeObjects = (assetManifest.sceneNativeObjects and true) or false
                        assetManifest.sceneDefaultStreamer = (assetManifest.sceneDefaultStreamer and true) or false
                        if assetManifest.sceneOffsets then
                            for i, j in imports.pairs(assetManifest.sceneOffsets) do
                                assetManifest.sceneOffsets[i] = imports.tonumber(j)
                            end
                        end
                        local sceneIPLPath = assetPath..(asset.public.references.scene)..".ipl"
                        local sceneIPLDatas = scene:parseIPL(file:read(sceneIPLPath), assetManifest.sceneNativeObjects)
                        if sceneIPLDatas then
                            asset.public:buildFile(sceneIPLPath, cAssetPack.rwDatas[assetName], assetManifest.encryptKey)
                            if not assetManifest.sceneMapped then
                                local debugTXDExistence = false
                                local sceneIDEPath = assetPath..(asset.public.references.scene)..".ide"
                                local sceneIDEDatas = scene:parseIDE(file:read(sceneIDEPath))
                                asset.public:buildFile(sceneIDEPath, cAssetPack.rwDatas[assetName], assetManifest.encryptKey)
                                cAssetPack.rwDatas[assetName].synced.sceneIDE = (sceneIDEDatas and true) or false
                                for k = 1, table.length(sceneIPLDatas), 1 do
                                    local v = sceneIPLDatas[k]
                                    if not v.nativeID then
                                        if sceneIDEDatas and sceneIDEDatas[(v[2])] then
                                            asset.public:buildFile(assetPath..(asset.public.references.txd).."/"..(sceneIDEDatas[(v[2])][1])..".txd", cAssetPack.rwDatas[assetName], assetManifest.encryptKey, _, _, true)
                                        else
                                            local childTXDPath = assetPath..(asset.public.references.txd).."/"..v[2]..".txd"
                                            debugTXDExistence = (not debugTXDExistence and not file:exists(childTXDPath) and true) or debugTXDExistence
                                            asset.public:buildFile(childTXDPath, cAssetPack.rwDatas[assetName], assetManifest.encryptKey)
                                        end
                                        asset.public:buildFile(assetPath..(asset.public.references.dff).."/"..v[2]..".dff", cAssetPack.rwDatas[assetName], assetManifest.encryptKey, _, _, true)
                                        asset.public:buildFile(assetPath..(asset.public.references.dff).."/"..(asset.public.references.lod).."/"..v[2]..".dff", cAssetPack.rwDatas[assetName], assetManifest.encryptKey)
                                        asset.public:buildFile(assetPath..(asset.public.references.col).."/"..v[2]..".col", cAssetPack.rwDatas[assetName], assetManifest.encryptKey)
                                    end
                                    thread:pause()
                                end
                                asset.public:buildFile(assetPath..(asset.public.references.asset)..".txd", cAssetPack.rwDatas[assetName], assetManifest.encryptKey, _, _, debugTXDExistence)
                            end
                        end
                    else
                        local debugTXDExistence = false
                        if assetManifest.assetClumps then
                            for i, j in imports.pairs(assetManifest.assetClumps) do
                                local childTXDPath = assetPath..(asset.public.references.clump).."/"..j.."/"..(asset.public.references.asset)..".txd"
                                debugTXDExistence = (not debugTXDExistence and not file:exists(childTXDPath) and true) or debugTXDExistence
                                asset.public:buildFile(childTXDPath, cAssetPack.rwDatas[assetName], assetManifest.encryptKey)
                                asset.public:buildFile(assetPath..(asset.public.references.clump).."/"..j.."/"..(asset.public.references.asset)..".dff", cAssetPack.rwDatas[assetName], assetManifest.encryptKey, _, _, true)
                                asset.public:buildFile(assetPath..(asset.public.references.clump).."/"..j.."/"..(asset.public.references.asset)..".col", cAssetPack.rwDatas[assetName], assetManifest.encryptKey)
                                thread:pause()
                            end
                        else
                            asset.public:buildFile(assetPath..(asset.public.references.asset)..".dff", cAssetPack.rwDatas[assetName], assetManifest.encryptKey, _, _, true)
                        end
                        asset.public:buildFile(assetPath..(asset.public.references.asset)..".txd", cAssetPack.rwDatas[assetName], assetManifest.encryptKey, _, _, debugTXDExistence)
                        asset.public:buildFile(assetPath..(asset.public.references.asset)..".col", cAssetPack.rwDatas[assetName], assetManifest.encryptKey)
                        thread:pause()
                    end
                    asset.public:buildShader(assetPath, assetManifest.shaderMaps, cAssetPack.rwDatas[assetName], assetManifest.encryptKey)
                    assetManifest.assetDeps = asset.public:buildDep(assetPath, assetManifest.assetDeps, cAssetPack.rwDatas[assetName], assetManifest.encryptKey)
                end
            end
            assetPack.assetPack = cAssetPack
            execFunction(callback, true, assetType)
        end):resume({executions = settings.downloader.buildRate, frames = 1})
        return true
    end
end
