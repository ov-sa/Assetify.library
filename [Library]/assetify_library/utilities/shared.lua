----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shared.lua
     Server: -
     Author: OvileAmriam
     Developer(s): Aviril, Tron
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Shared Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    fileExists = fileExists,
    fileCreate = fileCreate,
    fileOpen = fileOpen,
    fileRead = fileRead,
    fileWrite = fileWrite,
    fileGetSize = fileGetSize,
    fileClose = fileClose,
    math = {
        deg = math.deg,
        atan2 = math.atan2
    }
}


---------------------
--[[ Class: File ]]--
---------------------

file = {
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

function table.clone(baseTable, isRecursive)
    if not baseTable or imports.type(baseTable) ~= "table" then return false end
    local clonedTable = {}
    for i, j in imports.pairs(baseTable) do
        if imports.type(j) == "table" and isRecursive then
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
    convertToEuler = function(w, x, y, z)
        if not w or not x or not y or not z then return false end
        if (imports.type(w) ~= "number") or (imports.type(x) ~= "number") or (imports.type(y) ~= "number") or (imports.type(z) ~= "number") then return false end

        local sinX, sinY, sinZ = 2.0 * ((w*x) + (y*z)), 2.0 * ((w*y) - (z*x)), 2.0 * ((w*z) + (x*y))
        local cosX, cosZ = 1.0 - (2.0 * ((x*x) + (y*y))), 1.0 - (2.0 * ((y*y) + (z*z)))
        return imports.math.deg(imports.math.atan2(sinX, cosX)), imports.math.deg(math.asin(Clamp(sinY, -1.0, 1.0))), imports.math.deg(imports.math.atan2(sinZ, cosZ))
    end
}