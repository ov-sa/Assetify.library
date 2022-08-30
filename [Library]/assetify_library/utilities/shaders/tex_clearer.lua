----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: tex_clearer.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Texture Clearer ]]--
----------------------------------------------------------------


----------------
--[[ Shader ]]--
----------------

local identity = "Assetify_TextureClearer"
shaderRW.buffer[identity] = {
    exec = function()
        return shaderRW.create()..[[
        /*-----------------
        -->> Variables <<--
        -------------------*/

        texture baseTexture;


        /*------------------
        -->> Techniques <<--
        --------------------*/

        technique ]]..identity..[[ {
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