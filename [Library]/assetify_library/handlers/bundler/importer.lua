----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: bundler: importer.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Bundler: Importer Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local bundler = bundler:import()
local imports = {
    pairs = pairs
}


-------------------------
--[[ Bundler: Buffer ]]--
-------------------------

bundler.private:createBuffer("imports", false, [[
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
    ]]..bundler.private:createAPIs("assetify.__core", "library")..[[
    assetify.imports.setmetatable(assetify, {__index = assetify.__core})
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

bundler.private:createBuffer("scheduler", false, [[
    ]]..bundler.private:createBuffer("core")..[[
    ]]..bundler.private:createModule("network")..[[
    assetify.scheduler = {}
    ]]..bundler.private:createScheduler()..[[
]])

bundler.private:createBuffer("syncer", false, bundler.private:createAPIs("assetify.syncer", "syncer"))
bundler.private:createBuffer("world", false, bundler.private:createAPIs("assetify.world", "world"))
bundler.private:createBuffer("animation", false, bundler.private:createAPIs("assetify.animation", "animation"))
bundler.private:createBuffer("sound", false, bundler.private:createAPIs("assetify.sound", "sound"))
bundler.private:createBuffer("renderer", false, bundler.private:createAPIs("assetify.renderer", "renderer"))
bundler.private:createBuffer("attacher", false, bundler.private:createAPIs("assetify.attacher", "attacher"))


---------------------------
--[[ Bundler: Importer ]]--
---------------------------

function import(...)
    local cArgs = table.pack(...)
    if cArgs[1] == true then
        table.remove(cArgs, 1)
        local build, buffer, __buffer = {}, {}, {}
        local fetchAll = false
        if (table.length(cArgs) <= 0) then
            table.insert(build, "core")
        elseif cArgs[1] == "*" then
            fetchAll = true
            for i, j in imports.pairs(bundler.private.buffer) do
                table.insert(build, i)
            end
        else
            build = cArgs
        end
        for i = 1, table.length(build), 1 do
            local j = build[i]
            if (j ~= "imports") and bundler.private.buffer[j] and not __buffer[j] then
                __buffer[j] = true
                table.insert(buffer, {
                    index = bundler.private.buffer[j].module or j,
                    rw = bundler.private.buffer["imports"].rw..[[
                    ]]..bundler.private.buffer[j].rw
                })
            end
        end
        if table.length(buffer) <= 0 then return false end
        return buffer, fetchAll
    else
        cArgs = ((table.length(cArgs) > 0) and ", \""..table.concat(cArgs, "\", \"").."\"") or ""
        return [[
        local buffer, fetchAll = call(getResourceFromName("]]..syncer.libraryName..[["), "import", true]]..cArgs..[[)
        if not buffer then return false end
        local result = (not fetchAll and {}) or false
        for i = 1, #buffer, 1 do
            local j = buffer[i]
            assert(loadstring(j.rw))()
            if result then result[(#result + 1)] = assetify[(j.index)] end
        end
        if fetchAll then return assetify
        else return table.unpack(result) end
        ]]
    end
    return false
end