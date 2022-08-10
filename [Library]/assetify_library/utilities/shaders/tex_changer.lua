----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: tex_changer.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Texture Changer ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs
}


-------------------
--[[ Variables ]]--
-------------------

local identifier = "Assetify_TextureChanger"
local depDatas, dependencies = "", {}
for i, j in imports.pairs(dependencies) do
    local depData = file:read(j)
    if depData then
        depDatas = depDatas.."\n"..depData
    end
end


----------------
--[[ Shader ]]--
----------------

shaderRW[identifier] = {
    properties = {
        disabled = {}
    },

    exec = function()
        return depDatas..[[
        /*-----------------
        -->> Variables <<--
        -------------------*/

        texture baseTexture;
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


        /*----------------
        -->> Handlers <<--
        ------------------*/

        Export PSHandler(PSInput PS) : COLOR0 {
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

        technique ]]..identifier..[[ {
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