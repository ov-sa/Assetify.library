----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: engine: interface.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Interface Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    tonumber = tonumber,
    getTickCount = getTickCount,
    dxCreateFont = dxCreateFont,
    getKeyState = getKeyState,
    getCursorPosition = getCursorPosition,
    isCursorShowing = isCursorShowing,
    isMTAWindowActive = isMTAWindowActive,
    isChatBoxInputActive = isChatBoxInputActive,
    guiGetInputEnabled = guiGetInputEnabled
}


--------------------------
--[[ Class: Interface ]]--
--------------------------

local interface = class:create("interface")
interface.public.tick = imports.getTickCount()
interface.private.cache = {}
interface.private.cache.font = {}
interface.private.cache.key = {}
interface.private.cache.scroll = {}

function interface.public.getCursorPosition()
    if not imports.isCursorShowing() then return false end
    local x, y, world_x, world_y, world_z = imports.getCursorPosition()
    return x*ov_widget.resolution[1], y*ov_widget.resolution[2], world_x, world_y, world_z
end

function interface.public.isCursorAtPosition(x, y, width, height)
    local cx, cy = interface.public.getCursorPosition()
    if not cx or not cy then return false end
    return ((cx >= x) and (cx <= (x + width)) and (cy >= y) and (cy <= (y + height)) and true) or false
end

function interface.public.createFont(path, size)
    if not path or not size then return false end
    interface.private.cache.font[path] = interface.private.cache.font[path] or {}
    interface.private.cache.font[path][size] = interface.private.cache.font[path][size] or {element = imports.dxCreateFont(path, size)}
    interface.private.cache.font[path][size].tick = interface.public.tick
    return interface.private.cache.font[path][size].element
end

function interface.private.setKeyRegistered(key, state)
    state = (state and true) or false
    if not key then return false end
    if state then
        interface.private.cache.key[key] = interface.private.cache.key[key] or {}
        interface.private.cache.key[key].tick = interface.public.tick
    else
        interface.private.cache.key[key] = nil
    end
    return true
end

function interface.public.isKeyOnHold(key)
    if not interface.private.setKeyRegistered(key, true) then return false end
    return (interface.private.cache.key[key] and interface.private.cache.key[key].hold and true) or false
end

function interface.public.isKeyClicked(key)
    if not interface.private.setKeyRegistered(key, true) then return false end
    return (interface.private.cache.key[key] and interface.private.cache.key[key].clicked and true) or false
end

function interface.public.isMouseScrolled()
    return interface.private.cache.scroll.state or false
end

function interface.public.registerKeyClick(key)
    if not key or not interface.private.cache.key[key] then return false end
    interface.private.cache.key[key].clicked = nil
    return true
end

function interface.public.registerMouseScroll()
    if not interface.private.cache.scroll.state then return false end
    interface.private.cache.scroll.state, interface.private.cache.scroll.count = nil, nil
    return true
end

addEventHandler("onClientRender", root, function()
    interface.public.tick = imports.getTickCount()
    for i, j in imports.pairs(interface.private.cache.key) do
        local state = imports.getKeyState(i)
        state = ((stringn.find(i, "mouse") or (not imports.isMTAWindowActive() and not imports.guiGetInputEnabled() and not imports.isChatBoxInputActive())) and state) or false
        j.clicked = (state and (j.hold ~= state) and true) or false
        j.hold = state
    end
    if interface.private.cache.scroll.state then
        interface.private.cache.scroll.count = interface.private.cache.scroll.count - 1
        if interface.private.cache.scroll.count <= 0 then
            interface.public.registerMouseScroll()
        end
    end
end)

addEventHandler("onClientKey", root, function(key)
    if ((key ~= "mouse_wheel_up") and (key ~= "mouse_wheel_down")) then return false end
    interface.private.cache.scroll.state = stringn.gsub(key, "mouse_wheel_", "")
    interface.private.cache.scroll.count = 2
end)

timer:create(function()
    for i, j in imports.pairs(interface.private.cache.font) do
        for k, v in imports.pairs(j) do
            if (interface.public.tick - v.tick) >= 3000 then
                destroyElement(v.font)
                interface.private.cache.font[i][k] = nil
            end
        end
    end
    for i, j in imports.pairs(interface.private.cache.key) do
        if (interface.public.tick - j.tick) >= 3000 then
            interface.private.setKeyRegistered(i, false)
        end
    end
end, 3000, 0)