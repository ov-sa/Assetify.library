----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: tex_clearer.lua
     Server: -
     Author: OvileAmriam
     Developer(s): Aviril, Tron
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Texture Clearer ]]--
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

local identifier = "Assetify_TextureClearer"
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

shaderRW["Assetify_TextureClearer"] = depDatas..[[
/*----------------
-->> Handlers <<--
------------------*/

float4 PixelShaderFunction() : COLOR0 {
    return 0;
}


/*------------------
-->> Techniques <<--
--------------------*/

technique ]]..identifier..[[
{
    pass P0 {
        AlphaBlendEnable = TRUE;
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}

technique fallback {
    pass P0 {}
}
]]