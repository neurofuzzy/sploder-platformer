/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.util {
	
	import flash.geom.Point;
	import fuz2d.model.object.Point2d;

	public class Geom2d {
		
		public static const PI:Number = Math.PI;
		public static const TWOPI:Number = Math.PI * 2;
		public static const HALFPI:Number = Math.PI * 0.5;
		
		// translate between angle units
		private static var _dtr:Number = Math.PI / 180;
		private static var _rtd:Number = 180 / Math.PI;
		
		//
		//
		public static function angleBetween (pt1:Point2d, pt2:Point2d):Number {

			return Math.atan2(pt2.worldY - pt1.worldY, pt2.worldX - pt1.worldX);
			
		}
		
		//
		//
		public static function distanceBetween (a:Point2d, b:Point2d):Number {
			
			if (a.parentObject == b.parentObject) {
				
				return Math.sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y));
				
			} else {
			
				return Math.sqrt((a.worldX - b.worldX) * (a.worldX - b.worldX) + (a.worldY - b.worldY) * (a.worldY - b.worldY));
				
			}
			
		}
		
		//
		//
		public static function squaredDistanceBetween (a:Point2d, b:Point2d):Number {
			
			if (a.parentObject == b.parentObject) {
				
				return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y);
				
			} else {
			
				return (a.worldX - b.worldX) * (a.worldX - b.worldX) + (a.worldY - b.worldY) * (a.worldY - b.worldY);
				
			}
			
		}
		
		//
		//
		public static function horizontalDistanceBetweenPoints (pt1:Point, pt2:Point):Number {
			
			return Math.abs(pt2.x - pt1.x);
			
		}	
		
		//
		//
		public static function angleBetweenPoints (pt1:Point, pt2:Point):Number {

			return Math.atan2(pt2.y - pt1.y, pt2.x - pt1.x);
			
		}
		
		//
		//
		public static function distanceBetweenPoints (pt1:Point, pt2:Point):Number {
			
			return Math.sqrt((pt2.x - pt1.x) * (pt2.x - pt1.x) + (pt2.y - pt1.y) * (pt2.y - pt1.y));
			
		}
		
		
		//
        //
        //
        public static function squaredDistanceBetweenPoints (pt1:Point, pt2:Point):Number {
    
            return (pt2.x - pt1.x) * (pt2.x - pt1.x) + (pt2.y - pt1.y) * (pt2.y - pt1.y);
    
        }
		
		//
		public static function get dtr ():Number {
			return _dtr;
		}
		
		//
		public static function get rtd ():Number {
			return _rtd;
		}
		
		//
		//
		public static function rotate (pt:Point2d, angle:Number = 0):Point2d {
			
			pt = pt.copy;
			
			var ox:Number = pt.x;
			var oy:Number = pt.y;
			
			var sa:Number = Math.sin(0 - angle);
			var ca:Number = Math.cos(0 - angle);
			
			pt.x = ca * ox - sa * oy;
			pt.y = sa * ox + ca * oy;
			
			return pt;
			
		}
		
		//
		//
		public static function rotatePoint (pt:Point, angle:Number):void {
			
			var ox:Number = pt.x;
			var oy:Number = pt.y;
			
			var sa:Number = Math.sin(angle);
			var ca:Number = Math.cos(angle);
			
			pt.x = ca * ox - sa * oy;
			pt.y = sa * ox + ca * oy;			
			
		}
		
		//
		//
		public static function rotatePointComputedAngle (pt:Point, angleSin:Number, angleCos:Number):void {
			
			var ox:Number = pt.x;
			var oy:Number = pt.y;
			
			pt.x = angleCos * ox - angleSin * oy;
			pt.y = angleSin * ox + angleCos * oy;			
			
		}
		
		//
		//
		public static function isConvex (p:Array):Boolean {

			
			return (getArea(p) > 0) ? true : false;
			
		}
		
		//
		//
		public static function getArea (p:Array):Number {
			
			if (p.length > 2) {
				
				var area:Number = 0;
			
				var n:int = p.length;
				
				for (var i:int = 1; i <= n - 2; i++) {
					
					area += p[i].x * (p[i+1].y - p[i-1].y);
					
				}
				
				area += p[p.length - 1].x * (p[0].y - p[p.length - 2].y);
				area += p[0].x * (p[1].y - p[p.length - 1].y);
				
				return area;
				
			}
			
			return 0;
			
		}
		
		//
        //
        //
        public static function lerp (a:Number, b:Number, t:Number):Number {
            return a + (b - a) * t;
        }
		
        //
        //
        //
        public static function intersectCircleLine (cx:Number, cy:Number, r:Number, x1:Number, y1:Number, x2:Number, y2:Number):Point {
            
            var result:String;
            
            var a:Number = (x2-x1)*(x2-x1)+(y2-y1)*(y2-y1);
            var b:Number = 2*((x2-x1)*(x1-cx)+(y2-y1)*(y1-cy));
            var cc:Number = cx*cx+cy*cy+x1*x1+y1*y1-2*(cx*x1+cy*y1)-r*r;
            var d:Number = b*b-4*a*cc;
            
            var ipoint:Point;
            
            if (d < 0) {
                result = "Outside";
            } else if (d == 0) {
                result = "Tangent";
            } else {
                var e:Number = Math.sqrt(d);
                var u1:Number = (-b+e)/(2*a);
                var u2:Number = (-b-e)/(2*a);
                if ((u1<0 || u1>1) && (u2<0 || u2>1)) {
                    if ((u1<0 && u2<0) || (u1>1 && u2>1)) {
                        return null;
                    } else {
                        return null;
                    }
                } else {
                    ipoint = new Point();
                    ipoint.x = 0;
                    ipoint.y = 0;
                    if (0<=u2 && u2<=1) {
                        ipoint.x = lerp(x1,x2,u2);
                        ipoint.y = lerp(y1,y2,u2);
                        return ipoint;
                    }
                    if (0<=u1 && u1<=1) {
                        ipoint.x = lerp(x1,x2,u1);
                        ipoint.y = lerp(y1,y2,u1);
                        return ipoint;
                    }
                    return null;
                }
            }
            
            return ipoint;
            
        };
		
		//
		//
		//
		public static function twoLinesIntersect (a1x:Number, a1y:Number, a2x:Number, a2y:Number, b1x:Number, b1y:Number, b2x:Number, b2y:Number):Boolean {
			
			var ua_t:Number = (b2x-b1x) * (a1y-b1y) - (b2y-b1y) * (a1x-b1x);
			var ub_t:Number = (a2x-a1x) * (a1y-b1y) - (a2y-a1y) * (a1x-b1x);
			var u_b:Number = (b2y-b1y) * (a2x-a1x) - (b2x-b1x) * (a2y-a1y);

			if ( u_b != 0 ) {
				
				var ua:Number = ua_t / u_b;
				var ub:Number = ub_t / u_b;

				if ( 0 <= ua && ua <= 1 && 0 <= ub && ub <= 1 ) {

					return true;
					
				} else {
					
					return false;
					
				}
				
			} else {
				
				return false;
				
			}
			
		}
		
		//
		//
		//
	    public static function intersectLineLine(a1x:Number, a1y:Number, a2x:Number, a2y:Number, b1x:Number, b1y:Number, b2x:Number, b2y:Number):Point {
	
			var ua_t:Number = (b2x-b1x) * (a1y-b1y) - (b2y-b1y) * (a1x-b1x);
			var ub_t:Number = (a2x-a1x) * (a1y-b1y) - (a2y-a1y) * (a1x-b1x);
			var u_b:Number = (b2y-b1y) * (a2x-a1x) - (b2x-b1x) * (a2y-a1y);
	
	
			if ( u_b != 0 ) {
				
				var ua:Number = ua_t / u_b;
				var ub:Number = ub_t / u_b;
	
				if ( 0 <= ua && ua <= 1 && 0 <= ub && ub <= 1 ) {
						
					return new Point(a1x + ua * (a2x - a1x), a1y + ua * (a2y - a1y));
		
				} else {
						
					return null;
						
				}
			
			} else {
					
				return null;
					
			}
			
	    }
		
		//
		//
		//
	    public static function constrainLineByLine(a1x:Number, a1y:Number, a2x:Number, a2y:Number, b1x:Number, b1y:Number, b2x:Number, b2y:Number):Object {
	
			var ua_t:Number = (b2x-b1x) * (a1y-b1y) - (b2y-b1y) * (a1x-b1x);
			var ub_t:Number = (a2x-a1x) * (a1y-b1y) - (a2y-a1y) * (a1x-b1x);
			var u_b:Number = (b2y-b1y) * (a2x-a1x) - (b2x-b1x) * (a2y-a1y);
	
	
			if ( u_b != 0 ) {
				
				var ua:Number = ua_t / u_b;
				var ub:Number = ub_t / u_b;
	
				if ( 0 <= ua && ua <= 1 && 0 <= ub && ub <= 1 ) {
						
					return { x: a1x + ua * (a2x - a1x), y: a1y + ua * (a2y - a1y) };
		
				} else {
						
					return { x: a1x, y: a1y };
						
				}
			
			} else {
					
				return { x: a1x, y: a1y };
					
			}
			
	    }
		
		//
		//
		public static function normalizeRotation (pt:Point2d):void {
			
			if (pt.rotation != 0) pt.rotation = normalizeAngle(pt.rotation);

		}
		
		//
		//
		public static function clearRotation (pt:Point2d):void {
			
			pt.rotation = 0;
			
		}
		
		//
		//
		public static function normalizeAngle (angle:Number):Number {
			
			if (angle > PI) {
				angle -= TWOPI;
			} else if (angle < 0 - PI) {
				angle += TWOPI;
			}
			
			return angle;
				
		}

		//
		//
		public static function constrainAngle (angle:Number, min:Number, max:Number):Number {

			angle = normalizeAngle(angle);
			
			if (max < min) {
				var temp:Number = max;
				max = min;
				min = temp;
			}
			
			if (angle > max) {
				angle = max;
			} else if (angle < min) {
				angle = min;
			}
			
			return angle;
		
		}
		
        //
        //
        //
        public static function lineWithinBounds (minx:Number, miny:Number, maxx:Number, maxy:Number, p1x:Number, p1y:Number, p2x:Number, p2y:Number):Boolean {
            
            if (p1x > minx && p1x < maxx && p2x > minx && p2x < maxx && p1y > miny && p1y < maxy && p2y > miny && p2y < maxy) {
                
                return true;
                
            } else {
                
                return false;
                
            }
            
        }
	
	}
	
}
