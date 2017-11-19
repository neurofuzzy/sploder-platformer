/**
* ...
* @author Default
* @version 0.1
*/

package fuz2d.util {

	public class Faster {
		
		public static const PI:Number = Math.PI;
		//
		//
		public static function abs (val:Number):Number {
			if (val < 0) val = -val;
			return val
		}
		
		//
		//
		public static function floor (val:Number):int {
			
			return val >> 0;
			
		}
		
		//
		//
		public static function sin (x:Number):Number {

		   // clamp
		   if( x < -PI ) x += 2*PI else if( x > PI ) x -= 2*PI;
		   // approximate
		   var s:Number = (x - x * abs(x) / PI) * 4 / PI;
		   // adds correction
		   var fix:Number = s + .225 * (s * abs(s) - s);
		   // we're done !
		   return fix;
		}
		
		//
		//
		public static function cos (x:Number):Number {
			return sin(x + PI / 2);
		}
		
	}
	
}
