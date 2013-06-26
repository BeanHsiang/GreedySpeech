package
{
	import cmodule.shine.*;

	import flash.display.*;
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.sensors.Accelerometer;
	import flash.system.*;
	import flash.text.*;
	import flash.utils.*;

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
			this._micRecord=new MicRecorder();
			this._micRecord.addEventListener(Event.COMPLETE, this.onRecordComplete);
			//注册外部调用函数
			External.addCallback(STARTRECORD_FUNCTION, this._micRecord.record);
			External.addCallback(STOPRECORD_FUNCTION, internalStopRecord);
			External.addCallback(SET_FUNCTION, internalSet);
			External.addCallback(PLAY_FUNCTION, internalPlay);
			External.addCallback(STOP_FUNCTION, internalStop);
			External.addCallback(UPLOAD_FUNCTION, internalUpload);
		}

		private function internalStopRecord(onSuccess:String, onError:String=null):void
		{
			this._micRecord.stop();
			this._stopRecordSuccessCallback=onSuccess;
			this._stopRecordErrorCallback=onError;
		}

		private function internalSet():void
		{
			Security.showSettings(SecurityPanel.PRIVACY);
		}

		private function internalPlay():void
		{
			var mp3ByteArray:ByteArray=this._mp3Encoder.data; //这里替换成自己的ByteArray
			_loader=new MP3FileReferenceLoader();
			//External.debug(mp3ByteArray.bytesAvailable.toString());
			_loader.getMySound(mp3ByteArray);
			_loader.addEventListener(MP3SoundEvent.COMPLETE, mp3LoaderCompleteHandler);

		}

		private function internalStop():void
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
			var loader:URLLoader=new flash.net.URLLoader();
			var request:URLRequest=new URLRequest(url);
			loader.addEventListener(flash.events.Event.COMPLETE, this.uploadCompleteHandler);
//			loader.addEventListener(flash.events.Event.OPEN, this.openHandler);
//			loader.addEventListener(flash.events.ProgressEvent.PROGRESS, this.progressHandler);
			loader.addEventListener(flash.events.SecurityErrorEvent.SECURITY_ERROR, this.uploadErrorHandler);
//			loader.addEventListener(flash.events.HTTPStatusEvent.HTTP_STATUS, this.httpStatusHandler);
			loader.addEventListener(flash.events.IOErrorEvent.IO_ERROR, this.uploadErrorHandler);

			request.method=URLRequestMethod.POST;
			request.contentType=mime;
			request.data=mime == "audio/x-mpeg" ? this._mp3Encoder.data : this._micRecord.wavData;
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
			External.debug(event.target.data);
			if (this._uploadSuccessCallback != "")
			{
				External.call(this._uploadSuccessCallback, event.target.data);
			}
		}

		private function uploadErrorHandler(event:ErrorEvent):void
		{
			if (this._uploadErrorCallback.length > 0)
			{
				External.call(this._uploadErrorCallback, event.text);
			}
		}

		private function onRecordComplete(event:Event):void
		{
			External.debug(this._micRecord.wavData.bytesAvailable.toString());
			this._mp3Encoder=new MP3Encoder(this._micRecord.wavData);
			this._mp3Encoder.addEventListener(Event.COMPLETE, encodeComplete);
//			this._mp3Encoder.addEventListener("start", makeStart);
			this._mp3Encoder.start();
			return;
		}

		private function encodeComplete(event:Event):void
		{
			External.call(this._stopRecordSuccessCallback);
		}

//		private function clickHandler(ev:MouseEvent):void
//		{
//			_fileReference.browse([new FileFilter("mp3 files", "*.mp3")]);
//		}
//
//		private function fileReferenceSelectHandler(ev:Event):void
//		{
//			_loader.getSound(_fileReference);
//		}

		private function mp3LoaderCompleteHandler(ev:MP3SoundEvent):void
		{
			this._sndChannel=ev.sound.play();
		}

		//提供给外部调用的函数名称
		private const STARTRECORD_FUNCTION:String="startRecord";
		private const STOPRECORD_FUNCTION:String="stopRecord";
//		private const PAUSE_FUNCTION:String="pause";
		//		private const RESUME_EVENT="resume";

		private const PLAY_FUNCTION:String="play";
		private const STOP_FUNCTION:String="stop";
		private const UPLOAD_FUNCTION:String="upload";
//		private const SAVE_FUNCTION:String="save";
		private const SET_FUNCTION:String="set";

		//应用设置
		private var _option:SpeechOption;
		private var _micRecord:MicRecorder;
		private var _mp3Encoder:MP3Encoder;
		private var _sndChannel:SoundChannel=null;
		private var _loader:MP3FileReferenceLoader;
		//private var _fileReference:FileReference;
		private var _stopRecordSuccessCallback:String;
		private var _stopRecordErrorCallback:String;
		private var _uploadSuccessCallback:String;
		private var _uploadErrorCallback:String;
	}
}
