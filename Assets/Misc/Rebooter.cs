using UnityEngine;

namespace Rcam
{
    sealed class Rebooter : MonoBehaviour
    {
        public void Reboot()
        {
            UnityEngine.SceneManagement.SceneManager.LoadScene(0);
        }
    }
}
