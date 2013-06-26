package greedy.utils
{
	import flash.external.*;

	public class External
	{
		public function External()
		{
			super();
		}

		public static function call(functionName:String, ... rest):void
		{
			var arguments:Array=rest;
			if (ExternalInterface.available && functionName)
			{
				try
				{
					ExternalInterface.call(functionName, arguments);
				}
				catch (e:Error)
				{
					debug("Error calling external function: " + e.message);
				}
			}
			else
			{
				debug("No ExternalInterface - External.call: " + functionName + "(" + arguments + ")");
			}
			return;
		}

		public static function addCallback(functionName:String, asFunction:Function):void
		{
			if (ExternalInterface.available && functionName)
			{
				try
				{
					ExternalInterface.addCallback(functionName, asFunction);
				}
				catch (e:Error)
				{
					debug("Error calling external function: " + e.message);
				}
			}
			else
			{
				debug("No ExternalInterface - External.addCallback: " + functionName);
			}
			return;
		}

		public static function debug(arg1:String):void
		{
			if (_IsConsole)
			{
				ExternalInterface.call("console.log", arg1);
			}
			else
			{
				trace(arg1);				
			}
		}

		private static var _IsConsole:Boolean=true;
	}
}
