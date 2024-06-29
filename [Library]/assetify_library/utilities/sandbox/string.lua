----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: sandbox: string.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: String Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    sha256 = sha256,
    tostring = tostring,
    tonumber = tonumber,
    loadstring = loadstring,
    string = string,
    encodeString = encodeString,
    decodeString = decodeString
}


-----------------------
--[[ Class: String ]]--
-----------------------

local string = class:create("string", utf8)
for i, j in imports.pairs(imports.string) do
    string.public[i] = (not string.public[i] and j) or string.public[i]
end
string.private.ref = imports.sha256("vStudio")

function string.public.isVoid(baseString)
    if not baseString or (imports.type(baseString) ~= "string") then return false end
    baseString = string.public.gsub(baseString, "[\n\r\t%s]", "")
    return (not string.public.match(baseString, "[%W%w]") and true) or false
end

local __string_len = string.public.len
function string.public.len(baseString)
    if not baseString or (imports.type(baseString) ~= "string") then return false end
    return __string_len(baseString)
end

function string.public.parse(baseString)
    if not baseString then return false end
    if imports.tostring(baseString) == "nil" then return
    elseif imports.tostring(baseString) == "false" then return false
    elseif imports.tostring(baseString) == "true" then return true
    else return imports.tonumber(baseString) or baseString end
end

function string.public.parseHex(baseString)
    if not baseString then return false end
    baseString = string.public.gsub(baseString, "#", "")
    return imports.tonumber("0x"..string.public.sub(baseString, 1, 2)) or 0, imports.tonumber("0x"..string.public.sub(baseString, 3, 4)) or 0, imports.tonumber("0x"..string.public.sub(baseString, 5, 6)) or 0
end

function string.public.formatTime(milliseconds)
    milliseconds = imports.tonumber(milliseconds)
    if not milliseconds then return false end
    milliseconds = math.floor(milliseconds)
    local totalSeconds = math.floor(milliseconds/1000)
    local seconds = totalSeconds%60
    local minutes = math.floor(totalSeconds/60)
    local hours = math.floor(minutes/60)
    minutes = minutes%60
    return imports.string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

function string.public.encode(baseString, type, options)
    if not baseString or (imports.type(baseString) ~= "string") then return false end
    return imports.encodeString(type, baseString, options)
end

function string.public.decode(baseString, type, options, clipNull)
    if not baseString or (imports.type(baseString) ~= "string") then return false end
    baseString = imports.decodeString(type, baseString, options)
    return (baseString and clipNull and string.public.gsub(baseString, string.public.char(0), "")) or baseString
end

function string.public.split(baseString, separator)
    if not baseString or (imports.type(baseString) ~= "string") or not separator or (imports.type(separator) ~= "string") then return false end
    baseString = baseString..string.public.match(separator, separator)
    local result = {}
    for matchValue in string.public.gmatch(baseString, "(.-)"..separator) do
        table.insert(result, matchValue)
    end
    return result
end

function string.public.kern(baseString, kerner)
    if not baseString or (imports.type(baseString) ~= "string") then return false end
    return string.public.sub(string.public.gsub(baseString, ".", (kerner or " ").."%0"), 2)
end

function string.public.detab(baseString)
    if not baseString or (imports.type(baseString) ~= "string") then return false end
    return string.public.gsub(baseString, "\t", "    ")
end

function string.public.minify(baseString)
    if not baseString or (imports.type(baseString) ~= "string") then return false end
    baseString = string.public.gsub(baseString, "%-%-%[%[(.-)%]%]", "") --Removes single-line comments
    baseString = string.public.gsub(baseString, "%-%-.-\n", "") --Removes multi-line comments
    do
        --Encodes strings into bytes
        local index, key, result = 1, false, [[
            local function vsdk_processbyte(byte)
                local result = ""
                for num in string.gmatch(byte, "(%d+):") do
                    result = result..string.char(num)
                end
                return result
            end
        ]]
        repeat
            local rw = string.public.sub(baseString, index, index)
            local isEscaped = string.public.sub(baseString, index - 1, index - 1) == "\\"
            if not key then
                if not isEscaped and ((rw == "\"") or (rw == "\'")) then
                    key = rw
                    result = result.."vsdk_processbyte(\""
                else
                    result = result..rw
                end
            else
                if not isEscaped and (key == rw) then
                    key = false
                    result = result.."\")"
                else
                    result = result..string.public.byte(rw)..":"
                end
            end
            index = index + 1
        until(index > #baseString)
        baseString = result
    end
    baseString = string.public.gsub(baseString, "\n", " ") --Removes newlines
    baseString = string.public.gsub(baseString, "%s+$", "") --Removes trailing spaces
    baseString = string.public.gsub(baseString, "%s+", " ") --Removes trailing spaces
    return baseString
end