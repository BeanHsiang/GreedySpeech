package greedy.recorder
{
	import flash.events.*;
	import flash.media.Microphone;
	import flash.utils.*;
	import flash.system.*;

	import greedy.media.*;
	import greedy.utils.External;

	public class MicRecorder extends EventDispatcher
	{
		public function MicRecorder()
		{
			super();
			this._buffer=new ByteArray();
			this._buffer.endian=Endian.LITTLE_ENDIAN;
			this._completeEvent=new Event(Event.COMPLETE);
			initMic();
		}

		private function initMic():void
		{
			this._mic=Microphone.getMicrophone();
			this._mic.setSilenceLevel(0, 1000);
			//this._mic.gain=this._gain;
			this._mic.rate=44;
//			this._mic.addEventListener(StatusEvent.STATUS, this.onStatus);
//			this._mic.addEventListener(ActivityEvent.ACTIVITY, this.onActivity);			
		}

		public function record(onSuccess:String, onError:String=null):void
		{
			if (!this.Enabled)
			{
				Security.showSettings(SecurityPanel.PRIVACY);
				if (onError != null)
				{
					External.call(onError, "access denied");
				}
				return;
			}
			if (!this._recording)
			{
				this._mic.addEventListener(SampleDataEvent.SAMPLE_DATA, this.onSampleData);
				this._buffer.clear();
				this._buffer.position=0;
				this._recording=true;
				External.debug("start a new record");
			}
			External.call(onSuccess);
		}

		public function stop():void
		{
//			this._mic.removeEventListener(StatusEvent.STATUS, this.onStatus);
//			this._mic.removeEventListener(ActivityEvent.ACTIVITY, this.onActivity);
			if (this._recording)
			{
				this._mic.removeEventListener(SampleDataEvent.SAMPLE_DATA, this.onSampleData);
				this._recording=false;
				dispatchEvent(this._completeEvent);
			}
		}

//		public function pause():void
//		{
//		}

		public function get Enabled():Boolean
		{
			if (this._mic.muted)
			{
				this._enabled=false;
				External.debug("Microphone access was denied.");
			}
			else
			{
				this._enabled=true;
				External.debug("Microphone access was allowed.");
			}
			return this._enabled;
		}

		public function get wavData():ByteArray
		{
			var format:MediaFormat=new MediaFormat(MediaFormat.toRawRate(44), 16, 2, Endian.LITTLE_ENDIAN);
			var encode:WavEncode=new WavEncode();
			this._output=encode.toByteArray(format, this._buffer);
			return this._output;
		}

//		private function onStatus(event:StatusEvent):void
//		{
//			//			if (event.code == "Microphone.Unmuted") 
//			//			{ 
//			//				trace("Microphone access was allowed."); 
//			//			}  
//			//			else if (event.code == "Microphone.Muted") 
//			//			{ 
//			//				trace("Microphone access was denied."); 
//			//			} 
//			if (this._mic.muted)
//			{
//				this._enabled=false;
//				External.debug("Microphone access was denied.");
//			}
//			else
//			{
//				this._enabled=true;
//				External.debug("Microphone access was allowed.");
//			}
//		}

//		private function onActivity(event:ActivityEvent):void
//		{
//			External.debug("active");
//		}

		private function onSampleData(event:SampleDataEvent):void
		{
			while (event.data.bytesAvailable)
			{
				var sample:Number=event.data.readFloat();
//				this._buffer.writeFloat(sample);
				this._buffer.writeShort(sample * 32767);
				this._buffer.writeShort(sample * 32767); //默认16bit双声道
			}
		}

		private var _mic:Microphone;
		private var _enabled:Boolean=false;
		private var _buffer:ByteArray; //用于存放音频采样数据
		private var _output:ByteArray; //转换成wav的数据
		private var _completeEvent:Event; //录音完成事件对象
		private var _recording:Boolean; //录音中的状态
	}
}
