----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: builder.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Builder Handler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    addEventHandler = addEventHandler
}


----------------------------------
--[[ Event: On Resource Start ]]--
----------------------------------

local function onLibraryLoaded()
    network:emit("Assetify:onLoad", false)
    for i, j in imports.pairs(syncer.scheduledClients) do
        syncer:syncPack(i, _, true)
        syncer.loadedClients[i] = true
        syncer.scheduledClients[i] = nil
    end
end

imports.addEventHandler("onResourceStart", resourceRoot, function()
    thread:create(function(self)
        syncer.libraryModules = {}
        if not settings.assetPacks["module"] then
            network:emit("Assetify:onModuleLoad", false)
        end
        for i, j in imports.pairs(settings.assetPacks) do
            asset:buildPack(i, j, function(state, assetType)
                if assetType == "module" then
                    network:emit("Assetify:onModuleLoad", false)
                end
                timer:create(function()
                    self:resume()
                end, 1, 1)
            end)
            thread:pause()
        end
        onLibraryLoaded()
    end):resume()
end)

imports.addEventHandler("onResourceStop", resourceRoot, function()
    network:emit("Assetify:onUnload", false)
end)
