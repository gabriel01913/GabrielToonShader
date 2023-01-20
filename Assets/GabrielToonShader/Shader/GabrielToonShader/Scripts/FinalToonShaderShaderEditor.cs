using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;
using UnityEngine.Rendering;
using FinalToonShader;

public class FinalToonShaderShaderEditor : ShaderGUI
{

#region Variables
    MaterialProperty _DistortionFactor;
    MaterialProperty _GGStriveWorkFlow;
    MaterialProperty _Isface;
    MaterialProperty _FSMEnum;
    MaterialProperty _Cull;
    MaterialProperty _BaseColor;
    MaterialProperty _ShadowColor;
    MaterialProperty _ILM;
    MaterialProperty _Detail;
    MaterialProperty _FaceShadowMask;
    MaterialProperty _FaceShadowMask2;
    MaterialProperty _Emission;
    MaterialProperty _NormalMap;
    MaterialProperty _Parallax;
    MaterialProperty _ParallaxMap;
    MaterialProperty _BaseTint;
    MaterialProperty _BaseIntensity;
    MaterialProperty _BaseSaturation;
    MaterialProperty _ShadowTint;
    MaterialProperty _ShadowIntensity ;
    MaterialProperty _ShadowSaturation ;
    MaterialProperty _Shadow2Tint ; 
    MaterialProperty _Shadow2Intensity;
    MaterialProperty _Shadow2Saturation ;
    MaterialProperty _SpecularTint ;
    MaterialProperty _SpecularIntensity ;
    MaterialProperty _SpecularSaturation ;
    MaterialProperty _FresnelTint ;
    MaterialProperty _FresnelIntensity ;
    MaterialProperty _FresnelSaturation ;
    MaterialProperty _EmissionTint ;
    MaterialProperty _EmissionIntensity ;
    MaterialProperty _EmissionSaturation ;
    MaterialProperty _ReceiveShadows ;
    MaterialProperty _remapRotation ;
    MaterialProperty _ShadeSmoothStep;
    MaterialProperty _ShadowOffset;
    MaterialProperty _Shadow2Offset;
    MaterialProperty _Fresnel;
    MaterialProperty _FresnelSize;
    MaterialProperty _FresnelThreshHold;    
    MaterialProperty _FresnelShadowsOnly;
    MaterialProperty _Specular;
    MaterialProperty _SpecularSize;    
    MaterialProperty _AdditionalLightReplaceColor;  
    MaterialProperty _Debug;
    MaterialProperty _DebugStates;
    MaterialProperty _VertexColors; 
    MaterialProperty _VertexChannel;     
    MaterialProperty _ILMDebug;
    MaterialProperty _ILMChannel;
    MaterialProperty _Surface;
    MaterialProperty _Blend;
    MaterialProperty _AlphaClip;
    MaterialProperty _AlphaClipThreshold;
    MaterialProperty _AlphaClipChannel;
    MaterialProperty _SrcBlend;
    MaterialProperty _DstBlend;
    MaterialProperty _ZWrite;

    public static Dictionary<Material, FinalToonShaderFoldout > dictionaryFoldouts = new Dictionary<Material, FinalToonShaderFoldout>();
    FinalToonShaderFoldout foldoutBools = new FinalToonShaderFoldout(); 
#endregion

public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
{
    Material target = materialEditor.target as Material;
    if (!dictionaryFoldouts.ContainsKey(target))
    {
        dictionaryFoldouts.Add(target, foldoutBools);
    }

    GetProperties(properties);

    #region Configuration Foldout
    dictionaryFoldouts[target].configurationFoldout = EditorGUILayout.Foldout(
        dictionaryFoldouts[target].configurationFoldout, 
        new GUIContent(dictionaryFoldouts[target].labels[0], dictionaryFoldouts[target].toolTips[0])
    );
    if(dictionaryFoldouts[target].configurationFoldout)
    {
        if(target.IsKeywordEnabled("_GGSTRIVEWORKFLOW"))
        {
            dictionaryFoldouts[target].workflowEnum = ShaderWorkflow.GGStrive;
        }else{
            dictionaryFoldouts[target].workflowEnum = ShaderWorkflow.Standard;
        }

        EditorGUI.BeginChangeCheck();
        dictionaryFoldouts[target].workflowEnum = (ShaderWorkflow)EditorGUILayout.EnumPopup(
            new GUIContent(dictionaryFoldouts[target].labels[1], dictionaryFoldouts[target].toolTips[1]), 
            dictionaryFoldouts[target].workflowEnum
        );

        if(EditorGUI.EndChangeCheck())
        {            
            if((int)dictionaryFoldouts[target].workflowEnum > 0)            
            {
                target.EnableKeyword("_GGSTRIVEWORKFLOW");
            }else{
                target.DisableKeyword("_GGSTRIVEWORKFLOW");            
            }
        }

        dictionaryFoldouts[target].renderFace = (RenderFace)EditorGUILayout.EnumPopup(
            new GUIContent("Render Face", "Specifies which faces to cull from your geometry. Front culls front faces. Back culls backfaces. None means that both sides are rendered."), 
            dictionaryFoldouts[target].renderFace
        );
        target.SetFloat("_Cull", (int)dictionaryFoldouts[target].renderFace);

        EditorGUI.BeginChangeCheck();
        dictionaryFoldouts[target].surfaceType = (SurfaceType)EditorGUILayout.EnumPopup(
            new GUIContent("Surface Type", "Change the surface type"), 
            dictionaryFoldouts[target].surfaceType
        );
        if(EditorGUI.EndChangeCheck())
        {
            ChangeSurfaceType(target, dictionaryFoldouts);
        }
        EditorGUI.BeginChangeCheck();
        if(dictionaryFoldouts[target].surfaceType == SurfaceType.Transparent)
        {
            dictionaryFoldouts[target].alphaBlendMode = (AlphaBlendMode)EditorGUILayout.EnumPopup(
            new GUIContent("Blend Mode", "Chose Blend mode for transparent object"), 
            dictionaryFoldouts[target].alphaBlendMode
            );
        }
        if(EditorGUI.EndChangeCheck())
        {
            ChangeSurfaceType(target, dictionaryFoldouts);
        }

        if(CreatePropertyToogle("_AlphaClip","Alpha Clip", "Alpha Clip CutOut", materialEditor))
        {
            dictionaryFoldouts[target].alphaClipChannel = (AlphaClipChannel)EditorGUILayout.EnumPopup(
            new GUIContent("Alpha Clip Channel", "Select the channel that contains the cutout mask"), 
            dictionaryFoldouts[target].alphaClipChannel
            );
            ChangeSurfaceType(target, dictionaryFoldouts);
            materialEditor.ShaderProperty(_AlphaClipThreshold, new GUIContent("Clip Threshold","Ajust the Threshold of alpha clip"));           
        }

        materialEditor.ShaderProperty(_ReceiveShadows, new GUIContent("Receive Shadows","Receive shadow cast of other objects"));

        EditorGUI.BeginChangeCheck();
        if(CreatePropertyToogle("_Isface", "Is Face?", "Mark this if the material is for the face model", materialEditor))
        {
            dictionaryFoldouts[target].shadowMaskOptions = (ShadowMaskOptions)Enum.ToObject(typeof(ShadowMaskOptions), (int)target.GetFloat("_FSMEnum"));
            dictionaryFoldouts[target].shadowMaskOptions = (ShadowMaskOptions)EditorGUILayout.EnumPopup(
            new GUIContent("Shadow Mask Options", "Select the shadow Mask options"), 
            dictionaryFoldouts[target].shadowMaskOptions
            );
            target.SetFloat("_FSMEnum", (int)dictionaryFoldouts[target].shadowMaskOptions);            
        }
        if(EditorGUI.EndChangeCheck() && Convert.ToBoolean(target.GetFloat("_Isface")))
        {
            target.EnableKeyword("_FACESHADOWMASK");
        }else if(EditorGUI.EndChangeCheck())
        {
            target.DisableKeyword("_FACESHADOWMASK");
        }
    }
    #endregion

    EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);

    #region Texture Foldout
    dictionaryFoldouts[target].textureFoldout = EditorGUILayout.Foldout(
        dictionaryFoldouts[target].textureFoldout, 
        new GUIContent(dictionaryFoldouts[target].labels[7], dictionaryFoldouts[target].toolTips[7])
    );
    
    if(dictionaryFoldouts[target].textureFoldout)
    {  
        GUILayout.BeginHorizontal(); 
        materialEditor.TexturePropertySingleLine(new GUIContent("Base Texture", "Base unlit shaded Color"), _BaseColor, _BaseTint);
        GUILayout.EndHorizontal(); 
        if(target.IsKeywordEnabled("_GGSTRIVEWORKFLOW")) 
        materialEditor.TexturePropertySingleLine(new GUIContent("SSS Texture", "Shadow texture"),_ShadowColor, _ShadowTint);
        if(target.GetFloat("_Isface") > 0)
        {
            if(dictionaryFoldouts[target].shadowMaskOptions == ShadowMaskOptions.MaskVertical)
            {
                materialEditor.TexturePropertySingleLine(new GUIContent("Shadow Mask", "Ramp mask for shadow face"), _FaceShadowMask); 
                              
            }else if(dictionaryFoldouts[target].shadowMaskOptions == ShadowMaskOptions.MaskMultidirectional)
            {
                materialEditor.TexturePropertySingleLine(new GUIContent("Shadow Mask 2", "Ramp mask for shadow face"), _FaceShadowMask2);                
            
            }else{
                materialEditor.TexturePropertySingleLine(new GUIContent("Shadow Mask", "Ramp mask for shadow face"), _FaceShadowMask);
                materialEditor.TexturePropertySingleLine(new GUIContent("Shadow Mask 2", "Ramp mask for shadow face"), _FaceShadowMask2);                
            }            
        }

        materialEditor.TexturePropertySingleLine(new GUIContent("Emission Texture", "Emission texture. rgb colors, alpha ramp"),_Emission, _EmissionTint);          
        materialEditor.TexturePropertySingleLine(new GUIContent("Detail Texture", "Detail Texture"),_Detail);            
        if(target.IsKeywordEnabled("_GGSTRIVEWORKFLOW")) 
        materialEditor.TexturePropertySingleLine(new GUIContent("ILM Textrure", "ILM GG Striver workflow"), _ILM);                       
        materialEditor.TexturePropertySingleLine(new GUIContent("Normal Map", "Baked normal map"), _NormalMap);
        if(target.HasProperty("_NormalMap"))
        CoreUtils.SetKeyword(target, "_NORMALMAP", target.GetTexture("_NormalMap"));
        materialEditor.TexturePropertySingleLine(new GUIContent("Height Map", "Height map for parallax effect"), _ParallaxMap);
        if(target.HasProperty("_ParallaxMap"))
        CoreUtils.SetKeyword(target, "_PARALLAXMAP", target.GetTexture("_ParallaxMap"));
        if(target.GetTexture("_ParallaxMap"))
        materialEditor.ShaderProperty(_Parallax, new GUIContent("Height Factor","Factor parallax effect"));
                    
    }
    #endregion

    EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);

    #region Colors Foldout
    dictionaryFoldouts[target].colorOptionsFoldout = EditorGUILayout.Foldout(
        dictionaryFoldouts[target].colorOptionsFoldout, 
        new GUIContent(dictionaryFoldouts[target].labels[2], dictionaryFoldouts[target].toolTips[2])
    );       
    if(dictionaryFoldouts[target].colorOptionsFoldout)
    {
        materialEditor.ShaderProperty(_BaseTint, "Base Color Tint");
        materialEditor.ShaderProperty(_BaseIntensity, "Base Color Intensity");
        materialEditor.ShaderProperty(_BaseSaturation, "Base Color Saturation");
        EditorGUILayout.Space();
        materialEditor.ShaderProperty(_ShadowTint, "Shadows Color Tint");
        materialEditor.ShaderProperty(_ShadowIntensity, "Shadows Color Intensity");
        materialEditor.ShaderProperty(_ShadowSaturation, "Shadows Color Saturation");
        EditorGUILayout.Space();
        materialEditor.ShaderProperty(_Shadow2Tint, "Second Shadows Shadows Tint");
        materialEditor.ShaderProperty(_Shadow2Intensity, "Second Shadows Intensity");
        materialEditor.ShaderProperty(_Shadow2Saturation, "Second Shadows Saturation"); 
        EditorGUILayout.Space();           
        materialEditor.ShaderProperty(_EmissionTint, "Emission Tint");
        materialEditor.ShaderProperty(_EmissionIntensity, "Emission Intensity");
        materialEditor.ShaderProperty(_EmissionSaturation, "Emission Saturation");
    }
    #endregion

    EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);

    #region Additional Colors Foldout
    dictionaryFoldouts[target].additionalColorsFoldout = EditorGUILayout.Foldout(
        dictionaryFoldouts[target].additionalColorsFoldout, 
        new GUIContent(dictionaryFoldouts[target].labels[3], dictionaryFoldouts[target].toolTips[3])
    );       
    if(dictionaryFoldouts[target].additionalColorsFoldout)
    {          
        if(CreatePropertyToogle("_Fresnel","Rim Light", "Enable, disable Rim Light", materialEditor))
        {
            materialEditor.ShaderProperty(_FresnelTint, "Fresnel Tint");
            materialEditor.ShaderProperty(_FresnelIntensity, "Fresnel Intensity");
            materialEditor.ShaderProperty(_FresnelSaturation, "Fresnel Saturation");
        }

        EditorGUILayout.Space();            

        if(CreatePropertyToogle("_Specular","Specular Highlight", "Enable, disable Specular Highlight", materialEditor))
        {
            materialEditor.ShaderProperty(_SpecularTint, "Specular Tint");
            materialEditor.ShaderProperty(_SpecularIntensity, "Specular Intensity");
            materialEditor.ShaderProperty(_SpecularSaturation, "Specular Saturation");
        }
    }
    #endregion

    EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);

    #region Ramp Ajust Foldout
    dictionaryFoldouts[target].rampAjustsFoldout = EditorGUILayout.Foldout(
        dictionaryFoldouts[target].rampAjustsFoldout, 
        new GUIContent(dictionaryFoldouts[target].labels[4], dictionaryFoldouts[target].toolTips[4])
    );    
    if(dictionaryFoldouts[target].rampAjustsFoldout)
    {          
        materialEditor.ShaderProperty(_ShadeSmoothStep, "Shade Blend Threshold");
        materialEditor.ShaderProperty(_ShadowOffset, "Shadow Offset");
        materialEditor.ShaderProperty(_Shadow2Offset, "Second Shadows Offset");
        EditorGUILayout.Space();

        if(CreatePropertyToogle("_Fresnel","Rim Light", "Enable, disable Rim Light", materialEditor))
        {
            materialEditor.ShaderProperty(_FresnelSize, "Fresnel Size");
            materialEditor.ShaderProperty(_FresnelThreshHold, "Fresnel Threshold");
            materialEditor.ShaderProperty(_FresnelShadowsOnly, new GUIContent("Fresnel Only Shadows","Enable, disable fresnel only in shadows"));
        }

        EditorGUILayout.Space();
        
        if(CreatePropertyToogle("_Specular","Specular Highlight", "Enable, disable Specular Highlight", materialEditor))
        {
            materialEditor.ShaderProperty(_SpecularSize, "Specular Size");
        }
        EditorGUILayout.Space();

        materialEditor.ShaderProperty(_remapRotation, new GUIContent("Remap Shadow Face Rotation","Remap min max shadow face rotation"));
    }
    #endregion
    
    EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);

    #region Others Option Foldout
    dictionaryFoldouts[target].otherOptionsFoldout = EditorGUILayout.Foldout(
        dictionaryFoldouts[target].otherOptionsFoldout, 
        new GUIContent(dictionaryFoldouts[target].labels[5], dictionaryFoldouts[target].toolTips[5])
    );
    if(dictionaryFoldouts[target].otherOptionsFoldout)
    {
        EditorGUILayout.Space();

        CreateKeywordToogle("_ADDITIONAL_LIGHT_REPLACE","Additional Light Replace Color","Enable, disable that additional light colors, replace the base color", materialEditor);
        
        materialEditor.ShaderProperty(_DistortionFactor, new GUIContent("Distortion Vertex","CAN RESULT IN ARTIFACTS! Distortion per vertex base, to squash the mesh"));
        if(CreateKeywordToogle("_CUSTOM_UV","Custom UV","Enable, disable Custom UV Configuration", materialEditor))
        {
            dictionaryFoldouts[target].baseChannels = (UVChannels)EditorGUILayout.EnumPopup(
            new GUIContent("Base Texture Channel", "Base Texture UV Channel"), 
            dictionaryFoldouts[target].baseChannels
            );
            target.SetFloat("_BaseColorUV", (int)dictionaryFoldouts[target].baseChannels);

            dictionaryFoldouts[target].shadowChannels = (UVChannels)EditorGUILayout.EnumPopup(
            new GUIContent("Shadow Texture Channel", "Shadow Texture UV Channel"), 
            dictionaryFoldouts[target].shadowChannels
            );
            target.SetFloat("_ShadowColorUV", (int)dictionaryFoldouts[target].shadowChannels);

            dictionaryFoldouts[target].ILMUVChannels = (UVChannels)EditorGUILayout.EnumPopup(
            new GUIContent("ILM Texture Channel", "ILM Texture UV Channel"), 
            dictionaryFoldouts[target].ILMUVChannels
            );
            target.SetFloat("_ILMUV", (int)dictionaryFoldouts[target].ILMUVChannels);

            dictionaryFoldouts[target].DetailUVChannels = (UVChannels)EditorGUILayout.EnumPopup(
            new GUIContent("Detail Texture Channel", "Shadow Texture UV Channel"), 
            dictionaryFoldouts[target].DetailUVChannels
            );
            target.SetFloat("_DetailUV", (int)dictionaryFoldouts[target].DetailUVChannels);

            dictionaryFoldouts[target].FaceShadowMaskUVChannels = (UVChannels)EditorGUILayout.EnumPopup(
            new GUIContent("Face Shadow Mask Texture Channel", "Base Texture UV Channel"), 
            dictionaryFoldouts[target].FaceShadowMaskUVChannels
            );
            target.SetFloat("_FaceShadowMaskUV", (int)dictionaryFoldouts[target].FaceShadowMaskUVChannels);

            dictionaryFoldouts[target].FaceShadowMask2UVChannels = (UVChannels)EditorGUILayout.EnumPopup(
            new GUIContent("Face Shadow Mask 2 Texture Channel", "ILM Texture UV Channel"), 
            dictionaryFoldouts[target].FaceShadowMask2UVChannels
            );
            target.SetFloat("_FaceShadowMask2UV", (int)dictionaryFoldouts[target].FaceShadowMask2UVChannels);

            dictionaryFoldouts[target].EmissionUVChannels = (UVChannels)EditorGUILayout.EnumPopup(
            new GUIContent("Emission Texture Channel", "Shadow Texture UV Channel"), 
            dictionaryFoldouts[target].EmissionUVChannels
            );
            target.SetFloat("_EmissionUV", (int)dictionaryFoldouts[target].EmissionUVChannels);

            dictionaryFoldouts[target].NormalMapUVChannels = (UVChannels)EditorGUILayout.EnumPopup(
            new GUIContent("NormalMap Texture Channel", "ILM Texture UV Channel"), 
            dictionaryFoldouts[target].NormalMapUVChannels
            );
            target.SetFloat("_NormalMapUV", (int)dictionaryFoldouts[target].NormalMapUVChannels);

            dictionaryFoldouts[target].ParallaxMapUVChannels = (UVChannels)EditorGUILayout.EnumPopup(
            new GUIContent("Height Texture Channel", "Shadow Texture UV Channel"), 
            dictionaryFoldouts[target].ParallaxMapUVChannels
            );
            target.SetFloat("_ParallaxMapUV", (int)dictionaryFoldouts[target].ParallaxMapUVChannels);
        }
    }
    #endregion
    
    EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);
    
    #region Debug Foldout
    dictionaryFoldouts[target].debugFoldout = EditorGUILayout.Foldout(
        dictionaryFoldouts[target].debugFoldout, 
        new GUIContent(dictionaryFoldouts[target].labels[6], dictionaryFoldouts[target].toolTips[6])
    );
        
    if(dictionaryFoldouts[target].debugFoldout)
    {
        if(CreateKeywordToogle("_DEBUG","Debug","Enable, disable Debug", materialEditor))
        {
            dictionaryFoldouts[target].debugOptions = (DebugOptions)EditorGUILayout.EnumPopup("Debug Options", dictionaryFoldouts[target].debugOptions);              
            switch((int)dictionaryFoldouts[target].debugOptions)
            {
                case 0:
                    target.SetFloat("_VertexColors", 0);
                    target.SetFloat("_ILMDebug", 0);
                    materialEditor.ShaderProperty(_DebugStates, "Debug Light Ramps");
                    break;
                case 1: 
                    target.SetFloat("_VertexColors", 1);
                    target.SetFloat("_ILMDebug", 0);
                    materialEditor.ShaderProperty(_VertexChannel, "Vertex Colors");             
                    break;
                case 2:
                    target.SetFloat("_VertexColors", 0);
                    target.SetFloat("_ILMDebug", 1);
                    materialEditor.ShaderProperty(_ILMChannel, "Texture Channels");               
                    break;
                default:
                    materialEditor.ShaderProperty(_DebugStates, "Debug Light Ramps");
                    break;
            }          
        }
    }
    else
    {
        target.DisableKeyword("_Debug");
    }
    #endregion

    base.OnGUI(materialEditor, properties);
}

void GetProperties(MaterialProperty[] properties)
{
    _DistortionFactor = ShaderGUI.FindProperty("_DistortionFactor", properties);
    _GGStriveWorkFlow = ShaderGUI.FindProperty("_GGStriveWorkFlow", properties);
    _Isface = ShaderGUI.FindProperty("_Isface", properties);
    _FSMEnum = ShaderGUI.FindProperty("_FSMEnum", properties);
    _Cull = ShaderGUI.FindProperty("_Cull", properties);

    _BaseColor = ShaderGUI.FindProperty("_BaseColor", properties);
    _ShadowColor = ShaderGUI.FindProperty("_ShadowColor", properties);
    _ILM = ShaderGUI.FindProperty("_ILM", properties);
    _Detail = ShaderGUI.FindProperty("_Detail", properties);
    _FaceShadowMask = ShaderGUI.FindProperty("_FaceShadowMask", properties);
    _FaceShadowMask2 = ShaderGUI.FindProperty("_FaceShadowMask2", properties);
    _Emission = ShaderGUI.FindProperty("_Emission", properties);
    _NormalMap = ShaderGUI.FindProperty("_NormalMap", properties);
    _Parallax = ShaderGUI.FindProperty("_Parallax", properties);
    _ParallaxMap = ShaderGUI.FindProperty("_ParallaxMap", properties);

    _BaseTint = ShaderGUI.FindProperty("_BaseTint", properties);
    _BaseIntensity = ShaderGUI.FindProperty("_BaseIntensity", properties);
    _BaseSaturation = ShaderGUI.FindProperty("_BaseSaturation", properties);
    _ShadowTint = ShaderGUI.FindProperty("_ShadowTint", properties);
    _ShadowIntensity = ShaderGUI.FindProperty("_ShadowIntensity", properties);
    _ShadowSaturation = ShaderGUI.FindProperty("_ShadowSaturation", properties);
    _Shadow2Tint = ShaderGUI.FindProperty("_Shadow2Tint", properties); 
    _Shadow2Intensity = ShaderGUI.FindProperty("_Shadow2Intensity", properties);
    _Shadow2Saturation = ShaderGUI.FindProperty("_Shadow2Saturation", properties) ;
    _SpecularTint = ShaderGUI.FindProperty("_SpecularTint", properties);
    _SpecularIntensity = ShaderGUI.FindProperty("_SpecularIntensity", properties);
    _SpecularSaturation = ShaderGUI.FindProperty("_SpecularSaturation", properties);
    _FresnelTint = ShaderGUI.FindProperty("_FresnelTint", properties);
    _FresnelIntensity = ShaderGUI.FindProperty("_FresnelIntensity", properties);
    _FresnelSaturation = ShaderGUI.FindProperty("_FresnelSaturation", properties);
    _EmissionTint = ShaderGUI.FindProperty("_EmissionTint", properties);
    _EmissionIntensity = ShaderGUI.FindProperty("_EmissionIntensity", properties);
    _EmissionSaturation = ShaderGUI.FindProperty("_EmissionSaturation", properties);

    _ReceiveShadows = ShaderGUI.FindProperty("_ReceiveShadows2", properties);
    _remapRotation = ShaderGUI.FindProperty("_Remap", properties);
    _ShadeSmoothStep = ShaderGUI.FindProperty("_ShadeSmoothStep", properties);
    _ShadowOffset = ShaderGUI.FindProperty("_ShadowOffset", properties);
    _Shadow2Offset = ShaderGUI.FindProperty("_Shadow2Offset", properties);
    _Fresnel = ShaderGUI.FindProperty("_Fresnel", properties);
    _Specular = ShaderGUI.FindProperty("_Specular", properties);
    _FresnelSize = ShaderGUI.FindProperty("_FresnelSize", properties);
    _FresnelThreshHold = ShaderGUI.FindProperty("_FresnelThreshHold", properties);    
    _FresnelShadowsOnly = ShaderGUI.FindProperty("_FresnelShadowsOnly", properties);
    _SpecularSize = ShaderGUI.FindProperty("_SpecularSize", properties);

    _AdditionalLightReplaceColor = ShaderGUI.FindProperty("_AdditionalLightReplaceColor", properties);

    _Debug = ShaderGUI.FindProperty("_Debug", properties);
    _DebugStates = ShaderGUI.FindProperty("_DebugStates", properties);
    _VertexColors = ShaderGUI.FindProperty("_VertexColors", properties);
    _VertexChannel = ShaderGUI.FindProperty("_VertexChannel", properties);  
    _ILMDebug = ShaderGUI.FindProperty("_ILMDebug", properties);
    _ILMChannel = ShaderGUI.FindProperty("_ILMChannel", properties);

    _Surface = ShaderGUI.FindProperty("_Surface", properties);
    _Blend = ShaderGUI.FindProperty("_Blend", properties);
    _AlphaClip = ShaderGUI.FindProperty("_AlphaClip", properties);
    _AlphaClipThreshold = ShaderGUI.FindProperty("_AlphaClipThreshold", properties);;
    _AlphaClipChannel = ShaderGUI.FindProperty("_AlphaClipChannel", properties);;
    _SrcBlend = ShaderGUI.FindProperty("_SrcBlend", properties);
    _DstBlend = ShaderGUI.FindProperty("_DstBlend", properties);
    _ZWrite = ShaderGUI.FindProperty("_ZWrite", properties);
}

bool CreatePropertyToogle(string propertyName, string label, string toolTips, MaterialEditor materialEditor)
{
    bool output = false;
    Material target = materialEditor.target as Material;
    target.SetFloat(
            propertyName,
            Convert.ToSingle(
                EditorGUILayout.Toggle( 
                    new GUIContent(label, toolTips),
                    Convert.ToBoolean(target.GetFloat(propertyName))
                )
            )
        );
    output = target.GetFloat(propertyName) > 0? true: false;
    return output;
}

bool CreateKeywordToogle(string propertyName, string label, string toolTips, MaterialEditor materialEditor)
{    
    Material target = materialEditor.target as Material;
    bool keyword = target.IsKeywordEnabled(propertyName);
    bool output = EditorGUILayout.Toggle( new GUIContent(label, toolTips), keyword);
    if(output)
    {
        target.EnableKeyword(propertyName);
    }
    else
    {
        target.DisableKeyword(propertyName);
    }    
    return output;
}

void ChangeSurfaceType(Material target, Dictionary<Material, FinalToonShaderFoldout > dictionaryFoldouts)
{
    switch(dictionaryFoldouts[target].surfaceType)
    {
        case SurfaceType.Opaque:
            if(target.GetFloat("_AlphaClip") <= 0)
            {
                target.renderQueue = (int)RenderQueue.Geometry;
                target.SetOverrideTag("Renter Type", "Opaque");
                target.DisableKeyword("_ALPHATEST_ON");                   
            }
            else
            {
                target.renderQueue = (int)RenderQueue.AlphaTest;
                target.SetOverrideTag("Renter Type", "TransparentCutout");
                target.EnableKeyword("_ALPHATEST_ON");                    
            }
            target.SetInt("_SrcBlend", (int)BlendMode.One);
            target.SetInt("_DstBlend", (int)BlendMode.Zero);
            target.SetInt("_ZWrite", 1);                
        break;
        case SurfaceType.Transparent:
            target.renderQueue = (int)RenderQueue.Transparent;
            target.SetOverrideTag("Renter Type", "Transparent");
            target.DisableKeyword("_ALPHATEST_ON");
            if(dictionaryFoldouts[target].alphaBlendMode == AlphaBlendMode.Alpha)
            {
                target.SetInt("_SrcBlend", (int)BlendMode.SrcAlpha);
                target.SetInt("_DstBlend", (int)BlendMode.OneMinusSrcAlpha);
            }
            else
            {
                target.SetInt("_SrcBlend", (int)BlendMode.SrcAlpha);
                target.SetInt("_DstBlend", (int)BlendMode.One);
            }
            target.SetInt("_ZWrite", 0);
        break;
        default:
            target.renderQueue = (int)RenderQueue.Geometry;
            target.SetOverrideTag("Renter Type", "Opaque");
            target.DisableKeyword("_ALPHATEST_ON"); 
            target.SetInt("_SrcBlend", (int)BlendMode.One);
            target.SetInt("_DstBlend", (int)BlendMode.Zero);
            target.SetInt("_ZWrite", 1);
        break;
    }
}
}
