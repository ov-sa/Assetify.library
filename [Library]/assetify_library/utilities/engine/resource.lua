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

local imports = {
    pairs = pairs,
    md5 = md5,
    collectgarbage = collectgarbage,
    outputDebugString = outputDebugString,
    getResourceName = getResourceName,
    addEventHandler = addEventHandler
}


-------------------------
--[[ Class: Resource ]]--
-------------------------

local syncer = syncer:import()
local resource = class:create("resource")
resource.private.buffer = {
    name = {},
    source = {}
}

function resource.public:import() return resource end
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

function resource.public:unload()
    if not resource.public:isInstance(self) then return false end
    resource.private.buffer.name[(self.resourceName)] = nil
    resource.private.buffer.source[(self.resource)] = nil
    self:destroyInstance()
    imports.collectgarbage()
    return true
end

if localPlayer then
    function resource.public:load(resourceSource)
        local resourceName = (resourceSource and imports.getResourceName(resourceSource)) or false
        if not resource.public:isInstance(self) or not resourceName or resource.private.buffer.name[resourceName] then return false end
        self.resource = resourceSource
        self.resourceName = resourceName
        network:emit("Assetify:onResourceLoad", false, self.resourceName, self.resource) 
        return true
    end
else
    function resource.public:load(resourceSource, resourceFiles)
        local resourceName = (resourceSource and imports.getResourceName(resourceSource)) or false
        resourceFiles = (resourceFiles and (imports.type(resourceFiles) == "table") and resourceFiles) or false
        if not resource.public:isInstance(self) or not resourceName or resource.private.buffer.name[resourceName] then return false end
        self.resource = resourceSource
        self.resourceName = resourceName
        self.isSilent = (isSilent and true) or false
        self.synced = {
            bandwidthData = {total = 0, file = {}},
        }
        self.unSynced = {
            fileData = {},
            fileHash = {}
        }
        if resourceFiles then
            for i = 1, #resourceFiles, 1 do
                local j = ":"..resourceName.."/"..resourceFiles[i]
                local builtFileData, builtFileSize = file:read(j)
                if builtFileData then
                    self.synced.bandwidthData.file[j] = builtFileSize
                    self.synced.bandwidthData.total = self.synced.bandwidthData.total + self.synced.bandwidthData.file[j]
                    self.unSynced.fileData[j] = builtFileData
                    self.unSynced.fileHash[j] = imports.md5(builtFileData)
                else
                    imports.outputDebugString("[Assetify] | Invalid File: "..j)
                end
            end
        end
        resource.private.buffer.name[(self.resourceName)] = self
        resource.private.buffer.source[(self.resource)] = self
        if not self.isSilent then
            thread:create(function(self)
                for i, j in imports.pairs(syncer.public.libraryClients.loaded) do
                    syncer.private:syncResource(i, resourceName)
                    thread:pause()
                end
            end):resume({executions = settings.downloader.syncRate, frames = 1})
        end
        network:emit("Assetify:onResourceLoad", false, self.resourceName, self.resource) 
        return true
    end
end


---------------------
--[[ API Syncers ]]--
---------------------

imports.addEventHandler((localPlayer and "onClientResourceStop") or "onResourceStop", root, function(resourceSource)
    if resourceSource == syncer.public.libraryResource then return false end
    local resourceName = imports.getResourceName(resourceSource)
    network:emit("Assetify:onResourceUnload", false, resourceName, resourceSource)
    network:emit("Assetify:onResourceFlush", false, resourceName, resourceSource)
end)
network:fetch("Assetify:onResourceFlush"):on(function(resourceName)
    if not resource.private.buffer.name[resourceName] then return false end
    resource.private.buffer.name[resourceName]:destroy()
end)