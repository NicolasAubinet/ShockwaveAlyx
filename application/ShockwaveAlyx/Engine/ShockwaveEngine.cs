using System.Collections.Generic;
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

        public async Task PlayPattern(HapticGroupPattern pattern)
        {
            int delay = pattern.delay;

            foreach (HapticGroupInfo hapticGroupInfo in pattern.groupInfos)
            {
                // ShockwaveManager.Instance?.SendHapticGroup(hapticGroupInfo.group, hapticGroupInfo.intensity,( (int)(delay*1.5f)/25) *25);
                ShockwaveManager.Instance?.SendHapticGroup(hapticGroupInfo.group, hapticGroupInfo.intensity, delay);
                await Task.Delay(delay);
            }
        }

        public async Task PlayPattern(HapticIndexPattern pattern)
        {
            int delay = pattern.delay;

            foreach (List<HapticIndex> patternIndexes in pattern.indices)
            {
                List<int> indexes = new();
                List<float> intensities = new();
                foreach (HapticIndex hapticIndex in patternIndexes)
                {
                    indexes.Add(hapticIndex.index);
                    intensities.Add(hapticIndex.intensity);
                }
                ShockwaveManager.Instance?.sendHapticsPulse(indexes.ToArray(), intensities.ToArray(), delay);
                await Task.Delay(delay);
            }
        }
    }
}