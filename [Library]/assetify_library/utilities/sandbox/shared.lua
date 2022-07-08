----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: sandbox: shared.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Shared Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    tonumber = tonumber,
    getLocalPlayer = getLocalPlayer,
    isElement = isElement,
    destroyElement = destroyElement,
    getElementMatrix = getElementMatrix,
    getElementPosition = getElementPosition,
    table = table,
    string = string,
    math = math
}


---------------
--[[ Utils ]]--
---------------


localPlayer = (imports.getLocalPlayer and imports.getLocalPlayer()) or false
isElement = function(element) return (element and imports.isElement(element)) or false end
destroyElement = function(element) return (isElement(element) and imports.destroyElement(element)) or false end
execFunction = function(exec, ...) if not exec or (imports.type(exec) ~= "function") then return false end return exec(...) end

getElementPosition = function(element, offX, offY, offZ)
    if not offX or not offY or not offZ then
        return imports.getElementPosition(element)
    else
        if not element or not imports.isElement(element) then return false end
        offX, offY, offZ = imports.tonumber(offX) or 0, imports.tonumber(offY) or 0, imports.tonumber(offZ) or 0
        local cMatrix = imports.getElementMatrix(element)
        return (offX*cMatrix[1][1]) + (offY*cMatrix[2][1]) + (offZ*cMatrix[3][1]) + cMatrix[4][1], (offX*cMatrix[1][2]) + (offY*cMatrix[2][2]) + (offZ*cMatrix[3][2]) + cMatrix[4][2], (offX*cMatrix[1][3]) + (offY*cMatrix[2][3]) + (offZ*cMatrix[3][3]) + cMatrix[4][3]
    end
end

getDistanceBetweenPoints2D = function(x1, y1, x2, y2)
    x1, y1, x2, y2 = imports.tonumber(x1), imports.tonumber(y1), imports.tonumber(x2), imports.tonumber(y2)
    if not x1 or not y1 or not x2 or not y2 then return false end
    return imports.math.sqrt(((x2 - x1)^2) + ((y2 - y1)^2))
end

getDistanceBetweenPoints3D = function(x1, y1, z1, x2, y2, z2)
    x1, y1, z1, x2, y2, z2 = imports.tonumber(x1), imports.tonumber(y1), imports.tonumber(z1), imports.tonumber(x2), imports.tonumber(y2), imports.tonumber(z2)
    if not x1 or not y1 or not z1 or not x2 or not y2 or not z2 then return false end
    return imports.math.sqrt(((x2 - x1)^2) + ((y2 - y1)^2) + ((z2 - z1)^2))
end


---------------------
--[[ Class: Math ]]--
---------------------

math.percent = function(amount, percent)
    amount, percent = imports.tonumber(amount), imports.tonumber(percent)
    if not percent or not amount then return false end
    return amount*percent*0.01
end

math.round = function(number, decimals)
    number = imports.tonumber(number)
    if not number then return false end
    decimals = imports.tonumber(decimals) or 0
    return imports.tonumber(imports.string.format("%."..decimals.."f", number))
end

math.findRotation2D = function(x1, y1, x2, y2) 
    x1, y1, x2, y2 = imports.tonumber(x1), imports.tonumber(y1), imports.tonumber(x2), imports.tonumber(y2)
    if not x1 or not y1 or not x2 or not y2 then return false end
    local rotAngle = -imports.math.deg(imports.math.atan2(x2 - x1, y2 - y1))
    return ((rotAngle < 0) and (rotAngle + 360)) or rotAngle
end

math.findDistRotationPoint2D = function(x, y, distance, angle)
    x, y, distance, angle = imports.tonumber(x), imports.tonumber(y), imports.tonumber(distance), imports.tonumber(angle)
    if not x or not y or not distance then return false end
    angle = angle or 0
    angle = imports.math.rad(90 - angle)
    return x + (imports.math.cos(angle)*distance), y + (imports.math.sin(angle)*distance)
end