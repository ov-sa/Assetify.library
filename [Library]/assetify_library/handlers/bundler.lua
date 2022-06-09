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
--[[ Function: Imports Modules ]]--
-----------------------------------

function import(...)
    local args = {...}
    if args[1] == true then
        local genImports = {}
        local isCompleteFetch = false
        imports.table.insert(genImports, {rw = bundler.core})
        if args[2] and (args[2] == "*") then
            isCompleteFetch = true
            for i, j in imports.pairs(bundler) do
                if i ~= "core" then
                    local cImport = {index = i}
                    if imports.type(j) == "table" then
                        cImport.module = j.module or false
                        cImport.rw = j.rw
                    else
                        cImport.rw = j
                    end
                    imports.table.insert(genImports, cImport)
                end
            end
        else
            local __genImports = {}
            for i = 2, #args, 1 do
                local j = args[i]
                if (j ~= "core") and bundler[j] and not __genImports[j] then
                    local cImport = {index = j}
                    if imports.type(bundler[j]) == "table" then
                        cImport.module = bundler[j].module or false
                        cImport.rw = bundler[j].rw
                    else
                        cImport.rw = bundler[j]
                    end
                    __genImports[j] = true
                    imports.table.insert(genImports, cImport)
                end
            end
            __genImports = nil
        end
        return genImports, isCompleteFetch
    else
        local args = {...}
        args = ((#args > 0) and ", \""..imports.table.concat(args, "\", \"").."\"") or ""
        return [[
        local genImports, isCompleteFetch = call(getResourceFromName("]]..syncer.libraryName..[["), "import", true]]..args..[[)
        local genReturns = (not isCompleteFetch and {}) or false
        for i = 1, #genImports, 1 do
            local j = genImports[i]
            loadstring(j.rw)()
            if not isCompleteFetch and j.index then
                if not j.module then
                    table.insert(genReturns, assetify[(j.index)])
                else
                    table.insert(genReturns, _G[(j.module)])
                end
            end
        end
        if isCompleteFetch or (#genReturns <= 0) then return true
        else return unpack(genReturns) end
        ]]
    end
end


-----------------
--[[ Bundler ]]--
-----------------

bundler["core"] = [[
    if not assetify then
    ]]..imports.file.read("utilities/shared.lua")..[[
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

bundler["threader"] = {module = "thread", rw = imports.file.read("utilities/threader.lua")}
bundler["networker"] = {module = "network", rw = imports.file.read("utilities/networker.lua")}

bundler["scheduler"] = [[
    assetify.scheduler = {
        buffer = {onLoad = {}, onModuleLoad = {}},
        execOnLoad = function(execFunc)
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
        end,

        execOnModuleLoad = function(execFunc)
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
        end,

        execScheduleOnLoad = function(execFunc)
            if not execFunc or (assetify.imports.type(execFunc) ~= "function") then return false end
            assetify.imports.table.insert(assetify.scheduler.buffer.onLoad, execFunc)
            return true
        end,

        execScheduleOnModuleLoad = function(execFunc)
            if not execFunc or (assetify.imports.type(execFunc) ~= "function") then return false end
            assetify.imports.table.insert(assetify.scheduler.buffer.onModuleLoad, execFunc)
            return true
        end,

        boot = function()
            assetify.scheduler.execOnLoad(function()
                if #assetify.scheduler.buffer.onLoad > 0 then
                    for i = 1, #assetify.scheduler.buffer.onLoad, 1 do
                        assetify.scheduler.execOnLoad(assetify.scheduler.buffer.onLoad[i])
                    end
                    assetify.scheduler.buffer.onLoad = {}
                end
                return true
            end)
            assetify.scheduler.execOnModuleLoad(function()
                if #assetify.scheduler.buffer.onModuleLoad > 0 then
                    for i = 1, #assetify.scheduler.buffer.onModuleLoad, 1 do
                        assetify.scheduler.execOnModuleLoad(assetify.scheduler.buffer.onModuleLoad[i])
                    end
                    assetify.scheduler.buffer.onModuleLoad = {}
                end
                return true
            end)
            return true
        end
    }
]]

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

bundler["syncer"] = [[
    assetify.syncer = {
        setGlobalData = function(...)
            return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setGlobalData", ...)
        end,
    
        getGlobalData = function(...)
            return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getGlobalData", ...)
        end,
    
        setEntityData = function(...)
            return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setEntityData", ...)
        end,
    
        getEntityData = function(...)
            return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getEntityData", ...)
        end
    }
]]

bundler["attacher"] = [[
    assetify.attacher = {
        setBoneAttach = function(...)
            return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setBoneAttachment", ...)
        end,
    
        setBoneDetach = function(...)
            return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setBoneDetachment", ...)
        end,
    
        setBoneRefresh = function(...)
            return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setBoneRefreshment", ...)
        end,
    
        clearBoneAttach = function(...)
            return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "clearBoneAttachment", ...)
        end
    }
]]

bundler["lights"] = [[
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