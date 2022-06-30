----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: file.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Table Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    tonumber = tonumber,
    select = select,
    unpack = unpack,
    table = table
}


----------------------
--[[ Class: Table ]]--
----------------------

local table = class:create("table", table)

 function table.public:pack(...)
    return {__T = {
        length = imports.select("#", ...)
    }, ...}
end

function table.public:unpack(baseTable)
    return imports.unpack(baseTable, 1, (baseTable.__T and baseTable.__T.length) or #baseTable)
end

function table.public:clone(baseTable, isRecursive)
    if not baseTable or (imports.type(baseTable) ~= "table") then return false end
    local __baseTable = {}
    for i, j in imports.pairs(baseTable) do
        if (imports.type(j) == "table") and isRecursive then
            __baseTable[i] = table.public:clone(j, isRecursive)
        else
            __baseTable[i] = j
        end
    end
    return __baseTable
end

function table.public:concat(...)
    return imports.table.concat(...)
end

function table.public:insert(baseTable, index, value, isForced)
    if not baseTable or (imports.type(baseTable) ~= "table") then return false end
    if index and (isForced or (value ~= nil)) then
        index = imports.tonumber(index)
        if not index then return false end
    else
        value, index = index, nil
    end
    baseTable.__T = baseTable.__T or {}
    baseTable.__T.length = baseTable.__T.length or #baseTable
    index = index or (baseTable.__T.length + 1)
    if (index <= 0) or (index > (baseTable.__T.length + 1)) then return false end
    if index <= baseTable.__T.length then
        for i = baseTable.__T.length, index, -1 do
            baseTable[(i + 1)] = baseTable[i]
            baseTable[i] = nil
        end
    end
    baseTable[index] = value
    baseTable.__T.length = baseTable.__T.length + 1
    return true
end

function table.public:remove(baseTable, index)
    index = imports.tonumber(index)
    if not baseTable or (imports.type(baseTable) ~= "table") or not index then return false end
    baseTable.__T = baseTable.__T or {}
    baseTable.__T.length = baseTable.__T.length or #baseTable
    if (index <= 0) or (index > baseTable.__T.length) then return false end
    baseTable[index] = nil
    if index < baseTable.__T.length then
        for i = index + 1, baseTable.__T.length, 1 do
            baseTable[(i - 1)] = baseTable[i]
            baseTable[i] = nil
        end
    end
    baseTable.__T.length = baseTable.__T.length - 1
    return true
end

unpack = function(...) table.public:unpack(...) end