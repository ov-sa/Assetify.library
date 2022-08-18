static const float PI = 3.141592653589793f;
float4x4 gWorld : WORLD;
float4x4 gView : VIEW;
float4x4 gProjection : PROJECTION;
float4x4 gWorldView : WORLDVIEW;
float4x4 gWorldViewProjection : WORLDVIEWPROJECTION;
float4x4 gProjectionMainScene : PROJECTION_MAIN_SCENE;
float4x4 gViewMainScene : VIEW_MAIN_SCENE;
float4x4 gViewProjection : VIEWPROJECTION;
float4x4 gViewInverse : VIEWINVERSE;
float4x4 gWorldInverseTranspose : WORLDINVERSETRANSPOSE;
float4x4 gViewInverseTranspose : VIEWINVERSETRANSPOSE;

float gTime : TIME;
float4 gLightAmbient : LIGHTAMBIENT;
float4 gLightDiffuse : LIGHTDIFFUSE;
float4 gLightSpecular : LIGHTSPECULAR;
float3 gLightDirection : LIGHTDIRECTION;
float3 gCameraPosition : CAMERAPOSITION;
float3 gCameraDirection : CAMERADIRECTION;

int gDiffuseMaterialSource <string renderState="DIFFUSEMATERIALSOURCE";>;
int gSpecularMaterialSource <string renderState="SPECULARMATERIALSOURCE";>;
int gAmbientMaterialSource <string renderState="AMBIENTMATERIALSOURCE";>;
int gEmissiveMaterialSource <string renderState="EMISSIVEMATERIALSOURCE";>;

int gLighting <string renderState="LIGHTING";>;
float4 gGlobalAmbient <string renderState="AMBIENT";>;
int gFogEnable <string renderState="FOGENABLE";>;
float4 gFogColor <string renderState="FOGCOLOR";>;
float gFogStart <string renderState="FOGSTART";>;
float gFogEnd <string renderState="FOGEND";>;

float4 gMaterialAmbient <string materialState="Ambient";>;
float4 gMaterialDiffuse <string materialState="Diffuse";>;
float4 gMaterialSpecular <string materialState="Specular";>;
float4 gMaterialEmissive <string materialState="Emissive";>;
float gMaterialSpecPower <string materialState="Power";>;

float2 vResolution = false;
bool vEmissiveSource = false;
bool vRenderingEnabled = false;
bool vSource1Enabled = false;
bool vSource2Enabled = false;
bool vDynamicSkyEnabled = false;
bool vDynamicWaterEnabled = false;
bool vTimeSync = false;
float vServerTick = 60*60*12;
float vMinuteDuration = 60;
float vWeatherBlend = false;
float3 vSunOffset = 1;
float2 vSunViewOffset = 1;
texture vSource0;
texture vSource1 <string renderTarget = "yes";>;
texture vSource2 <string renderTarget = "yes";>;
texture gDepthBuffer : DEPTHBUFFER;
int gMaxAnisotropy <string deviceCaps="MaxAnisotropy";>;
int gDeclNormal <string vertexDeclState="Normal";>;
texture gTexture0 <string textureState="0,Texture";>;
texture gTexture1 <string textureState="1,Texture";>;
texture gTexture2 <string textureState="2,Texture";>;
texture gTexture3 <string textureState="3,Texture";>;

int gLight0Enable <string lightEnableState="0,Enable";>;
int gLight1Enable <string lightEnableState="1,Enable";>;
int gLight2Enable <string lightEnableState="2,Enable";>;
int gLight3Enable <string lightEnableState="3,Enable";>;
int gLight4Enable <string lightEnableState="4,Enable";>;

int gLight0Type <string lightState="0,Type";>;
float4 gLight0Diffuse <string lightState="0,Diffuse";>;
float4 gLight0Specular <string lightState="0,Specular";>;
float4 gLight0Ambient <string lightState="0,Ambient";>;
float3 gLight0Position <string lightState="0,Position";>;
float3 gLight0Direction <string lightState="0,Direction";>;

int gLight1Type <string lightState="1,Type";>;
float4 gLight1Diffuse <string lightState="1,Diffuse";>;
float4 gLight1Specular <string lightState="1,Specular";>;
float4 gLight1Ambient <string lightState="1,Ambient";>;
float3 gLight1Position <string lightState="1,Position";>;
float3 gLight1Direction <string lightState="1,Direction";>;

int gLight2Type <string lightState="2,Type";>;
float4 gLight2Diffuse <string lightState="2,Diffuse";>;
float4 gLight2Specular <string lightState="2,Specular";>;
float4 gLight2Ambient <string lightState="2,Ambient";>;
float3 gLight2Position <string lightState="2,Position";>;
float3 gLight2Direction <string lightState="2,Direction";>;

int gLight3Type <string lightState="3,Type";>;
float4 gLight3Diffuse <string lightState="3,Diffuse";>;
float4 gLight3Specular <string lightState="3,Specular";>;
float4 gLight3Ambient <string lightState="3,Ambient";>;
float3 gLight3Position <string lightState="3,Position";>;
float3 gLight3Direction <string lightState="3,Direction";>;

int gLight4Type <string lightState="4,Type";>;
float4 gLight4Diffuse <string lightState="4,Diffuse";>;
float4 gLight4Specular <string lightState="4,Specular";>;
float4 gLight4Ambient <string lightState="4,Ambient";>;
float3 gLight4Position <string lightState="4,Position";>;
float3 gLight4Direction <string lightState="4,Direction";>;

int CUSTOMFLAGS
<
#ifdef GENERATE_NORMALS
    string createNormals = "yes";
#endif
    string skipUnusedParameters = "yes";
>;

float MTAUnlerp(float from, float to, float pos) {
    if (from == to) return 1;
    else return (pos - from) / (to - from);
}

float4 MTACalcScreenPosition(float3 InPosition) {
    return mul(float4(InPosition, 1), gWorldViewProjection);
}

float3 MTACalcWorldPosition(float3 InPosition) {
    return mul(float4(InPosition, 1), gWorld).xyz;
}

float3 MTACalcWorldNormal(float3 InNormal) {
    return mul(InNormal, (float3x3)gWorld);
}

float4 MTACalcGTABuildingDiffuse(float4 InDiffuse) {
    float4 OutDiffuse;
    if (!gLighting) OutDiffuse = InDiffuse;
    else
    {
        float4 ambient  = gAmbientMaterialSource  == 0 ? gMaterialAmbient  : InDiffuse;
        float4 diffuse  = gDiffuseMaterialSource  == 0 ? gMaterialDiffuse  : InDiffuse;
        float4 emissive = gEmissiveMaterialSource == 0 ? gMaterialEmissive : InDiffuse;
        OutDiffuse = gGlobalAmbient * saturate(ambient + emissive);
        OutDiffuse.a *= diffuse.a;
    }
    return OutDiffuse;
}

float4 MTACalcGTAVehicleDiffuse(float3 WorldNormal, float4 InDiffuse) {
    float4 ambient  = gAmbientMaterialSource  == 0 ? gMaterialAmbient  : InDiffuse;
    float4 diffuse  = gDiffuseMaterialSource  == 0 ? gMaterialDiffuse  : InDiffuse;
    float4 emissive = gEmissiveMaterialSource == 0 ? gMaterialEmissive : InDiffuse;
    float4 TotalAmbient = ambient * (gGlobalAmbient + gLightAmbient);
    float DirectionFactor = max(0, dot(WorldNormal, -gLightDirection));
    float4 TotalDiffuse = (diffuse * gLightDiffuse * DirectionFactor);
    float4 OutDiffuse = saturate(TotalDiffuse + TotalAmbient + emissive);
    OutDiffuse.a *= diffuse.a;
    return OutDiffuse;
}

float4 MTACalcGTACompleteDiffuse(float3 WorldNormal, float4 InDiffuse) {
    float4 ambient  = gAmbientMaterialSource  == 0 ? gMaterialAmbient  : InDiffuse;
    float4 diffuse  = gDiffuseMaterialSource  == 0 ? gMaterialDiffuse  : InDiffuse;
    float4 emissive = gEmissiveMaterialSource == 0 ? gMaterialEmissive : InDiffuse;
    float4 TotalAmbient = ambient * (gGlobalAmbient + gLightAmbient);
    float DirectionFactor = 0;
    float4 TotalDiffuse = 0;
    if (gLight1Enable) {
        DirectionFactor = max(0, dot(WorldNormal, -gLight1Direction));
        TotalDiffuse += (gLight1Diffuse*DirectionFactor);
    }
    if (gLight2Enable) {
        DirectionFactor = max(0, dot(WorldNormal, -gLight2Direction));
        TotalDiffuse += (gLight2Diffuse*DirectionFactor);
    }
    if (gLight3Enable) {
        DirectionFactor = max(0, dot(WorldNormal, -gLight3Direction));
        TotalDiffuse += (gLight3Diffuse*DirectionFactor);
    }
    if (gLight4Enable) {
        DirectionFactor = max(0, dot(WorldNormal, -gLight4Direction));
        TotalDiffuse += (gLight4Diffuse*DirectionFactor);
    }	
    TotalDiffuse *= diffuse;
    float4 OutDiffuse = saturate(TotalDiffuse + TotalAmbient + emissive);
    OutDiffuse.a *= diffuse.a;
    return OutDiffuse;
}

float4 MTACalcGTADynamicDiffuse(float3 WorldNormal) {
    float DirectionFactor = 0;
    float4 TotalDiffuse = 0;
    if (gLight1Enable) {
        DirectionFactor = max(0, dot(WorldNormal, -gLight1Direction));
        TotalDiffuse += (gLight1Diffuse*DirectionFactor);
    }
    if (gLight2Enable) {
    DirectionFactor = max(0, dot(WorldNormal, -gLight2Direction));
    TotalDiffuse += (gLight2Diffuse*DirectionFactor);
                     }
    if (gLight3Enable) {
        DirectionFactor = max(0, dot(WorldNormal, -gLight3Direction));
        TotalDiffuse += (gLight3Diffuse*DirectionFactor);
    }
    if (gLight4Enable) {
        DirectionFactor = max(0, dot(WorldNormal, -gLight4Direction));
        TotalDiffuse += (gLight4Diffuse*DirectionFactor);
    }	
    float4 OutDiffuse = saturate(TotalDiffuse);
    return OutDiffuse;
}

float3 MTACalculateCameraDirection(float3 CamPos, float3 InWorldPos) {
    return normalize(InWorldPos - CamPos);
}

float MTACalcCameraDistance(float3 CamPos, float3 InWorldPos) {
    return distance(InWorldPos, CamPos);
}

float MTACalculateSpecular(float3 CamDir, float3 LightDir, float3 SurfNormal, float SpecPower) {
    LightDir = normalize(LightDir);
    SurfNormal = normalize(SurfNormal);
    float3 halfAngle = normalize(-CamDir - LightDir);
    float r = dot(halfAngle, SurfNormal);
    return pow(saturate(r), SpecPower);
}

float3 MTAApplyFog(float3 texel, float linDistance) {
    if (!gFogEnable) return texel;
    float FogAmount = (linDistance - gFogStart)/(gFogEnd - gFogStart);
    texel.rgb = lerp(texel.rgb, gFogColor.rgb, saturate(FogAmount));
    return texel;
}

void MTAFixUpNormal(in out float3 OutNormal) {
    if (OutNormal.x == 0 && OutNormal.y == 0 && OutNormal.z == 0)
        OutNormal = float3(0, 0, 1);
}

float4x4 MTACreateMatrix(float3 position, float3 rotation) {
    float sYaw = sin(rotation.x), sPitch = sin(rotation.y), sRoll = sin(rotation.z);
    float cYaw = cos(rotation.x), cPitch = cos(rotation.y), cRoll = cos(rotation.z);
    float4x4 cMatrix = {
        float4((cRoll*cPitch) - (sRoll*sYaw*sPitch), (cPitch*sRoll) + (cRoll*sYaw*sPitch), -cYaw*sPitch, 0),
        float4(-cYaw*sRoll, cRoll*cYaw, sYaw, 0),
        float4((cRoll*sPitch) + (cPitch*sRoll*sYaw), (sRoll*sPitch) - (cRoll*cPitch*sYaw), cYaw*cPitch, 0),
        float4(position.x, position.y, position.z, 1)
    };
    return cMatrix;
}

float4x4 MTACreatePositionMatrix(float3 position) {
    float4x4 cMatrix = {
        float4(1, 0, 0, 0),
        float4(0, 1, 0, 0),
        float4(0, 0, 1, 0),
        float4(position.x, position.y, position.z, 1)
    };
    return cMatrix;
}

float MTAGetWeatherTick() {
    return vTimeSync ? vServerTick + gTime : vServerTick;
}

float MTAGetWeatherCycle() {
    return (MTAGetWeatherTick()/(60*vMinuteDuration))%24;
}

float MTAGetWeatherValue() {
    float cycle = MTAGetWeatherCycle();
    float weatherClamp = 0.0025;
    float weatherValue = cycle/12;
    return (cycle >= 12) ? max(weatherClamp, 2 - weatherValue) : max(weatherClamp, weatherValue);
}

float3 MTAGetWeatherColor() {
    return float3(1, 1, 1);
}