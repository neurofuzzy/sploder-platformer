package com.sploder.asui {
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;
    /**
    * ...
    * @author Default
    * @version 0.1
    */
    
    
    
    public class ColorTools {

        
        //
        public static function getRedComponent (color:Number):Number {
            return color >> 16;
        }
        
        //
        public static function getGreenComponent (color:Number):Number {
            return color >> 8 & 0xff;
        }
        
        //  
        public static function getBlueComponent (color:Number):Number {
            return color & 0xff;
        }
        
        //
        public static function getRedOffset (tintColor:Number, amount:Number):Number {
            var tintRed:Number = getRedComponent(tintColor);
            return tintRed * amount;
        }
        
        //
        public static function getGreenOffset (tintColor:Number, amount:Number):Number {
            var tintGreen:Number = getGreenComponent(tintColor);
            return tintGreen * amount;
        }
        
        //  
        public static function getBlueOffset (tintColor:Number, amount:Number):Number {
            var tintBlue:Number = getBlueComponent(tintColor);
            return tintBlue * amount;
        }
        
    
        public static function getTintedColor (baseColor:Number, tintColor:Number, amount:Number):Number {
        
            var red:Number = getRedComponent(baseColor);
            var green:Number = getGreenComponent(baseColor);
            var blue:Number = getBlueComponent(baseColor);
            
            var tintRed:Number= getRedComponent(tintColor);
            var tintGreen:Number = getGreenComponent(tintColor);
            var tintBlue:Number = getBlueComponent(tintColor);
            
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
		
        public static function getDesaturatedColor (color:Number):Number {
            
            var redLevel:Number = getRedComponent(color) / 255;
            var greenLevel:Number = getGreenComponent(color) / 255;
            var blueLevel:Number = getBlueComponent(color) / 255;
    
            var value:Number = (redLevel + greenLevel + blueLevel / 3) * 255;
            
            return (value) << 16 | (value) << 8 | (value);
            
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


		/** 
		* Convert RGB values to hexadecimal number
		* @param Number r  Red value
		* @param Number g  Green value
		* @param Number b  Blue value
		* @return Number   RGB as a hex value
		* @access public
		*/
		public static function rgb2hex ( r:Number, g:Number, b:Number ):Number {
			return ( r << 16 | g << 8 | b );
		}

		/**
		* Convert a hex number into rgb values
		* @param Number hex_col Hex colour to convert
		* @return Object   Object with r, g and b properties
		* @access public
		*/
		public static function hex2rgb ( hex_col:Number ):Object {
			
			var red:int   = hex_col >> 16;
			var green_blue:int = hex_col - ( red << 16 );
			var green:int  = green_blue >> 8 ;
			var blue:int   = green_blue - ( green << 8 );
			
			return ( { r:red, g:green, b:blue } );
			
		}

		/**
		* Convert a hex colour to HSV colour
		* @param Number hex_col Hex colour to convert
		* @return Object   Object with h, s and v properties
		* @return Object   Object with h, s and v properties
		* @access public
		*/
		public static function hex2hsv ( hex_col:Number ):Object {
			
			var rgb:Object = hex2rgb( hex_col );
			
			return rgb2hsv( rgb.r, rgb.g, rgb.b );
			
		}

		/**
		* Convert a set of HSV values to a hex colour
		* @param Number h  Hue value
		* @param Number s  Sautration value
		* @param Number v  'Value' value
		* @return Number   Hex colour to convert
		* @access public
		*/
		public static function hsv2hex ( hue:Number, sat:Number, val:Number ):Number {
			
			var rgb:Object = hsv2rgb( hue, sat, val );
			
			return rgb2hex( rgb.r, rgb.g, rgb.b );
			
		}

		/**
		* Convert HSB (also known as HSV values) to a hex values
		* @param Number h  Hue value
		* @param Number s  Sautration value
		* @param Number v  'Value' value
		* @return Object   Object with r, g and b properties
		* @access public
		*/
		public static function hsv2rgb ( hue:Number, sat:Number, val:Number ):Object {
			
			var red:Number;
			var grn:Number;
			var blu:Number;
			var i:Number;
			var f:Number;
			var p:Number;
			var q:Number;
			var t:Number;
			
			hue %= 360;
			if (val == 0) { return( { r:0, g:0, b:0 } ); }
			sat /= 100;
			val /= 100;
			hue /= 60;
			i = Math.floor(hue);
			f = hue-i;
			p = val*(1-sat);
			q = val*(1-(sat*f));
			t = val*(1-(sat*(1-f)));
			if (i==0) {red=val; grn=t; blu=p;}
			else if (i==1) {red=q; grn=val; blu=p;}
			else if (i==2) {red=p; grn=val; blu=t;}
			else if (i==3) {red=p; grn=q; blu=val;}
			else if (i==4) {red=t; grn=p; blu=val;}
			else if (i==5) {red=val; grn=p; blu=q;}
			red = Math.floor(red*255);
			grn = Math.floor(grn*255);
			blu = Math.floor(blu * 255);
			
			return ( { r:red, g:grn, b:blu } );
			
		}

		/** 
		* Convert RGB values to HSV value
		* @param Number r  Red value
		* @param Number g  Green value
		* @param Number b  Blue value
		* @return Object   Object with h, s and v properties
		* @access public
		*/
		public static function rgb2hsv ( red:Number, grn:Number, blu:Number ):Object {
			
			var x:Number;
			var f:Number;
			var i:int;
			
			var hue:Number;
			var sat:Number;
			var val:Number;
			
			red /= 255;
			grn /= 255;
			blu /= 255;
			
			x = Math.min(Math.min(red, grn), blu);
			val = Math.max(Math.max(red, grn), blu);
			if (x == val) { return( { h:0, s:0, v:val * 100 } ); }
			f = (red == x) ? grn-blu : ((grn == x) ? blu-red : red-grn);
			i = (red == x) ? 3 : ((grn == x) ? 5 : 1);
			
			hue = Math.floor((i - f / (val - x)) * 60) % 360;
			sat = Math.floor(((val - x) / val) * 100);
			val = Math.floor(val * 100);
			
			return( { h:hue, s:sat, v:val } );
			
		}
		
		public static function setColorValue (color:Number, value:int = 50):Number {
            
            var redLevel:Number = getRedComponent(color);
            var greenLevel:Number = getGreenComponent(color);
            var blueLevel:Number = getBlueComponent(color);
            
            var col:Object = rgb2hsv(redLevel, greenLevel, blueLevel);
			var col2:Object = hsv2rgb(col.h, col.s, value);
			
			return (col2.r) << 16 | (col2.g) << 8 | (col2.b);
            
        }
		
		public static function getHue (color:Number):Number {
            
            var redLevel:Number = getRedComponent(color);
            var greenLevel:Number = getGreenComponent(color);
            var blueLevel:Number = getBlueComponent(color);
            
            return rgb2hsv(redLevel, greenLevel, blueLevel).h;
            
        }
		
		public static function getSaturation (color:Number):Number {
            
            var redLevel:Number = getRedComponent(color);
            var greenLevel:Number = getGreenComponent(color);
            var blueLevel:Number = getBlueComponent(color);
            
            return rgb2hsv(redLevel, greenLevel, blueLevel).s;
            
        }
		
        public static function getValue (color:Number):Number {
            
            var redLevel:Number = getRedComponent(color);
            var greenLevel:Number = getGreenComponent(color);
            var blueLevel:Number = getBlueComponent(color);
            
            return rgb2hsv(redLevel, greenLevel, blueLevel).v;
            
        }
		

		
		//
		//
		public static function applyColor (obj:DisplayObject, color:Number):void {
			
			if (obj != null) {
				
				var c:ColorTransform = new ColorTransform();
				c.color = color;
				obj.transform.colorTransform = c;
			
			}
			
		}
    
    }
    
}
