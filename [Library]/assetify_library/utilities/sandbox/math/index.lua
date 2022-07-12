----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: sandbox: math. index.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Math Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    tonumber = tonumber,
    loadstring = loadstring
}


---------------------
--[[ Class: Math ]]--
---------------------

local math = namespace:create("math", math)

function math.public.round(value, decimals)
    value = imports.tonumber(value)
    if not value then return false end
    return imports.tonumber(string.format("%."..(imports.tonumber(decimals) or 0).."f", value))
end

function math.public.percent(value, percent)
    value, percent = imports.tonumber(value), imports.tonumber(percent)
    if not value or not percent then return false end
    return value*percent*0.01
end

function math.public.findDistance2D(x1, y1, x2, y2)
    x1, y1, x2, y2 = imports.tonumber(x1), imports.tonumber(y1), imports.tonumber(x2), imports.tonumber(y2)
    if not x1 or not y1 or not x2 or not y2 then return false end
    return math.public.sqrt(((x2 - x1)^2) + ((y2 - y1)^2))
end

function math.public.findDistance3D(x1, y1, z1, x2, y2, z2)
    x1, y1, z1, x2, y2, z2 = imports.tonumber(x1), imports.tonumber(y1), imports.tonumber(z1), imports.tonumber(x2), imports.tonumber(y2), imports.tonumber(z2)
    if not x1 or not y1 or not z1 or not x2 or not y2 or not z2 then return false end
    return math.public.sqrt(((x2 - x1)^2) + ((y2 - y1)^2) + ((z2 - z1)^2))
end

function math.public.findRotation2D(x1, y1, x2, y2) 
    x1, y1, x2, y2 = imports.tonumber(x1), imports.tonumber(y1), imports.tonumber(x2), imports.tonumber(y2)
    if not x1 or not y1 or not x2 or not y2 then return false end
    local rotation = -math.public.deg(math.public.atan2(x2 - x1, y2 - y1))
    return ((rotation < 0) and (rotation + 360)) or rotation
end

function math.public.findPointByRotation2D(x, y, distance, rotation)
    x, y, distance, rotation = imports.tonumber(x), imports.tonumber(y), imports.tonumber(distance), imports.tonumber(rotation)
    if not x or not y or not distance or not rotation then return false end
    rotation = math.public.rad(90 - rotation)
    return x + (math.public.cos(rotation)*distance), y + (math.public.sin(rotation)*distance)
end