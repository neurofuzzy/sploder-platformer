/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.screen.shape {
	
	import flash.geom.Point;

	//
	//
	public class ScreenPoint extends Point {
		
		public var scale:Number;

		//
		//
		public function ScreenPoint (x:Number, y:Number, scale:Number) {
			
			super(x,y);

			this.scale = scale;

		}
		
	}
	
}
