----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: api: sound.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Sound APIs ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    playSound = playSound,
    playSound3D = playSound3D,
    setSoundVolume = setSoundVolume
}


---------------------
--[[ APIs: Sound ]]--
---------------------

if localPlayer then
    manager:exportAPI("sound", "play", function(assetName, soundCategory, soundIndex, soundVolume, isScoped, ...)
        if not syncer.isLibraryLoaded then return false end
        local cAsset, isLoaded = manager:getAssetData("sound", assetName, syncer.librarySerial)
        if not cAsset or not isLoaded then return false end
        if not cAsset.manifest.assetSounds or not cAsset.unsynced.cache[soundCategory] or not cAsset.unsynced.cache[soundCategory][soundIndex] or not cAsset.unsynced.cache[soundCategory][soundIndex].cAsset then return false end
        local cSound = imports.playSound(cAsset.unsynced.raw.sound[(cAsset.unsynced.cache[soundCategory][soundIndex].cAsset.rwPaths.sound)], ...)
        if cSound then
            if soundVolume then imports.setSoundVolume(cSound, soundVolume) end
            if isScoped then manager:setElementScoped(cSound) end
        end
        return cSound
    end)

    manager:exportAPI("sound", "play3D", function(assetName, soundCategory, soundIndex, soundVolume, isScoped, ...)
        if not syncer.isLibraryLoaded then return false end
        local cAsset, isLoaded = manager:getAssetData("sound", assetName, syncer.librarySerial)
        if not cAsset or not isLoaded then return false end
        if not cAsset.manifest.assetSounds or not cAsset.unsynced.cache[soundCategory] or not cAsset.unsynced.cache[soundCategory][soundIndex] or not cAsset.unsynced.cache[soundCategory][soundIndex].cAsset then return false end
        local cSound = imports.playSound3D(cAsset.unsynced.raw.sound[(cAsset.unsynced.cache[soundCategory][soundIndex].cAsset.rwPaths.sound)], ...)
        if cSound then
            if soundVolume then imports.setSoundVolume(cSound, soundVolume) end
            if isScoped then manager:setElementScoped(cSound) end
        end
        return cSound
    end)
else

end