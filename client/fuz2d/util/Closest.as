/**
* ...
* @author Default
* @version 0.1
*/

package fuz2d.util {
	
	import flash.geom.Point;

	import fuz2d.action.physics.*;
	import fuz2d.model.object.*;
	
	public class Closest {
		
		public static const EPSILON:Number = 0.00001;
		private static var csr:ClosestSegmentResult;
		
        /** Given three ints, return the one with the middle value. I.e., it
         *  is not the single largest or the single smallest. */
        private static function mid(a:Number, b:Number, c:Number):Number {
            if(a <= b) {
                if(b <= c)
                    return b;
                else if(c <= a)
                    return a;
                else
                    return c;
            }
            if(b >= c)
                return b;
            else if(c >= a)
                return a;
            else
                return c;
        }
		
		/* 
		* Given the coordinates of the endpoints of a line segment, and a
		* point, set res to be the closest point on the segment to the
		* given point. */
        public static function pointClosestTo(obj:Point, ptA:Point, ptB:Point):Point {
                
			var x1:Number = ptA.x >> 0;
			var y1:Number = ptA.y >> 0;
			
			var x2:Number = ptB.x >> 0;
			var y2:Number = ptB.y >> 0;			
			
            var dx:Number;
            var dy:Number;
            var res:Point = new Point();

            if (y1 == y2 && x1 == x2) {
                
                res.x = x1;
                res.y = y1;
 
            } else if (y1 == y2) {
                
                res.y = y1;
                res.x = mid(x1, x2, obj.x);
      
            } else if(x1 == x2) {
                
                res.x = x1;
                res.y = mid(y1, y2, obj.y);
    
            } else {
                
                dx = x2 - x1;
                dy = y2 - y1;
                
                res.x = dy * (dy * x1 - dx * (y1 - obj.y)) + dx * dx * obj.x;
                res.x = res.x / (dx * dx + dy * dy);
                res.y = (dx * (obj.x - res.x)) / dy + obj.y;
    
                if (x2 > x1) {
                    
                    if (res.x > x2) {
                        res.x = x2;
                        res.y = y2;
                    } else if (res.x < x1) {
                        res.x = x1;
                        res.y = y1;
                    }
                   
                } else {
                    
                    if (res.x < x2) {
                        res.x = x2;
                        res.y = y2;
                    } else if (res.x > x1) {
                        res.x = x1;
                        res.y = y1;
                    }
                    
                }
				 
            }

            return res;
            
        }
		
		//
		//
		public static function pointOnLineToPoint (p:Point, linePtA:Point, linePtB:Point, segmentClamp:Boolean = true):Point {
			
			var ap:Point = p.clone().subtract(linePtA);
			var ab:Point = linePtB.subtract(linePtA);
			
			var ab2:Number = ab.x * ab.x + ab.y * ab.y;
			var ap_ab:Number = ap.x * ab.x + ap.y * ab.y;
			var t:Number = ap_ab / ab2;
			
			if (segmentClamp) {
			
				if (t < 0) t = 0;
				if (t > 1) t = 1;
			
			}
			
			ap.x *= t;
			ap.y *= t;
			
			return linePtA.clone().add(ab);
			
		}
		
		//
		//
		public static function distanceFromLine (origin:Point, linePtA:Point, linePtB:Point):Number {
			
			var closestPoint:Point = pointOnLineToPoint(origin, linePtA, linePtB);
			
			return Point.distance(origin, closestPoint);
			
		}
		
		
		//
		//
		public static function ptPointSegment (p:Point, line:CollisionObject, segmentClamp:Boolean = true):Point {
			
			var ap:Point = p.subtract(line.a);
			var ab:Point = line.b.subtract(line.a);
			
			var ab2:Number = ab.x * ab.x + ab.y * ab.y;
			var ap_ab:Number = ap.x * ab.x + ap.y * ab.y;
			var t:Number = ap_ab / ab2;
			
			if (segmentClamp) {
			
				if (t < 0) t = 0;
				if (t > 1) t = 1;
			
			}
			
			ap.x *= t;
			ap.y *= t;
			
			return line.a.clone().add(ab);
			
		}
	
		//
		//
		public static function distPointSegment (p:Point, line:CollisionObject):Number {
			
			var d:Point = ptPointSegment(p, line);
			return d.subtract(p).length;
			
		}
		
		//
		//
		public static function sqDistPointSegment (p:Point, line:CollisionObject):Number {
			
			var d:Point = ptPointSegment(p, line);
			
			return (p.x - d.x) * (p.x - d.x) + (p.y - d.y) * (p.y - d.y);
			
		}
		
		//
		public static function clamp (n:Number, min:Number, max:Number):Number {
			
			if (n < min) return min;
			if (n > max) return max;
			return n;
			
		}
		
		//
		//
		public static function closestPtSegmentSegment (p1:Point, q1:Point, p2:Point, q2:Point):ClosestSegmentResult {
			
			var s:Number;
			var t:Number;
			var c1:Vector2d;
			var c2:Vector2d;
			var dist:Number;
			
			var d1:Vector2d = new Vector2d(q1.subtract(p1));
			var d2:Vector2d = new Vector2d(q2.subtract(p2));
			var r:Vector2d = new Vector2d(p1.subtract(p2));
			var a:Number = d1.getDotProduct(d1);
			var e:Number = d2.getDotProduct(d2);
			var f:Number = d2.getDotProduct(r);
			
			if (csr == null) csr = new ClosestSegmentResult();
			var res:ClosestSegmentResult = csr;
			
			if (a <= EPSILON && e <= EPSILON) {
				
				s = t = 0;
				c1 = new Vector2d(p1);
				c2 = new Vector2d(p2);
				dist = c1.getDifference(c2).getDotProduct(c1.getDifference(c2));
				
				res.init(c1, c2, dist, s, t);
				return res;
				
			}
			
			if (a <= EPSILON) {
				
				s = 0;
				t = f / e;
				t = clamp(t, 0, 1);
				
			} else {
				
				var c:Number = d1.getDotProduct(r);
				
				if (e <= EPSILON) {
					
					t = 0;
					s = clamp( -c / a, 0, 1);
					
				} else {
					
					var b:Number = d1.getDotProduct(d2);
					var denom:Number = a * e - b * b;
					
					if (denom != 0) s = clamp((b * f - c * e) / denom, 0, 1);
					else s = 0;
						
					t = (b * s + f) / e;
					
					if (t < 0) {
						
						t = 0;
						s = clamp( -c / a, 0, 1);
						
					} else if (t > 1) {
						
						t = 1;
						s = clamp((b - c) / a, 0, 1);
						
					}
					
				}
				
			}
			
			c1 = new Vector2d(p1);
			c2 = new Vector2d(p2);
			
			c1.addScaled(d1, s);
			c2.addScaled(d2, t);
			
			dist = c1.getDifference(c2).getDotProduct(c1.getDifference(c2));
			
			res.init(c1, c2, dist, s, t);
			return res;
			
		}
		
	}
	
}
