//
// Rcam depth surface reconstructor and renderer
//

using UnityEngine;
using UnityEngine.Rendering;

namespace Rcam
{
    [ExecuteInEditMode]
    sealed class RcamSurface : MonoBehaviour
    {
        #region Editable attributes

        [Space]
        [SerializeField] Transform _sensorOrigin = null;
        [SerializeField] Texture _colorMap = null;
        [SerializeField] Texture _positionMap = null;
        [SerializeField, HideInInspector] Material _baseMaterial = null;

        [Space]
        [SerializeField, ColorUsage(true, true)] Color _effectColor = Color.white;

        #endregion

        #region Public properties

        [Space]
        [SerializeField, Range(0, 1)] float _metallic = 0.5f;
        [SerializeField, Range(0, 1)] float _hueRandomness = 0;

        public float metallic { set { _metallic = value; } }
        public float hueRandomness { set { _hueRandomness = value; } }

        [Space]
        [SerializeField, Range(0, 1)] float _lineToAlpha = 1;
        [SerializeField, Range(0, 1)] float _lineToEmission = 1;

        public float lineToAlpha { set { _lineToAlpha = value; } }
        public float lineToEmission { set { _lineToEmission = value; } }

        [Space]
        [SerializeField, Range(0, 1)] float _slitToAlpha = 0;
        [SerializeField, Range(0, 1)] float _slitToEmission = 0;

        public float slitToAlpha { set { _slitToAlpha = value; } }
        public float slitToEmission { set { _slitToEmission = value; } }

        [Space]
        [SerializeField, Range(0, 1)] float _sliderToAlpha = 0;
        [SerializeField, Range(0, 1)] float _sliderToEmission = 0;

        public float sliderToAlpha { set { _sliderToAlpha = value; } }
        public float sliderToEmission { set { _sliderToEmission = value; } }

        #endregion

        #region Public methods

        public void RandomHue()
        {
            _hueOffset = Random.value;
        }

        public void ResetHue()
        {
            _hueOffset = 0;
        }

        #endregion

        #region Private objects

        MaterialPropertyBlock _props;
        float _hueOffset;

        #endregion

        #region MonoBehaviour implementation

        void LateUpdate()
        {
            if (_colorMap == null || _positionMap == null) return;
            if (_baseMaterial == null) return;

            if (_props == null) _props = new MaterialPropertyBlock();

            if (_slitToAlpha >= 0.9999f || _sliderToAlpha > 0.9999f) return;

            var xc = _positionMap.width / 4;
            var yc = _positionMap.height / 4;

            _props.SetTexture("_BaseColorMap", _colorMap);
            _props.SetTexture("_PositionMap", _positionMap);

            _props.SetInt("_XCount", xc);
            _props.SetInt("_YCount", yc);

            _props.SetColor("_BaseColor", Color.white);
            _props.SetFloat("_Metallic", Mathf.Min(_metallic * 2, 1));
            _props.SetFloat("_Smoothness", _metallic * 0.8f);

            _props.SetColorHsv("_RcamEmission", _effectColor);
            _props.SetVector("_RcamHue", _hueOffset, _hueRandomness);

            _props.SetVector("_RcamLine", _lineToAlpha, _lineToEmission);
            _props.SetVector("_RcamSlit",_slitToAlpha, _slitToEmission);
            _props.SetVector("_RcamSlider",_sliderToAlpha, _sliderToEmission);

            var tref = _sensorOrigin != null ? _sensorOrigin : transform;
            _props.SetMatrix("_LocalToWorld", tref.localToWorldMatrix);

            Graphics.DrawProcedural(
                _baseMaterial,
                new Bounds(Vector3.zero, Vector3.one * 1000),
                MeshTopology.Points, xc * yc, 1,
                null, _props,
                ShadowCastingMode.On, true, gameObject.layer
            );
        }

        #endregion
    }

    static class MaterialPropertyBlockExtensions
    {
        public static void SetVector
            (this MaterialPropertyBlock block, string name,
             float x, float y = 0, float z = 0, float w = 0)
        {
            block.SetVector(name, new Vector4(x, y, z, w));
        }

        public static void SetColorHsv
            (this MaterialPropertyBlock block, string name, Color color)
        {
            float h, s, v;
            Color.RGBToHSV(color, out h, out s, out v);
            block.SetVector(name, new Vector4(h, s, v, color.a));
        }
    }
}
