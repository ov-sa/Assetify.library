----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: sandbox: filesystem.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: File System Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    collectgarbage = collectgarbage,
    fileExists = fileExists,
    fileCreate = fileCreate,
    fileDelete = fileDelete,
    fileOpen = fileOpen,
    fileRead = fileRead,
    fileWrite = fileWrite,
    fileGetSize = fileGetSize,
    fileClose = fileClose,
    pathIsDirectory = pathIsDirectory,
    pathListDir = pathListDir
}


---------------------
--[[ Class: File ]]--
---------------------

local file = class:create("file")
file.public.validPointers = {
    rootDir = "~/",
    localDir = "@/"
}

function file.public:exists(path)
    if not path or (imports.type(path) ~= "string") then return false end
    return imports.fileExists(path) or false
end

function file.public:delete(path)
    if not file.public:exists(path) then return false end
    return imports.fileDelete(path)
end

function file.public:read(path)
    if not file.public:exists(path) then return false end
    local cFile = imports.fileOpen(path, true)
    if not cFile then return false end
    local size = imports.fileGetSize(cFile)
    local data = imports.fileRead(cFile, size)
    imports.fileClose(cFile)
    return data, size
end

function file.public:write(path, data)
    if not path or (imports.type(path) ~= "string") or not data then return false end
    local cFile = imports.fileCreate(path)
    if not cFile then return false end
    imports.fileWrite(cFile, data)
    imports.fileClose(cFile)
    data = nil
    imports.collectgarbage("step", 1)
    return true
end

function file.public:deleteDir(path)
    if not path or (imports.type(path) ~= "string") or not imports.pathIsDirectory(path) then return false end
    for i, j in imports.pairs(imports.pathListDir(path)) do
        j = path.."/"..j
        if imports.pathIsDirectory(j) then
            file.public:deleteDir(j)
        else
            file.public:delete(j)
        end
    end
    return true
end

function file.public:parseURL(path)
    if not path or (imports.type(path) ~= "string") then return false end
    local extension = string.match(path, "^.+%.(.+)$")
    extension = (extension and string.match(extension, "%w") and extension) or false
    local pointer, pointerEndN = nil, nil
    for i, j in imports.pairs(file.public.validPointers) do
        local startN, endN = string.find(path, j)
        if startN and endN and (startN == 1) then
            pointer, pointerEndN = i, endN + 1
            break
        end
    end
    local url = string.sub(path, pointerEndN or 1, string.len(path) - ((extension and (string.len(extension) + 1)) or 0))
    if string.match(url, "%w") then
        local result = {
            pointer = pointer or false,
            url = (extension and (url.."."..extension)) or url,
            extension = extension,
            directory = string.match(url, "(.*[/\\])") or false
        }
        result.file = (result.extension and string.sub(result.url, (result.directory and (string.len(result.directory) + 1)) or 1)) or false
        return result
    end
    return false
end

function file.public:resolveURL(path, chroot)
    if not path or (imports.type(path) ~= "string") or (chroot and (imports.type(chroot) ~= "string")) then return false end
    local result = file.public:parseURL(path)
    if not result then return false end
    result.url = (result.pointer and string.gsub(result.url, file.public.validPointers[(result.pointer)], "")) or result.url
    local dirs = string.split(result.url, "/")
    if table.length(dirs) > 0 then
        if chroot then
            chroot = file.public:parseURL(((string.sub(chroot, string.len(chroot)) ~= "/") and chroot.."/") or chroot)
            chroot = (chroot and chroot.pointer and string.gsub(chroot.url, file.public.validPointers[(chroot.pointer)], "")) or chroot
        end
        result.url = false
        local __dirs = {}
        for i = 1, table.length(dirs), 1 do
            local j = dirs[i]
            if j == "..." then
                if not chroot or (chroot ~= result.url) then
                    table.remove(__dirs, table.length(__dirs))
                end
            else
                table.insert(__dirs, j)
            end
            result.url = table.concat(__dirs, "/")
            local __result = file.public:parseURL(result.url)
            result.url = (__result and not __result.file and result.url.."/") or result.url
        end
        result.url = ((result.pointer and file.public.validPointers[(result.pointer)]) or "")..(result.url or "")
    end
    return result.url
end