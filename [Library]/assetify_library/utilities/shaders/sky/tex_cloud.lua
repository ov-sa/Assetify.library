----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: sky: tex_cloud.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Sky Texture Cloud ]]--
----------------------------------------------------------------


----------------
--[[ Shader ]]--
----------------

local identity = "Assetify_Sky_Tex_Cloud"
shaderRW.buffer[identity] = {
    exec = function()
        return shaderRW.create()..[[
        // Variables //
        float nightTransitionPercent = 1;
        float3 skyColorTop = 1;
        float3 skyColorBottom = 1;
        float cloudSpeed = 1;
        float cloudScale = 1;
        float2 cloudDirection = 1;
        float4 cloudColor = 1;
        float2 starSpeed = float2(0, 3);
        float starScale = 0.095;
        float starIntensity = 0.6;
        float starGrid = 40.0;
        float4 starColor1 = float4(1, 0.94, 0.72, 0.7);
        float4 starColor2 = float4(0.18, 0.03, 0.41, 0.7);
        float4 starColor3 = float4(0.63, 0.50, 0.81, 0.7);
        texture cloudRT <string renderTarget = "yes";>;
        texture cloudTex;

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
        sampler cloudSampler = sampler_state {
            Texture = cloudTex;
        };

        // Utils //
        #define mod(x, y) (x - (y*floor(x/y)))
        float3 GetSkyGradient(float2 uv) { return lerp(skyColorBottom*0.5, skyColorTop*0.5, saturate(uv.y*(1/0.4))); }
        float2 RandVector(in float2 vec, in float seed) { return float2(frac(sin(vec.x*999.9 + vec.y)*seed), frac(sin(vec.y*999.9 + vec.x)*seed)); }
        void DrawStars(inout float4 fragColor, in float4 color, in float2 uv, in float grid, in float2 size, in float2 speed, in float seed) {
            float2 randv = RandVector(floor(uv/grid), seed) - 0.5;
            float len = length(randv);
            if (len < 0.5) {
                float radius = 1.0 - distance(mod(uv, grid)/grid, 0.5 + randv)/(size*(0.5 - len));
                if (radius > 0.0) fragColor += color*radius;
            }
        }
    
        // Handlers //
        PSInput VSHandler(VSInput VS) {
            PSInput PS = (PSInput)0;
            PS.Position = mul(float4(VS.Position, 1), gWorldViewProjection);
            PS.TexCoord = VS.TexCoord;
            return PS;
        }

        Export PSHandler(PSInput PS) : COLOR0 {
            Export Output;
            float3 skyGradient = GetSkyGradient(PS.TexCoord);
            float2 cloudUV = PS.TexCoord;
            float cloudDepth = lerp(0, 1, 0.9 - cloudUV.y);
            cloudUV.y /= cloudDepth*1.25;
            float4 cloudTexel = tex2D(cloudSampler, cloudUV*12*cloudScale*float2(0.5, 1) + gTime*cloudSpeed*cloudDirection*0.01) + tex2D(cloudSampler, cloudUV*8*cloudScale*float2(0.5, 1) + gTime*cloudSpeed*cloudDirection*0.011);
            float2 starUV = PS.TexCoord*vResolution*float2(1, 1.1)*3;
            float4 starTexel = 0;
            DrawStars(starTexel, starColor1, starUV, starGrid, starScale, starSpeed, 123456.789);
            DrawStars(starTexel, starColor2, starUV, starGrid*2.0/3.0, starScale, starSpeed/1.2, 345678.912);
            DrawStars(starTexel, starColor3, starUV, starGrid/2.0, starScale*3.0/4.0, starSpeed/1.6, 567891.234);
            starTexel *= starIntensity*nightTransitionPercent;
            cloudTexel.a *= cloudColor.a*0.15*pow(cloudDepth, 1.2);
            float cloudMask = cloudTexel.a;
            cloudTexel.rgb = lerp(skyGradient + starTexel, 0.1 + (length(skyGradient)*cloudColor), cloudTexel.a);
            cloudTexel.a = 1 - PS.TexCoord.y*(1/0.4);
            cloudMask *= cloudTexel.a;
            float maskTop = PS.TexCoord.y/0.07;
            maskTop = 1 - (maskTop < 1 ? 0 : maskTop);
            float maskBottom = 1 - clamp((PS.TexCoord.y - 0.07)/0.07, 0, 1);
            cloudTexel.rgb = lerp(cloudTexel, skyGradient + starTexel, maskTop);
            cloudTexel.rgb = lerp(cloudTexel, skyGradient + starTexel, maskBottom);
            cloudMask = lerp(cloudMask, 0, maskTop);
            cloudMask = lerp(cloudMask, 0, maskBottom);
            Output.World = cloudTexel;
            Output.Color = float4(cloudMask, cloudMask, cloudMask, 1);
            return Output;
        }

        // Techniques //
        technique ]]..identity..[[ {
            pass P0 {
                CullMode = None;
                DepthBias = 5;
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