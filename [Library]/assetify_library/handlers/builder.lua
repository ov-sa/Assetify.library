----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: builder.lua
     Server: -
     Author: OvileAmriam
     Developer(s): Aviril, Tron
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Builder Handler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    setTimer = setTimer,
    addEventHandler = addEventHandler
}


----------------------------------
--[[ Event: On Resource Start ]]--
----------------------------------

local function onLibraryLoaded()
    syncer.isLibraryLoaded = true
    for i, j in imports.pairs(syncer.scheduledClients) do
        syncer:syncPack(i)
        syncer.loadedClients[i] = true
        syncer.scheduledClients[i] = nil
    end
end

imports.addEventHandler("onResourceStart", resourceRoot, function()
    thread:create(function(cThread)
        for i, j in imports.pairs(availableAssetPacks) do
            asset:buildPack(i, j, function(state)
                imports.setTimer(function()
                    cThread:resume()
                end, 1, 1)
            end)
            thread.pause()
        end
        onLibraryLoaded()
    end):resume()
end)