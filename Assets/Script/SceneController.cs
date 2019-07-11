using UnityEngine;
using UnityEngine.Events;

namespace Rcam
{
    sealed class SceneController : MonoBehaviour
    {
        [System.Serializable]
        sealed class BatteryLevelEvent : UnityEvent<float> {}

        [SerializeField] BatteryLevelEvent _batteryLevelEvent = null;

        public void Reboot()
        {
            UnityEngine.SceneManagement.SceneManager.LoadScene(0);
        }

        void Update()
        {
            _batteryLevelEvent.Invoke(Mathf.Clamp01(SystemInfo.batteryLevel));
        }
    }
}
