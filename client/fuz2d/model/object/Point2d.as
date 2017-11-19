/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.model.object {
	
	import flash.geom.Point;
	import fuz2d.util.Geom2d;
	
	public class Point2d {

		protected var pt:Point
		public function get point ():Point { return pt; };
		public function set point (val:Point):void { if (val != null) pt = val; }
		
		protected var _z:Number = 0;
		
		protected var _parentObject:Point2d;
		
		protected var _complex:Boolean = false;
		public function get complex ():Boolean { return _complex; }

		protected var _rotation:Number = 0;
		protected var _rotated:Boolean = false;
		protected var _scale:Number;
		
		protected var _renderable:Boolean = false;
		protected var _zSortChildNodes:Boolean = true;
		
		private var _nodeIndex:Number;
		
		protected var _deleted:Boolean = false;
		
		//
		public function get deleted ():Boolean {	
			return (_deleted) ? true : (_parentObject != null) ? _parentObject.deleted : false;
		}
		public function set deleted (val:Boolean):void {
			_deleted = (val) ? true : false;
		}
		
		
		// LOCAL SPACE
		// ------------------------------------------------
		// ------------------------------------------------
		
		// POSITION
		// ------------------------------------------------
		
		//
		public function get x ():Number { return pt.x;  }
		public function set x (val:Number):void {
			moved = (!isNaN(val) && val != pt.x) ? true : _moved;
			pt.x = (isNaN(val)) ? pt.x : val;	
			clearRotatedPosition();
		}
		
		//
		public function get y ():Number { return pt.y; }
		public function set y (val:Number):void {
			moved = (!isNaN(val) && val != pt.y) ? true : _moved;
			pt.y = (isNaN(val)) ? pt.y : val;
			clearRotatedPosition();
		}
		
		//
		public function get z ():Number { return _z; }
		public function set z (val:Number):void {
			moved = (!isNaN(val) && val != _z) ? true : _moved;
			_z = (isNaN(val)) ? _z : val;
			clearRotatedPosition();
		}
		
		// ROTATION
		// ------------------------------------------------
		
		//
		public function get rotated ():Boolean {
			return (_parentObject != null) ? (_parentObject.rotated || _rotated) : _rotated;
		}
		
		//
		public function get rotation ():Number { return _rotation;	}
		public function set rotation (val:Number):void {
			clearRotatedPosition();
			turned = (!isNaN(val) && val != _rotation) ? true : _turned;
			_rotation = (isNaN(val)) ? _rotation : val;
			_rotation = Geom2d.normalizeAngle(_rotation);
			_rotated = (_rotation != 0);
		}
		
		//
		public function setRotatedPosition ():void {
			
			if (_parentObject != null) {

				var pr:Point2d = Geom2d.rotate(this, _parentObject.worldRot);			
					
				_xr = pr.x;
				_yr = pr.y;

				_rr = true;
				
			}
			
		}
		
		//
		public function clearRotatedPosition ():void { _rr = false; }

		protected var _xr:Number = 0;
		protected var _yr:Number = 0;
		protected var _rr:Boolean = false;
		
		
		// SCALE
		// ------------------------------------------------
		
		//
		public function get scale ():Number {
			return _scale;	
		}
		public function set scale (val:Number):void {
			_scale = (isNaN(val)) ? _scale : val;	
			update();
		}
		
		
		
		// WORLD SPACE
		// ------------------------------------------------
		// ------------------------------------------------

		// POSITION
		// ------------------------------------------------
		
		//
		public function get worldX ():Number {	
			if (_parentObject != null) {
				if (!_parentObject.rotated) {
					return _parentObject.worldX + pt.x;	
				} else {
					if (!_rr) setRotatedPosition();
					return _parentObject.worldX + _xr;
				}
			} else {
				return pt.x;
			}
		}
		
		//
		public function get worldY ():Number {	
			if (_parentObject != null) {
				if (!_parentObject.rotated) {
					return _parentObject.worldY + pt.y;	
				} else {
					if (!_rr) setRotatedPosition();
					return _parentObject.worldY + _yr;
				}
			} else {
				return pt.y;
			}
		}

		
		// POSITION - NO ROTATION
		// ------------------------------------------------
		
		//
		public function get waX ():Number {	
			return (_parentObject != null) ? _parentObject.waX + pt.x : pt.x;	
		}
		//
		public function get waY ():Number {	
			return (_parentObject != null) ? _parentObject.waY + pt.y : pt.y;	
		}
		
		// ROTATION
		// ------------------------------------------------
		
		//
		public function get worldRot ():Number {
			if (_parentObject != null) {
				if (!_rr) setRotatedPosition();
				return _parentObject.worldRot + rotation;
			} else {
				return rotation;
			}
		}
		public function set worldRot (val:Number):void {
			rotation = (_parentObject != null) ? val - _parentObject.worldRot : val;
		}
		
			
		// INHERITANCE
		// ------------------------------------------------
		
		//
		public function get parentObject ():Point2d {
			return _parentObject;	
		}
		public function set parentObject (pobj:Point2d):void {	
			
			if (pobj == null) {
				_parentObject = null;
				return;
			}
			
			if (pobj == _parentObject) return;
			
			var ox:Number = 0;
			var oy:Number = 0;
	
			if (_parentObject != null) {
				ox = _parentObject.worldX;
				oy = _parentObject.worldY;	
			}
			
			_parentObject = pobj;
			
			if (_parentObject != null) {
				x -= pobj.worldX - ox;
				y -= pobj.worldY - oy;
			} else {
				x = ox;
				y = oy;
			}
			
		}
		
		//
		public function clearParentObject ():void {
			_parentObject = null;
		}
		
		//
		public function get rootObject ():Point2d {
			return (_parentObject != null) ? _parentObject.rootObject : this;	
		}
		
		//
		public function get copy ():Point2d {
			return new Point2d(parentObject, pt.x, pt.y, _scale);	
		}	
		
		//
		public function get renderable ():Boolean {
			return _renderable;
		}	
		
		//
		public function get zSortChildNodes ():Boolean {
			return _zSortChildNodes;
		}
		public function set zSortChildNodes (val:Boolean):void {
			_zSortChildNodes = (val) ? true : false;
		}
		
		// CHANGE
		// ------------------------------------------------
		
		protected var _moved:Boolean = true;
		protected var _turned:Boolean = true;
		
		//
		public function get moved ():Boolean {
			return _moved;
		}
		public function set moved (val:Boolean):void {
			_moved = (val) ? true : false;
		}
		
		//
		public function get turned ():Boolean {
			return _turned;
		}
		public function set turned (val:Boolean):void {
			_turned = (val) ? true : false;
		}		
		
		public function set changed (val:Boolean):void {
			_moved = (val) ? true : false;
			_turned = (val) ? true : false;
		}

		//
		//
		public function Point2d (parentObject:Point2d = null, x:Number = 0, y:Number = 0, z:Number = 0, scale:Number = 1) {
			
			_parentObject = parentObject;
			
			pt = new Point(x, y);
			
			_z = z;
			_scale = scale;
				
		}	
		
		//
		//
		public function addBy (pt:Point2d):void {
	
			pt.x += pt.x;
			pt.y += pt.y;
			
		}
		
		//
		//
		public function alignTo (pt:Point2d, position:Boolean = true, rotate:Boolean = true):void {
			
			if (position) {
				x = pt.x;
				y = pt.y;
			}
			
			if (rotate) rotation = pt.rotation;
			
		}
		
		//
		//
		public function alignToPoint (pt:Point):void {
			
			x = pt.x;
			y = pt.y;
			
		}
		
		//
		//
		public function alignToWorldCoords (pt:Point2d):void {
			
			x = pt.worldX;
			y = pt.worldY;

		}
		
		//
		//
		public function update ():void { }
		
		//
		//
		public function destroy ():void {
			
			_deleted = true;
			delete this;
			
		}

	}
	
}
