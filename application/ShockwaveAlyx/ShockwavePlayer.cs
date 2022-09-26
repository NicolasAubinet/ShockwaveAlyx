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
            }, 40);

        private static readonly HapticPattern DropInBackpackLeftPattern = new(
            new List<HapticGroupInfo>{
                new(ShockwaveManager.HapticGroup.LEFT_SHOULDER_BACK, 0.5f),
                new(ShockwaveManager.HapticGroup.LEFT_CHEST_BACK, 0.6f),
                new(ShockwaveManager.HapticGroup.LEFT_SPINE_BACK, 0.6f),
                new(ShockwaveManager.HapticGroup.WAIST_BACK, 1.0f),
            }, 40);

        private static readonly HapticPattern GetFromBackpackRightPattern = new(
            new List<HapticGroupInfo>{
                new(ShockwaveManager.HapticGroup.WAIST_BACK, 0.8f),
                new(ShockwaveManager.HapticGroup.RIGHT_SPINE_BACK, 0.6f),
                new(ShockwaveManager.HapticGroup.RIGHT_CHEST_BACK, 0.6f),
                new(ShockwaveManager.HapticGroup.RIGHT_SHOULDER_BACK, 0.3f),
            }, 40);

        private static readonly HapticPattern GetFromBackpackLeftPattern = new(
            new List<HapticGroupInfo>{
                new(ShockwaveManager.HapticGroup.WAIST_BACK, 0.8f),
                new(ShockwaveManager.HapticGroup.LEFT_SPINE_BACK, 0.6f),
                new(ShockwaveManager.HapticGroup.LEFT_CHEST_BACK, 0.6f),
                new(ShockwaveManager.HapticGroup.LEFT_SHOULDER_BACK, 0.3f),
            }, 40);
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

        private void PlayPattern(HapticPattern hapticPattern)
        {
            Task.Run(() => _engine.PlayPattern(hapticPattern));
        }

        public void PlayTestHaptic()
        {
            PlayPattern(new HapticPattern(new List<HapticGroupInfo>{ new(ShockwaveManager.HapticGroup.CHEST, 0.3f) }, 100));
        }

        public void HealthRemaining(float health)
        {
            // TODO
        }

        public void PlayerHurt(int healthRemaining, string enemy, float locationAngle, string enemyName, string enemyDebugName)
        {
            ShockwaveManager.Instance.sendHapticsPulsewithPositionInfo(ShockwaveManager.HapticRegion.TORSO, 1, locationAngle, 2, 4, 50);
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
                }, 10);
            }
            else
            {
                pattern = new(new List<HapticGroupInfo>
                {
                    new(ShockwaveManager.HapticGroup.RIGHT_FOREARM, 1f),
                    new(ShockwaveManager.HapticGroup.RIGHT_ARM, 0.8f),
                    new(ShockwaveManager.HapticGroup.RIGHT_BICEP, 0.4f),
                    new(ShockwaveManager.HapticGroup.RIGHT_SHOULDER, 0.05f),
                }, 10);
            }
            // TODO two-handed mode
            PlayPattern(pattern);
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
            PlayPattern(leftShoulder ? DropInBackpackLeftPattern : DropInBackpackRightPattern);
        }

        public void DropResinInBackpack(bool leftShoulder)
        {
            PlayPattern(leftShoulder ? DropInBackpackLeftPattern : DropInBackpackRightPattern);
        }

        public void RetrievedBackpackClip(bool leftShoulder)
        {
            PlayPattern(leftShoulder ? GetFromBackpackLeftPattern : GetFromBackpackRightPattern);
        }

        public void RetrievedBackpackResin(bool leftShoulder)
        {
            PlayPattern(leftShoulder ? GetFromBackpackLeftPattern : GetFromBackpackRightPattern);
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
                new(ShockwaveManager.HapticGroup.CHEST_FRONT, 0.6f)
            }, 50);
            PlayPattern(pattern);
        }

        public void ShockOnArm(bool leftArm)
        {
        }
    }
}