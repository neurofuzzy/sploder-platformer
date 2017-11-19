/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2007 Geoffrey P. Gaudreault
* 
*/

package fuz2d.screen.shape {
	
	import flash.geom.Matrix;
	import flash.display.GradientType;
	import fuz2d.model.environment.*;
	import fuz2d.model.object.*;
	import fuz2d.screen.*;
	import fuz2d.util.Geom2d;
	
	import flash.display.Graphics;
	
	public class Circle extends Polygon {
			
		protected var _m:Matrix;
		
		//
		//
		public function Circle (view:View, container:ViewSprite) {
			
			super(view, container);
					
		}
		
		//
		//
		override public function setPoints ():Boolean {
			
			_screenPoints = [];

			_container.screenPt = _view.translate2d(_container.objectRef);

			return (_container.screenPt != null);

		}
		
		//
		//
		override protected function draw (g:Graphics, clear:Boolean = true):void	{
		
			if (clear) g.clear();
			
			if (setPoints()) {
				
				var r:Number = _container.screenPt.scale * Circle2d(_container.objectRef).radius;
				var o:Number = _container.objectRef.material.opacity;
				var f:Number = _container.objectRef.material.falloff;
				var fx:Number = _container.objectRef.material.falloffRatio;
				
				if (f != 0) {
					
					if (_m == null) _m = new Matrix();
					
					_m.createGradientBox(r * 2, r * 2, 0, 0 - r, 0 - r);
					
					var a1:Number;
					var a2:Number;
					var a3:Number;
					
					if (f > 0) {
						a1 = o;
						a2 = (o + f) * 0.25;
						a3 = 1 - f; 
					} else {
						a1 = 1 + f;
						a2 = (o + f) * 0.25;
						a3 = o;
					}
					
					g.beginGradientFill(GradientType.RADIAL, [adjustedColor, adjustedColor, adjustedColor], [a1, a2, a3], [0, 245 * fx, 245], _m); 
					
				} else {
					
					g.beginFill(adjustedColor, o);
					
				}

				g.drawCircle(0, 0, r);

				g.endFill();

			}

		}
		
	}
	
}
