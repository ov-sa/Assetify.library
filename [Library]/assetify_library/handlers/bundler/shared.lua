----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: bundler: shared.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Bundler: Shared Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local bundler = bundler:import()
local imports = {
    type = type,
    pairs = pairs
}


---------------------------
--[[ Bundler: Handlers ]]--
---------------------------

bundler.private:createBuffer("imports", _, [[
    if not assetify then
        assetify = {}
        ]]..bundler.private:createModule("namespace")..[[
        ]]..bundler.private:createUtils()..[[
        assetify.imports = {
            resourceName = "]]..syncer.libraryName..[[",
            type = type,
            pairs = pairs,
            call = call,
            pcall = pcall,
            assert = assert,
            setmetatable = setmetatable,
            outputDebugString = outputDebugString,
            loadstring = loadstring,
            getThisResource = getThisResource,
            getResourceFromName = getResourceFromName,
            table = table,
            string = string
        }
    end
]])

bundler.private:createBuffer("core", "__core", [[
    assetify.__core = {}
    assetify.imports.setmetatable(assetify, {__index = assetify.__core})
    ]]..bundler.private:createAPIs({
        shared = {
            {exportIndex = "assetify.__core.isBooted", exportName = "isLibraryBooted"},
            {exportIndex = "assetify.__core.isLoaded", exportName = "isLibraryLoaded"},
            {exportIndex = "assetify.__core.isModuleLoaded", exportName = "isModuleLoaded"},
            {exportIndex = "assetify.__core.isResourceLoaded", exportName = "isResourceLoaded"},
            {exportIndex = "assetify.__core.isResourceFlushed", exportName = "isResourceFlushed"},
            {exportIndex = "assetify.__core.isResourceUnloaded", exportName = "isResourceUnloaded"},
            {exportIndex = "assetify.__core.getAssets", exportName = "getLibraryAssets"},
            {exportIndex = "assetify.__core.getAsset", exportName = "getAssetData"},
            {exportIndex = "assetify.__core.getAssetDep", exportName = "getAssetDep"},
            {exportIndex = "assetify.__core.setElementAsset", exportName = "setElementAsset"},
            {exportIndex = "assetify.__core.getElementAsset", exportName = "getElementAsset"},
            {exportIndex = "assetify.__core.setElementAssetTone", exportName = "setElementAssetTone"},
            {exportIndex = "assetify.__core.getElementAssetTone", exportName = "getElementAssetTone"},
            {exportIndex = "assetify.__core.createDummy", exportName = "createAssetDummy"}
        },
        client = {
            {exportIndex = "assetify.__core.getDownloadProgress", exportName = "getDownloadProgress"},
            {exportIndex = "assetify.__core.getResourceDownloadProgress", exportName = "getResourceDownloadProgress"},
            {exportIndex = "assetify.__core.isAssetLoaded", exportName = "isAssetLoaded"},
            {exportIndex = "assetify.__core.getAssetID", exportName = "getAssetID"},
            {exportIndex = "assetify.__core.loadAsset", exportName = "loadAsset"},
            {exportIndex = "assetify.__core.unloadAsset", exportName = "unloadAsset"},
            {exportIndex = "assetify.__core.loadAnim", exportName = "loadAnim"},
            {exportIndex = "assetify.__core.unloadAnim", exportName = "unloadAnim"},
            {exportIndex = "assetify.__core.createShader", exportName = "createShader"},
            {exportIndex = "assetify.__core.clearWorld", exportName = "clearWorld"},
            {exportIndex = "assetify.__core.restoreWorld", exportName = "restoreWorld"},
            {exportIndex = "assetify.__core.toggleOcclusions", exportName = "toggleOcclusions"},
            {exportIndex = "assetify.__core.clearModel", exportName = "clearModel"},
            {exportIndex = "assetify.__core.restoreModel", exportName = "restoreModel"},
            {exportIndex = "assetify.__core.playSound", exportName = "playSoundAsset"},
            {exportIndex = "assetify.__core.playSound3D", exportName = "playSoundAsset3D"}
        },
        server = {
            {exportIndex = "assetify.__core.loadResource", exportName = "loadResource"}
        }
    })..[[
    assetify.__core.loadModule = function(assetName, moduleTypes)
        local cAsset = assetify.getAsset("module", assetName)
        if not cAsset or not moduleTypes or (table.length(moduleTypes) <= 0) then return false end
        if not cAsset.manifestData.assetDeps or not cAsset.manifestData.assetDeps.script then return false end
        for i = 1, table.length(moduleTypes), 1 do
            local j = moduleTypes[i]
            if cAsset.manifestData.assetDeps.script[j] then
                for k = 1, table.length(cAsset.manifestData.assetDeps.script[j]), 1 do
                    local rwData = assetify.getAssetDep("module", assetName, "script", j, k)
                    local status, error = assetify.imports.pcall(assetify.imports.loadstring(rwData))
                    if not status then
                        assetify.imports.outputDebugString("Module - "..assetName..": Importing Failed ━│  "..cAsset.manifestData.assetDeps.script[j][k].." ("..j..")")
                        assetify.imports.assert(assetify.imports.loadstring(rwData))
                        assetify.imports.outputDebugString(error)
                    end
                end
            end
        end
        return true
    end
]])

bundler.private:createBuffer("scheduler", _, [[
    ]]..bundler.private:createBuffer("core")..[[
    ]]..bundler.private:createModule("network")..[[
    assetify.scheduler = {}
    ]]..bundler.private:createScheduler()..[[
]])

bundler.private:createBuffer("renderer", _, [[
    assetify.renderer = {}
    ]]..bundler.private:createAPIs({
        client = {
            {exportIndex = "assetify.renderer.isVirtualRendering", exportName = "isRendererVirtualRendering"},
            {exportIndex = "assetify.renderer.setVirtualRendering", exportName = "setRendererVirtualRendering"},
            {exportIndex = "assetify.renderer.getVirtualSource", exportName = "getRendererVirtualSource"},
            {exportIndex = "assetify.renderer.getVirtualRTs", exportName = "getRendererVirtualRTs"},
            {exportIndex = "assetify.renderer.isTimeSynced", exportName = "isRendererTimeSynced"},
            {exportIndex = "assetify.renderer.setTimeSync", exportName = "setRendererTimeSync"},
            {exportIndex = "assetify.renderer.setServerTick", exportName = "setRendererServerTick"},
            {exportIndex = "assetify.renderer.setMinuteDuration", exportName = "setRendererMinuteDuration"},
            {exportIndex = "assetify.renderer.getAntiAliasing", exportName = "getRendererAntiAliasing"},
            {exportIndex = "assetify.renderer.setAntiAliasing", exportName = "setRendererAntiAliasing"},
            {exportIndex = "assetify.renderer.isEmissiveMode", exportName = "isRendererEmissiveMode"},
            {exportIndex = "assetify.renderer.setEmissiveMode", exportName = "setRendererEmissiveMode"},
            {exportIndex = "assetify.renderer.isDynamicSky", exportName = "isRendererDynamicSky"},
            {exportIndex = "assetify.renderer.setDynamicSky", exportName = "setRendererDynamicSky"},
            {exportIndex = "assetify.renderer.isDynamicPrelights", exportName = "isRendererDynamicPrelights"},
            {exportIndex = "assetify.renderer.setDynamicPrelights", exportName = "setRendererDynamicPrelights"},
            {exportIndex = "assetify.renderer.getDynamicSunColor", exportName = "getRendererDynamicSunColor"},
            {exportIndex = "assetify.renderer.setDynamicSunColor", exportName = "setRendererDynamicSunColor"},
            {exportIndex = "assetify.renderer.isDynamicStars", exportName = "isRendererDynamicStars"},
            {exportIndex = "assetify.renderer.setDynamicStars", exportName = "setRendererDynamicStars"},
            {exportIndex = "assetify.renderer.getDynamicCloudDensity", exportName = "getRendererDynamicCloudDensity"},
            {exportIndex = "assetify.renderer.setDynamicCloudDensity", exportName = "setRendererDynamicCloudDensity"},
            {exportIndex = "assetify.renderer.getDynamicCloudScale", exportName = "getRendererDynamicCloudScale"},
            {exportIndex = "assetify.renderer.setDynamicCloudScale", exportName = "setRendererDynamicCloudScale"},
            {exportIndex = "assetify.renderer.getDynamicCloudColor", exportName = "getRendererDynamicCloudColor"},
            {exportIndex = "assetify.renderer.setDynamicCloudColor", exportName = "setRendererDynamicCloudColor"},
            {exportIndex = "assetify.renderer.getTimeCycle", exportName = "getRendererTimeCycle"},
            {exportIndex = "assetify.renderer.setTimeCycle", exportName = "setRendererTimeCycle"}
        }
    })..[[
]])

bundler.private:createBuffer("syncer", _, [[
    assetify.syncer = {}
    ]]..bundler.private:createAPIs({
        shared = {
            {exportIndex = "assetify.syncer.setGlobalData", exportName = "setGlobalData"},
            {exportIndex = "assetify.syncer.getGlobalData", exportName = "getGlobalData"},
            {exportIndex = "assetify.syncer.getAllGlobalDatas", exportName = "getAllGlobalDatas"},
            {exportIndex = "assetify.syncer.setEntityData", exportName = "setEntityData"},
            {exportIndex = "assetify.syncer.getEntityData", exportName = "getEntityData"},
            {exportIndex = "assetify.syncer.getAllEntityDatas", exportName = "getAllEntityDatas"}
        }
    })..[[
]])

bundler.private:createBuffer("attacher", _, [[
    assetify.attacher = {}
    ]]..bundler.private:createAPIs({
        shared = {
            {exportIndex = "assetify.attacher.setAttachment", exportName = "setAttachment"},
            {exportIndex = "assetify.attacher.setDetachment", exportName = "setDetachment"},
            {exportIndex = "assetify.attacher.clearAttachment", exportName = "clearAttachment"},
            {exportIndex = "assetify.attacher.setBoneAttach", exportName = "setBoneAttachment"},
            {exportIndex = "assetify.attacher.setBoneDetach", exportName = "setBoneDetachment"},
            {exportIndex = "assetify.attacher.setBoneRefresh", exportName = "setBoneRefreshment"},
            {exportIndex = "assetify.attacher.clearBoneAttach", exportName = "clearBoneAttachment"}
        }
    })..[[
]])


bundler.private:createBuffer("lights", "light", [[
    assetify.light = {
        planar = {}
    }
    ]]..bundler.private:createAPIs({
        client = {
            {exportIndex = "assetify.light.planar.create", exportName = "createPlanarLight"},
            {exportIndex = "assetify.light.planar.setResolution", exportName = "setPlanarLightResolution"},
            {exportIndex = "assetify.light.planar.setTexture", exportName = "setPlanarLightTexture"},
            {exportIndex = "assetify.light.planar.setColor", exportName = "setPlanarLightColor"}
        }
    })..[[
]])