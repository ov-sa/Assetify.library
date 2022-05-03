----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: builder.lua
     Author: vStudio
     Developer(s): Aviril, Tron
     DOC: 19/10/2021
     Desc: Builder Handler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    setTimer = setTimer,
    addEventHandler = addEventHandler,
    triggerEvent = triggerEvent
}


----------------------------------
--[[ Event: On Resource Start ]]--
----------------------------------

local function onLibraryLoaded()
    imports.triggerEvent("onAssetifyLoad", resourceRoot)
    for i, j in imports.pairs(syncer.scheduledClients) do
        syncer:syncPack(i, _, true)
        syncer.loadedClients[i] = true
        syncer.scheduledClients[i] = nil
    end
end

imports.addEventHandler("onResourceStart", resourceRoot, function()
    thread:create(function(cThread)
        syncer.libraryModules = {}
        if not availableAssetPacks["module"] then
            imports.triggerEvent("onAssetifyModuleLoad", resourceRoot)
        end
        for i, j in imports.pairs(availableAssetPacks) do
            asset:buildPack(i, j, function(state, assetType)
                if assetType == "module" then
                    imports.triggerEvent("onAssetifyModuleLoad", resourceRoot)
                end
                imports.setTimer(function()
                    cThread:resume()
                end, 1, 1)
            end)
            thread.pause()
        end
        onLibraryLoaded()
    end):resume()
end)

imports.addEventHandler("onResourceStop", resourceRoot, function()
    imports.triggerEvent("onAssetifyUnLoad", resourceRoot)
end)
