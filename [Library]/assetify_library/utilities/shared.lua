----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shared.lua
     Author: vStudio
     Developer(s): Aviril, Tron
     DOC: 19/10/2021
     Desc: Shared Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    setmetatable = setmetatable,
    fileExists = fileExists,
    fileCreate = fileCreate,
    fileDelete = fileDelete,
    fileOpen = fileOpen,
    fileRead = fileRead,
    fileWrite = fileWrite,
    fileGetSize = fileGetSize,
    fileClose = fileClose,
    math = math
}


---------------------
--[[ Class: File ]]--
---------------------

file = {
    exists = imports.fileExists,
    delete = imports.fileDelete,

    read = function(path)
        if not path or not imports.fileExists(path) then return false end
        local cFile = imports.fileOpen(path, true)
        if not cFile then return false end
        local data = imports.fileRead(cFile, imports.fileGetSize(cFile))
        imports.fileClose(cFile)
        return data
    end,

    write = function(path, data)
        if not path or not data then return false end
        local cFile = imports.fileCreate(path)
        if not cFile then return false end
        imports.fileWrite(cFile, data)
        imports.fileClose(cFile)    
        return true
    end
}


----------------------
--[[ Class: Table ]]--
----------------------

table.clone = function(baseTable, isRecursive)
    if not baseTable or (imports.type(baseTable) ~= "table") then return false end
    local clonedTable = {}
    for i, j in imports.pairs(baseTable) do
        if (imports.type(j) == "table") and isRecursive then
            clonedTable[i] = table.clone(j, true)
        else
            clonedTable[i] = j
        end
    end
    return clonedTable
end


---------------------
--[[ Class: Quat ]]--
---------------------

quat = {
    new = function(w, x, y, z)
        if not w or not x or not y or not z then return false end
        return imports.setmetatable({w, x, y, z}, quat)
    end,

    __add = function(quat1, quat2)
        if not quat1 or not quat2 then return false end
        return quat.new(quat1[1] + quat2[1], quat1[2] + quat2[2], quat1[3] + quat2[3], quat1[4] + quat2[4])
    end,

    __sub = function(quat1, quat2)
        if not quat1 or not quat2 then return false end
        return quat.new(quat1[1] - quat2[1], quat1[2] - quat2[2], quat1[3] - quat2[3], quat1[4] - quat2[4])
    end,

    __mul = function(quat1, quat2)
        if not quat1 or not quat2 then return false end
        return quat.new(
            (quat1[1]*quat2[1]) - (quat1[2]*quat2[2]) - (quat1[3]*quat2[3]) - (quat1[4]*quat2[4]),
            (quat1[1]*quat2[2]) + (quat1[2]*quat2[1]) + (quat1[3]*quat2[4]) - (quat1[4]*quat2[3]),
            (quat1[1]*quat2[3]) + (quat1[3]*quat2[1]) + (quat1[4]*quat2[2]) - (quat1[2]*quat2[4]),
            (quat1[1]*quat2[4]) + (quat1[4]*quat2[1]) + (quat1[2]*quat2[3]) - (quat1[3]*quat2[2])
        )
    end,

    __div = function(quat1, quat2)
        if not quat1 or not quat2 then return false end
        return quat.new(quat1[1]/quat2[1], quat1[2]/quat2[2], quat1[3]/quat2[3], quat1[4]/quat2[4])
    end,

    fromVectorAngle = function(vector, angle)
        if not vector or not angle then return false end
        local a = imports.math.rad(angle*0.5)
        local s, w = imports.math.sin(a), imports.math.cos(a)
        return quat.new(w, s*vector.x, s*vector.y, s*vector.z)
    end,

    fromEuler = function(x, y, z)
        if not x or not y or not z then return false end
        x, y, z = imports.math.rad(x)*0.5, imports.math.rad(y)*0.5, imports.math.rad(z)*0.5
        local sinX, sinY, sinZ = imports.math.sin(x), imports.math.sin(y), imports.math.sin(z)
        local cosX, cosY, cosZ = imports.math.cos(x), imports.math.cos(y), imports.math.cos(z)
        return (cosZ*cosX*cosY) + (sinZ*sinX*sinY), (cosZ*sinX*cosY) - (sinZ*cosX*sinY), (cosZ*cosX*sinY) + (sinZ*sinX*cosY), (sinZ*cosX*cosY) - (cosZ*sinX*sinY)
    end,

    toEuler = function(w, x, y, z)
        if not w or not x or not y or not z then return false end
        local sinX, sinY, sinZ = 2*((w*x) + (y*z)), 2*((w*y) - (z*x)), 2*((w*z) + (x*y))
        local cosX, cosY, cosZ = 1 - (2*((x*x) + (y*y))), imports.math.min(imports.math.max(sinY, -1), 1), 1 - (2*((y*y) + (z*z)))
        return imports.math.deg(imports.math.atan2(sinX, cosX)), imports.math.deg(imports.math.asin(cosY)), imports.math.deg(imports.math.atan2(sinZ, cosZ))
    end
}
quat.__index = quat


-----------------------
--[[ Class: Matrix ]]--
-----------------------

matrix = {
    fromPosition = function(posX, posY, posZ, rotX, rotY, rotZ)
        if not posX or not posY or not posZ or not rotX or not rotY or not rotZ then return false end
        rotX, rotY, rotZ = imports.math.rad(rotX), imports.math.rad(rotY), imports.math.rad(rotZ)
        local sYaw, cYaw = imports.math.sin(rotX), imports.math.cos(rotX)
        local sPitch, cPitch = imports.math.sin(rotY), imports.math.cos(rotY)
        local sRoll, cRoll = imports.math.sin(rotZ), imports.math.cos(rotZ)
        return {
            {(cRoll*cPitch) - (sRoll*sYaw*sPitch), (cPitch*sRoll) + (cRoll*sYaw*sPitch), -cYaw*sPitch, 0},
            {-cYaw*sRoll, cRoll*cYaw, sYaw, 0},
            {(cRoll*sPitch) + (cPitch*sRoll*sYaw), (sRoll*sPitch) - (cRoll*cPitch*sYaw), cYaw*cPitch, 0},
            {posX, posY, posZ, 1}
        }
    end,

    fromRotation = function(rotX, rotY, rotZ)
        if not rotX or not rotY or not rotZ then return false end
        rotX, rotY, rotZ = imports.math.rad(rotX), imports.math.rad(rotY), imports.math.rad(rotZ)
        local sYaw, cYaw = imports.math.sin(rotX), imports.math.cos(rotX)
        local sPitch, cPitch = imports.math.sin(rotY), imports.math.cos(rotY)
        local sRoll, cRoll = imports.math.sin(rotZ), imports.math.cos(rotZ)
        return {
            {(sRoll*sPitch*sYaw) + (cRoll*cYaw), sRoll*cPitch, (sRoll*sPitch*cYaw) - (cRoll*sYaw)},
            {(cRoll*sPitch*sYaw) - (sRoll*cYaw), cRoll*cPitch, (cRoll*sPitch*cYaw) + (sRoll*sYaw)},
            {cPitch*sYaw, -sPitch, cPitch*cYaw}
        }
    end,

    transform = function(elemMatrix, rotMatrix, posX, posY, posZ, isAbsoluteRotation, isDuplication)
        if not elemMatrix or not rotMatrix or not posX or not posY or not posZ then return false end
        if isAbsoluteRotation then
            if isDuplication then elemMatrix = table.clone(elemMatrix, true) end
            for i = 1, 3, 1 do
                for k = 1, 3, 1 do
                    elemMatrix[i][k] = 1
                end
            end
        end
        return {
            {
                (elemMatrix[2][1]*rotMatrix[1][2]) + (elemMatrix[1][1]*rotMatrix[1][1]) + (rotMatrix[1][3]*elemMatrix[3][1]),
                (elemMatrix[3][2]*rotMatrix[1][3]) + (elemMatrix[1][2]*rotMatrix[1][1]) + (elemMatrix[2][2]*rotMatrix[1][2]),
                (elemMatrix[2][3]*rotMatrix[1][2]) + (elemMatrix[3][3]*rotMatrix[1][3]) + (rotMatrix[1][1]*elemMatrix[1][3]),
                0
            },
            {
                (rotMatrix[2][3]*elemMatrix[3][1]) + (elemMatrix[2][1]*rotMatrix[2][2]) + (rotMatrix[2][1]*elemMatrix[1][1]),
                (elemMatrix[3][2]*rotMatrix[2][3]) + (elemMatrix[2][2]*rotMatrix[2][2]) + (elemMatrix[1][2]*rotMatrix[2][1]),
                (rotMatrix[2][1]*elemMatrix[1][3]) + (elemMatrix[3][3]*rotMatrix[2][3]) + (elemMatrix[2][3]*rotMatrix[2][2]),
                0
            },
            {
                (elemMatrix[2][1]*rotMatrix[3][2]) + (rotMatrix[3][3]*elemMatrix[3][1]) + (rotMatrix[3][1]*elemMatrix[1][1]),
                (elemMatrix[3][2]*rotMatrix[3][3]) + (elemMatrix[2][2]*rotMatrix[3][2]) + (rotMatrix[3][1]*elemMatrix[1][2]),
                (rotMatrix[3][1]*elemMatrix[1][3]) + (elemMatrix[3][3]*rotMatrix[3][3]) + (elemMatrix[2][3]*rotMatrix[3][2]),
                0
            },
            {
                (posZ*elemMatrix[1][1]) + (posY*elemMatrix[2][1]) - (posX*elemMatrix[3][1]) + elemMatrix[4][1],
                (posZ*elemMatrix[1][2]) + (posY*elemMatrix[2][2]) - (posX*elemMatrix[3][2]) + elemMatrix[4][2],
                (posZ*elemMatrix[1][3]) + (posY*elemMatrix[2][3]) - (posX*elemMatrix[3][3]) + elemMatrix[4][3],
                1
            }
        }
    end
}