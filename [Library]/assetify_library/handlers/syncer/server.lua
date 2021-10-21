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

isLibraryLoaded = false
local scheduledSyncs = {}


------------------------------------
--[[ Function: Syncs Asset Pack ]]--
------------------------------------

local function syncAssetPack(player)

    thread:create(function(cThread)
        for i, j in imports.pairs(availableAssetPacks) do
            for k, v in imports.pairs(j.assetPack) do
                if k ~= "rwDatas" then
                    imports.triggerLatentClientEvent(player, "onClientRecieveAssetPack", downloadSpeed, false, player, i, k, v)
                else
                    if i == "scene" then
                        --TODO: ..
                    else
                        for m, n in imports.pairs(v) do
                            for x, y in imports.pairs(n) do
                                if x ~= "rwData" then
                                    imports.triggerLatentClientEvent(player, "onClientRecieveAssetPack", downloadSpeed, false, player, i, k, nil, {m, x}, y)
                                else
                                    for o, p in imports.pairs(y) do
                                        imports.triggerLatentClientEvent(player, "onClientRecieveAssetPack", downloadSpeed, false, player, i, k, nil, {m, x, o}, p)
                                        thread.pause()
                                    end
                                end
                                thread.pause()
                            end
                            thread.pause()
                        end
                    end
                end
                thread.pause()
            end
        end
        imports.triggerLatentClientEvent(player, "onClientLoadAssetPack", downloadSpeed, false, player)
    end):resume({
        executions = 5,
        frames = 1
    })
    return true

end


-----------------------------------------------
--[[ Events: On Player Resource-Start/Quit ]]--
-----------------------------------------------

function onLibraryLoaded()

    isLibraryLoaded = true
    for i, j in imports.pairs(scheduledSyncs) do
        syncAssetPack(i)
        scheduledSyncs[i] = nil
    end
    
end

imports.addEventHandler("onPlayerResourceStart", root, function()

    if isLibraryLoaded then
        syncAssetPack(source)
    else
        scheduledSyncs[source] = true
    end

end)

imports.addEventHandler("onPlayerQuit", root, function()

    scheduledSyncs[source] = nil

end)