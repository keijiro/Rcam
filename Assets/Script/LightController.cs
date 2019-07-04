using UnityEngine;

namespace Rcam
{
    sealed class LightController : MonoBehaviour
    {
        #region OSC bindings

        public float intensity1 { set {
            _light1.enabled = _renderer1.enabled = (value > 0.001f);
            _light1.intensity = _baseIntensity1 * value;
            _renderer1.transform.localScale = Vector3.one * (_baseScale1 * value);
        } }

        public float intensity2 { set {
            _light2.enabled = _renderer2.enabled = (value > 0.001f);
            _light2.intensity = _baseIntensity2 * value;
            _renderer2.transform.localScale = Vector3.one * (_baseScale2 * value);
        } }

        #endregion

        #region Editable attributes

        [SerializeField] Light _light1 = null;
        [SerializeField] Light _light2 = null;
        [SerializeField] Renderer _renderer1 = null;
        [SerializeField] Renderer _renderer2 = null;
        [SerializeField] float _hueAnimation = 0.1f;

        #endregion

        #region MonoBehaviour implementation

        float _baseIntensity1;
        float _baseIntensity2;
        float _baseScale1;
        float _baseScale2;
        float _hue;

        void Start()
        {
            _baseIntensity1 = _light1.intensity;
            _baseIntensity2 = _light2.intensity;
            _baseScale1 = _renderer1.transform.localScale.x;
            _baseScale2 = _renderer2.transform.localScale.x;
        }

        void Update()
        {
            _hue = (_hue + _hueAnimation * Time.deltaTime) % 1.0f;
            _light2.color = Color.HSVToRGB(_hue, 1, 1);
        }

        #endregion
    }
}
