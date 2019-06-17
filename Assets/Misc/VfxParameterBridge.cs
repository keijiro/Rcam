using UnityEngine;
using UnityEngine.Experimental.VFX;

namespace Rcam
{
    sealed class VfxParameterBridge : MonoBehaviour
    {
        public float parameterValue {
            set { if (_target.enabled) _target.SetFloat(_id, value); }
        }

        VisualEffect _target;
        int _id;

        void Start()
        {
            _target = transform.parent.GetComponent<VisualEffect>();
            _id = Shader.PropertyToID(gameObject.name);
        }
    }
}
