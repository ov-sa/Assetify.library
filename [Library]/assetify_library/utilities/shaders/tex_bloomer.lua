----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: tex_bloomer.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Texture Bloomer ]]--
----------------------------------------------------------------


----------------
--[[ Shader ]]--
----------------

local identity = "Assetify_TextureBloomer"
shaderRW.buffer[identity] = {
    exec = function()
        return shaderRW.create()..[[
        /*-----------------
        -->> Variables <<--
        -------------------*/

        texture baseTexture;
        struct PSInput {
            float4 Position : POSITION0;
            float2 TexCoord : TEXCOORD0;
        };
        sampler baseSampler = sampler_state {
            Texture = baseTexture;
        };


        /*----------------
        -->> Handlers <<--
        ------------------*/

        float4 SampleEmissive(PSInput PS, bool isVertical) {
            return float4(1, 0, 0, 1);
        }
    
        float4 EmissiveXHandler(PSInput PS) : COLOR0 { return SampleEmissive(PS, false) }
        float4 EmissiveYHandler(PSInput PS) : COLOR0 { return SampleEmissive(PS, true) }


        /*------------------
        -->> Techniques <<--
        --------------------*/

        technique ]]..identity..[[ {
            pass P0 {
                AlphaBlendEnable = true;
                PixelShader  = compile ps_2_0 EmissiveXHandler();
            }
            pass P1 {
                AlphaBlendEnable = true;
                PixelShader  = compile ps_2_0 EmissiveYHandler();
            }
        }

        technique fallback {
            pass P0 {}
        }
        ]]
    end
}