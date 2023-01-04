#ifndef AAA_FUNCTION
#define AAA_FUNCTION

// モノクロ変換
float ConvertMonochrome(float3 rgbCol)
{
    return dot(rgbCol, float3(0.299, 0.587, 0.114));
}

// オブジェクトの大きさを計算
float3 ObjectScale()
{
    float3 scale = float3(
                            length(float3(unity_ObjectToWorld[0].x , unity_ObjectToWorld[1].x , unity_ObjectToWorld[2].x)),
	                        length(float3(unity_ObjectToWorld[0].y , unity_ObjectToWorld[1].y , unity_ObjectToWorld[2].y)),
	                        length(float3(unity_ObjectToWorld[0].z , unity_ObjectToWorld[1].z , unity_ObjectToWorld[2].z))
                        );

    scale = COMPARE_EPS(scale);
    return scale;
}

// HSVのVをRGBから計算
float GetValueColor(float3 rgbCol)
{
    return max(rgbCol.r, max(rgbCol.g, rgbCol.b));
}

// RGBからVで明度を調整する。
float3 AdjustRGBWithV(float3 rgb, bool isBright, float v)
{
    return lerp(rgb, (float3)isBright, v);
}

// 法線を合成する
// https://docs.unity3d.com/Packages/com.unity.shadergraph@6.9/manual/Normal-Blend-Node.html
float3 Blend_RNM(float3 n1, float3 n2)
{
    float3 t = n1 + float3(0, 0, 1);
    float3 u = n2 * float3(-1, -1, 1);
    float3 r = normalize(t * dot(t, u) - u * t.z);
    return r;
}

// Rimlightを計算する
float CalcRimlight(float3 V, float3 N, float width, float intensity)
{
    float rim = pow(saturate(1. - dot(V, N) + width), intensity);
    rim = saturate(rim);
    return rim;
}

// Specularを計算する
float CalcSpecular(float3 HV, float3 N, float smoothness)
{
    float spec = pow(saturate(dot(HV, N)), smoothness);
    spec = saturate(spec);
    return spec;
}

// MatCapを計算する
float3 CalcMatCap(sampler2D tex, float2 uv)
{
    float3 matCap = tex2D(tex, uv);
    return matCap;
}

#endif