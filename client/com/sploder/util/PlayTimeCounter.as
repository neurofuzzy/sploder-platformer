package com.sploder.util 
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author geoff
	 */
	public class PlayTimeCounter 
	{
		public static var mainInstance:PlayTimeCounter;
		public static var showTime:Boolean = false;
		public static var timeLimit:int = 0;
		
		private var _timer:Timer;
		private var _running:Boolean = false;
		public var complete:Boolean = false;
		
		private var _secondsCounted:int = 0;
		
		public function PlayTimeCounter() 
		{
			
		}
		
		public function init ():PlayTimeCounter {
			
			mainInstance = this;
			
			if (_timer == null) {
				
				_timer = new Timer(1000, 0);
				_timer.addEventListener(TimerEvent.TIMER, onTimerTick);
				_timer.start();
				
			}
			
			return this;
			
		}
		
		private function onTimerTick (e:TimerEvent):void {
			
			if (_running) {
				_secondsCounted++;
			}
			
		}
		
		public function get secondsCounted():int 
		{
			return _secondsCounted;
		}
		
				
		public function reset ():void {
			
			_running = false;
			complete = false;
			_secondsCounted = 0;
			
		}
		
		public function pause ():void {
			
			_running = false;
			
		}
		
		public function resume ():void {
			
			_running = true;
			
		}
		
		public function end ():void {
			
			if (_timer != null) {
				
				_timer.stop();
				_timer = null;
				
			}
			
		}
		
		
	}

}