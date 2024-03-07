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
    sha256 = sha256,
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
resource.public.isResourceUnloaded = function() return (not manager:isInternal() and resource.private.buffer.source[sourceResource] and resource.private.buffer.source[sourceResource].isUnLoaded and true) or false end

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

function resource.public:unload(isFlush)
    if not resource.public:isInstance(self) then return false end
    if isFlush then
        if self.isFlushed then return false end
        self.isFlushed = true
    else
        if self.isUnloaded then return false end
        self.isUnloaded = true
        timer:create(function()
            resource.private.buffer.name[(self.name)] = nil
            resource.private.buffer.source[(self.resource)] = nil
            self:destroyInstance()
            imports.collectgarbage()
        end, 1, 1)
    end
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
            file = bandwidth.file
        }
        resource.private.buffer.name[(self.name)] = self
        resource.private.buffer.source[(self.resource)] = self
        return true
    end

    function resource.public:getDownloadProgress(resourceSource)
        local cPointer = resource.private.buffer.source[resourceSource]
        if not cPointer then return false end
        local cBandwidth = cPointer.bandwidthData.total
        local cDownloaded = (cPointer.bandwidthData.isDownloaded and cBandwidth) or (cPointer.bandwidthData.status and cPointer.bandwidthData.status.total) or 0
        local cETA = (not cPointer.bandwidthData.isDownloaded and cPointer.bandwidthData.status and (cPointer.bandwidthData.status.eta/math.max(1, cPointer.bandwidthData.status.eta_count))) or false
        return cDownloaded, cBandwidth, (cDownloaded/math.max(1, cBandwidth))*100, cETA
    end
else
    resource.private.resourceSchedules = {resource = {}, client = {}}
    resource.private.resourceClients = {loaded = {}}
    network:create("Assetify:Resource:onLoadClient"):on(function(source, resourceName)
        --TODO: STORE RESOURCES DOWNLOAD LIST AND DO THE BELOW UPON VOID LIST ONLY
        resource.private.resourceClients.loaded[source] = true
    end)
    syncer.private.execOnLoad(function()
        for i, j in imports.pairs(resource.private.resourceSchedules.resource) do
            syncer.public:syncResource(_, i, table.unpack(j))
        end
        resource.private.resourceSchedules.resource = nil
    end)

    network:fetch("Assetify:Syncer:onSyncPostPool"):on(function(self, source)
        self:resume({executions = settings.downloader.syncRate, frames = 1})
        syncer.private:syncResource(source)
        if resource.private.resourceSchedules.client[source] then
            for i, j in imports.pairs(resource.private.resourceSchedules.client[source]) do
                if resource.private.buffer.source[i] then syncer.private:syncResource(source, resource.private.buffer.source[i].name) end
                thread:pause()
            end
        end
        resource.private.resourceSchedules.client[source] = nil
    end, {isAsync = true})

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
            for i = 1, table.length(resourceFiles), 1 do
                local j = ":"..(self.name).."/"..resourceFiles[i]
                local builtFileData, builtFileSize = file:read(j)
                if builtFileData then
                    self.bandwidthData.file[j] = builtFileSize
                    self.bandwidthData.total = self.bandwidthData.total + self.bandwidthData.file[j]
                    self.unSynced.fileData[j] = builtFileData
                    self.unSynced.fileHash[j] = imports.sha256(builtFileData)
                else
                    imports.outputDebugString("Assetify: Invalid File ━│  "..j)
                end
            end
        end
        self.isLoaded = true
        resource.private.buffer.name[(self.name)] = self
        resource.private.buffer.source[(self.resource)] = self
        if not self.isSilent then
            thread:create(function(self)
                for i, j in imports.pairs(syncer.public.libraryClients.loaded) do
                    syncer.private:syncResource(i, self.name)
                    thread:pause()
                end
            end):resume({executions = settings.downloader.syncRate, frames = 1})
        end
        network:emit("Assetify:onResourceLoad", false, self.name, self.resource) 
        return true
    end
end


---------------------
--[[ API Syncers ]]--
---------------------

if localPlayer then
    network:fetch("Assetify:onResourceLoad"):on(function(resourceName)
        network:emit("Assetify:Resource:onLoadClient", true, false, localPlayer, resourceName)
    end)
end
network:fetch("Assetify:onResourceFlush"):on(function(resourceName)
    if not resource.private.buffer.name[resourceName] then return false end
    resource.private.buffer.name[resourceName]:destroy(true)
end)
network:fetch("Assetify:onResourceUnload"):on(function(resourceName)
    if not resource.private.buffer.name[resourceName] then return false end
    resource.private.buffer.name[resourceName]:destroy()
end)
imports.addEventHandler((localPlayer and "onClientResourceStop") or "onResourceStop", root, function(resourceSource)
    if resourceSource == syncer.public.libraryResource then return false end
    local resourceName = (resource.private.buffer.source[resourceSource] and resource.private.buffer.source[resourceSource].name) or imports.getResourceName(resourceSource)
    network:emit("Assetify:onResourceFlush", false, resourceName, resourceSource)
    network:emit("Assetify:onResourceUnload", false, resourceName, resourceSource)
end)
imports.addEventHandler("onPlayerQuit", root, function()
    if not syncer.public.isLibraryLoaded then return false end
    resource.private.resourceSchedules.client[source] = nil
    resource.private.resourceClients.loaded[source] = nil
end)