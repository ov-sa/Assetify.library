----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: cli: updater.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: CLI: Updater Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local cli = cli:import()
local imports = {
    pairs = pairs,
    collectgarbage = collectgarbage,
    outputServerLog = outputServerLog,
    restartResource = restartResource,
    getResourceFromName = getResourceFromName
}


----------------------
--[[ CLI: Helpers ]]--
----------------------

local updateResources = nil
updateResources = {
    updateTags = {"file", "script"},
    fetchSource = function(base, version, ...) return (base and version and string.format(base, version, ...)) or false end,
    onUpdateCallback = function(isCompleted, isNotification)
        if isCompleted then
            syncer.libraryVersion = updateResources.updateCache.libraryVersion
            for i, j in imports.pairs(updateResources.updateCache.backup) do
                imports.outputServerLog("Assetify: Updater ━│  Backed up <"..i.."> due to compatibility breaking changes; Kindly acknowledge it accordingly!")
                file:write(i, j)
            end
            for i, j in imports.pairs(updateResources.updateCache.output) do
                file:write(i, j)
            end
            imports.outputServerLog("Assetify: Updater ━│  Update successfully completed; Rebooting!")
            for i = 1, table.length(updateResources), 1 do
                local j = updateResources[i]
                if not j.isSilentResource and j.resourceREF then
                    local cResource = imports.getResourceFromName(j.resourceREF)
                    if cResource then imports.restartResource(cResource) end
                end
            end
        end
        if isNotification and not isCompleted then imports.outputServerLog("Assetify: Updater ━│  Update failed due to connectivity issues; Try again later...") end
        if updateResources.updatePromise then updateResources.updatePromise.resolve() end
        if updateResources.updateThread then updateResources.updateThread:destroy() end
        updateResources.updateCache = nil
        updateResources.updateThread = nil
        cli.public.isLibraryBeingUpdated = nil
        imports.collectgarbage()
        return true
    end,
    {
        isSilentResource = false,
        resourceREF = syncer.libraryName,
        resourceName = "assetify_library",
        resourceSource = "https://raw.githubusercontent.com/ov-sa/Assetify.library/%s/[Library]/",
        resourceBackup = {
            ["settings/shared.lua"] = true,
            ["settings/server.lua"] = true
        }
    },
    --[[
    {
        isSilentResource = true,
        resourceName = "assetify_mapper",
        resourceSource = "https://raw.githubusercontent.com/ov-sa/Assetify.library/mapper/[Library]/"
    }
    ]]
}
for i = 1, table.length(updateResources), 1 do
    local j = updateResources[i]
    if j.isSilentResource then j.buffer = {} end
    if j.resourceREF then j.resourcePointer = ":"..j.resourceREF.."/" end
end


-----------------------
--[[ CLI: Handlers ]]--
-----------------------

function cli.private:update(resourcePointer, responsePointer, isUpdateStatus)
    if not responsePointer then
        updateResources.updatePromise = thread:createPromise()
        updateResources.updateThread = thread:create(function()
            for i = 1, table.length(updateResources), 1 do
                local resourcePointer, resourceResponse = updateResources[i], false
                local resourceMeta = updateResources.updateCache.libraryVersionSource..(resourcePointer.resourceName).."/meta.xml"
                thread:create(function()
                    try({
                        exec = function(self)
                            resourceResponse = self:await(rest:get(resourceMeta))
                            updateResources.updateThread:resume()
                        end,
                        catch = function() updateResources.onUpdateCallback(false, true) end
                    })
                end):resume()
                updateResources.updateThread:pause()
                local isLastIndex = false
                for i = 1, table.length(updateResources.updateTags), 1 do
                    for j in string.gmatch(resourceResponse, "<".. updateResources.updateTags[i].." src=\"(.-)\"(.-)/>") do
                        if not string.isVoid(j) and (not updateResources.updateCache.isBackwardCompatible or not resourcePointer.resourceBackup or not resourcePointer.resourceBackup[j]) then
                            cli.private:update(resourcePointer, {updateResources.updateCache.libraryVersionSource..(resourcePointer.resourceName).."/"..j, j})
                            timer:create(function()
                                if isLastIndex then
                                    updateResources.updateThread:resume()
                                end
                            end, 1, 1)
                            updateResources.updateThread:pause()
                        end
                    end
                end
                isLastIndex = true
                cli.private:update(resourcePointer, {resourceMeta, "meta.xml", resourceResponse})
            end
            updateResources.onUpdateCallback(true, true)
        end)
        updateResources.updateThread:resume()
    else
        if resourcePointer.isSilentResource then resourcePointer.isFetched = false end
        local outputPointer = (not resourcePointer.isSilentResource and updateResources.updateCache.output) or resourcePointer.buffer
        local isBackupToBeCreated = (not resourcePointer.isSilentResource and resourcePointer.resourceBackup and resourcePointer.resourceBackup[(responsePointer[2])] and true) or false
        responsePointer[2] = resourcePointer.resourcePointer..responsePointer[2]
        if isBackupToBeCreated then updateResources.updateCache.backup[(responsePointer[2]..".backup")] = file:read(responsePointer[2]) end
        if responsePointer[3] then
            outputPointer[(responsePointer[2])] = responsePointer[3]
            updateResources.updateThread:resume()
        else
            thread:create(function()
                try({
                    exec = function(self)
                        outputPointer[(responsePointer[2])] = self:await(rest:get(responsePointer[1]))
                        updateResources.updateThread:resume()
                    end,
                    catch = function() updateResources.onUpdateCallback(false, true) end
                })
            end):resume()
        end
    end
    return updateResources.updatePromise
end

function cli.public:update(isAction)
    if cli.public.isLibraryBeingUpdated then return imports.outputServerLog("Assetify: Updater ━│  An update request is already being processed; Kindly have patience...") end
    cli.public.isLibraryBeingUpdated = true
    local cPromise = thread:createPromise()
    thread:create(function()
        try({
            exec = function(self)
                if isAction then imports.outputServerLog("Assetify: Updater ━│  Fetching latest version; Hold up...") end
                local response = table.decode(self:await(rest:get(syncer.librarySource)), "json")
                if syncer.libraryVersion == response.tag_name then
                    if isAction then imports.outputServerLog("Assetify: Updater ━│  Already upto date - "..response.tag_name) end
                    return updateResources.onUpdateCallback()
                end
                local isToBeUpdated, isAutoUpdate = (isAction and true) or settings.library.autoUpdate, (not isAction and settings.library.autoUpdate) or false
                imports.outputServerLog("Assetify: Updater ━│  "..((isToBeUpdated and not isAutoUpdate and "Updating to latest version") or (isToBeUpdated and isAutoUpdate and "Auto-updating to latest version") or "Latest version available").." - "..response.tag_name)
                if not isToBeUpdated then return updateResources.onUpdateCallback() end
                updateResources.updateCache = {
                    output = {}, backup = {},
                    isAutoUpdate = isAutoUpdate,
                    libraryVersion = response.tag_name,
                    libraryVersionSource = updateResources.fetchSource(updateResources[1].resourceSource, response.tag_name),
                    isBackwardCompatible = string.match(syncer.libraryVersion, "(%d+)%.") == string.match(response.tag_name, "(%d+)%.")
                }
                self:await(cli.private:update())
            end,
            catch = function() updateResources.onUpdateCallback(false, true) end
        })
        cPromise.resolve()
    end):resume()
    return cPromise
end
