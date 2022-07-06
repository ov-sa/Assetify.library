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

local syncer = syncer:import()
local imports = {
    pairs = pairs,
    type = type,
    isElement = isElement,
    getElementType = getElementType
}


---------------------
--[[ Class: Data ]]--
---------------------

syncer.public.syncedGlobalDatas = {}
syncer.public.syncedEntityDatas = {}
network:create("Assetify:onGlobalDataChange")
network:create("Assetify:onEntityDataChange")

if localPlayer then
    function syncer.public:syncGlobalData(data, value)
        if not data or (imports.type(data) ~= "string") then return false end
        local __value = syncer.public.syncedGlobalDatas[data]
        syncer.public.syncedGlobalDatas[data] = value
        network:emit("Assetify:onGlobalDataChange", false, data, __value, value)
        return true
    end

    function syncer.public:syncEntityData(element, data, value, remoteSignature)
        if not element or (not remoteSignature and not imports.isElement(element)) or not data or (imports.type(data) ~= "string") then return false end
        syncer.public.syncedEntityDatas[element] = syncer.public.syncedEntityDatas[element] or {}
        local __value = syncer.public.syncedEntityDatas[element][data]
        syncer.public.syncedEntityDatas[element][data] = value
        network:emit("Assetify:onEntityDataChange", false, element, data, __value, value)
        return true
    end
    network:create("Assetify:onRecieveSyncedGlobalData"):on(function(...) syncer.public:syncGlobalData(...) end)
    network:create("Assetify:onRecieveSyncedEntityData"):on(function(...) syncer.public:syncEntityData(...) end)
else
    function syncer.public:syncGlobalData(data, value, isSync, targetPlayer)
        if not targetPlayer then return network:emit("Assetify:onRecieveSyncedGlobalData", true, false, targetPlayer, data, value) end
        if not data or (imports.type(data) ~= "string") then return false end
        local __value = syncer.public.syncedGlobalDatas[data]
        syncer.public.syncedGlobalDatas[data] = value
        network:emit("Assetify:onGlobalDataChange", false, data, __value, value)
        local execWrapper = nil
        execWrapper = function()
            for i, j in imports.pairs(syncer.public.loadedClients) do
                syncer.public:syncGlobalData(data, value, isSync, i)
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

    function syncer.public:syncEntityData(element, data, value, isSync, targetPlayer, remoteSignature)
        if not targetPlayer then return network:emit("Assetify:onRecieveSyncedEntityData", true, false, targetPlayer, element, data, value, remoteSignature) end
        if not element or not imports.isElement(element) or not data or (imports.type(data) ~= "string") then return false end
        remoteSignature = imports.getElementType(element)
        syncer.public.syncedEntityDatas[element] = syncer.public.syncedEntityDatas[element] or {}
        local __value = syncer.public.syncedEntityDatas[element][data]
        syncer.public.syncedEntityDatas[element][data] = value
        network:emit("Assetify:onEntityDataChange", false, element, data, __value, value)
        local execWrapper = nil
        execWrapper = function()
            for i, j in imports.pairs(syncer.public.loadedClients) do
                syncer.public:syncEntityData(element, data, value, isSync, i, remoteSignature)
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