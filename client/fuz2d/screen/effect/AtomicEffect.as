package fuz2d.screen.effect {
  
    import com.sploder.*;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
    
    import flash.filters.GlowFilter;
	
	import flash.geom.ColorTransform;
    
    public class AtomicEffect extends Effect {

        public var _transform:ColorTransform;
        public var _filter:GlowFilter;
		
		protected var _target:DisplayObject;

        //
        //
        public function AtomicEffect (parentClass:EffectManager) {
            
            super(parentClass);
			
        }
        
        //
        //
        override public function init (parentClass:EffectManager):void {
            
			super.init(parentClass);

			_type = "atomic";
			_affectsColor = true;

            _lifeSpan = 30000;
            _transform = new ColorTransform(1, 1, 1, 1, 244, 50, -50, 0);
			
			if (_parentClass.asset.clip is MovieClip && MovieClip(_parentClass.asset.clip)["body"]) {
				_target = MovieClip(_parentClass.asset.clip)["body"];
			} else {
				_target = _parentClass.asset.clip;
			}
			
			activate();
			
        }
        
        //
        //
        override public function activate ():void {

            super.activate();
			
			_filter = new GlowFilter(0xff9900, 1, 16, 16, 2, 1, false, false);
			
			_target.filters = [_filter];
			_target.transform.colorTransform = _transform;

        }
        
        //
        //
        override public function deactivate (callEnd:Boolean = false):void {

            super.deactivate(callEnd);
			
			if (_target) {
				
				_target.filters = [];
				_transform = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
				_target.scaleX = _target.scaleY = 1;
				_target.transform.colorTransform = _transform;
				_target = null;
				
			}
    
			_complete = true;
            
        }
        
        //
        //
        override public function update ():void {

            super.update();
           
			if (_activated) {

				if (age < _lifeSpan - 2000) {
					
					if (_target.scaleX < 1.2) {
						_target.scaleX += 0.04;
						_target.scaleY = _target.scaleX;
					}
					
				} else {
					
					if (_target.scaleX > 1) {
						_target.scaleX -= 0.04;
						_target.scaleY = _target.scaleX;
					}
					
				}
				
				_filter.alpha = 0.7 + Math.random() * 0.3;
				_target.filters = [_filter];
					
			}
            
        }
            
    }
	
}
