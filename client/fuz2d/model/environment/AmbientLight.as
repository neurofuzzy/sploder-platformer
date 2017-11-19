/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.model.environment {

	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import fuz2d.model.*;
	import fuz2d.model.object.*;
	import fuz2d.util.Geom2d;
	
	public class AmbientLight extends OmniLight {
		
		
		//
		//
		public function AmbientLight (parentObject:Point2d = null, x:Number = 0, y:Number = 0, brightness:Number = 1, color:uint = 0xffffff, radius:Number = 200, falloffRadius:Number = 100) {
			
			super(parentObject, x, y, brightness, color, radius, falloffRadius);
			
		}
		
		
		//
		//
		override public function getLightLevel (object:Object2d):Number {
		
			return brightness;
			
		}
		
	}
	
}