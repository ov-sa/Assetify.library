----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers. api: anim: client.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Anim APIs ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    isElement = isElement,
    engineReplaceAnimation = engineReplaceAnimation,
    engineRestoreAnimation = engineRestoreAnimation
}


---------------------
--[[ APIs: Anim ]]--
---------------------

function manager.API.Anim:loadAnim(element, assetName)
    if not syncer.isLibraryLoaded then return false end
    if not element or not imports.isElement(element) then return false end
    local cAsset, isLoaded = manager:getData("animation", assetName)
    if not cAsset or not isLoaded then return false end
    if cAsset.manifestData.assetAnimations then
        for i = 1, #cAsset.manifestData.assetAnimations, 1 do
            local j = cAsset.manifestData.assetAnimations[i]
            imports.engineReplaceAnimation(element, j.defaultBlock, j.defaultAnim, "animation."..assetName, j.assetAnim)
        end
    end
    return true
end

function manager.API.Anim:unloadAnim(element, assetName)
    if not syncer.isLibraryLoaded then return false end
    if not element or not imports.isElement(element) then return false end
    local cAsset, isLoaded = manager:getData("animation", assetName)
    if not cAsset or not isLoaded then return false end
    if cAsset.manifestData.assetAnimations then
        for i = 1, #cAsset.manifestData.assetAnimations, 1 do
            local j = cAsset.manifestData.assetAnimations[i]
            imports.engineRestoreAnimation(element, j.defaultBlock, j.defaultAnim)
        end
    end
    return true
end