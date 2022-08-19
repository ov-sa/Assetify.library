----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: overlay_google.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Google Overlay ]]--
----------------------------------------------------------------


-------------------
--[[ Variables ]]--
-------------------

local identity = {
    name = "Assetify_OverlayGoogle",
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
            ["vSource1"] = true,
            ["vSource2"] = true
        }
    },

    exec = function()
        return identity.deps..[[
        /*-----------------
        -->> Variables <<--
        -------------------*/

        float3 tintColor = float3(0.6, 1, 0.6);
        float warpSize = 0.1;
        float warpSpeed = 1.5;
        struct VSInput {
            float3 Position : POSITION0;
            float2 TexCoord : TEXCOORD0;
        };
        struct PSInput {
            float4 Position : POSITION0;
            float2 TexCoord : TEXCOORD0;
        };
        sampler vSource0Sampler = sampler_state {
            Texture = vSource0;
        };


        /*----------------
        -->> Handlers <<--
        ------------------*/

        float FetchReMap(float value, float inMin, float inMax, float outMin, float outMax) {
            return ((value - inMin)*(outMax - outMin))/(inMax - inMin + outMin);
        }
        
        float3 CreateMask(float2 center, float2 coord) {
            float maskLength = distance(center, coord);
            return maskLength > 0.5 ? 0 : smoothstep(0, 1, clamp(FetchReMap(0.5 - maskLength, 0, 0.1, 0, 1), 0, 1));
        }

        PSInput VSHandler(VSInput VS) {
            PSInput PS = (PSInput)0;
            PS.Position = MTACalcScreenPosition(VS.Position);
            PS.TexCoord = VS.TexCoord;
            return PS;
        }
    
        float4 PSHandler(PSInput PS) : COLOR0 {
            float screenRatio = vResolution.x/vResolution.y;
            float2 screenCoord = float2(PS.TexCoord.x*screenRatio, PS.TexCoord.y);
            float screenNoise = 0.5 + frac(sin(dot(PS.TexCoord*float2(0.1, 1), float2(12.9898, 78.233)))*43758.5453 + (gTime*5))*0.5;
            float screenWarp = FetchReMap(clamp((screenCoord.y - frac(-gTime*0.5*warpSpeed)) - warpSize*0.5, 0, warpSize), 0, warpSize, 0, 1);
            float4 sampledTexel = tex2D(vSource0Sampler, PS.TexCoord + float2(sin(screenWarp*10)*(-4.0*pow(screenWarp - 0.5, 2) + 1)*0.02, 0));
            sampledTexel.rgb *= 1 - (1 - CreateMask(0.5, screenCoord))*(1 - CreateMask(float2(screenRatio - 0.5, 0.5), screenCoord));
            sampledTexel.rgb += 0.075;
            sampledTexel.rgb *= (1.0 - (1.0 - screenNoise)*0.3)*tintColor;
            sampledTexel.rgb *= abs(PS.TexCoord.y - frac(-gTime*19)) < 0.0005 ? 0.5 : 1;
            return saturate(sampledTexel);
        }


        /*------------------
        -->> Techniques <<--
        --------------------*/

        technique ]]..identity.name..[[ {
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