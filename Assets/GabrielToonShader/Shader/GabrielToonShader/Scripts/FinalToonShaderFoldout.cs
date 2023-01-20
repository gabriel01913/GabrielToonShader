using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace FinalToonShader{
    public enum UVChannels
    {
        UV0 = 0,
        UV1 = 1,
        UV2 = 2,
        UV3 = 3,
        UV4 = 4,
        UV5 = 5,
        UV6 = 6,
        UV7 = 7,
    }

    public enum ShadowMaskOptions
    {
        MaskVertical = 0, 
        MaskMultidirectional = 1,
        Both = 2
    }

    public enum ShaderWorkflow{
        Standard = 0,
        GGStrive = 1
    }

    public enum DebugOptions{
        LighRamp = 0,
        VertexColor = 1,
        ILMTexture = 2,
    }

    public enum RenderFace{
        Front = 2,
        Back = 1,
        Both = 0
    }

    public enum SurfaceType
    {
        Opaque,
        Transparent
    }

    public enum AlphaBlendMode
    {
        Alpha,
        Additive
    }

    public enum AlphaClipChannel
    {
        BaseTextureAlpha = 0, 
        DetailTextureAlpha = 1,
        NormalMapAlpha = 2,
        ShadowTextureAlpha = 3
    }

    public enum DebugLight{
        MainLight = 0,
        AdditionalLight = 1,
        ShadowRamp = 2,
        DarkShadowRamp = 3,
        SpecularRamp = 4,
        FresnelRamp = 5,
        FaceShadowMask = 6    
    }

    public enum TextureDebug{
        AllChannels = 0,
        Red = 1,
        Green = 2,
        Blue = 3,
        Alpha = 4,
    }

    public class FinalToonShaderFoldout
    {
        public bool configurationFoldout = false;
        public ShaderWorkflow workflowEnum = ShaderWorkflow.Standard;
        public DebugOptions debugOptions = DebugOptions.LighRamp;
        public RenderFace renderFace = RenderFace.Front;
        public SurfaceType surfaceType = SurfaceType.Opaque;
        public AlphaBlendMode alphaBlendMode = AlphaBlendMode.Alpha;
        public AlphaClipChannel alphaClipChannel = AlphaClipChannel.BaseTextureAlpha;
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
        public ShadowMaskOptions shadowMaskOptions = ShadowMaskOptions.MaskVertical;
        public bool textureFoldout = false;
        public bool editingState = false;    
        public bool colorOptionsFoldout = false;
        public bool additionalColorsFoldout = false;
        public bool debugFoldout = false;
        public bool rampAjustsFoldout = false;
        public bool otherOptionsFoldout = false;
        public string[] labels = new string[]{
            "Configuration",
            "Shader Workflow",
            "Base Colors",
            "Additional Colors",
            "Ramp Ajusts",
            "Others Options",
            "Debug Tools",
            "Texture"
        };
        
        public string[] toolTips = new string[]{
            "Base Configuration for the shader to work properly",
            "Standard workflow for more base material setup or Guilt Gear Striver texture/vertex color workflow",
            "Base shaded colors",
            "Additional shaded colors",
            "Ajust ramp values and offsets",
            "Miscelanious options",
            "Debug ramp options",
            "Texture options"
        };
    }
}


