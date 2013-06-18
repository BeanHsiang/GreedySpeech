//class ShineMP3Encoder
package greedy.media
{
	import cmodule.shine.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import greedy.utils.External;

	public class MP3Encoder extends flash.events.EventDispatcher
	{
		public function MP3Encoder(arg1:flash.utils.ByteArray)
		{
			super();
			dispatchEvent(new flash.events.Event("start", true));
			this.wavData=arg1;
			return;
		}

		public function start():void
		{
			dispatchEvent(new flash.events.Event("start"));
			this.initTime=flash.utils.getTimer();
			this.mp3Data=new flash.utils.ByteArray();
			this.timer=new flash.utils.Timer(1000 / 30);
			this.timer.addEventListener(flash.events.TimerEvent.TIMER, this.update);
			this.cshine=new cmodule.shine.CLibInit().init();
			this.cshine.init(this, this.wavData, this.mp3Data);
			if (this.timer)
			{
				this.timer.start();
			}
			return;
		}

		public function shineError(arg1:String):void
		{
			this.timer.stop();
			this.timer.removeEventListener(flash.events.TimerEvent.TIMER, this.update);
			this.timer=null;
			dispatchEvent(new flash.events.ErrorEvent(flash.events.ErrorEvent.ERROR, false, false, arg1));
			return;
		}

		public function saveAs(arg1:String=".mp3"):void
		{
			new flash.net.FileReference().save(this.mp3Data, arg1);
			return;
		}

		public function get data():flash.utils.ByteArray
		{
			return this.mp3Data;
		}

		private function update(arg1:flash.events.TimerEvent):void
		{
			var loc1:*=this.cshine.update();
			dispatchEvent(new flash.events.ProgressEvent(flash.events.ProgressEvent.PROGRESS, false, false, loc1, 100));
			External.debug("encoding mp3..." + loc1 + "%");
			if (loc1 == 100)
			{
				External.debug("Done in " + (flash.utils.getTimer() - this.initTime) * 0.001 + "s");
				this.timer.stop();
				this.timer.removeEventListener(flash.events.TimerEvent.TIMER, this.update);
				this.timer=null;
				dispatchEvent(new flash.events.Event(flash.events.Event.COMPLETE));
			}
			return;
		}

		private var wavData:flash.utils.ByteArray;

		private var mp3Data:flash.utils.ByteArray;

		private var cshine:Object;

		private var timer:flash.utils.Timer;

		private var initTime:uint;
	}
}


