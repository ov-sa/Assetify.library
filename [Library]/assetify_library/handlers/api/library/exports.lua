----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: api: library: exports.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Library APIs ]]--
----------------------------------------------------------------


-----------------
--[[ Exports ]]--
-----------------

manager:exportAPI("Library", {
    shared = {
        {name = "isLibraryBooted", API = "isBooted"},
        {name = "isLibraryLoaded", API = "isLoaded"},
        {name = "isModuleLoaded"},
        {name = "getLibraryAssets", API = "fetchAssets"},
        {name = "getAssetData"},
        {name = "getAssetDep"},
        {name = "setElementAsset"},
        {name = "getElementAssetInfo"},
        {name = "setGlobalData"},
        {name = "getGlobalData"},
        {name = "setEntityData"},
        {name = "getEntityData"},
        {name = "setAttachment"},
        {name = "setDetachment"},
        {name = "clearAttachment"},
        {name = "createAssetDummy"},
        {name = "setBoneAttachment"},
        {name = "syncBoneDetachment"},
        {name = "setBoneRefreshment"},
        {name = "clearBoneAttachment"}
    },
    client = {
        {name = "getDownloadProgress"},
        {name = "isAssetLoaded"},
        {name = "getAssetID"},
        {name = "loadAsset"},
        {name = "unloadAsset"},
        {name = "createShader"},
        {name = "isRendererVirtualRendering"},
        {name = "setRendererVirtualRendering"},
        {name = "getRendererVirtualSource"},
        {name = "getRendererVirtualRTs"},
        {name = "isRendererTimeSynced"},
        {name = "setRendererTimeSync"},
        {name = "setRendererServerTick"},
        {name = "setRendererMinuteDuration"},
        {name = "setRendererAntiAliasing"},
        {name = "getRendererAntiAliasing"},
        {name = "isRendererDynamicSky"},
        {name = "setRendererDynamicSky"},
        {name = "getRendererDynamicSunColor"},
        {name = "setRendererDynamicSunColor"},
        {name = "isRendererDynamicStars"},
        {name = "setRendererDynamicStars"},
        {name = "getRendererDynamicCloudDensity"},
        {name = "setRendererDynamicCloudDensity"},
        {name = "getRendererDynamicCloudScale"},
        {name = "setRendererDynamicCloudScale"},
        {name = "getRendererDynamicCloudColor"},
        {name = "setRendererDynamicCloudColor"},
        {name = "getRendererTimeCycle"},
        {name = "setRendererTimeCycle"},
        {name = "createPlanarLight"},
        {name = "setPlanarLightResolution"},
        {name = "setPlanarLightTexture"},
        {name = "setPlanarLightColor"}
    },
    server = {}
})