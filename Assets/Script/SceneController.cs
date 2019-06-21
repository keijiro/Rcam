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
            _frameCountLabel.text = Time.frameCount.ToString();
        }
    }
}
