package
{
	import cmodule.shine.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.system.*;
	import flash.text.*;
	import flash.utils.*;
	
	import flashx.textLayout.formats.Float;
	
	import greedy.media.*;
	import greedy.mp3.*;
	import greedy.recorder.*;
	import greedy.utils.External;

	public class GreedySpeech extends Sprite
	{
		public function GreedySpeech()
		{
			init();
//			_fileReference=new FileReference();
//			_fileReference.addEventListener(Event.SELECT, fileReferenceSelectHandler);
//			stage.addEventListener(MouseEvent.CLICK, clickHandler);
		}

		private function init():void
		{
			this._option=new SpeechOption(root.loaderInfo.parameters);
			External.debug(this._option.toString());
			this._micRecord=new MicRecorder(new MediaFormat(MediaFormat.toRawRate(this._option.rate), this._option.channels, this._option.bit));
			this._micRecord.addEventListener(Event.COMPLETE, this.onRecordComplete);
			//注册外部调用函数
			External.addCallback(STARTRECORD_FUNCTION, this._micRecord.record);
			External.addCallback(STOPRECORD_FUNCTION, internalStopRecord);
			External.addCallback(SET_FUNCTION, internalSet);
			External.addCallback(PLAYRECORD_FUNCTION, internalPlayRecord);
			External.addCallback(STOPPLAYRECORD_FUNCTION, internalStopPlayRecord);
			External.addCallback(PLAYAUDIO_FUNCTION, internalPlayAudio);
			External.addCallback(UPLOAD_FUNCTION, internalUpload);
			External.addCallback(SETVOLUME_FUNCTION, internalSetVolume);
			External.addCallback(SETGAIN_FUNCTION, internalSetGain);			
		}
		
		private function internalSetGain(gain:Number):void
		{
			this._micRecord.Gain=gain;	
		}
		
		private function internalSetVolume(volume:Number):void
		{
			if(this._sndChannel!=null)
			{
				var transform:SoundTransform = _sndChannel.soundTransform;
				transform.volume = volume;
				_sndChannel.soundTransform = transform;
			}
		}

		private function internalPlayAudio(url:String,onSuccess:String="", onError:String=""):void
		{
			try
			{
				var req:URLRequest = new URLRequest(url);
				this._snd=new Sound();
				this._snd.load(req);		
				this._sndChannel = this._snd.play();
				this._sndChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
			}
			catch(e:Error)
			{
				//External.debug(e.message);
			}			
		}
		
		private function soundCompleteHandler(e:Event):void
		{
			this._snd.removeEventListener(SampleDataEvent.SAMPLE_DATA, this.playbackSampleHandler);
			this._sndChannel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
		}
		
		private function internalStopRecord(onSuccess:String, onError:String=""):void
		{
			this._stopRecordSuccessCallback=onSuccess;
			this._stopRecordErrorCallback=onError;
			this._micRecord.stop();
		}

		private function internalSet():void
		{
			Security.showSettings(SecurityPanel.PRIVACY);
		}

		private function internalPlayRecord():void
//		private function internalPlay():void
		{
//			var mp3ByteArray:ByteArray;
			this._micRecord.pcmData.position=0;
			if (this._micRecord.pcmData.bytesAvailable)
			{
				this._snd=new Sound();
				this._snd.addEventListener(SampleDataEvent.SAMPLE_DATA, this.playbackSampleHandler);
				this._sndChannel=this._snd.play();				
				this._sndChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
//				mp3ByteArray=this._mp3Encoder.data; //这里替换成自己的ByteArray			
//				_loader=new MP3FileReferenceLoader();
//				_loader.getMySound(mp3ByteArray);
//				_loader.addEventListener(MP3SoundEvent.COMPLETE, mp3LoaderCompleteHandler);
			}
			else
			{
				External.debug("can't play wav");
			}
		}

		private function playbackSampleHandler(event:SampleDataEvent):void
		{
			for (var i:int=0; i < 8192 && this._micRecord.pcmData.bytesAvailable > 0; i++)
			{
				var sample:Number=this._micRecord.pcmData.readFloat();
				event.data.writeFloat(sample);
				event.data.writeFloat(sample);
			}
		}

		private function internalStopPlayRecord():void
		{
			if (this._sndChannel != null)
			{
				this._sndChannel.stop();
			}
		}

		private function internalUpload(url:String, mime:String="audio/x-wav", onSuccess:String="", onError:String=""):void
		{
			this._uploadSuccessCallback=onSuccess;
			this._uploadErrorCallback=onError;
			this._uploadUrl=url;

			if (mime == "audio/x-mpeg" && this._option.rate >= 44)
			{
				this._mp3Encoder=new MP3Encoder(this._micRecord.wavData);
				this._mp3Encoder.addEventListener(Event.COMPLETE, encodeComplete);
				this._mp3Encoder.start();
			}
			else
			{
				doUpload("audio/x-wav", this._micRecord.wavData);
			}
		}

		private function doUpload(mime:String, content:ByteArray):void
		{
			var loader:URLLoader=new flash.net.URLLoader();
			var request:URLRequest=new URLRequest(this._uploadUrl);
			loader.addEventListener(flash.events.Event.COMPLETE, this.uploadCompleteHandler);
			//			loader.addEventListener(flash.events.Event.OPEN, this.openHandler);
			//			loader.addEventListener(flash.events.ProgressEvent.PROGRESS, this.progressHandler);
			loader.addEventListener(flash.events.SecurityErrorEvent.SECURITY_ERROR, this.uploadErrorHandler);
			//			loader.addEventListener(flash.events.HTTPStatusEvent.HTTP_STATUS, this.httpStatusHandler);
			loader.addEventListener(flash.events.IOErrorEvent.IO_ERROR, this.uploadErrorHandler);

			request.method=URLRequestMethod.POST;
			request.contentType=mime;
			request.data=content;
			try
			{
				loader.load(request);
			}
			catch (error:Error)
			{

			}
		}

		private function uploadCompleteHandler(event:Event):void
		{
			if (this._uploadSuccessCallback != "")
			{
				External.call(this._uploadSuccessCallback, event.target.data);
			}
		}

		private function uploadErrorHandler(event:ErrorEvent):void
		{
			if (this._uploadErrorCallback != "")
			{
				External.call(this._uploadErrorCallback, event.text);
			}
		}

		private function onRecordComplete(event:Event):void
		{
			External.call(this._stopRecordSuccessCallback);
		}

		private function encodeComplete(event:Event):void
		{
			doUpload("audio/x-mpeg", this._mp3Encoder.data);
		}

		private function mp3LoaderCompleteHandler(ev:MP3SoundEvent):void
		{
			this._sndChannel=ev.sound.play();
		}

		//提供给外部调用的函数名称
		private const STARTRECORD_FUNCTION:String="startRecord";
		private const STOPRECORD_FUNCTION:String="stopRecord";
//		private const PAUSE_FUNCTION:String="pause";
		//		private const RESUME_EVENT="resume";

//		private const PLAY_FUNCTION:String="play";
		private const PLAYRECORD_FUNCTION:String="playRecord";
		private const STOPPLAYRECORD_FUNCTION:String="stopPlayRecord";
		private const PLAYAUDIO_FUNCTION:String="playAudio";
		private const STOPPLAYAUDIO_FUNCTION:String="stopPlayAudio";
		private const UPLOAD_FUNCTION:String="upload";
//		private const SAVE_FUNCTION:String="save";
		private const SET_FUNCTION:String="set";
		private const SETVOLUME_FUNCTION:String="setVolume";
		private const SETGAIN_FUNCTION:String="setGain";

		//应用设置
		private var _option:SpeechOption;
		private var _micRecord:MicRecorder;
		private var _mp3Encoder:MP3Encoder;
		private var _snd:Sound;
		private var _sndChannel:SoundChannel=null;
//		private var _loader:MP3FileReferenceLoader;
		//private var _fileReference:FileReference;
		private var _stopRecordSuccessCallback:String;
		private var _stopRecordErrorCallback:String;
		private var _uploadSuccessCallback:String;
		private var _uploadErrorCallback:String;
		private var _uploadUrl:String;
	}
}
