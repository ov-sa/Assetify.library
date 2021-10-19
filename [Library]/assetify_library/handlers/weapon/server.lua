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
    fetchFileData = fetchFileData
}


-------------------
--[[ Variables ]]--
-------------------

local assetPack = {
    reference = {
        packPath = "files/assets/weapons/",
        manifestPath = "manifest.json",
        assetPath = "asset.json"
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

    assetPack.manifestData = imports.fetchFileData(assetPack.reference.packPath..assetPack.reference.manifestPath)
    assetPack.manifestData = (assetPack.manifestData and imports.fromJSON(assetPack.manifestData)) or false

    if assetPack.manifestData then
        for i = 1, #assetPack.manifestData, 1 do
            local assetPath = assetPack.manifestData[i]
            local assetData = imports.fetchFileData((assetPack.reference.packPath)..assetPath.."/"..(assetPack.reference.assetPath))
            assetData = (assetData and imports.fromJSON(assetData)) or false
            if not assetData then
                assetPack.datas.rwDatas[assetPath] = false
            else
                assetPack.datas.rwDatas[assetPath] = {
                    rwData = {
                        txd = false,
                        dff = false,
                        col = false
                    }
                }
                print("LOAD FILE..: "..assetPath)
            end
        end
    end
    return (assetPack.manifestData and true) or false

end

addEventHandler("onResourceStart", resourceRoot, function()

    loadWeapons()

end)



--[[
function callBackTest(threadReference, index)

    print("WOW: "..index)
    setTimer(function()
        threadReference:resume()
    end, 1, 1)

end

threadInstance = thread:create(function(threadReference)
    for i = 1, 5000 do
        callBackTest(threadReference, i)
        thread.pause()
    end
    imports.collectgarbage()
end)

threadInstance:resume()
]]