----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: tex_clear.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Texture Clear ]]--
----------------------------------------------------------------


----------------
--[[ Shader ]]--
----------------

local identity = "Assetify_Tex_Clearer"
shaderRW.buffer[identity] = {
    exec = function()
        return shaderRW.create()..[[
        // Variables //
        texture baseTexture;

        // Techniques //
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