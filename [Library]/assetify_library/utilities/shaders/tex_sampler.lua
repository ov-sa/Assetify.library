----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: tex_sampler.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Texture Sampler ]]--
----------------------------------------------------------------


-------------------
--[[ Variables ]]--
-------------------

local identity = {
    name = "Assetify_TextureSampler",
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

        float sampleOffset = 0.001;
        float sampleIntensity = 2;
        float2x3 skyGradient = {
            float3(0.7, 0.75, 0.85),
            float3(0.2, 0.5, 0.85)
        };
        float cloudDensity = 10;
        float cloudScale = 15;
        float3 cloudColor = 0.85 * float3(1, 1, 1);
        float3 sunColor = float3(1, 0.7, 0.4);
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

        float4x4 GetViewMatrix(float4x4 matrixInput) {
            #define minor(a, b, c) determinant(float3x3(matrixInput.a, matrixInput.b, matrixInput.c))
            float4x4 cofactors = float4x4(
               minor(_22_23_24, _32_33_34, _42_43_44), 
               -minor(_21_23_24, _31_33_34, _41_43_44),
               minor(_21_22_24, _31_32_34, _41_42_44),
               -minor(_21_22_23, _31_32_33, _41_42_43),
               -minor(_12_13_14, _32_33_34, _42_43_44),
               minor(_11_13_14, _31_33_34, _41_43_44),
               -minor(_11_12_14, _31_32_34, _41_42_44),
               minor(_11_12_13, _31_32_33, _41_42_43),
               minor(_12_13_14, _22_23_24, _42_43_44),
               -minor(_11_13_14, _21_23_24, _41_43_44),
               minor(_11_12_14, _21_22_24, _41_42_44),
               -minor(_11_12_13, _21_22_23, _41_42_43),
               -minor(_12_13_14, _22_23_24, _32_33_34),
               minor(_11_13_14, _21_23_24, _31_33_34),
               -minor(_11_12_14, _21_22_24, _31_32_34),
               minor(_11_12_13, _21_22_23, _31_32_33)
            );
            #undef minor
            return transpose(cofactors)/determinant(matrixInput);
        }
       
        float3 GetViewClipPosition(float2 coords, float4 view) {
            return float3((coords.x*view.x) + view.z, (1 - coords.y)*view.y + view.w, 1)*(gProjectionMainScene[3][2]/(1 - gProjectionMainScene[2][2]));
        }
       
        float2 GetViewCoord(float3 dir, float2 div) {
            return float2(((atan2(dir.x, dir.z)/(PI*div.x)) + 1)/2, (acos(- dir.y)/(PI*div.y)));
        }

        float FetchNoise(float2 uv) {
            return frac(sin((uv.x*83.876) + (uv.y*76.123))*3853.875);
        }
      
        float CreatePerlinNoise(float2 uv, float iterations) {
            float c = 1;
            for (float i = 0; i < iterations; i++) {
                float power = pow(2, i + 1);
                float2 luv = uv * float2(power, power) + (gTime*0.2);
                float2 gv = smoothstep(0, 1, frac(luv));
                float2 id = floor(luv);
                float b = lerp(FetchNoise(id + float2(0, 0)), FetchNoise(id + float2(1, 0)), gv.x);
                float t = lerp(FetchNoise(id + float2(0, 1)), FetchNoise(id + float2(1, 1)), gv.x);
                c += 1/power*lerp(b, t, gv.y);
            }
            return c*0.5;
        }
    
        float2x4 SampleSource(float2 uv) {
            float4 baseTexel = tex2D(vSource0Sampler, uv);
            float4 depthTexel = tex2D(depthSampler, uv);
            float4 weatherTexel = ((depthTexel.r + depthTexel.g + depthTexel.b)/3) >= 1 ? baseTexel*float4(MTAGetWeatherColor(), 0.75) : float4(0, 0, 0, 0);
            float2x4 result = {baseTexel, weatherTexel};
            return result;
        }
    
        float4 SampleSky(float2 uv) {
            float2 viewAdd = - 1/float2(gProjectionMainScene[0][0], gProjectionMainScene[1][1]);	
            float2 viewMul = -2*viewAdd.xy;
            float4x4 viewMatrix = GetViewMatrix(gViewMainScene);
            float3 worldPosition = mul(float4(GetViewClipPosition(uv, float4(viewMul, viewAdd)), 1), viewMatrix).xyz;
            float3 viewDirection = normalize(worldPosition - viewMatrix[3].xyz);
            float2 viewCoord = GetViewCoord(-viewDirection.xzy, float2(1, 1));
            float2 screenCoord = float2(uv.x*(vResolution.x/vResolution.y), uv.y);
            // Sample Base
            float3 result = skyGradient[0]*1.1 - (viewCoord.y*viewCoord.y*0.5);
            result = lerp(result, 0.85*skyGradient[1], pow(1 - max(viewCoord.y, 0), 4));
            // Sample Clouds
            float cloudID = sin(2)*0.1 + 0.7;
            result = lerp(result, cloudColor, smoothstep(cloudID, cloudID + 0.1, CreatePerlinNoise(viewCoord*cloudScale, cloudDensity)));
            // Sample Sun
            float2 sunCoord = vSunViewOffset/vResolution;
            sunCoord.x *= vResolution.x/vResolution.y;
            float sunPoint = clamp(1 - distance(screenCoord, sunCoord), 0, 1);
            float sunGlow = clamp(pow(sunPoint, screenCoord.y*vResolution.y), 0, 1);
            sunPoint = clamp(pow(sunPoint, 100)*100, 0, 1);
            result += sunColor*sunPoint*pow(dot(screenCoord.y, screenCoord.y), 1/5);
            result += lerp(sunColor, sunColor - 0.25, 0.25)*sunGlow*pow(dot(screenCoord.y, screenCoord.y), 1/64);
            result += lerp(sunColor, sunColor - 0.4, 0.4)*sunGlow*pow(dot(screenCoord.y, screenCoord.y), 1/512);
            return float4(result, 1);
        }

        PSInput VSHandler(VSInput VS) {
            PSInput PS = (PSInput)0;
            PS.Position = MTACalcScreenPosition(VS.Position);
            PS.TexCoord = VS.TexCoord;
            return PS;
        }
    
        float4 PSHandler(PSInput PS) : COLOR0 {
            float2x4 rawTexel = SampleSource(PS.TexCoord + float2(sampleOffset, sampleOffset));
            rawTexel += SampleSource(PS.TexCoord + float2(-sampleOffset, -sampleOffset));
            rawTexel += SampleSource(PS.TexCoord + float2(-sampleOffset, sampleOffset));
            rawTexel += SampleSource(PS.TexCoord + float2(sampleOffset, -sampleOffset));
            rawTexel *= 0.25;
            float4 sampledTexel = rawTexel[0];
            if (rawTexel[1].a > 0) sampledTexel = vDynamicSkyEnabled ? SampleSky(PS.TexCoord) : rawTexel[1];
            else {
                float edgeIntensity = length(sampledTexel.rgb);
                sampledTexel.a = pow(length(float2(ddx(edgeIntensity), ddy(edgeIntensity))), 0.5)*sampleIntensity;
            }
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