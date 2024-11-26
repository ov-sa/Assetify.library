----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: sandbox: namespacer.lua
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

local buffer = {
    global = {},
    parents = {},
    instances = {}
}
class = {}
class.__index = class
local namespace = nil

function class:create(name, parent, nspace)
    if self ~= class then return false end
    nspace = (nspace and (imports.type(nspace) == "string") and nspace) or false
    if not name or (imports.type(name) ~= "string") or (parent and ((imports.type(parent) ~= "table") or buffer.instances[parent])) then return false end
    if (nspace and (not namespace.private.buffer[nspace] or namespace.private.buffer[nspace].class[name])) or buffer.global[name] then return false end
    parent = parent or {}
    parent.__index = parent
    if nspace then
        namespace.private.buffer[nspace].public[name] = parent
        namespace.private.buffer[nspace].class[name] = parent
    else
        buffer.global[name] = true
        _G[name] = parent
    end
    buffer.parents[parent], buffer.instances[parent] = {}, {
        name = name,
        nspace = nspace,
        public = parent,
        private = imports.setmetatable({}, {__index = parent})
    }
    function parent:getName()
        if not self or not buffer.instances[self] then return false end
        return (buffer.parents[self] and buffer.instances[self].name) or (buffer.instances[(buffer.instances[self])].name) or false
    end
    function parent:isInstance(instance)
        if (self ~= parent) or not buffer.parents[parent] then return false end
        return (buffer.parents[parent][instance] and true) or false
    end
    function parent:createInstance()
        if (self ~= parent) or not buffer.parents[parent] then return false end
        local cInstance = imports.setmetatable({}, {__index = self})
        buffer.instances[cInstance], buffer.parents[parent][cInstance] = parent, true
        function cInstance:destroyInstance()
            if (self ~= cInstance) or not buffer.instances[self] then return false end
            buffer.instances[self], buffer.parents[parent][self] = nil, nil
            self = nil
            imports.collectgarbage()
            return true
        end
        return cInstance
    end
    return {public = buffer.instances[parent].public, private = buffer.instances[parent].private}
end

function class:destroy(instance)
    if self ~= class then return false end
    if not instance or (imports.type(instance) ~= "table") or not buffer.parents[instance] then return false end
    for i, j in imports.pairs(buffer.parents[instance]) do
        if i then
            i:destroyInstance()
        end
    end
    local name, nspace = buffer.instances[instance].name, buffer.instances[instance].nspace
    if buffer.instances[instance].nspace then
        if namespace.private.buffer[nspace] and namespace.private.buffer[nspace][name] and (namespace.private.buffer[nspace][name] == buffer.instances[instance].public) then
            namespace.private.buffer[nspace][name] = nil
        end
    else
        if _G[name] and (_G[name] == buffer.instances[instance].public) then
            _G[name] = nil
        end
    end
    buffer.global[name] = nil
    buffer.instances[instance], buffer.parents[instance] = nil, nil
    instance = nil
    imports.collectgarbage()
    return true
end


--------------------------
--[[ Class: Namespace ]]--
--------------------------

namespace = class:create("namespace")
namespace.private.buffer = {}

function namespace.public:create(name, parent)
    if ((self ~= namespace.public) and (self ~= namespace.private)) or (parent and ((imports.type(parent) ~= "table") or buffer.instances[parent])) then return false end
    if not name or (imports.type(name) ~= "string") or namespace.private.buffer[name] then return false end
    parent = parent or {}
    _G[name] = parent
    local cNamespace = self:createInstance()
    namespace.private.buffer[name] = {
        instance = cNamespace,
        class = {},
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
    for i, j in imports.pairs(namespace.private.buffer[name].class) do
        if i then
            class:destroy(i, name)
        end
    end
    namespace.private.buffer[name].instance:destroyInstance()
    namespace.private.buffer[name] = nil
    return true
end