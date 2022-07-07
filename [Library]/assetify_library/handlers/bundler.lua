----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: bundler.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Bundler Handler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs
}


-----------------
--[[ Bundler ]]--
-----------------

local bundler = {
    rw = {},
    utils = {
        "utilities/sandbox/shared.lua",
        "utilities/sandbox/table.lua",
        "utilities/sandbox/math/index.lua",
        "utilities/sandbox/math/quat.lua",
        "utilities/sandbox/string.lua"
    },
    modules = {
        ["namespace"] = {module = "namespacer", namespace = "assetify.namespace", path = "utilities/sandbox/namespacer.lua", endpoints = {"namespace", "class"}},
        ["class"] = {namespace = "assetify.class"},
        ["file"] = {module = "filesystem", namespace = "assetify.file", path = "utilities/sandbox/filesystem.lua", endpoints = {"file"}},
        ["timer"] = {module = "timer", namespace = "assetify.timer", path = "utilities/sandbox/timer.lua", endpoints = {"timer"}},
        ["thread"] = {module = "threader", namespace = "assetify.thread", path = "utilities/sandbox/threader.lua", endpoints = {"thread"}},
        ["network"] = {module = "networker", namespace = "assetify.network", path = "utilities/sandbox/networker.lua", endpoints = {"network"}}
    }
}

local function parseUtil()
    local rw = ""
    for i = 1, #bundler.utils, 1 do
        local j = file:read(bundler.utils[i])
        for k, v in imports.pairs(bundler.modules) do
            j = string.gsub(j, k, v.namespace, _, true, "(", ".:)")
        end
        rw = rw..[[
        if true then
            ]]..j..[[
        end]]
    end
    return rw
end

local function parseModule(moduleName)
    if not moduleName then return false end
    local module = bundler.modules[moduleName]
    if not module then return false end
    local rw = file:read(module.path)
    for i, j in imports.pairs(bundler.modules) do
        local isBlacklisted = false
        for k = 1, #module.endpoints, 1 do
            local v = module.endpoints[k]
            if i == v then
                isBlacklisted = true
                break
            end
        end
        if not isBlacklisted then rw = string.gsub(rw, i, j.namespace, _, true, "(", ".:)") end
    end
    rw = ((moduleName == "namespace") and string.gsub(rw, "class = {}", "local class = {}")) or rw
    for i = 1, #module.endpoints, 1 do
        local j = module.endpoints[i]
        rw = rw..[[
            assetify["]]..j..[["] = ]]..j..((bundler.modules[j] and bundler.modules[j].module and ".public") or "")..[[
        ]]
        rw = rw..[[
            _G["]]..j..[["] = nil
        ]]
    end
    bundler.rw[(module.module)] = {
        module = moduleName,
        rw = [[
        if not assetify.]]..moduleName..[[ then
            ]]..rw..[[
        end
        ]]
    }
end
for i, j in imports.pairs(bundler.modules) do
    if j.module and j.endpoints then
        parseModule(i)
    end
end

function import(...)
    local cArgs = table:pack(...)
    if cArgs[1] == true then
        table:remove(cArgs, 1)
        local buildImports, genImports, __genImports = {}, {}, {}
        local isCompleteFetch = false
        if (#cArgs <= 0) then
            table:insert(buildImports, "core")
        elseif cArgs[1] == "*" then
            isCompleteFetch = true
            for i, j in imports.pairs(bundler.rw) do
                table:insert(buildImports, i)
            end
        else
            buildImports = cArgs
        end
        for i = 1, #buildImports, 1 do
            local j = buildImports[i]
            if (j ~= "imports") and bundler.rw[j] and not __genImports[j] then
                __genImports[j] = true
                local module = bundler.rw[j].module or j
                table:insert(genImports, {
                    index = module,
                    rw = bundler.rw["imports"]..[[
                    ]]..bundler.rw[j].rw
                })
            end
        end
        if #genImports <= 0 then return false end
        return genImports, isCompleteFetch
    else
        local cArgs = table:pack(...)
        cArgs = ((#cArgs > 0) and ", \""..table:concat(cArgs, "\", \"").."\"") or ""
        return [[
        local genImports, isCompleteFetch = call(getResourceFromName("]]..syncer.libraryName..[["), "import", true]]..cArgs..[[)
        if not genImports then return false end
        local genReturns = (not isCompleteFetch and {}) or false
        for i = 1, #genImports, 1 do
            local j = genImports[i]
            assert(loadstring(j.rw))()
            if genReturns then genReturns[(#genReturns + 1)] = assetify[(j.index)] end
        end
        if isCompleteFetch then return assetify
        else return table.unpack(genReturns) end
        ]]
    end
end


--------------------
--[[ Bundler RW ]]--
--------------------

bundler.rw["imports"] = [[
    if not assetify then
        assetify = {}
        ]]..bundler.rw["namespacer"].rw..[[
        ]]..parseUtil()..[[
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
            getResourceFromName = getResourceFromName,
            table = table
        }
    end
]]

bundler.rw["core"] = {
    module = "__core",
    rw = [[
        assetify.__core = {}
        assetify.imports.setmetatable(assetify, {__index = assetify.__core})
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
        
        assetify.__core.isBooted = function()
            return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "isLibraryBooted")
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
    ]]
}

bundler.rw["scheduler"] = {
    rw = [[
        ]]..bundler.rw["networker"].rw..[[
        assetify.scheduler = {
            buffer = {execOnBoot = {}, execOnLoad = {}, execOnModuleLoad = {}},
            execOnBoot = function(execFunc)
                if not execFunc or (assetify.imports.type(execFunc) ~= "function") then return false end
                local isBooted = assetify.isBooted()
                if isBooted then execFunc()
                else assetify.network:fetch("Assetify:onBoot", true):on(execFunc, {subscriptionLimit = 1}) end
                return true
            end,

            execOnLoad = function(execFunc)
                if not execFunc or (assetify.imports.type(execFunc) ~= "function") then return false end
                local isLoaded = assetify.isLoaded()
                if isLoaded then execFunc()
                else assetify.network:fetch("Assetify:onLoad", true):on(execFunc, {subscriptionLimit = 1}) end
                return true
            end,

            execOnModuleLoad = function(execFunc)
                if not execFunc or (assetify.imports.type(execFunc) ~= "function") then return false end
                local isModuleLoaded = assetify.isModuleLoaded()
                if isModuleLoaded then execFunc()
                else assetify.network:fetch("Assetify:onModuleLoad", true):on(execFunc, {subscriptionLimit = 1}) end
                return true
            end,

            execScheduleOnBoot = function(execFunc)
                if not execFunc or (assetify.imports.type(execFunc) ~= "function") then return false end
                assetify.imports.table:insert(assetify.scheduler.buffer.execOnBoot, execOnBoot)
                return true
            end,

            execScheduleOnLoad = function(execFunc)
                if not execFunc or (assetify.imports.type(execFunc) ~= "function") then return false end
                assetify.imports.table:insert(assetify.scheduler.buffer.execOnLoad, execFunc)
                return true
            end,

            execScheduleOnModuleLoad = function(execFunc)
                if not execFunc or (assetify.imports.type(execFunc) ~= "function") then return false end
                assetify.imports.table:insert(assetify.scheduler.buffer.execOnModuleLoad, execFunc)
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
    ]]
}

bundler.rw["renderer"] = {
    rw = [[
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
    ]]
}

bundler.rw["syncer"] = {
    rw = [[
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
}

bundler.rw["attacher"] = {
    rw = [[
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
}

bundler.rw["lights"] = {
    module = "light",
    rw = [[
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
    ]]
}