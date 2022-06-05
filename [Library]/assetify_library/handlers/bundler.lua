----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: bundler.lua
     Author: vStudio
     Developer(s): Aviril, Tron
     DOC: 19/10/2021
     Desc: Bundler Handler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    table = table,
    file = file
}


-------------------
--[[ Variables ]]--
-------------------

local bundler = {}


-----------------------------------
--[[ Function: Fetches Imports ]]--
-----------------------------------

function fetchImports(recieveData)
    if not bundler.library then return false end
    if recieveData == true then
        return bundler.library
    else
        return [[
        local importList = call(getResourceFromName("]]..syncer.libraryName..[["), "fetchImports", true)
        for i = 1, #importList, 1 do
            loadstring(importList[i])()
        end
        ]]
    end
end

function fetchThreader()
    return bundler.thread or false
end

function fetchNetworker()
    return bundler.network or false
end


-----------------------------------
--[[ Function: Bundles Library ]]--
-----------------------------------

function onBundleLibrary()
    bundler.thread = imports.file.read("utilities/threader.lua")
    bundler.network = imports.file.read("utilities/networker.lua")
    local libraryModules = {
        library = imports.file.read("utilities/shared.lua")..[[
            assetify = {
                imports = {
                    resourceName = "]]..syncer.libraryName..[[",
                    type = type,
                    call = call,
                    pcall = pcall,
                    assert = assert,
                    print = print,
                    loadstring = loadstring,
                    getResourceFromName = getResourceFromName,
                    addEventHandler = addEventHandler,
                    removeEventHandler = removeEventHandler,
                    table = table
                }
            }

            assetify.execOnLoad = function(execFunc)
                if not execFunc or (assetify.imports.type(execFunc) ~= "function") then return false end
                local isLoaded = assetify.isLoaded()
                if isLoaded then
                    execFunc()
                else
                    local execWrapper = nil
                    execWrapper = function()
                        execFunc()
                        assetify.imports.removeEventHandler("onAssetifyLoad", root, execWrapper)
                    end
                    assetify.imports.addEventHandler("onAssetifyLoad", root, execWrapper)
                end
                return true
            end

            assetify.execOnModuleLoad = function(execFunc)
                if not execFunc or (assetify.imports.type(execFunc) ~= "function") then return false end
                local isModuleLoaded = assetify.isModuleLoaded()
                if isModuleLoaded then
                    execFunc()
                else
                    local execWrapper = nil
                    execWrapper = function()
                        execFunc()
                        assetify.imports.removeEventHandler("onAssetifyModuleLoad", root, execWrapper)
                    end
                    assetify.imports.addEventHandler("onAssetifyModuleLoad", root, execWrapper)
                end
                return true
            end

            assetify.scheduleExec = {
                buffer = {
                    onLoad = {}, onModuleLoad = {}
                },

                boot = function()
                    assetify.execOnLoad(function()
                        if #assetify.scheduleExec.buffer.onLoad > 0 then
                            for i = 1, #assetify.scheduleExec.buffer.onLoad, 1 do
                                assetify.execOnLoad(assetify.scheduleExec.buffer.onLoad[i])
                            end
                            assetify.scheduleExec.buffer.onLoad = {}
                        end
                        return true
                    end)
                    assetify.execOnModuleLoad(function()
                        if #assetify.scheduleExec.buffer.onModuleLoad > 0 then
                            for i = 1, #assetify.scheduleExec.buffer.onModuleLoad, 1 do
                                assetify.execOnModuleLoad(assetify.scheduleExec.buffer.onModuleLoad[i])
                            end
                            assetify.scheduleExec.buffer.onModuleLoad = {}
                        end
                        return true
                    end)
                    return true
                end,

                execOnLoad = function(execFunc)
                    if not execFunc or (assetify.imports.type(execFunc) ~= "function") then return false end
                    assetify.imports.table.insert(assetify.scheduleExec.buffer.onLoad, execFunc)
                    return true
                end,

                execOnModuleLoad = function(execFunc)
                    if not execFunc or (assetify.imports.type(execFunc) ~= "function") then return false end
                    assetify.imports.table.insert(assetify.scheduleExec.buffer.onModuleLoad, execFunc)
                    return true
                end
            }

            if localPlayer then
                assetify.renderer = {
                    isVirtualRendering = function(...)
                        return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "isRendererVirtualRendering", ...)
                    end,
    
                    setVirtualRendering = function(...)
                        return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setRendererVirtualRendering", ...)
                    end,

                    getVirtualSource = function(...)
                        return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getRendererVirtualSource", ...)
                    end,

                    getVirtualRTs = function(...)
                        return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getRendererVirtualRTs", ...)
                    end,

                    setTimeSync = function(...)
                        return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setRendererTimeSync", ...)
                    end,

                    setServerTick = function(...)
                        return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setRendererServerTick", ...)
                    end,

                    setMinuteDuration = function(...)
                        return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setRendererMinuteDuration", ...)
                    end
                }

                assetify.light = {
                    planar = {
                        create = function(...)
                            return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "createPlanarLight", ...)
                        end,

                        setTexture = function(...)
                            return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setPlanarLightTexture", ...)
                        end,

                        setColor = function(...)
                            return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setPlanarLightColor", ...)
                        end
                    }
                }

                assetify.getProgress = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getLibraryProgress", ...)
                end

                assetify.getAssetID = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getAssetID", ...)
                end

                assetify.isAssetLoaded = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "isAssetLoaded", ...)
                end

                assetify.loadAsset = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "loadAsset", ...)
                end

                assetify.unloadAsset = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "unloadAsset", ...)
                end

                assetify.loadAnim = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "loadAnim", ...)
                end

                assetify.unloadAnim = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "unloadAnim", ...)
                end

                assetify.createShader = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "createShader", ...)
                end

                assetify.clearModel = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "clearModel", ...)
                end

                assetify.restoreModel = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "restoreModel", ...)
                end

                assetify.playSound = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "playSoundAsset", ...)
                end

                assetify.playSound3D = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "playSoundAsset3D", ...)
                end

                assetify.createDummy = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "createAssetDummy", ...)
                end
            end

            assetify.isLoaded = function()
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "isLibraryLoaded")
            end

            assetify.isModuleLoaded = function()
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "isModuleLoaded")
            end

            assetify.getAssets = function(...)
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getLibraryAssets", ...)
            end

            assetify.getAsset = function(...)
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getAssetData", ...)
            end

            assetify.getAssetDep = function(...)
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getAssetDep", ...)
            end

            assetify.loadModule = function(assetName, moduleTypes)
                local cAsset = assetify.getAsset("module", assetName)
                if not cAsset or not moduleTypes or (#moduleTypes <= 0) then return false end
                if not cAsset.manifestData.assetDeps or not cAsset.manifestData.assetDeps.script then return false end
                for i = 1, #moduleTypes, 1 do
                    local j = moduleTypes[i]
                    if cAsset.manifestData.assetDeps.script[j] then
                        for k = 1, #cAsset.manifestData.assetDeps.script[j], 1 do
                            local rwData = assetify.getAssetDep("module", assetName, "script", j, k)
                            if not assetify.imports.pcall(assetify.imports.loadstring(rwData)) then
                                assetify.imports.print("[Module: "..assetName.."] | "..cAsset.manifestData.assetDeps.script[j][k].." ("..j..")")
                                assetify.imports.assert(assetify.imports.loadstring(rwData))
                            end
                        end
                    end
                end
                return true
            end

            assetify.setElementAsset = function(...)
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setElementAsset", ...)
            end

            assetify.getElementAssetInfo = function(...)
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getElementAssetInfo", ...)
            end

            assetify.setBoneAttach = function(...)
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setBoneAttachment", ...)
            end

            assetify.setBoneDetach = function(...)
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setBoneDetachment", ...)
            end

            assetify.setBoneRefresh = function(...)
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setBoneRefreshment", ...)
            end

            assetify.clearBoneAttach = function(...)
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "clearBoneAttachment", ...)
            end
        ]]
    }
    bundler.library = {}
    imports.table.insert(bundler.library, libraryModules.library)
end
onBundleLibrary()