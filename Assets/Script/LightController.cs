using UnityEngine;
using UnityEngine.Experimental.VFX;

namespace Rcam
{
    sealed class LightController : MonoBehaviour
    {
        #region OSC bindings

        public float intensity1 { set {
            _light1.enabled = _vfx1.enabled = (value > 0.001f);
            _light1.intensity = _baseIntensity1 * value;
            _vfx1.SetFloat(_intensityID, value);
        } }

        public float intensity2 { set {
            _light2.enabled = _vfx2.enabled = (value > 0.001f);
            _light2.intensity = _baseIntensity2 * value;
            _vfx2.SetFloat(_intensityID, value);
        } }

        #endregion

        #region Editable attributes

        [SerializeField] Light _light1 = null;
        [SerializeField] Light _light2 = null;
        [SerializeField] VisualEffect _vfx1 = null;
        [SerializeField] VisualEffect _vfx2 = null;
        [SerializeField] float _hueAnimation = 0.1f;

        #endregion

        #region MonoBehaviour implementation

        int _intensityID;
        int _colorID;

        float _baseIntensity1;
        float _baseIntensity2;
        float _hue;

        void Start()
        {
            _intensityID = Shader.PropertyToID("Intensity");
            _colorID = Shader.PropertyToID("Color");

            _baseIntensity1 = _light1.intensity;
            _baseIntensity2 = _light2.intensity;

            intensity1 = 0;
            intensity2 = 0;
        }

        void Update()
        {
            _hue = (_hue + _hueAnimation * Time.deltaTime) % 1.0f;
            var color = Color.HSVToRGB(_hue, 0.9f, 1);

            _light2.color = color;
            _vfx2.SetVector4(_colorID, color);
        }

        #endregion
    }
}
