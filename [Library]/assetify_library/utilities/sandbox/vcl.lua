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
    bool = {
        ["true"] = true,
        ["false"] = true
    },
    string = {
        ["`"] = {
            isTemplate = {"${", "}"}
        },
        ["'"] = true,
        ["\""] = true
    },
    color = {"rgba(", ")"}
}

function vcl.private.fetchRW(rw, index) return string.sub(rw, index, index) end
function vcl.private.fetchLine(rw, index)
    local rwLines = string.split(string.sub(rw, 0, index), vcl.private.types.newline)
    local rwLine = math.max(1, table.length(rwLines))
    return rwLine, rwLines[rwLine] or ""
end

function vcl.private.parseComment(parser, buffer, rw)
    if (not parser.isType or parser.isTypeParsed or ((parser.isType == "object") and not parser.isTypeID and string.isVoid(parser.index))) and (rw == vcl.private.types.comment) then
        local rwLine, rwLineText = vcl.private.fetchLine(string.sub(buffer, 0, parser.ref))
        local rwLines = string.split(buffer, vcl.private.types.newline)
        parser.ref = parser.ref - string.len(rwLineText) + string.len(rwLines[rwLine]) + 1
    end
    return true
end

function vcl.private.parseBoolean(parser, buffer, rw)
    if not parser.isType or (parser.isType == "bool") then
        for i, j in imports.pairs(vcl.private.types.bool) do
            if string.sub(buffer, parser.ref, parser.ref + string.len(i) - 1) == i then
                parser.ref, parser.value, parser.isType, parser.isTypeParsed, parser.isValueSkipAppend = parser.ref + string.len(i) - 1, i, "bool", true, true
                if (vcl.private.fetchRW(buffer, parser.ref + 1) ~= vcl.private.types.space) and (vcl.private.fetchRW(buffer, parser.ref + 1) ~= vcl.private.types.newline) then return false end
                break
            end
        end
    end
    return true
end

function vcl.private.parseNumber(parser, buffer, rw)
    if not parser.isType or (parser.isType == "number") then
        local isNumber = imports.tonumber(rw)
        if not parser.isType then
            local isNegative = rw == vcl.private.types.negative
            if isNegative or isNumber then parser.isType, parser.isTypeNegative = "number", (isNegative and parser.ref) or false end
            if isNumber and ((vcl.private.fetchRW(buffer, parser.ref + 1) == vcl.private.types.space) or (vcl.private.fetchRW(buffer, parser.ref + 1) == vcl.private.types.newline)) then parser.isTypeParsed = true end
        else
            if rw == vcl.private.types.decimal then
                if not parser.isTypeFloat then parser.isTypeFloat = true
                else return false end
            elseif not parser.isTypeFloat and parser.isTypeNegative and (rw == vcl.private.types.init) then
                parser.ref, parser.index, parser.value, parser.isType, parser.isTypeFloat, parser.isTypeNegative, parser.isValueSkipAppend = parser.isTypeNegative - 1, "", "", "object", nil, nil, true
            elseif not parser.isTypeParsed then
                if not isNumber then return false
                elseif not string.isVoid(parser.value) and ((vcl.private.fetchRW(buffer, parser.ref + 1) == vcl.private.types.space) or (vcl.private.fetchRW(buffer, parser.ref + 1) == vcl.private.types.newline)) then parser.isTypeParsed = true end
            end
        end
    end
    return true
end

function vcl.private.parseString(parser, buffer, rw)
    if not parser.isType or (parser.isType == "string") then
        if (not parser.isTypeChar and vcl.private.types.string[rw]) or parser.isTypeChar then
            if not parser.isType then parser.isValueSkipAppend, parser.isType, parser.isTypeChar = true, "string", rw
            elseif not parser.isTypeParsed and (rw == parser.isTypeChar) then
                if vcl.private.fetchRW(buffer, parser.ref + 1) == vcl.private.types.init then
                    parser.ref, parser.value, parser.isType, parser.isTypeChar, parser.isValueSkipAppend = parser.ref - string.len(parser.value) - 1, "", "object", nil, nil, true
                elseif (vcl.private.fetchRW(buffer, parser.ref + 1) ~= vcl.private.types.space) and (vcl.private.fetchRW(buffer, parser.ref + 1) ~= vcl.private.types.newline) then return false
                else
                    parser.isTypeParsed, parser.isValueSkipAppend = true, true
                    if vcl.private.types.string[rw] and (imports.type(vcl.private.types.string[rw]) == "table") and vcl.private.types.string[rw].isTemplate then
                        local queryValue = ""
                        local startIndex, endIndex = string.find(parser.value, vcl.private.types.string[rw].isTemplate[1], startIndex)
                        queryValue = string.sub(parser.value, 0, (startIndex and (startIndex - 1)) or string.len(parser.value))
                        while(startIndex) do
                            endIndex = string.find(parser.value, vcl.private.types.string[rw].isTemplate[2], startIndex)
                            if not endIndex then return false end
                            local queryIndex = endIndex + 1
                            local templateIndex, templateValue = string.split(string.sub(parser.value, startIndex + 2, endIndex - 1), "["..vcl.private.types.index.."]"), parser.root
                            for i = 1, #templateIndex, 1 do
                                local j = templateIndex[i]
                                if (imports.type(templateValue) == "table") and (templateValue[j] ~= nil) then templateValue = templateValue[j]
                                else
                                    templateValue = nil
                                    break
                                end
                            end
                            startIndex, endIndex = string.find(parser.value, vcl.private.types.string[rw].isTemplate[1], endIndex)
                            queryValue = queryValue..imports.tostring(templateValue)..string.sub(parser.value, queryIndex, (startIndex and (startIndex - 1)) or string.len(parser.value))
                        end
                        parser.value = queryValue
                    end
                end
            end
        end
    end
    return true
end

function vcl.private.parseColor(parser, buffer, rw)
    if not parser.isType or (parser.isType == "color") then
        if not parser.isType then
            if string.sub(buffer, parser.ref, parser.ref + string.len(vcl.private.types.color[1]) - 1) == vcl.private.types.color[1] then
                parser.ref, parser.isType, parser.isTypeColor, parser.isValueSkipAppend = parser.ref + string.len(vcl.private.types.color[1]) - 1, "color", {}, true
            end
        elseif not parser.isTypeParsed and (rw ~= vcl.private.types.space) then
            parser.isValueSkipAppend = true
            local isNumber = imports.tonumber(rw)
            parser.isTypeColor.queryIndex = parser.isTypeColor.queryIndex or 1
            if rw == "," then
                if not parser.isTypeColor[(parser.isTypeColor.queryIndex)] or string.isVoid(parser.isTypeColor[(parser.isTypeColor.queryIndex)]) then return false end
                parser.isTypeColor.queryIndex = parser.isTypeColor.queryIndex + 1
            elseif rw == vcl.private.types.color[2] then
                if (parser.isTypeColor.queryIndex < 3) then return false
                elseif (vcl.private.fetchRW(buffer, parser.ref + 1) ~= vcl.private.types.space) and (vcl.private.fetchRW(buffer, parser.ref + 1) ~= vcl.private.types.newline) then return false end
                for i = 1, 4, 1 do
                    parser.isTypeColor[i] = imports.tonumber(parser.isTypeColor[i]) or 255
                    if (parser.isTypeColor[i] < 0) or (parser.isTypeColor[i] > 255) then return false end
                end
                parser.value, parser.isTypeParsed = parser.isTypeColor, true
            elseif isNumber then parser.isTypeColor[(parser.isTypeColor.queryIndex)] = (parser.isTypeColor[(parser.isTypeColor.queryIndex)] or "")..rw
            else return false end
        end
    end
    return true
end

function vcl.private.parseObject(parser, buffer, rw)
    if parser.isType == "object" then
        parser.isValueSkipAppend = true
        if string.isVoid(parser.index) and (rw == vcl.private.types.list) then parser.isTypeID = parser.ref
        elseif (parser.isTypeQuoted or (rw ~= vcl.private.types.space)) and (rw ~= vcl.private.types.newline) and (parser.isTypeQuoted or (rw ~= vcl.private.types.init)) then
            if not vcl.private.types.string[rw] and not parser.isTypeQuoted and not string.find(rw, "%w") then return false end
            if not vcl.private.types.string[rw] or (parser.isTypeQuoted and (parser.isTypeQuoted ~= rw)) then parser.index = parser.index..rw
            else
                if not parser.isTypeQuoted then parser.isTypeQuoted = rw
                elseif parser.isTypeQuoted == rw then
                    parser.isTypeQuoted = false
                    if vcl.private.fetchRW(buffer, parser.ref + 1) ~= vcl.private.types.init then return false end
                end
            end
        elseif rw == vcl.private.types.init then
            parser.pointer = parser.pointer or {}
            parser.index = (parser.isTypeID and string.isVoid(parser.index) and imports.tostring(table.length(parser.pointer) + 1)) or parser.index
            if string.isVoid(parser.index) or ((vcl.private.fetchRW(buffer, parser.ref + 1) ~= vcl.private.types.space) and (vcl.private.fetchRW(buffer, parser.ref + 1) ~= vcl.private.types.newline)) then return false end
            local _, rwLineText = vcl.private.fetchLine(string.sub(buffer, 0, parser.ref))
            local rwIndexPadding = string.len(rwLineText) - string.len(parser.index) - 1 - ((parser.isTypeID and #vcl.private.types.list) or 0)
            if parser.isChild and (rwIndexPadding <= parser.padding) then
                parser.ref, parser.isParsed = parser.ref - string.len(parser.index), true
            else
                if parser.isTypeID then parser.index, parser.isTypeID = imports.tonumber(parser.index), false end
                if parser.index then
                    local value, ref, isErrored = vcl.private.decode(buffer, parser.root, parser.ref + 1, rwIndexPadding)
                    if not isErrored then
                        if not parser.isChild then parser.root[(parser.index)] = value end
                        parser.pointer[(parser.index)], parser.ref, parser.index = value, ref - 1, ""
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
        if (parser.isType == "object") then parser.value = parser.pointer
        elseif (parser.isType == "bool") then parser.value = ((parser.value == "true") and true) or false
        elseif (parser.isType == "number") then parser.value = imports.tonumber(parser.value)
        elseif (parser.isType == "color") then parser.value = string.format("#%.2X%.2X%.2X%.2X", parser.value[1], parser.value[2], parser.value[3], parser.value[4]) end
    else
        parser.value = false
        if not parser.isErrored or (parser.isErrored == 1) then
            parser.errorMsg = string.format(parser.errorMsg, vcl.private.fetchLine(buffer, parser.ref), (parser.isType and ("Malformed "..parser.isType)) or "Invalid declaration")
            imports.outputDebugString(parser.errorMsg)
        end
    end
    return parser.value, parser.ref, not parser.isParsed, parser.root
end

function vcl.private.encode(buffer, padding)
    if not buffer or (imports.type(buffer) ~= "table") then return false end
    padding = padding or ""
    local index, result = {static = {numeric = {}, string = {}}, numeric = {}, string = {}}, ""
    for i, j in imports.pairs(buffer) do
        local rwType = imports.type(i)
        if imports.type(j) == "table" then
            table.insert(((rwType == "number") and index.numeric) or index.string, i)
        else
            if rwType == "number" then i = "-"..imports.tostring(i)
            elseif not string.isVoid(string.gsub(i, "%w", "")) then i = "\""..i.."\"" end
            if imports.type(j) == "string" then j = "\""..j.."\"" end
            table.insert(((rwType == "number") and index.static.numeric) or index.static.string, {i, j})
        end
    end
    local areStaticIndexVoid, areNestedIndexVoid = table.length(index.static.numeric) + table.length(index.static.string), table.length(index.numeric) + table.length(index.string)
    if (areStaticIndexVoid > 0) or (areNestedIndexVoid > 0) then
        table.sort(index.static.numeric, function(a, b) return a[1] < b[1] end)
        table.sort(index.numeric, function(a, b) return a < b end)
        for i = 1, table.length(index.static.numeric), 1 do
            local j = index.static.numeric[i]
            result = result..((not string.isVoid(result) and vcl.private.types.newline) or "")..padding..j[1]..vcl.private.types.init..vcl.private.types.space..imports.tostring(j[2])
        end
        for i = 1, table.length(index.numeric), 1 do
            local j = index.numeric[i]
            local __result = vcl.private.encode(buffer[j], padding..vcl.private.types.tab)
            if not __result then areNestedIndexVoid = areNestedIndexVoid - 1
            else result = result..((not string.isVoid(result) and vcl.private.types.newline) or "")..padding..vcl.private.types.list..j..vcl.private.types.init..__result end
        end
        for i = 1, table.length(index.static.string), 1 do
            local j = index.static.string[i]
            result = result..((not string.isVoid(result) and vcl.private.types.newline) or "")..padding..j[1]..vcl.private.types.init..vcl.private.types.space..imports.tostring(j[2])
        end
        for i = 1, table.length(index.string), 1 do
            local j = index.string[i]
            local __result = vcl.private.encode(buffer[j], padding..vcl.private.types.tab)
            if not __result then areNestedIndexVoid = areNestedIndexVoid - 1
            else result = result..((not string.isVoid(result) and vcl.private.types.newline) or "")..padding..j..vcl.private.types.init..vcl.private.encode(buffer[j], padding..vcl.private.types.tab) end
        end
    end
    return (((areStaticIndexVoid > 0) or (areNestedIndexVoid > 0)) and result) or false
end
function vcl.public.encode(buffer) return vcl.private.encode(buffer) end

function vcl.private.decode(buffer, root, ref, padding)
    if not buffer or (imports.type(buffer) ~= "string") then return false end
    if string.isVoid(buffer) then return {} end
    local parser = {
        root = root or {}, ref = ref or 1, isChild = (root and true) or false,
        index = "", value = "", padding = padding or 0,
        errorMsg = "Failed to decode vcl. [Line: %s] [Reason: %s]"
    }
    if not parser.isChild then
        buffer = string.gsub(string.detab(buffer), vcl.private.types.carriageline, "")
        buffer = ((vcl.private.fetchRW(buffer, string.len(buffer)) ~= vcl.private.types.newline) and buffer..vcl.private.types.newline) or buffer
    end
    while(parser.ref <= string.len(buffer)) do
        vcl.private.parseComment(parser, buffer, vcl.private.fetchRW(buffer, parser.ref))
        local ref, isType = parser.ref, parser.isType
        parser.isValueSkipAppend = nil
        parser.isErrored = (parser.isChild and (not vcl.private.parseBoolean(parser, buffer, vcl.private.fetchRW(buffer, parser.ref)) or not vcl.private.parseNumber(parser, buffer, vcl.private.fetchRW(buffer, parser.ref)) or not vcl.private.parseString(parser, buffer, vcl.private.fetchRW(buffer, parser.ref)) or not vcl.private.parseColor(parser, buffer, vcl.private.fetchRW(buffer, parser.ref))) and (parser.isErrored or 1)) or parser.isErrored
        if parser.isType then
            if not isType then
                local _, rwLineText = vcl.private.fetchLine(string.sub(buffer, 0, ref - 1))
                if string.len(rwLineText) <= parser.padding then parser.isType, parser.isErrored = false, 1 end
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
        parser.isType = (not parser.isType and not parser.isErrored and ((vcl.private.fetchRW(buffer, parser.ref) == vcl.private.types.list) or not string.isVoid(vcl.private.fetchRW(buffer, parser.ref))) and "object") or parser.isType
        parser.isErrored = (not parser.isErrored and not vcl.private.parseObject(parser, buffer, vcl.private.fetchRW(buffer, parser.ref)) and (parser.isErrored or 1)) or parser.isErrored
        if parser.isErrored or parser.isParsed then break end
        parser.ref = parser.ref + 1
        local currentThread = thread:getThread()
        if currentThread and currentThread.syncRate.executions and currentThread.syncRate.frames then thread:pause() end
    end
    parser.isParsed = (not parser.isErrored and (((parser.isType == "object") and not parser.isTypeID and string.isVoid(parser.index)) or parser.isParsed) and true) or false
    return vcl.private.parseReturn(parser, buffer)
end
function vcl.public.decode(buffer) return vcl.private.decode(buffer) end