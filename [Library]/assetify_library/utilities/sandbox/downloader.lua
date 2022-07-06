----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: sandbox: downloader.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Downloader Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local syncer = syncer:import()
local imports = {
    type = type,
    pairs = pairs,
    md5 = md5,
    collectgarbage = collectgarbage
}


---------------------------
--[[ Class: Downloader ]]--
---------------------------

if localPlayer then
    syncer.private.execOnLoad(function() network:emit("Assetify:Downloader:onPostSyncPool", true, false, localPlayer) end)
    network:create("Assetify:Downloader:onRecieveBandwidth"):on(function(bandwidth) syncer.public.libraryBandwidth = bandwidth end)
    network:create("Assetify:Downloader:onRecieveHash"):on(function(assetType, assetName, hashes)
        if not syncer.public.scheduledAssets[assetType] then syncer.public.scheduledAssets[assetType] = {} end
        syncer.public.scheduledAssets[assetType][assetName] = syncer.public.scheduledAssets[assetType][assetName] or {assetSize = 0}
        thread:create(function(self)
            local fetchFiles = {}
            for i, j in imports.pairs(hashes) do
                local fileData = file:read(i)
                if not fileData or (imports.md5(fileData) ~= j) then
                    fetchFiles[i] = true
                else
                    syncer.public.scheduledAssets[assetType][assetName].assetSize = syncer.public.scheduledAssets[assetType][assetName].assetSize + settings.assetPacks[assetType].rwDatas[assetName].assetSize.file[i]
                    syncer.public.__libraryBandwidth = (syncer.public.__libraryBandwidth or 0) + settings.assetPacks[assetType].rwDatas[assetName].assetSize.file[i]
                end
                fileData = nil
                thread:pause()
            end
            network:emit("Assetify:Downloader:onRecieveHash", true, true, localPlayer, assetType, assetName, fetchFiles)
            imports.collectgarbage()
        end):resume({executions = settings.downloader.buildRate, frames = 1})
    end)

    network:create("Assetify:Downloader:onRecieveData"):on(function(assetType, baseIndex, subIndexes, indexData)
        if not settings.assetPacks[assetType] then settings.assetPacks[assetType] = {} end
        if not subIndexes then
            settings.assetPacks[assetType][baseIndex] = indexData
        else
            if not settings.assetPacks[assetType][baseIndex] then settings.assetPacks[assetType][baseIndex] = {} end
            local totalIndexes = #subIndexes
            local indexPointer = settings.assetPacks[assetType][baseIndex]
            if totalIndexes > 1 then
                for i = 1, totalIndexes - 1, 1 do
                    local indexReference = subIndexes[i]
                    if not indexPointer[indexReference] then indexPointer[indexReference] = {} end
                    indexPointer = indexPointer[indexReference]
                end
            end
            indexPointer[(subIndexes[totalIndexes])] = indexData
        end
    end)

    network:create("Assetify:Downloader:onRecieveContent"):on(function(assetType, assetName, contentPath, ...)
        if assetType and assetName then
            syncer.public.scheduledAssets[assetType][assetName].assetSize = syncer.public.scheduledAssets[assetType][assetName].assetSize + settings.assetPacks[assetType].rwDatas[assetName].assetSize.file[contentPath]
            syncer.public.__libraryBandwidth = (syncer.public.__libraryBandwidth or 0) + settings.assetPacks[assetType].rwDatas[assetName].assetSize.file[contentPath]
        end
        file:write(contentPath, ...)
        imports.collectgarbage()
    end)

    network:create("Assetify:Downloader:onRecieveState"):on(function(assetType, assetName)
        local isTypeVoid = true
        syncer.public.scheduledAssets[assetType][assetName] = nil
        for i, j in imports.pairs(syncer.public.scheduledAssets[assetType]) do
            if j then
                isTypeVoid = false
                break
            end
        end
        if isTypeVoid then
            local isSyncDone = true
            syncer.public.scheduledAssets[assetType] = nil
            for i, j in imports.pairs(syncer.public.scheduledAssets) do
                if j then
                    isSyncDone = false
                    break
                end
            end
            if isSyncDone then
                if assetType == "module" then
                    network:emit("Assetify:Downloader:onRequestSyncPack", true, false, localPlayer)
                    thread:create(function(self)
                        if settings.assetPacks["module"].autoLoad and settings.assetPacks["module"].rwDatas then
                            for i, j in imports.pairs(settings.assetPacks["module"].rwDatas) do
                                if j then manager:load("module", i) end
                                thread:pause()
                            end
                        end
                        network:emit("Assetify:onModuleLoad", false)
                    end):resume({executions = settings.downloader.buildRate, frames = 1})
                else
                    syncer.public.scheduledAssets = nil
                    thread:create(function(self)
                        for i, j in imports.pairs(settings.assetPacks) do
                            if i ~= "module" then
                                if j.autoLoad and j.rwDatas then
                                    for k, v in imports.pairs(j.rwDatas) do
                                        if v then manager:load(i, k) end
                                        thread:pause()
                                    end
                                end
                            end
                        end
                        network:emit("Assetify:onLoad", false)
                    end):resume({executions = settings.downloader.buildRate, frames = 1})
                end
            end
        end
    end)
else
    function syncer.public:syncHash(player, ...) return network:emit("Assetify:Downloader:onRecieveHash", true, false, player, ...) end
    function syncer.public:syncData(player, ...) return network:emit("Assetify:Downloader:onRecieveData", true, false, player, ...) end
    function syncer.public:syncContent(player, ...) return network:emit("Assetify:Downloader:onRecieveContent", true, false, player, ...) end
    function syncer.public:syncState(player, ...) return network:emit("Assetify:Downloader:onRecieveState", true, false, player, ...) end
    network:create("Assetify:Downloader:onRecieveHash"):on(function(source, assetType, assetName, hashes) syncer.public:syncPack(source, {type = assetType, name = assetName, hashes = hashes}) end)
    network:create("Assetify:Downloader:onRequestSyncPack"):on(function(source) syncer.public:syncPack(source) end)

    function syncer.public:syncPack(player, assetDatas, syncModules)
        if not assetDatas then
            thread:create(function(self)
                local isLibraryVoid = true
                for i, j in imports.pairs(settings.assetPacks) do
                    if i ~= "module" then
                        if j.assetPack then
                            for k, v in imports.pairs(j.assetPack) do
                                if k ~= "rwDatas" then
                                    if syncModules then
                                        syncer.public:syncData(player, i, k, false, v)
                                    end
                                else
                                    for m, n in imports.pairs(v) do
                                        isLibraryVoid = false
                                        if syncModules then
                                            syncer.public:syncData(player, i, "rwDatas", {m, "assetSize"}, n.synced.assetSize)
                                        else
                                            syncer.public:syncHash(player, i, m, n.unSynced.fileHash)
                                        end
                                        thread:pause()
                                    end
                                end
                                thread:pause()
                            end
                        end
                    end
                end
                if syncModules then
                    local isModuleVoid = true
                    network:emit("Assetify:Downloader:onRecieveBandwidth", true, false, player, syncer.public.libraryBandwidth)
                    self:await(network:emitCallback(self, "Assetify:onRequestPreSyncPool", false, player))
                    if settings.assetPacks["module"] and settings.assetPacks["module"].assetPack then
                        for i, j in imports.pairs(settings.assetPacks["module"].assetPack) do
                            if i ~= "rwDatas" then
                                syncer.public:syncData(player, "module", i, false, j)
                            else
                                for k, v in imports.pairs(j) do
                                    isModuleVoid = false
                                    syncer.public:syncData(player, "module", "rwDatas", {k, "assetSize"}, v.synced.assetSize)
                                    syncer.public:syncHash(player, "module", k, v.unSynced.fileHash)
                                    thread:pause()
                                end
                            end
                            thread:pause()
                        end
                    end
                    if isModuleVoid then
                        network:emit("Assetify:onModuleLoad", true, false, player)
                        network:emit("Assetify:Downloader:onRequestSyncPack", false, player)
                    end
                else
                    if isLibraryVoid then network:emit("Assetify:onLoad", true, false, player) end
                end
            end):resume({executions = settings.downloader.syncRate, frames = 1})
        else
            thread:create(function(self)
                local cAsset = settings.assetPacks[(assetDatas.type)].assetPack.rwDatas[(assetDatas.name)]
                for i, j in imports.pairs(cAsset.synced) do
                    if i ~= "assetSize" then
                        syncer.public:syncData(player, assetDatas.type, "rwDatas", {assetDatas.name, i}, j)
                    end
                    thread:pause()
                end
                for i, j in imports.pairs(assetDatas.hashes) do
                    syncer.public:syncContent(player, assetDatas.type, assetDatas.name, i, cAsset.unSynced.fileData[i])
                    thread:pause()
                end
                syncer.public:syncState(player, assetDatas.type, assetDatas.name)
            end):resume({executions = settings.downloader.syncRate, frames = 1})
        end
        return true
    end
end