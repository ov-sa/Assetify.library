----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: index.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Shader Index ]]--
----------------------------------------------------------------


-------------------
--[[ Variables ]]--
-------------------

shaderRW = {
    buffer = {}
}

function shaderRW.createDeps(deps)
    if not deps then return false end
    local cDeps = ""
    for i = 1, #deps, 1 do
        local j = file:read(deps[i])
        cDeps = (j and cDeps.."\n"..j) or ""
    end
    return cDeps
end
