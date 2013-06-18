package
{

	public final class SpeechOption
	{
		public function SpeechOption(params:Object)
		{
			this._params=params;
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
		}

		public function get maxSpeechTime():uint
		{
			return _maxSpeechTime;
		}

//		public function set maxSpeechTime(value:int):void
//		{
//			_maxSpeechTime = value;
//		}
		private var _params:Object;
		//设定录音的时长，0表示不限制，单位是分钟
		private var _maxSpeechTime:uint;
	}
}
