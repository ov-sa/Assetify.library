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

local __string_gsub = string.public.gsub
function string.public.gsub(baseString, matchWord, replaceWord, matchLimit, isStrictcMatch, matchPrefix, matchPostfix)
    if not baseString or (imports.type(baseString) ~= "string") or not matchWord or (imports.type(matchWord) ~= "string") or not replaceWord or (imports.type(replaceWord) ~= "string") then return false end
    matchPrefix, matchPostfix = (matchPrefix and (imports.type(matchPrefix) == "string") and matchPrefix) or "", (matchPostfix and (imports.type(matchPostfix) == "string") and matchPostfix) or ""
    matchWord = (isStrictcMatch and "%f[^"..matchPrefix.."%z%s]"..matchWord.."%f["..matchPostfix.."%z%s]") or matchPrefix..matchWord..matchPostfix
    return __string_gsub(baseString, matchWord, replaceWord, matchLimit)
end

function string.public.encode(type, baseString, options)
    if not baseString or (imports.type(baseString) ~= "string") then return false end
    return imports.encodeString(type, baseString, options)
end

function string.public.decode(type, baseString, options, clipNull)
    if not baseString or (imports.type(baseString) ~= "string") then return false end
    baseString = imports.decodeString(type, baseString, options)
    return (baseString and clipNull and string.public.gsub(baseString, string.public.char(0), "")) or baseString
end

function string.public.split(baseString, separator)
    if not baseString or (imports.type(baseString) ~= "string") or not separator or (imports.type(separator) ~= "string") then return false end
    baseString = baseString..separator
    local result = {}
    for matchValue in string.public.gmatch(baseString, "(.-)"..separator) do
        if #string.public.gsub(matchValue, "%s", "") > 0 then
            table:insert(result, matchValue)
        end
    end
    return result
end