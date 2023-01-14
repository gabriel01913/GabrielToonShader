#ifndef TONEMAPING_FEATURE
#define TONEMAPING_FEATURE

struct DataInputs{
    float p; //Maximum brightness
    float a; //contrast
    float m; //linear section start
    float l; //lienar section lenght
    float c; //black tightness
    float b; //black
    float e;
};

float3 LinearLenght(float3 x, DataInputs i )
{
    half3 result = i.m + i.a *( x - i.m );
    return result;
}
float3 Toe(float3 x, DataInputs i)
{
    half3 result = i.m * (pow( ( x / i.m ) , i.c)) + i.b;
    return result;   
}
float3 Shoulder(float x, float l0, DataInputs i)
{
    float s0 = i.m - l0;
    float s1 = i.m + i.a * l0;
    float c2 = i.a * i.p / (i.p - s1);
    float exponential = -((c2 * (x - s0)) / i.p);
    half3 result = i.p - (i.p - s1)* pow(i.e, exponential);    
    return result;
}    

float3 GranTurismoToneMapping(float3 x, DataInputs i)
{
    float l0 = ((i.p - i.m) * i.l) / i.a;
    float L0 = i.m - (i.m / i.a);
    float L1 = i.m + (1 - i.m / i.a);

    float w0 = 1 - smoothstep( x, 0, i.m);
    float w2 = smoothstep(x, i.m + l0, i.m + l0);
    float w1 = 1 -  w0 - w2 ;
    float3 result = Toe(x, i) * w0 + LinearLenght(x, i) * w1 + Shoulder(x, l0, i) * w2;
    return result;
}

void Main_float(float4 Color, float P, float A, float M, float L, float C, float B, float E,out float4 Ouput){

    DataInputs i = (DataInputs)0;
    i.p = P;
    i.a = A;
    i.m = M;
    i.l = L;
    i.c = C;
    i.b = B;
    i.e = E;

    Ouput = float4(GranTurismoToneMapping(Color.xyz, i).rgb, Color.a);
}


#endif