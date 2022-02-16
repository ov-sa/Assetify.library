----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: tex_changer.lua
     Server: -
     Author: OvileAmriam
     Developer(s): Aviril, Tron
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Texture Changer ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    file = file
}


-------------------
--[[ Variables ]]--
-------------------

local identifier = "Assetify_TextureChanger"
local depDatas, dependencies = "", {}
for i, j in imports.pairs(dependencies) do
    local depData = imports.file.read(j.filePath)
    if depData then
        depDatas = depDatas.."\n"..depData
    end
end


----------------
--[[ Shader ]]--
----------------

shaderRW["Assetify_TextureChanger"] = depDatas..[[
/*-----------------
-->> Variables <<--
-------------------*/

texture baseTexture;


/*------------------
-->> Techniques <<--
--------------------*/

technique ]]..identifier..[[
{
    pass P0
    {
        Texture[0] = baseTexture;
    }
}

technique fallback {
    pass P0 {}
}
]]