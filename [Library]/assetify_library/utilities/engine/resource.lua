----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: engine: resource.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Resource Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {}


-------------------------
--[[ Class: Resource ]]--
-------------------------

local resource = class:create("resource")

function resource.public:create(...)
    local cResource = self:createInstance()
    if cResource and not cResource:load(...) then
        cResource:destroyInstance()
        return false
    end
    return cResource
end

function resource.public:destroy(...)
    if not resource.public:isInstance(self) then return false end
    return self:unload(...)
end

function resource.public:load()
    if not resource.public:isInstance(self) then return false end
    resource.public.buffer.resource[self] = true
    return true
end

function resource.public:unload()
    if not resource.public:isInstance(self) then return false end
    resource.public.buffer.resource[self] = nil
    self:destroyInstance()
    return true
end