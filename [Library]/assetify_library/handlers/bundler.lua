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
    type = type,
    pairs = pairs,
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

function fetchImports(...)
    local args = {...}
    if args[1] == true then
        local genImports = {}
        imports.table.insert(genImports, bundler.core)
        if (#args <= 1) or (args[2] == "*") then
            for i, j in imports.pairs(bundler) do
                if i ~= "core" then
                    imports.table.insert(genImports, j)
                end
            end
        else
            local __genImports = {}
            for i = 2, #args, 1 do
                local j = args[i]
                if (j ~= "core") and bundler[j] and not __genImports[j] then
                    __genImports[j] = true
                    imports.table.insert(genImports, j)
                end
            end
            __genImports = nil
        end
        return genImports
    else
        local args = {...}
        args = ((#args > 0) and ", "..imports.table.concat(args, ", ")) or ""
        return [[
        local genImports = call(getResourceFromName("]]..syncer.libraryName..[["), "fetchImports", true]]..args..[[)
        for i = 1, #genImports, 1 do
            loadstring(genImports[i])()
        end
        ]]
    end
end


-----------------
--[[ Bundler ]]--
-----------------

bundler["core"] = imports.file.read("utilities/shared.lua")..[[
    if not assetify then
        assetify = {
            imports = {
                resourceName = "]]..syncer.libraryName..[[",
                type = type,
                call = call,
                pcall = pcall,
                assert = assert,
                outputDebugString = outputDebugString,
                loadstring = loadstring,
                getResourceFromName = getResourceFromName,
                addEventHandler = addEventHandler,
                removeEventHandler = removeEventHandler,
                table = table
            }
        }

        if localPlayer then
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
                            assetify.imports.outputDebugString("[Module: "..assetName.."] | Importing Failed: "..cAsset.manifestData.assetDeps.script[j][k].." ("..j..")")
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
    end
]]

bundler["thread"] = imports.file.read("utilities/threader.lua")
bundler["network"] = imports.file.read("utilities/networker.lua")
bundler["renderer"] = [[
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
    end
]]

bundler["light"] = [[
    if localPlayer then
        assetify.light = {
            planar = {
                create = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "createPlanarLight", ...)
                end,

                setResolution = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setPlanarLightResolution", ...)
                end,

                setTexture = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setPlanarLightTexture", ...)
                end,

                setColor = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setPlanarLightColor", ...)
                end
            }
        }
    end
]]

bundler["scheduler"] = [[
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
]]

bundler["synced-data"] = [[
    assetify.setGlobalData = function(...)
        return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setGlobalData", ...)
    end

    assetify.getGlobalData = function(...)
        return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getGlobalData", ...)
    end

    assetify.setElementData = function(...)
        return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setElementData", ...)
    end

    assetify.getElementData = function(...)
        return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getElementData", ...)
    end
]]

bundler["bone-attachment"] = [[
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