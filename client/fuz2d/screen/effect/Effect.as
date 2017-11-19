package fuz2d.screen.effect {
	
	import fuz2d.TimeStep;
	
	public class Effect implements EffectInterface {
		
		protected var _parentClass:EffectManager;
		
		protected var _type:String;
		
        protected var _startTime:Number;
        protected var _lifeSpan:Number = 0;
		
		protected var _activated:Boolean = false;
		protected var _complete:Boolean = false;
		
		public function get type ():String { return _type; }
		public function get age ():int { return TimeStep.realTime - _startTime; }
		public function get active ():Boolean { return _activated; }
		public function get complete ():Boolean  { return _complete; }
		
		protected var _affectsColor:Boolean = false;
		public function get affectsColor():Boolean { return _affectsColor; }

		//
		//
		public function Effect (parentClass:EffectManager) {
			
			init(parentClass);
			
		}
		

        //
        //
        public function init (parentClass:EffectManager):void {
			
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
        public function update ():void {
			
            if (_parentClass == null || _parentClass.asset == null || _parentClass.asset.clip == null) {
                deactivate();
            }
			
			if (_complete) {
				
				_parentClass.removeEffect(this);
				
			} else if (_lifeSpan > 0 && age > _lifeSpan) {
					
				deactivate();

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

			_parentClass.removeEffect(this);

		}
		
	}
	
}