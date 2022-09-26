using System.Collections.Generic;

namespace ShockwaveAlyx
{
    public struct HapticPattern
    {
        public List<HapticGroupInfo> groupInfos;
        public int delay;

        public HapticPattern(List<HapticGroupInfo> groupInfos, int delay)
        {
            this.groupInfos = groupInfos;
            this.delay = delay;
        }

        public HapticPattern(HapticPattern hapticPattern)
        {
            groupInfos = new List<HapticGroupInfo>(hapticPattern.groupInfos);
            delay = hapticPattern.delay;
        }
    }
}