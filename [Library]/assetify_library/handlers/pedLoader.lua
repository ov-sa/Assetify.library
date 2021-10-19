----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: pedLoader.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Ped Loader ]]--
----------------------------------------------------------------


-------------------
--[[ Variables ]]--
-------------------

local loadedClientPeds = {
    modelIDs = {},
    models = {txd = {}, dff = {}}
}


--------------------------------------
--[[ Function: Retrieves Ped's ID ]]--
--------------------------------------

function _getPedID(pedType)

    if not pedType or not serverCharacters[pedType] or not loadedClientPeds.modelIDs[pedType] then return false end

    return loadedClientPeds.modelIDs[pedType]

end


-----------------------------------------
--[[ Event: On Client Resource Start ]]--
-----------------------------------------

addEventHandler("onClientResourceStart", resource, function()

    for i, j in pairs(serverCharacters) do
        local generatedModelID = engineRequestModel("ped")
        if generatedModelID then
            local pedType = i
            local pedTXDPath = ":mod_loader/files/characters/"..pedType.."/skin.txd"
            local pedDFFPath = ":mod_loader/files/characters/"..pedType.."/skin.dff"
            if pedTXDPath and File.exists(pedTXDPath) then
                if not loadedClientPeds.models.txd[pedTXDPath] then
                    loadedClientPeds.models.txd[pedTXDPath] = EngineTXD(pedTXDPath)
                end
                if loadedClientPeds.models.txd[pedTXDPath] and isElement(loadedClientPeds.models.txd[pedTXDPath]) then
                    loadedClientPeds.models.txd[pedTXDPath]:import(generatedModelID)
                end
            end
            if pedDFFPath and File.exists(pedDFFPath) then
                if not loadedClientPeds.models.dff[pedDFFPath] then
                    loadedClientPeds.models.dff[pedDFFPath] = EngineDFF(pedDFFPath)
                end
                if loadedClientPeds.models.dff[pedDFFPath] and isElement(loadedClientPeds.models.dff[pedDFFPath]) then
                    loadedClientPeds.models.dff[pedDFFPath]:replace(generatedModelID)
                end
            end
            loadedClientPeds.modelIDs[pedType] = generatedModelID
        end
    end

end)