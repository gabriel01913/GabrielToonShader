using System;
using System.Linq;
using UnityEditor;
using UnityEngine;
using Object = UnityEngine.Object;
using System.IO;
using MyBox;

public class GradientMaker : MonoBehaviour
{
    public Gradient gradient;
    public Material material;
    public enum Option{
        ShadowMaskVertical,
        ShadowMaskHorizontal,
        Both
    }
    public Option gradientOption = Option.ShadowMaskHorizontal;
    public int resolution = 256;
    public GradientMaker(Gradient Gradient, Material Material, Option GradientOption, int Resolution){
        this.gradient = Gradient;
        this.material = Material;
        this.gradientOption = GradientOption;
        this.resolution = Resolution;
    }

    [ButtonMethod]
    public void CreateGradient()
    {        
        Shader shader = Shader.Find("Unlit/FinalToonShader");
        if(material != null && material.shader == shader)
        {
            string path = AssetDatabase.GetAssetPath(material);
            string[] split = path.Split(new char[]{'/','.'});
            string materialName = split[split.Length-2];
            string nameGradient = gradientOption == Option.ShadowMaskVertical? "_gradientVertical" :  "_gradientHorizontal" ;
            string fullAssetName = materialName + nameGradient;
            var filterMode = gradient.mode == GradientMode.Blend
                            ? FilterMode.Bilinear
                            : FilterMode.Point;
            string pngPath = Application.dataPath + "/Gradient/"; 
            var textureAsset = GetTexture(pngPath, fullAssetName, filterMode);
            Undo.RecordObject(textureAsset, "Gradient Texture");
            textureAsset.name = fullAssetName;
            BakeGradient(gradient, textureAsset);                              
            SaveTextureAsPNG(textureAsset, pngPath, fullAssetName);

            if(gradientOption == Option.Both)
            {
                material.SetTexture("_FaceShadowMaskGradient",textureAsset);
                material.SetTexture("_FaceShadowMask2Gradient",textureAsset);
                Debug.Log("<color=#FF0000>Create Texture</color>");
            }
            else if(gradientOption == Option.ShadowMaskVertical)
            {
                material.SetTexture("_FaceShadowMaskGradient",textureAsset);
                Debug.Log("<color=#FF0000>Create Texture</color>");
            }
            else
            {
                material.SetTexture("_FaceShadowMask2Gradient",textureAsset);
                Debug.Log("<color=#FF0000>Create Texture</color>");
            }                   
        }
        else{
            Debug.Log("<color#FF0000>Material not assegined or wrong shader</color>");
        }
    }

    private Texture2D GetTexture(string path, string name, FilterMode filterMode) {
        var textureAsset = LoadTexture(path, name);

        if (textureAsset == null) {
            textureAsset = CreateTexture(path, name, filterMode);
        }

        // Force set filter mode for legacy materials.
        textureAsset.filterMode = filterMode;

        if (textureAsset.width != resolution) {
#if UNITY_2021_2_OR_NEWER
            textureAsset.Reinitialize(resolution, 1);
#else
            textureAsset.Resize(resolution, 1);
#endif
        }
        return textureAsset;
    }

    private Texture2D CreateTexture(string path, string name, FilterMode filterMode) {
        var textureAsset = new Texture2D(resolution, 1, TextureFormat.ARGB32, false)
        {
            name = name, wrapMode = TextureWrapMode.Clamp, filterMode = filterMode
        };
        return textureAsset;
    }

    private Texture2D LoadTexture(string path, string name) {
        Texture2D tex = null;
        byte[] fileData;
        string filePath = path+"/"+name; 
        if (File.Exists(filePath))
        {
            fileData = File.ReadAllBytes(filePath);
            tex = new Texture2D(resolution, 1);
            tex.LoadImage(fileData);
        }
        return tex;
    }

    private void BakeGradient(Gradient gradient, Texture2D texture) {
        if (gradient == null) {
            return;
        }

        for (int x = 0; x < texture.width; x++) {
            var color = gradient.Evaluate((float)x / (texture.width - 1));
            for (int y = 0; y < texture.height; y++) {
                texture.SetPixel(x, y, color);
            }
        }
        texture.Apply();
    }

    public static void SaveTextureAsPNG(Texture2D _texture, string _dirPath, string fileName)
    {
        byte[] _bytes =_texture.EncodeToPNG();
        if(!Directory.Exists(_dirPath)) {
            Directory.CreateDirectory(_dirPath);
        }
        File.WriteAllBytes(_dirPath + "/" + fileName + ".png", _bytes);
        Debug.Log(_bytes.Length/1024  + "Kb was saved as: " + _dirPath + "/" + fileName);
        AssetDatabase.Refresh();
    }
}
