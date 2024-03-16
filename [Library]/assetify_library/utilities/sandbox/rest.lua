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
    imports.fetchRemote(route, {queueName = "assetify_library", connectionAttempts = 1, connectTimeout = timeout, method = "GET"}, function(result, status)
        if status.success then cPromise.resolve(result)
        else cPromise.reject(false, status.statusCode) end
    end)
    return cPromise
end

function rest.public:post(route, data, timeout)
    if (self ~= rest.public) or not data then return false end
    if not route or (imports.type(route) ~= "string") then return false end
    timeout = math.max(imports.tonumber(timeout) or 10000, 1)
    local cPromise = thread:createPromise()
    imports.fetchRemote(route, {queueName = "assetify_library", connectionAttempts = 1, connectTimeout = timeout, method = "POST", formFields = data}, function(result, status)
        if status.success then cPromise.resolve(result)
        else cPromise.reject(false, status.statusCode) end
    end)
    return cPromise
end