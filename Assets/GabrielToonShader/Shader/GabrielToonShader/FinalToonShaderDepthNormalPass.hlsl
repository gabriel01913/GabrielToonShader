#ifndef FINALTOON_DEPTHNORMALPASS
#define FINALTOON_DEPTHNORMALPASS

struct Attributes
{
    float4 positionOS     : POSITION;
    float4 tangentOS      : TANGENT;
    float2 texcoord     : TEXCOORD0;
    float3 normal       : NORMAL;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS   : SV_POSITION;
    float2 uv           : TEXCOORD1;
    float3 normalWS                 : TEXCOORD2;

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
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

Varyings vert(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.uv         = TRANSFORM_TEX(input.texcoord, _BaseColor);
    output.positionCS = TransformObjectToHClip(input.positionOS.xyz);

    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal, input.tangentOS);
    output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);

    return output;
}

half4 frag(Varyings input) : SV_TARGET
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    #ifdef _ALPHATEST_ON    
    AlphaClip(output);
    #endif

    #if defined(_GBUFFER_NORMALS_OCT)
    float3 normalWS = normalize(input.normalWS);
    float2 octNormalWS = PackNormalOctQuadEncode(normalWS);           // values between [-1, +1], must use fp32 on some platforms.
    float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);   // values between [ 0,  1]
    half3 packedNormalWS = PackFloat2To888(remappedOctNormalWS);      // values between [ 0,  1]
    return half4(packedNormalWS, 0.0);
    #else
    float3 normalWS = NormalizeNormalPerPixel(input.normalWS);
    return half4(normalWS, 0.0);
    #endif
}
#endif