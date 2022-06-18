----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: tex_shadower.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Texture Shadower ]]--
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

local identifier = "Assetify_TextureShadower"
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

shaderRW[identifier] = function()
    return depDatas..[[
    /*-----------------
    -->> Variables <<--
    -------------------*/

    float shadowSize = 0.006;
    float4 shadowColor = float4(0, 0, 0, 1);
    float4 baseColor = float4(1, 1, 1, 1);
    bool vWeatherBlendEnabled = false;
    texture baseTexture;
    struct PSInput {
        float4 Position : POSITION0;
        float2 TexCoord : TEXCOORD0;
    };
    sampler baseSampler = sampler_state {
        Texture = baseTexture;
    };


    /*----------------
    -->> Handlers <<--
    ------------------*/

    float4 PSHandler(PSInput PS) : COLOR0 {
        float4 sampledTexel = tex2D(baseSampler, PS.TexCoord);
        float4 shadowTexel = tex2D(baseSampler, PS.TexCoord - float2(shadowSize*-0.5, shadowSize)) + tex2D(baseSampler, PS.TexCoord - float2(shadowSize*0.5, shadowSize));
        shadowTexel.rgb = 1;
        shadowTexel *= shadowColor;
        sampledTexel.rgb = pow(sampledTexel.rgb*1.5, 1.5);
        sampledTexel += shadowTexel;
        sampledTexel *= baseColor;
        if (vWeatherBlendEnabled) sampledTexel.a *= MTAGetWeatherValue();
        return saturate(sampledTexel);
    }


    /*------------------
    -->> Techniques <<--
    --------------------*/

    technique ]]..identifier..[[
    {
        pass P0
        {
            AlphaRef = 1;
            AlphaBlendEnable = true;
            FogEnable = false;
            PixelShader = compile ps_2_0 PSHandler();
        }
    }

    technique fallback {
        pass P0 {}
    }
    ]]
end