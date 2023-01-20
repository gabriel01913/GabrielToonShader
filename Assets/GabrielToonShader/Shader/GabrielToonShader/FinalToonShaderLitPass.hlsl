#ifndef FINALTOON_LITPASS
#define FINALTOON_LITPASS

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

// GLES2 has limited amount of interpolators
#if defined(_PARALLAXMAP) && !defined(SHADER_API_GLES)
#define REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR
#endif

#if (defined(_NORMALMAP) || (defined(_PARALLAXMAP) && !defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR))) || defined(_DETAIL)
#define REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR
#endif

struct Inputs
{
    float4 positionOS         : POSITION;
    float3 normalOS           : NORMAL;
    float4 tangentOS          : TANGENT;
    float2 uv0                : TEXCOORD0;
    #if defined(LIGHTMAP_ON)
    float2 uv1                : TEXCOORD1;
    #else
    half3 uv1                : TEXCOORD1;
    #endif
    float2 uv2                : TEXCOORD2;
    float2 uv3                : TEXCOORD3;    
    #if defined (_CUSTOM_UV)
    float2 uv4                : TEXCOORD4;
    float2 uv5                : TEXCOORD5;
    float2 uv6                : TEXCOORD6;
    float2 uv7                : TEXCOORD7;
    #endif
    float4 color              : COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Interpolators
{      
    float2 uv0                          : TEXCOORD0;
    #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
        float3 positionWS               : TEXCOORD1;
    #endif
        half3 normalWS                 : TEXCOORD2;
    #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
        half4 tangentWS                : TEXCOORD3;    // xyz: tangent, w: sign
    #endif
        float3 viewDirWS                : TEXCOORD4;

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        half4 fogFactorAndVertexLight   : TEXCOORD5; // x: fogFactor, yzw: vertex light
    #else
        half  fogFactor                 : TEXCOORD5;
    #endif

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        float4 shadowCoord              : TEXCOORD6;
    #endif

    #if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
        half3 viewDirTS                : TEXCOORD7;
    #endif
    #if defined(LIGHTMAP_ON)
    float2  uv1 : TEXCOORD8;
    #else
    half3  uv1 : TEXCOORD8;
    #endif
    float2  uv2 : TEXCOORD9;
    float4 positionOS         : TEXCOORD10;
    float3 normalOS            : NORMAL;
    float4 tangentOS          : TANGENT;
    float4 positionCS               : SV_POSITION;
    float4 color                :COLOR;    
    float2 uv3                : TEXCOORD11;
    #if defined (_CUSTOM_UV)
    float2 uv4                : TEXCOORD12;
    float2 uv5                : TEXCOORD13;
    float2 uv6                : TEXCOORD14;
    float2 uv7                : TEXCOORD15;
    #endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO  
};

struct DotData{
    half NdL; //lambert - 1st shade
    half NdL2; //lambert - 2st shade
    half VdN; //Rim light(fresnel effect)
    half HdN; //specular Bling Phong
};

struct DirectionVectors{
    half3 fowardDir;
    half3 upDir;
    half3 rightDir;
};

struct LightInputs{
    half3 mainLightDirection;
    half3 mainLightColor;
    half mainLightSAtt;
    half3 addLightColor;
    half addLightSAtt;
    half addLightDAtt;
    half3 staticLightMap;
    half3 dynamicLightMap;    
};

struct ReplaceColor{
    float3 currentColor;
    float3 previousColor;
    float currentDistance;
    float previousDistance;
};

struct MainColors{
    half3 lightColor;
    half3 shadowColor;
    half3 shadow2Color;
    half3 specularColor;
    half3 fresnelColor; 
    half3 emissionColor;    
};

half2 CustomUV(float input, Interpolators output)
{
    half2 uv = half2(0,0);
    #if defined (_CUSTOM_UV)
    switch(input)
    {
        case 0:
            uv = output.uv0.xy;
        break;
        case 1:
            uv = output.uv1.xy;
        break;
        case 2:
            uv = output.uv2.xy;
        break;
        case 3:
            uv = output.uv3.xy;
        break;
        case 4:
            uv = output.uv4.xy;
        break;
        case 5:
            uv = output.uv5.xy;
        break;
        case 6:
            uv = output.uv6.xy;
        break;
        case 7:
            uv = output.uv7.xy;
        break;
    }
    #endif
    return uv;
}

half3 ColorAjust(half3 currentColor, half4 lightColor , half intensity, half4 tint, half saturation){
    half3 color = (currentColor * lightColor.rgb * intensity * tint.rgb).rgb;
    half3 dotDesaturate = dot( color, half3( 0.299, 0.587, 0.114 ));
	color = lerp( color, dotDesaturate.xxx, ( 1.0 - saturation ) );
    return color;
}

DotData DotCreation(VertexPositionInputs vertexInput, VertexNormalInputs normalInputs, DirectionVectors dirVectors, LightInputs light)
{
    DotData dotIpunts;
    float3 normalWS = normalize(normalInputs.normalWS);
    float3 positionWS = vertexInput.positionWS;
    float3 lightDirWS = light.mainLightDirection;
    float3 viewDirWS = normalize(_WorldSpaceCameraPos - vertexInput.positionWS);
    float3 specularDir = reflect(-lightDirWS, normalInputs.normalWS);
    float3 halfVector = normalize(lightDirWS  + viewDirWS);

    //lambert  
    dotIpunts.NdL = clamp(0,1,dot(normalWS, lightDirWS));

    //specular Bling Phong
    dotIpunts.HdN = saturate(dot(halfVector, normalWS)) * (dotIpunts.NdL > 0);

    //Rim light(fresnel effect)
    dotIpunts.VdN = 1 - dot(viewDirWS, normalWS);

    return dotIpunts;
}

DotData DotAjusts(DotData dotInputs, Interpolators output)
{
    float specularSize = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _SpecularSize);
    dotInputs.HdN = pow(dotInputs.HdN, pow(2, specularSize));

    half4 ilm = half4(0,0,0,0);
    #if defined(_GGSTRIVEWORKFLOW)        
        #if defined(_CUSTOM_UV)
        float iLMUV = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _ILMUV);
        half2 uvilm = CustomUV(iLMUV, output);
        ilm = tex2D(_ILM, uvilm.xy);
        #else
        ilm = tex2D(_ILM, output.uv0.xy);
        #endif
        half ilmG = ilm.g;
        ilmG = pow(ilmG, 1.1/2.2);
        ilmG = clamp(((ilmG * 2) - 1),0,1);
        if(ilmG > 0)
        {
            dotInputs.NdL = (dotInputs.NdL + ilmG);

        }else
        {
            dotInputs.NdL = (dotInputs.NdL * ilmG);
        }

        //specular Bling Phong
        dotInputs.HdN = dotInputs.HdN < 0.1 ? 0 : 1;
        dotInputs.HdN = saturate( ( 1.0 - ( ( 1.0 - dotInputs.HdN) / max( ilm.b, 0.00001) )));
        half4 baseText = half4(0,0,0,0);
        #if defined(_CUSTOM_UV)
        float baseColorUV = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _BaseColorUV);
        half2 baseUV = CustomUV(baseColorUV, output);
        baseText = tex2D(_BaseColor, baseUV.xy);
        #else
        baseText = tex2D(_BaseColor, output.uv0.xy);
        #endif
        half baseA = pow(baseText.a, 1.1/2.2);
        baseA = clamp(((baseA * 2) - 1),0,1);
        dotInputs.VdN = dotInputs.VdN * baseText.a;
    #endif

    float shadeSmoothStep = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _ShadeSmoothStep);
    float shadowOffset = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _ShadowOffset);
    float shadow2Offset = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _Shadow2Offset);

    dotInputs.NdL2 = smoothstep(0, shadeSmoothStep, dotInputs.NdL - shadow2Offset);
    dotInputs.NdL = smoothstep(0, shadeSmoothStep, dotInputs.NdL - shadowOffset);

    float fresnelSize = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _FresnelSize);
    float fresnelThreshHold = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _FresnelThreshHold);
    dotInputs.VdN = dotInputs.VdN + fresnelSize;
    dotInputs.VdN = smoothstep(fresnelThreshHold, 1, dotInputs.VdN);

    return dotInputs;
}

LightInputs GetLightInputs(InputData inputData, Interpolators output)
{
    LightInputs lightInputs = (LightInputs)0;
    ReplaceColor repColor = (ReplaceColor)0;

    //Additional Light setup;
    Light additionalLight = (Light)0;
    additionalLight.shadowAttenuation = 1;

    //main light getter    
    half4 mainLightShadowMask = CalculateShadowMask(inputData);
    SurfaceData surface = (SurfaceData)0;
    AmbientOcclusionFactor aoFactor = CreateAmbientOcclusionFactor(inputData, surface);    
    Light mainLight = GetMainLight(inputData, mainLightShadowMask, aoFactor);

    //LightLayers
    uint meshRenderingLayers = GetMeshRenderingLightLayer();    

    #if defined(_ADDITIONAL_LIGHTS)

        uint pixelLightCount = GetAdditionalLightsCount();

        #if USE_CLUSTERED_LIGHTING
        for (uint lightIndex = 0; lightIndex < min(_AdditionalLightsDirectionalCount, MAX_VISIBLE_LIGHTS); lightIndex++)
        {
            Light light = GetAdditionalLight(lightIndex, inputData, mainLightShadowMask, aoFactor);
            additionalLight.shadowAttenuation *= light.shadowAttenuation;
            additionalLight.distanceAttenuation += light.distanceAttenuation;
            half NdotL = saturate(dot(inputData.normalWS, light.direction));
            half3 radiance = light.color * (light.distanceAttenuation * light.shadowAttenuation) * NdotL;        
            additionalLight.distanceAttenuation += (light.distanceAttenuation * light.shadowAttenuation) * NdotL;
            if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
            {
                #if defined(_ADDITIONAL_LIGHT_REPLACE)                 
                    half3 colorRamp  = additionalLight.color + radiance;
                    half ramp = max(colorRamp.x, colorRamp.y);
                    ramp = max(ramp, colorRamp.z);
                    ramp = step(_LightBlend,ramp);
                    ramp = ramp * NdotL;
                    if(lightIndex)
                    {
                        repColor.currentColor = light.color;
                        repColor.currentDistance = light.distanceAttenuation;
                    }
                    else
                    {
                        additionalLight.color = light.color * ramp;
                        repColor.previousDistance = light.distanceAttenuation;
                        repColor.previousColor = light.color;
                                        
                    }                    
                    if(repColor.currentDistance > repColor.previousDistance)
                    {
                        additionalLight.color = light.color * ramp;
                        repColor.previousDistance = repColor.currentDistance;
                        repColor.previousColor = repColor.currentColor;
                    }
                    else if((repColor.currentDistance - repColor.previousDistance ) >= 0.2)
                    {
                        additionalLight.color += repColor.currentColor * ramp;
                        repColor.previousDistance = repColor.currentDistance - repColor.previousDistance;
                        repColor.previousColor = repColor.currentColor;                 
                    }
                #else
                    additionalLight.color += radiance;
                #endif
            }
        }
        #endif

        
        LIGHT_LOOP_BEGIN(pixelLightCount)
            Light light = GetAdditionalLight(lightIndex, inputData, mainLightShadowMask, aoFactor);
            additionalLight.shadowAttenuation *= light.shadowAttenuation;
            additionalLight.distanceAttenuation += light.distanceAttenuation;
            half NdotL = saturate(dot(inputData.normalWS, light.direction));
            half3 radiance = light.color * (light.distanceAttenuation * light.shadowAttenuation) * NdotL;        
            additionalLight.distanceAttenuation += (light.distanceAttenuation * light.shadowAttenuation) * NdotL;            
            if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
            {
                #if defined(_ADDITIONAL_LIGHT_REPLACE)
                    if(lightIndex)
                    {
                        repColor.currentColor = light.color;
                        repColor.currentDistance = light.distanceAttenuation;
                    }
                    else
                    {
                        additionalLight.color = light.color;
                        repColor.previousDistance = light.distanceAttenuation;
                        repColor.previousColor = light.color;                                        
                    }                    
                    if(repColor.currentDistance > repColor.previousDistance)
                    {
                        additionalLight.color = light.color;
                        repColor.previousDistance = repColor.currentDistance;
                        repColor.previousColor = repColor.currentColor;
                    }
                    else if((repColor.currentDistance - repColor.previousDistance ) >= 0.2)
                    {
                        additionalLight.color += repColor.currentColor;
                        repColor.previousDistance = repColor.currentDistance - repColor.previousDistance;
                        repColor.previousColor = repColor.currentColor;                 
                    }
                #else
                    additionalLight.color += radiance;
                #endif
            }              
        LIGHT_LOOP_END
    #endif
    
    lightInputs.mainLightDirection = mainLight.direction;
    lightInputs.mainLightColor = mainLight.color;
    lightInputs.mainLightSAtt = mainLight.shadowAttenuation;
    lightInputs.addLightColor = additionalLight.color;
    lightInputs.addLightSAtt = additionalLight.shadowAttenuation;
    lightInputs.addLightDAtt = additionalLight.distanceAttenuation;
    #ifdef LIGHTMAP_ON
    half3 staticLightMap = SampleLightmap(output.uv1.xy, output.uv2.xy, inputData.normalWS.xyz);
    lightInputs.staticLightMap = staticLightMap;
    #endif
    half3 dynamicLightMap = SampleSHVertex(output.normalWS);    
    lightInputs.dynamicLightMap = dynamicLightMap;

    return lightInputs;
}

float3 DistortionVertex(float3 vertexPos)
{
    float3 output;
    float3 cameraDir = (-1 * mul((float3x3)unity_WorldToObject, transpose(mul(unity_ObjectToWorld, UNITY_MATRIX_I_V)) [2].xyz));    
    float3 vertexDir = TransformObjectToWorldDir(vertexPos);
    float vertexLenght = length(vertexPos);
    float3 offsetDir = (vertexDir * vertexLenght);
    float3 projection = cameraDir * dot(offsetDir, cameraDir) / dot(cameraDir, cameraDir);
    float distortionFactor = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _DistortionFactor);
    float factor = lerp(0, 0.9, distortionFactor);
    float3 result = offsetDir - (projection * factor);
    output = TransformWorldToObjectDir(GetCameraRelativePositionWS(result)) * length(result);    
    return output;
}

float2 RotationUV(float2 UV, float Rotation)
{    
    float2 UVOutput = 0;
    UV.xy -=0.5;
    float s = -sin ( Rotation);
    float c = cos ( Rotation);
    float2x2 rotationMatrix = float2x2( c, -s, s, c);
    rotationMatrix *=0.5;
    rotationMatrix +=0.5;
    rotationMatrix = rotationMatrix * 2-1;
    UVOutput.xy = mul (UV.xy, rotationMatrix );
    UVOutput.xy += 0.5;
    return UVOutput;
}

half invLerp(half a, half b, half v)
{
    return (v - a) / (b - a);
}

half RemapValue(half value, half sourceMin, half sourceMax , half destinyMin, half destenyMax)
{
    half Out = destinyMin + (value - sourceMin) * (destenyMax - destinyMin) / (sourceMax - sourceMin);
    half t = invLerp(sourceMin, sourceMax, value);
    half result = clamp(lerp(destinyMin, destenyMax, t), destinyMin, destenyMax);
    return Out;
}

half3 LightsColor(LightInputs lightInputs)
{
    half3 color = half3(0,0,0);
    lightInputs.mainLightColor = lerp(lightInputs.mainLightColor * 0.5, lightInputs.mainLightColor, lightInputs.mainLightSAtt);
    half3 ramp = (1 - lightInputs.addLightDAtt) * lightInputs.mainLightSAtt ;
    half3 ramp2 = lightInputs.mainLightColor * ramp ;
    half3 ramp3 = lightInputs.addLightColor + lightInputs.mainLightColor ;
    color = ramp3;    
    return color;
}

MainColors GetMainColors(InputData inputData, half3 lightsColor, Interpolators output, DotData dotInputs)
{
    MainColors colors;
    half4 white = half4(1,1,1,1);
    #if defined(_CUSTOM_UV)
    float baseColorUV = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _BaseColorUV);
    half2 baseUV = CustomUV(baseColorUV , output);
    float shadowColorUV = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _ShadowColorUV);
    half2 shadeUV = CustomUV( shadowColorUV, output); 
    float customEmissionUV = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _EmissionUV);   
    half2 emissionUV = CustomUV(customEmissionUV, output);
    half4 baseText = tex2D(_BaseColor, baseUV.xy);
    half4 shadeText = tex2D(_ShadowColor, shadeUV.xy);  
    half4 emission = tex2D(_Emission, emissionUV.xy);
    #else
    half4 baseText = tex2D(_BaseColor, output.uv0.xy);
    half4 shadeText = tex2D(_ShadowColor, output.uv0.xy);    
    half4 emission = tex2D(_Emission, output.uv0.xy);
    #endif
    half3 specularBase = baseText.rgb;
    specularBase = min(baseText, dotInputs.HdN).rgb;
    #if defined(_GGSTRIVEWORKFLOW)
        #if defined(_CUSTOM_UV)
        float customILMUV = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _ILMUV);
        half2 ilmUV = CustomUV(customILMUV , output);
        half3 ilm = tex2D(_ILM, ilmUV.xy).rgb;
        #else
        half3 ilm = tex2D(_ILM, output.uv0.xy).rgb;
        #endif
        shadeText = baseText * 0.5;
        specularBase = specularBase * ilm.r;
    #endif
    float specularIntensity = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _SpecularIntensity);
    float4 specularTint = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _SpecularTint);
    float specularSaturation = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _SpecularSaturation);     
    colors.specularColor = ColorAjust(specularBase, white , specularIntensity, specularTint , specularSaturation);

    float specular = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _Specular);
    half3 baseSpecular =  (colors.specularColor * specular) + baseText.rgb;

    float baseIntensity = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _BaseIntensity);
    float4 baseTint = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _BaseTint);
    float baseSaturation = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _BaseSaturation);  
    colors.lightColor = ColorAjust(baseSpecular, white , baseIntensity, baseTint , baseSaturation);  

    #if defined(_GGSTRIVEWORKFLOW)
    float shadowIntensity = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _ShadowIntensity);
    float4 shadowTint = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _ShadowTint);
    float shadowSaturation = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _ShadowSaturation); 
    colors.shadowColor = ColorAjust(shadeText.rgb, white , shadowIntensity, shadowTint , shadowSaturation);
    #else
    float shadowIntensity = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _ShadowIntensity);
    float4 shadowTint = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _ShadowTint);
    float shadowSaturation = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _ShadowSaturation); 
    colors.shadowColor = ColorAjust(baseText.rgb, white , shadowIntensity, shadowTint , shadowSaturation);
    #endif

    half4 blendOpSrc = half4(0,0,0,0);
	half4 blendOpDest = half4(baseSpecular * shadeText.rgb,1) ;
	half4 blendSoft = lerp(blendOpDest, 2.0f * blendOpDest * blendOpSrc + blendOpDest * blendOpDest * (1.0f - 2.0f * blendOpSrc),0.5);

    float shadow2Intensity = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _Shadow2Intensity);
    float4 shadow2Tint = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _Shadow2Tint);
    float shadow2Saturation = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _Shadow2Saturation);
    colors.shadow2Color = ColorAjust(blendSoft.rgb , white , shadow2Intensity, shadow2Tint, shadow2Saturation);

    float fresnelIntensity = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _FresnelIntensity);
    float4 fresnelTint = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _FresnelTint);
    float fresnelSaturation = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _FresnelSaturation);
    colors.fresnelColor = ColorAjust(colors.lightColor, white , _FresnelIntensity, _FresnelTint, _FresnelSaturation);

    float emissionIntensity = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _EmissionIntensity);
    float4 emissionTint = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _EmissionTint);
    float emissionSaturation = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _EmissionSaturation);
    colors.emissionColor = ColorAjust(emission.rgb, white , emissionIntensity, emissionTint, emissionSaturation);
    return colors;
}

half ShadowMask(Interpolators output, DotData dotInputs, LightInputs lightInputs, float shadow2Ramp)
{    
    #if defined(_CUSTOM_UV)
    float faceShadowMaskUV = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _FaceShadowMaskUV);
    half2 faceShUV = CustomUV(faceShadowMaskUV , output);
    float2 uvFlipedX = float2(-faceShUV.x, faceShUV.y);
    float4 SM_Text_Vertical = tex2D(_FaceShadowMask, uvFlipedX.xy);    
    float4 SM_Text_VerticalFliped = tex2D(_FaceShadowMask, faceShUV.xy);
    #else
    float2 uvFlipedX = float2(-output.uv0.x, output.uv0.y);
    float4 SM_Text_Vertical = tex2D(_FaceShadowMask, uvFlipedX.xy);    
    float4 SM_Text_VerticalFliped = tex2D(_FaceShadowMask, output.uv0.xy);
    #endif

    half NdotL = dotInputs.NdL;
    half3 lightDir = lightInputs.mainLightDirection;
    float3 rightVector = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _RightVector);
    half RHdL = dot(normalize(rightVector), lightDir);
    float3 fowardVector = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _FowardVector);
    half FWdL = dot(normalize(fowardVector), lightDir);
    half BWdL = dot(normalize(-fowardVector), lightDir);
    float3 upVector = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _UPVector);
    half UPdL = dot(normalize(upVector), lightDir);
    half DWdL = dot(normalize(-upVector), lightDir);
    half stepFoward = step(FWdL, 0);
    half shadowVertical = RHdL > 0 ? SM_Text_Vertical.x : SM_Text_VerticalFliped.x;
    float shadowOffset = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _ShadowOffset);
    half stepShadowVertical = step(BWdL + shadowOffset, shadowVertical);

    if(shadow2Ramp)
    {
        float shadow2Offset = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _Shadow2Offset);
        stepShadowVertical = step(BWdL + shadow2Offset, shadowVertical);
    }

    float2 lightDirNormalized = normalize(half2(lightDir.x, lightDir.y));

    float3 halfLeftVector = (float3(-1,-1,-1) * rightVector) - upVector;
    float2 leftVectorNormalize = normalize(halfLeftVector.xy);
    float halfLFUPdotL = dot(lightDirNormalized, leftVectorNormalize);


    float3 halfRHUP = rightVector - upVector;
    float2 halfRHUPNormalize = normalize(halfRHUP.xy);
    float halfRHUPdotL = dot(lightDirNormalized, halfRHUPNormalize);


    float acossine = acos(halfRHUPdotL) / 3.141593;
    acossine *= 2;  
    float multDirectionalDir = halfLFUPdotL > 0 ? acossine - 1: 1 - acossine;
    float3 remap = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _Remap);
    float remapRotation = RemapValue(multDirectionalDir, -1, 1, remap.x, remap.y) + remap.z; 
    #if defined(_CUSTOM_UV)
    float3 faceShadowMask2UV = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _FaceShadowMask2UV);
    half2 customrotateUV = CustomUV(faceShadowMask2UV , output);
    float2 rotateUV = RotationUV(customrotateUV.xy, remapRotation);
    #else
    float2 rotateUV = RotationUV(output.uv0.xy, remapRotation);
    #endif

    float4 SM_Text_Horizontal = tex2D(_FaceShadowMask2, rotateUV.xy);
    float2 uvHorizontalFilped = half2(rotateUV.x, 1 - rotateUV.y);
    float4 SM_Text_HorizontalFliped = tex2D(_FaceShadowMask2, uvHorizontalFilped.xy);    
    float shadowHorizontal = halfLFUPdotL > 0 ? SM_Text_HorizontalFliped.x : SM_Text_Horizontal.x;    

    float stepShadowHorizontal = step(RemapValue(BWdL, -1, 1, 0, 1), shadowHorizontal);
    if(shadow2Ramp)
    {
        stepShadowHorizontal = step(RemapValue(BWdL, -1, 1, 0, 1), shadowHorizontal);
    }

    switch(_FSMEnum)
    {
        case 0:
            return stepShadowVertical;
        break;
        case 1:
            return stepShadowHorizontal;
        break;
        case 2:
            return stepShadowVertical * stepShadowHorizontal;
        break;
    }
    return stepShadowVertical * stepShadowHorizontal;
}

half3 ToonColor(InputData inputData, DotData dotInputs, LightInputs lightInputs, Interpolators output)
{
    half3 color = 0;
    half3 lightMap = 1;
    lightMap += lightInputs.staticLightMap + lightInputs.dynamicLightMap;
    #if defined(_CUSTOM_UV)
    float customDetailUV = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _DetailUV);
    half2 detailUV = CustomUV(customDetailUV, output);
    half4 detail = tex2D(_Detail, detailUV.xy);
    float customEmissionUV = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _EmissionUV);
    half2 emissionUV = CustomUV(customEmissionUV, output);
    half4 emission = tex2D(_Emission, emissionUV.xy);
    #else
    half4 detail = tex2D(_Detail, output.uv3.xy);
    half4 emission = tex2D(_Emission, output.uv0.xy);
    #endif
    half3 lightsColor = LightsColor(lightInputs);
    MainColors baseColor = GetMainColors(inputData, lightsColor, output, dotInputs);

    half3 lightColor = baseColor.lightColor;
    half3 shadowColor = baseColor.shadowColor;
    half3 darkShadowColor = baseColor.shadow2Color;
    half3 rimLight = baseColor.fresnelColor;
    half lighRamp = dotInputs.NdL;
    half lighRamp2 = dotInputs.NdL2;

    #if defined(_FACESHADOWMASK)
        lighRamp = ShadowMask(output, dotInputs, lightInputs, 0);
        lighRamp2 = ShadowMask(output, dotInputs, lightInputs, 1);    
    #endif

    if(_ReceiveShadows2)
    {
        half mainLightShadowMask = smoothstep(0.9, 1, lightInputs.mainLightSAtt);
        lighRamp = saturate(lighRamp * mainLightShadowMask);
        lighRamp2 = saturate(lighRamp2 * mainLightShadowMask);
    }

    half maxShadow = max(lighRamp,lighRamp2);
    #if defined(_ADDITIONAL_LIGHT_REPLACE)    
        half addRamp = saturate(pow(abs(lightInputs.addLightDAtt), 1000));
        lightColor = lerp(lightColor, lightInputs.addLightColor, addRamp);
    #endif
    half3 lerpShadow = lerp(shadowColor, lightColor, lighRamp);    
    half3 lerpShadow2 = lerp(darkShadowColor, lerpShadow, maxShadow);

    if(_FresnelShadowsOnly)
    {
        dotInputs.VdN = dotInputs.VdN * (1 - lighRamp);
    }

    if(_Fresnel)
    {
        half3 lerpSpecularFresnel = lerp(lerpShadow2, rimLight, dotInputs.VdN);
        color = !_Isface ? lerpSpecularFresnel : lerpShadow2;
    }else{
        color = lerpShadow2;
    }

    #if defined(_ADDITIONAL_LIGHT_REPLACE) 
        color = (color * lightInputs.mainLightColor) * lightMap;
    #else 
        color = (color * lightInputs.mainLightColor) + lightInputs.addLightColor;
        color = color * lightMap;
    #endif    

    #if defined(_GGSTRIVEWORKFLOW)
        #if defined(_CUSTOM_UV)
        float customILMUV = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _ILMUV);
        half2 ilmUV = CustomUV(customILMUV, output);
        half4 ilm = tex2D(_ILM, ilmUV.xy);
        #else
        half4 ilm = tex2D(_ILM, output.uv0.xy);
        #endif
        float debug = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _Debug);
        if(output.color.r < 0.1 && !debug)
        {            
            color = (baseColor.shadow2Color * lightInputs.mainLightColor) + lightInputs.addLightColor;            
            color = color * lightMap;         
        }

        if(output.color.r > 0.1 && output.color.r < 0.8 && !debug)
        {
            color = (baseColor.shadowColor * lightInputs.mainLightColor) + lightInputs.addLightColor;
            color = color * lightMap;
        }

        color = lerp(color, baseColor.emissionColor, emission.a);
        color = color * ilm.a;        
        color = color * detail.rgb;
    #else
        color = lerp(color, baseColor.emissionColor, emission.a);
        color = color * detail.rgb;
    #endif

    #if defined(_DEBUG)
        float ilmDebug = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _ILMDebug);
        if (ilmDebug)
        {
            float ilmChannel = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _ILMChannel);
            half2 debugilmUV = half2(0,0);
            float debugCustomILMUV = 0;
            switch(ilmChannel)
            {
                case 0:
                    #if defined(_CUSTOM_UV)
                    debugCustomILMUV = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _ILMUV);
                    debugilmUV = CustomUV(debugCustomILMUV, output);
                    color = tex2D(_ILM, debugilmUV.xy).rgb;
                    #else
                    color = tex2D(_ILM, output.uv0.xy).rgb;
                    #endif
                    break;
                case 1:
                    #if defined(_CUSTOM_UV)
                    debugCustomILMUV = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _ILMUV);
                    debugilmUV = CustomUV(debugCustomILMUV, output);
                    color = tex2D(_ILM, debugilmUV.xy).r;
                    #else
                    color = tex2D(_ILM, output.uv0.xy).rgb;
                    #endif
                    break;
                case 2:
                    #if defined(_CUSTOM_UV)
                    debugCustomILMUV = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _ILMUV);
                    debugilmUV = CustomUV(debugCustomILMUV, output);
                    color = tex2D(_ILM, debugilmUV.xy).g;
                    #else
                    color = tex2D(_ILM, output.uv0.xy).rgb;
                    #endif
                    break;
                case 3:
                    #if defined(_CUSTOM_UV)
                    debugCustomILMUV = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _ILMUV);
                    debugilmUV = CustomUV(debugCustomILMUV, output);
                    color = tex2D(_ILM, debugilmUV.xy).b;
                    #else
                    color = tex2D(_ILM, output.uv0.xy).rgb;
                    #endif
                    break;
                case 4:
                    #if defined(_CUSTOM_UV)
                    debugCustomILMUV = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _ILMUV);
                    debugilmUV = CustomUV(debugCustomILMUV, output);
                    color = tex2D(_ILM, debugilmUV.xy).a;
                    #else
                    color = tex2D(_ILM, output.uv0.xy).rgb;
                    #endif
                    break;
                case 5:
                    #if defined(_CUSTOM_UV)
                    debugCustomILMUV = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _ILMUV);
                    debugilmUV = CustomUV(debugCustomILMUV, output);
                    color = tex2D(_BaseColor, debugilmUV.xy).a;
                    #else
                    color = tex2D(_ILM, output.uv0.xy).rgb;
                    #endif
                    break;
            }
        }
        else if(_VertexColors)
        {
            switch(_VertexChannel)
            {
                case 0:
                    color = output.color;
                    break;
                case 1:
                    color = output.color.r;
                    break;
                case 2:
                    color = output.color.g;
                    break;
                case 3:
                    color = output.color.b;
                    break;
                case 4:
                    color = output.color.a;
                    break;
            }
        }        
        else
        {
            switch(_DebugStates)
            {
                case 0:
                    color = lightInputs.mainLightSAtt;
                break;
                case 1:
                    color = lightInputs.addLightDAtt;
                break;
                case 2:
                    color = dotInputs.NdL;
                break;
                case 3:
                    lightColor = half3(1, 1, 1);
                    shadowColor = half3(0.5, 0.5, 0.5);
                    darkShadowColor = half3(0, 0, 0);

                    maxShadow = max(lighRamp,lighRamp2);
                    lerpShadow = lerp(shadowColor, lightColor, lighRamp);
                    lerpShadow2 = lerp(darkShadowColor, lerpShadow, maxShadow);
                    color = lerpShadow2;
                break;
                case 4:                    
                    color = dotInputs.HdN;
                break;
                case 5:
                    color = dotInputs.VdN;
                break;
                case 6:
                    lightColor = half3(1, 1, 1);
                    shadowColor = half3(0.5, 0.5, 0.5);
                    darkShadowColor = half3(0, 0, 0);

                    lighRamp = ShadowMask(output, dotInputs, lightInputs, 0);
                    lighRamp2 = ShadowMask(output, dotInputs, lightInputs, 1);

                    maxShadow = max(lighRamp,lighRamp2);
                    lerpShadow = lerp(shadowColor, lightColor, lighRamp);
                    lerpShadow2 = lerp(darkShadowColor, lerpShadow, maxShadow);
                    color = lerpShadow2;
                break;
            }
        }
    #endif

    return color;
}

void IntializeInputData (Interpolators input, out InputData inputData)
{
    inputData = (InputData)0;

    #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
        inputData.positionWS = input.positionWS;
    #endif

        half3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
    #if defined(_NORMALMAP) || defined(_DETAIL)
        float sgn = input.tangentWS.w;      // should be either +1 or -1
        float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
        half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);

        #if defined(_NORMALMAP)
        inputData.tangentToWorld = tangentToWorld;
        #endif
        inputData.normalWS = TransformTangentToWorld(0, tangentToWorld);
    #else
        inputData.normalWS = input.normalWS;
    #endif

        inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
        inputData.viewDirectionWS = viewDirWS;

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        inputData.shadowCoord = input.shadowCoord;
    #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
        inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
    #else
        inputData.shadowCoord = float4(0, 0, 0, 0);
    #endif
    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        inputData.fogCoord = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactorAndVertexLight.x);
        inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
    #else
        inputData.fogCoord = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactor);
    #endif

    #if defined(DYNAMICLIGHTMAP_ON)
        inputData.bakedGI = SAMPLE_GI(input.uv1, input.uv2, input.uv1, inputData.normalWS);
    #else
        inputData.bakedGI = SAMPLE_GI(input.uv1, input.uv1, inputData.normalWS);
    #endif

        inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
        inputData.shadowMask = SAMPLE_SHADOWMASK(input.uv1);

    #if defined(DEBUG_DISPLAY)
        #if defined(DYNAMICLIGHTMAP_ON)
        inputData.dynamicLightmapUV = input.uv2;
        #endif
        #if defined(LIGHTMAP_ON)
        inputData.staticLightmapUV = input.uv1;
        #else
        inputData.vertexSH = input.vertexSH;
        #endif
    #endif
}

void AlphaClip(Interpolators output)
{
    float alphaClip = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _AlphaClip);
    if(alphaClip)
    {
        half2 customUV = half2(0,0);
        float alphaClipChannel = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _AlphaClipChannel);
        switch(alphaClipChannel)
        {
            case 0:
                half base = 0;                        
                #if defined(_CUSTOM_UV)
                float baseColorUV = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _BaseColorUV);
                customUV = CustomUV(baseColorUV, output);
                base = tex2D(_BaseColor, customUV.xy).a;
                #else
                base = tex2D(_BaseColor, output.uv0.xy).a;
                #endif

                clip(base * _BaseTint.a - _AlphaClipThreshold);
            break;
            case 1:
                half detail = 0;
                #if defined(_CUSTOM_UV)
                float detailUV = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _DetailUV);
                customUV = CustomUV(detailUV, output);
                detail = tex2D(_Detail, customUV.xy).a;                
                #else
                detail = tex2D(_Detail, output.uv0.xy).a;
                #endif
                clip(detail - _AlphaClipThreshold);
            break;
            case 2:
                half normalMap = 0;
                #if defined(_CUSTOM_UV)
                float normalMapUV = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _NormalMapUV);
                customUV = CustomUV(normalMapUV, output);        
                normalMap = tex2D(_NormalMap, customUV.xy).a;                
                #else
                normalMap = tex2D(_NormalMap, output.uv0.xy).a;
                #endif
                clip(normalMap - _AlphaClipThreshold);            
            break;
            case 3:
                half shadow = 0;
                #if defined(_CUSTOM_UV)
                float shadowColorUV = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _ShadowColorUV);
                customUV = CustomUV(shadowColorUV, output);
                shadow = tex2D(_ShadowColor, customUV.xy).a;
                #else
                shadow = tex2D(_ShadowColor, output.uv0.xy).a;
                #endif
                float4 shadowTint = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _ShadowTint);
                float alphaClipThreshold = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _AlphaClipThreshold);
                clip(shadow * shadowTint.a - alphaClipThreshold);
            break;
        }        
    }
}

Interpolators vert (Inputs input)
{
    Interpolators output = (Interpolators)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);    
    if(_DistortionFactor > 0)
    {
        input.positionOS.xyz = DistortionVertex(input.positionOS.xyz);
    }

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);

    half fogFactor = 0;

    #if !defined(_FOG_FRAGMENT)
        fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
    #endif
        output.uv0 = TRANSFORM_TEX(input.uv0, _BaseColor);
        // already normalized from normal transform to WS.
        output.normalWS = normalInput.normalWS;

    #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR) || defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
        real sign = input.tangentOS.w * GetOddNegativeScale();
        half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
    #endif

    #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
        output.tangentWS = tangentWS;
    #endif

    #if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
        half3 viewDirWS = GetWorldSpaceNormalizeViewDir(vertexInput.positionWS);
        half3 viewDirTS = GetViewDirectionTangentSpace(tangentWS, output.normalWS, viewDirWS);
        output.viewDirTS = viewDirTS;
    #endif
    output.uv1 = input.uv1;
    output.uv2 = input.uv2;
    OUTPUT_LIGHTMAP_UV(input.uv1, unity_LightmapST, output.uv1);
    #ifdef DYNAMICLIGHTMAP_ON
        output.uv2 = input.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
    #endif
        OUTPUT_SH(output.normalWS.xyz, output.uv1);
    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
    #else
        output.fogFactor = fogFactor;
    #endif

    #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
        output.positionWS = vertexInput.positionWS;
    #endif

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        output.shadowCoord = GetShadowCoord(vertexInput);
    #endif

    output.uv3 = input.uv3;    
    #if defined (_CUSTOM_UV)
    output.uv4 = input.uv4;
    output.uv5 = input.uv5;
    output.uv6 = input.uv6;
    output.uv7 = input.uv7;
    #endif
    #if defined (_NORMALMAP)
        #if defined(_CUSTOM_UV)
        float4 normalMapUV = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _NormalMapUV);
        float4 customNormalMapUV = CustomUV(normalMapUV, output);
        input.normalOS = tex2Dlod(_NormalMap, half4(customNormalMapUV.xy,0,0));
        #else
        input.normalOS = tex2Dlod(_NormalMap, half4(input.uv0.xy,0,0));
        #endif        
    #endif

    output.positionCS = vertexInput.positionCS;
    output.positionOS = input.positionOS;
    output.normalOS = input.normalOS;
    output.tangentOS = input.tangentOS;
    output.color = input.color;
    return output;
}

half4 frag(Interpolators output) : SV_Target
{
    half3 color = half3(0,0,0);

    UNITY_SETUP_INSTANCE_ID(output);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(output);
    #ifdef _ALPHATEST_ON    
    AlphaClip(output);
    #endif

    #if defined(_PARALLAXMAP)
        #if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
            half3 viewDirTS = output.viewDirTS;
        #else
            half3 viewDirWS = GetWorldSpaceNormalizeViewDir(output.positionWS);
            half3 viewDirTS = GetViewDirectionTangentSpace(output.tangentWS, output.normalWS, viewDirWS);
        #endif
        ApplyPerPixelDisplacement(viewDirTS, output.uv);
    #endif

    InputData inputData;
    IntializeInputData(output, inputData);

    VertexPositionInputs vertexInput = GetVertexPositionInputs(output.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(output.normalOS, output.tangentOS);
    DirectionVectors dirVectors = (DirectionVectors)0;
    float3 fowardVector = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _FowardVector);
    dirVectors.fowardDir = normalize(fowardVector);
    float3 upVector = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _UPVector);
    dirVectors.upDir = normalize(upVector);
    float3 rightVector = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _RightVector);
    dirVectors.rightDir = normalize(rightVector);
    
    LightInputs lightInputs = GetLightInputs(inputData, output);
    DotData dotInputs = DotCreation(vertexInput, normalInput, dirVectors, lightInputs);
    dotInputs = DotAjusts(dotInputs, output);

    half3 finalColor = ToonColor(inputData, dotInputs, lightInputs, output);
    color = MixFog(finalColor.rgb, inputData.fogCoord);

    float4 baseTint = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _BaseTint);
    return half4(color.xyz, baseTint.a);
}
#endif