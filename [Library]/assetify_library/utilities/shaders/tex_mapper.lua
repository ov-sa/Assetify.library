----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: tex_mapper.lua
     Server: -
     Author: OvileAmriam
     Developer(s): Aviril, Tron
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Texture Changer ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    file = file,
    string = string
}


-------------------
--[[ Variables ]]--
-------------------

local identifier = "Assetify_TextureMapper"
local samplingIteration = 3
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

shaderRW[identifier] = function(shaderMaps)
    if not shaderMaps or (#shaderMaps <= 0) then return false end
    local isSamplingStage = false
    local controlVars, handlerBody, handlerFooter = [[
        sampler baseSampler = sampler_state {
            Texture = (gTexture0);
            MipFilter = Linear;
            MaxAnisotropy = gMaxAnisotropy*anisotropy;
            MinFilter = Anisotropic;
        };    
    ]], "", ""
    handlerBody = handlerBody..[[
        float4 baseTexel = tex2D(baseSampler, PS.TexCoord);
    ]]
    for i = #shaderMaps, 1, -1 do
        local j = shaderMaps[i]
        local isControlSampled = false
        for k = 1, #shader.defaultData.shaderChannels, 1 do
            local v, channel = shader.defaultData.shaderChannels[k].index, shader.defaultData.shaderChannels[k].channel
            if j[v] then
                if not isControlSampled then
                    if j.control then
                        controlVars = controlVars..[[
                            texture controlTex_]]..i..[[;
                            sampler controlSampler_]]..i..[[ = sampler_state { 
                                Texture = controlTex_]]..i..[[;
                                MipFilter = Linear;
                                MaxAnisotropy = gMaxAnisotropy*anisotropy;
                                MinFilter = Anisotropic;
                            };
                        ]]
                    end
                    handlerBody = handlerBody..[[
                        float4 controlTexel_]]..i..[[ = ]]..(((j.control) and [[tex2D(controlSampler_]]..i..[[, PS.TexCoord)]]) or [[baseTexel]])..[[;
                    ]]
                end
                controlVars = controlVars..[[
                    texture controlTex_]]..i..[[_]]..v..[[;
                    float controlScale_]]..i..[[_]]..v..[[ = ]]..(j[v].scale)..[[;
                    sampler controlSampler_]]..i..[[_]]..v..[[ = sampler_state { 
                        Texture = controlTex_]]..i..[[_]]..v..[[;
                        MipFilter = Linear;
                        MaxAnisotropy = gMaxAnisotropy*anisotropy;
                        MinFilter = Anisotropic;
                    };
                ]]
                handlerBody = handlerBody..[[
                    float4 controlTexel_]]..i..[[_]]..v..[[ = tex2D(controlSampler_]]..i..[[_]]..v..[[, PS.TexCoord*controlScale_]]..i..[[_]]..v..[[);
                ]]
                if not isControlSampled then
                    handlerBody = handlerBody..[[
                        float4 sampledTexel_]]..i..[[ = controlTexel_]]..i..[[;
                    ]]
                    isControlSampled = true
                end
                for m = 1, samplingIteration, 1 do
                    handlerBody = handlerBody..[[
                        sampledTexel_]]..i..[[ = lerp(sampledTexel_]]..i..[[, controlTexel_]]..i..[[_]]..v..[[, controlTexel_]]..i..[[.]]..channel..[[);
                    ]]
                end
            end
        end
        if isControlSampled then
            handlerBody = handlerBody..[[
                sampledTexel_]]..i..[[.rgb = sampledTexel_]]..i..[[.rgb*]]..(1/samplingIteration)..[[;
                sampledTexel_]]..i..[[.a = controlTexel_]]..i..[[.a;
            ]]
            handlerFooter = handlerFooter..((not isSamplingStage and [[
                float4 sampledTexel = sampledTexel_]]..i..[[;
            ]]) or [[
                sampledTexel = lerp(sampledTexel, sampledTexel_]]..i..[[, sampledTexel_]]..i..[[.a);
            ]])
            isSamplingStage = true
        end
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


    /*----------------
    -->> Handlers <<--
    ------------------*/

    float4 PSHandler(PSInput PS) : COLOR0 {
        ]]..handlerBody..handlerFooter..[[
        return saturate(sampledTexel);
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