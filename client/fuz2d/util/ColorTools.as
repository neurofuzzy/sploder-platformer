/**
* ...
* @author Default
* @version 0.1
*/

package fuz2d.util {

	public class ColorTools {
		
		//
		public static function getRedComponent (color:uint):uint {
			return color >> 16;
		}
		
		//
		public static function getGreenComponent (color:uint):uint {
			return color >> 8 & 0xff;
		}
		
		//	
		public static function getBlueComponent (color:uint):uint {
			return color & 0xff;
		}
		
		//
		public static function getRedOffset (tintColor:uint, amount:Number):Number {
			var tintRed:uint = getRedComponent(tintColor);
			return tintRed * amount;
		}
		
		//
		public static function getGreenOffset (tintColor:uint, amount:Number):Number {
			var tintGreen:uint = getGreenComponent(tintColor);
			return tintGreen * amount;
		}
		
		//	
		public static function getBlueOffset (tintColor:uint, amount:Number):Number {
			var tintBlue:uint = getBlueComponent(tintColor);
			return tintBlue * amount;
		}
		

		public static function getTintedColor (baseColor:uint, tintColor:uint, amount:Number):uint {
		
			var red:uint= getRedComponent(baseColor);
			var green:uint = getGreenComponent(baseColor);
			var blue:uint = getBlueComponent(baseColor);
			
			var tintRed:uint= getRedComponent(tintColor);
			var tintGreen:uint = getGreenComponent(tintColor);
			var tintBlue:uint = getBlueComponent(tintColor);
			
			return (red + (tintRed - red) * amount) << 16 | (green + (tintGreen - green) * amount) << 8 | (blue + (tintBlue - blue) * amount);
			
		}
		
        public static function getInverseColor (baseColor:Number):Number {
        
            var red:Number = getRedComponent(baseColor);
            var green:Number = getGreenComponent(baseColor);
            var blue:Number = getBlueComponent(baseColor);
            
            return (255 - red) << 16 | (255 - green) << 8 | (255 - blue);
            
        }
        
        public static function getBrightness (color:Number):Number {
            
            var redLevel:Number = getRedComponent(color);
            var greenLevel:Number = getGreenComponent(color);
            var blueLevel:Number = getBlueComponent(color);
            
            return Math.floor((redLevel + greenLevel + blueLevel) / 3);
            
        }
        
        public static function getSaturatedColor (color:Number, amount:Number):Number {
            
            amount = amount / 100;
    
            var redLevel:Number = getRedComponent(color) / 255;
            var greenLevel:Number = getGreenComponent(color) / 255;
            var blueLevel:Number = getBlueComponent(color) / 255;
    
            var red:Number = interpolate(0.5, redLevel, amount) * 255;
            var green:Number = interpolate(0.5, greenLevel, amount) * 255;
            var blue:Number = interpolate(0.5, blueLevel, amount) * 255;
            
            return (red) << 16 | (green) << 8 | (blue);
            
        }
        
        private static function interpolate (luma:Number, comp:Number, t:Number):Number {
            
            return Math.min(1, Math.max(0, luma + (comp - luma) * t));
            
        }
        
        public static function numberToHTMLColor (col:Number):String {
            
            var c:String = col.toString(16);
            while (c.length < 6) c = "0" + c;
            return "#" + c;
            
        }
        
        public static function HTMLColorToNumber (html:String):Number {
            
            return parseInt("0x" + html.split("#").join("").split("0x").join(""), 16);
            
        }
		
	}
	
}
