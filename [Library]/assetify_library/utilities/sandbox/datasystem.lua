----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: sandbox: datasystem.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Data System Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    isElement = isElement,
    getElementType = getElementType
}


---------------------
--[[ Class: Data ]]--
---------------------

syncer.syncedGlobalDatas = {}
syncer.syncedEntityDatas = {}
network:create("Assetify:onGlobalDataChange")
network:create("Assetify:onEntityDataChange")

if localPlayer then
    function syncer.syncGlobalData(data, value)
        if not data or (imports.type(data) ~= "string") then return false end
        local __value = syncer.syncedGlobalDatas[data]
        syncer.syncedGlobalDatas[data] = value
        network:emit("Assetify:onGlobalDataChange", false, data, __value, value)
        return true
    end

    function syncer.syncEntityData(element, data, value, remoteSignature)
        if not element or (not remoteSignature and not imports.isElement(element)) or not data or (imports.type(data) ~= "string") then return false end
        syncer.syncedEntityDatas[element] = syncer.syncedEntityDatas[element] or {}
        local __value = syncer.syncedEntityDatas[element][data]
        syncer.syncedEntityDatas[element][data] = value
        network:emit("Assetify:onEntityDataChange", false, element, data, __value, value)
        return true
    end
    network:create("Assetify:Syncer:onSyncGlobalData"):on(function(...) syncer.syncGlobalData(...) end)
    network:create("Assetify:Syncer:onSyncEntityData"):on(function(...) syncer.syncEntityData(...) end)
else
    function syncer.syncGlobalData(data, value, isSync, targetPlayer)
        if targetPlayer then return network:emit("Assetify:Syncer:onSyncGlobalData", true, false, targetPlayer, data, value) end
        if not data or (imports.type(data) ~= "string") then return false end
        local __value = syncer.syncedGlobalDatas[data]
        syncer.syncedGlobalDatas[data] = value
        network:emit("Assetify:onGlobalDataChange", false, data, __value, value)
        local execWrapper = nil
        execWrapper = function()
            for i, j in imports.pairs(syncer.libraryClients.loaded) do
                syncer.syncGlobalData(data, value, _, i)
                if not isSync then thread:pause() end
            end
            execWrapper = nil
        end
        if isSync then
            execWrapper()
        else
            thread:create(execWrapper):resume({executions = settings.downloader.syncRate, frames = 1})
        end
        return true
    end

    function syncer.syncEntityData(element, data, value, isSync, targetPlayer, remoteSignature)
        if targetPlayer then return network:emit("Assetify:Syncer:onSyncEntityData", true, false, targetPlayer, element, data, value, remoteSignature) end
        if not element or not imports.isElement(element) or not data or (imports.type(data) ~= "string") then return false end
        remoteSignature = {
            elementType = imports.getElementType(element)
        }
        syncer.syncedEntityDatas[element] = syncer.syncedEntityDatas[element] or {}
        local __value = syncer.syncedEntityDatas[element][data]
        syncer.syncedEntityDatas[element][data] = value
        network:emit("Assetify:onEntityDataChange", false, element, data, __value, value)
        local execWrapper = nil
        execWrapper = function()
            for i, j in imports.pairs(syncer.libraryClients.loaded) do
                syncer.syncEntityData(element, data, value, _, i, remoteSignature)
                if not isSync then thread:pause() end
            end
            execWrapper = nil
        end
        if isSync then
            execWrapper()
        else
            thread:create(execWrapper):resume({executions = settings.downloader.syncRate, frames = 1})
        end
        return true
    end
end


---------------------
--[[ API Syncers ]]--
---------------------

network:fetch("Assetify:onElementDestroy"):on(function(self, source)
    if not syncer.isLibraryBooted or not source then return false end
    if syncer.syncedEntityDatas[source] ~= nil then self:sleep(settings.syncer.persistenceDuration) end
    syncer.syncedEntityDatas[source] = nil
end, {isAsync = true})