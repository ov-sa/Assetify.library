----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: tex_map.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Texture Map ]]--
----------------------------------------------------------------


----------------
--[[ Shader ]]--
----------------

local identity = "Assetify_Tex_Map"
local iteration = 3
shaderRW.buffer[identity] = {
    prepare = function(shaderMaps, shaderModel)
        local sampled = false
        local result = {
            config = [[
                sampler baseSampler = sampler_state {
                    Texture = gTexture0;
                    MipFilter = Linear;
                    MaxAnisotropy = gMaxAnisotropy*anisotropy;
                    MinFilter = Anisotropic;
                };
            ]],
            body = [[
                float4 baseTexel = tex2D(baseSampler, PS.TexCoord);
            ]],
            footer = [[]]
        }
        for i = table.length(shaderMaps), 1, -1 do
            local j = shaderMaps[i]
            if j.control then
                result.config = result.config..[[
                    texture controlTex_]]..i..[[;
                    sampler controlSampler_]]..i..[[ = sampler_state { 
                        Texture = controlTex_]]..i..[[;
                        MipFilter = Linear;
                        MaxAnisotropy = gMaxAnisotropy*anisotropy;
                        MinFilter = Anisotropic;
                    };
                ]]
            end
            result.body = result.body..[[
                float4 controlTexel_]]..i..[[ = ]]..(((j.control) and [[tex2D(controlSampler_]]..i..[[, PS.TexCoord)]]) or [[baseTexel]])..[[;
                float4 sampledTexel_]]..i..[[ = controlTexel_]]..i..[[;
            ]]
            if j.bump then
                result.config = result.config..[[
                    texture controlTex_]]..i..[[_bump;
                    sampler controlSampler_]]..i..[[_bump = sampler_state { 
                        Texture = controlTex_]]..i..[[_bump;
                        MinFilter = Linear;
                        MagFilter = Linear;
                        MipFilter = Linear;
                    };
                ]]
                result.body = result.body..[[
                    float4 controlTexel_]]..i..[[_bump = tex2D(controlSampler_]]..i..[[_bump, PS.TexCoord);
                ]]
            end
            for k = 1, table.length(shader.validChannels), 1 do
                local v, channel = shader.validChannels[k].index, shader.validChannels[k].channel
                if j[v] then
                    result.config = result.config..[[
                        texture controlTex_]]..i..[[_]]..v..[[;
                        float controlScale_]]..i..[[_]]..v..[[ = ]]..(j[v].scale)..[[;
                        sampler controlSampler_]]..i..[[_]]..v..[[ = sampler_state { 
                            Texture = controlTex_]]..i..[[_]]..v..[[;
                            MipFilter = Linear;
                            MaxAnisotropy = gMaxAnisotropy*anisotropy;
                            MinFilter = Anisotropic;
                        };
                    ]]
                    if (shaderModel < 3) or not j[v].stochastic then
                        result.body = result.body..[[
                            float4 controlTexel_]]..i..[[_]]..v..[[ = tex2D(controlSampler_]]..i..[[_]]..v..[[, PS.TexCoord*controlScale_]]..i..[[_]]..v..[[);
                        ]]
                    else
                        result.body = result.body..[[
                            float4 controlTexel_]]..i..[[_]]..v..[[ = tex2DStochastic(controlSampler_]]..i..[[_]]..v..[[, PS.TexCoord*controlScale_]]..i..[[_]]..v..[[);
                        ]]
                    end
                    if j[v].bump then
                        result.config = result.config..[[
                            texture controlTex_]]..i..[[_]]..v..[[_bump;
                            sampler controlSampler_]]..i..[[_]]..v..[[_bump = sampler_state { 
                                Texture = controlTex_]]..i..[[_]]..v..[[_bump;
                                MinFilter = Linear;
                                MagFilter = Linear;
                                MipFilter = Linear;
                            };
                        ]]
                        if (shaderModel < 3) or not j[v].stochastic then
                            result.body = result.body..[[
                                float4 controlTexel_]]..i..[[_]]..v..[[_bump = tex2D(controlSampler_]]..i..[[_]]..v..[[_bump, PS.TexCoord*controlScale_]]..i..[[_]]..v..[[);
                            ]]
                        else
                            result.body = result.body..[[
                                float4 controlTexel_]]..i..[[_]]..v..[[_bump = tex2DStochastic(controlSampler_]]..i..[[_]]..v..[[_bump, PS.TexCoord*controlScale_]]..i..[[_]]..v..[[);
                            ]]
                        end
                    end
                    for m = 1, iteration, 1 do
                        result.body = result.body..[[
                            sampledTexel_]]..i..[[ = lerp(sampledTexel_]]..i..[[, controlTexel_]]..i..[[_]]..v..[[, controlTexel_]]..i..[[.]]..channel..[[);
                        ]]
                    end
                    if j[v].bump then
                        result.body = result.body..[[
                            sampledTexel_]]..i..[[.rgb *= controlTexel_]]..i..[[_]]..v..[[_bump.rgb;
                        ]]
                    end
                end
            end
            result.body = result.body..[[
                sampledTexel_]]..i..[[.rgb *= ]]..(1/iteration)..[[;
            ]]
            if j.bump then
                result.body = result.body..[[
                    sampledTexel_]]..i..[[.rgb *= controlTexel_]]..i..[[_bump.rgb;
                ]]
            end
            result.body = result.body..[[
                sampledTexel_]]..i..[[.a = controlTexel_]]..i..[[.a;
            ]]
            result.footer = result.footer..((not sampled and [[
                float4 sampledTexel = sampledTexel_]]..i..[[;
            ]]) or [[
                sampledTexel = lerp(sampledTexel, sampledTexel_]]..i..[[, sampledTexel_]]..i..[[.a);
            ]])
            sampled = true
        end
        return result
    end,

    exec = function(shaderMaps)
        if not shaderMaps or (table.length(shaderMaps) <= 0) then return false end
        local query = shaderRW.buffer[identity].prepare(shaderMaps, 3)
        return shaderRW.create({diffuse = true, emissive = true})..[[
        // Variables //
        float anisotropy = 1;
        ]]..query.config..[[

        // Inputs //
        struct VSInput {
            float3 Position : POSITION0;
            float2 TexCoord : TEXCOORD0;
            float4 Diffuse : COLOR0;
        };
        struct PSInput {
            float4 Position : POSITION0;
            float2 TexCoord : TEXCOORD0;
            float4 Diffuse : COLOR0;
        };
        struct Export {
            float4 World : COLOR0;
            float4 Diffuse : COLOR1;
            float4 Emissive : COLOR2;
        };

        // Handlers //
        PSInput VSHandler(VSInput VS) {
            PSInput PS = (PSInput)0;
            PS.Position = MTACalcScreenPosition(VS.Position);
            PS.TexCoord = VS.TexCoord;
            PS.Diffuse = MTACalcGTABuildingDiffuse(VS.Diffuse);
            return PS;
        }
    
        Export PSHandler(PSInput PS) : COLOR0 {
            Export output;
            ]]..query.body..query.footer..[[
            if (vRenderingEnabled) {
                output.Diffuse = vEmissiveSource ? 0 : sampledTexel;
                output.Emissive = vEmissiveSource ? sampledTexel : 0;
            }
            else {
                output.Diffuse = 0;
                output.Emissive = 0;
            }
            ]]..shaderRW.prelight(shaderMaps)..[[
            sampledTexel.rgb *= MTAGetWeatherValue();
            output.World = saturate(sampledTexel);
            return output;
        }

        // Techniques //
        technique ]]..identity..[[ {
            pass P0 {
                AlphaBlendEnable = true;
                SRGBWriteEnable = false;
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