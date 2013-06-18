package greedy.media
{
	import flash.utils.*;

	public class WavEncode
	{
		public function toByteArray(format:MediaFormat, data:ByteArray):ByteArray
		{
			var blocks:ByteArray=new ByteArray();
			blocks.endian=flash.utils.Endian.LITTLE_ENDIAN;
			blocks.writeUTFBytes(format.endian == Endian.LITTLE_ENDIAN ? MediaFormat.RIFF : MediaFormat.RIFX);
			blocks.writeInt(uint(44 + data.length));
			blocks.writeUTFBytes(MediaFormat.WAVE);
			blocks.writeUTFBytes(MediaFormat.FMT);
			blocks.writeInt(uint(16));
			blocks.writeShort(uint(1));
			blocks.writeShort(format.channels);
			blocks.writeInt(format.sampleRate);
			blocks.writeInt(format.avgBytesPerSec);
			blocks.writeShort(format.blockSize);
			blocks.writeShort(format.bits);
			blocks.writeUTFBytes(MediaFormat.DATA);
			blocks.writeInt(data.length);
			blocks.writeBytes(data);
			blocks.position=0;
			return blocks;
		}
	}
}
