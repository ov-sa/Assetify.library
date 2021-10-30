----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: bundler.lua
     Server: -
     Author: OvileAmriam
     Developer(s): Aviril, Tron
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Bundler Handler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    resourceName = getResourceName(getThisResource()),
    addEventHandler = addEventHandler,
    triggerEvent = triggerEvent,
    table = {
        insert = table.insert
    }
}


-------------------
--[[ Variables ]]--
-------------------

local bundlerData = false


-----------------------------------
--[[ Function: Fetches Imports ]]--
-----------------------------------

function fetchImports(recieveData)

    if not syncer.isLibraryLoaded or not bundlerData then return false end

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


-----------------------------------
--[[ Function: Bundles Library ]]--
-----------------------------------

function onBundleLibrary()

    local importedModules = {
        bundler = [[
            assetify = {
                imports = {
                    resourceName = ]]..imports.resourceName..[[,
                    type = type,
                    call = call,
                    getResourceFromName = getResourceFromName
                }
            }
            if localPlayer then
                assetify.getAsset = function(...)
                    local cAsset, cData = assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getAssetData", ...)
                    if cAsset then
                        cAsset.unsyncedData = nil
                        return cAsset, cData
                    end
                    return false
                end

                assetify.getAssetID = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getAssetID", ...)
                end

                assetify.isAssetLoaded = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "isAssetLoaded", ...)
                end

                assetify.loadAsset = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "loadAsset", ...)
                end

                assetify.unloadAsset = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "loadAsset", ...)
                end
            end

            assetify.setCharacter = function(...)
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setCharacterAsset", ...)
            end

            assetify.setVehicle = function(...)
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setVehicleAsset", ...)
            end
        ]]
    }

    bundlerData = {}
    imports.table.insert(bundlerData, importedModules.bundler)

end
onBundleLibrary()