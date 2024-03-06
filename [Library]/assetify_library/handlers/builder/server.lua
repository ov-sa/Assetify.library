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

local imports = {
    pairs = pairs,
    outputServerLog = outputServerLog,
    addEventHandler = addEventHandler
}


--------------------------
--[[ Builder Handlers ]]--
--------------------------

imports.addEventHandler("onResourceStart", resourceRoot, function()
    cli:update()
    thread:create(function()
        try({
            exec = function(self)
                syncer.libraryToken = self:await(rest:post("http://localhost:33022/onSetConnection", true)).token
                imports.outputServerLog("Assetify: Webserver ━│  Connection successfully established!")
                if not settings.assetPacks["module"] then network:emit("Assetify:onModuleLoad", false) end
                for i, j in imports.pairs(settings.assetPacks) do
                    thread:create(function()
                        asset:buildPack(i, j, function(state, assetType)
                            if assetType == "module" then network:emit("Assetify:onModuleLoad", false) end
                            timer:create(function()
                                self:resume()
                            end, 1, 1)
                        end)
                    end):resume({executions = settings.downloader.buildRate, frames = 1})
                    thread:pause()
                end
                network:emit("Assetify:onLoad", false)
            end,
            catch = function() imports.outputServerLog("Assetify: Webserver ━│  Connection failed; Kindly ensure the webserver is running prior connection...") end
        })
    end):resume()
end)

imports.addEventHandler("onResourceStop", resourceRoot, function()
    network:emit("Assetify:onUnload", false)
    if syncer.libraryToken then rest:post("http://localhost:33022/onSetConnection", false) end
end)
