/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.physics {

	import flash.geom.Point;
	
	import fuz2d.util.Faster;
	import fuz2d.util.Geom2d;

	public class Vector2d extends Point {
		
		public var angular:Boolean = false;
		
		public function get rotation ():Number { return Math.atan2(y, x); }

		public function get magnitude ():Number { return length; }
		
		public function get squareMagnitude ():Number { return x * x + y * y; }
		
		public function get negligible ():Boolean { return (Faster.abs(x) + Faster.abs(y) < 0.01); }

		public function get strength ():Number { return Faster.abs(x) + Faster.abs(y); }
		
		public function get copy ():Vector2d { return new Vector2d(null, x, y, angular); }
		
		public function get normalizedCopy ():Vector2d { var v:Vector2d = new Vector2d(null, x, y, angular); v.normalize(1); return v; }
		
		
		//
		//
		public function identityFront ():void {
			
			x = 0;
			y = -1;
			
		}
		
		//
		//
		public function identityTop ():void {
			
			x = 0;
			y = -1;
			
		}
		
		//
		//
		public function identityRight ():void {
			
			x = 1;
			y = 0;
			
		}
		
		
		//
		//
		public function Vector2d (pt:Point = null, x:Number = 0, y:Number = 0, angular:Boolean = false) {
			
			if (pt != null) {
				this.x = pt.x;
				this.y = pt.y;
			} else {
				this.x = x;
				this.y = y;
			}
			
			if (isNaN(x) || isNaN(y)) x = y = 0;
			
			this.angular = angular;
			
		}
		
		//
		//
		public function reset ():void {
			
			x = y = 0;
			
		}
		
		//
		//
		public function invert ():void {
			
			x = -x;
			y = -y;
			
		}
		
		//
		//
		public function getInverse ():Vector2d {
			
			return new Vector2d(null, -x, -y, angular);
			
		}
		
		//
		//
		public function alignTo (v:Vector2d):void {
				
			if (isNaN(v.x) || isNaN(v.y)) return;
			
			x = v.x;
			y = v.y;
			
			trunc();
			
		}
		
		//
		//
		public function alignToPoint (pt:Point):void {
			
			if (pt == null || isNaN(pt.x) || isNaN(pt.y)) return;
			
			x = pt.x;
			y = pt.y;
			
			trunc();
			
		}
		
		//
		//
		public function alignPoint (pt:Object):void {
			
			pt.x = x;
			pt.y = y;
			
		}
		
		//
		//
		public function addToPoint (pt:Object, scale:Number = 1):void {
			
			pt.x += x * scale;
			pt.y += y * scale;
	
		}
		
		//
		//
		public function isSameAs (v:Vector2d, tolerance:Number = 0.1):Boolean {
			
			if (Faster.abs(x - v.x) < tolerance && Faster.abs(y - v.y) < tolerance) {
				return true;
			}
			
			return false;
			
		}
		
		//
		//
		public function addBy (v:Vector2d):void {
			
			if (isNaN(v.x) || isNaN(v.y)) return;
			
			x += v.x;
			y += v.y;
			
		}
		
		//
		//
		public function getSum (v:Vector2d):Vector2d {
			return new Vector2d(null, x + v.x, y + v.y, angular);
		}
		
		//
		//
		public function addScaled (v:Vector2d, scale:Number):void {
			
			if (isNaN(v.x) || isNaN(v.y)) return;
			
			x += v.x * scale;
			y += v.y * scale;	
			
		}
		
		//
		//
		public function addRotated (v:Vector2d, rotation:Number):void {
			
			v = v.copy;
			v.rotate(rotation);
			addBy(v);
			
		}
		
		//
		//
		public function addRotatedScaled (v:Vector2d, rotation:Number, scale:Number):void {
			
			v = v.copy;
			v.rotate(rotation);
			addScaled(v, scale);
			
		}


		//
		//
		public function subtractBy (v:Vector2d):void {
			
			if (isNaN(v.x) || isNaN(v.y)) return;
			
			x -= v.x;
			y -= v.y;		
			
		}
		
		//
		//
		public function getDifference (v:Vector2d):Vector2d {
			return new Vector2d(null, x - v.x, y - v.y, angular);
		}
	
		
		//
		//
		public function multiplyBy (v:Vector2d):void {
		
			if (isNaN(v.x) || isNaN(v.y)) return;
			
			x *= v.x;
			y *= v.y;
			
			trunc();
			
		}
		
		//
		//
		public function getProduct (v:Vector2d):Vector2d {
			
			return new Vector2d(null, x * v.x, y * v.y, angular);
			
		}
		
		//
		//
		public function scaleBy (scale:Number):void {
			
			if (isNaN(scale)) return;
			
			x *= scale;
			y *= scale;
			
			trunc();
			
		}
		
		//
		//
		public function getScaled (scale:Number):Vector2d {
			
			return new Vector2d(null, x * scale, y * scale, angular);
			
		}
		
		//
		//
		public function clamp (max:Number):void {
			
			if (squareMagnitude > max * max) scaleBy((max * max) / squareMagnitude);
			
		}
		
		
		//
		//
		public function getDotProduct (v:Vector2d):Number {
			
			if (isNaN(v.x) || isNaN(v.y)) return 0;
			
			return x * v.x + y * v.y;
			
		}
		
		//
		//
		public function getMagnitudeInDirectionOf (v:Vector2d):Number {
			
			if (isNaN(v.x) || isNaN(v.y)) return 0;
			
			var m:Number = 1 / v.magnitude;
			return x * (v.x * m) + y * (v.y * m);
			
		}
		
		//
		//
		public function rotate (rotation:Number):void {
			
			var distance:Number = length;
			var angle:Number = this.rotation + rotation;
			
			var translatePoint:Point = Point.polar(distance, angle);
			x = translatePoint.x;
			y = translatePoint.y;
			
			trunc();
			
		}
		
		//
		//
		public function rotateBy (v:Vector2d):void {
			
			var angle:Number = Math.atan2(v.y, v.x);
			
			if (isNaN(angle)) return;
			
			rotate(angle);
			
		}
		
		///
		protected function trunc ():void {
			
			if (x < 0.00001 && x > -0.00001) x = 0;
			if (y < 0.00001 && y > -0.00001) y = 0;
			
		}

	}
	
}
