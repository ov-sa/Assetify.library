----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: api: library.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Library APIs ]]--
----------------------------------------------------------------


-----------------------
--[[ APIs: Library ]]--
-----------------------

manager:exportAPI("library", "isBooted", function() return syncer.isLibraryBooted end)
manager:exportAPI("library", "isLoaded", function() return syncer.isLibraryLoaded end)
manager:exportAPI("library", "isModuleLoaded ", function() return syncer.isModuleLoaded end)
manager:exportAPI("library", "fetchSerial", function() return syncer.librarySerial end)
manager:exportAPI("library", "fetchVersion", function() return syncer.libraryVersion end)
manager:exportAPI("library", "fetchWebserver", function() return syncer.libraryWebserver end)
manager:exportAPI("library", "fetchAssets", function(...) return manager:fetchAssets(...) end)
manager:exportAPI("library", "getAssetData", function(...) return manager:getAssetData(...) end)
manager:exportAPI("library", "getAssetDep", function(...) return manager:getAssetDep(...) end)
manager:exportAPI("library", "setElementAsset", function(...) return syncer.syncElementModel(_, ...) end)
manager:exportAPI("library", "getElementAsset", function(element)
    if not syncer.syncedElements[element] then return false end
    return syncer.syncedElements[element].assetType, syncer.syncedElements[element].assetName, syncer.syncedElements[element].assetClump, syncer.syncedElements[element].clumpMaps
end)

manager:exportAPI("library", "createDummy", function(...)
    local cDummy = syncer.syncDummySpawn(_, ...)
    return (cDummy and cDummy.cDummy) or false
end)

if localPlayer then
    manager:exportAPI("library", "getDownloadProgress", function(...) return manager:getDownloadProgress(...) end)
    manager:exportAPI("library", "isAssetLoaded", function(...) return manager:isAssetLoaded(...) end)
    manager:exportAPI("library", "getAssetID", function(...) return manager:getAssetID(...) end)
    manager:exportAPI("library", "loadAsset", function(...) return manager:loadAsset(...) end)
    manager:exportAPI("library", "unloadAsset", function(...) return manager:unloadAsset(...) end)
    
    manager:exportAPI("library", "createShader", function(...)
        local cShader = shader:create(...)
        return (cShader and cShader.cShader) or false
    end)
else

end