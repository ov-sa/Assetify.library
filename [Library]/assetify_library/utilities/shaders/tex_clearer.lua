----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: tex_clearer.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Texture Clearer ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs
}


-------------------
--[[ Variables ]]--
-------------------

local identifier = "Assetify_TextureClearer"
local depDatas, dependencies = "", {}
for i, j in imports.pairs(dependencies) do
    local depData = file:read(j)
    if depData then
        depDatas = depDatas.."\n"..depData
    end
end


----------------
--[[ Shader ]]--
----------------

shaderRW[identifier] = {
    properties = {
        disabled = {
            ["vSource0"] = true,
            ["vSource1"] = true,
            ["vSource2"] = true
        }
    },

    exec = function()
        return depDatas..[[
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
                AlphaBlendEnable = true;
                Texture[0] = baseTexture;
            }
        }

        technique fallback {
            pass P0 {}
        }
        ]]
    end
}