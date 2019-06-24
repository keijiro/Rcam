using UnityEngine;

namespace Rcam
{
    [ExecuteInEditMode]
    sealed class SurfaceRenderer : MonoBehaviour
    {
        [SerializeField] Transform _transform = null;
        [SerializeField] Texture _colorMap = null;
        [SerializeField] Texture _positionMap = null;

        [SerializeField, Range(0, 1)] float _intensity = 1;

        public float intensity {
            get { return _intensity; }
            set { _intensity = value; }
        }

        [SerializeField] Material _material = null;

        MaterialPropertyBlock _props;

        void Update()
        {
            if (_colorMap == null || _positionMap == null) return;
            if (_material == null) return;

            if (_props == null) _props = new MaterialPropertyBlock();

            if (_intensity < 0.001f) return;

            var xc = _positionMap.width / 2;
            var yc = _positionMap.height / 2;

            _props.SetTexture("_MainTex", _colorMap);
            _props.SetTexture("_PositionMap", _positionMap);

            _props.SetInt("_XCount", xc);
            _props.SetInt("_YCount", yc);

            _props.SetFloat("_Intensity", _intensity);

            var tref = _transform == null ? transform : _transform;
            _props.SetMatrix("_LocalToWorld", tref.localToWorldMatrix);

            Graphics.DrawProcedural(
                _material,
                new Bounds(Vector3.zero, Vector3.one * 1000),
                MeshTopology.Triangles,
                (xc - 1) * (yc - 1) * 6, 1,
                null, _props
            );
        }
    }
}
