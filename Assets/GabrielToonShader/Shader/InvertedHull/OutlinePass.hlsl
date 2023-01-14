#ifndef OUTLINEPASS_INCLUDED
#define OUTLINEPASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

struct Attributes{
    float4 positionOS: POSITION;
    float3 normalOS: NORMAL;
    half4 vertexColor : COLOR;
    half4 uv : TEXCOORD0;
};

struct VertexOutput{
    float4  positionCS: SV_POSITION;
    float4  uv: TEXCOORD0;
    float2 offset: TEXCOORD1;
};

float4 _OutlineColor;
float _OutlineSize;
float _DepthOffset;
float _EnableCameraDistanceMult;
sampler2D _BaseColor;
float4 _BaseColor_ST;
float _TextureColorMult;
float _DistortionFactor;


inline float3 ObjSpaceViewDir( in float4 v )
{
    float3 objSpaceCameraPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos.xyz, 1)).xyz;
    return objSpaceCameraPos - v.xyz;
}

float3 DistortionVertex(float3 vertexPos, float distortionFactor)
{
    float3 output;
    float3 cameraDir = (-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz));
    float3 vertexDir = TransformObjectToWorldDir(vertexPos);
    float vertexLenght = length(vertexPos);
    float3 offsetDir = vertexDir * vertexLenght;
    float3 projection = cameraDir * dot(offsetDir, cameraDir) / dot(cameraDir, cameraDir);
    float factor = lerp(0, 1, distortionFactor);
    float3 result = offsetDir - (projection * factor);
    return output = TransformWorldToObjectDir(GetCameraRelativePositionWS(result)) * length(result);
}

VertexOutput Vertex(Attributes input){    

    VertexOutput output = (VertexOutput)0;
    input.positionOS.xyz = DistortionVertex(input.positionOS.xyz, _DistortionFactor);    
    float3 objWS = TransformObjectToWorld(input.positionOS.xyz);
    float eyeDepth = -TransformWorldToView(input.positionOS.xyz).z;  
    float3 outlineMult = (( input.normalOS * 2E-05 ) * (( _EnableCameraDistanceMult * eyeDepth * input.vertexColor.g)));
    float3 dirCamera = ObjSpaceViewDir( float4( outlineMult , 0.0 )); 
    float4 distCamera = normalize( ( float4( dirCamera , 0.0 ) - input.positionOS ));
    float rampDepth = clamp( ( input.vertexColor.b + _DepthOffset ) , 0.0 , 1.0 );
    float4 finalPos = lerp( float4(outlineMult , 0.0 ) , -distCamera , ( 1.0 - rampDepth ));
    finalPos += float4(input.positionOS.xyz,0);
    float4 clipPosition = TransformObjectToHClip(finalPos);
    float3 clipNormal = mul((float3x3) UNITY_MATRIX_VP, mul((float3x3) UNITY_MATRIX_M, input.normalOS));
    float2 offset = (normalize(clipNormal.xy) * (_OutlineSize/100) * clipPosition.w) * (input.vertexColor * 2) ;
    float aspect = _ScreenParams.x / _ScreenParams.y;
    offset.y *= aspect;
    clipPosition.xy += offset;
    output.positionCS = clipPosition;
    output.uv = input.uv;
    return output;
}

float4 Fragment(VertexOutput input): SV_TARGET{
    float4 baseColor = tex2D(_BaseColor, input.uv.xy);
    return (_TextureColorMult > 0? baseColor  * _OutlineColor: _OutlineColor);
}
#endif

