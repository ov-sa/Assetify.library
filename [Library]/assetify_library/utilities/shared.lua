----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shared.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Shared Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    fileExists = fileExists,
    fileOpen = fileOpen,
    fileRead = fileRead,
    fileGetSize = fileGetSize,
    fileClose = fileClose
}


---------------------------------------
--[[ Function: Fetches File's Data ]]--
---------------------------------------

function fetchFileData(filePath)

    if not filePath or not imports.fileExists(filePath) then return false end
    local file = imports.fileOpen(filePath, true)
    if not file then return false end

    local fileData = imports.fileRead(file, imports.fileGetSize(file))
    imports.fileClose(file)
    return fileData

end


---------------------------------
--[[ Functions: Clones Table ]]--
---------------------------------

function table.clone(recievedTable, isRecursiveMode)

    if not recievedTable or imports.type(recievedTable) ~= "table" then return false end

    local clonedTable = {}
    for i, j in imports.pairs(recievedTable) do
        if imports.type(j) == "table" and isRecursiveMode then
            clonedTable[i] = table.clone(j, true)
        else
            clonedTable[i] = j
        end
    end
    return clonedTable

end