// Rcam depth surface reconstruction shader (geometry shader)
//
// This is a geometry shader that accepts a single point and outputs two
// triangles. It retrieves positions from a given position map and reconstruct
// normal/tangent vectors. It discards triangles that contains invalid (too
// far) positions.

// Uniforms given from RcamSurface.cs
uint _XCount, _YCount;
sampler2D _PositionMap;
float4x4 _LocalToWorld;

// Vertex data output helper
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

// Geometry shader body
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

    // Position map samples
    float4 s21 = tex2Dlod(_PositionMap, float4(u - du * 1, v - dv * 3, 0, 0));
    float4 s31 = tex2Dlod(_PositionMap, float4(u + du * 1, v - dv * 3, 0, 0));

    float4 s12 = tex2Dlod(_PositionMap, float4(u - du * 3, v - dv * 1, 0, 0));
    float4 s22 = tex2Dlod(_PositionMap, float4(u - du * 1, v - dv * 1, 0, 0));
    float4 s32 = tex2Dlod(_PositionMap, float4(u + du * 1, v - dv * 1, 0, 0));
    float4 s42 = tex2Dlod(_PositionMap, float4(u + du * 3, v - dv * 1, 0, 0));

    float4 s13 = tex2Dlod(_PositionMap, float4(u - du * 3, v + dv * 1, 0, 0));
    float4 s23 = tex2Dlod(_PositionMap, float4(u - du * 1, v + dv * 1, 0, 0));
    float4 s33 = tex2Dlod(_PositionMap, float4(u + du * 1, v + dv * 1, 0, 0));
    float4 s43 = tex2Dlod(_PositionMap, float4(u + du * 3, v + dv * 1, 0, 0));

    float4 s24 = tex2Dlod(_PositionMap, float4(u - du * 1, v + dv * 3, 0, 0));
    float4 s34 = tex2Dlod(_PositionMap, float4(u + du * 1, v + dv * 3, 0, 0));

    // Discard invalid outer samples.
    s21.xyz = lerp(s22.xyz, s21.xyz, s21.w);
    s31.xyz = lerp(s32.xyz, s31.xyz, s31.w);

    s12.xyz = lerp(s22.xyz, s12.xyz, s12.w);
    s13.xyz = lerp(s23.xyz, s13.xyz, s13.w);

    s42.xyz = lerp(s32.xyz, s42.xyz, s42.w);
    s43.xyz = lerp(s33.xyz, s43.xyz, s43.w);

    s24.xyz = lerp(s23.xyz, s24.xyz, s24.w);
    s34.xyz = lerp(s33.xyz, s34.xyz, s34.w);

    // Normal vector calculation
    float3 n0 = normalize(cross(s32.xyz - s12.xyz, s23.xyz - s21.xyz));
    float3 n1 = normalize(cross(s42.xyz - s22.xyz, s33.xyz - s31.xyz));
    float3 n2 = normalize(cross(s33.xyz - s13.xyz, s24.xyz - s22.xyz));
    float3 n3 = normalize(cross(s43.xyz - s23.xyz, s34.xyz - s32.xyz));

    // Tangent vector calculation
    float3 t0 = normalize(cross(n0, float3(0, 0, 1)));
    float3 t1 = normalize(cross(n1, float3(0, 0, 1)));
    float3 t2 = normalize(cross(n2, float3(0, 0, 1)));
    float3 t3 = normalize(cross(n3, float3(0, 0, 1)));

    // Convert into the world space.
    float3 p0 = mul(_LocalToWorld, float4(s22.xyz, 1)).xyz;
    float3 p1 = mul(_LocalToWorld, float4(s32.xyz, 1)).xyz;
    float3 p2 = mul(_LocalToWorld, float4(s23.xyz, 1)).xyz;
    float3 p3 = mul(_LocalToWorld, float4(s33.xyz, 1)).xyz;

    n0 = mul((float3x3)_LocalToWorld, n0);
    n1 = mul((float3x3)_LocalToWorld, n1);
    n2 = mul((float3x3)_LocalToWorld, n2);
    n3 = mul((float3x3)_LocalToWorld, n3);

    t0 = mul((float3x3)_LocalToWorld, t0);
    t1 = mul((float3x3)_LocalToWorld, t1);
    t2 = mul((float3x3)_LocalToWorld, t2);
    t3 = mul((float3x3)_LocalToWorld, t3);

    // UV coordinates
    float2 uv0 = float2(u - du, v - dv);
    float2 uv1 = float2(u + du, v - dv);
    float2 uv2 = float2(u - du, v + dv);
    float2 uv3 = float2(u + du, v + dv);

    // Mask values
    float4 mask = float4(s22.w, s32.w, s23.w, s33.w);

    // First triangle
    if (dot(mask.xyz, 1) > 2.9)
    {
        outStream.Append(VertexOutput(p0, n0, t0, uv0));
        outStream.Append(VertexOutput(p1, n1, t1, uv1));
        outStream.Append(VertexOutput(p2, n2, t2, uv2));
        outStream.RestartStrip();
    }

    // Second triangle
    if (dot(mask.yzw, 1) > 2.9)
    {
        outStream.Append(VertexOutput(p1, n1, t1, uv1));
        outStream.Append(VertexOutput(p3, n3, t3, uv3));
        outStream.Append(VertexOutput(p2, n2, t2, uv2));
        outStream.RestartStrip();
    }
}
