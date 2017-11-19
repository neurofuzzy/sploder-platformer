package com.sploder.texturegen_internal.util
{
	public class ColorComponents
	{
		public static var red:int;
		public static var green:int;
		public static var blue:int;
		
		public static function setFromColor(color:int, brightness:Number = 1.0):void
		{
			var m:* = Math;
			var c:* = ColorTools;
			red = m.floor(m.min(255, c.getRedComponent(color) * brightness));
			green = m.floor(m.min(255, c.getGreenComponent(color) * brightness));
			blue = m.floor(m.min(255, c.getBlueComponent(color) * brightness));
		}
		
		public static function setFromColorPlusOffset(color:int, brightness:Number = 1.0, offset:int = 0):void
		{
			var m:* = Math;
			var c:* = ColorTools;
			red = m.floor(m.min(255, c.getRedComponent(color) * brightness + offset));
			green = m.floor(m.min(255, c.getGreenComponent(color) * brightness + offset));
			blue = m.floor(m.min(255, c.getBlueComponent(color) * brightness + offset));
		}
		
		public static function setFromAddedColors(colorA:int, colorB:int):void
		{
			var m:* = Math;
			var c:* = ColorTools;
			red = m.floor(m.min(255, c.getRedComponent(colorA) + c.getRedComponent(colorB)));
			green = m.floor(m.min(255, c.getGreenComponent(colorA) + c.getGreenComponent(colorB)));
			blue = m.floor(m.min(255, c.getBlueComponent(colorA) + c.getBlueComponent(colorB)));
		}
		
		public static function setFromSubtractedColors(colorA:int, colorB:int):void
		{
			var m:* = Math;
			var c:* = ColorTools;
			red = m.floor(m.max(0, c.getRedComponent(colorA) - (255 - c.getRedComponent(colorB))));
			green = m.floor(m.max(0, c.getGreenComponent(colorA) - (255 - c.getGreenComponent(colorB))));
			blue = m.floor(m.max(0, c.getBlueComponent(colorA) - (255 - c.getBlueComponent(colorB))));
		}
		
		public static function getColor():int
		{
			return (red << 16 | green << 8) | blue;
		}
	
	}
}
