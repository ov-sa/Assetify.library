----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: tex_clumper.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Texture Clumper ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    file = file
}


-------------------
--[[ Variables ]]--
-------------------

local identifier = "Assetify_TextureClumper"
local depDatas, dependencies = "", {
    helper = "utilities/shaders/helper.fx"
}
for i, j in imports.pairs(dependencies) do
    local depData = imports.file.read(j)
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

    exec = function(shaderMaps)
        if not shaderMaps or not shaderMaps.clump then return false end
        local controlVars, handlerBody, handlerFooter = [[
            texture clumpTex;
            sampler clumpSampler = sampler_state {
                Texture = clumpTex;
                MipFilter = Linear;
                MaxAnisotropy = gMaxAnisotropy*anisotropy;
                MinFilter = Anisotropic;
            };    
        ]], "", ""
        if shaderMaps.bump then
            controlVars = controlVars..[[
                texture clumpTex_bump;
                sampler clumpSampler_bump = sampler_state { 
                    Texture = clumpTex_bump;
                    MinFilter = Linear;
                    MagFilter = Linear;
                    MipFilter = Linear;
                };
            ]]
            handlerBody = handlerBody..[[
                float4 clumpTexel_bump = tex2D(clumpSampler_bump, PS.TexCoord);
            ]]
        end
        handlerBody = handlerBody..[[
            float4 sampledTexel = tex2D(clumpSampler, PS.TexCoord);
        ]]
        if shaderMaps.bump then
            handlerBody = handlerBody..[[
                sampledTexel.rgb *= clumpTexel_bump.rgb;
            ]]
        end
        return depDatas..[[
        /*-----------------
        -->> Variables <<--
        -------------------*/

        float anisotropy = 1;
        ]]..controlVars..[[
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


        /*----------------
        -->> Handlers <<--
        ------------------*/

        Export PSHandler(PSInput PS) : COLOR0 {
            Export output;
            ]]..handlerBody..handlerFooter..[[
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

        technique ]]..identifier..[[
        {
            pass P0
            {
                SRGBWriteEnable = false;
                PixelShader = compile ps_2_0 PSHandler();
            }
        }

        technique fallback {
            pass P0 {}
        }
        ]]
    end
}