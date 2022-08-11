----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: tex_grayscaler.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Texture Grayscaler ]]--
----------------------------------------------------------------


-------------------
--[[ Variables ]]--
-------------------

local identity = {
    name = "Assetify_TextureGrayscaler",
    deps = shaderRW.createDeps({
        "utilities/shaders/helper.fx"
    })
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
            float averageTexel = (sampledTexel.r + sampledTexel.g + sampledTexel.b)/3;
            float4 grayscaleTexel = float4(averageTexel, averageTexel, averageTexel, sampledTexel.a);
            sampledTexel.rgb = pow(sampledTexel.rgb*1.5, 1.5);
            sampledTexel = lerp(sampledTexel, grayscaleTexel, grayscaleIntensity);
            if (vWeatherBlend) sampledTexel.a *= (1 - vWeatherBlend) + (vWeatherBlend*MTAGetWeatherValue());
            return saturate(sampledTexel);
        }


        /*------------------
        -->> Techniques <<--
        --------------------*/

        technique ]]..identity.name..[[ {
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