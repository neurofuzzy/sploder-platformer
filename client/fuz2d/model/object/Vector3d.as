/**
* Fuz3d: 3d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.model.object {

	import flash.geom.Point;
	import fuz2d.model.object.Point2d;

	public class Vector3d {
		
		public var x:Number;
		public var y:Number;
		public var z:Number;
		
		public var angular:Boolean;
		
		//
		//
		public function get magnitude ():Number {
			
			return Math.sqrt(x * x + y * y + z * z);
			
		}
		
		//
		//
		public function get squareMagnitude ():Number {
			
			return x * x + y * y + z * z;
			
		}
		
		//
		//
		public function get negligible ():Boolean {

			return (Math.abs(x) + Math.abs(y) + Math.abs(z) < 0.00001);
			
		}
		
		//
		//
		public function get strength ():Number {

			return Math.abs(x) + Math.abs(y) + Math.abs(z);
			
		}
		
		//
		//
		public function get normalizedCopy ():Vector3d {
			
			var m:Number = 1 / magnitude;
			return new Vector3d(x * m, y * m, z * m);
			
		}
		
		//
		//
		public function get copy ():Vector3d {
			
			return new Vector3d(x, y, z);
			
		}
		
		//
		//
		//
		public function get copyAsPoint ():Point2d {
			
			return new Point2d(null, x, y, z);
			
		}
		
		//
		//
		public function identityFront ():void {
			
			x = 0;
			y = -1;
			z = 0;
			
		}
		
		//
		//
		public function identityRight ():void {
			
			x = -1;
			y = 0;
			z = 0;
			
		}
		
		//
		//
		public function identityTop ():void {
			
			x = 0;
			y = 0;
			z = 1;
			
		}
		
		//
		//
		public function Vector3d (x:Number = 0, y:Number = 0, z:Number = 0, angular:Boolean = false) {
			
			this.x = x;
			this.y = y;
			this.z = z;
			
			this.angular = angular;
			
		}
		
		//
		//
		public function reset ():void {
			x = y = z = 0;
		}
		
		//
		//
		public function invert ():void {
			
			x = -x;
			y = -y;
			z = -z;
			
		}
		
		//
		//
		public function normalize ():void {
			
			var m:Number = 1 / magnitude;
			
			x *= m;
			y *= m;
			z *= m;
		
		}
		
		//
		//
		public function alignToPoint (pt:Point2d, worldSpace:Boolean = false):void {
			
			if (worldSpace) {
				
				if (!isNaN(pt.worldX) && !isNaN(pt.worldY) && !isNaN(pt.z)) {
					
					x = pt.worldX;
					y = pt.worldY;
					z = pt.z;
					
				}	
				
			} else {
				
				if (!isNaN(pt.x) && !isNaN(pt.y) && !isNaN(pt.z)) {
					
					x = pt.x;
					y = pt.y;
					z = pt.z;
					
				}
			
			}
			
		}
		
		//
		//
		public function alignPoint (pt:Point2d):void {
			
			pt.x = x;
			pt.y = y;
			pt.z = z;
			
		}
		
		//
		//
		public function addToPoint (pt:Point2d, scale:Number = 1):void {
			
			pt.x += x * scale;
			pt.y += y * scale;
			pt.z += z * scale;
			
		}
		
		//
		//
		public function isSameAs (v:Vector3d, tolerance:Number = 0.1):Boolean {
			
			if (Math.abs(x - v.x) < tolerance && Math.abs(y - v.y) < tolerance && Math.abs(z - v.z) < tolerance) {
				return true;
			}
			
			return false;
			
		}
		
		//
		//
		public function addBy (v:Vector3d):void {
			
			x += v.x;
			y += v.y;
			z += v.z;
			
		}
		
		//
		//
		public function addScaled (v:Vector3d, scale:Number):void {
			
			x += v.x * scale;
			y += v.y * scale;
			z += v.z * scale;			
			
		}
		
		//
		//
		public function addRotated (v:Vector3d, xrot:Number, yrot:Number, zrot:Number):void {
			
			v = v.copy;
			v.rotate(xrot, yrot, zrot);
			addBy(v);
			
		}
		
		//
		//
		public function addRotatedScaled (v:Vector3d, xrot:Number, yrot:Number, zrot:Number, scale:Number):void {
			
			v = v.copy;
			v.rotate(xrot, yrot, zrot);
			addScaled(v, scale);
			
		}
	
		
		//
		//
		public function get xrot ():Number {
			
			var run:Number = Math.sqrt(x * x + y * y);
			var rise:Number = z;
			
			return Math.atan2(rise, run);
						
			
		}
		
		//
		//
		public function get yrot ():Number {
			
			return 0;
			
		}
		
		//
		//
		public function get zrot ():Number {
			
			return 0 - Math.atan2(x, y);	
			
		}
		
		//
		//
		public function getSum (v:Vector3d):Vector3d {
			
			return new Vector3d(x + v.x, y + v.y, z + v.z);
			
		}
		
		//
		//
		public function subtractBy (v:Vector3d):void {
			
			x -= v.x;
			y -= v.y;
			z -= v.z;			
			
		}
		
		//
		//
		public function getDifference (v:Vector3d):Vector3d {
			
			return new Vector3d(x - v.x, y - v.y, z - v.z);
			
		}
		
		//
		//
		public function getSquaredDistance (v:Vector3d):Number {
			
			return (v.x - x) * (v.x - x) + (v.y - y) * (v.y - y) + (v.z - z) * (v.z - z);
			
		}
		
		//
		//
		public function multiplyBy (v:Vector3d):void {
		
			x *= v.x;
			y *= v.y;
			z *= v.z;				
			
		}
		
		//
		//
		public function getProduct (v:Vector3d):Vector3d {
			
			return new Vector3d(x * v.x, y * v.y, z * v.z);
			
		}
		
		//
		//
		public function scaleBy (scale:Number):void {
			
			x *= scale;
			y *= scale;
			z *= scale;
			
		}
		
		//
		//
		public function getScaled (scale:Number):Vector3d {
			
			return new Vector3d(x * scale, y * scale, z * scale);
			
		}
		
		
		//
		//
		public function getDotProduct (v:Vector3d):Number {
			
			return x * v.x + y * v.y + z * v.z;
			
		}
		
		//
		//
		public function getMagnitudeInDirectionOf (v:Vector3d):Number {
			
			var m:Number = 1 / v.magnitude;
			return x * (v.x * m) + y * (v.y * m) + z * (v.z * m);
			
		}
		
		//
		//
		public function crossBy (v:Vector3d):void {
		
			var ox:Number = x;
			var oy:Number = y;
			var oz:Number = z;
			
			x = oz * v.y - oy * v.z;
			y = 0 - ox * v.z - oz * v.x;
			z = oy * v.x - ox * v.y;
			
		}
		
		//
		//
		public function getCrossProduct (v:Vector3d):Vector3d {
			
			// NOTE: y and z are flipped from typical left-handed 3d engines
			// positive z is up in elevation off an x,y ground plane
			// also y is flipped
			
			return new Vector3d(z * v.y - y * v.z, 0 - x * v.z - z * v.x, y * v.x - x * v.y);
			
		}
		
		//
		//
		public function getCrossProduct2 (v:Vector3d):Vector3d {
			
			return new Vector3d(y * v.z - z * v.y, z * v.x - x * v.z, x * v.y - y * v.x);
			
		}
		
		//
		//
		public function rotate (xrot:Number, yrot:Number, zrot:Number):void {
			
			var sa:Number;
			var ca:Number;
			
			var tx:Number = x;
			var ty:Number = y;
			var tz:Number = z;
			
			if (yrot != 0) {
				
				sa = Math.sin(yrot);
				ca = Math.cos(yrot);
				
				tx = ca * x - sa * z;
				tz = sa * x + ca * z;
				
				x = tx;
				z = tz;
				
			}
			
			if (xrot != 0) {
				 
				sa = Math.sin(xrot);
				ca = Math.cos(xrot);
			
				ty = ca * y - sa * z;
				tz = ca * z + sa * y;
				
				y = ty;
				z = tz;
				
			}
			
			if (zrot != 0) {
				
				sa = Math.sin(zrot);
				ca = Math.cos(zrot);
				
				tx = ca * x - sa * y;
				ty = sa * x + ca * y;
				
				x = tx;
				y = ty;
				
			}
	
		}
		
		//
		//
		public function rotateBy (v:Vector3d):void {
			
			var o:Vector3d = v.normalizedCopy;
			var m:Number = magnitude;
			
			x = o.x * m;
			y = o.y * m;
			z = o.z * m;
			
		}

	}
	
}
