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
    getElementType = getElementType,
    addCommandHandler = addCommandHandler,
    outputServerLog = outputServerLog
}


-------------
--[[ CLI ]]--
-------------

local cli = class:create("cli")
function cli.public:import() return cli end
cli.private.validActions = {
    ["uid"] = true,
    ["version"] = true,
    ["update"] = true
}


----------------------
--[[ CLI Handlers ]]--
----------------------

function cli.public:uid(isAction)
    imports.outputServerLog("[Assetify] | Assetify UID: "..syncer.librarySerial)
    return true
end

function cli.public:version(isAction)
    imports.outputServerLog("[Assetify] | Assetify Version: "..(syncer.libraryVersion or "N/A"))
    return true
end


---------------------
--[[ CLI Syncers ]]--
---------------------

imports.addCommandHandler("assetify", function(isConsole, _, isAction, ...)
    if not isConsole or (imports.getElementType(isConsole) ~= "console") then return false end
    if not isAction or not cli.private.validActions[isAction] then return false end
    cli.public[isAction](_, true, ...)
end)