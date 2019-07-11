using UnityEngine;
using Unity.Mathematics;
using Random = Unity.Mathematics.Random;
using Klak.Math;

namespace Rcam
{
    sealed class CameraController : MonoBehaviour
    {
        #region OSC bindings

        public Vector2 Pan { set {
            _panNode.localEulerAngles =
                new Vector3(value.x, -value.y, 0) * 120;
        } }

        public float Distance { get; set; }

        public float Offset { set {
            var z = _baseOffset * math.exp(value);
            _offsetNode.localPosition = new Vector3(0, 0, z);
        } }

        public float Motion { set {
            _motionNode.rotationAmount = _baseMotion * value;
        } }

        public float Freeze { set {
            _trackerNode.enabled = value < 0.5f;
        } }

        public void Recenter()
        {
            _panNode.localEulerAngles = Vector3.zero;
        }

        public void Rehash()
        {
            _motionNode.Rehash();
        }

        public void Jump()
        {
            var p1 = _random.NextFloat3(-1f, 1f) * _jumpDistance;
            var p2 = _random.NextFloat3(-1f, 1f) * _jumpDistance;
            var r1 = _random.NextFloat3(-1f, 1f) * _jumpAngle;
            var r2 = _random.NextFloat3(-1f, 1f) * _jumpAngle;

            _motionNode.Rehash();

            _trackerNode.transform.localPosition += (Vector3)p1;
            _trackerNode.transform.localEulerAngles += (Vector3)r1;
            _followerNode.transform.localPosition += (Vector3)p2;
            _followerNode.transform.localEulerAngles += (Vector3)r2;
        }

        public void Shake()
        {
            _shakeTime = 0;
        }

        public void Impact()
        {
            Shake();
            Jump();
        }

        #endregion

        #region Editable attributes

        [Space]
        [SerializeField] Klak.Motion.SmoothFollow _trackerNode = null;
        [SerializeField] Klak.Motion.SmoothFollow _followerNode = null;
        [SerializeField] Klak.Motion.BrownianMotion _motionNode = null;
        [SerializeField] Klak.Motion.BrownianMotion _shakeNode = null;
        [SerializeField] Transform _panNode = null;
        [SerializeField] Transform _distanceNode = null;
        [SerializeField] Transform _offsetNode = null;
        [Space]
        [SerializeField] AnimationCurve _shakeCurve = null;
        [SerializeField] float _jumpDistance = 0.3f;
        [SerializeField] float _jumpAngle = 20;

        #endregion

        #region MonoBehaviour implementation

        float _baseDistance;
        float _baseOffset;
        float3 _baseMotion;

        CdsTween _distance;

        float3 _shakePosition;
        float3 _shakeRotation;
        float _shakeTime = 1e+3f;

        Random _random = new Random(372845);

        void Start()
        {
            _baseDistance = _distanceNode.localPosition.z;
            _baseOffset = _offsetNode.localPosition.z;
            _baseMotion = _motionNode.rotationAmount;

            _distance = new CdsTween(0, 4);

            _shakePosition = _shakeNode.positionAmount;
            _shakeRotation = _shakeNode.rotationAmount;
            _shakeNode.positionAmount = 0;
            _shakeNode.rotationAmount = 0;
        }

        void Update()
        {
            _distance.Step(_baseDistance * (1 + Distance));
            _distanceNode.localPosition = new Vector3(0, 0, _distance.Current);

            var shake = _shakeCurve.Evaluate(_shakeTime);
            _shakeNode.positionAmount = _shakePosition * shake;
            _shakeNode.rotationAmount = _shakeRotation * shake;
            _shakeTime += Time.deltaTime;
        }

        #endregion
    }
}
