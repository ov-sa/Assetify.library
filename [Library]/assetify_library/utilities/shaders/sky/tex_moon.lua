----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: sky: tex_moon.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Sky Texture Moon ]]--
----------------------------------------------------------------


----------------
--[[ Shader ]]--
----------------

local identity = "Assetify_Sky_Tex_Moon"
shaderRW.buffer[identity] = {
    exec = function()
        return shaderRW.create()..[[
        // Variables //
        float2 moonScale = 0.5;
        float moonNativeScale = 1;
        float moonBrightness = 1;
        float moonVisibility = 1;
        texture moonTex;
        texture moonRT <string renderTarget = "yes";>;

        // Inputs //
        struct PSInput {
            float4 Position : POSITION0;
            float2 TexCoord : TEXCOORD0;
            float4 Diffuse : COLOR0;
        };
        struct Export {
            float4 World : COLOR0;
            float4 Color : COLOR1;
        };
        sampler moonSampler = sampler_state {
            Texture = moonTex;
            AddressU = BORDER;
            AddressV = BORDER;
            BorderColor = 0;
        };

        // Utils //
        float ScaleCoord(float coord, float factor) {
            float offset = (1 - factor)/2;
            return (coord - offset)/factor;
        }

        // Handlers //
        Export PSHandler(PSInput PS) : COLOR0 {
            Export Output;
            PS.TexCoord.x = ScaleCoord(PS.TexCoord.x, vResolution.y/vResolution.x);
            float sampleScale = moonScale*max(4, moonNativeScale);
            float emissiveScale = 2;
            float4 sampledTexel = tex2D(moonSampler, (PS.TexCoord*sampleScale) + ((1 - sampleScale)*0.5))*PS.Diffuse;
            float emissiveTexel = (1 - distance((PS.TexCoord*emissiveScale) + ((1 - emissiveScale)*0.5), float2(0.5, 0.5)))*moonVisibility;
            sampledTexel.rgb *= moonBrightness*moonVisibility;
            Output.World = float4(sampledTexel.rgb, 1);
            Output.Color = float4(emissiveTexel, emissiveTexel, emissiveTexel, 1);
            return Output;
        }

        // Techniques //
        technique ]]..identity..[[ {
            pass P0 {
                CullMode = None;
                DepthBias = 6;
                AlphaBlendEnable = true;
                PixelShader = compile ps_2_0 PSHandler();
            }
        }

        technique fallback {
            pass P0 {}
        }
        ]]
    end
}