----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: bundler.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Bundler Handler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    resourceName = getResourceName(getThisResource()),
    addEventHandler = addEventHandler
}


-------------------
--[[ Variables ]]--
-------------------

local bundlerData = false


-----------------------------------
--[[ Function: Fetches Imports ]]--
-----------------------------------

function fetchImports(recieveData)

    if not isLibraryLoaded or not bundlerData then return false end

    if recieveData == true then
        return bundlerData
    else
        return [[
        local importList = call(getResourceFromName("]]..imports.resourceName..[["), "fetchImports", true)
        for i = 1, #importList, 1 do
            loadstring(importList[i])()
        end
        ]]
    end

end


---------------------------------
--[[ Event: On Assetify Load ]]--
----------------------------------

function onLibraryLoaded()

    isLibraryLoaded = true
    local importedModules = {
        bundler = [[
            assetify = {
                imports = {
                    resourceName = ]]..imports.resourceName..[[,
                    call = call,
                    getResourceFromName = getResourceFromName
                },

                getAsset = function(...)
                    local cAsset, cData = assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getAssetData", ...)
                    if cAsset then
                        cAsset.rwData = nil
                        return cAsset, cData                        
                    end
                    return false
                end,

                getAssetID = function(...)
                    local _, cData = assetify.getAsset(...)
                    if cData then
                       return cData.modelID or false
                    end
                end
            }
        ]]
    }

    bundlerData = {}
    imports.table.insert(bundlerData, importedModules.bundler)
    imports.triggerEvent("onAssetifyLoad", root)

end