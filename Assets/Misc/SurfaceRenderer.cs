using UnityEngine;

namespace Rcam
{
    [ExecuteInEditMode]
    sealed class SurfaceRenderer : MonoBehaviour
    {
        [SerializeField] Transform _transform = null;
        [SerializeField] Texture _colorMap = null;
        [SerializeField] Texture _positionMap = null;
        [SerializeField, HideInInspector] Shader _shader = null;

        Material _material;

        void OnDestroy()
        {
            if (_material != null)
            {
                if (Application.isPlaying)
                    Destroy(_material);
                else
                    DestroyImmediate(_material);
            }
        }

        void Update()
        {
            if (_colorMap == null || _positionMap == null) return;

            if (_material == null)
            {
                _material = new Material(_shader);
                _material.hideFlags = HideFlags.DontSave;
            }

            var xc = _positionMap.width / 4;
            var yc = _positionMap.height / 4;

            _material.SetTexture("_MainTex", _colorMap);
            _material.SetTexture("_PositionMap", _positionMap);

            _material.SetInt("_XCount", xc);
            _material.SetInt("_YCount", yc);

            var tref = _transform == null ? transform : _transform;
            _material.SetMatrix("_LocalToWorld", tref.localToWorldMatrix);

            Graphics.DrawProcedural(
                _material,
                new Bounds(Vector3.zero, Vector3.one * 1000),
                MeshTopology.Triangles,
                (xc - 1) * (yc - 1) * 6
            );
        }
    }
}
