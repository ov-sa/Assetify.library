----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: sandbox: math. matrix.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Matrix Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    tonumber = tonumber,
    setmetatable = setmetatable
}


-----------------------
--[[ Class: Matrix ]]--
-----------------------

local matrix = class:create("matrix", _, "math")
imports.setmetatable(matrix.public, matrix.public)

matrix.public.__call = function(_, ...)
    local rows, order = {...}, false
    local isValid = (#rows > 0 and true) or false
    for i = 1, #rows, 1 do
        local j = rows[i]
        local __order = ((imports.type(j) == "table") and #j) or false
        __order = (__order and (__order > 0) and __order) or false
        isValid = (isValid and __order and (not order or (order == __order)) and true) or false
        if isValid then
            order = __order
            for k = 1, __order, 1 do
                j[k] = imports.tonumber(j[k])
                if not j[k] then
                    isValid = false
                    break
                end
            end
        end
        if not isValid then break end
    end
    if not isValid then return false end
    local cMatrix = matrix.public:createInstance()
    imports.setmetatable(cMatrix, matrix.public)
    cMatrix.order = {#rows, order}
    cMatrix.rows = rows
    return cMatrix
end

function matrix.public:destroy()
    if not matrix.public:isInstance(self) then return false end
    self:destroyInstance()
    return true
end

matrix.public.__add = function(matrixLHS, matrixRHS)
    if not matrix.public:isInstance(matrixLHS) or not matrix.public:isInstance(matrixRHS) or (matrixLHS.order[1] ~= matrixRHS.order[1]) or (matrixLHS.order[2] ~= matrixRHS.order[2]) then return false end
    local rows = {}
    for i = 1, matrixLHS.order[1], 1 do
        rows[i] = rows[i] or {}
        for k = 1, matrixLHS.order[2], 1 do
            rows[i][k] = rows[i][k] or {}
            rows[i][k] = matrixLHS.rows[i][k] + matrixRHS.rows[i][k]
        end
    end
    return matrix.public(table.unpack(rows))
end

matrix.public.__sub = function(matrixLHS, matrixRHS)
    if not matrix.public:isInstance(matrixLHS) or not matrix.public:isInstance(matrixRHS) or (matrixLHS.order[1] ~= matrixRHS.order[1]) or (matrixLHS.order[2] ~= matrixRHS.order[2]) then return false end
    local rows = {}
    for i = 1, matrixLHS.order[1], 1 do
        for k = 1, matrixLHS.order[2], 1 do
            rows[i] = rows[i] or {}
            rows[i][k] = matrixLHS.rows[i][k] - matrixRHS.rows[i][k]
        end
    end
    return matrix.public(table.unpack(rows))
end

matrix.public.__mul = function(matrixLHS, matrixRHS)
    if not matrix.public:isInstance(matrixLHS) or not matrix.public:isInstance(matrixRHS) or (matrixLHS.order[1] ~= matrixRHS.order[1]) or (matrixLHS.order[2] ~= matrixRHS.order[2]) then return false end
    local rows = {}
    for i = 1, matrixLHS.order[1], 1 do
        for k = 1, matrixLHS.order[2], 1 do
            rows[i] = rows[i] or {}
            rows[i][k] = matrixLHS.rows[i][k] * matrixRHS.rows[i][k]
        end
    end
    return matrix.public(table.unpack(rows))
end

matrix.public.__div = function(matrixLHS, matrixRHS)
    if not matrix.public:isInstance(matrixLHS) or not matrix.public:isInstance(matrixRHS) or (matrixLHS.order[1] ~= matrixRHS.order[1]) or (matrixLHS.order[2] ~= matrixRHS.order[2]) then return false end
    local rows = {}
    for i = 1, matrixLHS.order[1], 1 do
        for k = 1, matrixLHS.order[2], 1 do
            rows[i] = rows[i] or {}
            rows[i][k] = matrixLHS.rows[i][k] / matrixRHS.rows[i][k]
        end
    end
    return matrix.public(table.unpack(rows))
end

function matrix.public:scale(scale)
    if not matrix.public:isInstance(self) then return false end
    scale = imports.tonumber(scale)
    if not scale then return false end
    for i = 1, #self.order[1], 1 do
        for k = 1, #self.order[2], 1 do
            self.rows[i][k] = self.rows[i][k]*scale
        end
    end
    return self
end

function matrix.public:transform(rotationMatrix, x, y, z)
    if not matrix.public:isInstance(self) or not matrix.public:isInstance(rotationMatrix) or (self.order[1] ~= 4) or (self.order[2] ~= 4) or (rotationMatrix.order[1] ~= 3) or (rotationMatrix.order[2] ~= 3) then return false end
    x, y, z, rotX, rotY, rotZ = imports.tonumber(x), imports.tonumber(y), imports.tonumber(z)
    if not x or not y or not z then return false end
    return matrix.public(
        {
            (self.rows[2][1]*rotationMatrix.rows[1][2]) + (self.rows[1][1]*rotationMatrix.rows[1][1]) + (rotationMatrix.rows[1][3]*self.rows[3][1]),
            (self.rows[3][2]*rotationMatrix.rows[1][3]) + (self.rows[1][2]*rotationMatrix.rows[1][1]) + (self.rows[2][2]*rotationMatrix.rows[1][2]),
            (self.rows[2][3]*rotationMatrix.rows[1][2]) + (self.rows[3][3]*rotationMatrix.rows[1][3]) + (rotationMatrix.rows[1][1]*self.rows[1][3]),
            0
        },
        {
            (rotationMatrix.rows[2][3]*self.rows[3][1]) + (self.rows[2][1]*rotationMatrix.rows[2][2]) + (rotationMatrix.rows[2][1]*self.rows[1][1]),
            (self.rows[3][2]*rotationMatrix.rows[2][3]) + (self.rows[2][2]*rotationMatrix.rows[2][2]) + (self.rows[1][2]*rotationMatrix.rows[2][1]),
            (rotationMatrix.rows[2][1]*self.rows[1][3]) + (self.rows[3][3]*rotationMatrix.rows[2][3]) + (self.rows[2][3]*rotationMatrix.rows[2][2]),
            0
        },
        {
            (self.rows[2][1]*rotationMatrix.rows[3][2]) + (rotationMatrix.rows[3][3]*self.rows[3][1]) + (rotationMatrix.rows[3][1]*self.rows[1][1]),
            (self.rows[3][2]*rotationMatrix.rows[3][3]) + (self.rows[2][2]*rotationMatrix.rows[3][2]) + (rotationMatrix.rows[3][1]*self.rows[1][2]),
            (rotationMatrix.rows[3][1]*self.rows[1][3]) + (self.rows[3][3]*rotationMatrix.rows[3][3]) + (self.rows[2][3]*rotationMatrix.rows[3][2]),
            0
        },
        {
            (z*self.rows[1][1]) + (y*self.rows[2][1]) - (x*self.rows[3][1]) + self.rows[4][1],
            (z*self.rows[1][2]) + (y*self.rows[2][2]) - (x*self.rows[3][2]) + self.rows[4][2],
            (z*self.rows[1][3]) + (y*self.rows[2][3]) - (x*self.rows[3][3]) + self.rows[4][3],
            1
        }
    )
end

function matrix.public:fromLocation(x, y, z, rotX, rotY, rotZ)
    if (self ~= matrix.public) and (self ~= matrix.private) then return false end
    x, y, z, rotX, rotY, rotZ = imports.tonumber(x), imports.tonumber(y), imports.tonumber(z), imports.tonumber(rotX), imports.tonumber(rotY), imports.tonumber(rotZ)
    if not x or not y or not z or not rotX or not rotY or not rotZ then return false end
    rotX, rotY, rotZ = math.rad(rotX), math.rad(rotY), math.rad(rotZ)
    local sYaw, sPitch, sRoll = math.sin(rotX), math.sin(rotY), math.sin(rotZ)
    local cYaw, cPitch, cRoll = math.cos(rotX), math.cos(rotY), math.cos(rotZ)
    return matrix.public(
        {(cRoll*cPitch) - (sRoll*sYaw*sPitch), (cPitch*sRoll) + (cRoll*sYaw*sPitch), -cYaw*sPitch, 0},
        {-cYaw*sRoll, cRoll*cYaw, sYaw, 0},
        {(cRoll*sPitch) + (cPitch*sRoll*sYaw), (sRoll*sPitch) - (cRoll*cPitch*sYaw), cYaw*cPitch, 0},
        {x, y, z, 1}
    )
end

function matrix.public:fromRotation(rotX, rotY, rotZ)
    if (self ~= matrix.public) and (self ~= matrix.private) then return false end
    rotX, rotY, rotZ = imports.tonumber(rotX), imports.tonumber(rotY), imports.tonumber(rotZ)
    if not rotX or not rotY or not rotZ then return false end
    rotX, rotY, rotZ = math.rad(rotX), math.rad(rotY), math.rad(rotZ)
    local sYaw, sPitch, sRoll = math.sin(rotX), math.sin(rotY), math.sin(rotZ)
    local cYaw, cPitch, cRoll = math.cos(rotX), math.cos(rotY), math.cos(rotZ)
    return matrix.public(
        {(sRoll*sPitch*sYaw) + (cRoll*cYaw), sRoll*cPitch, (sRoll*sPitch*cYaw) - (cRoll*sYaw)},
        {(cRoll*sPitch*sYaw) - (sRoll*cYaw), cRoll*cPitch, (cRoll*sPitch*cYaw) + (sRoll*sYaw)},
        {cPitch*sYaw, -sPitch, cPitch*cYaw}
    )
end