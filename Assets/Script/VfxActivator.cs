using UnityEngine;
using UnityEngine.Experimental.VFX;

namespace Rcam
{
    sealed class VfxActivator : MonoBehaviour
    {
        public float threshold = 0.01f;
        public float delay = 1;

        public float parameterValue {
            set
            {
                if (value > threshold)
                {
                    // Enabled
                    _target.enabled = true;
                    _offTime = -1;
                }
                else
                {
                    // Start counting offtime.
                    _offTime = Mathf.Max(_offTime, 0.0f);

                    // If no delay is given, immediately disable the vfx.
                    if (delay <= 0) _target.enabled = false;
                }
            }
        }

        VisualEffect _target;
        float _offTime = -1;

        void Start()
        {
            _target = GetComponent<VisualEffect>();
        }

        void Update()
        {
            if (_offTime >= 0 && _offTime < delay)
            {
                // Offtime accumulation.
                _offTime += Time.deltaTime;

                // Disable the vfx when it reached to the delay time.
                if (_offTime >= delay) _target.enabled = false;
            }
        }
    }
}
