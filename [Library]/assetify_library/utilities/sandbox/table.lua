----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: sandbox: table.lua
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
    toJSON = toJSON,
    fromJSON = fromJSON,
    select = select,
    unpack = unpack
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
    if not baseTable or (imports.type(baseTable) ~= "table") then return false end
    return imports.unpack(baseTable, 1, (baseTable.__T and baseTable.__T.length) or #baseTable)
end

function table.public:encode(baseTable)
    return (baseTable and (imports.type(baseTable) == "table") and imports.toJSON(baseTable)) or false
end

function table.public:decode(baseString)
    return (baseString and (imports.type(baseString) == "string") and imports.fromJSON(baseString)) or false
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

local __table_concat = table.concat
function table.public:concat(baseTable, separator, startIndex, endIndex)
    return __table_concat(baseTable, separator, startIndex, endIndex)
end

function table.public:keys(baseTable)
    if not baseTable or (imports.type(baseTable) ~= "table") then return false end
    local indexCache, __baseTable = {}, {}
    for i, j in imports.pairs(baseTable) do
        if i ~= "__T" then
            indexCache[i] = true
            table.public:insert(__baseTable, i)
        end
    end
    for i = 1, (baseTable.__T and baseTable.__T.length) or #baseTable, 1 do
        if not indexCache[i] then
            table.public:insert(__baseTable, i)
        end
    end
    return __baseTable
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

function table.public:forEach(baseTable, exec)
    if not baseTable or (imports.type(baseTable) ~= "table") or not exec or (imports.type(exec) ~= "function") then return false end
    for i = 1, (baseTable.__T and baseTable.__T.length) or #baseTable, 1 do
        exec(i, baseTable[i])
    end
    return true
end

unpack = function(...) table.public:unpack(...) end