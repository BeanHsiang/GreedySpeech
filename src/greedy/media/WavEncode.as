package greedy.media
{
	import flash.utils.*;

	public class WavEncode
	{
		public function toByteArray(data:ByteArray, format:MediaFormat):ByteArray
		{
			var blocks:ByteArray=new ByteArray();
			var buffer:ByteArray=create(data, format);
			blocks.endian=Endian.LITTLE_ENDIAN;
			blocks.writeUTFBytes(format.endian == Endian.LITTLE_ENDIAN ? MediaFormat.RIFF : MediaFormat.RIFX);
			blocks.writeInt(uint(44 + buffer.length));
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
			blocks.writeInt(buffer.length);
			blocks.writeBytes(buffer);
			blocks.position=0;
			return blocks;
		}

		private function create(data:ByteArray, format:MediaFormat):ByteArray
		{
			var _buffer:ByteArray=new ByteArray();
			_buffer.endian=Endian.LITTLE_ENDIAN;
			data.position=0;
			while (data.bytesAvailable)
			{
				_buffer.writeShort(data.readFloat() * 32767);
				if (format.channels == 2)
				{
					_buffer.writeShort(data.readFloat() * 32767);
				}
			}
			return _buffer;
		}
	}
}
