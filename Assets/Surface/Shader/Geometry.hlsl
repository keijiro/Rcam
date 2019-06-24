uint _XCount, _YCount;
sampler2D _PositionMap;
float4x4 _LocalToWorld;

PackedVaryingsType VertexOutput
    (float3 position, float3 normal, float3 tangent, float2 uv)
{
    AttributesMesh am;

    am.positionOS = position;
#ifdef ATTRIBUTES_NEED_NORMAL
    am.normalOS = normal;
#endif
#ifdef ATTRIBUTES_NEED_TANGENT
    am.tangentOS = float4(tangent, 1);
#endif
#ifdef ATTRIBUTES_NEED_TEXCOORD0
    am.uv0 = uv;
#endif
#ifdef ATTRIBUTES_NEED_TEXCOORD1
    am.uv1 = 0;
#endif
#ifdef ATTRIBUTES_NEED_TEXCOORD2
    am.uv2 = 0;
#endif
#ifdef ATTRIBUTES_NEED_TEXCOORD3
    am.uv3 = 0;
#endif
#ifdef ATTRIBUTES_NEED_COLOR
    am.color = 0;
#endif

    UNITY_TRANSFER_INSTANCE_ID(input, am);

    return Vert(am);
}

[maxvertexcount(6)]
void Geometry(
    uint pid : SV_PrimitiveID,
    point Attributes input[1],
    inout TriangleStream<PackedVaryingsType> outStream
)
{
    float u = (pid % _XCount + 0.5) / _XCount;
    float v = (pid / _XCount + 0.5) / _YCount;

    float du = 0.5 / _XCount;
    float dv = 0.5 / _YCount;

    float2 uv0 = float2(u - du, v - dv);
    float2 uv1 = float2(u + du, v - dv);
    float2 uv2 = float2(u - du, v + dv);
    float2 uv3 = float2(u + du, v + dv);

    float4 s0 = tex2Dlod(_PositionMap, float4(uv0, 0, 0));
    float4 s1 = tex2Dlod(_PositionMap, float4(uv1, 0, 0));
    float4 s2 = tex2Dlod(_PositionMap, float4(uv2, 0, 0));
    float4 s3 = tex2Dlod(_PositionMap, float4(uv3, 0, 0));

    float3 p0 = mul(_LocalToWorld, float4(s0.xyz, 1)).xyz;
    float3 p1 = mul(_LocalToWorld, float4(s1.xyz, 1)).xyz;
    float3 p2 = mul(_LocalToWorld, float4(s2.xyz, 1)).xyz;
    float3 p3 = mul(_LocalToWorld, float4(s3.xyz, 1)).xyz;

    float4 mask = float4(s0.w, s1.w, s2.w, s3.w);

    float3 n1 = normalize(cross(p1 - p0, p2 - p0));
    float3 n2 = normalize(cross(p1 - p3, p1 - p2));

    float3 t1 = normalize(cross(n1, float3(0, 0, 1)));
    float3 t2 = normalize(cross(n2, float3(0, 0, 1)));

    if (all(mask.xyz > 0.9))
    {
        outStream.Append(VertexOutput(p0, n1, t1, uv0));
        outStream.Append(VertexOutput(p1, n1, t1, uv1));
        outStream.Append(VertexOutput(p2, n1, t1, uv2));
        outStream.RestartStrip();
    }

    if (all(mask.yzw > 0.9))
    {
        outStream.Append(VertexOutput(p1, n2, t2, uv1));
        outStream.Append(VertexOutput(p3, n2, t2, uv3));
        outStream.Append(VertexOutput(p2, n2, t2, uv2));
        outStream.RestartStrip();
    }
}
