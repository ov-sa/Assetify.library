----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: tex_exporter.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Texture Exporter ]]--
----------------------------------------------------------------


-------------------
--[[ Variables ]]--
-------------------

local identity = {
    name = "Assetify_TextureExporter",
    deps = shaderRW.createDeps({
        "utilities/shaders/helper.fx"
    })
}


----------------
--[[ Shader ]]--
----------------

shaderRW.buffer[(identity.name)] = {
    properties = {
        disabled = {}
    },

    exec = function()
        return identity.deps..[[
        /*-----------------
        -->> Variables <<--
        -------------------*/

        texture renderLayer <string renderTarget = "yes";>;
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
            Texture = gTexture0;
        };


        /*----------------
        -->> Handlers <<--
        ------------------*/

        Export PSHandler(PSInput PS) {
            Export output;
            float4 sampledTexel = tex2D(baseSampler, PS.TexCoord);
            if (vRenderingEnabled) {
                if (vEmissiveSource) {
                    output.Diffuse = 0;
                    output.Emissive = sampledTexel;
                } else {
                    output.Diffuse = sampledTexel;
                    output.Emissive = 0;
                }
            } else {
                output.Diffuse = 0;
                output.Emissive = 0;
            }
            sampledTexel.rgb *= MTAGetWeatherValue();
            output.World = saturate(sampledTexel);
            return output;
        }


        /*------------------
        -->> Techniques <<--
        --------------------*/

        technique ]]..identity.name..[[ {
            pass P0 {
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