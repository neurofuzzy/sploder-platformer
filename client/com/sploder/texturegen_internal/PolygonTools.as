package com.sploder.texturegen_internal
{
	
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import com.sploder.texturegen_internal.util.Geom;
	
	public class PolygonTools
	{
		public static var OFFSET_TYPE_POLY_CENTERSCALING:int = 0;
		public static var OFFSET_TYPE_POLY_LINEAR:int = 1;
		public static var OFFSET_TYPE_BRICK:int = 2;
		public static var CLIP_TYPE_RAMP_TL:int = 1;
		public static var CLIP_TYPE_RAMP_TR:int = 2;
		public static var CLIP_TYPE_RAMP_BR:int = 3;
		public static var CLIP_TYPE_RAMP_BL:int = 4;
		protected static var centerPt:Point;
		
		public static function getClippedPolygons(polygons:Array, type:int = 0, offsetX:int = 0, offsetY:int = 0):Array
		{
			var clip_ptA:Point = new Point(-10000, -10000);
			var clip_ptB:Point = new Point(10000, 10000);
			switch (type)
			{
				case PolygonTools.CLIP_TYPE_RAMP_TL: 
				case PolygonTools.CLIP_TYPE_RAMP_BR: 
				{
					clip_ptA.x = 10000;
					clip_ptB.x = -10000;
				}
					break;
			}
			clip_ptA.x += offsetX;
			clip_ptA.y += offsetY;
			clip_ptB.x += offsetX;
			clip_ptB.y += offsetY;
			var new_polygons:Array = [];
			var pt:Point;
			var intersection_pt:Point;
			var inside:Boolean;
			var last_pt:Point = null;
			var poly_inside:Boolean = false;
			var last_inside:Boolean = false;
			var new_polygon:Array;
			{
				var _g:int = 0;
				while (_g < polygons.length)
				{
					var polygon:Array = polygons[_g];
					++_g;
					new_polygon = [];
					{
						var _g2:int = -1, _g1:int = polygon.length;
						while (_g2 < _g1)
						{
							var i:int = _g2++;
							if (i < 0)
								pt = polygon[polygon.length - 1];
							else
								pt = polygon[i];
							switch (type)
							{
								case PolygonTools.CLIP_TYPE_RAMP_TR: 
									inside = pt.x + offsetX <= pt.y + offsetY;
									break;
								case PolygonTools.CLIP_TYPE_RAMP_TL: 
									inside = pt.x - offsetX >= 0 - pt.y + offsetY;
									break;
								case PolygonTools.CLIP_TYPE_RAMP_BL: 
									inside = pt.x + offsetX >= pt.y + offsetY;
									break;
								case PolygonTools.CLIP_TYPE_RAMP_BR: 
									inside = pt.x - offsetX <= 0 - pt.y + offsetY;
									break;
								default: 
									inside = true;
									break;
							}
							if (i < 0)
								poly_inside = last_inside = inside;
							if (i >= 0)
							{
								if (inside != last_inside)
								{
									intersection_pt = Geom.intersectLineLine(clip_ptA.x, clip_ptA.y, clip_ptB.x, clip_ptB.y, pt.x, pt.y, last_pt.x, last_pt.y);
									if (intersection_pt != null)
										new_polygon.push(intersection_pt);
								}
							}
							if (inside)
								new_polygon.push(pt);
							last_pt = pt;
							last_inside = inside;
						}
					}
					if (new_polygon.length > 2)
						new_polygons.push(new_polygon);
				}
			}
			return new_polygons;
		}
		
		public static function getOffsetPolygons(polygons:Array, dist:Number, type:int = 0):Array
		{
			var new_polygons:Array = [];
			if (type == PolygonTools.OFFSET_TYPE_POLY_CENTERSCALING || type == PolygonTools.OFFSET_TYPE_POLY_LINEAR)
			{
				var _g1:int = 0, _g:int = polygons.length;
				while (_g1 < _g)
				{
					var i:int = _g1++;
					new_polygons.push(PolygonTools.getOffsetCentroid(polygons[i], dist, type));
				}
			}
			else
			{
				var _g11:int = 0, _g2:int = polygons.length;
				while (_g11 < _g2)
				{
					var i1:int = _g11++;
					new_polygons.push(PolygonTools.getOffsetRectangle(polygons[i1], dist));
				}
			}
			return new_polygons;
		}
		
		public static function getOffsetPolygon(polygon:Array, dist:Number, type:int = 0):Array
		{
			if (type != PolygonTools.OFFSET_TYPE_BRICK)
				return PolygonTools.getOffsetCentroid(polygon, dist, type);
			else
				return PolygonTools.getOffsetRectangle(polygon, dist);
			return null;
		}
		
		public static function getOffsetCentroid(points:Array, dist:Number, type:int = 0):Array
		{
			if (dist <= 0 || points.length < 3)
				return points.concat();
			var n:int = points.length;
			var offset_pts:Array = [];
			var centroid:Point = PolygonTools.getAverage(points);
			var offset_pt:Point = new Point();
			var cross_line:*;
			var line_ang:Number;
			var line_len:Number;
			{
				var _g:int = 0;
				while (_g < n)
				{
					var i:int = _g++;
					cross_line = {p0x: points[i].x, p0y: points[i].y, p1x: centroid.x, p1y: centroid.y}
					line_ang = PolygonTools.lineAngle(cross_line);
					line_len = PolygonTools.lineLength(cross_line);
					if (type == PolygonTools.OFFSET_TYPE_POLY_CENTERSCALING)
						offset_pt.x = Math.min(line_len, dist / ((100 - dist) / line_len));
					else
						offset_pt.x = Math.min(line_len, dist);
					offset_pt.y = 0;
					Geom.rotate(offset_pt, line_ang);
					offset_pt.x += points[i].x;
					offset_pt.y += points[i].y;
					offset_pts.push(offset_pt.clone());
				}
			}
			return offset_pts;
		}
		
		public static function getOffsetRectangle(points:Array, dist:Number):Array
		{
			var bounds:Rectangle = Geom.boundingBox(points);
			var center_pt:Point = new Point(bounds.left + bounds.width * 0.5, bounds.top + bounds.height * 0.5);
			var offset_pts:Array = [];
			var n:int = points.length;
			var pt:Point;
			dist = Math.min(dist, Math.min(bounds.height, bounds.width) * 0.5);
			var scale_x:Number = ((bounds.width == 0) ? 0 : (bounds.width - dist * 2) / bounds.width);
			var scale_y:Number = ((bounds.height == 0) ? 0 : (bounds.height - dist * 2) / bounds.height);
			{
				var _g:int = 0;
				while (_g < n)
				{
					var i:int = _g++;
					pt = points[i].clone();
					pt.x -= center_pt.x;
					pt.y -= center_pt.y;
					pt.x *= scale_x;
					pt.y *= scale_y;
					pt.x += center_pt.x;
					pt.y += center_pt.y;
					offset_pts.push(pt);
				}
			}
			return offset_pts;
		}
		
		public static function getCirclePolygon(center:Point, radius:Number = 0, sides:int = 5):Array
		{
			var res:Array = [];
			var ang:Number = 0;
			var ang_step:Number = Math.PI * 2 / sides;
			var pt:Point = new Point(0, 0 - radius);
			while (ang < Math.PI * 2)
			{
				res.push(pt.add(center));
				Geom.rotate(pt, ang_step);
				ang += ang_step;
			}
			return res;
		}
		
		protected static function lineAngle(line:*):Number
		{
			var a:Number = Math.atan2(line.p1y - line.p0y, line.p1x - line.p0x);
			if (a < 0.0001 && a > -0.0001)
				a = 0;
			return a;
		}
		
		protected static function lineLength(line:*):Number
		{
			var xlen:Number = line.p1x - line.p0x;
			var ylen:Number = line.p1y - line.p0y;
			return Math.sqrt(xlen * xlen + ylen * ylen);
		}
		
		public static function getCenters(polygons:Array):Array
		{
			var centers:Array = [];
			{
				var _g1:int = 0, _g:int = polygons.length;
				while (_g1 < _g)
				{
					var i:int = _g1++;
					centers.push(PolygonTools.getAverage(polygons[i]));
				}
			}
			return centers;
		}
		
		protected static function getAverage(points:Array):Point
		{
			var avg:Point = new Point();
			{
				var _g1:int = 0, _g:int = points.length;
				while (_g1 < _g)
				{
					var i:int = _g1++;
					avg.x += points[i].x;
					avg.y += points[i].y;
				}
			}
			if (points.length > 0)
			{
				avg.x /= points.length;
				avg.y /= points.length;
			}
			return avg;
		}
		
		public static function weld(points:Array, threshold:Number = 0):Array
		{
			if (points.length <= 3)
				return points;
			var old_points:Array = points;
			points = points.concat();
			var i:int = points.length - 1;
			var s_thresh:Number = threshold * threshold;
			var avg:Point;
			var pt:Point;
			while (i > 0)
			{
				i--;
				if (Geom.squaredDistanceBetween(points[i], points[i + 1]) <= s_thresh)
				{
					avg = PolygonTools.getAverage([points[i], points[i + 1]]);
					pt = points[i];
					pt.x = avg.x;
					pt.y = avg.y;
					points.splice(i + 1, 1);
				}
			}
			if (points.length > 1 && Geom.squaredDistanceBetween(points[1], points[points.length - 1]) <= s_thresh)
				points.pop();
			if (points.length >= 3)
				return points;
			return old_points;
		}
		
		public static function divideAtColinearPoints(polygons:Array):Array
		{
			var divider_points:Array = [];
			var i:int;
			var j:int = polygons.length;
			var k:int;
			var polygonA:Array;
			var polygonB:Array;
			var colinear_points:Array;
			while (j > 0)
			{
				j--;
				polygonA = polygons[j];
				PolygonTools.centerPt = PolygonTools.getAverage(polygonA);
				i = polygonA.length - 1;
				while (i > 0)
				{
					i--;
					var ptA:Point = polygonA[i];
					var ptB:Point = polygonA[i + 1];
					colinear_points = [];
					{
						var _g:int = 0;
						while (_g < polygons.length)
						{
							var polygonB1:Array = polygons[_g];
							++_g;
							if (polygonA != polygonB1)
							{
								k = polygonB1.length;
								while (k > 0)
								{
									k--;
									var test_pt:Point = polygonB1[k];
									if (!test_pt.equals(ptA) && !test_pt.equals(ptB) && Geom.pointIsOnSegment(ptA, ptB, test_pt))
									{
										var insert_pt:Point = polygonB1[k].clone();
										var exists:Boolean = false;
										{
											var _g1:int = 0;
											while (_g1 < divider_points.length)
											{
												var div_pt:Point = divider_points[_g1];
												++_g1;
												if (div_pt.equals(insert_pt))
												{
													exists = true;
													break;
												}
											}
										}
										if (!exists)
										{
											colinear_points.push(insert_pt);
											divider_points.push(insert_pt);
										}
									}
								}
							}
						}
					}
					while (colinear_points.length > 0)
						polygonA.insert(i + 1, colinear_points.pop());
				}
				polygonA.sort(PolygonTools.sortAlongLine);
				PolygonTools.weld(polygonA, 0.01);
			}
			return polygons;
		}
		
		public static function sortPolygonPoints(points:Array):void
		{
			PolygonTools.centerPt = PolygonTools.getAverage(points);
			points.sort(PolygonTools.sortAlongLine);
		}
		
		protected static function sortAlongLine(ptA:Point, ptB:Point):int
		{
			if (PolygonTools.centerPt != null)
			{
				var ang_A:Number = Geom.angleBetween(PolygonTools.centerPt, ptA);
				var ang_B:Number = Geom.angleBetween(PolygonTools.centerPt, ptB);
				if (ang_A < ang_B)
					return -1;
				if (ang_A > ang_B)
					return 1;
			}
			return 0;
		}
		
		public static function polygonWithinRectangle(polygon:Array, rect:Rectangle):Boolean
		{
			{
				var _g:int = 0;
				while (_g < polygon.length)
				{
					var point:Point = polygon[_g];
					++_g;
					if (point.x <= rect.left || point.y <= rect.top || point.x >= rect.right || point.y >= rect.bottom)
						return false;
				}
			}
			return true;
		}
	
	}
}
