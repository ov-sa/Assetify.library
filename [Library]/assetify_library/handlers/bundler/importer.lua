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


---------------------------
--[[ Bundler: Handlers ]]--
---------------------------

function import(...)
    local cArgs = table.pack(...)
    if cArgs[1] == true then
        table.remove(cArgs, 1)
        local buildImports, cImports, __cImports = {}, {}, {}
        local isCompleteFetch = false
        if (#cArgs <= 0) then
            table.insert(buildImports, "core")
        elseif cArgs[1] == "*" then
            isCompleteFetch = true
            for i, j in imports.pairs(bundler.private.buffer) do
                table.insert(buildImports, i)
            end
        else
            buildImports = cArgs
        end
        for i = 1, #buildImports, 1 do
            local j = buildImports[i]
            if (j ~= "imports") and bundler.private.buffer[j] and not __cImports[j] then
                __cImports[j] = true
                table.insert(cImports, {
                    index = bundler.private.buffer[j].module or j,
                    rw = bundler.private.buffer["imports"].rw..[[
                    ]]..bundler.private.buffer[j].rw
                })
            end
        end
        if #cImports <= 0 then return false end
        return cImports, isCompleteFetch
    else
        cArgs = ((#cArgs > 0) and ", \""..table.concat(cArgs, "\", \"").."\"") or ""
        return [[
        local cImports, isCompleteFetch = call(getResourceFromName("]]..syncer.libraryName..[["), "import", true]]..cArgs..[[)
        if not cImports then return false end
        local cReturns = (not isCompleteFetch and {}) or false
        for i = 1, #cImports, 1 do
            local j = cImports[i]
            assert(loadstring(j.rw))()
            if cReturns then cReturns[(#cReturns + 1)] = assetify[(j.index)] end
        end
        if isCompleteFetch then return assetify
        else return table.unpack(cReturns) end
        ]]
    end
    return false
end