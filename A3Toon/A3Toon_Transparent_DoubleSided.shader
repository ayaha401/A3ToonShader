Shader "A3Toon/Transparent_DoubleSided"
{
    Properties
    {
        // MainColor
        _MainTex("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        [Toggle] _UseVertCol("Use Vertex Color", int) = 0
        _AlphaMask("Alpha Mask", 2D) = "white" {}

        // Normal
        _BumpMap("Normal Map", 2D) = "bump" {}
        _BumpScale ("Normal Scale", Range(0.0, 1.0)) = 1.0

        // Shading
        _ShadeMask("Shade Mask", 2D) = "black" {}
        _ShadeColor("Shade Color", Color) = (0.0, 0.0, 0.0, 1.0)
        _ShadeBorder("Shade Border", Range(-1.0, 1.0)) = 0.0
        _ShadeBorderWidth("Shade Border Width", Range(0.0, 1.0)) = 0.5
        _Brightness("Brightness", Range(0.0, 1.0)) = 0.0

        // Rimlight
        [Toggle] _UseRim("Use Rimlight", int) = 0
        _RimMask("Rimlight Mask", 2D) = "white" {}
        _RimColor("Rimlight Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _RimPower("Rimlight Power", Range(0.0, 100.0)) = 1.0
        _RimWidth("Rimlight Width", Range(0.0, 1.0)) = 0.1
        [Toggle] _IgnoreAlphaRimlight("Ignore Alpha Rimlight", int) = 0
        
        // Reflection
        [Toggle] _UseReflect("Use Reflection", int) = 0
        _ReflectMask("Reflect Mask", 2D) = "white" {}
        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5
        _SpecularPower("Specular Power", Range(0.0, 1.0)) = 0.5
        _MatCapTex("MatCap Texture", 2D) = "black" {}
        [Toggle] _IgnoreAlphaReflection("Ignore Alpha Reflection", int) = 0

        // Outline
        [Toggle] _UseOutline("Use Outline", int) = 0
        _OutlineMask("Outline Mask Texture", 2D) = "white" {}
        _OutlineWidth("Outline Width", Range(0.0, 1.0)) = 0.5
        _OutlineColor("Outline Color", Color) = (0.0, 0.0, 0.0, 1.0)
        [Toggle] _UseLightColor("Use Light Color", int) = 0

        // OtherSetting
        [Enum(Off,0 ,Front,1, Back,2)] _CullingMode("Culling", int) = 0
        [Toggle] _EnableZWrite("ZWrite", int) = 1
        _MinBrightness("Min Brightness", Range(0.0, 1.0)) = 0.5
        [Toggle] _PointLightLimit("PointLight Limit", int) = 1
    }
    SubShader
    {
        Tags 
        {
            "IgnoreProjector" = "False"
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        LOD 0

        Pass
        {
            Name "ForwardBaseFront"
            Tags
            {
                "LightMode" = "ForwardBase"
            }

            Cull Front
            ZWrite ON
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma only_renderers d3d11 metal	
            #pragma target 4.5
            #pragma enable_d3d11_debug_symbols

            #define FB
            #define TRANSPARENT
            #include "../A3Toon/hlsl/A3Toon_Core.hlsl"
            
            ENDHLSL
        }

        Pass
        {
            Name "Outline"
            Tags
            {
                "LightMode" = "ForwardBase"
            }

            Cull Front
            ZWrite On
            Blend SrcAlpha OneMinusSrcAlpha
            ZTest Less

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma only_renderers d3d11 metal	
            #pragma target 4.5
            #pragma enable_d3d11_debug_symbols

            #define OL
            #define TRANSPARENT

            #include "../A3Toon/hlsl/A3Toon_Outline.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "ForwardBaseBack"
            Tags
            {
                "LightMode" = "ForwardBase"
            }

            Cull Back
            ZWrite ON
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma only_renderers d3d11 metal	
            #pragma target 4.5
            #pragma enable_d3d11_debug_symbols

            #define FB
            #define TRANSPARENT
            #define BACK
            #include "../A3Toon/hlsl/A3Toon_Core.hlsl"
            
            ENDHLSL
        }

        Pass
        {
            Name "ForwardAdd"
            Tags
            {
                "LightMode" = "ForwardAdd"
            }

            Cull [_CullingMode]

            Blend SrcAlpha One
            ZWrite Off

            HLSLPROGRAM
            #pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdadd
			#pragma multi_compile_fog
            #pragma only_renderers d3d11 metal	
            #pragma target 4.5
            #pragma enable_d3d11_debug_symbols

            #define FA
            #define TRANSPARENT

            #include "../A3Toon/hlsl/A3Toon_Core.hlsl"
            
            ENDHLSL
        }

        pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            Cull Off
            ZWrite On
            ZTest LEqual

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #pragma only_renderers d3d11 metal
            #pragma target 4.5
            #pragma enable_d3d11_debug_symbols

            #define SC
            #define TRANSPARENT
            #include "../A3Toon/hlsl/A3Toon_ShadowCaster.hlsl"

            ENDHLSL
        }
    }
}
