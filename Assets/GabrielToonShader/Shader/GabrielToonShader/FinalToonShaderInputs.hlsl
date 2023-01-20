#ifndef FINALTOON_INPUTS
#define FINALTOON_INPUTS

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
#define TEXTURE_UV_DECLARATION(textureName) float textureName##UV

sampler2D _BaseColor;
sampler2D _ShadowColor;
sampler2D _FaceShadowMask;
sampler2D _FaceShadowMaskGradient;
sampler2D _FaceShadowMask2;
sampler2D _FaceShadowMask2Gradient;
sampler2D _ILM;
sampler2D _Detail;
sampler2D _Emission;
sampler2D _NormalMap;

CBUFFER_START(UnityPerMaterial)
    int _GGStriveWorkFlow;
    int _ShadowMaskAjust;
    float _FSMEnum;
    float _DistortionFactor;    
    float4 _BaseColor_ST;
    TEXTURE_UV_DECLARATION(_BaseColor);   
    float4 _ShadowColor_ST;
    TEXTURE_UV_DECLARATION(_ShadowColor);    
    float4 _FaceShadowMask_ST;
    TEXTURE_UV_DECLARATION(_FaceShadowMask);    
    float4 _FaceShadowMaskGradient_ST;
    TEXTURE_UV_DECLARATION(_FaceShadowMaskGradient);    
    float4 _FaceShadowMask2_ST;
    TEXTURE_UV_DECLARATION(_FaceShadowMask2);    
    float4 _FaceShadowMask2Gradient_ST;
    TEXTURE_UV_DECLARATION(_FaceShadowMask2Gradient);    
    float4 _ILM_ST;
    TEXTURE_UV_DECLARATION(_ILM);    
    float4 _Detail_ST;
    TEXTURE_UV_DECLARATION(_Detail);    
    float4 _Emission_ST;
    TEXTURE_UV_DECLARATION(_Emission);    
    float4 _NormalMap_ST;
    TEXTURE_UV_DECLARATION(_NormalMap);
    half _Parallax;

    //Tint
    half4 _BaseTint;
    half _BaseIntensity;
    half _BaseSaturation;
    half4 _ShadowTint;
    half _ShadowIntensity;
    half _ShadowSaturation;
    half4 _Shadow2Tint;
    half _Shadow2Intensity;
    half _Shadow2Saturation;
    half4 _SpecularTint;
    half _SpecularIntensity;
    half _SpecularSaturation;
    half4 _FresnelTint;
    half _FresnelIntensity;
    half _FresnelSaturation;
    half4 _EmissionTint;
    half _EmissionIntensity;
    half _EmissionSaturation;

    //Head
    int _Isface;
    float3 _RightVector;
    float3 _UPVector;
    float3 _FowardVector;
    float3 _SunEuler;
    float3 _Remap;

    //Control
    half _ShadeSmoothStep; //smoothstep
    half _ShadowOffset; //add
    half _Shadow2Offset; //add
    half _Fresnel; //add
    half _FresnelSize; //add
    half _FresnelThreshHold; //smoothstep
    half _FresnelShadowsOnly;
    half _Specular;
    half _SpecularSize; //pow
    half _SpecularThreshHold; //smoothstep

    //Replace Color Additional Lights
    half _ReceiveShadows2;

    //Replace Color Additional Lights
    int _AdditionalLightReplaceColor;

    //Debug Booleans
    int _Debug;
    int _DebugStates;
    int _VertexChannel;
    int _VertexColors;
    int _ILMDebug;
    int _ILMChannel;

    //AlphaClip
    half _AlphaClip;
    half _AlphaClipThreshold;
    half _AlphaClipChannel;
CBUFFER_END


#ifdef UNITY_DOTS_INSTANCING_ENABLED
UNITY_INSTANCING_BUFFER_START(MaterialPropertyMetadata)
    UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)
    UNITY_DEFINE_INSTANCED_PROP(int, _GGStriveWorkFlow);
    UNITY_DEFINE_INSTANCED_PROP(int, _ShadowMaskAjust);
    UNITY_DEFINE_INSTANCED_PROP(float, _FSMEnum);
    UNITY_DEFINE_INSTANCED_PROP(float _DistortionFactor);    
    UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor_ST);
    UNITY_DEFINE_INSTANCED_PROP(float, _BaseColorUV);    
    UNITY_DEFINE_INSTANCED_PROP(float4, _ShadowColor_ST);
    UNITY_DEFINE_INSTANCED_PROP(float, _ShadowColorUV);    
    UNITY_DEFINE_INSTANCED_PROP(float4, _FaceShadowMask_ST);
    UNITY_DEFINE_INSTANCED_PROP(float, _FaceShadowMaskUV);    
    UNITY_DEFINE_INSTANCED_PROP(float4, _FaceShadowMaskGradient_ST);
    UNITY_DEFINE_INSTANCED_PROP(float, _FaceShadowMaskGradientUV);    
    UNITY_DEFINE_INSTANCED_PROP(float4, _FaceShadowMask2_ST);
    UNITY_DEFINE_INSTANCED_PROP(float, _FaceShadowMask2UV);    
    UNITY_DEFINE_INSTANCED_PROP(float4, _FaceShadowMask2Gradient_ST);
    UNITY_DEFINE_INSTANCED_PROP(float, _FaceShadowMask2GradientUV);    
    UNITY_DEFINE_INSTANCED_PROP(float4, _ILM_ST);
    UNITY_DEFINE_INSTANCED_PROP(float, _ILMUV);    
    UNITY_DEFINE_INSTANCED_PROP(float4, _Detail_ST);
    UNITY_DEFINE_INSTANCED_PROP(float, _DetailUV);    
    UNITY_DEFINE_INSTANCED_PROP(float4, _Emission_ST);
    UNITY_DEFINE_INSTANCED_PROP(float, _EmissionUV);    
    UNITY_DEFINE_INSTANCED_PROP(float4, _NormalMap_ST);
    UNITY_DEFINE_INSTANCED_PROP(float, _NormalMapUV);
    UNITY_DEFINE_INSTANCED_PROP(half, _Parallax);

    //Tint
    UNITY_DEFINE_INSTANCED_PROP(half4, _BaseTint);
    UNITY_DEFINE_INSTANCED_PROP(half, _BaseIntensity);
    UNITY_DEFINE_INSTANCED_PROP(half, _BaseSaturation);
    UNITY_DEFINE_INSTANCED_PROP(half4, _ShadowTint);
    UNITY_DEFINE_INSTANCED_PROP(half, _ShadowIntensity);
    UNITY_DEFINE_INSTANCED_PROP(half, _ShadowSaturation);
    UNITY_DEFINE_INSTANCED_PROP(half4, _Shadow2Tint);
    UNITY_DEFINE_INSTANCED_PROP(half, _Shadow2Intensity);
    UNITY_DEFINE_INSTANCED_PROP(half, _Shadow2Saturation);
    UNITY_DEFINE_INSTANCED_PROP(half4, _SpecularTint);
    UNITY_DEFINE_INSTANCED_PROP(half, _SpecularIntensity);
    UNITY_DEFINE_INSTANCED_PROP(half, _SpecularSaturation);
    UNITY_DEFINE_INSTANCED_PROP(half4, _FresnelTint);
    UNITY_DEFINE_INSTANCED_PROP(half, _FresnelIntensity);
    UNITY_DEFINE_INSTANCED_PROP(half, _FresnelSaturation);
    UNITY_DEFINE_INSTANCED_PROP(half4, _EmissionTint);
    UNITY_DEFINE_INSTANCED_PROP(half, _EmissionIntensity);
    UNITY_DEFINE_INSTANCED_PROP(half, _EmissionSaturation);

    //Head
    UNITY_DEFINE_INSTANCED_PROP(int, _Isface);
    UNITY_DEFINE_INSTANCED_PROP(float3, _RightVector);
    UNITY_DEFINE_INSTANCED_PROP(float3, _UPVector);
    UNITY_DEFINE_INSTANCED_PROP(float3, _FowardVector);
    UNITY_DEFINE_INSTANCED_PROP(float3, _SunEuler);
    UNITY_DEFINE_INSTANCED_PROP(float3, _Remap);

    //Control
    UNITY_DEFINE_INSTANCED_PROP(half, _ShadeSmoothStep); //smoothstep
    UNITY_DEFINE_INSTANCED_PROP(half, _ShadowOffset); //add
    UNITY_DEFINE_INSTANCED_PROP(half, _Shadow2Offset); //add
    UNITY_DEFINE_INSTANCED_PROP(half, _Fresnel); //add
    UNITY_DEFINE_INSTANCED_PROP(half, _FresnelSize); //add
    UNITY_DEFINE_INSTANCED_PROP(half, _FresnelThreshHold); //smoothstep
    UNITY_DEFINE_INSTANCED_PROP(half, _FresnelShadowsOnly);
    UNITY_DEFINE_INSTANCED_PROP(half, _Specular);
    UNITY_DEFINE_INSTANCED_PROP(half, _SpecularSize); //pow
    UNITY_DEFINE_INSTANCED_PROP(half, _SpecularThreshHold); //smoothstep

    //Replace Color Additional Lights
    UNITY_DEFINE_INSTANCED_PROP(half, _ReceiveShadows2);

    //Replace Color Additional Lights
    UNITY_DEFINE_INSTANCED_PROP(int, _AdditionalLightReplaceColor);

    //Debug Booleans
    UNITY_DEFINE_INSTANCED_PROP(int, _Debug);
    UNITY_DEFINE_INSTANCED_PROP(int, _DebugStates);
    UNITY_DEFINE_INSTANCED_PROP(int, _VertexChannel);
    UNITY_DEFINE_INSTANCED_PROP(int, _VertexColors);
    UNITY_DEFINE_INSTANCED_PROP(int, _ILMDebug);
    UNITY_DEFINE_INSTANCED_PROP(int, _ILMChannel);

    //AlphaClip
    UNITY_DEFINE_INSTANCED_PROP(half, _AlphaClip);
    UNITY_DEFINE_INSTANCED_PROP(half, _AlphaClipThreshold);
    UNITY_DEFINE_INSTANCED_PROP(half, _AlphaClipChannel);
UNITY_INSTANCING_BUFFER_END(MaterialPropertyMetadata)

#define _BaseColor     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4, Metadata_BaseColor)
#define _GGStriveWorkFlow     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(int, Metadata_GGStriveWorkFlow)
#define _ShadowMaskAjust     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(int, Metadata_ShadowMaskAjust)
#define _FSMEnum     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float, Metadata_FSMEnum)
#define _DistortionFactor     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float Metadata_DistortionFactor)  
#define _BaseColor_ST     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4, Metadata_BaseColor_ST)
#define _BaseColorUV     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4, Metadata_BaseColorUV)     
#define _ShadowColor_ST     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4, Metadata_ShadowColor_ST)
#define _ShadowColorUV     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float, Metadata_ShadowColorUV)   
#define FaceShadowMask_ST     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4, Metadata_FaceShadowMask_ST)
#define _FaceShadowMaskUV     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float, Metadata_FaceShadowMaskUV)  
#define _FaceShadowMaskGradient_ST     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4, Metadata_FaceShadowMaskGradient_ST)
#define _FaceShadowMaskGradientUV    UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float, Metadata_FaceShadowMaskGradientUV)   
#define _FaceShadowMask2_ST     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4, Metadata_FaceShadowMask2_ST)
#define _FaceShadowMask2UV     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float, Metadata_FaceShadowMask2UV)  
#define _FaceShadowMask2Gradient_ST     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4, Metadata_FaceShadowMask2Gradient_ST)
#define _FaceShadowMask2GradientUV     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float, Metadata_FaceShadowMask2GradientUV)   
#define _ILM_ST     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4, Metadata_ILM_ST)
#define _ILMUV     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float, Metadata_ILMUV)  
#define _Detail_ST     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4, Metadata_Detail_ST)
#define _DetailUV     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float, Metadata_DetailUV) 
#define _Emission_ST     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4, Metadata_Emission_ST)
#define _EmissionUV     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float, Metadata_EmissionUV) 
#define _NormalMap_ST     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4, Metadata_NormalMap_ST)
#define _NormalMapUV     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float, Metadata_NormalMapUV)
#define _Parallax     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_Parallax)
 
    //Tint
#define _BaseTint     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half4, Metadata_BaseTint)
#define _BaseIntensity     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_BaseIntensity)
#define _BaseSaturation     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_BaseSaturation)
#define _ShadowTint     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half4, Metadata_ShadowTint)
#define _ShadowIntensity     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_ShadowIntensity)
#define _ShadowSaturation     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_ShadowSaturation)
#define _Shadow2Tint     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half4, Metadata_Shadow2Tint)
#define _Shadow2Intensity     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_Shadow2Intensity)
#define _Shadow2Saturation     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_Shadow2Saturation)
#define _SpecularTint     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half4, Metadata_SpecularTint)
#define _SpecularIntensity     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_SpecularIntensity)
#define _SpecularSaturation     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_SpecularSaturation)
#define _FresnelTint     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half4, Metadata_FresnelTint)
#define _FresnelIntensity     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_FresnelIntensity)
#define _FresnelSaturation     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_FresnelSaturation)
#define _EmissionTint     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half4, Metadata_EmissionTint)
#define _EmissionIntensity     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_EmissionIntensity)
#define _EmissionSaturation     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_EmissionSaturation)

    //Head
#define _Isface     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(int, Metadata_Isface)
#define _RightVector     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float3, Metadata_RightVector)
#define _UPVector     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float3, Metadata_UPVector)
#define _FowardVector     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float3, Metadata_FowardVector)
#define _SunEuler     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float3, Metadata_SunEuler)
#define _Remap     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float3, Metadata_Remap)

    //Control
#define _ShadeSmoothStep     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_ShadeSmoothStep) //smoothstep
#define _ShadowOffset     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_ShadowOffset) //add
#define _Shadow2Offset     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_Shadow2Offset) //add
#define _Fresnel     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_Fresnel) //add
#define _FresnelSize     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_FresnelSize) //add
#define _FresnelThreshHold    UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_FresnelThreshHold) //smoothstep
#define _FresnelShadowsOnly     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_FresnelShadowsOnly)
#define _Specular     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_Specular)
#define _SpecularSize     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_SpecularSize) //pow
#define _SpecularThreshHold     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_SpecularThreshHold) //smoothstep

    //Replace Color Additional Lights
#define _ReceiveShadows2     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_ReceiveShadows2)

    //Replace Color Additional Lights
#define _AdditionalLightReplaceColor     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(int, Metadata_AdditionalLightReplaceColor)

    //Debug Booleans
#define _Debug     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(int, Metadata_Debug)
#define _DebugStates     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(int, Metadata_DebugStates)
#define _VertexChannel     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(int, Metadata_VertexChannel)
#define _VertexColors     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(int, Metadata_VertexColors)
#define _ILMDebug     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(int, Metadata_ILMDebug)
#define _ILMChannel     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(int, Metadata_ILMChannel)

    //AlphaClip
#define _AlphaClip     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_AlphaClip)
#define _AlphaClipThreshold     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_AlphaClipThreshold)
#define _AlphaClipChannel     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half, Metadata_AlphaClipChannel)
#endif

TEXTURE2D(_ParallaxMap);        SAMPLER(sampler_ParallaxMap);

void ApplyPerPixelDisplacement(half3 viewDirTS, inout float2 uv)
{
#if defined(_PARALLAXMAP)
    uv += ParallaxMapping(TEXTURE2D_ARGS(_ParallaxMap, sampler_ParallaxMap), viewDirTS, _Parallax, uv);
#endif
}


#endif