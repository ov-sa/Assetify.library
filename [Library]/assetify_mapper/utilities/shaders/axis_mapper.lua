----------------------------------------------------------------
--[[ Resource: Assetify Mapper
     Script: utilities: shaders: axis_mapper.lua
     Author: vStudio
     Developer(s): Tron
     DOC: 25/03/2022
     Desc: Axis Changer ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    file = file
}


-------------------
--[[ Variables ]]--
-------------------

local identifier = "Assetify_AxisMapper"
local depDatas, dependencies = "", {
    "utilities/shaders/helper.fx"
}
for i, j in imports.pairs(dependencies) do
    local depData = imports.file:read(j)
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

    float3 baseColor = float4(1, 1, 1, 1);
    struct PSInput {
        float4 Diffuse : COLOR0;
        float2 TexCoord : TEXCOORD0;
    };


    /*----------------
    -->> Samplers <<--
    ------------------*/
    
    sampler baseSampler = sampler_state {
        Texture = (gTexture0);
    };


    /*----------------
    -->> Handlers <<--
    ------------------*/

    float4 PSHandler(PSInput PS) : COLOR0 {
        float4 baseTexel = tex2D(baseSampler, PS.TexCoord);
        float4 finalColor = baseTexel * PS.Diffuse;
        finalColor.rgb *= baseColor.rgb;
        return finalColor; 
    }


    /*------------------
    -->> Techniques <<--
    --------------------*/

    technique ]]..identifier..[[
    {
        pass P0 {
            PixelShader = compile ps_2_0 PSHandler();
        }
    }

    technique fallback {
        pass P0 {}
    }
    ]]
end