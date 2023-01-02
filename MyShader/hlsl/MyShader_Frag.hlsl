#ifndef MY_FRAG
#define MY_FRAG

float4 frag (v2f i) : SV_Target
{
    // CameraPos
    float3 cameraPosWS = -UNITY_MATRIX_I_V._m03_m13_m23;

    // View
    float3 cameraViewWS = normalize(-cameraPosWS-i.posWS);
    float3 cameraViewCS = mul((float3x3)UNITY_MATRIX_V, cameraViewWS);

    // Normal
    float3 tangentNormal = UnpackNormalWithScale(tex2D(_BumpMap, i.uv), _BumpScale);
    float3 normalWS;
    normalWS.x = dot(i.tspace0, tangentNormal);
    normalWS.y = dot(i.tspace1, tangentNormal);
    normalWS.z = dot(i.tspace2, tangentNormal);
    normalWS = normalize(normalWS);

    float3 normalCS = mul((float3x3)UNITY_MATRIX_V, normalWS);


    // Light
    float3 lightDir = i.lightDirWS;
    float3 lightCol = i.lightCol;
    float isLight = i.lightDirWS.w;
    float3 shCol = i.sh;

    // Diff
    float NdotL = dot(normalWS, lightDir);
    float halfLambert = NdotL*.5+.5;

    float diff = halfLambert;
    diff += _ShadeBorder*.5;
    diff = clamp(((diff-.5)/COMPARE_EPS(_ShadeBorderWidth))+.5+(_Brightness*.5),_Brightness,1.);
    float shadeMask=_ShadeMask.Sample(mainTex_linear_clamp_sampler, i.uv);
    diff=max(shadeMask, diff);

    float3 albedo = _MainTex.Sample(mainTex_linear_clamp_sampler, i.uv)*_Color.rgb;
    float3 shade = _ShadeColor;
    float3 diffCol = lerp(shade, albedo, diff);
    
    float4 col = float4(0., 0., 0., 1.);
    col.rgb = diffCol;
    #if defined(TRANSPARENT) || defined(CUTOUT)
        col.a = _MainTex.Sample(mainTex_linear_clamp_sampler, i.uv).a*_Color.a;
        col.a *= _AlphaMask.Sample(mainTex_linear_clamp_sampler, i.uv).r;
    #endif

    // Cutout
    #ifdef CUTOUT
        clip(col.a - _Cutout);
    #endif

    // Light
    float3 lighting = 0.;
    float3 lightPower = 0.;

    #ifdef FB
        // DL
        lighting = lightCol;
        col.rgb *= lighting;
        
        // IL
        col.rgb += shCol * albedo;
        col.rgb = min(col.rgb, albedo);
    #endif

    #ifdef FA
        //PL
        UNITY_LIGHT_ATTENUATION(atten, i, i.posWS);
        float a = (max(diff*2.-1.,0.)) * atten * max(NdotL,0);
        lighting = a*lightCol;
        lighting = lerp(lighting, a*saturate(lightCol), _PointLightLimit);
        
        col.rgb *= lighting;
    #endif

    // Rimlight
    float3 rimlight = (float3)0.;
    float rim=0.;
    if(_UseRim)
    {
        float rimMask = _RimMask.Sample(mainTex_linear_clamp_sampler, i.uv).r;
        rim=CalcRimlight(cameraViewWS, normalWS, _RimWidth, _RimPower);
        rim*=rimMask;
        rimlight=(float3)rim*_RimColor;
        
        #ifdef FA
            rimlight*=lighting;
        #endif
    }

    // Reflection
    float3 specular=0.;
    float spec=0.;
    float3 materialCapture=0.;
    if(_UseReflect)
    {
        float reflectMask = _ReflectMask.Sample(mainTex_linear_clamp_sampler, i.uv).r;
        float smoothness=max(_Smoothness, .05)*100.;
        float specularInt=_SpecularPower;

        // Specular
        float3 hv=normalize(lightDir+cameraViewWS);
        spec=CalcSpecular(hv, normalWS, smoothness);
        spec*=reflectMask;
        specular=(float3)spec;
        specular*=specularInt;

        #ifdef FA
            specular*=lighting;
        #endif

        // Material Capture
        float3 matCapViewCS = cameraViewCS*float3(-1,-1,1);
        float2 matCapUV = Blend_RNM(matCapViewCS, normalCS).xy*.5+.5;
        materialCapture=CalcMatCap(_MatCapTex, matCapUV);
        materialCapture*=reflectMask;
        
        #ifdef FA
            materialCapture*=lighting;
        #endif
    }









    float4 lastCol = float4(0.,0.,0.,1.);
    lastCol.rgb = col.rgb;
    lastCol.rgb += rimlight;
    lastCol.rgb += specular;
    lastCol.rgb += materialCapture;

    #if defined(TRANSPARENT)
        lastCol.a = col.a;

        // Ignore Alpha
        lastCol.a = saturate(lastCol.a + ConvertMonochrome(rimlight)*_IgnoreAlphaRimlight);
        lastCol.a = saturate(lastCol.a + ConvertMonochrome(materialCapture)*_IgnoreAlphaReflection);
    #endif





    // float4 testCol;
    // testCol = float4(cameraViewCS/* *float3(-1,-1,1) */,1.);
    // testCol = float4((float3)rimlight,1.);
    // return testCol*.5+.5;

    // Fog
    UNITY_APPLY_FOG(IN.fogCoord, lastCol);

    
    return lastCol;
}

#endif