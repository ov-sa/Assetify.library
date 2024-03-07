----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: tex_grayscaler.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Texture Grayscaler ]]--
----------------------------------------------------------------


----------------
--[[ Shader ]]--
----------------

local identity = "Assetify_TextureGrayscaler"
shaderRW.buffer[identity] = {
    exec = function()
        return shaderRW.create()..[[
        /*-----------------
        -->> Variables <<--
        -------------------*/

        float grayscaleIntensity = 1;
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

        float4 PSHandler(PSInput PS) : COLOR0 {
            float4 sampledTexel = tex2D(baseSampler, PS.TexCoord);
            sampledTexel.rgb = lerp(sampledTexel, length(sampledTexel.rgb), grayscaleIntensity);
            if (vWeatherBlend) sampledTexel.a *= (1 - vWeatherBlend) + (vWeatherBlend*MTAGetWeatherValue());
            return saturate(sampledTexel);
        }


        /*------------------
        -->> Techniques <<--
        --------------------*/

        technique ]]..identity..[[ {
            pass P0 {
                AlphaRef = 1;
                AlphaBlendEnable = true;
                FogEnable = false;
                PixelShader = compile ps_2_0 PSHandler();
            }
        }

        technique fallback {
            pass P0 {}
        }
        ]]
    end
}