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
        public bool LeftHandedMode { get; set; }

        private bool _coughing;
        private float _playerRemainingHealth;

        #region Patterns
        private static readonly HapticGroupPattern DropInBackpackRightPattern = new(
            new List<HapticGroupInfo>{
                new(ShockwaveManager.HapticGroup.RIGHT_SHOULDER_BACK, 0.5f),
                new(ShockwaveManager.HapticGroup.RIGHT_CHEST_BACK, 0.6f),
                new(ShockwaveManager.HapticGroup.RIGHT_SPINE_BACK, 0.6f),
                new(ShockwaveManager.HapticGroup.WAIST_BACK, 1.0f),
            }, 40);

        private static readonly HapticGroupPattern DropInBackpackLeftPattern = new(
            new List<HapticGroupInfo>{
                new(ShockwaveManager.HapticGroup.LEFT_SHOULDER_BACK, 0.5f),
                new(ShockwaveManager.HapticGroup.LEFT_CHEST_BACK, 0.6f),
                new(ShockwaveManager.HapticGroup.LEFT_SPINE_BACK, 0.6f),
                new(ShockwaveManager.HapticGroup.WAIST_BACK, 1.0f),
            }, 40);

        private static readonly HapticGroupPattern GetFromBackpackRightPattern = new(
            new List<HapticGroupInfo>{
                new(ShockwaveManager.HapticGroup.WAIST_BACK, 0.8f),
                new(ShockwaveManager.HapticGroup.RIGHT_SPINE_BACK, 0.6f),
                new(ShockwaveManager.HapticGroup.RIGHT_CHEST_BACK, 0.6f),
                new(ShockwaveManager.HapticGroup.RIGHT_SHOULDER_BACK, 0.3f),
            }, 40);

        private static readonly HapticGroupPattern GetFromBackpackLeftPattern = new(
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

        public void Reset()
        {
            BarnacleGrab = false;
            _coughing = false;
            _playerRemainingHealth = 100;
        }

        private void PlayPattern(HapticGroupPattern hapticPattern)
        {
            Task.Run(() => _engine.PlayPattern(hapticPattern));
        }

        private void PlayPattern(HapticIndexPattern hapticPattern)
        {
            Task.Run(() => _engine.PlayPattern(hapticPattern));
        }

        public void PlayTestHaptic()
        {
            PlayPattern(new HapticGroupPattern(new List<HapticGroupInfo>{ new(ShockwaveManager.HapticGroup.CHEST, 0.3f) }, 100));
        }

        public void HealthRemaining(float health)
        {
            _playerRemainingHealth = health;
        }

        public void PlayerHurt(int healthRemaining, string enemy, float locationAngle, string enemyName, string enemyDebugName)
        {
            ShockwaveManager.Instance.sendHapticsPulsewithPositionInfo(ShockwaveManager.HapticRegion.TORSO, 1, locationAngle, 2, 4, 50);
        }

        public void PlayerShoot(string weapon)
        {
            HapticGroupPattern pattern;
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

        private bool IsLeftHand(bool primaryHand)
        {
            return LeftHandedMode ? primaryHand : !primaryHand;
        }

        public void GrenadeLauncherStateChange(int newState)
        {
        }

        public void GrabbityLockStart(bool primaryHand)
        {
            // ShockwaveManager.HapticGroup group = IsLeftHand(primaryHand)
                // ? ShockwaveManager.HapticGroup.LEFT_FOREARM
                // : ShockwaveManager.HapticGroup.RIGHT_FOREARM;
            // PlayPattern(new HapticGroupPattern(group, 0.4f, 60));
        }

        public void GrabbityLockStop(bool primaryHand)
        {
            // ShockwaveManager.HapticGroup group = IsLeftHand(primaryHand)
                // ? ShockwaveManager.HapticGroup.LEFT_FOREARM
                // : ShockwaveManager.HapticGroup.RIGHT_FOREARM;
            // PlayPattern(new HapticGroupPattern(group, 0.4f, 60));
        }

        public void GrabbityGlovePull(bool primaryHand)
        {
            HapticIndexPattern pattern = IsLeftHand(primaryHand)
                ? new(new []{ 46, 45 }, 0.6f, 50)
                : new(new []{ 54, 53 }, 0.6f, 50);
            PlayPattern(pattern);
        }

        public void GrabbityGloveCatch(bool primaryHand)
        {
            HapticIndexPattern pattern = IsLeftHand(primaryHand)
                ? new(new []{ 46, 45 }, 0.8f, 30)
                : new(new []{ 54, 53 }, 0.8f, 30);
            PlayPattern(pattern);
        }

        public void BarnacleGrabStart()
        {
        }

        public void PlayerDeath(int damagebits)
        {
            _playerRemainingHealth = 0;
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

        public void StoredItemInItemHolder(bool leftHolder)
        {
            ShockwaveManager.HapticGroup group = leftHolder
                ? ShockwaveManager.HapticGroup.LEFT_FOREARM
                : ShockwaveManager.HapticGroup.RIGHT_FOREARM;
            PlayPattern(new HapticGroupPattern(group, 0.6f, 60));
        }

        public void RemovedItemFromItemHolder(bool leftHolder)
        {
            ShockwaveManager.HapticGroup group = leftHolder
                ? ShockwaveManager.HapticGroup.LEFT_FOREARM
                : ShockwaveManager.HapticGroup.RIGHT_FOREARM;
            PlayPattern(new HapticGroupPattern(group, 0.6f, 60));
        }

        public void HealthPenUse(float angle)
        {
        }

        public void HealthStationUse(bool leftArm)
        {
            Task.Run(() => HealthStationUseFunc(leftArm));
        }

        private async Task HealthStationUseFunc(bool leftArm)
        {
            int[] fullBodyRightPatternIndices =
            {
                // Upper right arm
                54, 52, 50, 48,
                // Body
                38, 39, 36, 37, 29, 21, 13, 5,
                // Right leg back
                65, 67, 69, 71,
                // Right leg front
                70, 68, 66, 64,
                // Low body
                6, 15, 8, 1,
                // Left leg front
                56, 58, 60, 62,
                // Left leg back
                63, 61, 59, 57,
                // Back to right shoulder
                2, 1, 0, 7, 15, 23, 31, 39, 38,
                // Lower right arm
                49, 51, 53, 55
            };

            int[] pattern = leftArm
                ? _engine.GetPatternMirror(fullBodyRightPatternIndices)
                : fullBodyRightPatternIndices;

            for (int i = 0; i < (100 - _playerRemainingHealth) / 12; i++)
            {
                // Body
                const int delay = 50;
                HapticIndexPattern bodyPattern = new(pattern, 0.5f, delay);
                PlayPattern(bodyPattern);
                int patternDuration = delay * pattern.Length;

                // Arm
                ShockwaveManager.HapticGroup group =
                    leftArm ? ShockwaveManager.HapticGroup.LEFT_ARM : ShockwaveManager.HapticGroup.RIGHT_ARM;
                HapticGroupPattern armPattern = new(group, 0.4f, patternDuration);
                PlayPattern(armPattern);

                await Task.Delay(patternDuration);
            }
        }

        public void ClipInserted()
        {
            int[] rightArmIndices = { 55, 53 };
            int[] indices = LeftHandedMode ? _engine.GetPatternMirror(rightArmIndices) : rightArmIndices;

            HapticIndexPattern pattern = new(indices, 0.3f, 25);
            PlayPattern(pattern);
        }

        public void ChamberedRound()
        {
        }

        public void Cough()
        {
            _coughing = true;
            Task.Run(CoughFunc);
        }

        private async void CoughFunc()
        {
            const int delay = 50;
            await Task.Delay(500);

            while (_coughing)
            {
                if (!MenuOpen)
                {
                    HapticGroupPattern pattern = new(new List<HapticGroupInfo>
                    {
                        new(ShockwaveManager.HapticGroup.CHEST_FRONT, 0.6f)
                    }, delay);
                    PlayPattern(pattern);
                }

                await Task.Delay(delay);
            }
        }

        public void StopCough()
        {
            _coughing = false;
        }

        public void ShockOnArm(bool leftArm)
        {
        }
    }
}