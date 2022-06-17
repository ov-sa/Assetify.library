----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: light_planar.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Planar Light ]]--
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

local identifier = "Assetify_LightPlanar"
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

    float lightResolution = 1;
    float3 lightOffset = float3(0, 0, 0);
    float4 lightColor = float4(1, 1, 1, 1);
    texture baseTexture;
    struct VSInput {
        float4 Position : POSITION0;
        float4 Diffuse : COLOR0;
        float2 TexCoord : TEXCOORD0;
    };
    struct PSInput {
        float4 Position : POSITION0;
        float2 TexCoord : TEXCOORD0;
    };
    struct Export {
        float4 World : COLOR0;
        float4 Diffuse : COLOR1;
        float4 Emissive : COLOR2;
    };
    sampler baseSampler = sampler_state {
        Texture = baseTexture;
    };
    sampler vSource0Sampler = sampler_state {
        Texture = (vSource0);
    };
    sampler vSource1Sampler = sampler_state {
        Texture = (vSource1);
    };

    
    /*----------------
    -->> Handlers <<--
    ------------------*/

    PSInput VSHandler(VSInput VS) {
        PSInput PS = (PSInput)0;
        float4 position = VS.Position*lightResolution;
        float4x4 positionMatrix = MTACreateTranslationMatrix(lightOffset);
        float4x4 gWorldFix = mul(gWorld, positionMatrix);
        float4x4 worldViewMatrix = mul(gWorldFix, gView);
        float4 worldViewPosition = float4(worldViewMatrix[3].xyz + position.xzy - lightOffset.xzy, 1);
        worldViewPosition.xyz += 1.5*mul(normalize(gCameraPosition - lightOffset), gView).xyz;
        PS.Position = mul(worldViewPosition, gProjection);
        PS.TexCoord = float2(VS.TexCoord.x, VS.TexCoord.y);
        return PS;
    }
    
    Export PSHandler(PSInput PS) : COLOR0 {
        Export output;
        float4 sampledTexel = tex2D(baseSampler, PS.TexCoord.xy);
        sampledTexel.rgb = pow(sampledTexel.rgb*1.5, 1.5);
        output.Diffuse = 0;
        if (vRenderingEnabled) {
            float4 sourceTex = vSource1Enabled ? tex2D(vSource1Sampler, PS.TexCoord.xy) : tex2D(vSource0Sampler, PS.TexCoord.xy);
            sampledTexel.rgb *= lerp(sampledTexel.rgb, sourceTex.rgb*2.5, 0.95);
        } else {
            output.Emissive = 0;
        }
        sampledTexel *= lightColor;
        sampledTexel.rgb *= 1 + (1 - MTAGetWeatherValue());
        if (vRenderingEnabled) output.Emissive = sampledTexel;
        output.World = saturate(sampledTexel);
        return output;
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
            VertexShader = compile vs_2_0 VSHandler();
            PixelShader = compile ps_2_0 PSHandler();
        }
    }

    technique fallback {
        pass P0 {}
    }
    ]]
end