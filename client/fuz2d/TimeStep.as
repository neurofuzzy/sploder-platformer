package fuz2d 
{
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Geoff Gaudreault
	 */
	public class TimeStep 
	{
		private static var _stepValue:int = 300;
		private static var _stepTime:int = 5000;
		private static var _realTime:int = 5000;
		
		private static var _speed:Number;
		
		public static function reset ():void
		{
			_stepValue = 300;
			_speed = 1000 / 60;
			_stepTime = _stepValue * speed;	
			_realTime = getTimer() + 5000;
		}
		
		public static function step ():void
		{
			_stepValue++;
			_stepTime = _stepValue * speed;
			_realTime = getTimer() + 5000;
		}
		
		static public function get stepTime():int 
		{
			return _stepTime;
		}
		
		static public function get realTime():int 
		{
			return _realTime;
		}
		
		
		static public function get speed():Number 
		{
			return _speed;
		}
		
		static public function get stepValue():int 
		{
			return _stepValue;
		}
		
		static public function set stepValue(value:int):void 
		{
			_stepValue = value;
		}
		
	}

}