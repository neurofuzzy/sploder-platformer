/**
* ...
* @author Default
* @version 0.1
*/

package fuz2d.screen.shape {

	import fuz2d.model.environment.*;
	import fuz2d.model.object.*;
	import fuz2d.screen.*;
	import fuz2d.util.Geom2d;
	
	import flash.display.Graphics;
	
	public class Line extends Polygon {
		
		private var startPoint:ScreenPoint;
		private var endPoint:ScreenPoint;
		
		public function Line (view:View, container:ViewSprite) {
			
			super(view, container);

		}
		
		//
		//
		override public function setPoints ():Boolean {
			
			var c:Array = _container.objectRef.points;
			var i:uint = c.length;
			
			_screenPoints = [];

			var obj:Line2d = Line2d(_container.objectRef);
			
			startPoint = _view.translate2d(obj.startPoint);
			endPoint = _view.translate2d(obj.endPoint);
			
			if (startPoint != null && endPoint != null) {
				
				_container.screenPt.scale = (startPoint.scale + endPoint.scale) / 2;
				
				var thickS:Number = obj.thickness * startPoint.scale;
				var thickE:Number = obj.thickness * endPoint.scale;
				
				var angle:Number = Geom2d.angleBetweenPoints(endPoint, startPoint);
				angle += 90 * Geom2d.dtr;
				var sa:Number = Math.sin(angle);
				var ca:Number = Math.cos(angle);
				
				// start point
				var pt1:ScreenPoint = new ScreenPoint(thickS, 0, startPoint.scale);
				Geom2d.rotatePointComputedAngle(pt1, sa, ca);
				pt1.x += startPoint.x;
				pt1.y += startPoint.y;
				_screenPoints.push(pt1);
				
				var pt2:ScreenPoint = new ScreenPoint(0, 0 - thickS, startPoint.scale);
				Geom2d.rotatePointComputedAngle(pt2, sa, ca);
				pt2.x += startPoint.x;
				pt2.y += startPoint.y;
				_screenPoints.push(pt2);
				
				var pt3:ScreenPoint = new ScreenPoint(0 - thickS, 0, startPoint.scale);
				Geom2d.rotatePointComputedAngle(pt3, sa, ca);
				pt3.x += startPoint.x;
				pt3.y += startPoint.y;
				_screenPoints.push(pt3);

				// end point
				var pt4:ScreenPoint = new ScreenPoint(0 - thickE, 0, startPoint.scale);
				Geom2d.rotatePointComputedAngle(pt4, sa, ca);
				pt4.x += endPoint.x;
				pt4.y += endPoint.y;
				_screenPoints.push(pt4);
				
				var pt5:ScreenPoint = new ScreenPoint(0, 0 + thickE, startPoint.scale);
				Geom2d.rotatePointComputedAngle(pt5, sa, ca);
				pt5.x += endPoint.x;
				pt5.y += endPoint.y;
				_screenPoints.push(pt5);
				
				var pt6:ScreenPoint = new ScreenPoint(thickE, 0, startPoint.scale);
				Geom2d.rotatePointComputedAngle(pt6, sa, ca);
				pt6.x += endPoint.x;
				pt6.y += endPoint.y;
				_screenPoints.push(pt6);
				
				return true;
			
			} else {
				
				return false;
				
			}

		}
		
		/*
		//
		//
		override protected function draw(g:Graphics):void {
			
			g.clear();
			
			var c:ViewSprite = _container;
			
			if (setPoints()) {
					
				var i:uint;
				
				g.moveTo(_screenPoints[0].x - c.screenPt.x, _screenPoints[0].y - c.screenPt.y);

				g.beginFill(adjustedColor, _container.objectRef.material.opacity);
								
				for (i = 1; i < _screenPoints.length; i++) {
					
					g.lineTo(_screenPoints[i].x - c.screenPt.x, _screenPoints[i].y - c.screenPt.y);
	
				}

				g.endFill();
				
				g.beginFill(0xff0000);
				g.drawCircle(startPoint.x - c.screenPt.x, startPoint.y - c.screenPt.y, 2);
				g.drawCircle(endPoint.x - c.screenPt.x, endPoint.y - c.screenPt.y, 2);
				g.endFill();
				
			}
			
		}
		*/

	}
	
}
