----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: tex_change.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Texture Change ]]--
----------------------------------------------------------------


----------------
--[[ Shader ]]--
----------------

local identity = "Assetify_Tex_Change"
shaderRW.buffer[identity] = {
    exec = function()
        return shaderRW.create({diffuse = true, emissive = true})..[[
        // Variables //
        texture baseTexture;

        // Inputs //
        struct PSInput {
            float4 Position : POSITION0;
            float4 Diffuse : COLOR0;
            float2 TexCoord : TEXCOORD0;
        };
        struct Export {
            float4 World : COLOR0;
            float4 Diffuse : COLOR1;
            float4 Emissive : COLOR2;
        };
        sampler baseSampler = sampler_state {
            Texture = baseTexture;
        };

        // Handlers //
        Export PSHandler(PSInput PS) : COLOR0 {
            Export output;
            float4 sampledTexel = tex2D(baseSampler, PS.TexCoord);
            if (vRenderingEnabled) {
                output.Diffuse = vEmissiveSource ? 0 : sampledTexel;
                output.Emissive = vEmissiveSource ? sampledTexel : 0;
            }
            else {
                output.Diffuse = 0;
                output.Emissive = 0;
            }
            sampledTexel.rgb *= MTAGetTimeCycleValue();
            output.World = saturate(sampledTexel);
            return output;
        }

        // Techniques //
        technique ]]..identity..[[ {
            pass P0 {
                PixelShader = compile ps_2_0 PSHandler();
            }
        }

        technique fallback {
            pass P0 {}
        }
        ]]
    end
}