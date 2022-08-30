----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: tex_exporter.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Texture Exporter ]]--
----------------------------------------------------------------


----------------
--[[ Shader ]]--
----------------

local identity = "Assetify_TextureExporter"
shaderRW.buffer[identity] = {
    exec = function()
        return shaderRW.create()..[[
        /*-----------------
        -->> Variables <<--
        -------------------*/

        texture vRender0 <string renderTarget = "yes";>;
        struct PSInput {
            float4 Position : POSITION0;
            float4 Diffuse : COLOR0;
            float2 TexCoord : TEXCOORD0;
        };
        struct Export {
            float4 World : COLOR0;
            float4 Render : COLOR1;
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
            output.Render = sampledTexel;
            sampledTexel.rgb *= MTAGetWeatherValue();
            output.World = saturate(sampledTexel);
            return output;
        }


        /*------------------
        -->> Techniques <<--
        --------------------*/

        technique ]]..identity..[[ {
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