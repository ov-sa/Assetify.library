----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: client.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Client Sided Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
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


--------------------------------------------
--[[ Function: Loads Asset Pack's Chunk ]]--
--------------------------------------------

function loadAssetPackChunk(chunkData)

    local loadState = false
    if chunkData and chunkData.type and chunkData.rwData.txd and chunkData.rwData.dff then
        rwModelID = imports.engineRequestModel(chunkData.type, chunkData.id)
        if rwModelID then
            local rwFiles = {}
            rwFiles.txd = (chunkData.rwData.txd and ((imports.isElement(chunkData.rwData.txd) and chunkData.rwData.txd) or imports.engineLoadTXD(chunkData.rwData.txd))) or false
            rwFiles.dff = (chunkData.rwData.dff and ((imports.isElement(chunkData.rwData.dff) and chunkData.rwData.dff) or imports.engineLoadDFF(chunkData.rwData.dff))) or false
            rwFiles.col = (chunkData.rwData.col and ((imports.isElement(chunkData.rwData.col) and chunkData.rwData.col) or imports.engineLoadCOL(chunkData.rwData.col))) or false
            if rwFiles.dff then
                if rwFiles.txd then
                    imports.engineImportTXD(rwFiles.txd, rwModelID)
                end
                imports.engineReplaceModel(rwFiles.dff, rwModelID)
                if rwFiles.col then
                    imports.engineReplaceCOL(rwFiles.col, rwModelID)
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
                outputChatBox("LOADED MODEL ID: "..rwModelID)
                chunkData.rwData.modelID = rwModelID
                chunkData.rwData.rwFiles = rwFiles
                loadState = true
            end
        end
    end
    return loadState

end