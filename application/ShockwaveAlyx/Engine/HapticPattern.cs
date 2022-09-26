using System.Collections.Generic;

namespace ShockwaveAlyx
{
    public struct HapticPattern
    {
        public List<HapticGroupInfo> groupInfos;

        public HapticPattern(List<HapticGroupInfo> groupInfos)
        {
            this.groupInfos = groupInfos;
        }

        public HapticPattern(HapticPattern hapticPattern)
        {
            groupInfos = new List<HapticGroupInfo>(hapticPattern.groupInfos);
        }
    }
}