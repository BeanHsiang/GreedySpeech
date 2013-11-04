package
{
   	public final class SpeechOption
	{
		public function SpeechOption(params:Object)
		{
			this._params=params;
			init();
		}

		private function init():void
		{
			if (this._params["maxspeechtime"] != null)
			{
				this._maxSpeechTime=uint(this._params["maxspeechtime"]);
			}
			else
			{
				this._maxSpeechTime=0;
			}

			if (this._params.rate != null)
			{
				this._rate=uint(this._params.rate);
			}
			else
			{
				this._rate=44;
			}

			if (this._params["bit"] != null)
			{
				this._bit=uint(this._params["bit"]);
			}
			else
			{
				this._bit=16;
			}

			if (this._params["channels"] != null)
			{
				this._channels=uint(this._params["channels"]);
			}
			else
			{
				this._channels=2;
			}
		}

		public function get maxSpeechTime():uint
		{
			return _maxSpeechTime;
		}

		public function get rate():uint
		{
			return _rate;
		}

		public function get bit():uint
		{
			return _bit;
		}

		public function get channels():uint
		{
			return _channels;
		}

		public function toString():String
		{
			return "rate: " + this._rate + " channels: " + this._channels + " bit: " + this._bit + " maxSpeechTime: " + this._maxSpeechTime;
		}
//		public function set maxSpeechTime(value:int):void
//		{
//			_maxSpeechTime = value;
//		}
		private var _params:Object;
		//设定录音的时长，0表示不限制，单位是分钟
		private var _maxSpeechTime:uint;
		private var _rate:uint;
		private var _bit:uint;
		private var _channels:uint;
	}
}
