----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: api: animation.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Animation APIs ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    isElement = isElement,
    engineReplaceAnimation = engineReplaceAnimation,
    engineRestoreAnimation = engineRestoreAnimation
}


-------------------------
--[[ APIs: Animation ]]--
-------------------------

if localPlayer then
    manager:exportAPI("animation", {name = "loadAnim"}, function(element, assetName)
        if not syncer.isLibraryLoaded then return false end
        if not element or not imports.isElement(element) then return false end
        local cAsset, isLoaded = manager:getAssetData("animation", assetName)
        if not cAsset or not isLoaded then return false end
        if cAsset.manifest.assetAnimations then
            for i = 1, table.length(cAsset.manifest.assetAnimations), 1 do
                local j = cAsset.manifest.assetAnimations[i]
                imports.engineReplaceAnimation(element, j.defaultBlock, j.defaultAnim, "animation."..assetName, j.assetAnim)
            end
        end
        return true
    end)

    manager:exportAPI("animation", {name = "unloadAnim"}, function(element, assetName)
        if not syncer.isLibraryLoaded then return false end
        if not element or not imports.isElement(element) then return false end
        local cAsset, isLoaded = manager:getAssetData("animation", assetName)
        if not cAsset or not isLoaded then return false end
        if cAsset.manifest.assetAnimations then
            for i = 1, table.length(cAsset.manifest.assetAnimations), 1 do
                local j = cAsset.manifest.assetAnimations[i]
                imports.engineRestoreAnimation(element, j.defaultBlock, j.defaultAnim)
            end
        end
        return true
    end)
else

end