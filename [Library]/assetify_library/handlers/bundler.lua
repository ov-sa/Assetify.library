----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: bundler.lua
     Author: vStudio
     Developer(s): Aviril, Tron
     DOC: 19/10/2021
     Desc: Bundler Handler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    table = table,
    file = file
}


-------------------
--[[ Variables ]]--
-------------------

local bundlerData, threaderData = false, false


-----------------------------------
--[[ Function: Fetches Imports ]]--
-----------------------------------

function fetchImports(recieveData)
    if not bundlerData then return false end
    if recieveData == true then
        return bundlerData
    else
        return [[
        local importList = call(getResourceFromName("]]..syncer.libraryName..[["), "fetchImports", true)
        for i = 1, #importList, 1 do
            loadstring(importList[i])()
        end
        ]]
    end
end

function fetchThreader()
    return threaderData or false
end


-----------------------------------
--[[ Function: Bundles Library ]]--
-----------------------------------

function onBundleLibrary()
    threaderData = imports.file.read("utilities/thread.lua")
    local importedModules = {
        bundler = imports.file.read("utilities/shared.lua")..[[
            assetify = {
                imports = {
                    resourceName = "]]..syncer.libraryName..[[",
                    type = type,
                    call = call,
                    getResourceFromName = getResourceFromName
                }
            }
            if localPlayer then
                assetify.isLoaded = function()
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "isLibraryLoaded")
                end

                assetify.getProgress = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getLibraryProgress", ...)
                end

                assetify.getAssetID = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getAssetID", ...)
                end

                assetify.isAssetLoaded = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "isAssetLoaded", ...)
                end

                assetify.getAssetDep = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getAssetDep", ...)
                end

                assetify.loadAsset = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "loadAsset", ...)
                end

                assetify.unloadAsset = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "unloadAsset", ...)
                end

                assetify.loadAnim = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "loadAnim", ...)
                end

                assetify.unloadAnim = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "unloadAnim", ...)
                end

                assetify.createShader = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "createShader", ...)
                end

                assetify.playSound = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "playSoundAsset", ...)
                end

                assetify.playSound3D = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "playSoundAsset3D", ...)
                end

                assetify.createDummy = function(...)
                    return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "createAssetDummy", ...)
                end
            end

            assetify.getAssets = function(...)
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getLibraryAssets", ...)
            end

            assetify.getAsset = function(...)
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "getAssetData", ...)
            end

            assetify.setElementAsset = function(...)
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setElementAsset", ...)
            end

            assetify.setBoneAttach = function(...)
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setBoneAttachment", ...)
            end

            assetify.setBoneDetach = function(...)
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setBoneDetachment", ...)
            end

            assetify.setBoneRefresh = function(...)
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "setBoneRefreshment", ...)
            end

            assetify.clearBoneAttach = function(...)
                return assetify.imports.call(assetify.imports.getResourceFromName(assetify.imports.resourceName), "clearBoneAttachment", ...)
            end
        ]]
    }
    bundlerData = {}
    imports.table.insert(bundlerData, importedModules.bundler)
end
onBundleLibrary()