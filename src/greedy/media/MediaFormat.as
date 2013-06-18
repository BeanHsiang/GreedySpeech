package greedy.media
{
	import flash.utils.Endian;

	public class MediaFormat
	{
		public function MediaFormat(sampleRate:uint, bits:uint, channels:uint, endian:String)
		{
			this._sampleRate=sampleRate;
			this._bits=bits;
			this._channels=channels;
			this._endian=endian;
		}

		//从准确采样值转到近似值
		public static function toRoundedRate(rate:uint):uint
		{
			if (rate == 5512)
			{
				return 5;
			}
			if (rate == 8000)
			{
				return 8;
			}
			if (rate == 11025)
			{
				return 11;
			}
			if (rate == 16000)
			{
				return 16;
			}
			if (rate == 22050)
			{
				return 22;
			}
			if (rate == 44100)
			{
				return 44;
			}
			throw new Error("不支持的采样率(Hz): " + rate);
		}

		//从近似采样值转到准确值
		public static function toRawRate(rate:uint):uint
		{
			if (rate == 5)
			{
				return 5512;
			}
			if (rate == 8)
			{
				return 8000;
			}
			if (rate == 11)
			{
				return 11025;
			}
			if (rate == 16)
			{
				return 16000;
			}
			if (rate == 22)
			{
				return 22050;
			}
			if (rate == 44)
			{
				return 44100;
			}
			throw new Error("不支持的采样率(kHz): " + rate);
		}

		public function get sampleRate():uint
		{
			return this._sampleRate;
		}

		public function get bits():uint
		{
			return this._bits;
		}

		public function get channels():uint
		{
			return this._channels;
		}

		public function get endian():String
		{
			return this._endian;
		}

		public function get blockSize():uint
		{
			return this._channels * this._bits / 8;
		}

		public function get avgBytesPerSec():uint
		{
			return this.blockSize * this._sampleRate;
		}

		private var _sampleRate:uint; //采样率kHz为单位  11025Hz（11kHz）、22050Hz（22kHz）和44100Hz（44kHz）
		private var _bits:uint; //采样位值，与采样率相对应 8 16 32
		private var _channels:uint; //声道数 1：单声道  2：双声道
		private var _endian:String; //数据存储的字节序 flash.utils.Endian.BIG_ENDIAN flash.utils.Endian.LITTLE_ENDIAN

		//需要使用的常量
		public static const RIFF:String="RIFF";
		public static const RIFX:String="RIFX";
		public static const WAVE:String="WAVE";
		public static const FMT:String="fmt ";
		public static const DATA:String="data";
	}
}
