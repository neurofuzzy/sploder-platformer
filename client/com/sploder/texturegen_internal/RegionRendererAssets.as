package com.sploder.texturegen_internal
{
	
	import com.sploder.texturegen_internal.util.ColorTools;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import com.sploder.texturegen_internal.util.Geom;
	import flash.geom.ColorTransform;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	
	public class RegionRendererAssets
	{
		public var noiseMapMatrix:Matrix;
		public var noiseMap:BitmapData;
		public var matrix:Matrix;
		public var lightVector:Point;
		public var noiseMapScale:Number;
		public var noiseMapFactor:Number;
		public var noiseMapColor:int;
		public var offsetType:int;
		public var color_c_dark:int;
		public var color_b_dark:int;
		public var color_a_dark:int;
		public var color_c_light:int;
		public var color_b_light:int;
		public var color_a_light:int;
		public var color_c_perp:int;
		public var color_b_perp:int;
		public var color_a_perp:int;
		public var highlightColor:int;
		public var depthColor:int;
		public var shadowColor:int;
		public var lightColor:int;
		public var diffuseColor:int;
		
		public function RegionRendererAssets():void
		{
		}
		
		public function initWithColors(diffuseColor:int, lightColor:int, shadowColor:int, depthColor:int, highlightColor:int):*
		{
			this.diffuseColor = diffuseColor;
			this.lightColor = lightColor;
			this.shadowColor = shadowColor;
			this.depthColor = depthColor;
			this.highlightColor = highlightColor;
			this.lightVector = new Point(1, 1);
			this.matrix = new Matrix();
			this.noiseMapMatrix = new Matrix();
			this.noiseMapFactor = 1;
			this.noiseMapScale = 2;
			
			return this;
		}
		
		public function destroy():void
		{
			if (noiseMap != null)
			{
				noiseMap.dispose();
				noiseMap = null;
			}
		}
		
		public function setLightAngle(angle:Number):void
		{
			lightVector.x = 0;
			lightVector.y = 1;
			Geom.rotate(lightVector, angle * Math.PI / 180);
		}
		
		public function initNoiseMap(noiseMapFactor:Number, noiseMapScale:Number = 1.0):void
		{
			noiseMapColor = diffuseColor;
			noiseMapFactor = noiseMapFactor;
			noiseMapScale = noiseMapScale;
			var color:int = noiseMapColor;
			if (noiseMap == null)
				noiseMap = new BitmapData(256, 256, true, color);
			else
				noiseMap.fillRect(noiseMap.rect, color);
			var red:int = color >> 16;
			var green:int = color >> 8 & 255;
			var blue:int = color & 255;
			noiseMap.noise(color, 0, 255, 7, true);
			noiseMap.colorTransform(noiseMap.rect, new ColorTransform(red / 255, green / 255, blue / 255, noiseMapFactor));
			var noiseMapSpeckle:BitmapData = new BitmapData(256, 256, true, 0);
			noiseMapSpeckle.noise(color, 0, 16, 7, true);
			var offset_map_red:Array = [];
			var offset_map_green:Array = [];
			var offset_map_blue:Array = [];
			{
				var _g:int = 0;
				while (_g < 256)
				{
					var i:int = _g++;
					offset_map_red[i] = ((i < 16) ? 0 : Math.floor(255 * noiseMapFactor) << 16);
					offset_map_green[i] = 65280;
					offset_map_blue[i] = 255;
				}
			}
			noiseMapSpeckle.copyChannel(noiseMapSpeckle, noiseMapSpeckle.rect, new Point(), 1, 8);
			noiseMapSpeckle.copyChannel(noiseMapSpeckle, noiseMapSpeckle.rect, new Point(), 4, 1);
			noiseMap.draw(noiseMapSpeckle, null, null, BlendMode.SCREEN);
			noiseMapMatrix.identity();
			noiseMapMatrix.scale(noiseMapScale, noiseMapScale);
			noiseMapSpeckle.dispose();
		}
		
		public function initColors(lightFactor:Number = 1.0, depthFactor:Number = 0.5, roundFactor:Number = 0.5, lightOverExposure:Number = 0):void
		{
			var color:int = diffuseColor;
			color_a_perp = ((depthFactor == 0) ? color : ((depthFactor == 1) ? depthColor : ColorTools.getTintedColor(color, depthColor, depthFactor)));
			color_b_perp = ((depthFactor == 0) ? color : ColorTools.getTintedColor(color, depthColor, depthFactor * 0.5));
			color_c_perp = color;
			color_a_light = ((lightFactor == 0) ? color_a_perp : ((lightFactor == 1) ? lightColor : ColorTools.getColorScreen(color_a_perp, lightColor, lightFactor)));
			color_b_light = ((lightFactor == 0) ? color_b_perp : ((lightFactor == 1) ? lightColor : ColorTools.getColorScreen(color_b_perp, lightColor, lightFactor)));
			color_c_light = ((lightFactor == 0) ? color_c_perp : ((lightFactor == 1) ? lightColor : ColorTools.getColorScreen(color_c_perp, lightColor, lightFactor)));
			color_a_dark = ((lightFactor == 0) ? color_a_perp : ((lightFactor == 1) ? shadowColor : ColorTools.getColorMultiply(color_a_perp, shadowColor, lightFactor)));
			color_b_dark = ((lightFactor == 0) ? color_b_perp : ((lightFactor == 1) ? shadowColor : ColorTools.getColorMultiply(color_b_perp, shadowColor, lightFactor)));
			color_c_dark = ((lightFactor == 0) ? color_c_perp : ((lightFactor == 1) ? shadowColor : ColorTools.getColorMultiply(color_c_perp, shadowColor, lightFactor)));
			if (roundFactor > 0)
			{
				color_b_perp = ColorTools.getTintedColor(color_b_perp, color, roundFactor * 0.5);
				color_b_light = ColorTools.getTintedColor(color_b_light, color, roundFactor * 0.5);
				color_b_dark = ColorTools.getTintedColor(color_b_dark, color, roundFactor * 0.5);
				if (roundFactor == 1)
					color_c_light = color_c_dark = color;
				else
				{
					color_c_light = ColorTools.getTintedColor(color_c_light, color, roundFactor);
					color_c_dark = ColorTools.getTintedColor(color_c_dark, color, roundFactor);
				}
			}
			color_a_perp = ColorTools.getColorOverlay(color_a_perp, color);
			color_b_perp = ColorTools.getColorOverlay(color_b_perp, color);
			color_c_perp = ColorTools.getColorOverlay(color_c_perp, color);
			color_a_light = ColorTools.getColorOverlay(color_a_light, color);
			color_b_light = ColorTools.getColorOverlay(color_b_light, color);
			color_c_light = ColorTools.getColorOverlay(color_c_light, color);
			if (lightOverExposure > 0)
			{
				color_a_light = ColorTools.getColorScreen(color_a_light, lightColor, lightOverExposure);
				color_b_light = ColorTools.getColorScreen(color_b_light, lightColor, lightOverExposure);
				color_c_light = ColorTools.getColorScreen(color_c_light, lightColor, lightOverExposure);
			}
			color_a_dark = ColorTools.getColorOverlay(color_a_dark, color);
			color_b_dark = ColorTools.getColorOverlay(color_b_dark, color);
			color_c_dark = ColorTools.getColorOverlay(color_c_dark, color);
			if (highlightColor > 0)
			{
				color_a_dark = ColorTools.getColorScreen(color_a_dark, highlightColor, 1.0);
				color_b_dark = ColorTools.getColorScreen(color_b_dark, highlightColor, 0.5);
			}
		}
	}
}
