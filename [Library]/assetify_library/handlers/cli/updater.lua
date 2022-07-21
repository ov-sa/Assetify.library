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
    collectgarbage = collectgarbage,
    fetchRemote = fetchRemote,
    restartResource = restartResource,
    getResourceFromName = getResourceFromName,
    outputDebugString = outputDebugString
}


----------------------
--[[ CLI: Helpers ]]--
----------------------

local updateResources = nil
updateResources = {
    updateTags = {"file", "script"},
    fetchSource = function(base, version, ...) return (base and version and string.format(base, version, ...)) or false end,
    onUpdateCallback = function(isCompleted)
        if isCompleted then
            syncer.libraryVersion = updateResources.updateCache.libraryVersion
            for i = 1, #updateResources, 1 do
                local j = updateResources[i]
                local cResource = getResourceFromName(j.resourceName)
                if cResource then restartResource(cResource) end
            end
        end
        updateResources.updateCache = nil
        cli.public.isLibraryBeingUpdated = nil
        imports.collectgarbage()
        return true
    end,
    {
        resourceName = syncer.libraryName,
        resourceSource = "https://raw.githubusercontent.com/ov-sa/Assetify-Library/%s/[Library]/",
        resourceBackup = {
            ["settings/shared.lua"] = true,
            ["settings/server.lua"] = true
        }
    }
}
for i = 1, #updateResources, 1 do
    local j = updateResources[i]
    j.resourcePointer = ":"..j.resourceName.."/"
end


-----------------------
--[[ CLI: Handlers ]]--
-----------------------

function cli.private:update(resourcePointer, responsePointer, isUpdateStatus)
    if isUpdateStatus ~= nil then
        imports.outputDebugString("[Assetify] | "..((isUpdateStatus and "Update successfully completed; Rebooting!") or "Update failed due to connectivity issues; Try again later..."), 3)
        return updateResources.onUpdateCallback(isUpdateStatus)
    end
    if not responsePointer then
        updateResources.updateThread = thread:create(function()
            for i = 1, #updateResources, 1 do
                local resourcePointer, resoureResponse = updateResources[i], false
                local resourceMeta = updateResources.updateCache.libraryVersionSource..(resourcePointer.resourceName).."/meta.xml"
                imports.fetchRemote(resourceMeta, function(...) resoureResponse = table.pack(...); updateResources.updateThread:resume() end)
                updateResources.updateThread:pause()
                if not resoureResponse[1] or not resoureResponse[2] or (resoureResponse[2] ~= 0) then return cli.private:update(_, _, false) end
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
            cli.private:update(_, _, true)
        end)
        updateResources.updateThread:resume()
    else
        local isBackupToBeCreated = (resourcePointer.resourceBackup and resourcePointer.resourceBackup[(responsePointer[2])] and true) or false
        responsePointer[2] = resourcePointer.resourcePointer..responsePointer[2]
        if isBackupToBeCreated then imports.outputDebugString("[Assetify] | Backed up <"..responsePointer[2].."> due to compatibility breaking changes; Kindly update it accordingly!", 3) end
        if responsePointer[3] then
            if isBackupToBeCreated then file:write(responsePointer[2]..".backup", file:read(responsePointer[2])) end
            file:write(responsePointer[2], responsePointer[3])
            updateResources.updateThread:resume()
        else
            imports.fetchRemote(responsePointer[1], function(response, status)
                --TODO: INSTEAD OF DESTROYING HANDLE IN THIS SOME HANDLER
                if not response or not status or (status ~= 0) then
                    cli.private:update(_, _, false)
                    return updateResources.updateThread:destroy()
                end
                if isBackupToBeCreated then file:write(responsePointer[2]..".backup", file:read(responsePointer[2])) end
                file:write(responsePointer[2], response)
                updateResources.updateThread:resume()
            end)
        end
    end
    return true
end

function cli.public:update(isAction)
    if cli.public.isLibraryBeingUpdated then return imports.outputDebugString("[Assetify] | An update request is already being processed; Kindly have patience...", 3) end
    cli.public.isLibraryBeingUpdated = true
    if isAction then imports.outputDebugString("[Assetify] | Fetching latest version; Hold up...", 3) end
    imports.fetchRemote(syncer.librarySource, function(response, status)
        if not response or not status or (status ~= 0) then return updateResources.onUpdateCallback() end
        response = table.decode(response)
        if not response or not response.tag_name then return updateResources.onUpdateCallback() end
        if syncer.libraryVersion == response.tag_name then
            if isAction then imports.outputDebugString("[Assetify] | Already upto date - "..response.tag_name, 3) end
            return updateResources.onUpdateCallback()
        end
        local isToBeUpdated, isAutoUpdate = (isAction and true) or settings.library.autoUpdate, (not isAction and settings.library.autoUpdate) or false
        imports.outputDebugString("[Assetify] | "..((isToBeUpdated and not isAutoUpdate and "Updating to latest version") or (isToBeUpdated and isAutoUpdate and "Auto-updating to latest version") or "Latest version available").." - "..response.tag_name, 3)
        if not isToBeUpdated then return updateResources.onUpdateCallback() end
        updateResources.updateCache = {
            isAutoUpdate = isAutoUpdate,
            libraryVersion = response.tag_name,
            libraryVersionSource = updateResources.fetchSource(updateResources[1].resourceSource, response.tag_name),
            isBackwardCompatible = string.match(syncer.libraryVersion, "(%d+)%.") ~= string.match(response.tag_name, "(%d+)%.")
        }
        cli.private:update()
    end)
    return true
end