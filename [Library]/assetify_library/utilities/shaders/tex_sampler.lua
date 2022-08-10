----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: tex_sampler.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Texture Sampler ]]--
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

local identifier = "Assetify_TextureSampler"
local depDatas, dependencies = "", {
    helper = "utilities/shaders/helper.fx"
}
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
        disabled = {
            ["vSource1"] = true,
            ["vSource2"] = true
        }
    },

    exec = function()
        return depDatas..[[
        /*-----------------
        -->> Variables <<--
        -------------------*/

        float sampleOffset = 0.001;
        float sampleIntensity = 2;
        struct VSInput {
            float3 Position : POSITION0;
            float2 TexCoord : TEXCOORD0;
        };
        struct PSInput {
            float4 Position : POSITION0;
            float2 TexCoord : TEXCOORD0;
        };
        sampler depthSampler = sampler_state {
            Texture = gDepthBuffer;
        };
        sampler vSource0Sampler = sampler_state {
            Texture = vSource0;
        };


        /*----------------
        -->> Handlers <<--
        ------------------*/

        float2x4 SampleHandler(float2 TexCoord) {
            float4 baseTexel = tex2D(vSource0Sampler, TexCoord);
            float4 depthTexel = tex2D(depthSampler, TexCoord);
            float4 weatherTexel = ((depthTexel.r + depthTexel.g + depthTexel.b)/3) >= 1 ? baseTexel*float4(MTAGetWeatherColor(), 0.75) : float4(0, 0, 0, 0);
            float2x4 result = {baseTexel, weatherTexel};
            return result;
        }
    
        PSInput VSHandler(VSInput VS) {
            PSInput PS = (PSInput)0;
            PS.Position = mul(float4(VS.Position, 1), gWorldViewProjection);
            PS.TexCoord = VS.TexCoord;
            return PS;
        }
    
        float4 PSHandler(PSInput PS) : COLOR0 {
            float2x4 rawTexel = SampleHandler(PS.TexCoord + float2(sampleOffset, sampleOffset));
            rawTexel += SampleHandler(PS.TexCoord + float2(-sampleOffset, -sampleOffset));
            rawTexel += SampleHandler(PS.TexCoord + float2(-sampleOffset, sampleOffset));
            rawTexel += SampleHandler(PS.TexCoord + float2(sampleOffset, -sampleOffset));
            rawTexel *= 0.25;
            float4 sampledTexel = rawTexel[0];
            if (rawTexel[1].a > 0) sampledTexel = rawTexel[1];
            else {
                float edgeIntensity = length(sampledTexel.rgb);
                sampledTexel.a = pow(length(float2(ddx(edgeIntensity), ddy(edgeIntensity))), 0.5)*sampleIntensity;
            }
            return saturate(sampledTexel);
        }


        /*------------------
        -->> Techniques <<--
        --------------------*/

        technique ]]..identifier..[[ {
            pass P0 {
                AlphaBlendEnable = true;
                VertexShader = compile vs_3_0 VSHandler();
                PixelShader  = compile ps_3_0 PSHandler();
            }
        }

        technique fallback {
            pass P0 {}
        }
        ]]
    end
}