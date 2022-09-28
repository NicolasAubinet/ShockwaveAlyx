using System.Collections.Generic;

namespace ShockwaveAlyx
{
    public class HapticIndexPattern
    {
        public List<List<HapticIndex>> indices;
        public int delay;

        public HapticIndexPattern(List<List<HapticIndex>> indices, int delay)
        {
            this.indices = indices;
            this.delay = delay;
        }

        public HapticIndexPattern(int[][] indices, float intensity, int delay)
        {
            this.indices = new List<List<HapticIndex>>();
            this.delay = delay;

            foreach (int[] group in indices)
            {
                List<HapticIndex> hapticIndices = new();
                this.indices.Add(hapticIndices);
                foreach (int index in group)
                {
                    hapticIndices.Add(new HapticIndex(index, intensity));
                }
            }
        }

        public HapticIndexPattern(int[,] indices, float intensity, int delay)
        {
            this.indices = new List<List<HapticIndex>>();
            this.delay = delay;

            for (int x = 0; x < indices.GetLength(0); x += 1)
            {
                List<HapticIndex> hapticIndices = new();
                this.indices.Add(hapticIndices);
                for (int y = 0; y < indices.GetLength(1); y += 1)
                {
                    hapticIndices.Add(new HapticIndex(indices[x, y], intensity));
                }
            }
        }

        public HapticIndexPattern(int[] indices, float intensity, int delay)
        {
            this.indices = new List<List<HapticIndex>>();
            this.delay = delay;

            foreach (int index in indices)
            {
                List<HapticIndex> hapticIndices = new();
                this.indices.Add(hapticIndices);
                hapticIndices.Add(new HapticIndex(index, intensity));
            }
        }

        public HapticIndexPattern(HapticIndexPattern hapticPattern)
        {
            indices = new List<List<HapticIndex>>(hapticPattern.indices);
            delay = hapticPattern.delay;
        }
    }
}