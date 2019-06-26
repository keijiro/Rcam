// Rcam depth surface reconstruction shader (fragment shader)

// Uniforms given from RcamSurface.cs
float _RcamCutoff;
float4 _RcamParams;

// Effector functions
// Return: float2(intensity, alpha)

#if defined(_RCAM_EFFECT0)

float2 Effector(float3 wpos, float time)
{
    float g = wpos.y * 300;
    float fw = fwidth(g);
    g = saturate(1 - abs(0.5 - frac(g) * 0.5 / fw) * 2);
    g = lerp(g, 0.1, smoothstep(0.4, 0.7, fw));
    return float2(g, 1);
}

#elif defined(_RCAM_EFFECT1)

float2 Effector(float3 wpos, float time)
{
    return float2(0, frac(wpos.y * 20 + time));
}

#elif defined(_RCAM_EFFECT2)

#include "SimplexNoise2D.hlsl"

float2 Effector(float3 wpos, float time)
{
    float g = snoise(float2(wpos.y * 39 - time * 1, time));
    g += snoise(float2(wpos.y * 22 - time * 0.4, time * 0.7));
    return float2(0, abs(g));
}

#elif defined(_RCAM_EFFECT3)

float2 Effector(float3 wpos, float time)
{
    wpos.z -= 3;

    float phi = atan2(wpos.z, wpos.x);
    uint seed = (wpos.y * 60 + 1000) * 2;

    float w = lerp(0.02, 2, Hash(seed));
    float s = lerp(0.5, 3, Hash(seed + 1));

    float g = frac(phi * w + time * s);
    return float2(0, g);
}

#endif

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
    builtinData.emissiveColor = _BaseColor * eff.x;
    uint seed = posInput.positionSS.x + posInput.positionSS.y * 30000;
    seed += dot(input.texCoord0.xy, float2(324.4432, 6728.1287));
    clip(min(eff.y - _RcamCutoff, lerp(-5, 1, input.texCoord1.x) - Hash(seed)));

#ifdef DEBUG_DISPLAY
    ApplyDebugToSurfaceData(input.worldToTangent, surfaceData);
#endif

    ENCODE_INTO_GBUFFER(surfaceData, builtinData, posInput.positionSS, outGBuffer);

#ifdef _DEPTHOFFSET_ON
    outputDepth = posInput.deviceDepth;
#endif
}
