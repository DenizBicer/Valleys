Shader "Perlin/Update"
{
    Properties
    { 
         _Factor("Factor",float) = 0.05
         _Speed("Speed", float) = 0.5
    }

    CGINCLUDE

    #include "UnityCustomRenderTexture.cginc"
    //#include "ClassicNoise2D.cginc"
    #include "Simplex4D.cginc"
    #define M_PI 3.1415926535897932384626433832795
    float _Factor, _Speed;

    half4 frag(v2f_customrendertexture i) : SV_Target
    {
        float2 uv = i.globalTexcoord * _Factor;
         half t = _Time.x * _Speed;
        half value = snoise(float4(uv.x, uv.y, cos(4.0 * M_PI *t), sin(4.0 * M_PI *t)));

        return half4(value, value, 0, 0);
    }

    ENDCG


    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        Pass
        {
            Name "Update"
            CGPROGRAM
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            ENDCG
        }
    }
}
