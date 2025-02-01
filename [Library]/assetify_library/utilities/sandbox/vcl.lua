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

function vcl.private.fetchRW(parser, rw, index)
    return parser.encoder.sub(rw, index, index)
end

function vcl.private.fetchRef(parser, rw, index)
    return parser.encoder.find(rw, "[%S"..vcl.private.types.newline.."]", index)
end

function vcl.private.fetchLine(parser, rw, index)
    local lines = parser.encoder.split(parser.encoder.sub(rw, 0, index), vcl.private.types.newline)
    local line = math.max(1, table.length(lines))
    return line, lines[line] or ""
end

function vcl.private.fetchBuffer(parser, rw, line)
    local lines = parser.encoder.split(parser.encoder.sub(rw, 0, index), vcl.private.types.newline)
    return parser.encoder.len(table.concat(lines, vcl.private.types.newline, 1, line))
end

function vcl.private.isEOL(parser, rw, index)
    local char = parser.encoder.sub(rw, index, index)
    return (((char == vcl.private.types.space) or (char == vcl.private.types.newline)) and true) or false
end

function vcl.private.parseComment(parser, buffer, rw)
    if (not parser.type or parser.isTypeParsed or ((parser.type == "object") and not parser.isTypeID and parser.encoder.isVoid(parser.index))) and (rw == vcl.private.types.comment) then
        local line, lineText = vcl.private.fetchLine(parser, buffer, parser.ref)
        local lines = parser.encoder.split(buffer, vcl.private.types.newline)
        parser.ref = parser.ref - parser.encoder.len(lineText) + parser.encoder.len(lines[line]) + 1
    end
    return true
end

function vcl.private.parseBoolean(parser, buffer, rw)
    if not parser.type or (parser.type == "bool") then
        for i = 1, table.length(vcl.private.types.bool) do
            local j = tostring(vcl.private.types.bool[i])
            if parser.encoder.sub(buffer, parser.ref, parser.ref + parser.encoder.len(j) - 1) == j then
                parser.ref, parser.value, parser.type, parser.isTypeParsed = parser.ref + parser.encoder.len(j) - 1, j, "bool", true
                if not vcl.private.isEOL(parser, buffer, parser.ref + 1) then return false end
                break
            end
        end
    end
    return true
end

function vcl.private.parseNumber(parser, buffer, rw)
    if not parser.type or (parser.type == "number") then
        if imports.tonumber(rw) or (rw == vcl.private.types.negative) then
            parser.type = "number"
            local matchIndex = parser.encoder.find(buffer, "[^%d%"..vcl.private.types.decimal.."]+", parser.ref + 1)
            if not matchIndex or (vcl.private.fetchLine(parser, buffer, parser.ref) ~= vcl.private.fetchLine(parser, buffer, matchIndex - 1)) then return false end
            local matchedValue = parser.encoder.sub(buffer, parser.ref, matchIndex - 1)
            parser.value = tonumber(matchedValue)
            parser.ref = matchIndex - 1
            if ((not parser.value and (matchedValue == vcl.private.types.list)) or (parser.value == math.floor(parser.value))) and (vcl.private.fetchRW(parser, buffer, parser.ref + 1) == vcl.private.types.init) then
                parser.ref, parser.index, parser.type, parser.isTypeID, parser.value = parser.ref + 1, (parser.value and parser.encoder.sub(parser.value, 2)) or "", "object", not parser.value or (parser.value < 0), ""
            elseif not parser.value then return false
            else
                parser.isTypeParsed = true
                if not vcl.private.isEOL(parser, buffer, parser.ref + 1) then return false end
            end
        end
    end
    return true
end

function vcl.private.parseString(parser, buffer, rw)
    if not parser.type and vcl.private.types.string[rw] then
        parser.type = "string"
        local matchIndex = parser.encoder.find(buffer, rw, parser.ref + 1)
        if not matchIndex or (vcl.private.fetchLine(parser, buffer, parser.ref) ~= vcl.private.fetchLine(parser, buffer, matchIndex)) then return false end
        parser.ref, parser.value = matchIndex, parser.encoder.sub(buffer, parser.ref + 1, matchIndex - 1)
        if vcl.private.fetchRW(parser, buffer, parser.ref + 1) == vcl.private.types.init then
            parser.ref, parser.index, parser.value, parser.type = parser.ref + 1, parser.value, "", "object"
        else
            parser.isTypeParsed = true
            if not vcl.private.isEOL(parser, buffer, parser.ref + 1) then return false end
            if imports.type(vcl.private.types.string[rw]) == "table" then
                local parseIndex = {parser.encoder.find(parser.value, vcl.private.types.string[rw][1])}
                local queryValue = parser.encoder.sub(parser.value, 0, (parseIndex[1] and (parseIndex[1] - 1)) or parser.encoder.len(parser.value))
                while(parseIndex[1]) do
                    parseIndex[2] = parser.encoder.find(parser.value, vcl.private.types.string[rw][2], parseIndex[1])
                    if not parseIndex[2] then return false end
                    local matchIndex = parseIndex[2] + 1
                    local templateIndex, templateValue = parser.encoder.split(parser.encoder.sub(parser.value, parseIndex[1] + 2, parseIndex[2] - 1), "["..vcl.private.types.index.."]"), parser.root
                    for i = 1, #templateIndex, 1 do
                        local j = templateIndex[i]
                        if (imports.type(templateValue) == "table") and (templateValue[j] ~= nil) then templateValue = templateValue[j]
                        else
                            templateValue = nil
                            break
                        end
                    end
                    parseIndex[1] = parser.encoder.find(parser.value, vcl.private.types.string[rw][1], parseIndex[2])
                    queryValue = queryValue..imports.tostring(templateValue)..parser.encoder.sub(parser.value, matchIndex, (parseIndex[1] and (parseIndex[1] - 1)) or parser.encoder.len(parser.value))
                end
                parser.value = queryValue
            end
        end
    end
    return true
end

function vcl.private.parseColor(parser, buffer, rw)
    if not parser.type or (parser.type == "color") then
        if not parser.type then
            if parser.encoder.sub(buffer, parser.ref, parser.ref + parser.encoder.len(vcl.private.types.color[1]) - 1) == vcl.private.types.color[1] then
                parser.ref, parser.type, parser.isTypeColor = parser.ref + parser.encoder.len(vcl.private.types.color[1]) - 1, "color", {}
            end
        elseif not parser.isTypeParsed and (rw ~= vcl.private.types.space) then
            local isNumber = imports.tonumber(rw)
            parser.isTypeColor.queryIndex = parser.isTypeColor.queryIndex or 1
            if rw == "," then
                if not parser.isTypeColor[parser.isTypeColor.queryIndex] or parser.encoder.isVoid(parser.isTypeColor[parser.isTypeColor.queryIndex]) then return false end
                parser.isTypeColor.queryIndex = parser.isTypeColor.queryIndex + 1
            elseif rw == vcl.private.types.color[2] then
                if parser.isTypeColor.queryIndex < 3 then return false
                elseif not vcl.private.isEOL(parser, buffer, parser.ref + 1) then return false end
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
        if parser.encoder.isVoid(parser.index) and (rw == vcl.private.types.list) then
            local matchIndex = parser.encoder.find(buffer, "[^%d]+", parser.ref + 1)
            if not matchIndex or (vcl.private.fetchLine(parser, buffer, parser.ref) ~= vcl.private.fetchLine(parser, buffer, matchIndex - 1)) then return false end
            local matchedValue = parser.encoder.sub(buffer, parser.ref + 1, matchIndex - 1)
            if vcl.private.fetchRW(parser, buffer, matchIndex) ~= vcl.private.types.init then return false end
            parser.index, parser.isTypeID = tostring(matchedValue), parser.ref
            parser.ref = matchIndex
            vcl.private.parseObject(parser, buffer, vcl.private.fetchRW(parser, buffer, parser.ref))
        elseif (rw ~= vcl.private.types.space) and (rw ~= vcl.private.types.newline) and (rw ~= vcl.private.types.init) then
            if parser.encoder.isVoid(parser.index) and vcl.private.types.string[rw] then
                local matchIndex = parser.encoder.find(buffer, rw, parser.ref + 1)
                if not matchIndex or (vcl.private.fetchLine(parser, buffer, parser.ref) ~= vcl.private.fetchLine(parser, buffer, matchIndex)) then return false end
                parser.index = parser.encoder.sub(buffer, parser.ref + 1, matchIndex - 1)
                parser.ref = matchIndex
                parser.isTypeQuoted = true
                if vcl.private.fetchRW(parser, buffer, parser.ref + 1) ~= vcl.private.types.init then return false end
                parser.ref = parser.ref + 1
                vcl.private.parseObject(parser, buffer, vcl.private.fetchRW(parser, buffer, parser.ref))
            else
                if not parser.encoder.find(rw, "%w") then return false end
                parser.index = parser.index..rw
            end
        elseif rw == vcl.private.types.init then
            parser.pointer = parser.pointer or {}
            parser.index = (parser.isTypeID and parser.encoder.isVoid(parser.index) and imports.tostring(table.length(parser.pointer) + 1)) or parser.index
            if parser.encoder.isVoid(parser.index) or not vcl.private.isEOL(parser, buffer, parser.ref + 1) then return false end
            local _, lineText = vcl.private.fetchLine(parser, buffer, parser.ref)
            local linePadding = parser.encoder.len(lineText) - parser.encoder.len(parser.index) - 1 - ((parser.isTypeQuoted and 2) or 0) - ((parser.isTypeID and #vcl.private.types.list) or 0)
            parser.isTypeQuoted = nil
            if parser.child and (linePadding <= parser.next.padding) then
                parser.ref, parser.isParsed = parser.ref - parser.encoder.len(lineText) + linePadding, true
            else
                if parser.isTypeID then parser.index, parser.isTypeID = imports.tonumber(parser.index), false end
                if parser.index then
                    local next = (parser.next and table.clone(parser.next, true)) or {}
                    parser.ref = parser.encoder.find(buffer, "[%S]", parser.ref + 1) - 1
                    next.buffer_temp = parser.encoder.sub(buffer, 0, parser.ref + 1)
                    next.ref_temp = vcl.private.fetchBuffer(parser, next.buffer_temp, vcl.private.fetchLine(parser, next.buffer_temp) - 1)
                    next.ref = next.ref + next.ref_temp
                    next.buffer_temp = parser.encoder.sub(buffer, next.ref_temp + 1)
                    next.padding = linePadding
                    local value, ref, isErrored = vcl.private.decode(next.buffer_temp, parser.root, next, parser.ref - next.ref_temp + 1, parser.encoder)
                    if not isErrored then
                        if not parser.child then parser.root[parser.index] = value end
                        parser.pointer[parser.index], parser.ref, parser.index = value, ref + next.ref_temp - 1, ""
                    else parser.isErrored = 0 end
                else parser.isErrored = 1 end
                if parser.isErrored then return false end
            end
        elseif parser.isTypeID or not parser.encoder.isVoid(parser.index) then return false end
    end
    return true
end

function vcl.private.parseReturn(parser, buffer)
    if parser.isParsed then
        if (parser.type == "object") then parser.value = parser.pointer
        elseif (parser.type == "bool") then parser.value = ((parser.value == "true") and true) or false
        elseif (parser.type == "number") then parser.value = imports.tonumber(parser.value)
        elseif (parser.type == "color") then parser.value = parser.encoder.format("#%.2X%.2X%.2X%.2X", parser.value[1], parser.value[2], parser.value[3], parser.value[4]) end
    else
        parser.value = false
        if not parser.isErrored or (parser.isErrored == 1) then
            parser.error = parser.encoder.format(parser.error, vcl.private.fetchLine(parser, parser.next.buffer, parser.ref + parser.next.ref), (parser.type and ("Malformed "..parser.type)) or "Invalid declaration")
            imports.outputDebugString(parser.error)
        end
    end
    return parser.value, parser.ref, not parser.isParsed, parser.root
end

function vcl.private.encode(buffer, root, padding, encoder)
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
            local value = vcl.private.encode(j[2], true, padding..vcl.private.types.tab, encoder)
            if not value then count.nested = count.nested - 1
            else result = result..vcl.private.types.newline..padding..j[1]..vcl.private.types.init..value end
        end
        for i = 1, table.length(query.static.string), 1 do
            local j = query.static.string[i]
            result = result..vcl.private.types.newline..padding..j[1]..vcl.private.types.init..vcl.private.types.space..imports.tostring(j[2])
        end
        for i = 1, table.length(query.string), 1 do
            local j = query.string[i]
            local value = vcl.private.encode(j[2], true, padding..vcl.private.types.tab, encoder)
            if not value then count.nested = count.nested - 1
            else result = result..vcl.private.types.newline..padding..j[1]..vcl.private.types.init..value end
        end
    end
    if not root then
        if (count.static + count.nested) <= 0 then return result
        else result = encoder.match(result, "^\n*(.*)") or result end
    end
    return (((count.static + count.nested) > 0) and result) or false
end
function vcl.public.encode(buffer, encoding) return vcl.private.encode(buffer, false, false, ((encoding == "utf8") and string) or stringn) end

function vcl.private.decode(buffer, root, next, ref, encoder)
    if not buffer or (imports.type(buffer) ~= "string") then return false end
    local parser = {
        root = root or {},
        next = next or {},
        ref = ref or 1,
        index = "", value = "",
        encoder = encoder,
        child = (root and true) or false,
        error = "Failed to decode vcl. [Line: %s] [Reason: %s]"
    }
    if parser.encoder.isVoid(buffer) then return {} end
    parser.next.buffer = parser.next.buffer or buffer
    parser.next.ref = parser.next.ref or 0
    parser.next.padding = parser.next.padding or 0
    if not parser.child then
        buffer = parser.encoder.gsub(parser.encoder.detab(buffer), vcl.private.types.carriageline, "")
        buffer = ((vcl.private.fetchRW(parser, buffer, parser.encoder.len(buffer)) ~= vcl.private.types.newline) and buffer..vcl.private.types.newline) or buffer
    end
    while(parser.ref <= parser.encoder.len(buffer)) do
        parser.ref = ((not parser.type or ((parser.type == "object") and parser.encoder.isVoid(parser.index))) and vcl.private.fetchRef(parser, buffer, parser.ref)) or parser.ref
        vcl.private.parseComment(parser, buffer, vcl.private.fetchRW(parser, buffer, parser.ref))
        local ref, type = parser.ref, parser.type
        parser.isErrored = (parser.child and (not vcl.private.parseBoolean(parser, buffer, vcl.private.fetchRW(parser, buffer, parser.ref)) or not vcl.private.parseNumber(parser, buffer, vcl.private.fetchRW(parser, buffer, parser.ref)) or not vcl.private.parseString(parser, buffer, vcl.private.fetchRW(parser, buffer, parser.ref)) or not vcl.private.parseColor(parser, buffer, vcl.private.fetchRW(parser, buffer, parser.ref))) and (parser.isErrored or 1)) or parser.isErrored
        if parser.type then
            if not type then
                local _, lineText = vcl.private.fetchLine(parser, buffer, ref - 1)
                if parser.encoder.len(lineText) <= parser.next.padding then parser.type, parser.isErrored = false, 1 end
            end
            if not parser.isErrored and parser.isTypeParsed then
                parser.ref = vcl.private.fetchRef(parser, buffer, parser.ref + 1)
                parser.isParsed = vcl.private.fetchRW(parser, buffer, parser.ref) == vcl.private.types.newline
                parser.isErrored = (not parser.isParsed and (parser.isErrored or 1)) or parser.isErrored
                parser.ref = parser.ref + 1
            end
        end
        parser.type = (not parser.type and not parser.isErrored and ((vcl.private.fetchRW(parser, buffer, parser.ref) == vcl.private.types.list) or not parser.encoder.isVoid(vcl.private.fetchRW(parser, buffer, parser.ref))) and "object") or parser.type
        parser.isErrored = (not parser.isErrored and not vcl.private.parseObject(parser, buffer, vcl.private.fetchRW(parser, buffer, parser.ref)) and (parser.isErrored or 1)) or parser.isErrored
        if parser.isErrored or parser.isParsed then break end
        parser.ref = parser.ref + 1
        if thread:getThread() and thread:getThread().syncRate.executions and thread:getThread().syncRate.frames then thread:pause() end
    end
    parser.isParsed = (not parser.isErrored and (((parser.type == "object") and not parser.isTypeID and parser.encoder.isVoid(parser.index)) or parser.isParsed) and true) or false
    return vcl.private.parseReturn(parser, buffer)
end
function vcl.public.decode(buffer, encoding) return vcl.private.decode(buffer, false, false, false, ((encoding == "utf8") and string) or stringn) end