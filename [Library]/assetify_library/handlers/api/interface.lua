----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: api: interface.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Interface APIs ]]--
----------------------------------------------------------------


-------------------------
--[[ APIs: Interface ]]--
-------------------------

if localPlayer then
    manager:exportAPI("interface", "isCursorVisible", interface.isCursorVisible)
    manager:exportAPI("interface", "setCursorVisible", interface.setCursorVisible)
    manager:exportAPI("interface", "getCursorPosition", interface.getCursorPosition)
    manager:exportAPI("interface", "isCursorAtPosition", interface.isCursorAtPosition)
    manager:exportAPI("interface", "createFont", interface.createFont)
    manager:exportAPI("interface", "isKeyOnHold", interface.isKeyOnHold)
    manager:exportAPI("interface", "isKeyClicked", interface.isKeyClicked)
    manager:exportAPI("interface", "isMouseScrolled", interface.isMouseScrolled)
    manager:exportAPI("interface", "registerKeyClick", interface.registerKeyClick)
    manager:exportAPI("interface", "registerMouseScroll", interface.registerMouseScroll)
else

end