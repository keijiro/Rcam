// Rcam depth surface reconstruction shader
//
// This is a zero-constant vertex shader that only outputs (0, 0, 0, 0) for all
// inputs. An empty vertex shader may cause issues on some platforms (e.g.
// Vulkan on Linux), so we use this meaningless shader to avoid these issues.

struct Attributes { float4 position : POSITION; };

Attributes Vertex(uint vid : SV_VertexID)
{
    Attributes output;
    output.position = 0;
    return output;
}

