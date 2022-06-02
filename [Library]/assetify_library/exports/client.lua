----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: exports: client.lua
     Author: vStudio
     Developer(s): Aviril, Tron
     DOC: 19/10/2021
     Desc: Client Sided Exports ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    tonumber = tonumber,
    isElement = isElement,
    engineImportTXD = engineImportTXD,
    engineReplaceModel = engineReplaceModel,
    engineRestoreModel = engineRestoreModel,
    triggerEvent = triggerEvent,
    math = math
}


-------------------------
--[[ Functions: APIs ]]--
-------------------------

function getLibraryProgress(assetType, assetName)
    local cDownloaded, cBandwidth = nil, nil
    if assetType and assetName then
        if availableAssetPacks[assetType] and availableAssetPacks[assetType].rwDatas[assetName] then
            cBandwidth = availableAssetPacks[assetType].rwDatas[assetName].assetSize.total
            cDownloaded = (syncer.scheduledAssets and syncer.scheduledAssets[assetType] and syncer.scheduledAssets[assetType][assetName] and syncer.scheduledAssets[assetType][assetName].assetSize) or cBandwidth
        end
    else
        cBandwidth = syncer.libraryBandwidth
        cDownloaded = syncer.__libraryBandwidth or 0
    end
    if cDownloaded and cBandwidth then
        cDownloaded = imports.math.min(cDownloaded, cBandwidth)
        return cDownloaded, cBandwidth, (cDownloaded/imports.math.max(1, cBandwidth))*100
    end
    return false
end

function getAssetID(...)
    return manager:getID(...)
end

function isAssetLoaded(...)
    return manager:isLoaded(...)
end

function loadAsset(assetType, assetName, ...)
    local state = manager:load(assetType, assetName, ...)
    if state then
        imports.triggerEvent("onAssetLoad", localPlayer, assetType, assetName)
    end
    return state
end

function unloadAsset(assetType, assetName, ...)
    local state = manager:unload(assetType, assetName, ...)
    if state then
        imports.triggerEvent("onAssetUnLoad", localPlayer, assetType, assetName)
    end
    return state
end

function loadAnim(element, ...)
    if not element or not imports.isElement(element) then return false end
    return manager:loadAnim(element, ...)
end

function unloadAnim(element, ...)
    if not element or not imports.isElement(element) then return false end
    return manager:unloadAnim(element, ...)
end

function createShader(...)
    local cShader = shader:create(...)
    return cShader
end

function clearModel(modelID)
    modelID = imports.tonumber(modelID)
    if modelID then
        imports.engineImportTXD(asset.rwAssets.txd, modelID)
        imports.engineReplaceModel(asset.rwAssets.dff, modelID, false)
        return true
    end
    return false
end

function restoreModel(modelID)
    modelID = imports.tonumber(modelID)
    if not modelID then return false end
    return imports.engineRestoreModel(modelID)
end

function playSoundAsset(...)
    return manager:playSound(...)
end

function playSoundAsset3D(...)
    return manager:playSound3D(...)
end

function createAssetDummy(...)
    local cDummy = dummy:create(...)
    return (cDummy and cDummy.cDummy) or false
end

function isRendererVirtualRendering()
    return renderer.cache.isVirtualRendering
end

function setRendererVirtualRendering(...)
    return renderer:setVirtualRendering(...)
end

function getRendererVirtualSource()
    return (renderer.cache.isVirtualRendering and renderer.cache.virtualSource) or false
end

function getRendererVirtualRTs()
    return (renderer.cache.isVirtualRendering and renderer.cache.virtualRTs) or false
end

function setRendererTimeSync(...)
    return renderer:setTimeSync(...)
end

function setRendererServerTick(...)
    return renderer:setServerTick(...)
end

function setRendererMinuteDuration(...)
    return renderer:setMinuteDuration(...)
end

function createPlanarLight(...)
    local cLight = light.planar:create(...)
    return (cLight and cLight.cLight) or false
end

function setPlanarLightTexture(cLight, ...)
    if not light.planar.buffer[cLight] then return false end
    return light.planar.buffer[cLight]:setTexture(...)
end

function setPlanarLightColor(cLight, ...)
    if not light.planar.buffer[cLight] then return false end
    return light.planar.buffer[cLight]:setColor(...)
end