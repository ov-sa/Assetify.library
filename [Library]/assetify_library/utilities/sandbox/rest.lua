----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: sandbox: rest.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: REST Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    tonumber = tonumber,
    callRemote = callRemote,
    fetchRemote = fetchRemote
}


---------------------
--[[ Class: REST ]]--
---------------------

local rest = class:create("rest")

function rest.public:get(route, timeout)
    if self ~= rest.public then return false end
    if not route or (imports.type(route) ~= "string") then return false end
    timeout = math.max(imports.tonumber(timeout) or 10000, 1)
    local cPromise = thread:createPromise()
    imports.fetchRemote(route, {connectionAttempts = 1, connectTimeout = timeout}, function(result, status)
        if status.success then cPromise.resolve(result)
        else cPromise.reject(result, status.statusCode) end
    end)
    return cPromise
end

if localPlayer then

else
    function rest.public:post(route, data, timeout)
        if self ~= rest.public then return false end
        if not route or (imports.type(route) ~= "string") or not data or (imports.type(data) ~= "table") then return false end
        timeout = math.max(imports.tonumber(timeout) or 10000, 1)
        local cPromise = thread:createPromise()
        imports.callRemote(route, 1, timeout, function(result, status)
            if status.success then cPromise.resolve(result)
            else cPromise.reject(result, status.statusCode) end
        end)
        return cPromise
    end
end