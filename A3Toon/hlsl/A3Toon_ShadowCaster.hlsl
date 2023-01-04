#ifndef AAA_SHADOWCASTER
#define AAA_SHADOWCASTER

#include "UnityCG.cginc"
#include "../hlsl/A3Toon_Macro.hlsl"
#include "../hlsl/A3Toon_Function.hlsl"

// Sampler
SamplerState mainTex_linear_clamp_sampler;

// MainColor
Texture2D _MainTex; uniform float4 _MainTex_ST;
uniform float4 _Color;
#ifdef CUTOUT
    uniform float _Cutout;
#endif

// OtherSetting
uniform uint _CullingMode; 

struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
    float2 uv : TEXCOORD0;
    V2F_SHADOW_CASTER;

    UNITY_VERTEX_OUTPUT_STEREO
};

v2f vert(appdata v)
{
    v2f o;

    UNITY_INITIALIZE_OUTPUT(v2f, o);
	UNITY_SETUP_INSTANCE_ID(v);
	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    o.uv = v.uv;
    TRANSFER_SHADOW_CASTER(o)
    return o;
}

float4 frag(v2f i, bool face : SV_IsFrontFace) : SV_TARGET
{
    float frontFace = (float)face;

    float4 col = (float4)1.;

    #if defined(TRANSPARENT) || defined(CUTOUT)
        col.a = _MainTex.Sample(mainTex_linear_clamp_sampler, i.uv).a;
    #endif

    float alpha = col.a * _Color.a;
    if(_CullingMode == 2) alpha *= saturate(frontFace);
    if(_CullingMode == 1) alpha *= saturate((1. - frontFace));


    #ifdef CUTOUT
        alpha -= _Cutout;
    #endif

    clip(alpha - AAA_EPS);

    SHADOW_CASTER_FRAGMENT(i)

    return col;
}

#endif