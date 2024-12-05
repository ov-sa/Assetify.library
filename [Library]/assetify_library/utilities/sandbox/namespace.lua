----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: sandbox: namespace.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Namespace Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    setmetatable = setmetatable,
    collectgarbage = collectgarbage
}


----------------------
--[[ Class: Class ]]--
----------------------

class = {}
class.__index = class
local namespace = nil
local buffer = {
    global = {},
    parent = {},
    instance = {}
}

function class:create(name, parent, nspace)
    if self ~= class then return false end
    nspace = (nspace and (imports.type(nspace) == "string") and nspace) or false
    if not name or (imports.type(name) ~= "string") or (parent and ((imports.type(parent) ~= "table") or buffer.instance[parent])) then return false end
    if (not nspace and buffer.global[name]) or (nspace and (not namespace.private.buffer[nspace] or namespace.private.buffer[nspace].global[name])) then return false end
    parent = parent or {}
    parent.__index = parent
    if nspace then
        namespace.private.buffer[nspace].global[name] = parent
        namespace.private.buffer[nspace].public[name] = parent
    else
        buffer.global[name] = true
        _G[name] = parent
    end
    buffer.parent[parent], buffer.instance[parent] = {}, {
        name = name,
        nspace = nspace,
        public = parent,
        private = imports.setmetatable({}, {__index = parent})
    }
    function parent:getName()
        if not self or not buffer.instance[self] then return false end
        return (buffer.parent[self] and buffer.instance[self].name) or (buffer.instance[(buffer.instance[self])].name) or false
    end
    function parent:isInstance(instance)
        if (self ~= parent) or not buffer.parent[parent] then return false end
        return (buffer.parent[parent][instance] and true) or false
    end
    function parent:createInstance()
        if (self ~= parent) or not buffer.parent[parent] then return false end
        local cInstance = imports.setmetatable({}, {__index = self})
        buffer.instance[cInstance], buffer.parent[parent][cInstance] = parent, true
        function cInstance:destroyInstance()
            if (self ~= cInstance) or not buffer.instance[self] then return false end
            buffer.instance[self], buffer.parent[parent][self] = nil, nil
            self = nil
            imports.collectgarbage("collect")
            return true
        end
        return cInstance
    end
    return {public = buffer.instance[parent].public, private = buffer.instance[parent].private}
end

function class:destroy(instance)
    if self ~= class then return false end
    if not instance or (imports.type(instance) ~= "table") or not buffer.parent[instance] then return false end
    for i, j in imports.pairs(buffer.parent[instance]) do
        if i then
            i:destroyInstance()
        end
    end
    local name, nspace = buffer.instance[instance].name, buffer.instance[instance].nspace
    if nspace then
        namespace.private.buffer[nspace].global[name] = nil
        if namespace.private.buffer[nspace] and namespace.private.buffer[nspace].public[name] and (namespace.private.buffer[nspace].public[name] == buffer.instance[instance].public) then
            namespace.private.buffer[nspace].public[name] = nil
        end
    else
        buffer.global[name] = nil
        if _G[name] and (_G[name] == buffer.instance[instance].public) then
            _G[name] = nil
        end
    end
    buffer.parent[instance], buffer.instance[instance] = nil, nil
    instance = nil
    imports.collectgarbage("collect")
    return true
end


--------------------------
--[[ Class: Namespace ]]--
--------------------------

namespace = class:create("namespace")
namespace.private.buffer = {}

function namespace.public:create(name, parent)
    if ((self ~= namespace.public) and (self ~= namespace.private)) or (parent and ((imports.type(parent) ~= "table") or buffer.instance[parent])) then return false end
    if not name or (imports.type(name) ~= "string") or namespace.private.buffer[name] then return false end
    parent = parent or {}
    _G[name] = parent
    local cNamespace = self:createInstance()
    namespace.private.buffer[name] = {
        instance = cNamespace,
        global = {},
        public = parent,
        private = imports.setmetatable({}, {__index = parent})
    }
    return {public = namespace.private.buffer[name].public, private = namespace.private.buffer[name].private}
end

function namespace.public:destroy(name)
    if (self ~= namespace.public) and (self ~= namespace.private) then return false end
    if not name or (imports.type(name) ~= "string") or not namespace.private.buffer[name] then return false end
    if _G[name] and (_G[name] == namespace.private.buffer[name].public) then
        _G[name] = nil
    end
    for i, j in imports.pairs(namespace.private.buffer[name].global) do
        if j then
            class:destroy(j)
        end
    end
    namespace.private.buffer[name].instance:destroyInstance()
    namespace.private.buffer[name] = nil
    return true
end