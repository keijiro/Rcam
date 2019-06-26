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

        #endregion

        #region Public properties

        [Space]
        [SerializeField] Color _baseColor = Color.white;
        [SerializeField, Range(0, 1)] float _metallic = 0.5f;
        [SerializeField, Range(0, 1)] float _smoothness = 0.5f;
        [SerializeField, Range(0, 1)] float _cutoff = 0.5f;

        public Color baseColor { set { _baseColor = value; } }
        public float metallic { set { _metallic = value; } }
        public float smoothness { set { _smoothness = value; } }
        public float cutoff { set { _cutoff = value; } }

        [Space]
        [SerializeField, ColorUsage(true, true)] Color _effectColor = Color.white;
        [SerializeField, Range(0, 1)] float _parameter1 = 1;
        [SerializeField, Range(0, 1)] float _parameter2 = 1;
        [SerializeField, Range(0, 1)] float _parameter3 = 1;
        [SerializeField, Range(0, 1)] float _parameter4 = 1;

        public Color effectColor { set { _effectColor = value; } }
        public float parameter1 { set { _parameter1 = value; } }
        public float parameter2 { set { _parameter2 = value; } }
        public float parameter3 { set { _parameter3 = value; } }
        public float parameter4 { set { _parameter4 = value; } }

        #endregion

        #region Private objects

        MaterialPropertyBlock _props;

        #endregion

        #region MonoBehaviour implementation

        void LateUpdate()
        {
            if (_colorMap == null || _positionMap == null) return;
            if (_baseMaterial == null) return;

            if (_props == null) _props = new MaterialPropertyBlock();

            var xc = _positionMap.width / 4;
            var yc = _positionMap.height / 4;

            _props.SetTexture("_BaseColorMap", _colorMap);
            _props.SetTexture("_PositionMap", _positionMap);

            _props.SetInt("_XCount", xc);
            _props.SetInt("_YCount", yc);

            _props.SetColor("_BaseColor", _baseColor);
            _props.SetFloat("_Metallic", _metallic);
            _props.SetFloat("_Smoothness", _smoothness);
            _props.SetFloat("_RcamCutoff", _cutoff);

            _props.SetColor("_RcamColor", _effectColor);
            _props.SetVector("_RcamParams", new Vector4(
                _parameter1, _parameter2, _parameter3, _parameter4));

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
}
