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
    init = ":",
    comment = "#",
    tab = "\t",
    space = " ",
    newline = "\n",
    carriageline = "\r",
    list = "-",
    negative = "-",
    decimal = ".",
    bool = {
        ["true"] = "true",
        ["false"] = "false"
    },
    string = {
        ["`"] = true,
        ["'"] = true,
        ["\""] = true
    }
}

function vcl.private.isVoid(rw) return (not string.find(rw, "%w") and true) or false end
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
                parser.ref, parser.isType, parser.value, parser.isValueSkipAppend, parser.isTypeParsed = parser.ref + #i - 1, "bool", i, true, true
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
            elseif not parser.isTypeFloat and parser.isTypeNegative and ((vcl.private.isVoid(parser.index) and (rw == vcl.private.types.space)) or (rw == vcl.private.types.init)) then
                parser.ref, parser.index, parser.isType, parser.isTypeFloat, parser.isTypeNegative = parser.isTypeNegative - 1, "", "object", nil, nil
            elseif not parser.isTypeParsed then
                if not vcl.private.isVoid(parser.value) and ((vcl.private.fetchRW(buffer, parser.ref + 1) == vcl.private.types.space) or (vcl.private.fetchRW(buffer, parser.ref + 1) == vcl.private.types.newline)) then parser.isTypeParsed = true
                elseif not isNumber then return false end
            end
        end
    end
    return true
end

function vcl.private.parseString(parser, buffer, rw)
    if not parser.isType or (parser.isType == "string") then
        if (not parser.isTypeChar and vcl.private.types.string[rw]) or parser.isTypeChar then
            if not parser.isType then parser.isValueSkipAppend, parser.isType, parser.isTypeChar = true, "string", rw
            elseif not parser.isTypeParsed and (rw == parser.isTypeChar) then parser.isValueSkipAppend, parser.isTypeParsed = true, true end
        end
    end
    return true
end

function vcl.private.parseObject(parser, buffer, rw, isChild)
    if parser.isType == "object" then
        parser.isValueSkipAppend = true
        if vcl.private.isVoid(parser.index) and (rw == vcl.private.types.list) then parser.isTypeID = parser.ref
        elseif not vcl.private.isVoid(rw) then parser.index = parser.index..rw
        elseif rw == vcl.private.types.init then
            parser.index = (parser.isTypeID and vcl.private.isVoid(parser.index) and imports.tostring(table.length(parser.pointer) + 1)) or parser.index
            if vcl.private.isVoid(parser.index) or ((vcl.private.fetchRW(buffer, parser.ref + 1) ~= vcl.private.types.space) and (vcl.private.fetchRW(buffer, parser.ref + 1) ~= vcl.private.types.newline)) then return false end
            local _, rwLineText = vcl.private.fetchLine(string.sub(buffer, 0, parser.ref))
            local rwTypePadding = (parser.isTypeID and (parser.ref - parser.isTypeID - 1)) or 0
            local rwIndexPadding = #rwLineText - #parser.index - rwTypePadding - 1
            if isChild then
                parser.padding = parser.padding or (rwIndexPadding - 1)
                if rwIndexPadding <= parser.padding then
                    parser.ref, parser.isParsed = parser.ref - #parser.index - rwTypePadding, true
                    return true
                end
            end
            if parser.isTypeID then parser.isTypeID, parser.index = false, imports.tonumber(parser.index) end
            if parser.index then
                local value, ref, isErrored = vcl.private.decode(buffer, parser.ref + 1, rwIndexPadding, true)
                if not isErrored then parser.pointer[(parser.index)], parser.ref, parser.index = value, ref - 1, ""
                else parser.isErrored = 0 end
            else parser.isErrored = 1 end
            if parser.isErrored then return false end
        end
    end
    return true
end

function vcl.private.parseReturn(parser, buffer)
    parser.isParsed = (not parser.isErrored and (((parser.isType == "object") and not parser.isTypeID and vcl.private.isVoid(parser.index)) or parser.isParsed) and true) or false
    if not parser.isParsed then
        if not parser.isErrored or (parser.isErrored == 1) then
            parser.errorMsg = string.format(parser.errorMsg, vcl.private.fetchLine(buffer, parser.ref), (parser.isType and ("Malformed "..parser.isType)) or "Invalid declaration")
            imports.outputDebugString(parser.errorMsg)
        end
        return false, false, true
    elseif (parser.isType == "object") then return parser.pointer, parser.ref
    elseif (parser.isType == "bool") then return ((parser.value == "true") and true) or false, parser.ref
    else return ((parser.isType == "number" and imports.tonumber(parser.value)) or parser.value), parser.ref end
end

function vcl.private.encode(buffer, padding)
    if not buffer or (imports.type(buffer) ~= "table") then return false end
    padding = padding or ""
    local result, indexes = "", {numeric = {}, index = {}}
    for i, j in imports.pairs(buffer) do
        if imports.type(j) == "table" then
            table.insert(((imports.type(i) == "number") and indexes.numeric) or indexes.index, i)
        else
            i = ((imports.type(i) == "number") and "- "..imports.tostring(i)) or i
            if imports.type(j) == "string" then j = "\""..j.."\"" end
            result = result..vcl.private.types.newline..padding..i..vcl.private.types.init..vcl.private.types.space..imports.tostring(j)
        end
    end
    table.sort(indexes.numeric, function(a, b) return a < b end)
    for i = 1, table.length(indexes.numeric), 1 do
        local j = indexes.numeric[i]
        result = result..vcl.private.types.newline..padding..vcl.private.types.list..vcl.private.types.space..j..vcl.private.types.init..vcl.private.encode(buffer[j], padding..vcl.private.types.tab)
    end
    for i = 1, table.length(indexes.index), 1 do
        local j = indexes.index[i]
        result = result..vcl.private.types.newline..padding..j..vcl.private.types.init..vcl.private.encode(buffer[j], padding..vcl.private.types.tab)
    end
    return result
end
function vcl.public.encode(buffer) return vcl.private.encode(buffer) end

function vcl.private.decode(buffer, ref, padding, isChild)
    if not buffer or (imports.type(buffer) ~= "string") then return false end
    if string.isVoid(buffer) then return {} end
    local parser = {
        ref = ref or 1, padding = padding,
        index = "", pointer = {}, value = "",
        errorMsg = "Failed to decode vcl. [Line: %s] [Reason: %s]"
    }
    buffer = (not isChild and (string.gsub(string.detab(buffer), vcl.private.types.carriageline, "")..vcl.private.types.newline)) or buffer
    while(parser.ref <= #buffer) do
        vcl.private.parseComment(parser, buffer, vcl.private.fetchRW(buffer, parser.ref))
        parser.isValueSkipAppend = nil
        parser.isErrored = (isChild and (not vcl.private.parseBoolean(parser, buffer, vcl.private.fetchRW(buffer, parser.ref)) or not vcl.private.parseNumber(parser, buffer, vcl.private.fetchRW(buffer, parser.ref)) or not vcl.private.parseString(parser, buffer, vcl.private.fetchRW(buffer, parser.ref))) and (parser.isErrored or 1)) or parser.isErrored
        if parser.isType then
            parser.isErrored = (parser.isTypeParsed and not parser.__isParsed and (vcl.private.fetchRW(buffer, parser.ref + 1) ~= vcl.private.types.space) and (vcl.private.fetchRW(buffer, parser.ref + 1) ~= vcl.private.types.newline) and (parser.isErrored or 1)) or parser.isErrored
            if not parser.isErrored then
                if parser.__isParsed then
                    parser.isParsed = vcl.private.fetchRW(buffer, parser.ref) == vcl.private.types.newline
                    parser.isErrored = ((vcl.private.fetchRW(buffer, parser.ref) ~= vcl.private.types.space) and (vcl.private.fetchRW(buffer, parser.ref) ~= vcl.private.types.newline) and (parser.isErrored or 1)) or parser.isErrored
                end
                parser.value = (not parser.__isParsed and not parser.isValueSkipAppend and (parser.value..vcl.private.fetchRW(buffer, parser.ref))) or parser.value
                parser.__isParsed = parser.isTypeParsed
            end
        end
        parser.isType = (not parser.isType and ((vcl.private.fetchRW(buffer, parser.ref) == vcl.private.types.list) or not vcl.private.isVoid(vcl.private.fetchRW(buffer, parser.ref))) and "object") or parser.isType
        parser.isErrored = (not vcl.private.parseObject(parser, buffer, vcl.private.fetchRW(buffer, parser.ref), isChild) and (parser.isErrored or 1)) or parser.isErrored
        if parser.isErrored or parser.isParsed then break end
        parser.ref = parser.ref + 1
    end
    return vcl.private.parseReturn(parser, buffer)
end
function vcl.public.decode(buffer) return vcl.private.decode(buffer) end