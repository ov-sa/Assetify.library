----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: asset.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Asset Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    split = split,
    gettok = gettok,
    tonumber = tonumber,
    tostring = tostring,
    fromJSON = fromJSON,
    isElement = isElement,
    destroyElement = destroyElement,
    setmetatable = setmetatable,
    collectgarbage = collectgarbage,
    fetchFileData = fetchFileData,
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
    dxCreateTexture = dxCreateTexture,
    table = {
        clone = table.clone
    },
    string = {
        byte = string.byte,
        lower = string.lower,
        gsub = string.gsub
    },
    math = {
        min = math.min,
        max = math.max
    }
}


----------------------
--[[ Class: Asset ]]--
----------------------

asset = {
    references = {
        root = "files/assets/",
        manifest = "manifest",
        asset = "asset",
        scene = "scene"
    },
    separators = {
        IPL = imports.string.byte(", ")
    },
    ranges = {
        dimension = {-1, 65535},
        interior = {0, 255}
    },
    cMaps = {}
}
asset.__index = asset

if localPlayer then
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
    
    function asset:load(assetPackType, assetPack, assetData, assetScene, callback)
    
        if not self or (self == asset) then return false end
        if not assetPackType or not assetPack.assetType or not assetData or not callback or (imports.type(callback) ~= "function") then return false end

        local primary_rwFiles, secondary_rwFiles = nil, nil
        local modelID = false
        if assetData.rwData.dff then
            modelID = imports.engineRequestModel(assetPack.assetType, (assetScene and assetScene.manifestData and assetScene.manifestData.assetBase and (imports.type(assetScene.manifestData.assetBase) == "number") and assetScene.manifestData.assetBase) or (assetData.manifestData and assetData.manifestData.assetBase and (imports.type(assetData.manifestData.assetBase) == "number") and assetData.manifestData.assetBase) or assetPack.assetBase or nil)
            if modelID then
                imports.engineSetModelLODDistance(modelID, 300)
                primary_rwFiles = {}
                primary_rwFiles.dff = (assetData.rwData.dff and ((imports.isElement(assetData.rwData.dff) and assetData.rwData.dff) or imports.engineLoadDFF(assetData.rwData.dff))) or false
                primary_rwFiles.col = (assetData.rwData.col and ((imports.isElement(assetData.rwData.col) and assetData.rwData.col) or imports.engineLoadCOL(assetData.rwData.col))) or false
                if not primary_rwFiles.dff then
                    imports.engineFreeModel(modelID)
                    for i, j in imports.pairs(primary_rwFiles) do
                        if j and imports.isElement(j) then
                            imports.destroyElement(j)
                        end
                    end
                    primary_rwFiles = nil
                end
            end
        end
    
        local loadState = false
        if primary_rwFiles then
            if assetPackType == "scene" then
                secondary_rwFiles = {}
                secondary_rwFiles.txd = (assetScene and assetScene.rwData.txd and ((imports.isElement(assetScene.rwData.txd) and assetScene.rwData.txd) or imports.engineLoadTXD(assetScene.rwData.txd))) or false
                if secondary_rwFiles.txd then
                    imports.engineImportTXD(secondary_rwFiles.txd, modelID)
                end
            else
                primary_rwFiles.txd = (assetData.rwData.txd and ((imports.isElement(assetData.rwData.txd) and assetData.rwData.txd) or imports.engineLoadTXD(assetData.rwData.txd))) or false
                if primary_rwFiles.txd then
                    imports.engineImportTXD(primary_rwFiles.txd, modelID)
                end
            end
            imports.engineReplaceModel(primary_rwFiles.dff, modelID, (assetScene and assetScene.manifestData and assetScene.manifestData.assetTransparency and true) or (assetData.manifestData and assetData.manifestData.assetTransparency and true) or assetPack.assetTransparency)
            if primary_rwFiles.col then
                imports.engineReplaceCOL(primary_rwFiles.col, modelID)
            end
    
            assetData.cAsset = self
            self.cData = assetData
            self.cScene = assetScene
            self.syncedData = {
                modelID = modelID
            }
            self.unsyncedData = {
                primary_rwFiles = primary_rwFiles,
                secondary_rwFiles = secondary_rwFiles
            }
            assetData.cData = syncedData
            loadState = true
        end
        callback(loadState)
        return loadState
    
    end

    function asset:unload(callback)

        if not self or (self == asset) then return false end
        if not callback or (imports.type(callback) ~= "function") then return false end

        imports.engineFreeModel(self.syncedData.modelID)
        if self.unsyncedData.primary_rwFiles then
            for i, j in imports.pairs(self.unsyncedData.primary_rwFiles) do
                if j and imports.isElement(j) then
                    imports.destroyElement(j)
                end
            end
        end
        if self.unsyncedData.secondary_rwFiles then
            for i, j in imports.pairs(self.unsyncedData.secondary_rwFiles) do
                if j and imports.isElement(j) then
                    imports.destroyElement(j)
                end
            end
        end
        self.cData.cAsset = nil
        self = nil
        imports.collectgarbage()
        callback(true)
        return true

    end

    function asset:refreshMaps(refreshState, mapPack, mapData, mapType)

        if not mapPack or (refreshState and not mapData) or (imports.type(mapData) ~= "table") then return false end

        for i, j in imports.pairs(mapData) do
            if not mapType then
                asset:refreshMaps(refreshState, mapPack, j, i)
            else
                if refreshState then
                    if not asset.cMaps[i] then
                        if mapType == "bump" then
                            for k, v in imports.pairs(mapData) do
                                if v.map then
                                    local createdMap = imports.dxCreateTexture(v.map)
                                    local createdBumpMap = exports.graphify_library:createBumpMap(i, "world", createdMap)
                                    asset.cMaps[k] = {map = createdMap, shader = createdBumpMap}
                                end
                            end
                        elseif mapType == "control" then
                            
                        end
                    end
                else
                    if asset.cMaps[i] then
                        for k, v in imports.pairs(asset.cMaps[i]) do
                            if v and imports.isElement(v) then
                                imports.destroyElement(v)
                            end
                        end
                        asset.cMaps[i] = nil
                    end
                end
                if mapType == "emissive" then
                    if j then
                        exports.graphify_library:setTextureEmissiveState(i, "world", refreshState)
                    end
                end
            end
        end
        if not mapType and not refreshMaps then
            imports.collectgarbage()
        end
        return true

    end
else
    function asset:buildShader(assetPath, cThread, shaderMaps, shaderPack)

        if not assetPath or not cThread or not shaderMaps or not shaderPack then return false end

        for i, j in imports.pairs(shaderMaps) do
            if j and (imports.type(j) == "table") then
                shaderPack[i] = {}
                asset:buildShader(assetPath, cThread, j, shaderPack[i])
            else
                shaderPack[i] = ((i == "map") and imports.fetchFileData(assetPath.."map/"..j)) or j
            end
            imports.setTimer(function()
                cThread:resume()
            end, 1, 1)
            thread.pause()
        end
        return true

    end

    function asset:buildPack(assetPackType, assetPack, callback)

        if not assetPackType or not assetPack or not callback or (imports.type(callback) ~= "function") then return false end

        local cAssetPack = imports.table.clone(assetPack, true)
        cAssetPack.manifestData = imports.fetchFileData((asset.references.root)..imports.string.lower(assetPackType).."/"..(asset.references.manifest)..".json")
        cAssetPack.manifestData = (cAssetPack.manifestData and imports.fromJSON(cAssetPack.manifestData)) or false

        if cAssetPack.manifestData then
            cAssetPack.rwDatas = {}
            thread:create(function(cThread)
                local callbackReference = callback
                for i = 1, #cAssetPack.manifestData, 1 do
                    local assetReference = cAssetPack.manifestData[i]
                    local assetPath = (asset.references.root)..imports.string.lower(assetPackType).."/"..assetReference.."/"
                    local assetManifestData = imports.fetchFileData(assetPath..(asset.references.asset)..".json")
                    assetManifestData = (assetManifestData and imports.fromJSON(assetManifestData)) or false
                    if not assetManifestData then
                        cAssetPack.rwDatas[assetPath] = false
                    else
                        cAssetPack.rwDatas[assetReference] = {
                            manifestData = assetManifestData
                        }
                        if assetManifestData.shaderMaps then
                            cAssetPack.rwDatas[assetReference].rwMap = {}
                            asset:buildShader(assetPath, cThread, assetManifestData.shaderMaps, cAssetPack.rwDatas[assetReference].rwMap)
                        end
                        if assetPackType == "scene" then
                            assetManifestData.sceneDimension = imports.math.max(asset.ranges.dimension[1], imports.math.min(asset.ranges.dimension[2], imports.tonumber(assetManifestData.sceneDimension) or 0))
                            assetManifestData.sceneInterior = imports.math.max(asset.ranges.interior[1], imports.math.min(asset.ranges.interior[2], imports.tonumber(assetManifestData.sceneInterior) or 0))
                            assetManifestData.shaderMaps = (assetManifestData.shaderMaps and (imports.type(assetManifestData.shaderMaps) == "table") and assetManifestData.shaderMaps) or false
                            if assetManifestData.sceneOffset then
                                if imports.type(assetManifestData.sceneOffset) ~= "table" then
                                    assetManifestData.sceneOffset = false
                                else
                                    for i, j in imports.pairs(assetManifestData.sceneOffset) do
                                        assetManifestData.sceneOffset[i] = imports.tonumber(j)
                                    end
                                end
                            end
                            local sceneManifestData = imports.fetchFileData(assetPath..(asset.references.scene)..".ipl")
                            if sceneManifestData then
                                cAssetPack.rwDatas[assetReference].rwData = {
                                    txd = imports.fetchFileData(assetPath..(asset.references.asset)..".txd"),
                                    children = {}
                                }
                                local unparsedDatas = imports.split(sceneManifestData, "\n")
                                for k = 1, #unparsedDatas, 1 do
                                    local childName = imports.string.gsub(imports.tostring(imports.gettok(unparsedDatas[k], 2, asset.separators.IPL)), " ", "")
                                    cAssetPack.rwDatas[assetReference].rwData.children[childName] = {
                                        rwData = {
                                            dff = imports.fetchFileData(assetPath.."dff/"..childName..".dff"),
                                            col = imports.fetchFileData(assetPath.."col/"..childName..".col")
                                        },
                                        position = {
                                            x = imports.tonumber(imports.gettok(unparsedDatas[k], 4, asset.separators.IPL)),
                                            y = imports.tonumber(imports.gettok(unparsedDatas[k], 5, asset.separators.IPL)),
                                            z = imports.tonumber(imports.gettok(unparsedDatas[k], 6, asset.separators.IPL))
                                        },
                                        rotation = {
                                            x = imports.tonumber(imports.gettok(unparsedDatas[k], 7, asset.separators.IPL)),
                                            y = imports.tonumber(imports.gettok(unparsedDatas[k], 8, asset.separators.IPL)),
                                            z = imports.tonumber(imports.gettok(unparsedDatas[k], 9, asset.separators.IPL))
                                        }
                                    }
                                    imports.setTimer(function()
                                        cThread:resume()
                                    end, 1, 1)
                                    thread.pause()
                                end
                            end
                        else
                            cAssetPack.rwDatas[assetReference].rwData = {
                                txd = imports.fetchFileData(assetPath..(asset.references.asset)..".txd"),
                                dff = imports.fetchFileData(assetPath..(asset.references.asset)..".dff"),
                                col = imports.fetchFileData(assetPath..(asset.references.asset)..".col")
                            }
                        end
                    end
                    imports.setTimer(function()
                        cThread:resume()
                    end, 1, 1)
                    thread.pause()
                end
                assetPack.assetPack = cAssetPack
                if callbackReference and (imports.type(callbackReference) == "function") then
                    callbackReference(true)
                end
            end):resume()
            return true
        end
        if callbackReference and (imports.type(callbackReference) == "function") then
            callbackReference(false)
        end
        return false

    end
end