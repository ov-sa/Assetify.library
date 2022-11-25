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
    type = type,
    pairs = pairs,
    md5 = md5,
    collectgarbage = collectgarbage,
    outputDebugString = outputDebugString,
    getResourceName = getResourceName,
    addEventHandler = addEventHandler,
    getLatentEventStatus = getLatentEventStatus
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

network:create("Assetify:onResourceLoad")
network:create("Assetify:onResourceFlush")
network:create("Assetify:onResourceUnload")
resource.public.isResourceLoaded = function() return (not manager:isInternal() and resource.private.buffer.source[sourceResource] and resource.private.buffer.source[sourceResource].isLoaded and true) or false end
resource.public.isResourceFlushed = function() return (not manager:isInternal() and resource.private.buffer.source[sourceResource] and resource.private.buffer.source[sourceResource].isFlushed and true) or false end
resource.public.isResourceUnLoaded = function() return (not manager:isInternal() and resource.private.buffer.source[sourceResource] and resource.private.buffer.source[sourceResource].isUnLoaded and true) or false end

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
    resource.private.buffer.name[(self.name)] = nil
    resource.private.buffer.source[(self.resource)] = nil
    self:destroyInstance()
    imports.collectgarbage()
    return true
end

if localPlayer then
    function resource.public:load(resourceSource, bandwidth)
        local resourceName = (resourceSource and imports.getResourceName(resourceSource)) or false
        if not resource.public:isInstance(self) or not resourceName or resource.private.buffer.name[resourceName] then return false end
        self.resource = resourceSource
        self.name = resourceName
        self.bandwidthData = {
            total = bandwidth.total,
            file = bandwidth.file,
            status = {total = 0, eta = 0, eta_count = 0, file = {}},
        }
        resource.private.buffer.name[(self.name)] = self
        resource.private.buffer.source[(self.resource)] = self
        return true
    end
else
    resource.private.resourceClients = {loaded = {}, loading = {}}

    function resource.public:load(resourceSource, resourceFiles, isSilent)
        local resourceName = (resourceSource and imports.getResourceName(resourceSource)) or false
        resourceFiles = (resourceFiles and (imports.type(resourceFiles) == "table") and resourceFiles) or false
        if not resource.public:isInstance(self) or not resourceName or resource.private.buffer.name[resourceName] then return false end
        self.resource = resourceSource
        self.name = resourceName
        self.isSilent = (isSilent and true) or false
        self.bandwidthData = {total = 0, file = {}}
        self.unSynced = {
            fileData = {},
            fileHash = {}
        }
        if resourceFiles then
            for i = 1, #resourceFiles, 1 do
                local j = ":"..(self.name).."/"..resourceFiles[i]
                local builtFileData, builtFileSize = file:read(j)
                if builtFileData then
                    self.bandwidthData.file[j] = builtFileSize
                    self.bandwidthData.total = self.bandwidthData.total + self.bandwidthData.file[j]
                    self.unSynced.fileData[j] = builtFileData
                    self.unSynced.fileHash[j] = imports.md5(builtFileData)
                else
                    imports.outputDebugString("[Assetify] | Invalid File: "..j)
                end
            end
        end
        self.isLoaded = true
        resource.private.buffer.name[(self.name)] = self
        resource.private.buffer.source[(self.resource)] = self
        if not self.isSilent then
            thread:create(function(self)
                for i, j in imports.pairs(resource.private.resourceClients.loaded) do
                    syncer.private:syncResource(i, self.name)
                    thread:pause()
                end
            end):resume({executions = settings.downloader.syncRate, frames = 1})
        end
        network:emit("Assetify:onResourceLoad", false, self.name, self.resource) 
        return true
    end

    function resource.private:loadClient(player)
        if not resource.private.resourceClients.loading[player] then
            resource.private.resourceClients.loading[player] = thread:createHeartbeat(function()
                local self = resource.private.resourceClients.loading[player]
                if self and not resource.private.resourceClients.loaded[player] and thread:isInstance(self) then
                    print("HB RUNNING")
                    self.cStatus, self.cQueue = self.cStatus or {}, self.cQueue or {}
                    for i, j in imports.pairs(self.cQueue) do
                        local queueStatus = imports.getLatentEventStatus(player, i)
                        if queueStatus then
                            self.cStatus[(j.resourceName)] = self.cStatus[(j.resourceName)] or {}
                            self.cStatus[(j.resourceName)][(j.file)] = queueStatus
                        else
                            self.cQueue[i] = nil
                            if self.cStatus[(j.resourceName)] then
                                self.cStatus[(j.resourceName)][(j.file)] = (self.cStatus[(j.resourceName)][(j.file)] and {tickEnd = 0, percentComplete = 100}) or nil
                            end
                        end
                    end
                    network:emit("Assetify:Downloader:onSyncProgress", true, false, player, self.cStatus, _, true)
                    return true
                end
                return false
            end, function() resource.private.resourceClients.loading[player] = nil end, settings.downloader.trackRate)
        end
    end
    return true
end


---------------------
--[[ API Syncers ]]--
---------------------

network:fetch("Assetify:onResourceFlush"):on(function(resourceName)
    if not resource.private.buffer.name[resourceName] then return false end
    resource.private.buffer.name[resourceName]:destroy()
end)
imports.addEventHandler((localPlayer and "onClientResourceStop") or "onResourceStop", root, function(resourceSource)
    if resourceSource == syncer.public.libraryResource then return false end
    local resourceName = imports.getResourceName(resourceSource)
    if resource.private.buffer.name[resourceName] then
        resource.private.buffer.name[resourceName].isFlushed = true
        resource.private.buffer.name[resourceName].isUnloaded = true
    end
    network:emit("Assetify:onResourceFlush", false, resourceName, resourceSource)
    network:emit("Assetify:onResourceUnload", false, resourceName, resourceSource)
end)
imports.addEventHandler("onPlayerQuit", root, function()
    if resource.private.resourceClients.loading[source] then resource.private.resourceClients.loading[source]:destroy() end
    resource.private.resourceClients.loaded[source] = nil
    resource.private.resourceClients.loading[source] = nil
end)