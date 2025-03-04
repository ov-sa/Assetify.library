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
            {index = "assetify.__core.isBooted", api = {"library", "isBooted"}},
            {index = "assetify.__core.isLoaded", api = {"library", "isLoaded"}},
            {index = "assetify.__core.isModuleLoaded", api = {"library", "isModuleLoaded"}},
            {index = "assetify.__core.getSerial", api = {"library", "fetchSerial"}},
            {index = "assetify.__core.getVersion", api = {"library", "fetchVersion"}},
            {index = "assetify.__core.getWebserver", api = {"library", "fetchWebserver"}},
            {index = "assetify.__core.getAssets", api = {"library", "fetchAssets"}},
            {index = "assetify.__core.getAsset", api = {"library", "getAssetData"}},
            {index = "assetify.__core.getAssetDep", api = {"library", "getAssetDep"}},
            {index = "assetify.__core.setElementAsset", api = {"library", "setElementAsset"}},
            {index = "assetify.__core.getElementAsset", api = {"library", "getElementAsset"}},
            {index = "assetify.__core.createDummy", api = {"library", "createAssetDummy"}}
        },
        client = {
            {index = "assetify.__core.getDownloadProgress", api = {"library", "getDownloadProgress"}},
            {index = "assetify.__core.isAssetLoaded", api = {"library", "isAssetLoaded"}},
            {index = "assetify.__core.getAssetID", api = {"library", "getAssetID"}},
            {index = "assetify.__core.loadAsset", api = {"library", "loadAsset"}},
            {index = "assetify.__core.unloadAsset", api = {"library", "unloadAsset"}},
            {index = "assetify.__core.loadAnim", api = {"animation", "loadAnim"}},
            {index = "assetify.__core.unloadAnim", api = {"animation", "unloadAnim"}},
            {index = "assetify.__core.createShader", api = {"library", "createShader"}},
            {index = "assetify.__core.clearWorld", api = {"world", "clearWorld"}},
            {index = "assetify.__core.restoreWorld", api = {"world", "restoreWorld"}},
            {index = "assetify.__core.setOcclusions", api = {"world", "setOcclusions"}},
            {index = "assetify.__core.clearModel", api = {"world", "clearModel"}},
            {index = "assetify.__core.restoreModel", api = {"world", "restoreModel"}},
            {index = "assetify.__core.playSound", api = {"sound", "playSound"}},
            {index = "assetify.__core.playSound3D", api = {"sound", "playSound3D"}}
        },
        server = {}
    })..[[
    assetify.__core.loadModule = function(assetName, moduleTypes)
        local cAsset = assetify.getAsset("module", assetName)
        if not cAsset or not moduleTypes or (table.length(moduleTypes) <= 0) then return false end
        if not cAsset.manifest.assetDeps or not cAsset.manifest.assetDeps.script then return false end
        for i = 1, table.length(moduleTypes), 1 do
            local j = moduleTypes[i]
            if cAsset.manifest.assetDeps.script[j] then
                for k = 1, table.length(cAsset.manifest.assetDeps.script[j]), 1 do
                    local rwData = assetify.getAssetDep("module", assetName, "script", j, k)
                    local status, error = assetify.imports.pcall(assetify.imports.loadstring(rwData))
                    if not status then
                        assetify.imports.outputDebugString("Module - "..assetName..": Importing Failed ━│  "..cAsset.manifest.assetDeps.script[j][k].." ("..j..")")
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
            {index = "assetify.renderer.isVirtualRendering", api = {"library", "isRendererVirtualRendering"}},
            {index = "assetify.renderer.setVirtualRendering", api = {"library", "setRendererVirtualRendering"}},
            {index = "assetify.renderer.getVirtualSource", api = {"library", "getRendererVirtualSource"}},
            {index = "assetify.renderer.getVirtualRTs", api = {"library", "getRendererVirtualRTs"}},
            {index = "assetify.renderer.isTimeSynced", api = {"library", "isRendererTimeSynced"}},
            {index = "assetify.renderer.setTimeSync", api = {"library", "setRendererTimeSync"}},
            {index = "assetify.renderer.setServerTick", api = {"library", "setRendererServerTick"}},
            {index = "assetify.renderer.setMinuteDuration", api = {"library", "setRendererMinuteDuration"}},
            {index = "assetify.renderer.getAntiAliasing", api = {"library", "getRendererAntiAliasing"}},
            {index = "assetify.renderer.setAntiAliasing", api = {"library", "setRendererAntiAliasing"}},
            {index = "assetify.renderer.isEmissiveMode", api = {"library", "isRendererEmissiveMode"}},
            {index = "assetify.renderer.setEmissiveMode", api = {"library", "setRendererEmissiveMode"}},
            {index = "assetify.renderer.isDynamicSky", api = {"library", "isRendererDynamicSky"}},
            {index = "assetify.renderer.setDynamicSky", api = {"library", "setRendererDynamicSky"}},
            {index = "assetify.renderer.isDynamicPrelights", api = {"library", "isRendererDynamicPrelights"}},
            {index = "assetify.renderer.setDynamicPrelights", api = {"library", "setRendererDynamicPrelights"}},
            {index = "assetify.renderer.getDynamicSunColor", api = {"library", "getRendererDynamicSunColor"}},
            {index = "assetify.renderer.setDynamicSunColor", api = {"library", "setRendererDynamicSunColor"}},
            {index = "assetify.renderer.isDynamicStars", api = {"library", "isRendererDynamicStars"}},
            {index = "assetify.renderer.setDynamicStars", api = {"library", "setRendererDynamicStars"}},
            {index = "assetify.renderer.getDynamicCloudDensity", api = {"library", "getRendererDynamicCloudDensity"}},
            {index = "assetify.renderer.setDynamicCloudDensity", api = {"library", "setRendererDynamicCloudDensity"}},
            {index = "assetify.renderer.getDynamicCloudScale", api = {"library", "getRendererDynamicCloudScale"}},
            {index = "assetify.renderer.setDynamicCloudScale", api = {"library", "setRendererDynamicCloudScale"}},
            {index = "assetify.renderer.getDynamicCloudColor", api = {"library", "getRendererDynamicCloudColor"}},
            {index = "assetify.renderer.setDynamicCloudColor", api = {"library", "setRendererDynamicCloudColor"}},
            {index = "assetify.renderer.getTimeCycle", api = {"library", "getRendererTimeCycle"}},
            {index = "assetify.renderer.setTimeCycle", api = {"library", "setRendererTimeCycle"}}
        }
    })..[[
]])

bundler.private:createBuffer("syncer", _, [[
    assetify.syncer = {}
    ]]..bundler.private:createAPIs({
        shared = {
            {index = "assetify.syncer.setGlobalData", api = {"library", "setGlobalData"}},
            {index = "assetify.syncer.getGlobalData", api = {"library", "getGlobalData"}},
            {index = "assetify.syncer.getAllGlobalDatas", api = {"library", "getAllGlobalDatas"}},
            {index = "assetify.syncer.setEntityData", api = {"library", "setEntityData"}},
            {index = "assetify.syncer.getEntityData", api = {"library", "getEntityData"}},
            {index = "assetify.syncer.getAllEntityDatas", api = {"library", "getAllEntityDatas"}}
        }
    })..[[
]])

bundler.private:createBuffer("attacher", _, [[
    assetify.attacher = {}
    ]]..bundler.private:createAPIs({
        shared = {
            {index = "assetify.attacher.setAttachment", api = {"library", "setAttachment"}},
            {index = "assetify.attacher.setDetachment", api = {"library", "setDetachment"}},
            {index = "assetify.attacher.clearAttachment", api = {"library", "clearAttachment"}},
            {index = "assetify.attacher.setBoneAttach", api = {"library", "setBoneAttachment"}},
            {index = "assetify.attacher.setBoneDetach", api = {"library", "setBoneDetachment"}},
            {index = "assetify.attacher.setBoneRefresh", api = {"library", "setBoneRefreshment"}},
            {index = "assetify.attacher.clearBoneAttach", api = {"library", "clearBoneAttachment"}}
        }
    })..[[
]])