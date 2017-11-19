package fuz2d.screen.effect {

    import com.sploder.*;
    
    import flash.filters.GlowFilter;
	
	import flash.geom.ColorTransform;

    public class DisruptionEffect extends Effect {

        public var _transform:ColorTransform;
        public var _filter:GlowFilter;
        public var _poweringDown:Boolean = false;
    
        public var _xhome:Number;
        public var _yhome:Number;
        
        //
        //
        public function DisruptionEffect (parentClass:EffectManager = null) {
            
            super(parentClass);
        
        }
        
        //
        //
        override public function init (parentClass:EffectManager = null):void {

            super.init(parentClass);
			
			_type = "Disruptor";
			
            _lifeSpan = 10000;

			_transform = new ColorTransform(1, 1, 1, 1, 80, 0, 200, 0);
			
        }
		
		//
		//
		override public function setParent(parentClass:EffectManager):void {
			
			super.setParent(parentClass);
			
            _xhome = _parentClass.obj.x;
            _yhome = _parentClass.obj.y;			
			
		}
        
        //
        //
        override public function activate ():void {
            
			super.activate();
			
            _filter = new GlowFilter(0x3300ff, 1, 16, 16, 2, 1, false, false);

			_parentClass.obj.filters = [_filter];
			_parentClass.obj.transform.colorTransform = _transform;
            
        }
        
        //
        //
        override public function deactivate (callEnd:Boolean = false):void {

            super.deactivate(callEnd);
			
            _parentClass.obj.filters = [];
            _transform = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
			_parentClass.obj.transform.colorTransform = _transform;

        }
        
        //
        //
        override public function update ():void {

            super.update();
			
			if (_activated) {
				
				if (age < _lifeSpan) {
					
					_parentClass.obj._xvel = _parentClass.obj._yvel = 0;
					_parentClass.obj.x = _xhome;
					_parentClass.obj.y = _yhome;
					
				} else {
					
					if (!_poweringDown) {
						_poweringDown = true;
						_parentClass.obj.playfield.sounds.addSound(_parentClass.obj, "s_powerrestore");
					}
					
				}
				
				_filter.alpha = 0.7 + Math.random() * 0.3;
				_parentClass.obj.filters = [_filter];
				
				if (age > _lifeSpan) {
					
					deactivate();

				}
			
			}
            
        }
        
        
        
        
        
        
    }
}
