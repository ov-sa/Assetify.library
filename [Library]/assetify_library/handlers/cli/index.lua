----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: cli: index.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: CLI Handler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    outputServerLog = outputServerLog,
    getElementType = getElementType,
    addCommandHandler = addCommandHandler
}


--------------------
--[[ Class: CLI ]]--
--------------------

local cli = class:create("cli")
function cli.public:import() return cli end
cli.private.validActions = {
    ["serial"] = true,
    ["version"] = true,
    ["webserver"] = true,
    ["update"] = true
}


-----------------------
--[[ CLI: Handlers ]]--
-----------------------

function cli.public:serial(isAction)
    imports.outputServerLog("Assetify: Serial ━│  "..(manager.API.library.fetchSerial() or "N/A"))
    return true
end

function cli.public:version(isAction)
    imports.outputServerLog("Assetify: Version ━│  "..(manager.API.library.fetchVersion() or "N/A"))
    return true
end

function cli.public:webserver(isAction)
    imports.outputServerLog("Assetify: Webserver ━│  "..(manager.API.library.fetchWebserver() or "N/A"))
    return true
end


---------------------
--[[ CLI Syncers ]]--
---------------------

imports.addCommandHandler("assetify", function(isConsole, _, isAction, ...)
    if not isConsole or (imports.getElementType(isConsole) ~= "console") then return false end
    isAction = (isAction and ((stringn.sub(isAction, 0, 2) == "--") and stringn.sub(isAction, 3, stringn.len(isAction)))) or false
    if not isAction or not cli.private.validActions[isAction] then return false end
    cli.public[isAction](_, true, ...)
end)