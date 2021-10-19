----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: weapon: server.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Weapon Handler ]]--
----------------------------------------------------------------


-------------------
--[[ Variables ]]--
-------------------

local assetReference = {
    relativePath = "files/assets/weapons/",
    manifestPath = "manifest.json"
}


----------------------------------
--[[ Event: On Resource Start ]]--
----------------------------------

addEventHandler("onResourceStart", resourceRoot, function()

    print("STARTED WEAPON: ASSETIFY 1")

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