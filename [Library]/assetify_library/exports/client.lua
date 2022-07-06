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

function getAssetID(...) return manager:getID(...) end
function isAssetLoaded(...) return manager:isLoaded(...) end
function loadAsset(...) return manager:load(...) end
function unloadAsset(...) return manager:unload(...) end
function loadAnim(...) return manager.API.Anim:loadAnim(...) end
function unloadAnim(...) return manager.API.Anim:unloadAnim(...) end
function createShader(...) local cShader = shader:create(...) return cShader.cShader end

function clearWorld(...) return manager.API.World:clearWorld(...) end
function restoreWorld(...) return manager.API.World:restoreWorld(...) end
function clearModel(...) return manager.API.World:clearModel(...) end
function restoreModel(...) return manager.API.World:restoreModel(...) end
function playSoundAsset(...) return manager.API.Sound:playSound(...) end
function playSoundAsset3D(...) return manager.API.Sound:playSound3D(...) end

function isRendererVirtualRendering() return renderer.isVirtualRendering end
function setRendererVirtualRendering(...) return renderer:setVirtualRendering(...) end
function getRendererVirtualSource() return (renderer.isVirtualRendering and renderer.virtualSource) or false end
function getRendererVirtualRTs() return (renderer.isVirtualRendering and renderer.virtualRTs) or false end
function setRendererTimeSync(...) return renderer:setTimeSync(...) end
function setRendererServerTick(...) return renderer:setServerTick(...) end
function setRendererMinuteDuration(...) return renderer:setMinuteDuration(...) end
function createPlanarLight(...) local cLight = light.planar:create(...); return (cLight and cLight.cLight) or false end
function setPlanarLightResolution(cLight, ...) if not light.planar.buffer[cLight] then return false end; return light.planar.buffer[cLight]:setResolution(...) end
function setPlanarLightTexture(cLight, ...) if not light.planar.buffer[cLight] then return false end; return light.planar.buffer[cLight]:setTexture(...) end
function setPlanarLightColor(cLight, ...) if not light.planar.buffer[cLight] then return false end; return light.planar.buffer[cLight]:setColor(...) end