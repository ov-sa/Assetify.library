----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: asset.lua
     Server: -
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
    fromJSON = fromJSON,
    isElement = isElement,
    destroyElement = destroyElement,
    setmetatable = setmetatable,
    setTimer = setTimer,
    engineRequestModel = engineRequestModel,
    engineSetModelLODDistance = engineSetModelLODDistance,
    engineFreeModel = engineFreeModel,
    engineLoadTXD = engineLoadTXD,
    engineLoadDFF = engineLoadDFF,
    engineLoadCOL = engineLoadCOL,
    engineImportTXD = engineImportTXD,
    engineReplaceModel = engineReplaceModel,
    engineReplaceCOL = engineReplaceCOL,
    file = file,
    table = table,
    string = string,
    math = math
}


----------------------
--[[ Class: Asset ]]--
----------------------

asset = {
    references = {
        root = "@files/assets/",
        manifest = "manifest",
        asset = "asset",
        scene = "scene"
    },
    separators = {
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
    
    function asset:destroy(...)
        if not self or (self == asset) then return false end
        return self:unload(...)
    end
    
    function asset:load(assetType, assetPack, rwCache, assetManifest, assetData, rwPaths, callback)
        if not self or (self == asset) then return false end
        if not assetType or not assetPack or not assetPack.assetType or not rwCache or not assetManifest or not assetData or not rwPaths then return false end
        local modelID, collisionID = false, false
        if rwPaths.dff then
            modelID = imports.engineRequestModel(assetPack.assetType, (assetManifest.assetBase and (imports.type(assetManifest.assetBase) == "number") and assetManifest.assetBase) or assetPack.assetBase or nil)
            if modelID then
                if assetType == "scene" then
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
        local loadState = false
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
            self.syncedData = {
                modelID = modelID,
                collisionID = collisionID
            }
            loadState = true
        end
        if callback and (imports.type(callback) == "function") then
            callback(loadState)
        end
        return loadState
    end

    function asset:unload(rwCache, callback)
        if not self or (self == asset) then return false end
        if not rwCache then return false end
        imports.engineFreeModel(self.syncedData.modelID)
        if self.syncedData.collisionID then
            imports.engineFreeModel(self.syncedData.collisionID)
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
    function asset:buildFile(filePath, filePointer, encryptKey)
        if not filePath or not filePointer then return false end
        if not filePointer[filePath] then
            local builtFileData = imports.file.read(filePath)
            if builtFileData then
                filePointer[filePath] = true
                filePointer.fileData[filePath] = (encryptKey and imports.encodeString("tea", builtFileData, {key = encryptKey})) or builtFileData
                filePointer.fileHash[filePath] = imports.md5(filePointer.fileData[filePath])
            end
        end
        return true
    end

    function asset:buildShader(assetPath, shaderPack, assetFiles, encryptKey)
        for i, j in imports.pairs(shaderPack) do
            if j and (imports.type(j) == "table") then
                if i == "clump" then
                    for k, v in imports.pairs(j) do
                        for m = 1, #v, 1 do
                            v[m] = assetPath.."map/"..v[m]
                            asset:buildFile(v[m], assetFiles, encryptKey)
                        end
                    end
                elseif i == "control" then
                    for k, v in imports.pairs(j) do
                        for m = 1, #v, 1 do
                            local n = v[m]
                            if n.control then
                                n.control = assetPath.."map/"..n.control
                                asset:buildFile(n.control, assetFiles, encryptKey)
                            end
                            if n.bump then
                                n.bump = assetPath.."map/"..n.bump
                                asset:buildFile(n.bump, assetFiles, encryptKey)
                            end
                            for x = 1, #shader.defaultData.shaderChannels, 1 do
                                local y = shader.defaultData.shaderChannels[x].index
                                if n[y] then
                                    n[y].map = assetPath.."map/"..n[y].map
                                    asset:buildFile(n[y].map, assetFiles, encryptKey)
                                    if n[y].bump then
                                        n[y].bump = assetPath.."map/"..n[y].bump
                                        asset:buildFile(n[y].bump, assetFiles, encryptKey)
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
        cAssetPack.manifestData = (cAssetPack.manifestData and imports.fromJSON(cAssetPack.manifestData)) or false
        if cAssetPack.manifestData then
            cAssetPack.rwDatas = {}
            thread:create(function(cThread)
                local callbackReference = callback
                for i = 1, #cAssetPack.manifestData, 1 do
                    local assetReference = cAssetPack.manifestData[i]
                    local assetPath = (asset.references.root)..imports.string.lower(assetType).."/"..assetReference.."/"
                    local assetManifestPath = assetPath..(asset.references.asset)..".json"
                    local assetManifestData = imports.file.read(assetManifestPath)
                    assetManifestData = (assetManifestData and imports.fromJSON(assetManifestData)) or false
                    if not assetManifestData then
                        cAssetPack.rwDatas[assetPath] = false
                    else
                        assetManifestData.streamRange = imports.math.max(imports.tonumber(assetManifestData.streamRange) or 0, asset.ranges.streamRange)
                        assetManifestData.enableLODs = (assetManifestData.enableLODs and true) or false
                        assetManifestData.encryptKey = (assetManifestData.encryptKey and imports.md5(imports.tostring(assetManifestData.encryptKey))) or false
                        assetManifestData.assetClumps = (assetManifestData.assetClumps and (imports.type(assetManifestData.assetClumps) == "table") and assetManifestData.assetClumps) or false
                        cAssetPack.rwDatas[assetReference] = {
                            synced = {
                                manifestData = assetManifestData
                            },
                            unSynced = {
                                fileList = {},
                                fileData = {},
                                fileHash = {}
                            }
                        }
                        assetManifestData.shaderMaps = (assetManifestData.shaderMaps and (imports.type(assetManifestData.shaderMaps) == "table") and assetManifestData.shaderMaps) or false
                        if assetType == "scene" then
                            assetManifestData.sceneDimension = imports.math.max(asset.ranges.dimension[1], imports.math.min(asset.ranges.dimension[2], imports.tonumber(assetManifestData.sceneDimension) or 0))
                            assetManifestData.sceneInterior = imports.math.max(asset.ranges.interior[1], imports.math.min(asset.ranges.interior[2], imports.tonumber(assetManifestData.sceneInterior) or 0))
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
                            local sceneManifestData = imports.file.read(sceneIPLPath)
                            if sceneManifestData then
                                asset:buildFile(sceneIPLPath, cAssetPack.rwDatas[assetReference].unSynced, assetManifestData.encryptKey)
                                asset:buildFile(assetPath..(asset.references.asset)..".txd", cAssetPack.rwDatas[assetReference].unSynced, assetManifestData.encryptKey)
                                local unparsedDatas = imports.split(sceneManifestData, "\n")
                                for k = 1, #unparsedDatas, 1 do
                                    local childName = imports.string.gsub(imports.tostring(imports.gettok(unparsedDatas[k], 2, asset.separators.IPL)), " ", "")
                                    asset:buildFile(assetPath.."dff/"..childName..".dff", cAssetPack.rwDatas[assetReference].unSynced, assetManifestData.encryptKey)
                                    asset:buildFile(assetPath.."col/"..childName..".col", cAssetPack.rwDatas[assetReference].unSynced, assetManifestData.encryptKey)
                                    thread.pause()
                                end
                            end
                        else
                            asset:buildFile(assetPath..(asset.references.asset)..".txd", cAssetPack.rwDatas[assetReference].unSynced, assetManifestData.encryptKey)
                            if assetManifestData.assetClumps then
                                for i, j in imports.pairs(assetManifestData.assetClumps) do
                                    asset:buildFile(assetPath.."clump/"..j..".dff", cAssetPack.rwDatas[assetReference].unSynced, assetManifestData.encryptKey)
                                end
                            else
                                asset:buildFile(assetPath..(asset.references.asset)..".dff", cAssetPack.rwDatas[assetReference].unSynced, assetManifestData.encryptKey)
                            end
                            asset:buildFile(assetPath..(asset.references.asset)..".col", cAssetPack.rwDatas[assetReference].unSynced, assetManifestData.encryptKey)
                            thread.pause()
                        end
                        if assetManifestData.shaderMaps then
                            asset:buildShader(assetPath, assetManifestData.shaderMaps, cAssetPack.rwDatas[assetReference].unSynced, assetManifestData.encryptKey)
                        end
                    end
                end
                assetPack.assetPack = cAssetPack
                if callbackReference and (imports.type(callbackReference) == "function") then
                    callbackReference(true)
                end
            end):resume({
                executions = downloadSettings.buildRate,
                frames = 1
            })
            return true
        end
        if callbackReference and (imports.type(callbackReference) == "function") then
            callbackReference(false)
        end
        return false
    end
end