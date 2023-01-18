using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using System;
using MyBox;
using FinalToonShader;

[Serializable]
public class FinalToonShaderController : MonoBehaviour
{
#region Variables
    [SerializeField]
    static Shader finalToonShader;
    public GameObject _sun;
    public GameObject _faceGameObject;
    [SerializeField]
    [Range(0,1)]
    float _distortionFactor = 0;
    [SerializeField]    
    public bool _useGGStriveWorkflow = false;
    public RenderFace renderFace = RenderFace.Front;
    public SurfaceType surfaceType = SurfaceType.Opaque;
    public AlphaBlendMode alphaBlendMode = AlphaBlendMode.Alpha;
    [SerializeField]
    public bool alphaClip = false;
    [Range(0,1)]
    public float alphaClipThreshold = 0;
    public AlphaClipChannel alphaClipChannel = AlphaClipChannel.BaseTextureAlpha;   
    public ShadowMaskOptions shadowMaskOptions = ShadowMaskOptions.MaskVertical;
    [SerializeField]
    [ColorUsage(true, true)]
    Color _BaseTint = Color.white;
    [SerializeField]
    [Range(0,5)]
    float _BaseIntensity = 1f;
    [SerializeField]
    [Range(0,5)]
    float _BaseSaturation = 1f;
    [SerializeField]
    [ColorUsage(true, true)]
    Color _ShadowTint = Color.white;
    [SerializeField]
    [Range(0,5)]
    float _ShadowIntensity = 1;
    [SerializeField]
    [Range(0,5)]
    float _ShadowSaturation = 1;
    [SerializeField]
    [ColorUsage(true, true)]
    Color _Shadow2Tint = Color.grey;
    [SerializeField]
    [Range(0,5)]
    float _Shadow2Intensity = 1;
    [SerializeField]
    [Range(0,5)]
    float _Shadow2Saturation = 1;  
    [SerializeField]
    [ColorUsage(true, true)]
    Color _SpecularTint = Color.white;
    [SerializeField]
    [Range(0,5)]
    float _SpecularIntensity = 1;
    [SerializeField]
    [Range(0,5)]
    float _SpecularSaturation = 1; 
    [SerializeField]
    [ColorUsage(true, true)] 
    Color _FresnelTint = new Vector4(0.7f,0.7f,0.7f,0.7f);
    [SerializeField]
    [Range(0,5)]
    float _FresnelIntensity = 1;
    [SerializeField]
    [Range(0,5)]
    float _FresnelSaturation = 1;
    [SerializeField]
    [ColorUsage(true, true)]
    Color _EmissionTint = Color.white;
    [SerializeField]
    [Range(0,5)]
    float _EmissionIntensity = 1;
    [SerializeField]
    [Range(0,5)]
    float _EmissionSaturation = 1;    
    [SerializeField]
    bool _ReceiveShadows = false;
    [SerializeField]
    Vector2 _remapRotation = new Vector2(-1f,2.5f);
    Vector3 _UPVector;
    Vector3 _RightVector;
    Vector3 _FowardVector;
    Vector3 _SunEuler;
    [SerializeField]
    [Range(0,1)]
    float _ShadeSmoothStep = 0.3f;
    [SerializeField]
    [Range(-1,1)]
    float _ShadowOffset = 0;
    [SerializeField]
    [Range(-1,1)]
    float _Shadow2Offset = -0.4f; //add 
    [SerializeField]       
    public bool _Fresnel = true;
    [SerializeField]
    [Range(-1,5)]
    float _FresnelSize = 0.4f; //add
    [SerializeField]
    [Range(0,1)]
    float _FresnelThreshHold = 0.8f;
    [SerializeField]
    bool _FresnelShadowsOnly = false;
    [SerializeField]
    public bool _Specular = true;
    [SerializeField]
    [Range(0,20)]
    float _SpecularSize = 6f;
    [SerializeField]
    public bool _AdditionalLightReplaceColor = false;
    [SerializeField]
    public bool _Debug = false;
    public DebugOptions debugOptions = DebugOptions.LighRamp;    
    [SerializeField]
    public DebugLight debugLightOption = DebugLight.MainLight;    
    [SerializeField]
    public bool _VertexColors = false;
    [SerializeField]
    public TextureDebug debugVertexColors = TextureDebug.AllChannels;
    [SerializeField]
    public bool _ILMDebug = false;
    [SerializeField]
    public TextureDebug debugILM = TextureDebug.AllChannels;
    public bool customUV = false;
    public UVChannels baseChannels = UVChannels.UV0;
    public UVChannels shadowChannels = UVChannels.UV0;
    public UVChannels ILMUVChannels = UVChannels.UV0;
    public UVChannels DetailUVChannels = UVChannels.UV3;
    public UVChannels FaceShadowMaskUVChannels = UVChannels.UV0;
    public UVChannels FaceShadowMaskGradientUVChannels = UVChannels.UV0;
    public UVChannels FaceShadowMask2UVChannels = UVChannels.UV0;
    public UVChannels FaceShadowMask2GradientUVChannels = UVChannels.UV0;
    public UVChannels EmissionUVChannels = UVChannels.UV0;
    public UVChannels NormalMapUVChannels = UVChannels.UV0;
    public UVChannels ParallaxMapUVChannels = UVChannels.UV0;
    
#endregion

    private void Update() {
        UpdateFaceVectors();        
    }

    void UpdateFaceVectors()
    {
        if(_faceGameObject != null && _sun != null)
        {
            _FowardVector = _faceGameObject.transform.forward;
            _RightVector = _faceGameObject.transform.right;
            _UPVector = _faceGameObject.transform.up;
            _SunEuler = new Vector3(_sun.transform.rotation.x, _sun.transform.rotation.y,_sun.transform.rotation.z);          
            List<Material> materials = new List<Material>();
            materials = GetMaterialsInChildren();
            for(int i = 0; i < materials.Count; i++)
            {
                Material newMat = materials[i];
                if(materials[i] != null)
                {                   
                    if(materials[i].GetFloat("_Isface") > 0)
                    {
                        newMat.SetVector("_FowardVector", _FowardVector);            
                        newMat.SetVector("_RightVector", _RightVector);
                        newMat.SetVector("_UPVector", _UPVector);
                        newMat.SetVector("_SunEuler", _SunEuler);                          
                    }                    
                }             
            } 
        }         
    }
    
    List<Material> GetMaterialsInChildren()
    {
        if(finalToonShader == null)
        {
            finalToonShader = Shader.Find("GabrielShaders/ToonShader");
        }        
        List<Material> materials = new List<Material>();
        Renderer[] root = GetComponents<Renderer>();
        Renderer[] childs = GetComponentsInChildren<Renderer>();
        foreach(Renderer rend in root)
        {
            foreach(Material mat in rend.sharedMaterials)
            {
                if(mat.shader == finalToonShader)
                {
                    materials.Add(mat);
                }
            }            
        }

        foreach(Renderer rend in childs)
        {
            foreach(Material mat in rend.sharedMaterials)
            {
                if(mat.shader == finalToonShader)
                {
                    materials.Add(mat);
                }
            }            
        }
        return materials;
    }    
    
    List<Material> UpdateMaterialSettings()
    {
        List<Material> materials = new List<Material>(); 
        materials = GetMaterialsInChildren();
        for(int i = 0; i < materials.Count; i++)
        {
            Material newMat = materials[i];
            if(materials[i] != null)
            {
                KeywordHandle("_GGSTRIVEWORKFLOW", _useGGStriveWorkflow, newMat);
                KeywordHandle("_DEBUG", _Debug, newMat);
                KeywordHandle("_ADDITIONAL_LIGHT_REPLACE", _AdditionalLightReplaceColor, newMat);
                KeywordHandle("_CUSTOM_UV", customUV, newMat);
                newMat.SetFloat("_DistortionFactor", _distortionFactor);
                newMat.SetColor("_BaseTint", _BaseTint);
                newMat.SetFloat("_BaseIntensity", _BaseIntensity);
                newMat.SetFloat("_BaseSaturation", _BaseSaturation);
                newMat.SetColor("_ShadowTint", _ShadowTint);
                newMat.SetFloat("_ShadowIntensity", _ShadowIntensity);
                newMat.SetFloat("_ShadowSaturation", _ShadowSaturation);
                newMat.SetColor("_Shadow2Tint", _Shadow2Tint);
                newMat.SetFloat("_Shadow2Intensity", _Shadow2Intensity);
                newMat.SetFloat("_Shadow2Saturation", _Shadow2Saturation);
                newMat.SetColor("_SpecularTint", _SpecularTint);
                newMat.SetFloat("_SpecularIntensity", _SpecularIntensity);
                newMat.SetFloat("_SpecularSaturation", _SpecularSaturation);
                newMat.SetColor("_FresnelTint", _FresnelTint);
                newMat.SetFloat("_FresnelIntensity", _FresnelIntensity);
                newMat.SetFloat("_FresnelSaturation", _FresnelSaturation);
                newMat.SetColor("_EmissionTint", _EmissionTint);
                newMat.SetFloat("_EmissionIntensity", _EmissionIntensity);
                newMat.SetFloat("_EmissionSaturation", _EmissionSaturation);
                newMat.SetVector("_Remap", _remapRotation);
                newMat.SetFloat("_ShadeSmoothStep", _ShadeSmoothStep);
                newMat.SetFloat("_ReceiveShadows2", Convert.ToSingle(_ReceiveShadows));
                newMat.SetFloat("_ShadowOffset", _ShadowOffset);
                newMat.SetFloat("_Shadow2Offset", _Shadow2Offset);
                newMat.SetFloat("_Fresnel", Convert.ToSingle(_Fresnel));
                newMat.SetFloat("_FresnelSize", _FresnelSize);
                newMat.SetFloat("_FresnelThreshHold", _FresnelThreshHold);
                newMat.SetFloat("_FresnelShadowsOnly", Convert.ToSingle(_FresnelShadowsOnly));
                newMat.SetFloat("_Specular", Convert.ToSingle(_Specular));
                newMat.SetFloat("_SpecularSize", _SpecularSize);
                newMat.SetFloat("_AdditionalLightReplaceColor", Convert.ToSingle(_AdditionalLightReplaceColor));
                newMat.SetFloat("_Debug", Convert.ToSingle(_Debug));
                newMat.SetFloat("_DebugStates", (int)debugLightOption);
                newMat.SetFloat("_VertexColors", Convert.ToSingle(_VertexColors));
                newMat.SetFloat("_VertexChannel", (int)debugVertexColors);
                newMat.SetFloat("_ILMDebug", Convert.ToSingle(_ILMDebug));
                newMat.SetFloat("_ILMChannel", (int)debugILM);
                newMat.SetFloat("_BaseColorUV", (int)baseChannels);
                newMat.SetFloat("_ShadowColorUV", (int)shadowChannels);
                newMat.SetFloat("_ILMUV", (int)ILMUVChannels);
                newMat.SetFloat("_DetailUV", (int)DetailUVChannels);
                newMat.SetFloat("_FaceShadowMaskUV", (int)FaceShadowMaskUVChannels);
                newMat.SetFloat("_FaceShadowMask2UV", (int)FaceShadowMask2UVChannels);
                newMat.SetFloat("_EmissionUV", (int)EmissionUVChannels);
                newMat.SetFloat("_NormalMapUV", (int)NormalMapUVChannels);
                newMat.SetFloat("_ParallaxMapUV", (int)ParallaxMapUVChannels);
                newMat.SetFloat("_Cull", (int)renderFace);
                newMat.SetFloat("_AlphaClip", Convert.ToSingle(alphaClip));
                newMat.SetFloat("_AlphaClipChannel", (int)alphaClipChannel);
                newMat.SetFloat("_AlphaClipThreshold", alphaClipThreshold);
            }
            ChangeSurfaceType(newMat);
            materials[i] = newMat;
        }
        return materials;
    }

    void KeywordHandle(string name, bool state, Material target)
    {
        if(state)
        {
            target.EnableKeyword(name);
        }
        else
        {
            target.DisableKeyword(name);
        }
    }

    void ChangeSurfaceType(Material target)
    {
        switch(surfaceType)
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
                if(alphaBlendMode == AlphaBlendMode.Alpha)
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

    void SaveMaterials(List<Material> materials)
    {
        foreach(Material mat in materials)
        {
            EditorUtility.SetDirty( mat );
        }        
    }

    void UpdateMaterial(){       
        SaveMaterials(UpdateMaterialSettings());
    }
}
