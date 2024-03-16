----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: cli: builder.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: CLI: Builder Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    outputServerLog = outputServerLog,
    addEventHandler = addEventHandler,
    setWaterLevel = setWaterLevel
}


-----------------------
--[[ CLI: Handlers ]]--
-----------------------

if localPlayer then
    imports.addEventHandler("onClientResourceStart", resourceRoot, function()
        if settings.GTA.clearWorld then manager.API.World.clearWorld()
        else manager.API.World.restoreWorld() end
        if settings.GTA.waterLevel then
            if streamer.waterBuffer then imports.setWaterLevel(streamer.waterBuffer, settings.GTA.waterLevel) end
            imports.setWaterLevel(settings.GTA.waterLevel, true, true, true, true)
        end
    end)
    
    imports.addEventHandler("onClientResourceStop", resourceRoot, function()
        network:emit("Assetify:onUnload", false)
    end)
else
    imports.addEventHandler("onResourceStart", resourceRoot, function()
        thread:create(function()
            try({
                exec = function(self)
                    self:await(cli:update())
                    syncer.libraryToken = self:await(rest:post(syncer.libraryWebserver.."/onSetConnection", {state = true}))
                    imports.outputServerLog("Assetify: Webserver ━│  Connection successfully established!")
                    if not settings.assetPacks["module"] then network:emit("Assetify:onModuleLoad", false) end
                    for i, j in imports.pairs(settings.assetPacks) do
                        thread:create(function()
                            asset:buildPack(i, j, function(state, assetType)
                                if assetType == "module" then network:emit("Assetify:onModuleLoad", false) end
                                timer:create(function() self:resume() end, 1, 1)
                            end)
                        end):resume({executions = settings.downloader.buildRate, frames = 1})
                        thread:pause()
                    end
                    imports.outputServerLog("Assetify: Webserver ━│  Assets successfully synced!")
                    network:emit("Assetify:onLoad", false)
                end,
                catch = function() imports.outputServerLog("Assetify: Webserver ━│  Connection failed; Kindly ensure the webserver is running prior connection...") end
            })
        end):resume()
    end)

    imports.addEventHandler("onResourceStop", resourceRoot, function()
        network:emit("Assetify:onUnload", false)
        if syncer.libraryToken then rest:post(syncer.libraryWebserver.."/onSetConnection", {state = false}) end
    end)
end