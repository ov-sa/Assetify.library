----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: server.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Server Sided Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    fromJSON = fromJSON,
    setTimer = setTimer,
    fetchFileData = fetchFileData,
}


--------------------------------------
--[[ Function: Builds Weapon Pack ]]--
--------------------------------------

function buildPack(assetPack, callback)

    assetPack.datas.manifestData = imports.fetchFileData((assetPack.reference.root)..(assetPack.reference.manifest)..".json")
    assetPack.datas.manifestData = (assetPack.datas.manifestData and imports.fromJSON(assetPack.datas.manifestData)) or false

    if assetPack.datas.manifestData then
        thread:create(function(cThread)
            local callbackReference = callback
            for i = 1, #assetPack.datas.manifestData, 1 do
                local asset = assetPack.datas.manifestData[i]
                local assetPath = (assetPack.reference.root)..asset.."/"
                local assetData = imports.fetchFileData(assetPath..(assetPack.reference.asset)..".json")
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
            if callbackReference and imports.type(callbackReference) == "function" then
                callbackReference(assetPack.datas)
            end
        end):resume()
        return true
    end
    if callbackReference and imports.type(callbackReference) == "function" then
        callbackReference(false)
    end
    return false

end