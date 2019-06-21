using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering.HDPipeline;

namespace Rcam
{
    [ExecuteInEditMode]
    sealed class SimpleBlit : MonoBehaviour
    {
        [SerializeField] RenderTexture _source = null;

        string _label;

        void OnEnable()
        {
            _label = "Simple Blit :: " + gameObject.name;

            var data = GetComponent<HDAdditionalCameraData>();
            if (data != null) data.customRender += CustomRender;
        }

        void OnDisable()
        {
            var data = GetComponent<HDAdditionalCameraData>();
            if (data != null) data.customRender -= CustomRender;
        }

        void CustomRender(ScriptableRenderContext context, HDCamera camera)
        {
            var cmd = CommandBufferPool.Get(_label);

            cmd.SetViewport(new Rect(0, 0, Screen.width, Screen.height));
            CoreUtils.ClearRenderTarget(cmd, ClearFlag.All, Color.clear);

            HDUtils.BlitQuad(
                cmd, _source,
                new Vector4(1, 1, 0, 0),
                new Vector4(1, -1, 0, 1),
                0, true
            );

            context.ExecuteCommandBuffer(cmd);

            CommandBufferPool.Release(cmd);
        }
    }
}
