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

function asset:create(assetType, assetBase, assetTransparency, assetData, callback)

    if not assetType or not assetData or not callback or (imports.type(callback) ~= "function") then return false end

    local cAsset = imports.setmetatable({}, {__index = self})
    assetData.cAsset = cAsset
    cAsset.cData = assetData
    cAsset:load(assetType, assetBase, assetTransparency, assetData, callback)
    return cAsset

end

function asset:load(assetType, assetBase, assetTransparency, assetData, callback)

    if not assetType or not assetData or not callback or (imports.type(callback) ~= "function") then return false end

    local loadState = false
    if assetData.rwData.txd and assetData.rwData.dff then
        local modelID = imports.engineRequestModel(assetType, (assetData.manifestData.assetBase and (imports.type(assetData.manifestData.assetBase) == "number") and assetData.manifestData.assetBase) or assetBase or nil)
        if modelID then
            local rwFiles = {}
            rwFiles.txd = (assetData.rwData.txd and ((imports.isElement(assetData.rwData.txd) and assetData.rwData.txd) or imports.engineLoadTXD(assetData.rwData.txd))) or false
            rwFiles.dff = (assetData.rwData.dff and ((imports.isElement(assetData.rwData.dff) and assetData.rwData.dff) or imports.engineLoadDFF(assetData.rwData.dff))) or false
            rwFiles.col = (assetData.rwData.col and ((imports.isElement(assetData.rwData.col) and assetData.rwData.col) or imports.engineLoadCOL(assetData.rwData.col))) or false
            if rwFiles.dff then
                if rwFiles.txd then
                    imports.engineImportTXD(rwFiles.txd, modelID)
                end
                imports.engineReplaceModel(rwFiles.dff, modelID, (assetData.manifestData.assetTransparency and true) or assetTransparency)
                if rwFiles.col then
                    imports.engineReplaceCOL(rwFiles.col, modelID)
                end
            else
                imports.engineFreeModel(modelID)
                for i, j in imports.pairs(rwFiles) do
                    if j and imports.isElement(j) then
                        imports.destroyElement(j)
                    end
                end
                rwFiles = nil
            end
            if rwFiles then
                self.syncedData = {
                    modelID = modelID
                }
                self.unsyncedData = {
                    rwFiles = rwFiles
                }
                assetData.cData = syncedData
                loadState = true
            end
        end
    end
    callback(loadState)
    return loadState

end

if not localPlayer then

    function asset:buildPack(assetType, assetPack, callback)

        if not assetType or not assetPack or not callback or (imports.type(callback) ~= "function") then return false end

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
                        if assetType == "scene" then
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