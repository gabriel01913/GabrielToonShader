using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ToneMapingGT : ScriptableRendererFeature
{
    [System.Serializable]
    public class ToneMapingGTSettings{
        public Material material;
        public float maximumBrightness = 1;
        [Range(0,1)]
        public float contrast = 1;
        public float lienarStart = 0.22f;
        public float linearLenght = 0.4f;
        public float blackThigness = 1.33f;
        public float b = 0;
    }
    class ToneMapingGTPass : ScriptableRenderPass
    {
        private ToneMapingGTSettings settings = new ToneMapingGTSettings();
        private RenderTargetIdentifier source;
        private RenderTargetHandle tempTexture;

        public ToneMapingGTPass(ToneMapingGTSettings inputSettings)
        {
            this.settings.material = inputSettings.material;
            this.settings.maximumBrightness = inputSettings.maximumBrightness;
            this.settings.contrast = inputSettings.contrast;
            this.settings.lienarStart = inputSettings.lienarStart;
            this.settings.linearLenght = inputSettings.linearLenght;
            this.settings.blackThigness =inputSettings.blackThigness;
            this.settings.b = inputSettings.b;
            tempTexture.Init("_TempToneMapingTexture");
        }

        public void SetSource(RenderTargetIdentifier source){
            this.source = source;
        }       

        // This method is called before executing the render pass.
        // It can be used to configure render targets and their clear state. Also to create temporary render target textures.
        // When empty this render pass will render to the active camera render target.
        // You should never call CommandBuffer.SetRenderTarget. Instead call <c>ConfigureTarget</c> and <c>ConfigureClear</c>.
        // The render pipeline will ensure target setup and clearing happens in a performant manner.
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            settings.material.SetFloat("_P", settings.maximumBrightness);
            settings.material.SetFloat("_A", this.settings.contrast);
            settings.material.SetFloat("_M",this.settings.lienarStart);
            settings.material.SetFloat("_L",this.settings.linearLenght);
            settings.material.SetFloat("_C",this.settings.blackThigness);
            settings.material.SetFloat("_B", this.settings.b);            
        }

        // Here you can implement the rendering logic.
        // Use <c>ScriptableRenderContext</c> to issue drawing commands or execute command buffers
        // https://docs.unity3d.com/ScriptReference/Rendering.ScriptableRenderContext.html
        // You don't have to call ScriptableRenderContext.submit, the render pipeline will call it at specific points in the pipeline.
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get(name: "ToneMapingPass");
            RenderTextureDescriptor cameraTexture = renderingData.cameraData.cameraTargetDescriptor;
            cameraTexture.depthBufferBits = 0;
            cmd.GetTemporaryRT(tempTexture.id, cameraTexture, FilterMode.Bilinear);

            Blit(cmd, source, tempTexture.Identifier(), settings.material, 0);
            Blit(cmd, tempTexture.Identifier(), source);

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        // Cleanup any allocated resources that were created during the execution of this render pass.
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(tempTexture.id);
        }
    }
  
    [SerializeField]
    RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingPostProcessing;
    [SerializeField]
    private ToneMapingGTSettings settings = new ToneMapingGTSettings();
    ToneMapingGTPass m_ScriptablePass;
    

    /// <inheritdoc/>
    public override void Create()
    {
        m_ScriptablePass = new ToneMapingGTPass(settings);        

        // Configures where the render pass should be injected.
        m_ScriptablePass.renderPassEvent = renderPassEvent;
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        m_ScriptablePass.SetSource(renderer.cameraColorTarget);
        #if UNITY_EDITOR
        if(renderingData.cameraData.isSceneViewCamera) return;
        #endif
        if(settings.material != null)
        {
            renderer.EnqueuePass(m_ScriptablePass);
        }        
    }
}


