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
    isElement = isElement,
    destroyElement = destroyElement,
    setmetatable = setmetatable,
    fromJSON = fromJSON,
    setTimer = setTimer,
    fetchFileData = fetchFileData,
    engineRequestModel = engineRequestModel,
    engineFreeModel = engineFreeModel,
    engineLoadTXD = engineLoadTXD,
    engineLoadDFF = engineLoadDFF,
    engineLoadCOL = engineLoadCOL,
    engineImportTXD = engineImportTXD,
    engineReplaceModel = engineReplaceModel,
    engineReplaceCOL = engineReplaceCOL,
    string = {
        byte = string.byte
    }
}


----------------------
--[[ Class: Asset ]]--
----------------------

asset = {
    separators = {
        IPL = imports.string.byte(',')
    }
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
    
    function asset:load(assetPackType, assetType, assetBase, assetTransparency, assetData, sceneReference, callback)
    
        if not self or (self == asset) then return false end
        if not assetPackType or not assetType or not assetData or not callback or (imports.type(callback) ~= "function") then return false end
    
        local primary_rwFiles, secondary_rwFiles = nil, nil
        local modelID = false
        if assetData.rwData.dff then
            modelID = imports.engineRequestModel(assetType, (sceneReference and sceneReference.manifestData and sceneReference.manifestData.assetBase and (imports.type(sceneReference.manifestData.assetBase) == "number") and sceneReference.manifestData.assetBase) or (assetData.manifestData and assetData.manifestData.assetBase and (imports.type(assetData.manifestData.assetBase) == "number") and assetData.manifestData.assetBase) or assetBase or nil)
            if modelID then
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
                secondary_rwFiles.txd = (sceneReference and sceneReference.txd and ((imports.isElement(sceneReference.txd) and sceneReference.txd) or imports.engineLoadTXD(sceneReference.txd))) or false
                if secondary_rwFiles.txd then
                    imports.engineImportTXD(secondary_rwFiles.txd, modelID)
                end
            else
                primary_rwFiles.txd = (assetData.rwData.txd and ((imports.isElement(assetData.rwData.txd) and assetData.rwData.txd) or imports.engineLoadTXD(assetData.rwData.txd))) or false
                if primary_rwFiles.txd then
                    imports.engineImportTXD(primary_rwFiles.txd, modelID)
                end
            end
            imports.engineReplaceModel(primary_rwFiles.dff, modelID, (sceneReference and sceneReference.manifestData.assetTransparency and true) or (assetData.manifestData.assetTransparency and true) or assetTransparency)
            if primary_rwFiles.col then
                imports.engineReplaceCOL(primary_rwFiles.col, modelID)
            end
    
            assetData.cAsset = self
            self.cData = assetData
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

        --[[
        local primary_rwFiles, secondary_rwFiles = nil, nil
        local modelID = false
        if assetData.rwData.dff then
            modelID = imports.engineRequestModel(assetType, (sceneReference and sceneReference.manifestData and sceneReference.manifestData.assetBase and (imports.type(sceneReference.manifestData.assetBase) == "number") and sceneReference.manifestData.assetBase) or (assetData.manifestData and assetData.manifestData.assetBase and (imports.type(assetData.manifestData.assetBase) == "number") and assetData.manifestData.assetBase) or assetBase or nil)
            if modelID then
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
                secondary_rwFiles.txd = (sceneReference and sceneReference.txd and ((imports.isElement(sceneReference.txd) and sceneReference.txd) or imports.engineLoadTXD(sceneReference.txd))) or false
                if secondary_rwFiles.txd then
                    imports.engineImportTXD(secondary_rwFiles.txd, modelID)
                end
            else
                primary_rwFiles.txd = (assetData.rwData.txd and ((imports.isElement(assetData.rwData.txd) and assetData.rwData.txd) or imports.engineLoadTXD(assetData.rwData.txd))) or false
                if primary_rwFiles.txd then
                    imports.engineImportTXD(primary_rwFiles.txd, modelID)
                end
            end
            imports.engineReplaceModel(primary_rwFiles.dff, modelID, (sceneReference and sceneReference.manifestData.assetTransparency and true) or (assetData.manifestData.assetTransparency and true) or assetTransparency)
            if primary_rwFiles.col then
                imports.engineReplaceCOL(primary_rwFiles.col, modelID)
            end
    
            assetData.cAsset = self
            self.cData = assetData
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
        ]]--
    end
else
    function asset:buildPack(assetPackType, assetPack, callback)

        if not assetPackType or not assetPack or not callback or (imports.type(callback) ~= "function") then return false end

        local cAssetPack = {
            manifestData = false,
            type = assetPack.reference.type,
            base = assetPack.reference.base,
            transparency = assetPack.reference.transparency,
            rwDatas = {}
        }
        cAssetPack.manifestData = imports.fetchFileData((assetPack.reference.root)..(assetPack.reference.manifest)..".json")
        cAssetPack.manifestData = (cAssetPack.manifestData and imports.fromJSON(cAssetPack.manifestData)) or false

        if cAssetPack.manifestData then
            thread:create(function(cThread)
                local callbackReference = callback
                for i = 1, #cAssetPack.manifestData, 1 do
                    local assetReference = cAssetPack.manifestData[i]
                    local assetPath = (assetPack.reference.root)..assetReference.."/"
                    local assetManifestData = imports.fetchFileData(assetPath..(assetPack.reference.asset)..".json")
                    assetManifestData = (assetManifestData and imports.fromJSON(assetManifestData)) or false
                    if not assetManifestData then
                        cAssetPack.rwDatas[assetPath] = false
                    else
                        cAssetPack.rwDatas[assetReference] = {
                            manifestData = assetManifestData
                        }
                        if assetPackType == "scene" then
                            local sceneManifestData = imports.fetchFileData(assetPath..(assetPack.reference.scene)..".ipl")
                            if sceneManifestData then
                                cAssetPack.rwDatas[assetReference].rwData = {
                                    txd = imports.fetchFileData(assetPath..(assetPack.reference.asset)..".txd"),
                                    children = {}
                                }
                                local unparsedDatas = imports.split(sceneManifestData, "\n")
                                for k = 1, #unparsedDatas, 1 do
                                    local childName = imports.tostring(imports.gettok(unparsedDatas[k], 2, asset.separators.IPL))
                                    cAssetPack.rwDatas[assetReference].rwData.children[childName] = {
                                        rwData = {
                                            dff = imports.fetchFileData(assetPath..(assetPack.reference.asset).."/dff/"..childName..".dff"),
                                            col = imports.fetchFileData(assetPath..(assetPack.reference.asset).."/col/"..childName..".col")
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
                                txd = imports.fetchFileData(assetPath..(assetPack.reference.asset)..".txd"),
                                dff = imports.fetchFileData(assetPath..(assetPack.reference.asset)..".dff"),
                                col = imports.fetchFileData(assetPath..(assetPack.reference.asset)..".col")
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