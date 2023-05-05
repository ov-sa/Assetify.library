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
    bool = {["true"] = true, ["false"] = true},
    string = {["`"] = "template", ["'"] = true, ["\""] = true}
}

function vcl.private.fetchRW(rw, index) return string.sub(rw, index, index) end
function vcl.private.fetchLine(rw, index)
    local rwLines = string.split(string.sub(rw, 0, index), vcl.private.types.newline)
    local rwLine = math.max(1, table.length(rwLines))
    return rwLine, rwLines[rwLine] or ""
end

function vcl.private.parseComment(parser, buffer, rw)
    if (not parser.isType or parser.isTypeParsed) and (rw == vcl.private.types.comment) then
        local rwLine, rwLineText = vcl.private.fetchLine(string.sub(buffer, 0, parser.ref))
        local rwLines = string.split(buffer, vcl.private.types.newline)
        parser.ref = parser.ref - #rwLineText + #rwLines[rwLine] + 1
    end
    return true
end

function vcl.private.parseBoolean(parser, buffer, rw)
    if not parser.isType or (parser.isType == "bool") then
        for i, j in imports.pairs(vcl.private.types.bool) do
            if string.sub(buffer, parser.ref, parser.ref + #i - 1) == i then
                parser.ref, parser.value, parser.isType, parser.isTypeParsed, parser.isValueSkipAppend = parser.ref + #i - 1, i, "bool", true, true
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
                    parser.ref, parser.value, parser.isType, parser.isTypeChar, parser.isValueSkipAppend = parser.ref - #parser.value - 1, "", "object", nil, nil, true
                elseif (vcl.private.fetchRW(buffer, parser.ref + 1) ~= vcl.private.types.space) and (vcl.private.fetchRW(buffer, parser.ref + 1) ~= vcl.private.types.newline) then return false
                else
                    parser.isTypeParsed, parser.isValueSkipAppend = true, true
                    if vcl.private.types.string[rw] == "template" then
                        local queryValue = ""
                        local startIndex, endIndex = string.find(parser.value, "${", startIndex)
                        queryValue = string.sub(parser.value, 0, (startIndex and (startIndex - 1)) or #parser.value)
                        while(startIndex) do
                            endIndex = string.find(parser.value, "}", startIndex)
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
                            startIndex, endIndex = string.find(parser.value, "${", endIndex)
                            queryValue = queryValue..imports.tostring(templateValue)..string.sub(parser.value, queryIndex, (startIndex and (startIndex - 1)) or #parser.value)
                        end
                        parser.value = queryValue
                    end
                end
            end
        end
    end
    return true
end

function vcl.private.parseObject(parser, buffer, rw)
    if parser.isType == "object" then
        parser.isValueSkipAppend = true
        if string.isVoid(parser.index) and (rw == vcl.private.types.list) then parser.isTypeID = parser.ref
        elseif (parser.isTypeQuoted or (rw ~= vcl.private.types.space)) and (rw ~= vcl.private.types.newline) and (rw ~= vcl.private.types.init) then
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
            local rwTypePadding = (parser.isTypeID and (parser.ref - parser.isTypeID - 1)) or 0
            local rwIndexPadding = #rwLineText - #parser.index - rwTypePadding - 1
            if parser.isChild and (rwIndexPadding <= parser.padding) then
                parser.ref, parser.isParsed = parser.ref - #parser.index - rwTypePadding, true
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
        elseif (parser.isType == "number") then parser.value = imports.tonumber(parser.value) end
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
    local result, indexes = "", {numeric = {}, index = {}}
    for i, j in imports.pairs(buffer) do
        if imports.type(j) == "table" then
            table.insert(((imports.type(i) == "number") and indexes.numeric) or indexes.index, i)
        else
            if imports.type(i) == "number" then i = "-"..imports.tostring(i)
            elseif not string.isVoid(string.gsub(i, "%w", "")) then i = "\""..i.."\"" end
            if imports.type(j) == "string" then j = "\""..j.."\"" end
            result = result..vcl.private.types.newline..padding..i..vcl.private.types.init..vcl.private.types.space..imports.tostring(j)
        end
    end
    table.sort(indexes.numeric, function(a, b) return a < b end)
    for i = 1, table.length(indexes.numeric), 1 do
        local j = indexes.numeric[i]
        result = result..vcl.private.types.newline..padding..vcl.private.types.list..j..vcl.private.types.init..vcl.private.encode(buffer[j], padding..vcl.private.types.tab)
    end
    for i = 1, table.length(indexes.index), 1 do
        local j = indexes.index[i]
        result = result..vcl.private.types.newline..padding..j..vcl.private.types.init..vcl.private.encode(buffer[j], padding..vcl.private.types.tab)
    end
    return result
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
    buffer = (not parser.isChild and (string.gsub(string.detab(buffer), vcl.private.types.carriageline, "")..(((vcl.private.fetchRW(buffer, #buffer) ~= vcl.private.types.newline) and (buffer..vcl.private.types.newline)) or ""))) or buffer
    while(parser.ref <= #buffer) do
        vcl.private.parseComment(parser, buffer, vcl.private.fetchRW(buffer, parser.ref))
        local ref, isType = parser.ref, parser.isType
        parser.isValueSkipAppend = nil
        parser.isErrored = (parser.isChild and (not vcl.private.parseBoolean(parser, buffer, vcl.private.fetchRW(buffer, parser.ref)) or not vcl.private.parseNumber(parser, buffer, vcl.private.fetchRW(buffer, parser.ref)) or not vcl.private.parseString(parser, buffer, vcl.private.fetchRW(buffer, parser.ref))) and (parser.isErrored or 1)) or parser.isErrored
        if parser.isType then
            if not isType then
                local _, rwLineText = vcl.private.fetchLine(string.sub(buffer, 0, ref - 1))
                if #rwLineText <= parser.padding then parser.isType, parser.isErrored = false, 1 end
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
    end
    parser.isParsed = (not parser.isErrored and (((parser.isType == "object") and not parser.isTypeID and string.isVoid(parser.index)) or parser.isParsed) and true) or false
    return vcl.private.parseReturn(parser, buffer)
end
function vcl.public.decode(buffer) return vcl.private.decode(buffer) end

addEventHandler("onResourceStart", root, function()
local testCode = [[
"indexA": #DADADA
    "indexA": true #DADADA
    "indexC'@@@": 3131 #DADADA
    indexB: "WEW" #DADADA
    "indexAdada": true #DADADA
    wewA: #DADADA
        lol: "xD" #DADADA
        -: "Hello" #DADADA
            -: #DADADA
                -: "World" #DADADA
                -5: "xDD" #DADADA
]]

testCode = vcl.public.encode(vcl.public.decode(testCode))
print("\n==============================")
print(testCode)
end)