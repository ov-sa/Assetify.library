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
    function resource.public:load(resourceSource)
        local name = (resourceSource and imports.getResourceName(resourceSource)) or false
        if not resource.public:isInstance(self) or not name or resource.private.buffer.name[name] then return false end
        self.resource = resourceSource
        self.name = name
        self.bandwidthData = {total = 0, file = {}}
        resource.private.buffer.name[(self.name)] = self
        resource.private.buffer.source[(self.resource)] = self
        network:emit("Assetify:onResourceLoad", false, self.name, self.resource) 
        return true
    end
else
    resource.private.resourceClients = {loaded = {}, loading = {}}

    function resource.public:load(resourceSource, resourceFiles, isSilent)
        local name = (resourceSource and imports.getResourceName(resourceSource)) or false
        resourceFiles = (resourceFiles and (imports.type(resourceFiles) == "table") and resourceFiles) or false
        if not resource.public:isInstance(self) or not name or resource.private.buffer.name[name] then return false end
        self.resource = resourceSource
        self.name = name
        self.isSilent = (isSilent and true) or false
        self.synced = {
            bandwidthData = {total = 0, file = {}}
        }
        self.unSynced = {
            fileData = {},
            fileHash = {}
        }
        if resourceFiles then
            for i = 1, #resourceFiles, 1 do
                local j = ":"..(self.name).."/"..resourceFiles[i]
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
        resource.private.buffer.name[(self.name)] = self
        resource.private.buffer.source[(self.resource)] = self
        if not self.isSilent then
            thread:create(function(self)
                for i, j in imports.pairs(resource.private.resourceClients.loaded) do
                    syncer.private:syncResource(i, name)
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

network:fetch("Assetify:onResourceFlush"):on(function(name)
    if not resource.private.buffer.name[name] then return false end
    resource.private.buffer.name[name]:destroy()
end)
imports.addEventHandler((localPlayer and "onClientResourceStop") or "onResourceStop", root, function(resourceSource)
    if resourceSource == syncer.public.libraryResource then return false end
    local name = imports.getResourceName(resourceSource)
    network:emit("Assetify:onResourceFlush", false, name, resourceSource)
    network:emit("Assetify:onResourceUnload", false, name, resourceSource)
end)
imports.addEventHandler("onPlayerQuit", root, function()
    if resource.private.resourceClients.loading[source] then resource.private.resourceClients.loading[source]:destroy() end
    resource.private.resourceClients.loaded[source] = nil
    resource.private.resourceClients.loading[source] = nil
end)