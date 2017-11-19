package com.sploder.texturegen_internal.util
{
	import flash.geom.ColorTransform;
	
	public class ColorTools
	{
		public static function getRedComponent(color:int):int
		{
			return color >> 16;
		}
		
		public static function getGreenComponent(color:int):int
		{
			return color >> 8 & 255;
		}
		
		public static function getBlueComponent(color:int):int
		{
			return color & 255;
		}
		
		public static function addColors(colorA:int, colorB:int):int
		{
			var m:* = Math;
			var red:int = m.floor(m.min(255, getRedComponent(colorA) + getRedComponent(colorB)));
			var green:int = m.floor(m.min(255, getGreenComponent(colorA) + getGreenComponent(colorB)));
			var blue:int = m.floor(m.min(255, getBlueComponent(colorA) + getBlueComponent(colorB)));
			return (red << 16 | green << 8) | blue;
		}
		
		public static function subtractColors(colorA:int, colorB:int):int
		{
			var m:* = Math;
			var red:int = m.floor(m.max(0, getRedComponent(colorA) - (255 - getRedComponent(colorB))));
			var green:int = m.floor(m.max(0, getGreenComponent(colorA) - (255 - getGreenComponent(colorB))));
			var blue:int = m.floor(m.max(0, getBlueComponent(colorA) - (255 - getBlueComponent(colorB))));
			return (red << 16 | green << 8) | blue;
		}
		
		public static function getBrightness(color:int):int
		{
			var redLevel:int = getRedComponent(color);
			var greenLevel:int = getGreenComponent(color);
			var blueLevel:int = getBlueComponent(color);
			return Math.floor((redLevel + greenLevel + blueLevel) / 3);
		}
		
		public static function getTintedColor(baseColor:int, tintColor:int, amount:Number):int
		{
			var new_color:int = 0;
			if (amount <= 0)
				new_color = baseColor;
			else if (amount >= 1)
				new_color = tintColor;
			else
			{
				var red:int = getRedComponent(baseColor);
				var green:int = getGreenComponent(baseColor);
				var blue:int = getBlueComponent(baseColor);
				var tintRed:int = getRedComponent(tintColor);
				var tintGreen:int = getGreenComponent(tintColor);
				var tintBlue:int = getBlueComponent(tintColor);
				var m:* = Math;
				new_color = ((m.floor(red + (tintRed - red) * amount) << 16 | m.floor(green + (tintGreen - green) * amount) << 8) | m.floor(blue + (tintBlue - blue) * amount));
			}
			return new_color;
		}
		
		public static function getTintedColorSubtracted(colorA:int, colorB:int, amount:Number):int
		{
			var m:* = Math;
			var red:int = m.floor(m.max(0, getRedComponent(colorA) - (255 - getRedComponent(colorB)) * amount));
			var green:int = m.floor(m.max(0, getGreenComponent(colorA) - (255 - getGreenComponent(colorB)) * amount));
			var blue:int = m.floor(m.max(0, getBlueComponent(colorA) - (255 - getBlueComponent(colorB)) * amount));
			return (red << 16 | green << 8) | blue;
		}
		
		public static function getColorScreen(topColor:int, bottomColor:int, amount:Number):int
		{
			var m:* = Math;
			var redA:Number = getRedComponent(topColor) / 255;
			var greenA:Number = getGreenComponent(topColor) / 255;
			var blueA:Number = getBlueComponent(topColor) / 255;
			var redB:Number = getRedComponent(bottomColor) / 255;
			var greenB:Number = getGreenComponent(bottomColor) / 255;
			var blueB:Number = getBlueComponent(bottomColor) / 255;
			var red:int = m.floor(m.min(1, m.max(0, 1 - (1 - redA) * (1 - redB * amount))) * 255);
			var green:int = m.floor(m.min(1, m.max(0, 1 - (1 - greenA) * (1 - greenB * amount))) * 255);
			var blue:int = m.floor(m.min(1, m.max(0, 1 - (1 - blueA) * (1 - blueB * amount))) * 255);
			return (red << 16 | green << 8) | blue;
		}
		
		public static function getColorMultiply(topColor:int, bottomColor:int, amount:Number):int
		{
			var m:* = Math;
			var redA:Number = getRedComponent(topColor) / 255;
			var greenA:Number = getGreenComponent(topColor) / 255;
			var blueA:Number = getBlueComponent(topColor) / 255;
			var redB:Number = getRedComponent(bottomColor) / 255;
			var greenB:Number = getGreenComponent(bottomColor) / 255;
			var blueB:Number = getBlueComponent(bottomColor) / 255;
			var red:int = m.floor(m.min(1, m.max(0, redA * (1 - amount + redB * amount))) * 255);
			var green:int = m.floor(m.min(1, m.max(0, greenA * (1 - amount + greenB * amount))) * 255);
			var blue:int = m.floor(m.min(1, m.max(0, blueA * (1 - amount + blueB * amount))) * 255);
			return (red << 16 | green << 8) | blue;
		}
		
		public static function getColorOverlay(topColor:int, bottomColor:int):int
		{
			var redA:int = getRedComponent(topColor);
			var greenA:int = getGreenComponent(topColor);
			var blueA:int = getBlueComponent(topColor);
			var redB:int = getRedComponent(bottomColor);
			var greenB:int = getGreenComponent(bottomColor);
			var blueB:int = getBlueComponent(bottomColor);
			var m:* = Math;
			var red:int = ((redB < 128) ? m.floor(2 * redA * redB / 255) : m.floor(255 - 2 * (255 - redA) * (255 - redB) / 255));
			var green:int = ((greenB < 128) ? m.floor(2 * greenA * greenB / 255) : m.floor(255 - 2 * (255 - greenA) * (255 - greenB) / 255));
			var blue:int = ((blueB <= 128) ? m.floor(2 * blueA * blueB / 255) : m.floor(255 - 2 * (255 - blueA) * (255 - blueB) / 255));
			red = m.floor(m.min(255, m.max(0, red)));
			green = m.floor(m.min(255, m.max(0, green)));
			blue = m.floor(m.min(255, m.max(0, blue)));
			return (red << 16 | green << 8) | blue;
		}
		
		public static function getColorHardLight(topColor:int, bottomColor:int):int
		{
			return getColorOverlay(bottomColor, topColor);
		}
		
		public static function applyColorToColorTransform(color:int, transform:ColorTransform):void
		{
			ColorComponents.setFromColor(color);
			transform.redOffset = ColorComponents.red - 255;
			transform.greenOffset = ColorComponents.green - 255;
			transform.blueOffset = ColorComponents.blue - 255;
		}
		
		public static function rgb2hex(r:int, g:int, b:int):int
		{
			return (r << 16 | g << 8) | b;
		}
		
		public static function hex2rgb(hex_col:int):*
		{
			var red:int = hex_col >> 16;
			var green_blue:int = hex_col - (red << 16);
			var green:int = green_blue >> 8;
			var blue:int = green_blue - (green << 8);
			return {r: red, g: green, b: blue}
		}
		
		public static function hex2hsv(hex_col:int):*
		{
			var rgb:* = hex2rgb(hex_col);
			return rgb2hsv(rgb.r, rgb.g, rgb.b);
		}
		
		public static function hsv2hex(hue:Number, sat:Number, val:Number):int
		{
			var rgb:* = hsv2rgb(hue, sat, val);
			return rgb2hex(rgb.r, rgb.g, rgb.b);
		}
		
		public static function hsv2rgb(hue:Number, sat:Number, val:Number):*
		{
			var red:int = 0;
			var grn:int = 0;
			var blu:int = 0;
			var i:Number;
			var f:Number;
			var p:Number;
			var q:Number;
			var t:Number;
			hue %= 360;
			if (val == 0)
				return {r: 0, g: 0, b: 0}
			else
			{
				sat /= 100;
				val /= 100;
				hue /= 60;
				i = Math.floor(hue);
				f = hue - i;
				p = val * (1 - sat);
				q = val * (1 - sat * f);
				t = val * (1 - sat * (1 - f));
				if (i == 0)
				{
					red = Math.floor(val * 255);
					grn = Math.floor(t * 255);
					blu = Math.floor(p * 255);
				}
				else if (i == 1)
				{
					red = Math.floor(q * 255);
					grn = Math.floor(val * 255);
					blu = Math.floor(p * 255);
				}
				else if (i == 2)
				{
					red = Math.floor(p * 255);
					grn = Math.floor(val * 255);
					blu = Math.floor(t * 255);
				}
				else if (i == 3)
				{
					red = Math.floor(p * 255);
					grn = Math.floor(q * 255);
					blu = Math.floor(val * 255);
				}
				else if (i == 4)
				{
					red = Math.floor(t * 255);
					grn = Math.floor(p * 255);
					blu = Math.floor(val * 255);
				}
				else if (i == 5)
				{
					red = Math.floor(val * 255);
					grn = Math.floor(p * 255);
					blu = Math.floor(q * 255);
				}
				return {r: red, g: grn, b: blu}
			}
			return null;
		}
		
		public static function rgb2hsv(red:Number, grn:Number, blu:Number):*
		{
			var x:Number;
			var f:Number;
			var i:int;
			var hue:int;
			var sat:int;
			var val:Number;
			red /= 255;
			grn /= 255;
			blu /= 255;
			x = Math.min(Math.min(red, grn), blu);
			val = Math.max(Math.max(red, grn), blu);
			if (x == val)
				return {h: 0, s: 0, v: val * 100}
			else
			{
				f = ((red == x) ? grn - blu : ((grn == x) ? blu - red : red - grn));
				i = ((red == x) ? 3 : ((grn == x) ? 5 : 1));
				hue = Math.floor((i - f / (val - x)) * 60) % 360;
				sat = Math.floor((val - x) / val * 100);
				val = Math.floor(val * 100);
				return {h: hue, s: sat, v: val}
			}
			return null;
		}
	
	}
}
