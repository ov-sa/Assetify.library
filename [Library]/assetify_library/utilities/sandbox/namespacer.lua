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
    types = {},
    parents = {},
    instances = {}
}
class = {}
class.__index = class
local namespace = nil

function class:create(type, parent, nspace)
    if self ~= class then return false end
    if not type or (imports.type(type) ~= "string") or (parent and ((imports.type(parent) ~= "table") or buffer.instances[parent])) or buffer.types[type] then return false end
    nspace = (nspace and (imports.type(nspace) == "string") and nspace) or false
    if nspace and not namespace.private.types[nspace] then return false end
    parent = parent or {}
    parent.__index = parent
    if nspace then
        namespace.private.types[nspace].public[type] = parent
        namespace.private.classes[nspace] = parent
    else
        _G[type] = parent
    end
    buffer.types[type] = true
    buffer.parents[parent], buffer.instances[parent] = {}, {type = type, nspace = nspace, public = parent, private = imports.setmetatable({}, {__index = parent})}
    function parent:getType()
        if not self or not buffer.instances[self] then return false end
        return (buffer.parents[self] and buffer.instances[self].type) or (buffer.instances[(buffer.instances[self])].type) or false
    end
    function parent:isInstance(instance)
        if (self ~= parent) or not buffer.parents[parent] then return false end
        return (buffer.parents[parent][instance] and true) or false
    end
    function parent:createInstance()
        if (self ~= parent) or not buffer.parents[parent] then return false end
        local cInstance = imports.setmetatable({}, {__index = self})
        buffer.instances[cInstance], buffer.parents[self][cInstance] = parent, true
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
    local type, nspace = buffer.instances[instance].type, buffer.instances[instance].nspace
    if buffer.instances[instance].nspace then
        if namespace.private.types[nspace] and namespace.private.types[nspace][type] and (namespace.private.types[nspace][type] == buffer.instances[instance].public) then
            namespace.private.types[nspace][type] = nil
        end
    else
        if _G[type] and (_G[type] == buffer.instances[instance].public) then
            _G[type] = nil
        end
    end
    buffer.types[type] = nil
    buffer.instances[instance], buffer.parents[instance] = nil, nil
    instance = nil
    imports.collectgarbage()
    return true
end


--------------------------
--[[ Class: Namespace ]]--
--------------------------

namespace = class:create("namespace")
namespace.private.types = {}
namespace.private.classes = {}

function namespace.public:create(type, parent)
    if (self ~= namespace.public) and (self ~= namespace.private) or (parent and ((imports.type(parent) ~= "table") or buffer.instances[parent])) then return false end
    if not type or (imports.type(type) ~= "string") or namespace.private.types[type] then return false end
    local parent = parent or {}
    _G[type] = parent
    local cNamespace = self:createInstance()
    namespace.private.classes[type] = {}
    namespace.private.types[type] = {instance = cNamespace, public = parent, private = imports.setmetatable({}, {__index = parent})}
    return {public = namespace.private.types[type].public, private = namespace.private.types[type].private}
end

function namespace.public:destroy(type)
    if (self ~= namespace.public) and (self ~= namespace.private) then return false end
    if not type or (imports.type(type) ~= "string") or not namespace.private.types[type] then return false end
    if _G[type] and (_G[type] == namespace.private.types[type].public) then
        _G[type] = nil
    end
    for i, j in imports.pairs(namespace.private.classes[type]) do
        if i then
            class:destroy(i)
        end
    end
    namespace.private.types[type].instance:destroyInstance()
    namespace.private.types[type], namespace.private.classes[type] = nil, nil
    return true
end
