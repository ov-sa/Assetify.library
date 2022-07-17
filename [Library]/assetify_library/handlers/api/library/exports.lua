----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers. api: library: exports.lua
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
        {name = "isModuleLoaded", API = "isModuleLoaded"},
        {name = "getLibraryAssets", API = "fetchAssets"},
        {name = "getAssetData", API = "getAssetData"},
        {name = "getAssetDep", API = "getAssetDep"},
        {name = "setElementAsset", API = "setElementAsset"},
        {name = "getElementAssetInfo", API = "getElementAssetInfo"},
        {name = "setGlobalData", API = "setGlobalData"},
        {name = "getGlobalData", API = "getGlobalData"},
        {name = "setEntityData", API = "setEntityData"},
        {name = "getEntityData", API = "getEntityData"},
        {name = "setAttachment", API = "setAttachment"},
        {name = "setDetachment", API = "setDetachment"},
        {name = "clearAttachment", API = "clearAttachment"},
        {name = "createAssetDummy", API = "createAssetDummy"},
        {name = "setBoneAttachment", API = "setBoneAttachment"},
        {name = "syncBoneDetachment", API = "syncBoneDetachment"},
        {name = "setBoneRefreshment", API = "setBoneRefreshment"},
        {name = "clearBoneAttachment", API = "clearBoneAttachment"}
    },
    client = {
        {name = "getDownloadProgress", API = "getDownloadProgress"},
        {name = "isAssetLoaded", API = "isAssetLoaded"},
        {name = "getAssetID", API = "getAssetID"},
        {name = "loadAsset", API = "loadAsset"},
        {name = "unloadAsset", API = "unloadAsset"},
        {name = "createShader", API = "createShader"},
        {name = "isRendererVirtualRendering", API = "isRendererVirtualRendering"},
        {name = "setRendererVirtualRendering", API = "setRendererVirtualRendering"},
        {name = "getRendererVirtualSource", API = "getRendererVirtualSource"},
        {name = "getRendererVirtualRTs", API = "getRendererVirtualRTs"},
        {name = "setRendererTimeSync", API = "setRendererTimeSync"},
        {name = "setRendererServerTick", API = "setRendererServerTick"},
        {name = "setRendererMinuteDuration", API = "setRendererMinuteDuration"},
        {name = "createPlanarLight", API = "createPlanarLight"},
        {name = "setPlanarLightResolution", API = "setPlanarLightResolution"},
        {name = "setPlanarLightTexture", API = "setPlanarLightTexture"},
        {name = "setPlanarLightColor", API = "setPlanarLightColor"}
    },
    server = {}
})