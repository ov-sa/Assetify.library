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

local module = {
    ["stringn"] = class:create("stringn", string),
    ["utf8n"] = class:create("utf8n", utf8),
    ["string"] = class:create("string", table.clone(utf8))
}
for i, j in imports.pairs(imports.string) do
    module.string.public[i] = (not module.string.public[i] and j) or module.string.public[i]
end

for i, j in pairs(module) do
    j.private.ref = imports.sha256("vStudio")

    function j.public.isVoid(baseString)
        if not baseString or (imports.type(baseString) ~= "string") then return false end
        return (not j.public.find(baseString, "[%S]") and true) or false
    end
    
    local raw_len = j.public.len
    function j.public.len(baseString)
        if not baseString or (imports.type(baseString) ~= "string") then return false end
        return raw_len(baseString)
    end
    
    function j.public.parse(baseString)
        if not baseString then return false end
        if imports.tostring(baseString) == "nil" then return
        elseif imports.tostring(baseString) == "false" then return false
        elseif imports.tostring(baseString) == "true" then return true
        else return imports.tonumber(baseString) or baseString end
    end
    
    function j.public.parseHex(baseString)
        if not baseString then return false end
        baseString = j.public.gsub(baseString, "#", "")
        return imports.tonumber("0x"..j.public.sub(baseString, 1, 2)) or 0, imports.tonumber("0x"..j.public.sub(baseString, 3, 4)) or 0, imports.tonumber("0x"..j.public.sub(baseString, 5, 6)) or 0
    end
    
    function j.public.formatTime(milliseconds)
        milliseconds = imports.tonumber(milliseconds)
        if not milliseconds then return false end
        milliseconds = math.floor(milliseconds)
        local totalSeconds = math.floor(milliseconds/1000)
        local seconds = totalSeconds%60
        local minutes = math.floor(totalSeconds/60)
        local hours = math.floor(minutes/60)
        minutes = minutes%60
        return j.format("%02d:%02d:%02d", hours, minutes, seconds)
    end
    
    function j.public.encode(baseString, type, options)
        if not baseString or (imports.type(baseString) ~= "string") then return false end
        return imports.encodeString(type, baseString, options)
    end
    
    function j.public.decode(baseString, type, options, clipNull)
        if not baseString or (imports.type(baseString) ~= "string") then return false end
        baseString = imports.decodeString(type, baseString, options)
        return (baseString and clipNull and j.public.gsub(baseString, j.public.char(0), "")) or baseString
    end
    
    function j.public.split(baseString, separator)
        if not baseString or (imports.type(baseString) ~= "string") or not separator or (imports.type(separator) ~= "string") then return false end
        local result = {}
        local index = 1
        local length = j.public.len(separator)
        while(true) do
            local ref = j.public.find(baseString, separator, index, true)
            if not ref then
                table.insert(result, j.public.sub(baseString, index))
                break
            end
            table.insert(result, j.public.sub(baseString, index, ref - 1))
            index = ref + length
        end 
        return result
    end

    function j.public.kern(baseString, kerner)
        if not baseString or (imports.type(baseString) ~= "string") then return false end
        return j.public.sub(j.public.gsub(baseString, ".", (kerner or " ").."%0"), 2)
    end
    
    function j.public.detab(baseString)
        if not baseString or (imports.type(baseString) ~= "string") then return false end
        return j.public.gsub(baseString, "\t", "    ")
    end
    
    function j.public.minify(baseString)
        if not baseString or (imports.type(baseString) ~= "string") then return false end
        baseString = j.public.gsub(baseString, "%-%-%[%[(.-)%]%]", "") --Removes single-line comments
        baseString = j.public.gsub(baseString, "%-%-.-\n", "") --Removes multi-line comments
        do
            --Encodes strings into bytes
            local index, key, result = 1, false, [[
                local function vsdk_processbyte(byte)
                    local result = ""
                    for num in ]]..i..[[.gmatch(byte, "(%d+):") do
                        result = result..]]..i..[[.char(num)
                    end
                    return result
                end
            ]]
            repeat
                local rw = j.public.sub(baseString, index, index)
                local isEscaped = j.public.sub(baseString, index - 1, index - 1) == "\\"
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
                        result = result..j.public.byte(rw)..":"
                    end
                end
                index = index + 1
            until(index > #baseString)
            baseString = result
        end
        baseString = j.public.gsub(baseString, "\n", " ") --Removes newlines
        baseString = j.public.gsub(baseString, "%s+$", "") --Removes trailing spaces
        baseString = j.public.gsub(baseString, "%s+", " ") --Removes trailing spaces
        return baseString
    end
end