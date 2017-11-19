package com.sploder.geom {
	
	import com.sploder.builder.CreatorPlayfieldObject;
	
	import flash.display.Sprite;
	import flash.geom.Point;

	public class Geom2d {
		
		public static const PI:Number = Math.PI;
		public static const TWOPI:Number = Math.PI * 2;
		public static const HALFPI:Number = Math.PI * 0.5;
		
		// translate between angle units
		private static var _dtr:Number = Math.PI / 180;
		private static var _rtd:Number = 180 / Math.PI;
		
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
        public static function intersectLineLine(a1x:Number, a1y:Number, a2x:Number, a2y:Number, b1x:Number, b1y:Number, b2x:Number, b2y:Number):Object {
    
            var ua_t:Number = (b2x-b1x) * (a1y-b1y) - (b2y-b1y) * (a1x-b1x);
            var ub_t:Number = (a2x-a1x) * (a1y-b1y) - (a2y-a1y) * (a1x-b1x);
            var u_b:Number = (b2y-b1y) * (a2x-a1x) - (b2x-b1x) * (a2y-a1y);
    
    
            if ( u_b != 0 ) {
                
                var ua:Number = ua_t / u_b;
                var ub:Number = ub_t / u_b;
    
                if ( 0 <= ua && ua <= 1 && 0 <= ub && ub <= 1 ) {
                    
                    return { x: a1x + ua * (a2x - a1x), y: a1y + ua * (a2y - a1y) };
    
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
        public static function lineWithinBounds (minx:Number, miny:Number, maxx:Number, maxy:Number, p1x:Number, p1y:Number, p2x:Number, p2y:Number):Boolean {
            
            if (p1x > minx && p1x < maxx && p2x > minx && p2x < maxx && p1y > miny && p1y < maxy && p2y > miny && p2y < maxy) {
                
                return true;
                
            } else {
                
                return false;
                
            }
            
        }
        
        //
        //
        //
        public static function getPointAtVector (from_x:Number, from_y:Number, atdegrees:Number, atdistance:Number):Object {
            
            if (isNaN(from_x)) {
                from_x = from_y = 0;
            }
            
            atdegrees %= 360;
            atdistance = Math.abs(atdistance);
            
            var new_x:Number = from_x + atdistance * Math.sin((90 - atdegrees) * Math.PI/180);
            var new_y:Number = from_y + atdistance * Math.cos((90 - atdegrees) * Math.PI/180);
            
            return {x: new_x, y: new_y};
            
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
        public static function intersectCircleLine (cx:Number, cy:Number, r:Number, x1:Number, y1:Number, x2:Number, y2:Number):Boolean {
            
            var result:String;
            
            var a:Number = (x2-x1)*(x2-x1)+(y2-y1)*(y2-y1);
            var b:Number = 2*((x2-x1)*(x1-cx)+(y2-y1)*(y1-cy));
            var cc:Number = cx*cx+cy*cy+x1*x1+y1*y1-2*(cx*x1+cy*y1)-r*r;
            var d:Number = b*b-4*a*cc;
            
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
                        return false;
                    } else {
                        return true;
                    }
                } else {
                    return true;
                }
            }
            
            return false;
            
        };
        
        //
        //
        //
        public static function getIntersectCircleLine (cx:Number, cy:Number, r:Number, x1:Number, y1:Number, x2:Number, y2:Number):Point {
            
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
                    return ipoint;
                }
            }
            
            return ipoint;
            
        };
    
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
        public static function pointClosestTo(obj:CreatorPlayfieldObject, x1:Number, y1:Number, x2:Number, y2:Number):Point {
                
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
        //
        public static function getAngle (x1:Number, y1:Number, x2:Number, y2:Number):Number {
            
            var x:Number,
                y:Number,
                a:Number;
                
            x = x1 - x2;
            y = y1 - y2;
            
            if (x > 0) {
                a = (180/Math.PI) * Math.atan(y/x);
            } else if (x < 0) {
                a = ((180/Math.PI) * Math.atan(y/x)) - 180;
            } else {
                // prevent divide by zero
                a = (180/Math.PI) * Math.atan(y/0.00000000000000001);
            }
            
            //rotation = Math.floor(a);
            return a;
            
        }
        
        
        //
        //
        //
        public static function normalizeAngle (angle:Number):Number {
            
            angle %= 360;
            
            if (angle > 180) {
             angle -= 360 ;
            } else if (angle <= -180 ) {
             angle += 360;
            }
            
            return angle;
            
        }
    
        
        
        //
        //
        //
        public static function pointAtMouse (obj:Sprite):Number {
            
            var a:Number = getAngle(obj.parent.mouseX, obj.parent.mouseY, obj.x, obj.y);
            obj.rotation = a;
            return (Math.PI/180) * obj.rotation;
            
        }
    
        
        //
        //
        //
        public static function pointAtPoint (obj:Sprite, x:Number, y:Number):Number {
            
            var a:Number = getAngle(x, y, obj.x, obj.y);
            obj.rotation = a;
            return (Math.PI/180) * obj.rotation;
            
        }
		
        //
        //
        //
        public static function distanceBetween (obj1:CreatorPlayfieldObject, obj2:CreatorPlayfieldObject):Number {
    
            return Math.abs(Math.sqrt(Math.pow(obj1.x - obj2.x, 2) + Math.pow(obj1.y - obj2.y, 2))) - obj1.radius - obj2.radius;
    
        }
		
		//
        //
        //
        public static function squaredDistanceBetween (obj1:Object, obj2:Object):Number {
    
            return Math.abs(Math.pow(obj1.x - obj2.x, 2) + Math.pow(obj1.y - obj2.y, 2));
    
        }
        
        //
        //
        //
        public static function distanceBetweenPoints (obj1:Object, obj2:Object):Number {
    
            return Math.abs(Math.sqrt(Math.pow(obj1.x - obj2.x, 2) + Math.pow(obj1.y - obj2.y, 2)));
    
        }
        
        
        //
        //
        //
        public static function angleBetween (obj1:Sprite, obj2:Sprite):Number {
    
            return getAngle(obj1.x, obj1.y, obj2.x, obj2.y);
            
        }
        
        //
        //
        //
        public static function angleBetweenPoints (obj1:Object, obj2:Object):Number {
    
            return getAngle(obj1.x, obj1.y, obj2.x, obj2.y);
            
        }
           
		
	}
	
}