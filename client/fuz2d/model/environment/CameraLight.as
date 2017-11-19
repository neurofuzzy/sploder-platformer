/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.model.environment {

	import fuz2d.model.*;
	import fuz2d.model.object.*;
	import fuz2d.util.Geom2d;
	
	import flash.utils.Dictionary;
	
	public class CameraLight extends OmniLight {
		
		private var _camera:Camera2d;
		private var _invert:Boolean;
		
		//
		//
		public function CameraLight (camera:Camera2d, invert:Boolean = false, brightness:Number = 0.5, color:uint = 0xffffff) {
			
			super(0, 0, 1, brightness, color);
			
			_camera = camera;
			_invert = invert;
			_lightNorm = new Point(0, 0);
			
		}
		
		//
		//
		override public function update ():void {
			cast();
		}
		
		//
		//
		override public function getLightLevel (object:Object2d):Number {
		
			var lightFactor:Number = 1;
			
			lightFactor = getLightFactor(object);
		
			return Math.min(1, lightFactor);
			
		}
		
		//
		//
		override public function getLightFactor (object:Object2d):Number {
			
			return brightness;
					
		}
		
	}
	
}