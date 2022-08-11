----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: tex_clearer.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Texture Clearer ]]--
----------------------------------------------------------------


-------------------
--[[ Variables ]]--
-------------------

local identity = {
    name = "Assetify_TextureChanger",
    deps = shaderRW.createDeps({})
}


----------------
--[[ Shader ]]--
----------------

shaderRW.buffer[(identity.name)] = {
    properties = {
        disabled = {
            ["vSource0"] = true,
            ["vSource1"] = true,
            ["vSource2"] = true
        }
    },

    exec = function()
        return identity.deps..[[
        /*-----------------
        -->> Variables <<--
        -------------------*/

        texture baseTexture;


        /*------------------
        -->> Techniques <<--
        --------------------*/

        technique ]]..identity.name..[[ {
            pass P0 {
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