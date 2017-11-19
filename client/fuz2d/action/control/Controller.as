/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.action.control {
	
	import flash.events.*;
	import fuz2d.action.play.PlayObject;
	import fuz2d.TimeStep;

	public class Controller {
		
		protected var _active:Boolean = false;
		public function get active():Boolean { return _active; }
		public function set active(value:Boolean):void { _active = value; }	
		
		protected var _ended:Boolean = false;
		
		protected var _lastTime:int;
		protected var _delta:Number;
		public function get delta():Number { return _delta; }
		
		//
		//
		public function Controller () {
			
			_lastTime = TimeStep.realTime;
			
		}
		
		//
		//
		public function wake ():void {
			
			if (!_ended && !_active) {
				_lastTime = TimeStep.realTime;
				active = true;
			}
			
		}
		
		//
		//
		public function sleep ():void {
			
			if (_active) active = false;
		
		}
		
		//
		//
		public function see (p:PlayObject):void {
			
			//trace("hi!");
			
		}
		
		//
		//
		public function signal (signaler:Controller, message:String = ""):void {
			
		}
		
		//
		//
		public function update (e:Event):void { 
	
			if (_ended || !_active) return;
			
			_delta = (TimeStep.realTime - _lastTime) * 0.033;
			_lastTime = TimeStep.realTime;
			
		}
		
		//
		//
		public function end ():void {

			_active = false;
			_ended = true;
			
		}
		

	}
	
}
