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
    isMTAWindowActive = isMTAWindowActive,
    isChatBoxInputActive = isChatBoxInputActive,
    guiGetInputEnabled = guiGetInputEnabled
}


----------------------
--[[ Class: Scene ]]--
----------------------

local interface = class:create("interface")
interface.private.cache = {}

if localPlayer then
    interface.private.cache.font = {}
    interface.private.cache.key = {}
    interface.private.cache.scroll = {}

    function interface.public.createFont(path, size)
        if not path or not size then return false end
        interface.private.cache.font[path] = interface.private.cache.font[path] or {}
        interface.private.cache.font[path][size] = interface.private.cache.font[path][size] or {element = imports.dxCreateFont(path, size)}
        interface.private.cache.font[path][size].tick = interface.private.cache.tick
        return interface.private.cache.font[path][size].element
    end

    function interface.private.setKeyRegistered(key, state)
        state = (state and true) or false
        if not key then return false end
        if state then
            interface.private.cache.key[key] = interface.private.cache.key[key] or {}
            interface.private.cache.key[key].tick = interface.private.cache.tick
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
        interface.private.cache.tick = imports.getTickCount()
        for i, j in imports.pairs(interface.private.cache.key) do
            local hold = imports.getKeyState(i)
            hold = ((stringn.find(i, "mouse") or (not imports.isMTAWindowActive() and not imports.guiGetInputEnabled() and not imports.isChatBoxInputActive())) and hold) or false
            j.clicked = (hold and (j.hold ~= hold) and true) or false
            j.hold = hold
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
                if (interface.private.cache.tick - v.tick) >= 3000 then
                    destroyElement(v.font)
                    interface.private.cache.font[i][k] = nil
                end
            end
        end
        for i, j in imports.pairs(interface.private.cache.key) do
            if (interface.private.cache.tick - j.tick) >= 3000 then
                interface.private.setKeyRegistered(i, false)
            end
        end
    end, 3000, 0)
end