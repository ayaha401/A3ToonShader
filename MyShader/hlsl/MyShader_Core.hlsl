#ifndef MY_CORE
#define MY_CORE

#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "Lighting.cginc"
#include "../hlsl/MyShader_Macro.hlsl"
#include "../hlsl/MyShader_Function.hlsl"

// Sampler
SamplerState mainTex_linear_clamp_sampler;

// MainColor
Texture2D _MainTex; uniform float4 _MainTex_ST;
uniform float4 _Color;
uniform int _UseVertCol;
#if defined(TRANSPARENT) || defined(CUTOUT)
    Texture2D _AlphaMask; uniform float4 _AlphaMask_ST;
#endif

#ifdef CUTOUT
    uniform float _Cutout;
#endif

// Normal
uniform sampler2D _BumpMap; uniform float4 _BumpMap_ST;
uniform float _BumpScale;

// Shade
Texture2D _ShadeMask;
uniform float4 _ShadeColor;
uniform float _ShadeBorder;
uniform float _ShadeBorderWidth;
uniform float _Brightness;

// Rimlight
uniform int _UseRim;
Texture2D _RimMask;
uniform float3 _RimColor;
uniform float _RimPower;
uniform float _RimWidth;
#if defined(TRANSPARENT)
    uniform int _IgnoreAlphaRimlight;
#endif

// Reflection
uniform int _UseReflect;
Texture2D _ReflectMask;
uniform float _Smoothness;
uniform float _SpecularPower;
uniform sampler2D _MatCapTex;
#if defined(TRANSPARENT)
    uniform int _IgnoreAlphaReflection;
#endif

// OtherSetting
#ifdef FB
    uniform float _MinBrightness;
#endif
#ifdef FA
    uniform bool _PointLightLimit;
#endif

// メッシュデータが持つ情報
struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
    float2 uv1 : TEXCOORD0;
    float4 color : COLOR;

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 posWS : TEXCOORD1;
    float4 lightDirWS : TEXCOORD2;      // w : isLight
    float3 lightCol : TEXCOORD3;
    float3 tspace0 : TEXCOORD4;
    float3 tspace1 : TEXCOORD5;
    float3 tspace2 : TEXCOORD6;
    #ifdef FA
        UNITY_LIGHTING_COORDS(7, 8)
    #endif
    float3 sh : TEXCOORD9;

    float3 normal : NORMAL;
    float4 color : COLOR;
    
    UNITY_FOG_COORDS(10)


    UNITY_VERTEX_OUTPUT_STEREO
};

#include "../hlsl/MyShader_Vert.hlsl"
#include "../hlsl/MyShader_Frag.hlsl"

#endif