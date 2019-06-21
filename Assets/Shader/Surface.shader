Shader "Hidden/Rcam/Sureface"
{
    CGINCLUDE

    #include "UnityCG.cginc"

    // Hash function from H. Schechter & R. Bridson, goo.gl/RXiKaH
    uint Hash(uint s)
    {
        s ^= 2747636419u;
        s *= 2654435769u;
        s ^= s >> 16;
        s *= 2654435769u;
        s ^= s >> 16;
        s *= 2654435769u;
        return s;
    }

    float Random(uint seed)
    {
        return float(Hash(seed)) / 4294967295.0; // 2^32-1
    }

#if 0

    float effect(float3 wpos, float time)
    {
        return frac(wpos.y * 20 + time) < 0.5;
    }

#elif 0

    float effect(float3 wpos, float time)
    {
        float g = wpos.y * 400;
        float fw = fwidth(g);
        g = saturate(1 - abs(0.5 - frac(g) * 0.5 / fw) * 2);
        return lerp(g, 0.5, smoothstep(0.4, 0.7, fw));
    }

#elif 0

    #include "SimplexNoise2D.hlsl"

    float effect(float3 wpos, float time)
    {
        float g = snoise(float2(wpos.y * 29 - time * 1, time));
        g += snoise(float2(wpos.y * 12 - time * 0.4, time * 0.7));
        return abs(g) < 0.3;
    }

#else

    float effect(float3 wpos, float time)
    {
        wpos.z -= 3;

        float phi = atan2(wpos.z, wpos.x);
        uint seed = (wpos.y * 60 + 1000) * 2;

        float w = lerp(0.02, 2, Random(seed));
        float s = lerp(0.5, 3, Random(seed + 1));

        float g = frac(phi * w + time * s);
        return g < 0.5;
    }

#endif

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

        texCoord = float4(u, v, p.z, c.a);
        worldPos = mul(_LocalToWorld, float4(p.xyz, 1)).xyz;
        clipPos = UnityObjectToClipPos(float4(worldPos, 1));
    }

    float4 Fragment(
        float4 texCoord : TEXCOORD1,
        float3 worldPos : TEXCOORD2,
        float4 position : SV_Position
    ) : SV_Target
    {
        const float alpha_range = 0.00004;

        float3 c = tex2D(_MainTex, texCoord.xy).rgb;
        float a = saturate((texCoord.w - 1 + alpha_range) / alpha_range);

        float g = effect(worldPos, _Time.y);
        g *= 1 - smoothstep(1, 2, texCoord.z);

        c = lerp(0.3, 1, Luminance(c)) * g;

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
