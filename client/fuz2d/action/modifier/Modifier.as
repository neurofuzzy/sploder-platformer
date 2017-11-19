package fuz2d.action.modifier {
	
	import flash.events.*;
	import fuz2d.TimeStep;
	
	public class Modifier extends EventDispatcher implements ModifierInterface {
		
		protected var _parentClass:ModifierManager;
		public function get parentClass():ModifierManager { return _parentClass; }
		public function set parentClass(value:ModifierManager):void {
			
			_parentClass = value;
			if (value != null) init(_parentClass);
			else end();
			
		}
		
		protected var _type:String;
		
        protected var _startTime:Number;
        protected var _lifeSpan:Number = 0;
		
		protected var _activated:Boolean = false;
		protected var _complete:Boolean = false;
		
		public function get type ():String { return _type; }
		public function get age ():int { return TimeStep.realTime - _startTime; }
		public function get active ():Boolean { return _activated; }
		public function get complete ():Boolean  { return _complete; }
		
		//
		//
		public function Modifier () {
			
			
		}
		

        //
        //
        protected function init (parentClass:ModifierManager = null):void {
			
			_parentClass = parentClass;
			_startTime = TimeStep.realTime;
			
		}
		
        //
        //
        public function activate ():void { 
		
			if (!_complete) _activated = true;
			
		}
        
        //
        //
        public function deactivate (callEnd:Boolean = false):void {
			
			_activated = false;
			if (callEnd) {
				_complete = true;
				end();
			}
			
		}
        
        //
        //
        public function update (e:Event):void {
			
            if (_parentClass.playObject == null || _parentClass.playObject.deleted) {
                deactivate();
            }

			if (_lifeSpan > 0 && age > _lifeSpan) {
				deactivate(true);
			}
			
		}
		
		//
		//
		public function addLife (time:Number):void {
			if (!isNaN(time)) _lifeSpan += time;
		}
		
		//
		//
		public function end ():void {
			
			_complete = true;
			
			if (_parentClass) {
				_parentClass.dispatchEvent(new ModifierEvent(ModifierEvent.END, false, false, this));
				_parentClass.remove(this);
			}
			
		}
		
	}
	
}