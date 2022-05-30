----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: asset.lua
     Author: vStudio
     Developer(s): Aviril, Tron
     DOC: 19/10/2021
     Desc: Asset Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    md5 = md5,
    encodeString = encodeString,
    decodeString = decodeString,
    split = split,
    gettok = gettok,
    tonumber = tonumber,
    tostring = tostring,
    isElement = isElement,
    destroyElement = destroyElement,
    setmetatable = setmetatable,
    setTimer = setTimer,
    engineRequestModel = engineRequestModel,
    engineSetModelLODDistance = engineSetModelLODDistance,
    engineFreeModel = engineFreeModel,
    engineLoadIFP = engineLoadIFP,
    engineLoadTXD = engineLoadTXD,
    engineLoadDFF = engineLoadDFF,
    engineLoadCOL = engineLoadCOL,
    engineImportTXD = engineImportTXD,
    engineReplaceModel = engineReplaceModel,
    engineReplaceCOL = engineReplaceCOL,
    file = file,
    json = json,
    table = table,
    string = string,
    math = math
}


----------------------
--[[ Class: Asset ]]--
----------------------

asset = {
    references = {
        root = ((downloadSettings.isAccessSafe and "@") or "").."files/assets/",
        manifest = "manifest",
        asset = "asset",
        scene = "scene"
    },
    separators = {
        IDE = imports.string.byte(", "),
        IPL = imports.string.byte(", ")
    },
    ranges = {
        dimension = {-1, 65535},
        interior = {0, 255},
        streamRange = 170
    }
}
asset.__index = asset

if localPlayer then
    asset.rwAssets = {
        txd = imports.engineLoadTXD("utilities/rw/dict.rw"),
        dff = imports.engineLoadDFF("utilities/rw/buffer.rw")
    }

    function asset:create(...)
        local cAsset = imports.setmetatable({}, {__index = self})
        if not cAsset:load(...) then
            cAsset = nil
            return false
        end
        return cAsset
    end
    
    function asset:createDep(assetDeps, rwCache, encryptKey)
        if not assetDeps or not rwCache then return false end
        for i, j in imports.pairs(assetDeps) do
            rwCache[i] = {}
            for k, v in imports.pairs(j) do
                if i == "texture" then
                    rwCache[i][k] = shader:loadTex(v, encryptKey)
                elseif i == "script" then
                    rwCache[i][k] = {}
                    if k ~= "server" then
                        for m, n in imports.pairs(v) do
                            rwCache[i][k][m] = (encryptKey and imports.decodeString("tea", imports.file.read(n), {key = encryptKey}, true)) or imports.file.read(n)
                        end
                    end
                end
            end
        end
        return true
    end

    function asset:destroy(...)
        if not self or (self == asset) then return false end
        return self:unload(...)
    end

    function asset:clearAssetBuffer(rwCache)
        if not rwCache then return false end
        for i, j in imports.pairs(rwCache) do
            if j and imports.isElement(j) then
                imports.destroyElement(j)
            end
        end
        return true
    end

    function asset:load(assetType, assetName, assetPack, rwCache, assetManifest, assetData, rwPaths, callback)
        if not self or (self == asset) then return false end
        if not assetType or not assetName or not assetPack or not rwCache or not assetManifest or not assetData or not rwPaths then return false end
        local loadState = false
        if assetType == "module" then
            assetData.cAsset = self
            self.rwPaths = rwPaths
            loadState = true
        elseif assetType == "animation" then
            if rwPaths.ifp and not rwCache.ifp[(rwPaths.ifp)] then
                rwCache.ifp[(rwPaths.ifp)] = imports.engineLoadIFP((assetManifest.encryptKey and imports.decodeString("tea", imports.file.read(rwPaths.ifp), {key = assetManifest.encryptKey})) or rwPaths.ifp, assetType.."."..assetName)
                if rwCache.ifp[(rwPaths.ifp)] then
                    assetData.cAsset = self
                    self.rwPaths = rwPaths
                    loadState = true
                end
            end
        elseif assetType == "sound" then
            if rwPaths.sound and not rwCache.sound[(rwPaths.sound)] then
                rwCache.sound[(rwPaths.sound)] = (assetManifest.encryptKey and imports.decodeString("tea", imports.file.read(rwPaths.sound), {key = assetManifest.encryptKey})) or rwPaths.sound
                assetData.cAsset = self
                self.rwPaths = rwPaths
                loadState = true
            end
        else
            if not assetPack.assetType then return false end
            local modelID, collisionID = false, false
            if rwPaths.dff then
                modelID = imports.engineRequestModel(assetPack.assetType, (assetManifest.assetBase and (imports.type(assetManifest.assetBase) == "number") and assetManifest.assetBase) or assetPack.assetBase or nil)
                if modelID then
                    if assetManifest.assetClumps or (assetType == "scene") then
                        collisionID = imports.engineRequestModel(assetPack.assetType, assetPack.assetBase)
                    end
                    if not rwCache.dff[(rwPaths.dff)] and imports.file.exists(rwPaths.dff) then
                        imports.engineSetModelLODDistance(modelID, asset.ranges.streamRange)
                        rwCache.dff[(rwPaths.dff)] = imports.engineLoadDFF((assetManifest.encryptKey and imports.decodeString("tea", imports.file.read(rwPaths.dff), {key = assetManifest.encryptKey})) or rwPaths.dff)
                    end
                    if not rwCache.dff[(rwPaths.dff)] then
                        imports.engineFreeModel(modelID)
                        if collisionID then
                            imports.engineFreeModel(collisionID)
                            collisionID = false
                        end
                        return false
                    else
                        if not rwCache.col[(rwPaths.col)] and imports.file.exists(rwPaths.col) then
                            if collisionID then
                                imports.engineSetModelLODDistance(collisionID, asset.ranges.streamRange)
                            end
                            rwCache.col[(rwPaths.col)] = imports.engineLoadCOL((assetManifest.encryptKey and imports.decodeString("tea", imports.file.read(rwPaths.col), {key = assetManifest.encryptKey})) or rwPaths.col)
                        else
                            if collisionID then
                                imports.engineFreeModel(collisionID)
                                collisionID = false
                            end
                        end
                    end
                end
            end
            if modelID then
                if not rwCache.txd[(rwPaths.txd)] and imports.file.exists(rwPaths.txd) then
                    rwCache.txd[(rwPaths.txd)] = imports.engineLoadTXD((assetManifest.encryptKey and imports.decodeString("tea", imports.file.read(rwPaths.txd), {key = assetManifest.encryptKey})) or rwPaths.txd)
                end
                if rwCache.txd[(rwPaths.txd)] then
                    imports.engineImportTXD(rwCache.txd[(rwPaths.txd)], modelID)
                end
                imports.engineReplaceModel(rwCache.dff[(rwPaths.dff)], modelID, (assetManifest and assetManifest.assetTransparency and true) or assetPack.assetTransparency)
                if collisionID then
                    imports.engineImportTXD(asset.rwAssets.txd, collisionID)
                    imports.engineReplaceModel(asset.rwAssets.dff, collisionID, false)
                end
                if rwCache.col[(rwPaths.col)] then
                    imports.engineReplaceCOL(rwCache.col[(rwPaths.col)], modelID)
                    if collisionID then
                        imports.engineReplaceCOL(rwCache.col[(rwPaths.col)], collisionID)
                    end
                end
                assetData.cAsset = self
                self.rwPaths = rwPaths
                self.synced = {
                    modelID = modelID,
                    collisionID = collisionID
                }
                loadState = true
            end
        end
        if callback and (imports.type(callback) == "function") then
            callback(loadState)
        end
        return loadState
    end

    function asset:unload(rwCache, callback)
        if not self or (self == asset) or self.isUnloading then return false end
        if not rwCache then return false end
        self.isUnloading = true
        if self.synced then
            if self.synced.modelID then
                imports.engineFreeModel(self.synced.modelID)
            end
            if self.synced.collisionID then
                imports.engineFreeModel(self.synced.collisionID)
            end
        end
        if self.rwPaths then
            for i, j in imports.pairs(self.rwPaths) do
                if rwCache[i] and rwCache[i][j] and imports.isElement(rwCache[i][j]) then
                    imports.destroyElement(rwCache[i][j])
                    rwCache[i][j] = nil
                end
            end
        end
        self = nil
        if callback and (imports.type(callback) == "function") then
            callback(true)
        end
        return true
    end
else
    function asset:buildFile(filePath, filePointer, encryptKey, rawPointer, skipSync)
        if not filePath or not filePointer then return false end
        if (not skipSync and not filePointer.unSynced.fileHash[filePath]) or (skipSync and rawPointer and not rawPointer[filePath]) then
            local builtFileData, builtFileSize = imports.file.read(filePath)
            if builtFileData then
                if not skipSync then
                    filePointer.synced.assetSize.file[filePath] = builtFileSize
                    filePointer.synced.assetSize.total = filePointer.synced.assetSize.total + filePointer.synced.assetSize.file[filePath]
                    syncer.libraryBandwidth = syncer.libraryBandwidth + filePointer.synced.assetSize.file[filePath]
                    filePointer.unSynced.fileData[filePath] = (encryptKey and imports.encodeString("tea", builtFileData, {key = encryptKey})) or builtFileData
                    filePointer.unSynced.fileHash[filePath] = imports.md5(filePointer.unSynced.fileData[filePath])
                end
                if rawPointer then rawPointer[filePath] = builtFileData end
            end
        end
        return true
    end

    function asset:buildShader(assetPath, shaderPack, filePointer, encryptKey)
        for i, j in imports.pairs(shaderPack) do
            if j and (imports.type(j) == "table") then
                if i == "clump" then
                    for k, v in imports.pairs(j) do
                        for m = 1, #v, 1 do
                            local n = v[m]
                            if n.clump then
                                n.clump = assetPath.."map/"..n.clump
                                asset:buildFile(n.clump, filePointer, encryptKey)
                            end
                            if n.bump then
                                n.bump = assetPath.."map/"..n.bump
                                asset:buildFile(n.bump, filePointer, encryptKey)
                            end
                        end
                    end
                elseif i == "control" then
                    for k, v in imports.pairs(j) do
                        for m = 1, #v, 1 do
                            local n = v[m]
                            if n.control then
                                n.control = assetPath.."map/"..n.control
                                asset:buildFile(n.control, filePointer, encryptKey)
                            end
                            if n.bump then
                                n.bump = assetPath.."map/"..n.bump
                                asset:buildFile(n.bump, filePointer, encryptKey)
                            end
                            for x = 1, #shader.cache.validChannels, 1 do
                                local y = shader.cache.validChannels[x].index
                                if n[y] then
                                    n[y].map = assetPath.."map/"..n[y].map
                                    asset:buildFile(n[y].map, filePointer, encryptKey)
                                    if n[y].bump then
                                        n[y].bump = assetPath.."map/"..n[y].bump
                                        asset:buildFile(n[y].bump, filePointer, encryptKey)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            thread.pause()
        end
        return true
    end

    function asset:buildPack(assetType, assetPack, callback)
        if not assetType or not assetPack or not callback or (imports.type(callback) ~= "function") then return false end
        local cAssetPack = imports.table.clone(assetPack, true)
        cAssetPack.manifestData = imports.file.read((asset.references.root)..imports.string.lower(assetType).."/"..(asset.references.manifest)..".json")
        cAssetPack.manifestData = (cAssetPack.manifestData and imports.json.decode(cAssetPack.manifestData)) or false
        if cAssetPack.manifestData then
            cAssetPack.rwDatas = {}
            thread:create(function(cThread)
                local callbackReference = callback
                for i = 1, #cAssetPack.manifestData, 1 do
                    local assetName = cAssetPack.manifestData[i]
                    local assetPath = (asset.references.root)..imports.string.lower(assetType).."/"..assetName.."/"
                    local assetManifestPath = assetPath..(asset.references.asset)..".json"
                    local assetManifestData = imports.file.read(assetManifestPath)
                    assetManifestData = (assetManifestData and imports.json.decode(assetManifestData)) or false
                    if assetManifestData then
                        assetManifestData.streamRange = imports.math.max(imports.tonumber(assetManifestData.streamRange) or 0, asset.ranges.streamRange)
                        assetManifestData.enableLODs = (assetManifestData.enableLODs and true) or false
                        assetManifestData.encryptKey = (assetManifestData.encryptKey and imports.md5(imports.tostring(assetManifestData.encryptKey))) or false
                        assetManifestData.assetClumps = (assetManifestData.assetClumps and (imports.type(assetManifestData.assetClumps) == "table") and assetManifestData.assetClumps) or false
                        assetManifestData.assetAnimations = (assetManifestData.assetAnimations and (imports.type(assetManifestData.assetAnimations) == "table") and assetManifestData.assetAnimations) or false
                        assetManifestData.assetSounds = (assetManifestData.assetSounds and (imports.type(assetManifestData.assetSounds) == "table") and assetManifestData.assetSounds) or false
                        assetManifestData.shaderMaps = (assetManifestData.shaderMaps and (imports.type(assetManifestData.shaderMaps) == "table") and assetManifestData.shaderMaps) or false
                        assetManifestData.assetDeps = (assetManifestData.assetDeps and (imports.type(assetManifestData.assetDeps) == "table") and assetManifestData.assetDeps) or false
                        cAssetPack.rwDatas[assetName] = {
                            synced = {
                                manifestData = assetManifestData,
                                assetSize = {
                                    total = 0,
                                    file = {}
                                }
                            },
                            unSynced = {
                                rawData = {},
                                fileData = {},
                                fileHash = {}
                            }
                        }
                        if assetType == "module" then
                            imports.table.insert(syncer.libraryModules, assetName)
                            assetManifestData.streamRange = false
                            assetManifestData.enableLODs = false
                            assetManifestData.assetClumps = false
                            assetManifestData.assetAnimations = false
                            assetManifestData.assetSounds = false
                            assetManifestData.shaderMaps = false
                        elseif assetType == "animation" then
                            assetManifestData.streamRange = false
                            assetManifestData.enableLODs = false
                            assetManifestData.assetClumps = false
                            assetManifestData.assetSounds = false
                            assetManifestData.shaderMaps = false
                            asset:buildFile(assetPath..(asset.references.asset)..".ifp", cAssetPack.rwDatas[assetName], assetManifestData.encryptKey)
                            thread.pause()
                        elseif assetType == "sound" then
                            assetManifestData.streamRange = false
                            assetManifestData.enableLODs = false
                            assetManifestData.assetClumps = false
                            assetManifestData.assetAnimations = false
                            assetManifestData.shaderMaps = false
                            if assetManifestData.assetSounds then
                                local assetSounds = {}
                                for i, j in imports.pairs(assetManifestData.assetSounds) do
                                    if j and (imports.type(j) == "table") then
                                        assetSounds[i] = {}
                                        for k, v in imports.pairs(j) do
                                            if v then
                                                assetSounds[i][k] = v
                                                asset:buildFile(assetPath.."sound/"..v, cAssetPack.rwDatas[assetName], assetManifestData.encryptKey)
                                                thread.pause()
                                            end
                                        end
                                    end
                                end
                                assetManifestData.assetSounds = assetSounds
                            end
                            thread.pause()
                        else
                            assetManifestData.assetAnimations = false
                            assetManifestData.assetSounds = false
                            if assetType == "scene" then
                                assetManifestData.assetClumps = false
                                assetManifestData.sceneDimension = imports.math.max(asset.ranges.dimension[1], imports.math.min(asset.ranges.dimension[2], imports.tonumber(assetManifestData.sceneDimension) or 0))
                                assetManifestData.sceneInterior = imports.math.max(asset.ranges.interior[1], imports.math.min(asset.ranges.interior[2], imports.tonumber(assetManifestData.sceneInterior) or 0))
                                assetManifestData.sceneMapped = (assetManifestData.sceneMapped and true) or false
                                if assetManifestData.sceneOffset then
                                    if imports.type(assetManifestData.sceneOffset) ~= "table" then
                                        assetManifestData.sceneOffset = false
                                    else
                                        for i, j in imports.pairs(assetManifestData.sceneOffset) do
                                            assetManifestData.sceneOffset[i] = imports.tonumber(j)
                                        end
                                    end
                                end
                                local sceneIPLPath = assetPath..(asset.references.scene)..".ipl"
                                local sceneIPLData = imports.file.read(sceneIPLPath)
                                if sceneIPLData then
                                    asset:buildFile(sceneIPLPath, cAssetPack.rwDatas[assetName], assetManifestData.encryptKey)
                                    if not assetManifestData.sceneMapped then
                                        local sceneIDEPath = assetPath..(asset.references.scene)..".ide"
                                        local sceneIDEData = imports.file.read(sceneIDEPath)
                                        asset:buildFile(sceneIDEPath, cAssetPack.rwDatas[assetName], assetManifestData.encryptKey)
                                        asset:buildFile(assetPath..(asset.references.asset)..".txd", cAssetPack.rwDatas[assetName], assetManifestData.encryptKey)
                                        local unparsedIDEDatas, unparsedIPLDatas = (sceneIDEData and imports.split(sceneIDEData, "\n")) or false, imports.split(sceneIPLData, "\n")
                                        local parsedIDEDatas = (unparsedIDEDatas and {}) or false
                                        cAssetPack.rwDatas[assetName].synced.sceneIDE = (parsedIDEDatas and true) or false
                                        if unparsedIDEDatas then
                                            for k = 1, #unparsedIDEDatas, 1 do
                                                local childName = imports.string.gsub(imports.tostring(imports.gettok(unparsedIDEDatas[k], 2, asset.separators.IDE)), " ", "")
                                                parsedIDEDatas[childName] = {
                                                    imports.string.gsub(imports.tostring(imports.gettok(unparsedIDEDatas[k], 3, asset.separators.IDE)), " ", "")
                                                }
                                            end
                                        end
                                        for k = 1, #unparsedIPLDatas, 1 do
                                            local childName = imports.string.gsub(imports.tostring(imports.gettok(unparsedIPLDatas[k], 2, asset.separators.IPL)), " ", "")
                                            asset:buildFile(assetPath.."dff/"..childName..".dff", cAssetPack.rwDatas[assetName], assetManifestData.encryptKey)
                                            asset:buildFile(assetPath.."col/"..childName..".col", cAssetPack.rwDatas[assetName], assetManifestData.encryptKey)
                                            if parsedIDEDatas and parsedIDEDatas[childName] then
                                                asset:buildFile(assetPath.."txd/"..(parsedIDEDatas[childName][1])..".txd", cAssetPack.rwDatas[assetName], assetManifestData.encryptKey)
                                            end
                                            thread.pause()
                                        end
                                    end
                                end
                            else
                                asset:buildFile(assetPath..(asset.references.asset)..".txd", cAssetPack.rwDatas[assetName], assetManifestData.encryptKey)
                                if assetManifestData.assetClumps then
                                    for i, j in imports.pairs(assetManifestData.assetClumps) do
                                        asset:buildFile(assetPath.."clump/"..j.."/"..(asset.references.asset)..".txd", cAssetPack.rwDatas[assetName], assetManifestData.encryptKey)
                                        asset:buildFile(assetPath.."clump/"..j.."/"..(asset.references.asset)..".dff", cAssetPack.rwDatas[assetName], assetManifestData.encryptKey)
                                        asset:buildFile(assetPath.."clump/"..j.."/"..(asset.references.asset)..".col", cAssetPack.rwDatas[assetName], assetManifestData.encryptKey)
                                        thread.pause()
                                    end
                                else
                                    asset:buildFile(assetPath..(asset.references.asset)..".dff", cAssetPack.rwDatas[assetName], assetManifestData.encryptKey)
                                end
                                asset:buildFile(assetPath..(asset.references.asset)..".col", cAssetPack.rwDatas[assetName], assetManifestData.encryptKey)
                                thread.pause()
                            end
                            if assetManifestData.shaderMaps then
                                asset:buildShader(assetPath, assetManifestData.shaderMaps, cAssetPack.rwDatas[assetName], assetManifestData.encryptKey)
                            end
                        end
                        if assetManifestData.assetDeps then
                            local assetDeps = {}
                            for i, j in imports.pairs(assetManifestData.assetDeps) do
                                if j and (imports.type(j) == "table") then
                                    assetDeps[i] = {}
                                    for k, v in imports.pairs(j) do
                                        assetDeps[i][k] = {}
                                        if i == "script" then
                                            for m, n in imports.pairs(v) do
                                                v[m] = assetPath.."dep/"..v[m]
                                                assetDeps[i][k][m] = v[m]
                                                asset:buildFile(assetDeps[i][k][m], cAssetPack.rwDatas[assetName], assetManifestData.encryptKey, cAssetPack.rwDatas[assetName].unSynced.rawData, k == "server")
                                                thread.pause()
                                            end
                                        else
                                            j[k] = assetPath.."dep/"..j[k]
                                            assetDeps[i][k] = j[k]
                                            asset:buildFile(assetDeps[i][k], cAssetPack.rwDatas[assetName], assetManifestData.encryptKey, cAssetPack.rwDatas[assetName].unSynced.rawData)
                                        end
                                        thread.pause()
                                    end
                                end
                                thread.pause()
                            end
                            assetManifestData.assetDeps = assetDeps
                        end
                    end
                end
                assetPack.assetPack = cAssetPack
                if callbackReference and (imports.type(callbackReference) == "function") then
                    callbackReference(true, assetType)
                end
            end):resume({
                executions = downloadSettings.buildRate,
                frames = 1
            })
            return true
        end
        if callbackReference and (imports.type(callbackReference) == "function") then
            callbackReference(false, assetType)
        end
        return false
    end
end