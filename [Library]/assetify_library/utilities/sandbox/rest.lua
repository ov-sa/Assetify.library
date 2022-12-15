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
    fetchRemote = fetchRemote
}


---------------------
--[[ Class: REST ]]--
---------------------

local rest = class:create("rest")
rest.private.methods = {"post", "get"}
rest.private.__methods, rest.private.methods = rest.private.methods, {}
for i = 1, table.length(rest.private.__methods), 1 do
    local j = rest.private.__methods[i]
    rest.private.methods[j] = true
end
rest.private.__methods = nil

function rest.public:fetch(method, route, data)
    if self ~= rest.public then return false end
    if not method or not rest.private.methods[method] or not route or (imports.type(route) ~= "string") then return false end
    data = (data and (imports.type(data) == "table")) or false
    if (method == "post") and not data then return false end
    local cPromise = thread:createPromise()
    local options = {
        method = string.upper(method),
        headers = {
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json"
        },
        formFields = (method == "post" and data) or nil
    }
    imports.fetchRemote(route, options, function(result, status)
        if status.success then cPromise.resolve(result)
        else cPromise.reject(result, status.statusCode) end
    end)
    return cPromise
end