using System.Threading.Tasks;

namespace ShockwaveAlyx
{
    public class ShockwaveEngine
    {
        private ShockwaveManager _instance;

        public ShockwaveEngine()
        {
            _instance = ShockwaveManager.Instance;
            _instance.enableBodyTracking = false;
        }

        public void Connect()
        {
            _instance.InitializeSuit();
        }

        public void Disconnect()
        {
            _instance.DisconnectSuit();
        }

        public async Task PlayPattern(HapticPattern basePattern, int delay)
        {
            HapticPattern pattern = new HapticPattern(basePattern);

            while (pattern.groupInfos.Count > 0)
            {
                HapticGroupInfo hapticGroupInfo = pattern.groupInfos[0];
                ShockwaveManager.Instance?.SendHapticGroup(hapticGroupInfo.group, hapticGroupInfo.intensity,( (int)(delay*1.5f)/25) *25);
                // ShockwaveManager.Instance?.SendHapticGroup(hapticGroupInfo.group, hapticGroupInfo.intensity, delay);
                pattern.groupInfos.RemoveAt(0);
                await Task.Delay(delay);
            }
        }
    }
}