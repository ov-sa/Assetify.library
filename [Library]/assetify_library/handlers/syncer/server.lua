----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: syncer: server.lua
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
    addEventHandler = addEventHandler,
    triggerLatentClientEvent = triggerLatentClientEvent
}


-------------------
--[[ Variables ]]--
-------------------

local scheduledSyncs = {}


-----------------------------------------------
--[[ Events: On Player Resource-Start/Quit ]]--
-----------------------------------------------

imports.addEventHandler("onPlayerResourceStart", root, function()

    if isLibraryLoaded then
        local clientPlayer = source
        thread:create(function(cThread)
            for i, j in imports.pairs(availableAssetPacks) do
                for k, v in imports.pairs(j.assetPack) do
                    if k ~= "rwDatas" then
                        imports.triggerLatentClientEvent(clientPlayer, "onClientRecieveAssets", 125000, false, clientPlayer, i, k, v)
                    else
                        for x, y in imports.pairs(v) do
                            imports.triggerLatentClientEvent(clientPlayer, "onClientRecieveAssets", 125000, false, clientPlayer, i, k, _, x, y)
                            thread.pause()
                        end
                    end
                    thread.pause()
                end
            end
        end):resume({
            executions = 5,
            frames = 1
        })
    else
        scheduledSyncs[source] = true
    end

end)

imports.addEventHandler("onPlayerQuit", root, function()

    scheduledSyncs[source] = nil

end)
