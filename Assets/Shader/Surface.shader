Shader "Hidden/Rcam/Sureface"
{
    CGINCLUDE

    #include "UnityCG.cginc"

    sampler2D _MainTex;
    sampler2D _PositionMap;
    uint _XCount, _YCount;

    float _Intensity;

    float4x4 _LocalToWorld;

    void Vertex(
        uint vid : SV_VertexID,
        out float4 texCoord : TEXCOORD1,
        out float3 worldPos : TEXCOORD2,
        out float4 clipPos : SV_Position
    )
    {
        uint pi = vid % 6;  // point index
        uint ti = vid / 6;  // triangle index
        uint xi = ti % (_XCount - 1); // X index
        uint yi = ti / (_XCount - 1); // Y index

        // UV coordinate
        float u = (float)(xi + (pi + 3) / 4 - (pi > 2)) / (_XCount - 1);
        float v = (float)(yi + pi % 2                 ) / (_YCount - 1);

        // Samples from maps
        float4 p = tex2Dlod(_PositionMap, float4(u, v, 0, 0));
        float4 c = tex2Dlod(_MainTex,     float4(u, v, 0, 0));

        texCoord = float4(u, v, p.z, c.a > 0.999999);
        worldPos = mul(_LocalToWorld, float4(p.xyz, 1)).xyz;
        clipPos = UnityObjectToClipPos(float4(worldPos, 1));
    }

    float4 Fragment(
        float4 texCoord : TEXCOORD1,
        float3 worldPos : TEXCOORD2,
        float4 position : SV_Position
    ) : SV_Target
    {
        float3 c = tex2D(_MainTex, texCoord.xy).rgb;
        float a = texCoord.w > 0.999999;

        float g = worldPos.y * 400;
        float fw = fwidth(g);

        g = saturate(1 - abs(0.5 - frac(g) * 0.5 / fw) * 2);
        g = lerp(g, 0.5, smoothstep(0.4, 0.7, fw));
        g *= 1 - smoothstep(1, 2, texCoord.z);

        c = lerp(0.4, 1, Luminance(c)) * g;

        return float4(c, a * _Intensity);
    }

    ENDCG

    SubShader
    {
        Pass
        {
            Blend SrcAlpha One
            ZWrite Off Cull Off
            CGPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            ENDCG
        }
    }
}
