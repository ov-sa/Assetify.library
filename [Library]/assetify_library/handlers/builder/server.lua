----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: builder: server.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Builder Handler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local syncer = syncer:import()
local imports = {
    pairs = pairs,
    fetchRemote = fetchRemote,
    outputDebugString = outputDebugString,
    addEventHandler = addEventHandler
}


--------------------------
--[[ Builder Handlers ]]--
--------------------------

imports.addEventHandler("onResourceStart", resourceRoot, function()
    imports.fetchRemote(syncer.public.librarySource, function(response, status)
        if not response or not status or (status ~= 0) then return false end
        response = table.decode(response)
        if response and response.tag_name and (syncer.private.libraryVersion ~= response.tag_name) then
            local isBackwardsCompatible = string.match(syncer.private.libraryVersion, "(%d+)%.") == string.match(response.tag_name, "(%d+)%.")
            syncer.private.libraryVersionSource = string.gsub(syncer.private.libraryVersionSource, syncer.private.libraryVersion, response.tag_name, 1)
            imports.outputDebugString("[Assetify]: "..((settings.library.autoUpdate and "Auto-updating to latest version") or "Latest version available").." - "..response.tag_name, 3)
            if settings.library.autoUpdate then
                for i = 1, #syncer.private.libraryResources, 1 do
                    local j = syncer.private.libraryResources[i]
                    syncer.private:updateLibrary(j, isBackwardsCompatible)
                end
            end
        end
    end)

    thread:create(function(self)
        if not settings.assetPacks["module"] then network:emit("Assetify:onModuleLoad", false) end
        for i, j in imports.pairs(settings.assetPacks) do
            asset:buildPack(i, j, function(state, assetType)
                if assetType == "module" then network:emit("Assetify:onModuleLoad", false) end
                timer:create(function()
                    self:resume()
                end, 1, 1)
            end)
            thread:pause()
        end
        network:emit("Assetify:onLoad", false)
    end):resume()
end)

imports.addEventHandler("onResourceStop", resourceRoot, function()
    network:emit("Assetify:onUnload", false)
end)
