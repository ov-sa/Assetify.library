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
    utf8 = utf8,
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
        imports.table.remove(args, 1)
        local buildImports, genImports, __genImports = {}, {}, {}
        local isCompleteFetch = false
        if (#args <= 0) then
            imports.table.insert(buildImports, "core")
        elseif args[1] == "*" then
            isCompleteFetch = true
            for i, j in imports.pairs(bundler) do
                imports.table.insert(buildImports, i)
            end
        else
            buildImports = args
        end
        for i = 1, #buildImports, 1 do
            local j = buildImports[i]
            if (j ~= "imports") and bundler[j] and not __genImports[j] then
                __genImports[j] = true
                imports.table.insert(genImports, {index = bundler[j].module or j, rw = bundler["imports"]..bundler[j].rw})
            end
        end
        if #genImports <= 0 then return false end
        return genImports, isCompleteFetch
    else
        local args = {...}
        args = ((#args > 0) and ", \""..imports.table.concat(args, "\", \"").."\"") or ""
        return [[
        local genImports, isCompleteFetch = call(getResourceFromName("]]..syncer.libraryName..[["), "import", true]]..args..[[)
        if not genImports then return false end
        local genReturns = (not isCompleteFetch and {}) or false
        for i = 1, #genImports, 1 do
            local j = genImports[i]
            loadstring(j.rw)()
            if not isCompleteFetch then
                table.insert(genReturns, assetify[(j.index)])
            end
        end
        if isCompleteFetch then return assetify
        else return unpack(genReturns) end
        ]]
    end
end


-----------------
--[[ Bundler ]]--
-----------------

bundler["imports"] = imports.file.read("utilities/shared.lua")..[[
    if not assetify then
        assetify = {
            imports = {
                resourceName = "]]..syncer.libraryName..[[",
                type = type,
                pairs = pairs,
                call = call,
                pcall = pcall,
                assert = assert,
                outputDebugString = outputDebugString,
                loadstring = loadstring,
                getResourceFromName = getResourceFromName,
                table = table
            }
        }
    end
]]

bundler["core"] = {
    module = "__core",
    rw = [[
        if not assetify.__core then
            assetify.__core = {}
            if localPlayer then
                assetify.__core.getProgress = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getLibraryProgress", ...)
                end
            
                assetify.__core.getAssetID = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getAssetID", ...)
                end
            
                assetify.__core.isAssetLoaded = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "isAssetLoaded", ...)
                end
            
                assetify.__core.loadAsset = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "loadAsset", ...)
                end
            
                assetify.__core.unloadAsset = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "unloadAsset", ...)
                end
            
                assetify.__core.loadAnim = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "loadAnim", ...)
                end
            
                assetify.__core.unloadAnim = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "unloadAnim", ...)
                end
            
                assetify.__core.createShader = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "createShader", ...)
                end
            
                assetify.__core.clearWorld = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "clearWorld", ...)
                end
            
                assetify.__core.restoreWorld = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "restoreWorld", ...)
                end
            
                assetify.__core.clearModel = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "clearModel", ...)
                end
            
                assetify.__core.restoreModel = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "restoreModel", ...)
                end
            
                assetify.__core.playSound = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "playSoundAsset", ...)
                end
            
                assetify.__core.playSound3D = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "playSoundAsset3D", ...)
                end
            end
            
            assetify.__core.isLoaded = function()
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "isLibraryLoaded")
            end
            
            assetify.__core.isModuleLoaded = function()
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "isModuleLoaded")
            end
            
            assetify.__core.getAssets = function(...)
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getLibraryAssets", ...)
            end
            
            assetify.__core.getAsset = function(...)
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getAssetData", ...)
            end
            
            assetify.__core.getAssetDep = function(...)
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getAssetDep", ...)
            end
            
            assetify.__core.loadModule = function(assetName, moduleTypes)
                local cAsset = assetify.getAsset("module", assetName)
                if not cAsset or not moduleTypes or (#moduleTypes <= 0) then return false end
                if not cAsset.manifestData.assetDeps or not cAsset.manifestData.assetDeps.script then return false end
                for i = 1, #moduleTypes, 1 do
                    local j = moduleTypes[i]
                    if cAsset.manifestData.assetDeps.script[j] then
                        for k = 1, #cAsset.manifestData.assetDeps.script[j], 1 do
                            local rwData = assetify.getAssetDep("module", assetName, "script", j, k)
                            local status, error = assetify.imports.pcall(assetify.imports.loadstring(rwData))
                            if not status then
                                assetify.imports.outputDebugString("[Module: "..assetName.."] | Importing Failed: "..cAsset.manifestData.assetDeps.script[j][k].." ("..j..")")
                                assetify.imports.assert(assetify.imports.loadstring(rwData))
                                assetify.imports.outputDebugString(error)
                            end
                        end
                    end
                end
                return true
            end
            
            assetify.__core.setElementAsset = function(...)
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setElementAsset", ...)
            end
            
            assetify.__core.getElementAssetInfo = function(...)
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getElementAssetInfo", ...)
            end
            
            assetify.__core.createDummy = function(...)
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "createAssetDummy", ...)
            end

            for i, j in assetify.imports.pairs(assetify.__core) do
                assetify[i] = j
            end
        end
    ]]
}

bundler["threader"] = {
    module = "thread",
    rw = [[
        if not assetify.thread then
            ]]..imports.utf8.gsub(imports.file.read("utilities/threader.lua"), "thread", "assetify.thread", true, "(", ".:)")..[[
        end
    ]]
}

bundler["networker"] = {
    module = "network",
    rw = [[
        if not assetify.network then
            ]]..bundler["threader"].rw..[[
            ]]..imports.utf8.gsub(imports.utf8.gsub(imports.file.read("utilities/networker.lua"), "thread", "assetify.thread", true, "(", ".:)"), "network", "assetify.network", true, "(", ".:)")..[[
        end
    ]]
}

bundler["scheduler"] = {
    rw = [[
        if not assetify.scheduler then
            ]]..bundler["threader"].rw..[[
            ]]..bundler["networker"].rw..[[
            assetify.scheduler = {
                buffer = {execOnLoad = {}, execOnModuleLoad = {}},
                execOnLoad = function(execFunc)
                    if not execFunc or (assetify.imports.type(execFunc) ~= "function") then return false end
                    local isLoaded = assetify.isLoaded()
                    if isLoaded then
                        execFunc()
                    else
                        local execWrapper = nil
                        execWrapper = function()
                            execFunc()
                            assetify.network:fetch("Assetify:onLoad"):off(execWrapper)
                        end
                        assetify.network:fetch("Assetify:onLoad", true):on(execWrapper)
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
                            assetify.network:fetch("Assetify:onModuleLoad"):off(execWrapper)
                        end
                        assetify.network:fetch("Assetify:onModuleLoad", true):on(execWrapper)
                    end
                    return true
                end,

                execScheduleOnLoad = function(execFunc)
                    if not execFunc or (assetify.imports.type(execFunc) ~= "function") then return false end
                    assetify.imports.table.insert(assetify.scheduler.buffer.execOnLoad, execFunc)
                    return true
                end,

                execScheduleOnModuleLoad = function(execFunc)
                    if not execFunc or (assetify.imports.type(execFunc) ~= "function") then return false end
                    assetify.imports.table.insert(assetify.scheduler.buffer.execOnModuleLoad, execFunc)
                    return true
                end,

                boot = function()
                    for i, j in assetify.imports.pairs(assetify.scheduler.buffer) do
                        if #j > 0 then
                            for k = 1, #j, 1 do
                                assetify.scheduler[i](j[k])
                            end
                            assetify.scheduler.buffer[i] = {}
                        end
                    end
                    return true
                end
            }
        end
    ]]
}

bundler["renderer"] = {
    rw = [[
        if not assetify.renderer then
            assetify.renderer = {}
            if localPlayer then
                assetify.renderer.isVirtualRendering = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "isRendererVirtualRendering", ...)
                end

                assetify.renderer.setVirtualRendering = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setRendererVirtualRendering", ...)
                end

                assetify.renderer.getVirtualSource = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getRendererVirtualSource", ...)
                end

                assetify.renderer.getVirtualRTs = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getRendererVirtualRTs", ...)
                end

                assetify.renderer.setTimeSync = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setRendererTimeSync", ...)
                end

                assetify.renderer.setServerTick = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setRendererServerTick", ...)
                end

                assetify.renderer.setMinuteDuration = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setRendererMinuteDuration", ...)
                end
            end
        end
    ]]
}

bundler["syncer"] = {
    rw = [[
        if not assetify.syncer then
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
        end
    ]]
}

bundler["attacher"] = {
    rw = [[
        if not assetify.attacher then
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
        end
    ]]
}

bundler["lights"] = {
    module = "light",
    rw = [[
        if not assetify.light then
            assetify.light = {
                planar = {}
            }
            if localPlayer then
                assetify.light.planar.create = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "createPlanarLight", ...)
                end

                assetify.light.planar.setResolution = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setPlanarLightResolution", ...)
                end

                assetify.light.planar.setTexture = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setPlanarLightTexture", ...)
                end

                assetify.light.planar.setColor = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setPlanarLightColor", ...)
                end
            end
        end
    ]]
}