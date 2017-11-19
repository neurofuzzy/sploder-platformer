package com.sploder.texturegen_internal.util
{
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.Matrix;
	
	public class Geom
	{
		public static var DTR:Number = 0.0174532925;
		public static var RTD:Number = 57.2957795;
		
		public static function angleBetween(pt1:Point, pt2:Point):Number
		{
			var a:Number = Math.atan2(pt2.y - pt1.y, pt2.x - pt1.x);
			if (a < 0.0001 && a > -0.0001)
				a = 0;
			return a;
		}
		
		public static function normalizeAngle(a:Number):Number
		{
			var p:Number = Math.PI;
			var hp:Number = p * 0.5;
			while (a <= -hp)
				a += p;
			while (a > hp)
				a -= p;
			return a;
		}
		
		public static function distanceBetween(pt1:Point, pt2:Point):Number
		{
			var xlen:Number = pt2.x - pt1.x;
			var ylen:Number = pt2.y - pt1.y;
			return Math.sqrt(xlen * xlen + ylen * ylen);
		}
		
		public static function squaredDistanceBetween(pt1:Point, pt2:Point):Number
		{
			var xlen:Number = pt2.x - pt1.x;
			var ylen:Number = pt2.y - pt1.y;
			return xlen * xlen + ylen * ylen;
		}
		
		public static function rotate(pt:Point, angle:Number):void
		{
			var ox:Number = pt.x;
			var oy:Number = pt.y;
			var sa:Number = Math.sin(angle);
			var ca:Number = Math.cos(angle);
			pt.x = ca * ox - sa * oy;
			pt.y = sa * ox + ca * oy;
		}
		
		public static function pointScaledBy(a:Point, b:Number):Point
		{
			return new Point(a.x * b, a.y * b);
		}
		
		public static function pointAddedBy(a:Point, b:Point):Point
		{
			return new Point(a.x + b.x, a.y + b.y);
		}
		
		public static function pointSubtractedBy(a:Point, b:Point):Point
		{
			return new Point(a.x - b.x, a.y - b.y);
		}
		
		public static function pointCrossedBy(a:Point, b:Point):Number
		{
			return a.x * b.y - b.x * a.y;
		}
		
		public static function pointDottedBy(a:Point, b:Point):Number
		{
			return a.x * b.x + a.y * b.y;
		}
		
		public static function pointMagnitude(pt:Point):Number
		{
			return Math.sqrt(pt.x * pt.x + pt.y * pt.y);
		}
		
		public static function pointNormalized(pt:Point, scale:Number = 1.0):Point
		{
			return Geom.pointScaledBy(pt, Geom.pointMagnitude(pt) * scale);
		}
		
		public static function normalize(pt:Point, scale:Number = 1.0):void
		{
			var len:Number = 1 / Math.sqrt(pt.x * pt.x + pt.y * pt.y);
			pt.x *= len * scale;
			pt.y *= len * scale;
		}
		
		public static function crossProductLinePoint(a:Point, b:Point, pt:Point):Number
		{
			return (b.x - a.x) * (pt.y - a.y) - (b.y - a.y) * (pt.x - a.x);
		}
		
		public static function pointIsOnSegment(ptA:Point, ptB:Point, testPt:Point):Boolean
		{
			var crossproduct:Number = (testPt.y - ptA.y) * (ptB.x - ptA.x) - (testPt.x - ptA.x) * (ptB.y - ptA.y);
			if (Math.abs(crossproduct) > 0.000000001)
				return false;
			var dotproduct:Number = (testPt.x - ptA.x) * (ptB.x - ptA.x) + (testPt.y - ptA.y) * (ptB.y - ptA.y);
			if (dotproduct < 0)
				return false;
			var squaredlengthba:Number = (ptB.x - ptA.x) * (ptB.x - ptA.x) + (ptB.y - ptA.y) * (ptB.y - ptA.y);
			if (dotproduct > squaredlengthba)
				return false;
			return true;
		}
		
		public static function gridPointsThatIntersectLine(ptA:Point, ptB:Point, gridScale:Number = 1, occludeEnds:Boolean = false):Array
		{
			ptA = ptA.clone();
			var igs:Number = 1 / gridScale;
			ptA.x *= igs;
			ptA.y *= igs;
			ptB = ptB.clone();
			ptB.x *= igs;
			ptB.y *= igs;
			var cells:Array = [];
			var dx:Number = ptB.x - ptA.x;
			var dy:Number = ptB.y - ptA.y;
			var pt:Point;
			var dpt:Point;
			var i:int;
			var b:Number;
			var g:int;
			var og:int = -100000;
			var reversed:Boolean = false;
			if (Math.abs(dx) > Math.abs(dy))
			{
				if (dy == 0)
					dpt = new Point(1, 0);
				else
					dpt = new Point(1, dy / dx);
				var sx:int;
				var ex:int;
				var rsy:int;
				var rey:int;
				if (ptA.x <= ptB.x)
				{
					sx = (ptA.x);
					ex = (ptB.x);
					pt = new Point(ptA.x, ptA.y);
					b = ptA.x - Math.ceil(ptA.x);
					rsy = (ptA.y);
					rey = (ptB.y);
				}
				else
				{
					sx = (ptB.x);
					ex = (ptA.x);
					pt = new Point(ptB.x, ptB.y);
					b = ptB.x - Math.ceil(ptB.x);
					rsy = (ptB.y);
					rey = (ptA.y);
					reversed = true;
				}
				pt.x = sx;
				b *= dpt.y;
				pt.y -= b;
				pt.y -= dpt.y;
				{
					var _g1:int = sx, _g:int = ex + 1;
					while (_g1 < _g)
					{
						var i1:int = _g1++;
						pt.x += 1;
						pt.y += dpt.y;
						g = (pt.y);
						if (i1 > sx && og != g && i1 < ex)
						{
							if (og < g)
								cells.push(new Point(pt.x - 1, g - 1));
							else
								cells.push(new Point(pt.x - 1, g + 1));
						}
						else if (i1 == sx && rsy != g)
						{
							if (rsy < g)
								cells.push(new Point(pt.x - 1, g - 1));
							else
								cells.push(new Point(pt.x - 1, g + 1));
						}
						else if (i1 == ex && og != rey)
						{
							if (og != -100000)
								cells.push(new Point(pt.x - 1, og));
						}
						if (i1 != ex)
							cells.push(new Point(pt.x - 1, g));
						else
							cells.push(new Point(pt.x - 1, rey));
						og = g;
					}
				}
			}
			else
			{
				if (dy == 0)
					dpt = new Point(0, 1);
				else
					dpt = new Point(dx / dy, 1);
				var sy:int;
				var ey:int;
				var rsx:int;
				var rex:int;
				if (ptA.y <= ptB.y)
				{
					sy = (ptA.y);
					ey = (ptB.y);
					pt = new Point(ptA.x, ptA.y);
					b = ptA.y - Math.ceil(ptA.y);
					rsx = (ptA.x);
					rex = (ptB.x);
				}
				else
				{
					sy = (ptB.y);
					ey = (ptA.y);
					pt = new Point(ptB.x, ptB.y);
					b = ptB.y - Math.ceil(ptB.y);
					rsx = (ptB.x);
					rex = (ptA.x);
					reversed = true;
				}
				pt.y = sy;
				b *= dpt.x;
				pt.x -= b;
				pt.x -= dpt.x;
				{
					var _g11:int = sy, _g2:int = ey + 1;
					while (_g11 < _g2)
					{
						var i2:int = _g11++;
						pt.x += dpt.x;
						pt.y += 1;
						g = (pt.x);
						if (i2 > sy && og != g && i2 < ey)
						{
							if (og < g)
								cells.push(new Point(g - 1, pt.y - 1));
							else
								cells.push(new Point(g + 1, pt.y - 1));
						}
						else if (i2 == sy && rsx != g)
						{
							if (rsx < g)
								cells.push(new Point(g - 1, pt.y - 1));
							else
								cells.push(new Point(g + 1, pt.y - 1));
						}
						else if (i2 == ey && og != rex)
							cells.push(new Point(rex, pt.y - 1));
						if (i2 != ey)
							cells.push(new Point(g, pt.y - 1));
						else
							cells.push(new Point(rex, pt.y - 1));
						og = g;
					}
				}
			}
			if (occludeEnds)
			{
				cells.shift();
				cells.pop();
			}
			if (reversed)
				cells.reverse();
			return cells;
		}
		
		public static function createMatrixBox(m:Matrix, scaleX:Number = 1.0, scaleY:Number = 1.0, rotation:Number = 0, tx:Number = 0, ty:Number = 0):void
		{
			m.a = scaleX;
			m.d = scaleY;
			m.b = rotation;
			m.tx = tx;
			m.ty = ty;
		}
		
		protected static function mid(a:Number, b:Number, c:Number):Number
		{
			if (a <= b)
			{
				if (b <= c)
					return b;
				else if (c <= a)
					return a;
				else
					return c;
			}
			if (b >= c)
				return b;
			else if (c >= a)
				return a;
			else
				return c;
			return 0.;
		}
		
		public static function closestPointOnLineToObj(obj:Point, ptA:Point, ptB:Point):Point
		{
			var x1:Number = ptA.x;
			var y1:Number = ptA.y;
			var x2:Number = ptB.x;
			var y2:Number = ptB.y;
			var dx:Number;
			var dy:Number;
			var res:Point = new Point();
			if (y1 == y2 && x1 == x2)
			{
				res.x = x1;
				res.y = y1;
			}
			else if (y1 == y2)
			{
				res.y = y1;
				res.x = Geom.mid(x1, x2, obj.x);
			}
			else if (x1 == x2)
			{
				res.x = x1;
				res.y = Geom.mid(y1, y2, obj.y);
			}
			else
			{
				dx = x2 - x1;
				dy = y2 - y1;
				res.x = dy * (dy * x1 - dx * (y1 - obj.y)) + dx * dx * obj.x;
				res.x = res.x / (dx * dx + dy * dy);
				res.y = dx * (obj.x - res.x) / dy + obj.y;
				if (x2 > x1)
				{
					if (res.x > x2)
					{
						res.x = x2;
						res.y = y2;
					}
					else if (res.x < x1)
					{
						res.x = x1;
						res.y = y1;
					}
				}
				else if (res.x < x2)
				{
					res.x = x2;
					res.y = y2;
				}
				else if (res.x > x1)
				{
					res.x = x1;
					res.y = y1;
				}
			}
			return res;
		}
		
		public static function intersectLineLine(a1x:Number, a1y:Number, a2x:Number, a2y:Number, b1x:Number, b1y:Number, b2x:Number, b2y:Number):Point
		{
			var ua_t:Number = (b2x - b1x) * (a1y - b1y) - (b2y - b1y) * (a1x - b1x);
			var ub_t:Number = (a2x - a1x) * (a1y - b1y) - (a2y - a1y) * (a1x - b1x);
			var u_b:Number = (b2y - b1y) * (a2x - a1x) - (b2x - b1x) * (a2y - a1y);
			if (u_b != 0)
			{
				var ua:Number = ua_t / u_b;
				var ub:Number = ub_t / u_b;
				if (0 <= ua && ua <= 1 && 0 <= ub && ub <= 1)
					return new Point(a1x + ua * (a2x - a1x), a1y + ua * (a2y - a1y));
				else
					return null;
			}
			else
				return null;
			return null;
		}
		
		public static function boundingBox(points:Array):Rectangle
		{
			var rect:Rectangle = new Rectangle();
			rect.x = rect.y = 100000000;
			rect.width = rect.height = -10000000;
			{
				var _g:int = 0;
				while (_g < points.length)
				{
					var point:Point = points[_g];
					++_g;
					rect.x = Math.min(rect.x, point.x);
					rect.y = Math.min(rect.y, point.y);
					rect.width = Math.max(rect.width, point.x);
					rect.height = Math.max(rect.height, point.y);
				}
			}
			rect.width -= rect.x;
			rect.height -= rect.y;
			return rect;
		}
	
	}
}
