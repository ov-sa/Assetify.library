----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: loader: client.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Library Loader ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    isElement = isElement,
    destroyElement = destroyElement,
    engineRequestModel = engineRequestModel,
    engineFreeModel = engineFreeModel,
    engineLoadTXD = engineLoadTXD,
    engineLoadDFF = engineLoadDFF,
    engineLoadCOL = engineLoadCOL,
    engineImportTXD = engineImportTXD,
    engineReplaceModel = engineReplaceModel,
    engineReplaceCOL = engineReplaceCOL
}


---------------------------------
--[[ Function: Loads Chunk's ]]--
---------------------------------

function loadChunk(chunkData, callback)

    local loadState = false
    if chunkData and chunkData.type and chunkData.rwData.txd and chunkData.rwData.dff then
        rwModelID = imports.engineRequestModel(chunkData.type, chunkData.id)
        if rwModelID then
            local rwFiles = {}
            rwFiles.txd = (imports.isElement(chunkData.rwData.txd) or imports.engineLoadTXD(chunkData.rwData.txd)) or false
            rwFiles.dff = (imports.isElement(chunkData.rwData.dff) or imports.engineLoadDFF(chunkData.rwData.dff)) or false
            rwFiles.col = (imports.isElement(chunkData.rwData.col) or imports.engineLoadCOL(chunkData.rwData.col)) or false
            if rwFiles.dff then
                if rwFiles.txd then
                    imports.engineImportTXD(rwModelID, rwFiles.txd)
                end
                imports.engineReplaceModel(rwModelID, rwFiles.dff)
                if rwFiles.col then
                    imports.engineReplaceCOL(rwModelID, rwFiles.col)
                end
            else
                imports.engineFreeModel(rwModelID)
                for i, j in imports.pairs(rwFiles) do
                    if j and imports.isElement(j) then
                        imports.destroyElement(j)
                    end
                end
                rwFiles = nil
            end
            if rwFiles then
                chunkData.rwData.modelID = rwModelID
                chunkData.rwData.rwFiles = rwFiles
                loadState = true
            end
        end
    end
    return loadState

end