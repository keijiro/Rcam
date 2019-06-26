// Rcam depth surface reconstruction shader (fragment shader)

// Uniforms given from RcamSurface.cs
float _RcamCutoff;
float4 _RcamColor;
float4 _RcamParams;

// Effector function
// Return: float2(intensity, alpha)

#include "SimplexNoise2D.hlsl"

float2 Effector(float3 wpos, float time)
{
    float g1 = wpos.y * 200;
    float fw = fwidth(g1);
    g1 = saturate(1 - abs(0.5 - frac(g1) * 0.5 / fw) * 2);
    g1 = lerp(g1, 0.1, smoothstep(0.4, 0.7, fw));

    float g2 = snoise(float2(wpos.y * 39 - time * 1, time));
    g2 += snoise(float2(wpos.y * 22 - time * 0.4, time * 0.7));
    g2 = lerp(1, g2, _RcamParams.x);

    wpos.z -= 3;

    float phi = atan2(wpos.z, wpos.x);
    uint seed = (wpos.y * 60 + 1000) * 2;

    float w = lerp(0.02, 2, Hash(seed));
    float s = lerp(0.5, 3, Hash(seed + 1));
    float g3 = frac(phi * w + time * s);
    g3 = lerp(1, g3, _RcamParams.y);

    return float2(g1, min(abs(g2), g3));
}

// Fragment shader function, copy-pasted from HDRP/ShaderPass/ShaderPassGBuffer.hlsl
// There are a few modification from the original shader. See "Custom:" for details.
void Fragment(
            PackedVaryingsToPS packedInput,
            OUTPUT_GBUFFER(outGBuffer)
            #ifdef _DEPTHOFFSET_ON
            , out float outputDepth : SV_Depth
            #endif
            )
{
    FragInputs input = UnpackVaryingsMeshToFragInputs(packedInput.vmesh);

    // input.positionSS is SV_Position
    PositionInputs posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS);

#ifdef VARYINGS_NEED_POSITION_WS
    float3 V = GetWorldSpaceNormalizeViewDir(input.positionRWS);
#else
    // Unused
    float3 V = float3(1.0, 1.0, 1.0); // Avoid the division by 0
#endif

    SurfaceData surfaceData;
    BuiltinData builtinData;
    GetSurfaceAndBuiltinData(input, V, posInput, surfaceData, builtinData);

    // Custom: Call the effector function and apply material changes.
    float2 eff = Effector(GetAbsolutePositionWS(input.positionRWS), _Time.y);
    builtinData.emissiveColor = _RcamColor.rgb * surfaceData.baseColor * eff.x;

    uint seed = posInput.positionSS.x + posInput.positionSS.y * 30000;
    seed += dot(input.texCoord0.xy, float2(324.4432, 6728.1287));
    float fade = lerp(-5, 1, input.texCoord1.x) - Hash(seed);

    clip(min(eff.y - _RcamCutoff, fade));

#ifdef DEBUG_DISPLAY
    ApplyDebugToSurfaceData(input.worldToTangent, surfaceData);
#endif

    ENCODE_INTO_GBUFFER(surfaceData, builtinData, posInput.positionSS, outGBuffer);

#ifdef _DEPTHOFFSET_ON
    outputDepth = posInput.deviceDepth;
#endif
}
