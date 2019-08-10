Shader "Custom/StripedVertexModifier" {
	Properties {
		_Tess ("Tessellation", Range(1,32)) = 4
		 [HideInInspector]_MainTex ("Base (RGB)", 2D) = "white" {}
		_ModTex ("Vertex Modify", 2D) = "white" {}
		_ModAmount ("Modulation Amount", float) = 1.0
		_Horizontal("Horizontal stripe", float) = 1.0
		_Vertical("Verical stripe", float) = 1.0
		_Isoline("Isoline", float) = 1.0
		_Freq("Frequency", float) = 1.0
		_Thickness("Thickness", float) = 1.0

		[Space]
        _Color0("Color 0", Color) = (1,1,1,1)
        _Color1("Color 1", Color) = (1,1,1,1)
	
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		
		CGPROGRAM
		#pragma surface surf Lambert vertex:vert  tessellate:tessDistance
		#pragma target 4.6
		#pragma glsl
		#include "Tessellation.cginc"

   		struct appdata {
            float4 vertex : POSITION;
            float4 tangent : TANGENT;
            float3 normal : NORMAL;
            float2 texcoord : TEXCOORD0;
        };
		
        float _Tess;
        float4 tessDistance (appdata v0, appdata v1, appdata v2) {
            float minDist = 10.0;
            float maxDist = 25.0;
            return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, _Tess);
        }

		sampler2D _MainTex;
		sampler2D _ModTex;
		float _ModAmount;
		float _Horizontal, _Vertical, _Isoline, _Freq, _Thickness;
		fixed4 _Color0, _Color1;

		struct Input {
			float2 uv_MainTex;
			float3 worldPos;
			float4 screenPos;
		};
		
		void vert(inout appdata v) {
			float4 tex = tex2Dlod(_ModTex, float4(v.texcoord.xy, 0, 0)) * 4.0;

				float3 d = float3(1, -1, 0.0);
				tex += tex2Dlod(_ModTex, float4(v.texcoord.xy - d.xx,0,0)) * 1.0; // -1,-1
				tex += tex2Dlod(_ModTex, float4(v.texcoord.xy - d.zx,0,0)) * 2.0; // 0, -1
				tex += tex2Dlod(_ModTex, float4(v.texcoord.xy - d.yx,0,0)) * 1.0; // +1, -1
				tex += tex2Dlod(_ModTex, float4(v.texcoord.xy - d.xz,0,0)) * 2.0; // -1, 0
				tex += tex2Dlod(_ModTex, float4(v.texcoord.xy + d.xz,0,0)) * 2.0; // +1, 0
				tex += tex2Dlod(_ModTex, float4(v.texcoord.xy + d.yx,0,0)) * 1.0; // -1, +1
				tex += tex2Dlod(_ModTex, float4(v.texcoord.xy + d.zx,0,0)) * 2.0; // 0, +1
				tex += tex2Dlod(_ModTex, float4(v.texcoord.xy + d.xx,0,0)) * 1.0; // +1, +1
		
				tex /=  16.0;
				

			v.vertex.y -= tex.y * _ModAmount;
		}
		
		void surf (Input IN, inout SurfaceOutput o) {
			float dis = distance(IN.uv_MainTex, float2(0.5,0.5)) * 10.0;

            half stripe = step(0.25 *_Thickness, (IN.uv_MainTex.y * 400.0 * _Freq )%2.0)* _Horizontal;
			stripe += step(0.25 * _Thickness, (IN.uv_MainTex.x * 400.0 *_Freq)%2.0)		* _Vertical;
			stripe += step(0.25 * _Thickness , (abs(IN.worldPos.y) * 400.0 *_Freq )%2.0)*_Isoline;

            half4 c = stripe * _Color1 + (1.0 -stripe) * _Color0;

			o.Albedo = c.rgb;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}