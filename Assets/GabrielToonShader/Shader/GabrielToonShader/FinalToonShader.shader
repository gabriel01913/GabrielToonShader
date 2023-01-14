Shader "Unlit/FinalToonShader"
{
    Properties
    {
        [HideInInspector][ToggleOff]_Isface ("Is Face", Float) = 0
        [HideInInspector][ToggleOff]_ShadowMaskAjust ("Use Shadow Mask Gradient Ajust", Float) = 0 
        [HideInInspector][Enum(Face Shadow Mask Horizontal, 0, Face Shadow Mask Multidirectional, 1, Both, 2)]_FSMEnum("Face Shadow Mask Options", Float) = 0
        [HideInInspector][ToggleOff]_GGStriveWorkFlow ("Use GGStrive Work Flow", Float) = 1
        [HideInInspector]_DistortionFactor("Distortion Factor", Range(0,1)) = 0

        [HideInInspector][MainTexture] _BaseColor ("Base Texture", 2D) = "white" {}
        [HideInInspector]_BaseColorUV("UV Channel", Float) = 0
        [HideInInspector]_ShadowColor ("Shadow Texture", 2D) = "white" {}
        [HideInInspector]_ShadowColorUV("UV Channel", Float) = 0
        [HideInInspector]_ILM ("ILM Texture", 2D) = "white" {}
        [HideInInspector]_ILMUV("UV Channel", Float) = 0
        [HideInInspector]_Detail("Detail Texture", 2D) =  "white" {}
        [HideInInspector]_DetailUV("UV Channel", Float) = 3
        [HideInInspector]_FaceShadowMask  ("Face Shadow Mask Vertical Texture", 2D) = "white" {}
        [HideInInspector]_FaceShadowMaskUV("UV Channel", Float) = 0
        [HideInInspector]_FaceShadowMaskGradient("Face Shadow Vertical Gradient", 2D) = "white" {}
        [HideInInspector]_FaceShadowMaskGradientUV("UV Channel", Float) = 0
        [HideInInspector]_FaceShadowMask2  ("Face Shadow 2 Mask Horizontal Texture", 2D) = "white" {}
        [HideInInspector]_FaceShadowMask2UV("UV Channel", Float) = 0
        [HideInInspector]_FaceShadowMask2Gradient("Face Shadow Horizontal Gradient", 2D) = "white" {}
        [HideInInspector]_FaceShadowMask2GradientUV("UV Channel", Float) = 0
        [HideInInspector]_Emission ("Emission Texture", 2D) = "black" {}
        [HideInInspector]_EmissionUV("UV Channel", Float) = 0
        [HideInInspector]_NormalMap ("Normal Map", 2D) = "bump" {}
        [HideInInspector]_NormalMapUV("UV Channel", Float) = 0
        [HideInInspector]_Parallax("Parallax Factor", Range(0.005, 0.08)) = 0.005
        [HideInInspector]_ParallaxMap ("Height Map", 2D) = "black" {}
        [HideInInspector]_ParallaxMapUV("UV Channel", Float) = 0

        //Tint
        [HideInInspector][MainColor][HDR] _BaseTint ("Base Color Tint ", Color) = (0.7,0.7,0.7,0.7)
        [HideInInspector]_BaseIntensity("Base Color Intensity", Float) = 1
        [HideInInspector]_BaseSaturation("Base Color Saturation", Range(0,5)) = 1
        [HideInInspector][HDR]_ShadowTint ("Shadow Color Tint", Color) = (0.5,0.5,0.5,0.5)
        [HideInInspector]_ShadowIntensity("Shadow Color Intensity", Float) = 1
        [HideInInspector]_ShadowSaturation("Shadow Color Saturation", Range(0,5)) = 1
        [HideInInspector][HDR]_Shadow2Tint ("Shadow2 Color Tint", Color) = (0.3,0.3,0.3,0.3)
        [HideInInspector]_Shadow2Intensity("Shadow2 Color Intensity", Float) = 1
        [HideInInspector]_Shadow2Saturation("Shadow2 Color Saturation", Range(0,5)) = 1        
        [HideInInspector][HDR]_SpecularTint ("Specular Color Tint", Color) = (1,1,1,1)
        [HideInInspector]_SpecularIntensity("Specular Color Intensity", Float) = 1
        [HideInInspector]_SpecularSaturation("Specular Color Saturation", Range(0,5)) = 1  
        [HideInInspector][HDR]_FresnelTint ("Fresnel Color Tint", Color) = (0.7,0.7,0.7,0.7)
        [HideInInspector]_FresnelIntensity("Fresnel Color Intensity", Float) = 1
        [HideInInspector]_FresnelSaturation("Fresnel Color Saturation", Range(0,5)) = 1        
        [HideInInspector][HDR]_EmissionTint ("Emission Color Tint", Color) = (1,1,1,1)
        [HideInInspector]_EmissionIntensity("Emission Color Intensity", Float) = 1
        [HideInInspector]_EmissionSaturation("Emission Color Saturation", Range(0,5)) = 1

        //Head        
        [HideInInspector]_RightVector("Base Color Tint ", Vector) = (1,0,0,0)
        [HideInInspector]_UPVector("Base Color Tint ", Vector) = (0,1,0,0)
        [HideInInspector]_FowardVector("Base Color Tint ", Vector) = (0,0,1,0)
        [HideInInspector]_SunEuler("Base Color Tint ", Vector) = (0,0,1,0)
        [HideInInspector]_Remap("Remap Vector Rotation", Vector) = (-1,2.5,0,0)

        //Control        
        [HideInInspector]_ShadeSmoothStep ("Shade SmoothStep", Range(0,1)) = 1.0 //smoothstep
        [HideInInspector][ToggleOff]_ReceiveShadows2("Receive Shadows", Float) = 0
        [HideInInspector]_ShadowOffset("Shadow Offset", Range(-1,1)) = 0 //add
        [HideInInspector]_Shadow2Offset("Shadow2 Offset", Range(-1,1)) = -0.4 //add        
        [HideInInspector][ToggleOff] _Fresnel("Fresnel", Float) = 0
        [HideInInspector]_FresnelSize("Fresnel Size", Range(-1,5)) = 1.0 //add
        [HideInInspector]_FresnelThreshHold("Fresnel ThreshHold", Range(0,1)) = 1.0 //smoothstep
        [HideInInspector][ToggleOff] _FresnelShadowsOnly("Fresnel Shadows Only", Float) = 0
        [HideInInspector][ToggleOff] _Specular("Specular", Float) = 0
        [HideInInspector]_SpecularSize("Specular Size", Range(0,20)) = 1.0 //pow

        //Replace Color Additional Lights
        [HideInInspector][ToggleOff] _AdditionalLightReplaceColor("Hard Additional Light", Float) = 0

        //Debug Booleans
        [HideInInspector][ToggleOff] _Debug("Debug", Float) = 0
        [HideInInspector][Enum(Main Light,0,Additional Light,1,Shadow Ramp,2,Dark Shadow Ramp,3,Specular Ramp,4,Fresnel Ramp,5, Face Shadow Mask,6)]_DebugStates("Debug Options", Float) = 0
        [HideInInspector][ToggleOff] _VertexColors("Vertex Colors", Float) = 0
        [HideInInspector][Enum(All Channels,0,Red,1,Green,2,Blue,3,Alpha,4)]_VertexChannel("Vertex Channel", Float) = 0
        [HideInInspector][ToggleOff] _ILMDebug("Texture Debug", Float) = 0
        [HideInInspector][Enum(Ilm All Channels, 0, Ilm Red, 1, Ilm Green, 2, Ilm Blue, 3, Ilm Alpha, 4, Base Alpha, 5)]_ILMChannel("Texture Channels", Float) = 0
        
        [HideInInspector]_Surface("__surface", Float) = 0.0
        [HideInInspector]_Blend("__blend", Float) = 0.0
        [HideInInspector]_Cull("__cull", Float) = 2.0
        [HideInInspector][ToggleUI] _AlphaClip("_AlphaClip", Float) = 0.0
        [HideInInspector] _AlphaClipThreshold("_AlphaClipThreshold", Range(0,1)) = 0.0
        [HideInInspector][Enum(Base Texture Alpha, 0, Detail Texture Alpha, 1, Normal Map Alpha, 2, Shadow Texture Alpha, 3)]_AlphaClipChannel("Alpha Clip Channel", Float) = 0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0
    }
    SubShader
    {
        Tags{
            "RenderType" = "Opaque" 
            "RenderPipeline" = "UniversalPipeline" 
            }
        LOD 100

       Pass
        {
            Name "Toon Shader Lit"
            Tags{
                "LightMode" = "UniversalForward"
                }
            
            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma shader_feature_local _GGSTRIVEWORKFLOW
            #pragma shader_feature_local _DEBUG
            #pragma shader_feature_local _FACESHADOWMASK
            #pragma shader_feature_local _ADDITIONAL_LIGHT_REPLACE
            #pragma shader_feature_local _CUSTOM_UV

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _PARALLAXMAP
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
            #pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local_fragment _OCCLUSIONMAP
            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature_local_fragment _SPECULAR_SETUP

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile _ _CLUSTERED_RENDERING

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex vert
            #pragma fragment frag            

            #include "FinalToonShaderInputs.hlsl"
            #include "FinalToonShaderLitPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            // Lightmode matches the ShaderPassName set in UniversalRenderPipeline.cs. SRPDefaultUnlit and passes with
            // no LightMode tag are also rendered by Universal Render Pipeline
            Name "GBuffer"
            Tags{
                "LightMode" = "UniversalGBuffer"
                }

            Cull Back
            Blend One Zero
            ZTest LEqual
            ZWrite On            

            HLSLPROGRAM
            #pragma target 4.5
            #pragma exclude_renderers gles gles3 glcore
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma shader_feature_local _GGSTRIVEWORKFLOW
            #pragma shader_feature_local _DEBUG
            #pragma shader_feature_local _FACESHADOWMASK
            #pragma shader_feature_local _ADDITIONAL_LIGHT_REPLACE
            #pragma shader_feature_local _CUSTOM_UV
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _PARALLAXMAP

            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
            #pragma multi_compile_fragment _ DEBUG_DISPLAY   
            #pragma multi_compile _ UNITY_HDR_ON     
            #pragma multi_compile_prepassfinal

            #pragma vertex vert
            #pragma fragment frag

            #include "FinalToonShaderInputs.hlsl"
            #include "FinalToonShaderGbufferPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON            
            #pragma shader_feature_local _CUSTOM_UV
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            // -------------------------------------
            // Universal Pipeline keywords

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma vertex vert
            #pragma fragment frag

            #include "FinalToonShaderInputs.hlsl"
            #include "FinalToonShaderShadowCasterPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex vert
            #pragma fragment frag

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "FinalToonShaderInputs.hlsl"
            #include "FinalToonShaderLitPass.hlsl"
            ENDHLSL
        }

        // This pass is used when drawing to a _CameraNormalsTexture texture
        Pass
        {
            Name "DepthNormals"
            Tags{"LightMode" = "DepthNormals"}

            ZWrite On
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex vert
            #pragma fragment frag

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _PARALLAXMAP
            #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "FinalToonShaderInputs.hlsl"
            #include "FinalToonShaderLitPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "Meta"
            Tags{
                "LightMode" = "Meta"
                }
            
            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            #pragma shader_feature_local _CUSTOM_UV

            #pragma shader_feature EDITOR_VISUALIZATION
            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
            #pragma multi_compile_instancing

            #pragma shader_feature_local_fragment _SPECGLOSSMAP
            
            #pragma vertex vert
            #pragma fragment frag

            #include "FinalToonShaderInputs.hlsl"
            #include "FinalToonShaderMetaPass.hlsl"
            ENDHLSL
        }
    }
    CustomEditor "FinalToonShaderShaderEditor"
}
