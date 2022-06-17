----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: exports: client.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Client Sided Exports ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    tonumber = tonumber,
    isElement = isElement,
    destroyElement = destroyElement,
    engineImportTXD = engineImportTXD,
    engineReplaceModel = engineReplaceModel,
    engineRestoreModel = engineRestoreModel,
    removeWorldModel = removeWorldModel,
    restoreAllWorldModels = restoreAllWorldModels,
    createWater = createWater,
    setOcclusionsEnabled = setOcclusionsEnabled,
    setWorldSpecialPropertyEnabled = setWorldSpecialPropertyEnabled,
    math = math
}


-------------------------
--[[ Functions: APIs ]]--
-------------------------

function getLibraryProgress(assetType, assetName)
    local cDownloaded, cBandwidth = nil, nil
    if assetType and assetName then
        if settings.assetPacks[assetType] and settings.assetPacks[assetType].rwDatas[assetName] then
            cBandwidth = settings.assetPacks[assetType].rwDatas[assetName].assetSize.total
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
        network:emit("Assetify:onAssetLoad", false, assetType, assetName)
    end
    return state
end

function unloadAsset(assetType, assetName, ...)
    local state = manager:unload(assetType, assetName, ...)
    if state then
        network:emit("Assetify:onAssetUnload", false, assetType, assetName)
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

function clearWorld()
    for i = 550, 19999, 1 do
        imports.removeWorldModel(i, 100000, 0, 0, 0)
    end
    if settings.GTA.waterLevel then
        streamer.waterBuffer = imports.createWater(-3000, -3000, 0, 3000, -3000, 0, -3000, 3000, 0, 3000, 3000, 0, false)
    end
    imports.setOcclusionsEnabled(false)
    imports.setWorldSpecialPropertyEnabled("randomfoliage", false)
    return true
end

function restoreWorld()
    if streamer.waterBuffer and imports.isElement(streamer.waterBuffer) then
        imports.destroyElement(streamer.waterBuffer)
    end
    streamer.waterBuffer = nil
    imports.restoreAllWorldModels()
    imports.setOcclusionsEnabled(true)
    imports.setWorldSpecialPropertyEnabled("randomfoliage", true)
    return true
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

function setPlanarLightResolution(cLight, ...)
    if not light.planar.buffer[cLight] then return false end
    return light.planar.buffer[cLight]:setResolution(...)
end

function setPlanarLightTexture(cLight, ...)
    if not light.planar.buffer[cLight] then return false end
    return light.planar.buffer[cLight]:setTexture(...)
end

function setPlanarLightColor(cLight, ...)
    if not light.planar.buffer[cLight] then return false end
    return light.planar.buffer[cLight]:setColor(...)
end