#ifndef FINALTOON_METAPASS
#define FINALTOON_METAPASS
struct appdata
{
    float4 vertex : POSITION;
    float4 uv0: TEXCOORD0;
	float2 lightmap : TEXCOORD1;
     #if defined (_CUSTOM_UV)
    float2 uv4                : TEXCOORD4;
    float2 uv5                : TEXCOORD5;
    float2 uv6                : TEXCOORD6;
    float2 uv7                : TEXCOORD7;
    float2 uv01                : TEXCOORD8;
    float2 uv02                : TEXCOORD9;
    #endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Interpolators
{
    float4 vertex : SV_POSITION;
    float4 uv0: TEXCOORD0;
    #if defined (_CUSTOM_UV)
    float2 uv4                : TEXCOORD4;
    float2 uv5                : TEXCOORD5;
    float2 uv6                : TEXCOORD6;
    float2 uv7                : TEXCOORD7;
    float2 uv01                : TEXCOORD8;
    float2 uv02                : TEXCOORD9;
    #endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
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
            uv = output.uv01.xy;
        break;
        case 2:
            uv = output.uv02.xy;
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

struct CustomFragmentOutput {
		float4 color : SV_Target;
};

Interpolators vert (appdata v)
{
    Interpolators o;
    UNITY_SETUP_INSTANCE_ID(v);
	v.vertex.xy = v.lightmap * unity_LightmapST.xy + unity_LightmapST.zw;
	v.vertex.z = v.vertex.z > 0 ? 0.0001 : 0;
    o.vertex = TransformObjectToHClip(v.vertex);
    o.uv0 = v.uv0;
    return o;
}

CustomFragmentOutput frag (Interpolators i)
{
    CustomFragmentOutput output = (CustomFragmentOutput)0;
    #ifdef _ALPHATEST_ON    
    AlphaClip(output);
    #endif
    UNITY_SETUP_INSTANCE_ID(i);
    float4 color = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _BaseTint);
    #ifdef _CUSTOM_UV
    float baseColorUV = UNITY_ACCESS_INSTANCED_PROP(MaterialPropertyMetadata, _BaseColorUV);
    float2 customUV = CustomUV(baseColorUV, output);
    half3 textMap = tex2D(_BaseColor, customUV.xy).xyz * color.xyz;
    #else
    half3 textMap = tex2D(_BaseColor, i.uv0.xy).xyz * color.xyz;
    #endif
    output.color = float4(textMap.xyz,0);
    return output;
}
#endif