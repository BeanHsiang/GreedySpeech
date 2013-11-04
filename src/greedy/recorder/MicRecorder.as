package greedy.recorder
{
	import flash.events.*;
	import flash.media.*;
	import flash.system.*;
	import flash.utils.*;
	
	import greedy.media.*;
	import greedy.utils.External;

	public class MicRecorder extends EventDispatcher
	{
		public function MicRecorder(format:MediaFormat=null)
		{
			super();
			this._encode=new WavEncode();
			this._data=new ByteArray();
			this._buffer=new ByteArray();
			this._buffer.endian=Endian.LITTLE_ENDIAN;
			this._gain=50;			
			this._completeEvent=new Event(Event.COMPLETE);
			if (format == null)
			{
				this._mediaFormat=new MediaFormat();
			}
			else
			{
				this._mediaFormat=format;
			}
			initMic();
		}

		private function initMic():void
		{
			this._mic=Microphone.getMicrophone();			
			if(Microphone.names.length==0)
			{
				External.debug("nonono");				
			}
			this._mic.setSilenceLevel(0, 1000);
			//this._mic.gain=this._gain;
			if (this._mediaFormat.sampleRate == 16000)
			{
				this._mic.codec=SoundCodec.SPEEX;
			}
			this._mic.rate=MediaFormat.toRoundedRate(this._mediaFormat.sampleRate);

//			this._mic.addEventListener(StatusEvent.STATUS, this.onStatus);
//			this._mic.addEventListener(ActivityEvent.ACTIVITY, this.onActivity);			
		}

		public function record(onSuccess:String, onError:String=""):void
		{
			if (!this.Enabled)
			{
				Security.showSettings(SecurityPanel.PRIVACY);
				if (onError != "")
				{
					External.call(onError, "access denied");
				}
				return;
			}
			if (!this._recording)
			{
				this._mic.addEventListener(SampleDataEvent.SAMPLE_DATA, this.onSampleData);
				this._mic.gain=this._gain;
				this._data.clear();
				this._data.position=0;
				this._recording=true;
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
				this._buffer=this._encode.toByteArray(this._data, this._mediaFormat);
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
			return this._buffer;
		}

		public function get pcmData():ByteArray
		{
			return this._data;
		}
		
		public function get Format():MediaFormat
		{
			return this._mediaFormat;
		}

		public function set Gain(value:Number):void
		{
			this._gain=value;
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
				this._data.writeFloat(sample);
			}
		}

		private var _mic:Microphone;
		private var _enabled:Boolean=false;
		private var _buffer:ByteArray; //用于存放音频采样数据 
		private var _data:ByteArray; //PCM数据
		private var _completeEvent:Event; //录音完成事件对象
		private var _recording:Boolean; //录音中的状态
		private var _mediaFormat:MediaFormat; //录音中的状态
		private var _encode:WavEncode; //wav编码器
		private var _gain:Number; //wav编码器
	}
}
