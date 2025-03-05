----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: sky: tex_depth.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Sky Texture Depth ]]--
----------------------------------------------------------------


----------------
--[[ Shader ]]--
----------------

local identity = "Assetify_Sky_Tex_Depth"
shaderRW.buffer[identity] = {
    exec = function()
        return shaderRW.create()..[[
        // Variables //
        float3 renderPosition = 0;
        texture vDepth0 <string renderTarget = "yes";>;

        // Inputs //
        struct VSInput {
            float3 Position : POSITION0;
            float2 TexCoord : TEXCOORD0;
        };
        struct PSInput {
            float4 Position : POSITION0;
            float2 TexCoord : TEXCOORD0;
        };
        struct Export {
            float4 World : COLOR0;
            float4 Color : COLOR1;
        };


        // Handlers //
        PSInput VSHandler(VSInput VS) {
            PSInput PS = (PSInput)0;
            float4x4 worldViewMatrix = mul(MTACreatePositionMatrix(renderPosition.xyz), gView);
            float4 worldViewPosition = float4(worldViewMatrix[3].xyz + (VS.Position.xzy*500000), 1);
            PS.Position = mul(worldViewPosition, gProjection);
            PS.TexCoord = VS.TexCoord;
            return PS;
        }

        Export PSHandler(PSInput PS) : COLOR0 {
            Export Output;
            Output.World = float4(0, 0, 0, 0.00615);
            Output.Color = 1;
            return Output;
        }

        
        // Techniques //
        technique ]]..identity..[[ {
            pass P0 {
                CullMode = None;
                DepthBias = 6;
                AlphaBlendEnable = true;
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