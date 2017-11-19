/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.behavior {
	
	import flash.events.*;
	
	import fuz2d.action.physics.*;
	import fuz2d.action.play.PlayObject;
	import fuz2d.model.object.Object2d;

	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class Behavior extends EventDispatcher {
		
		public static const START:String = "start";
		public static const COMPLETE:String = "complete";
		public static const END:String = "end";
		public static const WAKE:String = "wake";
		public static const SLEEP:String = "sleep";
		public static const UPDATE:String = "update";
		
		protected var _priority:int = 10;
		protected var _parentClass:BehaviorManager;

		protected var _idle:Boolean = false;
		public function get idle():Boolean { return _idle; }
		public function set idle(value:Boolean):void {
			
			if (value != _idle) {
				if (value) releaseControl();
				else assumeControl(true);
			}

			_idle = (value) ? true: false;
			
		}
		
		protected var _sleeping:Boolean = false;
		protected var _ended:Boolean = false;
		
		public function get sleeping():Boolean { return _sleeping; }
		public function get ended():Boolean { return _ended; }	
		
		public function get parentClass():BehaviorManager { return _parentClass; }
		
		public function set parentClass(value:BehaviorManager):void {
			
			_parentClass = value;
			if (value != null) init(_parentClass);
			else end();
			
		}
		
		public function get priority():int { return _priority; }
		
		public function set priority(value:int):void 
		{
			_priority = value;
		}
		
		//
		//
		public function Behavior (priority:int = 0) {

			_priority = priority;
			
		}
		
		//
		//
		protected function init (parentClass:BehaviorManager):void {
			
			_parentClass = parentClass;
			
			dispatchEvent(new Event(START));
			
		}
		
		//
		//
		public function assign ():void {
			
			
		}
		
		//
		//
		public function update (e:Event):void {

		}
		
		//
		//
		public function sleep ():void {
		
			releaseControl();
			_sleeping = true;
			
			dispatchEvent(new Event(SLEEP));
			
		}
		
		//
		//
		public function wake ():void {
			
			_sleeping = false;
			
			dispatchEvent(new Event(WAKE));
			
		}
		
		//
		//
		public function assumeControl (force:Boolean = false):void {
			
			if (force) assign();
			
		}
		
		//
		//
		public function releaseControl ():void {
			
		}
		
		//
		//
		public function resolve ():void {
			
			assumeControl();
			
		}
		
		
		//
		//
		public function end ():void {
			
			_ended = true;

			releaseControl();
			
			_parentClass.remove(this);

			dispatchEvent(new Event(Behavior.END));
			
		}

	}
	
}