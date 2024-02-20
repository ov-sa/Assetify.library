----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: tex_sampler.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Texture Sampler ]]--
----------------------------------------------------------------


----------------
--[[ Shader ]]--
----------------

local identity = "Assetify_TextureSampler"
shaderRW.buffer[identity] = {
    exec = function()
        local controlVars, controlHandlers = "", [[
            float3x4 FetchTimeCycle(float hour) {
                float3x4 cycles[24] = {
        ]]
        for i = 1, 24, 1 do
            controlVars = controlVars..[[
                float3x4 timecycle_]]..i..[[ = false;
            ]]
            controlHandlers = controlHandlers..[[
                timecycle_]]..i..[[,
            ]]
        end
        controlHandlers = controlHandlers..[[
                };
                return cycles[hour];
            }
        ]]
        return shaderRW.create({}, true)..[[
        /*-----------------
        -->> Variables <<--
        -------------------*/

        float sampleOffset = 0.001;
        float sampleIntensity = 0;
        float3 sunColor = false;
        bool isStarsEnabled = false;
        float cloudDensity = false;
        float cloudScale = false;
        float3 cloudColor = false;
        texture vSky0 <string renderTarget = "yes";>;
        ]]..controlVars..[[
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
            float4 Sky : COLOR1;
        };
        sampler vSource0Sampler = sampler_state {
            Texture = vSource0;
        };
        sampler vSource2Sampler = sampler_state {
            Texture = vSource2;
        };
        sampler vDepth0Sampler = sampler_state {
            Texture = vDepth0;
        };
    

        /*----------------
        -->> Handlers <<--
        ------------------*/

        ]]..controlHandlers..[[
        float4x4 GetViewMatrix(float4x4 viewMatrix) {
            #define minor(a, b, c) determinant(float3x3(viewMatrix.a, viewMatrix.b, viewMatrix.c))
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
            return transpose(cofactors)/determinant(viewMatrix);
        }
       
        float3 GetViewClipPosition(float2 uv, float4 view) {
            return float3((uv.x*view.x) + view.z, (1 - uv.y)*view.y + view.w, 1)*(gProjectionMainScene[3][2]/(1 - gProjectionMainScene[2][2]));
        }
       
        float2 GetViewCoord(float3 dir, float2 div) {
            return float2(((atan2(dir.x, dir.z)/(PI*div.x)) + 1)/2, (acos(- dir.y)/(PI*div.y)));
        }

        float FetchNoise(float2 uv) {
            return frac(sin((uv.x*83.876) + (uv.y*76.123))*3853.875);
        }
      
        float CreatePerlinNoise(float2 uv, float iteration) {
            float c = 1;
            for (float i = 0; i < iteration; i++) {
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
            float4 baseTexel = tex2Dlod(vSource0Sampler, float4(uv, 0, 0));
            float4 depthTexel = tex2Dlod(vDepth0Sampler, float4(uv, 0, 0));
            float4 weatherTexel = ((depthTexel.r + depthTexel.g + depthTexel.b)/3) >= 1 ? 1 : 0;
            if ((sampleOffset > 0) && (weatherTexel.a <= 0)) {
                float4 sampledTexel = tex2Dlod(vSource0Sampler, float4(uv + float2(sampleOffset, sampleOffset), 0, 0));
                sampledTexel += tex2Dlod(vSource0Sampler, float4(uv + float2(-sampleOffset, -sampleOffset), 0, 0));
                sampledTexel += tex2Dlod(vSource0Sampler, float4(uv + float2(-sampleOffset, sampleOffset), 0, 0));
                sampledTexel += tex2Dlod(vSource0Sampler, float4(uv + float2(sampleOffset, -sampleOffset), 0, 0));
                sampledTexel *= 0.25;
                float edgeIntensity = length(sampledTexel.rgb);
                edgeIntensity = pow(length(float2(ddx(edgeIntensity), ddy(edgeIntensity))), 0.5)*sampleIntensity;
                baseTexel = lerp(baseTexel, sampledTexel, edgeIntensity);
            }
            return float2x4(baseTexel, weatherTexel);
        }
    
        float3 SampleCycle(float2 uv, float3x4 cycle) {
            float4 result = cycle[0];
            float alpha = 1.57079633;
            float step = (uv.x*cos(-alpha)) - (uv.y*sin(-alpha)), length = -sin(-alpha);
            for (int i = 0; i < 2; i++) {
                if (cycle[i].a >= 0) result = lerp(result, cycle[(i + 1)], smoothstep(cycle[i].a*length, (cycle[(i + 1)].a >= 0 ? cycle[(i + 1)].a : 1)*length, step));
                else break;
            }
            return result.rgb;
        }

        float SampleStars(float2 uv, float cycle) {
            cycle = cycle < 18 ? cycle + 24 : cycle;
            float alpha = 0;
            if ((cycle > 18) && (cycle < 28)) alpha = clamp(1 - (18 - cycle), 0, 1)*clamp(28- cycle, 0, 1);
            if (alpha <= 0) return 0;
            uv *= 10000;
            float t = gTime/7;
            float a = sin((uv.x - t + cos(uv.y*20 + t))*10);
            a *= cos((uv.y*0.234 - t*3.24 + sin(uv.x*12.3 + t*0.243))*7.34);
            float3 p = frac(float3(uv.x*0.1031, uv.y*0.11369, uv.x*0.13787));
            p += dot(p, p.yzx + 19.19);
            return pow(frac((p.x + p.y)*p.z), 1000)*(a*0.5 + 0.15)*alpha;
        }

        float2x4 SampleSky(float2 uv, bool isFetchBase) {
            float2 viewAdd = - 1/float2(gProjectionMainScene[0][0], gProjectionMainScene[1][1]);	
            float2 viewMul = -2*viewAdd.xy;
            float4x4 viewMatrix = GetViewMatrix(gViewMainScene);
            float3 worldPosition = mul(float4(GetViewClipPosition(uv, float4(viewMul, viewAdd)), 1), viewMatrix).xyz;
            float3 viewDirection = normalize(worldPosition - viewMatrix[3].xyz);
            float2 viewCoord = GetViewCoord(-viewDirection.xzy, float2(1, 1));
            float2 screenCoord = float2(uv.x*(vResolution.x/vResolution.y), uv.y);
            // Sample Base
            float cycle = MTAGetWeatherCycle();
            float hour = floor(cycle);
            float3 skyBase = lerp(SampleCycle(viewCoord, FetchTimeCycle(hour > 0 ? hour - 1 : 23)), SampleCycle(viewCoord, FetchTimeCycle(hour)), cycle - hour);
            float3 result = skyBase;
            if (isFetchBase) return float2x4(float4(0, 0, 0, 0), float4(skyBase, 1));;
            // Sample Stars
            if (isStarsEnabled) result += SampleStars(viewCoord, cycle);
            // Sample Sun
            float2 sunCoord = vSunViewOffset/vResolution;
            sunCoord.x *= vResolution.x/vResolution.y;
            float sunPoint = clamp(1 - distance(screenCoord, sunCoord), 0, 1);
            float sunGlow = clamp(pow(sunPoint, screenCoord.y*vResolution.y), 0, 1);
            sunPoint = clamp(pow(sunPoint, 100)*100, 0, 1);
            result += sunColor*sunPoint*pow(dot(screenCoord.y, screenCoord.y), 1/5);
            result += lerp(sunColor, sunColor - 0.25, 0.25)*sunGlow*pow(dot(screenCoord.y, screenCoord.y), 1/64);
            result += lerp(sunColor, sunColor - 0.4, 0.4)*sunGlow*pow(dot(screenCoord.y, screenCoord.y), 1/512);
            // Sample Clouds
            float cloudID = sin(2)*0.1 + 0.7;
            result = lerp(result, cloudColor, length(skyBase)*smoothstep(cloudID, cloudID + 0.1, CreatePerlinNoise(viewCoord*cloudScale, cloudDensity)));
            return float2x4(float4(result, 1), float4(skyBase, 1));
        }

        float4 SampleEmissive(float2 uv) {
            float viewPI = PI*2;
            float2 viewRadius = 20/vResolution;
            float viewIterations = 26, viewQuality = 4, viewBrightness = 1.5;
            float4 result = tex2Dlod(vSource2Sampler, float4(uv, 0, 0))*viewBrightness;
            for(float i = 0; i < viewPI; i += viewPI/viewIterations) {
                for(float j = 1/viewQuality; j <= 1; j += 1/viewQuality) {
                    result += tex2Dlod(vSource2Sampler, float4(uv + (float2(cos(i), sin(i))*viewRadius*j), 0, 0))*viewBrightness;
                }
            }
            result /= (viewQuality*viewIterations) - 15;
            return result;
        }
    
        PSInput VSHandler(VSInput VS) {
            PSInput PS = (PSInput)0;
            PS.Position = MTACalcScreenPosition(VS.Position);
            PS.TexCoord = VS.TexCoord;
            return PS;
        }
    
        Export BufferHandler(PSInput PS) : COLOR0 {
            Export output;
            output.Sky = 1;
            output.World = 1;
            return output;
        }

        Export PSHandler(PSInput PS) : COLOR0 {
            Export output;
            float2x4 rawTexel = SampleSource(PS.TexCoord);
            float4 sampledTexel = rawTexel[0];
            output.Sky = 1;
            bool isViewCenter = (PS.TexCoord.x >= 0.5) && (PS.TexCoord.x <= (0.5 + (1/vResolution.x))) && (PS.TexCoord.y >= 0.5) && (PS.TexCoord.y <= (0.5 + (1/vResolution.y)));
            bool isSkyVisible = rawTexel[1].a > 0;
            if (!vDynamicSkyEnabled && isSkyVisible) sampledTexel = rawTexel[1];
            else if (vDynamicSkyEnabled && (isViewCenter || isSkyVisible)) {
                float2x4 skyTexel = SampleSky(PS.TexCoord, !isSkyVisible);
                sampledTexel = isSkyVisible ? skyTexel[0] : sampledTexel;
                output.Sky = skyTexel[1];
            }
            if (vSource2Enabled) sampledTexel += SampleEmissive(PS.TexCoord);
            // Sample Gamma & Vignette
            sampledTexel.rgb *= lerp(1, float3(0.8, 0.9, 1.3), sin(gTime + 3)*0.5 + 0.5);
            sampledTexel.rgb *= (1 - dot(PS.TexCoord -= 0.5, PS.TexCoord))*pow(smoothstep(0, 10, gTime), 2);
            output.World = saturate(sampledTexel);
            return output;
        }


        /*------------------
        -->> Techniques <<--
        --------------------*/

        technique ]]..identity..[[ {
            pass P0 {
                AlphaBlendEnable = true;
                VertexShader = compile vs_3_0 VSHandler();
                PixelShader = compile ps_3_0 BufferHandler();
            }
            pass P1 {
                VertexShader = compile vs_3_0 VSHandler();
                PixelShader = compile ps_3_0 PSHandler();
            }
        }

        technique fallback {
            pass P0 {}
        }
        ]]
    end
}