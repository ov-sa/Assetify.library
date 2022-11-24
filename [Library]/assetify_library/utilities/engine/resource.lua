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
    collectgarbage = collectgarbage,
    getResourceName = getResourceName,
    addEventHandler = addEventHandler
}


-------------------------
--[[ Class: Resource ]]--
-------------------------

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

if localPlayer then

else
    function resource.public:load(resourceSource)
        local resourceName = (resourceSource and imports.getResourceName(resourceSource)) or false
        if not resource.public:isInstance(self) or not resourceName then return false end
        self.resource = resourceSource
        self.resourceName = resourceName
        resource.private.buffer.name[(self.resourceName)] = self
        resource.private.buffer.source[(self.resource)] = self
        return true
    end

    function resource.public:unload()
        if not resource.public:isInstance(self) then return false end
        resource.private.buffer.name[(self.resourceName)] = nil
        resource.private.buffer.source[(self.resource)] = nil
        self:destroyInstance()
        imports.collectgarbage()
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
if not localPlayer then
    network:fetch("Assetify:onResourceLoad"):on(function(resourceName, resourceSource, resourceFiles, isSilent)
        if syncer.private.syncedResources[resourceName] then return false end
        syncer.private.syncedResources[resourceName] = {
            isSilent = (isSilent and true) or false,
            synced = {
                bandwidthData = {total = 0, file = {}},
            },
            unSynced = {
                fileData = {},
                fileHash = {}
            }
        }
        for i = 1, #resourceFiles, 1 do
            local j = ":"..resourceName.."/"..resourceFiles[i]
            local builtFileData, builtFileSize = file:read(j)
            if builtFileData then
                syncer.private.syncedResources[resourceName].synced.bandwidthData.file[j] = builtFileSize
                syncer.private.syncedResources[resourceName].synced.bandwidthData.total = syncer.private.syncedResources[resourceName].synced.bandwidthData.total + syncer.private.syncedResources[resourceName].synced.bandwidthData.file[j]
                syncer.private.syncedResources[resourceName].unSynced.fileData[j] = builtFileData
                syncer.private.syncedResources[resourceName].unSynced.fileHash[j] = imports.md5(builtFileData)
            else
                imports.outputDebugString("[Assetify] | Invalid File: "..j)
            end
        end
        if not syncer.private.syncedResources[resourceName].isSilent then
            thread:create(function(self)
                for i, j in imports.pairs(syncer.public.libraryClients.loaded) do
                    syncer.private:syncResource(i, resourceName)
                    thread:pause()
                end
            end):resume({executions = settings.downloader.syncRate, frames = 1})
        end
    end)
end