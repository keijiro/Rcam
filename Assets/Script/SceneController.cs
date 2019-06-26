using UnityEngine;
using UI = UnityEngine.UI;

namespace Rcam
{
    sealed class SceneController : MonoBehaviour
    {
        [SerializeField] UI.Text _frameCountLabel = null;

        public void Reboot()
        {
            UnityEngine.SceneManagement.SceneManager.LoadScene(0);
        }

        void Update()
        {
            if (_frameCountLabel != null)
                _frameCountLabel.text = Time.frameCount.ToString();
        }
    }
}
