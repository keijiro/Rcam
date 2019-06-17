using UnityEngine;

namespace Rcam
{
    sealed class Rebooter : MonoBehaviour
    {
        void Update()
        {
            if (Input.GetKeyDown(KeyCode.Q))
                UnityEngine.SceneManagement.SceneManager.LoadScene(0);
        }
    }
}
