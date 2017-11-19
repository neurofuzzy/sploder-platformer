/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.model.object  {

	import fuz2d.model.environment.*;
	import fuz2d.model.material.*;
	
	public class Circle2d extends Object2d {
		
		private var _radius:Number;
		private var _radius2:Number;
		
		public function get radius():Number { return _radius; }
		
		public function set radius(value:Number):void {
			_radius = value;
			if (_model != null) _model.update(this);
		}
		
		public function get radius2():Number { return _radius2; }
		
		public function set radius2(value:Number):void {
			_radius2 = value;
			if (_model != null) _model.update(this);
		}
		
		//
		//
		public function Circle2d (parentObject:Point2d = null, x:Number = 0, y:Number = 0, scale:Number = 1, radius:Number = 10, radius2:Number = 0, material:Material = null) {
			
			super(parentObject, x, y, scale);
			
			_radius = radius;
			_radius2 = radius2;
			
			if (material == null) {
				_material = new Material();
			} else {
				_material = material;
			}
			
			_renderable = true;
			
			_minX = _minY = 0 - _radius;
			_maxX = _maxY = _radius;

		}
		
	}
	
}
