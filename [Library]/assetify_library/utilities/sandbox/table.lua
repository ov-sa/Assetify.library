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
    tostring = tostring,
    tonumber = tonumber,
    toJSON = toJSON,
    fromJSON = fromJSON,
    vcl = vcl,
    select = select,
    unpack = unpack,
    print = print,
    getmetatable = getmetatable,
    loadstring = loadstring
}
vcl = nil


----------------------
--[[ Class: Table ]]--
----------------------

local table = class:create("table", table)
table.private.inspectTypes = {
    raw = {
        ["nil"] = true,
        ["string"] = true,
        ["number"] = true,
        ["boolean"] = true
    }
}

function table.public.length(baseTable)
    if not baseTable or (imports.type(baseTable) ~= "table") then return false end
    return (baseTable.__T and baseTable.__T.length) or #baseTable
end

function table.public.pack(...)
    return {__T = {
        length = imports.select("#", ...)
    }, ...}
end

function table.public.unpack(baseTable)
    if not baseTable or (imports.type(baseTable) ~= "table") then return false end
    return imports.unpack(baseTable, 1, table.public.length(baseTable))
end

function table.public.encode(baseTable, encoding)
    if not baseTable or (imports.type(baseTable) ~= "table") then return false end
    if encoding == "json" then return imports.toJSON(baseTable)
    else return imports.vcl.encode(baseTable) end
end

function table.public.decode(baseString, encoding)
    if not baseString or (imports.type(baseString) ~= "string") then return false end
    if encoding == "json" then return imports.fromJSON(baseString)
    else return imports.vcl.decode(baseString) end
end

function table.public.clone(baseTable, isRecursive)
    if not baseTable or (imports.type(baseTable) ~= "table") then return false end
    local __baseTable = {}
    for i, j in imports.pairs(baseTable) do
        if (imports.type(j) == "table") and isRecursive then
            __baseTable[i] = table.public.clone(j, isRecursive)
        else
            __baseTable[i] = j
        end
    end
    return __baseTable
end

function table.private.inspect(baseTable, showHidden, limit, level, buffer, skipTrim)
    local dataType = imports.type(baseTable)
    showHidden, limit, level, buffer = (showHidden and true) or false, math.max(1, imports.tonumber(limit) or 0) + 1, math.max(1, imports.tonumber(level) or 0), buffer or table.public.pack()
    if (dataType ~= "table") then
        table.public.insert(buffer, ((table.private.inspectTypes.raw[dataType] and (((dataType == "string") and string.format("%q", baseTable)) or imports.tostring(baseTable))) or ("<"..imports.tostring(baseTable)..">")).."\n")
    elseif level > limit then
        table.public.insert(buffer, "{...}\n")
    else
        table.public.insert(buffer, "{\n")
        local indent = string.rep(" ", 2*level)
        for k, v in imports.pairs(baseTable) do
            table.public.insert(buffer, indent..imports.tostring(k)..": ")
            table.private.inspect(v, showHidden, limit, level + 1, buffer, true)
        end
        if showHidden then
            local metadata = imports.getmetatable(baseTable)
            if metadata then
                table.public.insert(buffer, indent.."<metadata>: ")
                table.private.inspect(metadata, showHidden, limit, level + 1, buffer, true)
            end
        end
        indent = string.rep(" ", 2*(level - 1))
        table.public.insert(buffer, indent.."}\n")
    end
    if not skipTrim then table.public.remove(buffer) end
    return table.public.concat(buffer)
end
function table.public.inspect(...) return table.private.inspect(table.public.unpack(table.public.pack(...), 3)) end 

function table.public.print(...)
    return imports.print(table.public.inspect(...))
end

function table.public.keys(baseTable)
    if not baseTable or (imports.type(baseTable) ~= "table") then return false end
    local indexCache, __baseTable = {}, {}
    for i, j in imports.pairs(baseTable) do
        if i ~= "__T" then
            indexCache[i] = true
            table.public.insert(__baseTable, i)
        end
    end
    for i = 1, table.public.length(baseTable), 1 do
        if not indexCache[i] then
            table.public.insert(__baseTable, i)
        end
    end
    return __baseTable
end

function table.public.insert(baseTable, index, value, isForced)
    if not baseTable or (imports.type(baseTable) ~= "table") then return false end
    if index and (isForced or (value ~= nil)) then
        index = imports.tonumber(index)
        if not index then return false end
    else
        value, index = index, nil
    end
    baseTable.__T = baseTable.__T or {}
    baseTable.__T.length = table.public.length(baseTable)
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

function table.public.remove(baseTable, index)
    index = imports.tonumber(index)
    if not baseTable or (imports.type(baseTable) ~= "table") or not index then return false end
    baseTable.__T = baseTable.__T or {}
    baseTable.__T.length = table.public.length(baseTable)
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

function table.public.forEach(baseTable, exec)
    if not baseTable or (imports.type(baseTable) ~= "table") or not exec or (imports.type(exec) ~= "function") then return false end
    for i = 1, table.public.length(baseTable), 1 do
        exec(i, baseTable[i])
    end
    return true
end

unpack = function(...) return table.public.unpack(...) end
inspect = function(...) return table.public.inspect(...) end
iprint = function(...) return imports.print(table.public.inspect(...)) end
