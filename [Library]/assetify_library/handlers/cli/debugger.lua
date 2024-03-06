----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: cli: debugger.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: CLI: Debugger Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    addCommandHandler = addCommandHandler,
    addEventHandler = addEventHandler,
    removeEventHandler = removeEventHandler,
    dxDrawText = dxDrawText
}


----------------------
--[[ Class: Debug ]]--
----------------------

local debug = class:create("debug")
debug.private.state = false
debug.private.offset = {renderer.resolution[1] - 10, 10}
debug.private.padding = "         "
debug.private.colors = {"#E1E1E1", "#AFAFAF"}

function debug.private.render()
    if not settings.assetPacks then return false end
    local renderText = debug.private.colors[1].."Assetify ━│  Debugger\n\n"
    for assetType, _ in imports.pairs(settings.assetPacks) do
        renderText = renderText..debug.private.colors[1]..debug.private.padding.."━ "..assetType.."\n"
        if settings.assetPacks[assetType].rwDatas then
            for assetName, _ in imports.pairs(settings.assetPacks[assetType].rwDatas) do
                local _, _, progress, eta = manager:getDownloadProgress(assetType, assetName)
                renderText = renderText..debug.private.colors[2]..debug.private.padding..debug.private.padding.."• "..assetName.." ━│  ("
                renderText = renderText.."Progress: "..math.floor(progress or 0).."%"
                if eta then renderText = renderText.."  |  ETA: "..string.formatTime(eta) end
                renderText = renderText..")\n"
            end
        end
    end
    imports.dxDrawText(renderText, debug.private.offset[1], debug.private.offset[2], debug.private.offset[1], debug.private.offset[2], -1, 1, "default-bold", "right", "top", false, false, true, true)
    return true
end

function debug.public:toggle(state)
    if debug.private.state == state then return false end
    debug.private.state = state
    if debug.private.state then imports.addEventHandler("onClientHUDRender", root, debug.private.render)
    else imports.removeEventHandler("onClientHUDRender", root, debug.private.render) end
    return true
end


---------------------
--[[ CLI Syncers ]]--
---------------------

imports.addCommandHandler("assetify", function(_, isAction, ...)
    isAction = (isAction and ((string.sub(isAction, 0, 2) == "--") and string.sub(isAction, 3, string.len(isAction)))) or false
    if not isAction or (isAction ~= "debug") then return false end
    debug.public:toggle(not debug.private.state)
end)