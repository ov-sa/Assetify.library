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
    engineReplaceCOL = engineReplaceCOL
}


----------------------
--[[ Class: Asset ]]--
----------------------

asset = {}
asset.__index = asset

function asset:create(assetData, callback)

    if not assetData or not callback or (imports.type(callback) ~= "function") then return false end

    local createdAsset = imports.setmetatable({}, {__index = self})
    assetData.cAsset = createdAsset
    createdAsset:load(assetData, callback)
    return createdAsset

end

function asset:load(assetData, callback)

    if not assetData or not callback or (imports.type(callback) ~= "function") then return false end

    local loadState = false
    if assetData.rwData.txd and assetData.rwData.dff then
        rwModelID = imports.engineRequestModel(assetData.type, assetData.manifestData.assetBase or assetData.base or nil)
        if rwModelID then
            local rwFiles = {}
            rwFiles.txd = (assetData.rwData.txd and ((imports.isElement(assetData.rwData.txd) and assetData.rwData.txd) or imports.engineLoadTXD(assetData.rwData.txd))) or false
            rwFiles.dff = (assetData.rwData.dff and ((imports.isElement(assetData.rwData.dff) and assetData.rwData.dff) or imports.engineLoadDFF(assetData.rwData.dff))) or false
            rwFiles.col = (assetData.rwData.col and ((imports.isElement(assetData.rwData.col) and assetData.rwData.col) or imports.engineLoadCOL(assetData.rwData.col))) or false
            if rwFiles.dff then
                if rwFiles.txd then
                    imports.engineImportTXD(rwFiles.txd, rwModelID)
                end
                imports.engineReplaceModel(rwFiles.dff, rwModelID)
                if rwFiles.col then
                    imports.engineReplaceCOL(rwFiles.col, rwModelID)
                end
            else
                imports.engineFreeModel(rwModelID)
                for i, j in imports.pairs(rwFiles) do
                    if j and imports.isElement(j) then
                        imports.destroyElement(j)
                    end
                end
                rwFiles = nil
            end
            if rwFiles then
                self.modelID = rwModelID
                self.rwFiles = rwFiles
                loadState = true
            end
        end
    end
    callback(loadState)
    return loadState

end

if not localPlayer then

    function asset:buildPack(assetPack, callback)

        if not assetPack or not callback or (imports.type(callback) ~= "function") then return false end

        assetPack.datas = {
            manifestData = false,
            type = assetPack.reference.type,
            rwDatas = {}
        }
        assetPack.datas.manifestData = imports.fetchFileData((assetPack.reference.root)..(assetPack.reference.manifest)..".json")
        assetPack.datas.manifestData = (assetPack.datas.manifestData and imports.fromJSON(assetPack.datas.manifestData)) or false

        if assetPack.datas.manifestData then
            thread:create(function(cThread)
                local callbackReference = callback
                for i = 1, #assetPack.datas.manifestData, 1 do
                    local assetReference = assetPack.datas.manifestData[i]
                    local assetPath = (assetPack.reference.root)..assetReference.."/"
                    local assetData = imports.fetchFileData(assetPath..(assetPack.reference.asset)..".json")
                    assetData = (assetData and imports.fromJSON(assetData)) or false
                    if not assetData then
                        assetPack.datas.rwDatas[assetPath] = false
                    else
                        assetPack.datas.rwDatas[assetReference] = {
                            assetData = assetData,
                            rwData = {
                                txd = imports.fetchFileData(assetPath..assetPack.reference.asset..".txd"),
                                dff = imports.fetchFileData(assetPath..assetPack.reference.asset..".dff"),
                                col = imports.fetchFileData(assetPath..assetPack.reference.asset..".col")
                            }
                        }
                    end
                    imports.setTimer(function()
                        cThread:resume()
                    end, 1, 1)
                    thread.pause()
                end
                if callbackReference and imports.type(callbackReference) == "function" then
                    callbackReference(assetPack.datas)
                end
            end):resume()
            return true
        end
        if callbackReference and imports.type(callbackReference) == "function" then
            callbackReference(false)
        end
        return false

    end

end