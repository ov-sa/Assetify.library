----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: light_planar.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Planar Light ]]--
----------------------------------------------------------------


----------------
--[[ Shader ]]--
----------------

local identity = "Assetify_LightPlanar"
shaderRW.buffer[identity] = {
    exec = function()
        return shaderRW.create({emissive = true})..[[
        /*-----------------
        -->> Variables <<--
        -------------------*/

        float lightResolution = 1;
        float3 lightOffset = float3(0, 0, 0);
        float4 lightColor = float4(1, 1, 1, 1);
        texture baseTexture;
        struct VSInput {
            float4 Position : POSITION0;
            float4 Diffuse : COLOR0;
            float2 TexCoord : TEXCOORD0;
        };
        struct PSInput {
            float4 Position : POSITION0;
            float2 TexCoord : TEXCOORD0;
        };
        struct Export {
            float4 World : COLOR0;
            float4 Emissive : COLOR1;
        };
        sampler baseSampler = sampler_state {
            Texture = baseTexture;
        };
        sampler vSource0Sampler = sampler_state {
            Texture = vSource0;
        };
        sampler vSource1Sampler = sampler_state {
            Texture = vSource1;
        };

        
        /*----------------
        -->> Handlers <<--
        ------------------*/

        PSInput VSHandler(VSInput VS) {
            PSInput PS = (PSInput)0;
            float4 position = VS.Position*lightResolution;
            float4x4 positionMatrix = MTACreatePositionMatrix(lightOffset);
            float4x4 gWorldFix = mul(gWorld, positionMatrix);
            float4x4 worldViewMatrix = mul(gWorldFix, gView);
            float4 worldViewPosition = float4(worldViewMatrix[3].xyz + position.xzy - lightOffset.xzy, 1);
            worldViewPosition.xyz += 1.5*mul(normalize(gCameraPosition - lightOffset), gView).xyz;
            PS.Position = mul(worldViewPosition, gProjection);
            PS.TexCoord = float2(VS.TexCoord.x, VS.TexCoord.y);
            return PS;
        }
        
        Export PSHandler(PSInput PS) : COLOR0 {
            Export output;
            float4 sampledTexel = tex2D(baseSampler, PS.TexCoord);
            sampledTexel.rgb = pow(sampledTexel.rgb*1.5, 1.5);
            if (vRenderingEnabled) {
                float4 sourceTex = vSource1Enabled ? tex2D(vSource1Sampler, PS.TexCoord) : tex2D(vSource0Sampler, PS.TexCoord);
                sampledTexel.rgb *= lerp(sampledTexel.rgb, sourceTex.rgb*2.5, 0.95);
            }
            else output.Emissive = 0;
            sampledTexel *= lightColor;
            sampledTexel.rgb *= 1 + (1 - MTAGetWeatherValue());
            if (vRenderingEnabled) output.Emissive = sampledTexel;
            output.World = saturate(sampledTexel);
            return output;
        }
        

        /*------------------
        -->> Techniques <<--
        --------------------*/

        technique ]]..identity..[[ {
            pass P0 {
                AlphaRef = 1;
                AlphaBlendEnable = true;
                FogEnable = false;
                VertexShader = compile vs_2_0 VSHandler();
                PixelShader = compile ps_2_0 PSHandler();
            }
        }

        technique fallback {
            pass P0 {}
        }
        ]]
    end
}