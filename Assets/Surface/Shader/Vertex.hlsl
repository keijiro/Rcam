// Zero constant vertex shader
// An empty vertex shader may cause issues on some platforms (e.g. Vulkan on
// Linux), so we use this this meaningless shader to avoid the issues.

struct Attributes { float4 position : POSITION; };

Attributes Vertex(uint vid : SV_VertexID)
{
    Attributes output;
    output.position = 0;
    return output;
}

