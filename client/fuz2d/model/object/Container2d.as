/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.model.object {
	
	import fuz2d.model.Model;
	import fuz2d.model.environment.OmniLight;

	public class Container2d extends Point2d {
		
		protected var _model:Model;
		
		public function get model ():Model {
			return _model;
		}
		public function set model (mdl:Model):void {
			_model = (mdl != null) ? mdl : _model;
		}
		
		
		protected var _childObjects:Array;
		protected var _pointRefs:Array;
		
		public var meshPoints:Array;
		
		public var ignoreChildNodes:Boolean;
		
		//
		public function get childObjects ():Array {
			return _childObjects;
		}
	
		
		//
		public function get points ():Array {
			return _pointRefs;
		}
		
		protected var _minX:Number = 0;
		protected var _maxX:Number = 0;
		protected var _minY:Number = 0;
		protected var _maxY:Number = 0;

		public function get minX():Number { return _minX; }
		public function get maxX():Number { return _maxX; }	
		public function get minY():Number { return _minY; }
		public function get maxY():Number { return _maxY; }

		public function get minWorldX():Number { return worldX + _minX; }
		public function get maxWorldX():Number { return worldX + _maxX; }	
		public function get minWorldY():Number { return worldY + _minY; }
		public function get maxWorldY():Number { return worldY + _maxY; }
		
		protected var _size:Number = 0;
		public function get size():Number { return _size; }
		
		//
		//
		//
		public function Container2d (parentObject:Point2d, x:Number = 0, y:Number = 0, scale:Number = 1) {
			
			super(parentObject, x, y, scale);
			
			_childObjects = [];
			_pointRefs = [];
			
			ignoreChildNodes = false;

		}
		
		//
		//
		public function addChildObject (child:Point2d):Point2d {
			
			if (child.parentObject != this) child.parentObject = this;

			if (_childObjects.indexOf(child) == -1) {
				_childObjects.push(child);
			}
			
			return child;
			
		}
		
		//
		//
		public function removeChildObject (child:Point2d):Point2d {
			
			if (_childObjects.indexOf(child) != -1) {
				child.parentObject = null;
				_childObjects.splice(_childObjects.indexOf(child), 1);
			}
			
			return child;
			
		}
		
		//
		//
		public function addPoint (pt:Point2d):Point2d {
			
			_pointRefs.push(pt);
			
			return pt;
			
		}
		
		//
		//
		override public function update ():void {
	
			for each (var pt:Point2d in _childObjects) pt.update();
			
		}
			
		//
		override public function clearRotatedPosition ():void {
			
			super.clearRotatedPosition();
			for each (var pt:Point2d in _childObjects) pt.clearRotatedPosition();
			//for each (pt in points) pt.clearRotatedPosition();
			//for each (pt in meshPoints) pt.clearRotatedPosition();

		}
		
		//
		override public function get moved ():Boolean {
			
			if (_parentObject != null) {
				
				return (_moved || _parentObject.moved);
				
			} else {
				
				return super.moved;
				
			}
			
		}
		
		//
		override public function get turned ():Boolean {
			
			if (_parentObject != null) {
				
				return (_turned || _parentObject.turned);
				
			} else {
				
				return super.turned;
				
			}
			
		}
		
		
		//
		protected function computeBounds (additionalPoints:Array = null):void {

			var pt:Point2d;
			
			_minX = _minY = _maxX = _maxY = 0;
			
			for each (pt in _childObjects) {
				
				_minX = Math.min(_minX, pt.x);
				_minY = Math.min(_minY, pt.y);
				_maxX = Math.max(_maxX, pt.x);
				_maxY = Math.max(_maxY, pt.y);
				
			}
			
			if (additionalPoints != null) {
				
				try {
					
					for each (pt in additionalPoints) {
						
						_minX = Math.min(_minX, pt.x);
						_minY = Math.min(_minY, pt.y);
						_maxX = Math.max(_maxX, pt.x);
						_maxY = Math.max(_maxY, pt.y);
						
					}
				
				} catch (e:Error) {
					
					trace("checking additional bounding points failed");
					
				}
				
			}
			
			_size = Math.max(Math.abs(_minX), Math.abs(_maxX), Math.abs(_minY), Math.abs(_maxY));
			_size *= 2;
			
		}
		
	}
	
}
