----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: syncer. server.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Library Syncer ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    addEvent = addEvent,
    addEventHandler = addEventHandler,
    getResourceRootElement = getResourceRootElement
}


-------------------
--[[ Variables ]]--
-------------------

isLibraryLoaded = false


-----------------------------------------------
--[[ Events: On Player Resource-Start/Quit ]]--
-----------------------------------------------

function onLibraryLoaded()

    isLibraryLoaded = true
    for i, j in imports.pairs(syncer.scheduledClients) do
        syncer:syncPack(i)
        syncer.scheduledClients[i] = nil
    end
    
end

imports.addEventHandler("onPlayerResourceStart", root, function(resourceElement)

    if imports.getResourceRootElement(resourceElement) == resourceRoot then
        if isLibraryLoaded then
            syncer:syncPack(source)
        else
            syncer.scheduledClients[source] = true
        end
    end

end)

imports.addEventHandler("onPlayerQuit", root, function()

    syncer.scheduledClients[source] = nil

end)