----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: tex_exporter.lua
     Author: vStudio
     Developer(s): Aviril, Tron
     DOC: 19/10/2021
     Desc: Texture Exporter ]]--
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

local identifier = "Assetify_TextureExporter"
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

    texture renderTex;
    texture renderLayer <string renderTarget = "yes";>;
    struct PSInput {
        float4 Position : POSITION0;
        float4 Diffuse : COLOR0;
        float2 TexCoord : TEXCOORD0;
    };
    struct Export {
        float4 World : COLOR0;
        float4 Render : COLOR1;
    };
    sampler baseSampler = sampler_state {
        Texture = (gTexture0);
    };
    sampler renderSampler = sampler_state {
        Texture = renderTex;
    };


    /*----------------
    -->> Handlers <<--
    ------------------*/

    Export PSHandler(PSInput PS) {
        Export output;
        float4 sampledTexel = tex2D(baseSampler, PS.TexCoord);
        sampledTexel.rgb *= MTAGetWeatherValue();
        output.World = saturate(sampledTexel);
        if (renderTex) {
            output.Render = sampledTexel;
        } else {
            float4 renderTexel = tex2D(renderSampler, PS.TexCoord);
            output.Render = renderTexel;
        }
        return output;
    }


    /*------------------
    -->> Techniques <<--
    --------------------*/

    technique ]]..identifier..[[
    {
        pass P0
        {
            AlphaBlendEnable = true;
            PixelShader = compile ps_2_0 PSHandler();
        }
    }

    technique fallback {
        pass P0 {}
    }
    ]]
end