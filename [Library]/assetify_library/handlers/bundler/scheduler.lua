----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: bundler: scheduler.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Bundler: Scheduler Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local bundler = bundler:import()
local imports = {
    type = type,
    pairs = pairs
}

bundler.private.schedulers = {
    ["execOnBoot"] = {exec = "assetify.isBooted", network = "Assetify:onBoot"},
    ["execOnLoad"] = {exec = "assetify.isLoaded", network = "Assetify:onLoad"},
    ["execOnModuleLoad"] = {exec = "assetify.isModuleLoaded", network = "Assetify:onModuleLoad"}
}


---------------------------
--[[ Bundler: Handlers ]]--
---------------------------

function bundler.private:createScheduler()
    if imports.type(bundler.private.schedulers) == "table" then
        local header, body = [[assetify.scheduler.buffer = {pending = {]], ""
        local footer = [[
        local bootExec = function(type)
            if not assetify.scheduler.buffer.pending[type] then return false end
            if #assetify.scheduler.buffer.pending[type] > 0 then
                for i = 1, #assetify.scheduler.buffer.pending[type], 1 do
                    assetify.scheduler.buffer.pending[type][i]()
                end
                assetify.scheduler.buffer.pending[type] = {}
            end
            return true
        end
        local scheduleExec = function(type, exec)
            if not assetify.scheduler.buffer.schedule[type] then return false end
            if not exec or (assetify.imports.type(exec) ~= "function") then return false end
            assetify.imports.table.insert(assetify.scheduler.buffer.schedule[type], exec)
            return true
        end  
        for i, j in assetify.imports.pairs(assetify.scheduler.buffer.schedule) do
            assetify.scheduler[(assetify.imports.string.gsub(i, "exec", "execSchedule", 1))] = function(...) return scheduleExec(i, ...) end
        end
        ]]
        for i, j in imports.pairs(bundler.private.schedulers) do
            header = header..i..[[ = {}, ]]
            body = body..[[
            assetify.scheduler.]]..i..[[ = function(exec)
                if not exec or (assetify.imports.type(exec) ~= "function") then return false end
                if ]]..j.exec..[[() then exec()
                else assetify.imports.table.insert(assetify.scheduler.buffer.pending.]]..i..[[, exec) end
                return true
            end
            ]]
            footer = footer..[[
            assetify.network:fetch("]]..j.network..[[", true):on(function() bootExec("]]..i..[[") end, {subscriptionLimit = 1})
            ]]
        end
        header = header..[[}}
        assetify.scheduler.buffer.schedule = assetify.imports.table.clone(assetify.scheduler.buffer.pending, true)
        assetify.scheduler.boot = function()
            for i, j in assetify.imports.pairs(assetify.scheduler.buffer.schedule) do
                if #j > 0 then
                    for k = 1, #j, 1 do
                        assetify.scheduler[i](j[k])
                    end
                    assetify.scheduler.buffer.schedule[i] = {}
                end
            end
            return true
        end
        ]]
        bundler.private.schedulers = header..body..footer
    end
    return bundler.private.schedulers
end