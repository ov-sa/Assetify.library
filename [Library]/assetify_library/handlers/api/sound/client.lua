----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers. api: sound: client.lua
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

function manager.API.Sound:playSound(assetName, soundCategory, soundIndex, soundVolume, isScoped, ...)
    if not syncer.isLibraryLoaded then return false end
    local cAsset, isLoaded = manager:getData("sound", assetName, syncer.librarySerial)
    if not cAsset or not isLoaded then return false end
    if not cAsset.manifestData.assetSounds or not cAsset.unSynced.assetCache[soundCategory] or not cAsset.unSynced.assetCache[soundCategory][soundIndex] or not cAsset.unSynced.assetCache[soundCategory][soundIndex].cAsset then return false end
    local cSound = imports.playSound(cAsset.unSynced.rwCache.sound[(cAsset.unSynced.assetCache[soundCategory][soundIndex].cAsset.rwPaths.sound)], ...)
    if cSound then
        if soundVolume then imports.setSoundVolume(cSound, soundVolume) end
        if isScoped then manager:setElementScoped(cSound) end
    end
    return cSound
end

function manager.API.Sound:playSound3D(assetName, soundCategory, soundIndex, soundVolume, isScoped, ...)
    if not syncer.isLibraryLoaded then return false end
    local cAsset, isLoaded = manager:getData("sound", assetName, syncer.librarySerial)
    if not cAsset or not isLoaded then return false end
    if not cAsset.manifestData.assetSounds or not cAsset.unSynced.assetCache[soundCategory] or not cAsset.unSynced.assetCache[soundCategory][soundIndex] or not cAsset.unSynced.assetCache[soundCategory][soundIndex].cAsset then return false end
    local cSound = imports.playSound3D(cAsset.unSynced.rwCache.sound[(cAsset.unSynced.assetCache[soundCategory][soundIndex].cAsset.rwPaths.sound)], ...)
    if cSound then
        if soundVolume then imports.setSoundVolume(cSound, soundVolume) end
        if isScoped then manager:setElementScoped(cSound) end
    end
    return cSound
end