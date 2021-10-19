----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: weapon: server.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Weapon Handler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    fromJSON = fromJSON,
    setTimer = setTimer,
    fetchFileData = fetchFileData
}


-------------------
--[[ Variables ]]--
-------------------

local assetPack = {
    reference = {
        assetRootPath = "files/assets/weapons/",
        manifestFileName = "manifest",
        assetFileName = "asset"
    },

    datas = {
        manifestData = false,
        rwDatas = {}
    }
}


----------------------------------
--[[ Event: On Resource Start ]]--
----------------------------------

function loadWeapons()

    assetPack.manifestData = imports.fetchFileData((assetPack.reference.assetRootPath)..(assetPack.reference.manifestFileName)..".json")
    assetPack.manifestData = (assetPack.manifestData and imports.fromJSON(assetPack.manifestData)) or false

    if assetPack.manifestData then
        thread:create(function(cThread)
            for i = 1, #assetPack.manifestData, 1 do
                local assetReference = assetPack.manifestData[i]
                local assetPath = (assetPack.reference.assetRootPath)..assetReference.."/"
                local assetData = imports.fetchFileData(assetPath..(assetPack.reference.assetFileName)..".json")
                assetData = (assetData and imports.fromJSON(assetData)) or false
                if not assetData then
                    assetPack.datas.rwDatas[assetPath] = false
                else
                    assetPack.datas.rwDatas[assetPath] = {
                        assetData = assetData,
                        rwData = {
                            txd = imports.fetchFileData(assetPath.."asset.txd"),
                            dff = imports.fetchFileData(assetPath.."asset.dff"),
                            col = imports.fetchFileData(assetPath.."asset.col")
                        }
                    }
                end
                imports.setTimer(function()
                    cThread:resume()
                end, 1, 1)
                thread.pause()
            end
            print("LOADED ASSETS")
        end):resume()
    end
    return (assetPack.manifestData and true) or false

end

addEventHandler("onResourceStart", resourceRoot, function()

    loadWeapons()

end)