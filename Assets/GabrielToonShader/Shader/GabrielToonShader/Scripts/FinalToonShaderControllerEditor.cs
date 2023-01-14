using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using FinalToonShader;

[CustomEditor(typeof(FinalToonShaderController))]
public class FinalToonShaderControllerEditor : Editor
{
    #region Variable
    SerializedObject m_Object;
    SerializedProperty _sun;
    SerializedProperty _faceGameObject;
    SerializedProperty _gradient;
    SerializedProperty _gradientMaterial;
    SerializedProperty _gradientOption;
    SerializedProperty _alphaClip;
    SerializedProperty _alphaClipThreshold;
    SerializedProperty _resolution;
    SerializedProperty _distortionFactor;
    SerializedProperty _useGGStriveWorkflow;
    SerializedProperty _BaseTint;
    SerializedProperty _BaseIntensity;
    SerializedProperty _BaseSaturation;
    SerializedProperty _ShadowTint;
    SerializedProperty _ShadowIntensity ;
    SerializedProperty _ShadowSaturation ;
    SerializedProperty _Shadow2Tint ; 
    SerializedProperty _Shadow2Intensity;
    SerializedProperty _Shadow2Saturation ;
    SerializedProperty _SpecularTint ;
    SerializedProperty _SpecularIntensity ;
    SerializedProperty _SpecularSaturation ;
    SerializedProperty _FresnelTint ;
    SerializedProperty _FresnelIntensity ;
    SerializedProperty _FresnelSaturation ;
    SerializedProperty _EmissionTint ;
    SerializedProperty _EmissionIntensity ;
    SerializedProperty _EmissionSaturation ;
    SerializedProperty _ReceiveShadows ;
    SerializedProperty _remapRotation ;
    SerializedProperty _ShadeSmoothStep;
    SerializedProperty _ShadowOffset;
    SerializedProperty _Shadow2Offset;
    SerializedProperty _Fresnel;
    SerializedProperty _FresnelSize;
    SerializedProperty _FresnelThreshHold;    
    SerializedProperty _FresnelShadowsOnly;
    SerializedProperty _SpecularSize;    
    SerializedProperty _AdditionalLightReplaceColor;  
    SerializedProperty _Debug;
    SerializedProperty debugOptions;
    SerializedProperty debugLightOption;
    SerializedProperty _VertexColors;      
    SerializedProperty debugVertexColors;       
    SerializedProperty _ILMDebug;       
    SerializedProperty debugILM;
    SerializedProperty workflow;
    SerializedProperty customUV;
    SerializedProperty baseChannels;
    SerializedProperty shadowChannels;
    SerializedProperty ILMUVChannels;
    SerializedProperty DetailUVChannels;
    SerializedProperty FaceShadowMaskUVChannels;
    SerializedProperty FaceShadowMaskGradientUVChannels;
    SerializedProperty FaceShadowMask2UVChannels;
    SerializedProperty FaceShadowMask2GradientUVChannels;
    SerializedProperty EmissionUVChannels;
    SerializedProperty NormalMapUVChannels;
    SerializedProperty ParallaxMapUVChannels;

    public static Dictionary<Object, FinalToonShaderFoldout > dictionaryFoldouts = new Dictionary<Object, FinalToonShaderFoldout>();
    FinalToonShaderFoldout foldoutBools = new FinalToonShaderFoldout();
    #endregion 

    public virtual void OnEnable()
    {        
        GetProperties();
    }

    public override void OnInspectorGUI()
    {
        m_Object.Update();    
        FinalToonShaderController toonController = (FinalToonShaderController)target;

        if (!dictionaryFoldouts.ContainsKey(target))
        {
            dictionaryFoldouts.Add(target, foldoutBools);
        }        

        EditorGUILayout.LabelField("", GUI.skin.horizontalSlider); 

        #region Gradient Foldout
        dictionaryFoldouts[target].gradientToolFoldout = EditorGUILayout.Foldout(
            dictionaryFoldouts[target].gradientToolFoldout, 
            new GUIContent(dictionaryFoldouts[target].labels[2], dictionaryFoldouts[target].toolTips[2])
        );       
        if(dictionaryFoldouts[target].gradientToolFoldout)
        {
            EditorGUILayout.PropertyField(_gradient);
            EditorGUILayout.PropertyField(_gradientMaterial);
            EditorGUILayout.PropertyField(_gradientOption);
            if(GUILayout.Button("Create Gradient"))
            {
                toonController.CreateGradient();
            }
        }
        #endregion
        
        EditorGUILayout.LabelField("", GUI.skin.horizontalSlider); 

        #region Edit Button
        GUIStyle buttonStyle = new GUIStyle(GUI.skin.button);
        buttonStyle.normal.textColor = Color.blue;
        buttonStyle.onNormal.textColor = Color.blue;
        buttonStyle.hover.textColor = Color.blue;

        GUIStyle buttonStyle2 = new GUIStyle(GUI.skin.button);
        buttonStyle2.normal.textColor = Color.green;
        buttonStyle2.onNormal.textColor = Color.green;
        buttonStyle2.hover.textColor = Color.green;    

        if(dictionaryFoldouts[target].editingState)
        {            
            dictionaryFoldouts[target].editingState = !GUILayout.Button("Stop Editing",buttonStyle2);            
        }
        else
        {
            dictionaryFoldouts[target].editingState = GUILayout.Button("Start Editing", buttonStyle);            
        }
        #endregion

        EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);

        #region Configuration Foldout        
        dictionaryFoldouts[target].configurationFoldout = EditorGUILayout.Foldout(
            dictionaryFoldouts[target].configurationFoldout, 
            new GUIContent(dictionaryFoldouts[target].labels[0], dictionaryFoldouts[target].toolTips[0])
        );
        if(dictionaryFoldouts[target].configurationFoldout)
        {
            EditorGUI.BeginChangeCheck();
            EditorGUILayout.PropertyField(_sun);
            EditorGUILayout.PropertyField(_faceGameObject);
            if(EditorGUI.EndChangeCheck())
            {
                m_Object.ApplyModifiedProperties();
            }
            EditorGUI.BeginChangeCheck();
            dictionaryFoldouts[target].workflowEnum = (ShaderWorkflow)EditorGUILayout.EnumPopup(
                new GUIContent(dictionaryFoldouts[target].labels[1], dictionaryFoldouts[target].toolTips[1]), 
                dictionaryFoldouts[target].workflowEnum
            );
            if(EditorGUI.EndChangeCheck())
            {
                if(dictionaryFoldouts[target].workflowEnum == ShaderWorkflow.GGStrive)
                {
                    toonController._useGGStriveWorkflow = true;
                }
                else
                {
                    toonController._useGGStriveWorkflow = false;
                }                
            }
            
            toonController.renderFace = (RenderFace)EditorGUILayout.EnumPopup(
                new GUIContent("Render Face", "Specifies which faces to cull from your geometry. Front culls front faces. Back culls backfaces. None means that both sides are rendered."), 
                dictionaryFoldouts[target].renderFace
            );
            dictionaryFoldouts[target].renderFace = toonController.renderFace;

            toonController.surfaceType = (SurfaceType)EditorGUILayout.EnumPopup(
                new GUIContent("Surface Type", "Change the surface type"), 
                dictionaryFoldouts[target].surfaceType
            );
            dictionaryFoldouts[target].surfaceType = toonController.surfaceType;

            if(toonController.surfaceType == SurfaceType.Transparent)
            {
                toonController.alphaBlendMode = (AlphaBlendMode)EditorGUILayout.EnumPopup(
                new GUIContent("Blend Mode", "Chose Blend mode for transparent object"), 
                dictionaryFoldouts[target].alphaBlendMode
                );
                dictionaryFoldouts[target].alphaBlendMode = toonController.alphaBlendMode;
            }

            EditorGUILayout.PropertyField(_alphaClip);
            if(toonController.alphaClip)
            {
                toonController.alphaClipChannel = (AlphaClipChannel)EditorGUILayout.EnumPopup(
                new GUIContent("Alpha Clip Channel", "Select the channel that contains the cutout mask"), 
                dictionaryFoldouts[target].alphaClipChannel
                );
                dictionaryFoldouts[target].alphaClipChannel = toonController.alphaClipChannel;

               EditorGUILayout.PropertyField(_alphaClipThreshold);         
            }

            EditorGUILayout.PropertyField(_ReceiveShadows, new GUIContent("Receive Shadows","Receive shadow cast of other objects"));
        }
        #endregion

        EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);        
        
        #region ColorFoldout
        dictionaryFoldouts[target].colorOptionsFoldout = EditorGUILayout.Foldout(
            dictionaryFoldouts[target].colorOptionsFoldout, 
            new GUIContent(dictionaryFoldouts[target].labels[3], dictionaryFoldouts[target].toolTips[3])
        );

        if(dictionaryFoldouts[target].colorOptionsFoldout)
        {
            EditorGUILayout.PropertyField(_BaseTint);
            EditorGUILayout.PropertyField(_BaseIntensity);
            EditorGUILayout.PropertyField(_BaseSaturation);
            EditorGUILayout.Space();
            EditorGUILayout.PropertyField(_ShadowTint);
            EditorGUILayout.PropertyField(_ShadowIntensity);
            EditorGUILayout.PropertyField(_ShadowSaturation);
            EditorGUILayout.Space();
            EditorGUILayout.PropertyField(_Shadow2Tint);
            EditorGUILayout.PropertyField(_Shadow2Intensity);
            EditorGUILayout.PropertyField(_Shadow2Saturation); 
            EditorGUILayout.Space();           
            EditorGUILayout.PropertyField(_EmissionTint);
            EditorGUILayout.PropertyField(_EmissionIntensity);
            EditorGUILayout.PropertyField(_EmissionSaturation);
        }
        #endregion

        EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);

        #region AdditionalColorsFoldout
        dictionaryFoldouts[target].additionalColorsFoldout = EditorGUILayout.Foldout(
            dictionaryFoldouts[target].additionalColorsFoldout, 
            new GUIContent(dictionaryFoldouts[target].labels[4], dictionaryFoldouts[target].toolTips[4])
        );       
        if(dictionaryFoldouts[target].additionalColorsFoldout)
        {
            toonController._Fresnel = EditorGUILayout.Toggle( new GUIContent("Rim Light","Enable, disable Rim Light"), toonController._Fresnel);            
            if(toonController._Fresnel)
            {
                EditorGUILayout.PropertyField(_FresnelTint);
                EditorGUILayout.PropertyField(_FresnelIntensity);
                EditorGUILayout.PropertyField(_FresnelSaturation);
            }

            EditorGUILayout.Space();

            toonController._Specular = EditorGUILayout.Toggle( new GUIContent("Specular Highlight","Enable, disable Specular Highlight"), toonController._Specular);            
            if(toonController._Specular)
            {
                EditorGUILayout.PropertyField(_SpecularTint);
                EditorGUILayout.PropertyField(_SpecularIntensity);
                EditorGUILayout.PropertyField(_SpecularSaturation);
            }
        }
        #endregion

        EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);

        #region RampAjust
        dictionaryFoldouts[target].rampAjustsFoldout = EditorGUILayout.Foldout(
            dictionaryFoldouts[target].rampAjustsFoldout, 
            new GUIContent(dictionaryFoldouts[target].labels[5], dictionaryFoldouts[target].toolTips[5])
        );    
        if(dictionaryFoldouts[target].rampAjustsFoldout)
        {          
            EditorGUILayout.PropertyField(_ShadeSmoothStep);
            EditorGUILayout.PropertyField(_ShadowOffset);
            EditorGUILayout.PropertyField(_Shadow2Offset);           
            EditorGUILayout.Space();

            toonController._Fresnel = EditorGUILayout.Toggle( new GUIContent("Rim Light","Enable, disable Rim Light"), toonController._Fresnel);            
            if(toonController._Fresnel)
            {
                EditorGUILayout.PropertyField(_FresnelSize);
                EditorGUILayout.PropertyField(_FresnelThreshHold);
                EditorGUILayout.PropertyField(_FresnelShadowsOnly, new GUIContent("Fresnel Only Shadows","Enable, disable fresnel only in shadows"));
            }

            EditorGUILayout.Space();

            toonController._Specular = EditorGUILayout.Toggle( new GUIContent("Specular Highlight","Enable, disable Specular Highlight"), toonController._Specular);            
            if(toonController._Specular)
            {
                EditorGUILayout.PropertyField(_SpecularSize);
            }
            EditorGUILayout.Space();

            EditorGUILayout.PropertyField(_remapRotation, new GUIContent("Remap Shadow Face Rotation","Remap min max shadow face rotation"));
        }
        #endregion

        EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);

        #region OthersOptions
        dictionaryFoldouts[target].otherOptionsFoldout = EditorGUILayout.Foldout(
            dictionaryFoldouts[target].otherOptionsFoldout, 
            new GUIContent(dictionaryFoldouts[target].labels[6], dictionaryFoldouts[target].toolTips[6])
        );
        if(dictionaryFoldouts[target].otherOptionsFoldout)
        {
            toonController._AdditionalLightReplaceColor = EditorGUILayout.Toggle
            ( 
                new GUIContent("Additional Light Replace", "Enable, disable, additional light replace pixel color"), 
                toonController._AdditionalLightReplaceColor
            );
            EditorGUILayout.Space();
            EditorGUILayout.PropertyField(_distortionFactor, new GUIContent("Distortion Vertex","CAN RESULT IN ARTIFACTS! Distortion per vertex base, to squash the mesh"));
            EditorGUILayout.PropertyField(customUV);
            if(toonController.customUV)
            {
                EditorGUILayout.PropertyField(baseChannels);
                EditorGUILayout.PropertyField(shadowChannels);
                EditorGUILayout.PropertyField(ILMUVChannels);
                EditorGUILayout.PropertyField(DetailUVChannels);
                EditorGUILayout.PropertyField(FaceShadowMaskUVChannels);
                EditorGUILayout.PropertyField(FaceShadowMaskGradientUVChannels);
                EditorGUILayout.PropertyField(FaceShadowMask2UVChannels);
                EditorGUILayout.PropertyField(FaceShadowMask2GradientUVChannels);
                EditorGUILayout.PropertyField(EmissionUVChannels);
                EditorGUILayout.PropertyField(NormalMapUVChannels);
                EditorGUILayout.PropertyField(ParallaxMapUVChannels);
            }

        }
        #endregion

        EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);

        #region DebugFoldout
        dictionaryFoldouts[target].debugFoldout = EditorGUILayout.Foldout(
            dictionaryFoldouts[target].debugFoldout, 
            new GUIContent(dictionaryFoldouts[target].labels[7], dictionaryFoldouts[target].toolTips[7])
        );       
        if(dictionaryFoldouts[target].debugFoldout)
        {
            toonController._Debug = EditorGUILayout.Toggle( new GUIContent("Debug","Enable, disable Debug"), toonController._Debug);
            if(toonController._Debug)
            {
                EditorGUILayout.PropertyField(debugOptions,new GUIContent("Debug Options"));                
                switch((int)toonController.debugOptions)
                {
                    case 0:
                        toonController._VertexColors = false;
                        toonController._ILMDebug = false;
                        EditorGUILayout.PropertyField(debugLightOption,new GUIContent("Debug Light Ramps"));                    
                        break;
                    case 1:
                        toonController._VertexColors = true;
                        toonController._ILMDebug = false;
                        EditorGUILayout.PropertyField(debugVertexColors,new GUIContent("Vertex Colors"));                   
                        break;
                    case 2:
                        toonController._VertexColors = false;
                        toonController._ILMDebug = true;
                        EditorGUILayout.PropertyField(debugILM,new GUIContent("Texture Channels"));                  
                        break;
                    default:
                        EditorGUILayout.PropertyField(debugLightOption,new GUIContent("Debug Light Ramps"));
                        break;
                }                
            }
        }
        #endregion
                
        if(dictionaryFoldouts[target].editingState && GUI.changed)
        {
            m_Object.ApplyModifiedProperties();
            toonController.Invoke("UpdateMaterial",0f);               
                     
        }
    }

    void GetProperties()
    {
        m_Object = new SerializedObject(target);
        _sun = m_Object.FindProperty("_sun");
        _faceGameObject = m_Object.FindProperty("_faceGameObject");
        _gradient = m_Object.FindProperty("_gradient");
        _gradientMaterial = m_Object.FindProperty("_gradientMaterial");
        _gradientOption = m_Object.FindProperty("_gradientOption");
        _alphaClip = m_Object.FindProperty("alphaClip");
        _alphaClipThreshold = m_Object.FindProperty("alphaClipThreshold");
        _BaseTint = m_Object.FindProperty("_BaseTint");
        _BaseIntensity = m_Object.FindProperty("_BaseIntensity");
        _BaseSaturation = m_Object.FindProperty("_BaseSaturation");
        _ShadowTint = m_Object.FindProperty("_ShadowTint");
        _ShadowIntensity = m_Object.FindProperty("_ShadowIntensity");
        _ShadowSaturation = m_Object.FindProperty("_ShadowSaturation");
        _Shadow2Tint = m_Object.FindProperty("_Shadow2Tint");
        _Shadow2Intensity = m_Object.FindProperty("_Shadow2Intensity");
        _Shadow2Saturation = m_Object.FindProperty("_Shadow2Saturation");
        _SpecularTint = m_Object.FindProperty("_SpecularTint");
        _SpecularIntensity = m_Object.FindProperty("_SpecularIntensity");
        _SpecularSaturation = m_Object.FindProperty("_SpecularSaturation");
        _FresnelTint = m_Object.FindProperty("_FresnelTint");
        _FresnelIntensity = m_Object.FindProperty("_FresnelIntensity");
        _FresnelSaturation = m_Object.FindProperty("_FresnelSaturation");
        _EmissionTint = m_Object.FindProperty("_EmissionTint");
        _EmissionIntensity = m_Object.FindProperty("_EmissionIntensity");
        _EmissionSaturation = m_Object.FindProperty("_EmissionSaturation");
        debugOptions = m_Object.FindProperty("debugOptions");
        debugLightOption = m_Object.FindProperty("debugLightOption");        
        _VertexColors = m_Object.FindProperty("debugOptions");   
        debugVertexColors = m_Object.FindProperty("debugVertexColors");       
        _ILMDebug = m_Object.FindProperty("_ILMDebug");      
        debugILM = m_Object.FindProperty("debugILM");
        _ReceiveShadows = m_Object.FindProperty("_ReceiveShadows");
        _remapRotation = m_Object.FindProperty("_remapRotation");
        _ShadeSmoothStep = m_Object.FindProperty("_ShadeSmoothStep");
        _ShadowOffset = m_Object.FindProperty("_ShadowOffset");
        _Shadow2Offset = m_Object.FindProperty("_Shadow2Offset");
        _Fresnel = m_Object.FindProperty("_Fresnel");
        _FresnelSize = m_Object.FindProperty("_FresnelSize");
        _FresnelThreshHold = m_Object.FindProperty("_FresnelThreshHold"); 
        _FresnelShadowsOnly = m_Object.FindProperty("_FresnelShadowsOnly");
        _SpecularSize = m_Object.FindProperty("_SpecularSize");
        _AdditionalLightReplaceColor = m_Object.FindProperty("_AdditionalLightReplaceColor");
        _distortionFactor = m_Object.FindProperty("_distortionFactor");
        customUV = m_Object.FindProperty("customUV");
        baseChannels = m_Object.FindProperty("baseChannels");
        shadowChannels = m_Object.FindProperty("shadowChannels");
        ILMUVChannels = m_Object.FindProperty("ILMUVChannels");
        DetailUVChannels = m_Object.FindProperty("DetailUVChannels");
        FaceShadowMaskUVChannels = m_Object.FindProperty("FaceShadowMaskUVChannels");
        FaceShadowMaskGradientUVChannels = m_Object.FindProperty("FaceShadowMaskGradientUVChannels");
        FaceShadowMask2UVChannels = m_Object.FindProperty("FaceShadowMask2UVChannels");
        FaceShadowMask2GradientUVChannels = m_Object.FindProperty("FaceShadowMask2GradientUVChannels");
        EmissionUVChannels = m_Object.FindProperty("EmissionUVChannels");
        NormalMapUVChannels = m_Object.FindProperty("NormalMapUVChannels");
        ParallaxMapUVChannels = m_Object.FindProperty("ParallaxMapUVChannels");
    }

}


