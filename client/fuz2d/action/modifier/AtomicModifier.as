package fuz2d.action.modifier {
  
	import flash.events.Event;
	
    import flash.filters.GlowFilter;
	
	import flash.geom.ColorTransform;
	
	import fuz2d.*;
	import fuz2d.action.modifier.*;
    
    public class AtomicModifier extends Modifier {

        public var _transform:ColorTransform;
        public var _filter:GlowFilter;
        public var _poweringDown:Boolean = false;
    
        //
        //
        public function AtomicModifier () {

        }
        
        //
        //
        override protected function init (parentClass:ModifierManager = null):void {
            
			super.init(parentClass);
			
			_type = "atomic";

            _lifeSpan = 30000;
			
			activate();

        }
        
        //
        //
        override public function activate ():void {

            super.activate();
			
			_parentClass.playObject.strengthFactor = 3;
            
        }
        
        //
        //
        override public function deactivate (callEnd:Boolean = false):void {
 			
			_parentClass.playObject.restoreStrength();
            
			super.deactivate(callEnd);
            
        }
        
        //
        //
        override public function update (e:Event):void {

            super.update(e);
          
			if (_activated) {

				if (age >= _lifeSpan - 2000) {
					
					if (!_poweringDown) {
						_poweringDown = true;
						Fuz2d.sounds.addSound(_parentClass.playObject, "atomic_powerdown");
					}
					
				}
					
			}
            
        }
            
    }
	
}
