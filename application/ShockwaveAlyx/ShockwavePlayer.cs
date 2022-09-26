using System.Collections.Generic;
using System.Threading.Tasks;

namespace ShockwaveAlyx
{
    public class ShockwavePlayer
    {
        private ShockwaveEngine _engine;

        public bool TwoHandedMode { get; set; }
        public bool MenuOpen { get; set; }
        public bool BarnacleGrab { get; set; }
        public bool Coughing { get; set; }
        public bool LeftHandedMode { get; set; }

        #region Patterns
        private static readonly HapticPattern DropInBackpackRightPattern = new(
            new List<HapticGroupInfo>{
                new(ShockwaveManager.HapticGroup.RIGHT_SHOULDER_BACK, 0.5f),
                new(ShockwaveManager.HapticGroup.RIGHT_CHEST_BACK, 0.6f),
                new(ShockwaveManager.HapticGroup.RIGHT_SPINE_BACK, 0.6f),
                new(ShockwaveManager.HapticGroup.WAIST_BACK, 1.0f),
            });

        private static readonly HapticPattern DropInBackpackLeftPattern = new(
            new List<HapticGroupInfo>{
                new(ShockwaveManager.HapticGroup.LEFT_SHOULDER_BACK, 0.5f),
                new(ShockwaveManager.HapticGroup.LEFT_CHEST_BACK, 0.6f),
                new(ShockwaveManager.HapticGroup.LEFT_SPINE_BACK, 0.6f),
                new(ShockwaveManager.HapticGroup.WAIST_BACK, 1.0f),
            });

        private static readonly HapticPattern GetFromBackpackRightPattern = new(
            new List<HapticGroupInfo>{
                new(ShockwaveManager.HapticGroup.WAIST_BACK, 0.8f),
                new(ShockwaveManager.HapticGroup.RIGHT_SPINE_BACK, 0.6f),
                new(ShockwaveManager.HapticGroup.RIGHT_CHEST_BACK, 0.6f),
                new(ShockwaveManager.HapticGroup.RIGHT_SHOULDER_BACK, 0.3f),
            });

        private static readonly HapticPattern GetFromBackpackLeftPattern = new(
            new List<HapticGroupInfo>{
                new(ShockwaveManager.HapticGroup.WAIST_BACK, 0.8f),
                new(ShockwaveManager.HapticGroup.LEFT_SPINE_BACK, 0.6f),
                new(ShockwaveManager.HapticGroup.LEFT_CHEST_BACK, 0.6f),
                new(ShockwaveManager.HapticGroup.LEFT_SHOULDER_BACK, 0.3f),
            });
        #endregion

        public ShockwavePlayer()
        {
            _engine = new ShockwaveEngine();
        }

        public void Connect()
        {
            _engine.Connect();
        }

        public void Disconnect()
        {
            _engine.Disconnect();
        }

        private void PlayPattern(HapticPattern hapticPattern, int delay)
        {
            Task.Run(() => _engine.PlayPattern(hapticPattern, delay));
        }

        public void PlayTestHaptic()
        {
            PlayPattern(new HapticPattern(new List<HapticGroupInfo>{ new(ShockwaveManager.HapticGroup.CHEST, 0.3f) }), 100);
        }

        public void HealthRemaining(float health)
        {
            // TODO
        }

        public void PlayerHurt(int healthRemaining, string enemy, float locationAngle, string enemyName, string enemyDebugName)
        {
            // TODO
        }

        public void PlayerShoot(string weapon)
        {
            HapticPattern pattern;
            if (LeftHandedMode)
            {
                pattern = new(new List<HapticGroupInfo>
                {
                    new(ShockwaveManager.HapticGroup.LEFT_FOREARM, 1f),
                    new(ShockwaveManager.HapticGroup.LEFT_ARM, 0.8f),
                    new(ShockwaveManager.HapticGroup.LEFT_BICEP, 0.4f),
                    new(ShockwaveManager.HapticGroup.LEFT_SHOULDER, 0.05f),
                });
            }
            else
            {
                pattern = new(new List<HapticGroupInfo>
                {
                    new(ShockwaveManager.HapticGroup.RIGHT_FOREARM, 1f),
                    new(ShockwaveManager.HapticGroup.RIGHT_ARM, 0.8f),
                    new(ShockwaveManager.HapticGroup.RIGHT_BICEP, 0.4f),
                    new(ShockwaveManager.HapticGroup.RIGHT_SHOULDER, 0.05f),
                });
            }
            // TODO two-handed mode
            PlayPattern(pattern, 10);
        }

        public void GrenadeLauncherStateChange(int newState)
        {
        }

        public void GrabbityLockStart(bool primaryHand)
        {
            // TODO use LeftHandedMode var
        }

        public void GrabbityLockStop(bool primaryHand)
        {
        }

        public void GrabbityGlovePull(bool primaryHand)
        {
        }

        public void GrabbityGloveCatch(bool primaryHand)
        {
        }

        public void BarnacleGrabStart()
        {
        }

        public void Reset()
        {
        }

        public void PlayerDeath(int damagebits)
        {
        }

        public void DropAmmoInBackpack(bool leftShoulder)
        {
            PlayPattern(leftShoulder ? DropInBackpackLeftPattern : DropInBackpackRightPattern, 40);
        }

        public void DropResinInBackpack(bool leftShoulder)
        {
            PlayPattern(leftShoulder ? DropInBackpackLeftPattern : DropInBackpackRightPattern, 40);
        }

        public void RetrievedBackpackClip(bool leftShoulder)
        {
            PlayPattern(leftShoulder ? GetFromBackpackLeftPattern : GetFromBackpackRightPattern, 40);
        }

        public void RetrievedBackpackResin(bool leftShoulder)
        {
            PlayPattern(leftShoulder ? GetFromBackpackLeftPattern : GetFromBackpackRightPattern, 40);
        }

        public void StoredItemInItemholder(bool leftHolder)
        {
        }

        public void RemovedItemFromItemholder(bool leftHolder)
        {
        }

        public void HealthPenUse(float angle)
        {
        }

        public void HealthStationUse(bool leftArm)
        {
        }

        public void ClipInserted()
        {
        }

        public void ChamberedRound()
        {
        }

        public void Cough()
        {
            HapticPattern pattern = new(new List<HapticGroupInfo>
            {
                new(ShockwaveManager.HapticGroup.CHEST_FRONT, 0.7f)
            });
            PlayPattern(pattern, 100);
        }

        public void ShockOnArm(bool leftArm)
        {
        }
    }
}