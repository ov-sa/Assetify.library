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
        float2x3 skyColor = 1;
        float cloudSpeed = 1;
        float cloudScale = 1;
        float2 cloudDirection = 1;
        float4 cloudColor = 1;
        float starGrid = 40.0;
        float2 starSpeed = float2(0, 5);
        float starScale = 0.085;
        float starIntensity = 1;
        float starsVisibility = 1;
        texture cloudTex;
        texture vCloud0 <string renderTarget = "yes";>;

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
        float3 GetSkyGradient(float2 uv) {
            return lerp(skyColor[1], skyColor[0], saturate(uv.y*(1/0.4)));
        }

        float2 RandFloat2(in float2 vec, in float seed) {
            return float2(frac(sin(vec.x*999.9 + vec.y)*seed), frac(sin(vec.y*999.9 + vec.x)*seed));
        }

        void RenderStars(inout float4 result, in float4 color, in float2 uv, in float grid, in float2 size, in float2 speed, in float seed) {
            float2 randv = RandFloat2(floor(uv/grid), seed) - 0.5;
            float len = length(randv);
            if (len < 0.5) {
                float radius = 1.0 - distance(mod(uv, grid)/grid, 0.5 + randv)/(size*(0.5 - len));
                if (radius > 0.0) result += color*radius*abs(sin(gTime*max(randv.x, randv.y)*max(speed.x, speed.y)*7));
            }
        }

        void RenderClouds(sampler2D tex, inout float4 result, float2 offset, float2 uv) {
            uv = offset + uv + gTime*cloudSpeed*cloudDirection*0.012*0;
            float4 cloudTexel = tex2DStochastic(cloudSampler, uv)*0.5;
            float difference = uv.x - offset.x;
            float blendwidth = 0.005;
            cloudTexel *= min(difference/blendwidth, 1)*min((1 - difference)/blendwidth, 1);
            result += cloudTexel;
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
            float4 cloudTexel = 0;
            cloudTexel += tex2D(cloudSampler, cloudUV*12*cloudScale*float2(0.5, 1) + gTime*cloudSpeed*cloudDirection*0.01)*tex2D(cloudSampler, cloudUV*10*cloudScale*float2(0.5, 1) + gTime*cloudSpeed*cloudDirection*0.011)*lerp(-0.25, -1, cloudUV.y*2.5);
            RenderClouds(cloudSampler, cloudTexel, cloudUV*12*cloudScale*float2(0.5, 1) + gTime*cloudSpeed*cloudDirection*0.02, cloudUV);
            float2 starUV = PS.TexCoord*vResolution*float2(1, 1.1)*3;
            float4 starTexel = 0;
            RenderStars(starTexel, float4(1.0, 1.0, 0.0, 1.0), starUV, starGrid, starScale, starSpeed/1.1, 123456.789);
            RenderStars(starTexel, float4(0.5, 0.7, 1.0, 1.0), starUV, starGrid*2.0/3.0, starScale, starSpeed/1.2, 345678.912);
            RenderStars(starTexel, float4(1.0, 0.5, 0.5, 1.0), starUV, starGrid/2.0, starScale, starSpeed/1.6, 567891.234);
            starTexel *= starIntensity*starsVisibility;
            cloudTexel.a *= cloudColor.a*0.15*cloudDepth;
            float cloudMask = cloudTexel.a;
            skyGradient += lerp(0, starTexel, 1 + pow(length(starTexel.rgb), 2));
            cloudTexel.rgb = lerp(skyGradient, cloudColor*lerp(skyGradient, 1, (1 - cloudDepth)), cloudTexel.a);
            cloudTexel.a = 1 - PS.TexCoord.y*(1/0.4);
            cloudMask *= cloudTexel.a;
            float maskTop = PS.TexCoord.y/0.07;
            maskTop = 1 - (maskTop < 1 ? 0 : maskTop);
            float maskBottom = 1 - clamp((PS.TexCoord.y - 0.07)/0.07, 0, 1);
            cloudTexel.rgb = lerp(cloudTexel, skyGradient, maskTop);
            cloudTexel.rgb = lerp(cloudTexel, skyGradient, maskBottom);
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