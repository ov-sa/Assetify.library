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

        float blurIntensity = 1;
        float bloomIntensity = 1;
        static const float2x2 kernelWeights[13] = {
            float2x2(-6, 0.002216),
            float2x2(-5, 0.008764),
            float2x2(-4, 0.026995),
            float2x2(-3, 0.064759),
            float2x2(-2, 0.120985),
            float2x2(-1, 0.176033),
            float2x2(0, 0.199471),
            float2x2(1, 0.176033),
            float2x2(2, 0.120985),
            float2x2(3, 0.064759),
            float2x2(4, 0.026995),
            float2x2(5, 0.008764),
            float2x2(6, 0.002216)
        };
        texture vEmissive0 <string renderTarget = "yes";>;
        texture vEmissive1 <string renderTarget = "yes";>;
        struct PSInput {
            float4 Position : POSITION0;
            float2 TexCoord : TEXCOORD0;
        };
        struct Export {
            float4 World : COLOR0;
            float4 Intermediate : COLOR1;
            float4 Emissive : COLOR2;
        };
        sampler vEmissive0Sampler = sampler_state {
            Texture = vSource2;
            MinFilter = Linear;
            MagFilter = Linear;
            MipFilter = Linear;
            AddressU = Mirror;
            AddressV = Mirror;
        };
        sampler vEmissive1Sampler = sampler_state {
            Texture = vEmissive0;
            MinFilter = Linear;
            MagFilter = Linear;
            MipFilter = Linear;
            AddressU = Mirror;
            AddressV = Mirror;
        };


        /*----------------
        -->> Handlers <<--
        ------------------*/

        Export SampleEmissive(PSInput PS, bool isVertical) {
            Export output;
            float2 sampledTexel;
            if (!isVertical) {
                sampledTexel.x = PS.TexCoord.x;
                for(int i = 0; i < 13; i++) {
                    sampledTexel.x = PS.TexCoord.x + ((blurIntensity/viewportSize.x)*kernelWeights[i].x);
                    output.Intermediate += tex2Dlod(vEmissive0Sampler, float4(sampledTexel.xy, 0, 0))*bloomIntensity*kernelWeights[i].y;
                }
                output.Emissive = 0;
            }
            else {
                sampledTexel.y = PS.TexCoord.y;
                for(int i = 0; i < 13; i++) {
                    sampledTexel.y = PS.TexCoord.y + ((blurIntensity/viewportSize.y)*kernelWeights[i].x);
                    output.Emissive += tex2Dlod(vEmissive1Sampler, float4(sampledTexel.xy, 0, 0))*bloomIntensity*kernelWeights[i].y;
                }
                output.Intermediate = 0;
            }
            output.World = 0;
            return output;
        }
        Export EmissiveXHandler(PSInput PS) : COLOR0 { return SampleEmissive(PS, false); }
        Export EmissiveYHandler(PSInput PS) : COLOR0 { return SampleEmissive(PS, true); }


        /*------------------
        -->> Techniques <<--
        --------------------*/

        technique ]]..identity..[[ {
            pass P0 {
                AlphaBlendEnable = true;
                PixelShader = compile ps_2_0 EmissiveXHandler();
            }
            pass P1 {
                AlphaBlendEnable = true;
                PixelShader = compile ps_2_0 EmissiveYHandler();
            }
        }

        technique fallback {
            pass P0 {}
        }
        ]]
    end
}