/**
* ...
* @author Default
* @version 0.1
*/

package fuz2d.model.object {

	import flash.geom.Point;
	
	import fuz2d.model.environment.*;
	import fuz2d.model.material.*;
	
	public class Line2d extends Object2d {
		
		protected var _startPoint:Point;
		protected var _endPoint:Point;
		
		private var _thickness:Number;
		public function get thickness ():Number { return _thickness; }
		public function set thickness (val:Number):void { _thickness = (!isNaN(val)) ? val : _thickness; }
		
		public function get startPoint():Point { return _startPoint; }
		
		public function set startPoint(value:Point):void {
			_startPoint = value;
			updateDimensions();
		}
		
		public function get endPoint():Point { return _endPoint; }
		
		public function set endPoint(value:Point):void {
			_endPoint = value;
			updateDimensions();
		}
		
		public function Line2d (parentObject:Point2d, x:Number = 0, y:Number = 0, length:Number = 20, thickness:Number = 1, material:Material = null, points:Array = null) {
			
			super(parentObject, x, y, scale);
			
			
			if (points == null || points.length < 2 || !(points[0] is Point) || !(points[1] is Point) ) {
				
				startPoint = new Point(0, length / 2);
				endPoint = new Point(0, 0 - length / 2);
				
			} else {
				
				startPoint = points[0].clone();
				endPoint = points[1].clone();
				
			}
			
			_thickness = thickness;
			
			if (material == null) {
				_material = new Material();
			} else {
				_material = material;
			}
			
			_renderable = true;
			
			updateDimensions();
				
		}
		
		protected function updateDimensions ():void {
			
			if (startPoint != null && endPoint != null) {
				
				xpos = startPoint.x + endPoint.x * 0.5;
				ypos = startPoint.y + endPoint.y * 0.5;
				
				width = Math.abs(endPoint.x - startPoint.x);
				height = Math.abs(endPoint.y - startPoint.y);
				
			}
			
		}
		
	}
	
}
