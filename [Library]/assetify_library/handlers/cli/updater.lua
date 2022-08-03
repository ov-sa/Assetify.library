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
    fetchRemote = fetchRemote,
    restartResource = restartResource,
    getResourceFromName = getResourceFromName,
    outputServerLog = outputServerLog
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
                imports.outputServerLog("[Assetify] | Backed up <"..i.."> due to compatibility breaking changes; Kindly acknowledge it accordingly!")
                file:write(i, j)
            end
            for i, j in imports.pairs(updateResources.updateCache.output) do
                file:write(i, j)
            end
            imports.outputServerLog("[Assetify] | Update successfully completed; Rebooting!")
            for i = 1, #updateResources, 1 do
                local j = updateResources[i]
                if not j.isSilentResource and j.resourceREF then
                    local cResource = imports.getResourceFromName(j.resourceREF)
                    if cResource then imports.restartResource(cResource) end
                end
            end
        end
        if isNotification and not isCompleted then imports.outputServerLog("[Assetify] | Update failed due to connectivity issues; Try again later...") end
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
        resourceSource = "https://raw.githubusercontent.com/ov-sa/Assetify-Library/%s/[Library]/",
        resourceBackup = {
            ["settings/shared.lua"] = true,
            ["settings/server.lua"] = true
        }
    },
    --[[
    {
        isSilentResource = true,
        resourceName = "assetify_mapper",
        resourceSource = "https://raw.githubusercontent.com/ov-sa/Assetify-Library/mapper/[Library]/"
    }
    ]]
}
for i = 1, #updateResources, 1 do
    local j = updateResources[i]
    if j.isSilentResource then j.buffer = {} end
    if j.resourceREF then j.resourcePointer = ":"..j.resourceREF.."/" end
end


-----------------------
--[[ CLI: Handlers ]]--
-----------------------

function cli.private:update(resourcePointer, responsePointer, isUpdateStatus)
    if not responsePointer then
        updateResources.updateThread = thread:create(function()
            for i = 1, #updateResources, 1 do
                local resourcePointer, resoureResponse = updateResources[i], false
                local resourceMeta = updateResources.updateCache.libraryVersionSource..(resourcePointer.resourceName).."/meta.xml"
                imports.fetchRemote(resourceMeta, function(...) resoureResponse = table.pack(...); updateResources.updateThread:resume() end)
                updateResources.updateThread:pause()
                if not resoureResponse[1] or not resoureResponse[2] or (resoureResponse[2] ~= 0) then return updateResources.onUpdateCallback(false, true) end
                local isLastIndex = false
                for i = 1, #updateResources.updateTags, 1 do
                    for j in string.gmatch(resoureResponse[1], "<".. updateResources.updateTags[i].." src=\"(.-)\"(.-)/>") do
                        if (#string.gsub(j, "%s", "") > 0) and (not updateResources.updateCache.isBackwardCompatible or not resourcePointer.resourceBackup or not resourcePointer.resourceBackup[j]) then
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
                cli.private:update(resourcePointer, {resourceMeta, "meta.xml", resoureResponse[1]})
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
            imports.fetchRemote(responsePointer[1], function(response, status)
                if not response or not status or (status ~= 0) then return updateResources.onUpdateCallback(false, true) end
                outputPointer[(responsePointer[2])] = response
                updateResources.updateThread:resume()
            end)
        end
    end
    return true
end

function cli.public:update(isAction)
    if cli.public.isLibraryBeingUpdated then return imports.outputServerLog("[Assetify] | An update request is already being processed; Kindly have patience...") end
    cli.public.isLibraryBeingUpdated = true
    if isAction then imports.outputServerLog("[Assetify] | Fetching latest version; Hold up...") end
    imports.fetchRemote(syncer.librarySource, function(response, status)
        if not response or not status or (status ~= 0) then return updateResources.onUpdateCallback(false, true) end
        response = table.decode(response)
        if not response or not response.tag_name then return updateResources.onUpdateCallback(false, true) end
        if syncer.libraryVersion == response.tag_name then
            if isAction then imports.outputServerLog("[Assetify] | Already upto date - "..response.tag_name) end
            return updateResources.onUpdateCallback()
        end
        local isToBeUpdated, isAutoUpdate = (isAction and true) or settings.library.autoUpdate, (not isAction and settings.library.autoUpdate) or false
        imports.outputServerLog("[Assetify] | "..((isToBeUpdated and not isAutoUpdate and "Updating to latest version") or (isToBeUpdated and isAutoUpdate and "Auto-updating to latest version") or "Latest version available").." - "..response.tag_name)
        if not isToBeUpdated then return updateResources.onUpdateCallback() end
        updateResources.updateCache = {
            output = {}, backup = {},
            isAutoUpdate = isAutoUpdate,
            libraryVersion = response.tag_name,
            libraryVersionSource = updateResources.fetchSource(updateResources[1].resourceSource, response.tag_name),
            isBackwardCompatible = string.match(syncer.libraryVersion, "(%d+)%.") == string.match(response.tag_name, "(%d+)%.")
        }
        cli.private:update()
    end)
    return true
end