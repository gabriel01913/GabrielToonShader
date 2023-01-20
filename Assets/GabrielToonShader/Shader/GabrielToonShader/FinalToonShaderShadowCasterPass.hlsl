#ifndef FINALTOON_SHADOWCASTERPASS
#define FINALTOON_SHADOWCASTERPASS

struct appdata {
	float4 vertex : POSITION;
    float4 uv0 : TEXCOORD0;
    float2 uv1                : TEXCOORD1;
    float2 uv2                : TEXCOORD2;
    #if defined (_CUSTOM_UV)
    float2 uv3                : TEXCOORD3;
    float2 uv4                : TEXCOORD4;
    float2 uv5                : TEXCOORD5;
    float2 uv6                : TEXCOORD6;
    float2 uv7                : TEXCOORD7;
    #endif
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Interpolators {
	float4 clipPos : SV_POSITION;
    float4 uv0 : TEXCOORD0;
    float2 uv1                : TEXCOORD1;
    float2 uv2                : TEXCOORD2;
    #if defined (_CUSTOM_UV)
    float2 uv3                : TEXCOORD3;
    float2 uv4                : TEXCOORD4;
    float2 uv5                : TEXCOORD5;
    float2 uv6                : TEXCOORD6;
    float2 uv7                : TEXCOORD7;
    #endif
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

void AlphaClip(Interpolators output)
{
    float alphaClip = _AlphaClip;
    if(alphaClip)
    {
        half2 customUV = half2(0,0);
        float alphaClipChannel = _AlphaClipChannel;
        switch(alphaClipChannel)
        {
            case 0:
                half base = 0;                        
                #if defined(_CUSTOM_UV)
                float baseColorUV =  _BaseColorUV;
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
                float detailUV =  _DetailUV;
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
                float normalMapUV =  _NormalMapUV;
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
                float shadowColorUV =  _ShadowColorUV;
                customUV = CustomUV(shadowColorUV, output);
                shadow = tex2D(_ShadowColor, customUV.xy).a;
                #else
                shadow = tex2D(_ShadowColor, output.uv0.xy).a;
                #endif
                float4 shadowTint = _ShadowTint;
                float alphaClipThreshold =  _AlphaClipThreshold;
                clip(shadow * shadowTint.a - alphaClipThreshold);
            break;
        }        
    }
}

Interpolators vert (appdata i) {
	Interpolators output = (Interpolators)0;
	UNITY_SETUP_INSTANCE_ID(i);
	float4 worldPos = mul(UNITY_MATRIX_M, float4(i.vertex.xyz, 1.0));    
	output.clipPos = mul(unity_MatrixVP, worldPos);

    #if UNITY_REVERSED_Z
		output.clipPos.z =
			min(output.clipPos.z, output.clipPos.w * UNITY_NEAR_CLIP_VALUE);
	#else
		output.clipPos.z =
			max(output.clipPos.z, output.clipPos.w * UNITY_NEAR_CLIP_VALUE);
	#endif
    output.uv1 = i.uv1;
    output.uv2 = i.uv2;
    #if defined (_CUSTOM_UV)
    output.uv3 = i.uv3;
    output.uv4 = i.uv4;
    output.uv5 = i.uv5;
    output.uv6 = i.uv6;
    output.uv7 = i.uv7;
    #endif

	return output;
}

float4 frag (Interpolators output) : SV_TARGET {
    #ifdef _ALPHATEST_ON    
    AlphaClip(output);
    #endif
	return 0;
}

#endif