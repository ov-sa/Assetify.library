----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: sandbox: vcl.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: VCL Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    tostring = tostring,
    tonumber = tonumber,
    outputDebugString = outputDebugString
}


--------------------
--[[ Class: VCL ]]--
--------------------

local vcl = class:create("vcl")
vcl.private.types = {
    comment = "#",
    tab = "\t",
    space = " ",
    newline = "\n",
    carriageline = "\r",
    list = "-",
    negative = "-",
    decimal = ".",
    index = ".",
    init = ":",
    bool = {true, false},
    string = {
        ["`"] = {"${", "}"},
        ["'"] = true,
        ["\""] = true
    },
    color = {"rgba(", ")"}
}

function vcl.private.fetchRW(rw, index) return string.sub(rw, index, index) end
function vcl.private.fetchLine(rw, index)
    local lines = string.split(string.sub(rw, 0, index), vcl.private.types.newline)
    local line = math.max(1, table.length(lines))
    return line, lines[line] or ""
end

function vcl.private.parseComment(parser, buffer, rw)
    if (not parser.type or parser.isTypeParsed or ((parser.type == "object") and not parser.isTypeID and string.isVoid(parser.index))) and (rw == vcl.private.types.comment) then
        local line, lineText = vcl.private.fetchLine(string.sub(buffer, 0, parser.ref))
        local lines = string.split(buffer, vcl.private.types.newline)
        parser.ref = parser.ref - string.len(lineText) + string.len(lines[line]) + 1
    end
    return true
end

function vcl.private.parseBoolean(parser, buffer, rw)
    if not parser.type or (parser.type == "bool") then
        for i = 1, table.length(vcl.private.types.bool) do
            local j = tostring(vcl.private.types.bool[i])
            if string.sub(buffer, parser.ref, parser.ref + string.len(j) - 1) == j then
                parser.ref, parser.value, parser.type, parser.isTypeParsed, parser.isValueSkipAppend = parser.ref + string.len(j) - 1, j, "bool", true, true
                if (vcl.private.fetchRW(buffer, parser.ref + 1) ~= vcl.private.types.space) and (vcl.private.fetchRW(buffer, parser.ref + 1) ~= vcl.private.types.newline) then return false end
                break
            end
        end
    end
    return true
end

function vcl.private.parseNumber(parser, buffer, rw)
    if not parser.type or (parser.type == "number") then
        local isNumber = imports.tonumber(rw)
        if not parser.type then
            if isNumber or (rw == vcl.private.types.negative) then parser.type, parser.isTypeNegative = "number", ((rw == vcl.private.types.negative) and parser.ref) or false end
            if isNumber and ((vcl.private.fetchRW(buffer, parser.ref + 1) == vcl.private.types.space) or (vcl.private.fetchRW(buffer, parser.ref + 1) == vcl.private.types.newline)) then parser.isTypeParsed = true end
        else
            if rw == vcl.private.types.decimal then
                if not parser.isTypeFloat then parser.isTypeFloat = true
                else return false end
            elseif not parser.isTypeFloat and parser.isTypeNegative and (rw == vcl.private.types.init) then
                parser.ref, parser.index, parser.value, parser.type, parser.isTypeFloat, parser.isTypeNegative, parser.isValueSkipAppend = parser.isTypeNegative - 1, "", "", "object", nil, nil, true
            elseif not parser.isTypeParsed then
                if not isNumber then return false
                elseif not string.isVoid(parser.value) and ((vcl.private.fetchRW(buffer, parser.ref + 1) == vcl.private.types.space) or (vcl.private.fetchRW(buffer, parser.ref + 1) == vcl.private.types.newline)) then parser.isTypeParsed = true end
            end
        end
    end
    return true
end

function vcl.private.parseString(parser, buffer, rw)
    if not parser.type and vcl.private.types.string[rw] then
        parser.type, parser.isValueSkipAppend = "string", true
        local matchIndex = string.find(buffer, rw, parser.ref + 1)
        if not matchIndex or (vcl.private.fetchLine(string.sub(buffer, 0, parser.ref)) ~= vcl.private.fetchLine(string.sub(buffer, 0, matchIndex))) then return false end
        parser.value = string.sub(buffer, parser.ref + 1, matchIndex - 1)
        parser.ref = matchIndex
        if vcl.private.fetchRW(buffer, parser.ref + 1) == vcl.private.types.init then
            parser.ref, parser.value, parser.type = parser.ref - string.len(parser.value) - 2, "", "object"
        elseif (vcl.private.fetchRW(buffer, parser.ref + 1) ~= vcl.private.types.space) and (vcl.private.fetchRW(buffer, parser.ref + 1) ~= vcl.private.types.newline) then return false
        else
            parser.isTypeParsed = true
            for i, j in pairs(vcl.private.types.string) do
                if type(j) == "table" then
                    local parseIndex = {string.find(parser.value, j[1])}
                    local queryValue = string.sub(parser.value, 0, (parseIndex[1] and (parseIndex[1] - 1)) or string.len(parser.value))
                    while(parseIndex[1]) do
                        parseIndex[2] = string.find(parser.value, j[2], parseIndex[1])
                        if not parseIndex[2] then return false end
                        local matchIndex = parseIndex[2] + 1
                        local templateIndex, templateValue = string.split(string.sub(parser.value, parseIndex[1] + 2, parseIndex[2] - 1), "["..vcl.private.types.index.."]"), parser.root
                        for i = 1, #templateIndex, 1 do
                            local j = templateIndex[i]
                            if (imports.type(templateValue) == "table") and (templateValue[j] ~= nil) then templateValue = templateValue[j]
                            else
                                templateValue = nil
                                break
                            end
                        end
                        parseIndex[1] = string.find(parser.value, j[1], parseIndex[2])
                        queryValue = queryValue..imports.tostring(templateValue)..string.sub(parser.value, matchIndex, (parseIndex[1] and (parseIndex[1] - 1)) or string.len(parser.value))
                    end
                    parser.value = queryValue
                end
            end
        end
    end
    return true
end

function vcl.private.parseColor(parser, buffer, rw)
    if not parser.type or (parser.type == "color") then
        if not parser.type then
            if string.sub(buffer, parser.ref, parser.ref + string.len(vcl.private.types.color[1]) - 1) == vcl.private.types.color[1] then
                parser.ref, parser.type, parser.isTypeColor, parser.isValueSkipAppend = parser.ref + string.len(vcl.private.types.color[1]) - 1, "color", {}, true
            end
        elseif not parser.isTypeParsed and (rw ~= vcl.private.types.space) then
            local isNumber = imports.tonumber(rw)
            parser.isValueSkipAppend = true
            parser.isTypeColor.queryIndex = parser.isTypeColor.queryIndex or 1
            if rw == "," then
                if not parser.isTypeColor[parser.isTypeColor.queryIndex] or string.isVoid(parser.isTypeColor[parser.isTypeColor.queryIndex]) then return false end
                parser.isTypeColor.queryIndex = parser.isTypeColor.queryIndex + 1
            elseif rw == vcl.private.types.color[2] then
                if parser.isTypeColor.queryIndex < 3 then return false
                elseif (vcl.private.fetchRW(buffer, parser.ref + 1) ~= vcl.private.types.space) and (vcl.private.fetchRW(buffer, parser.ref + 1) ~= vcl.private.types.newline) then return false end
                for i = 1, 4, 1 do
                    parser.isTypeColor[i] = imports.tonumber(parser.isTypeColor[i]) or 255
                    if (parser.isTypeColor[i] < 0) or (parser.isTypeColor[i] > 255) then return false end
                end
                parser.value, parser.isTypeParsed = parser.isTypeColor, true
            elseif isNumber then parser.isTypeColor[parser.isTypeColor.queryIndex] = (parser.isTypeColor[parser.isTypeColor.queryIndex] or "")..rw
            else return false end
        end
    end
    return true
end

function vcl.private.parseObject(parser, buffer, rw)
    if parser.type == "object" then
        parser.isValueSkipAppend = true
        if string.isVoid(parser.index) and (rw == vcl.private.types.list) then parser.isTypeID = parser.ref
        elseif (parser.isTypeQuoted or (rw ~= vcl.private.types.space)) and (rw ~= vcl.private.types.newline) and (parser.isTypeQuoted or (rw ~= vcl.private.types.init)) then
            if not vcl.private.types.string[rw] and not parser.isTypeQuoted and not string.find(rw, "%w") then return false end
            if not vcl.private.types.string[rw] or (parser.isTypeQuoted and (parser.isTypeQuoted ~= rw)) then parser.index = parser.index..rw
            else
                if not parser.isTypeQuoted then parser.isTypeQuoted = rw
                elseif parser.isTypeQuoted == rw then
                    parser.isTypeQuoted = nil
                    parser.wasTypeQuoted = true
                    if vcl.private.fetchRW(buffer, parser.ref + 1) ~= vcl.private.types.init then return false end
                end
            end
        elseif rw == vcl.private.types.init then
            parser.pointer = parser.pointer or {}
            parser.index = (parser.isTypeID and string.isVoid(parser.index) and imports.tostring(table.length(parser.pointer) + 1)) or parser.index
            if string.isVoid(parser.index) or ((vcl.private.fetchRW(buffer, parser.ref + 1) ~= vcl.private.types.space) and (vcl.private.fetchRW(buffer, parser.ref + 1) ~= vcl.private.types.newline)) then return false end
            local _, lineText = vcl.private.fetchLine(string.sub(buffer, 0, parser.ref))
            local rwIndexPadding = string.len(lineText) - string.len(parser.index) - 1 - ((parser.wasTypeQuoted and 2) or 0) - ((parser.isTypeID and #vcl.private.types.list) or 0)
            parser.wasTypeQuoted = nil
            if parser.child and (rwIndexPadding <= parser.padding) then
                parser.ref, parser.isParsed = parser.ref - string.len(lineText) + rwIndexPadding, true
            else
                if parser.isTypeID then parser.index, parser.isTypeID = imports.tonumber(parser.index), false end
                if parser.index then
                    local value, ref, isErrored = vcl.private.decode(buffer, parser.root, parser.ref + 1, rwIndexPadding)
                    if not isErrored then
                        if not parser.child then parser.root[(parser.index)] = value end
                        parser.pointer[(parser.index)], parser.ref, parser.index = value, ref - 1, ""
                        parser.isTypeQuoted = nil
                    else parser.isErrored = 0 end
                else parser.isErrored = 1 end
                if parser.isErrored then return false end
            end
        elseif parser.isTypeID or not string.isVoid(parser.index) then return false end 
    end
    return true
end

function vcl.private.parseReturn(parser, buffer)
    if parser.isParsed then
        if (parser.type == "object") then parser.value = parser.pointer
        elseif (parser.type == "bool") then parser.value = ((parser.value == "true") and true) or false
        elseif (parser.type == "number") then parser.value = imports.tonumber(parser.value)
        elseif (parser.type == "color") then parser.value = string.format("#%.2X%.2X%.2X%.2X", parser.value[1], parser.value[2], parser.value[3], parser.value[4]) end
    else
        parser.value = false
        if not parser.isErrored or (parser.isErrored == 1) then
            parser.error = string.format(parser.error, vcl.private.fetchLine(buffer, parser.ref), (parser.type and ("Malformed "..parser.type)) or "Invalid declaration")
            imports.outputDebugString(parser.error)
        end
    end
    return parser.value, parser.ref, not parser.isParsed, parser.root
end

function vcl.private.encode(buffer, root, padding)
    if not buffer or (imports.type(buffer) ~= "table") then return false end
    padding = padding or ""
    local query, result = {static = {numeric = {}, string = {}}, numeric = {}, string = {}}, ""
    for i, j in imports.pairs(buffer) do
        local rwType = imports.type(i)
        if rwType == "number" then i = vcl.private.types.list..imports.tostring(i)
        else i = "\""..i.."\"" end
        if imports.type(j) == "table" then
            table.insert(((rwType == "number") and query.numeric) or query.string, {i, j})
        else
            if imports.type(j) == "string" then j = "\""..j.."\"" end
            table.insert(((rwType == "number") and query.static.numeric) or query.static.string, {i, j})
        end
    end
    local count = {
        static = table.length(query.static.numeric) + table.length(query.static.string),
        nested = table.length(query.numeric) + table.length(query.string)
    }
    if (count.static > 0) or (count.nested > 0) then
        table.sort(query.static.numeric, function(a, b) return a[1] < b[1] end)
        table.sort(query.numeric, function(a, b) return a[1] < b[1] end)
        for i = 1, table.length(query.static.numeric), 1 do
            local j = query.static.numeric[i]
            result = result..vcl.private.types.newline..padding..j[1]..vcl.private.types.init..vcl.private.types.space..imports.tostring(j[2])
        end
        for i = 1, table.length(query.numeric), 1 do
            local j = query.numeric[i]
            local value = vcl.private.encode(j[2], true, padding..vcl.private.types.tab)
            if not value then count.nested = count.nested - 1
            else result = result..vcl.private.types.newline..padding..j[1]..vcl.private.types.init..value end
        end
        for i = 1, table.length(query.static.string), 1 do
            local j = query.static.string[i]
            result = result..vcl.private.types.newline..padding..j[1]..vcl.private.types.init..vcl.private.types.space..imports.tostring(j[2])
        end
        for i = 1, table.length(query.string), 1 do
            local j = query.string[i]
            local value = vcl.private.encode(j[2], true, padding..vcl.private.types.tab)
            if not value then count.nested = count.nested - 1
            else result = result..vcl.private.types.newline..padding..j[1]..vcl.private.types.init..value end
        end
    end
    if not root then
        if (count.static + count.nested) <= 0 then return result
        else result = string.match(result, "^\n*(.*)") or result end
    end
    return (((count.static + count.nested) > 0) and result) or false
end
function vcl.public.encode(buffer) return vcl.private.encode(buffer) end

function vcl.private.decode(buffer, root, ref, padding)
    if not buffer or (imports.type(buffer) ~= "string") then return false end
    if string.isVoid(buffer) then return {} end
    local parser = {
        root = root or {}, ref = ref or 1, child = (root and true) or false,
        index = "", value = "", padding = padding or 0,
        error = "Failed to decode vcl. [Line: %s] [Reason: %s]"
    }
    if not parser.child then
        buffer = string.gsub(string.detab(buffer), vcl.private.types.carriageline, "")
        buffer = ((vcl.private.fetchRW(buffer, string.len(buffer)) ~= vcl.private.types.newline) and buffer..vcl.private.types.newline) or buffer
    end
    while(parser.ref <= string.len(buffer)) do
        vcl.private.parseComment(parser, buffer, vcl.private.fetchRW(buffer, parser.ref))
        local ref, type = parser.ref, parser.type
        parser.isValueSkipAppend = nil
        parser.isErrored = (parser.child and (not vcl.private.parseBoolean(parser, buffer, vcl.private.fetchRW(buffer, parser.ref)) or not vcl.private.parseNumber(parser, buffer, vcl.private.fetchRW(buffer, parser.ref)) or not vcl.private.parseString(parser, buffer, vcl.private.fetchRW(buffer, parser.ref)) or not vcl.private.parseColor(parser, buffer, vcl.private.fetchRW(buffer, parser.ref))) and (parser.isErrored or 1)) or parser.isErrored
        if parser.type then
            if not type then
                local _, lineText = vcl.private.fetchLine(string.sub(buffer, 0, ref - 1))
                if string.len(lineText) <= parser.padding then parser.type, parser.isErrored = false, 1 end
            end
            if not parser.isErrored then
                if parser.__isParsed then
                    parser.isParsed = vcl.private.fetchRW(buffer, parser.ref) == vcl.private.types.newline
                    parser.isErrored = ((vcl.private.fetchRW(buffer, parser.ref) ~= vcl.private.types.space) and (vcl.private.fetchRW(buffer, parser.ref) ~= vcl.private.types.newline) and (parser.isErrored or 1)) or parser.isErrored
                end
                parser.value = (not parser.__isParsed and not parser.isValueSkipAppend and (parser.value..vcl.private.fetchRW(buffer, parser.ref))) or parser.value
                parser.__isParsed = parser.isTypeParsed
            end
        end
        parser.type = (not parser.type and not parser.isErrored and ((vcl.private.fetchRW(buffer, parser.ref) == vcl.private.types.list) or not string.isVoid(vcl.private.fetchRW(buffer, parser.ref))) and "object") or parser.type
        parser.isErrored = (not parser.isErrored and not vcl.private.parseObject(parser, buffer, vcl.private.fetchRW(buffer, parser.ref)) and (parser.isErrored or 1)) or parser.isErrored
        if parser.isErrored or parser.isParsed then break end
        parser.ref = parser.ref + 1
        if thread:getThread() and thread:getThread().syncRate.executions and thread:getThread().syncRate.frames then thread:pause() end
    end
    parser.isParsed = (not parser.isErrored and (((parser.type == "object") and not parser.isTypeID and string.isVoid(parser.index)) or parser.isParsed) and true) or false
    return vcl.private.parseReturn(parser, buffer)
end
function vcl.public.decode(buffer) return vcl.private.decode(buffer) end