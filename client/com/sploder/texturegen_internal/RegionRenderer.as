package com.sploder.texturegen_internal
{
	
	import com.sploder.texturegen_internal.util.ColorTools;
	import com.sploder.texturegen_internal.util.Geom;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class RegionRenderer
	{
		
		public static var TYPE_DIFFUSE:int = 1;
		public static var TYPE_DIFFUSE_TINT:int = 2;
		public static var TYPE_NORMAL:int = 3;
		public static var TYPE_DEPTH:int = 4;
		public static var TYPE_FAKE_LIGHTING:int = 5;
		public static var TYPE_FAKE_LIGHTING_FILL_ONLY:int = 6;
		public static var TYPE_FAKE_LIGHTING_BEVEL_ONLY:int = 7;
		
		public static function fillRegions(regions:Array, g:Graphics, type:int = 0, bevelAmount:Number = 8.0, bevelRatio:int = 255, lightFactor:Number = 0.75, depthFactor:Number = 0.25, roundFactor:Number = 0, diffuseColor:int = 0xffffff, lightColor:int = 0xffffff, lightAngle:Number = 0, shadowColor:int = 0, depthColor:int = 0, highlightColor:int = 0, overExposure:Number = 0, noiseFactor:Number = 0, noiseScale:Number = 1, gradientType:* = null, offsetType:int = -1):RegionRendererAssets
		{
			var assets:RegionRendererAssets = new RegionRendererAssets().initWithColors(diffuseColor, lightColor, shadowColor, depthColor, highlightColor);
			assets.setLightAngle(lightAngle);
			assets.initColors(lightFactor, depthFactor, roundFactor, overExposure);
			assets.initNoiseMap(noiseFactor, noiseScale);
			
			var tintColor:int = 0;
			if (type == TYPE_DIFFUSE_TINT) tintColor = ColorTools.getTintedColor(diffuseColor, depthColor, Math.min(1, depthFactor * 2));
			
			var color:int = diffuseColor;
			
			if (gradientType == null) gradientType = GradientType.LINEAR;
			if (offsetType < 0) offsetType = PolygonTools.OFFSET_TYPE_POLY_CENTERSCALING;
			
			assets.offsetType = offsetType;
			
			var i:int = regions.length;
			
			while (i--)
			{
				switch (type)
				{
					case TYPE_DIFFUSE:
						fillRegion(assets, regions[i], g, color, 1, gradientType, 0, noiseFactor);
						break;
						
					case TYPE_DIFFUSE_TINT:
						fillRegion(assets, regions[i], g, tintColor, depthFactor * 0.5, gradientType);
						break;
						
					case TYPE_NORMAL:
						fillRegionBevelsNormalMap(assets, regions[i], g, bevelAmount, roundFactor);
						break;
					
					case TYPE_DEPTH:
						fillRegion(assets, regions[i], g, 0xffffff, 1, 1);
						if (bevelAmount > 0) fillRegionBevels(assets, regions[i], g, 0xffffff, 1.0, bevelAmount, bevelRatio, 0, 1.0);
						break;
						
					case TYPE_FAKE_LIGHTING:
						fillRegion(assets, regions[i], g, color, 1, gradientType, lightFactor, noiseFactor);
						if (bevelAmount > 0) fillRegionBevels(assets, regions[i], g, color, 1.0, bevelAmount, bevelRatio, lightFactor, depthFactor, roundFactor, overExposure, noiseFactor);
						break;
					
					case TYPE_FAKE_LIGHTING_FILL_ONLY:
						fillRegion(assets, regions[i], g, color, 1, gradientType, lightFactor, noiseFactor);
						break;
						
					case TYPE_FAKE_LIGHTING_BEVEL_ONLY:
						if (bevelAmount > 0) fillRegionBevels(assets, regions[i], g, color, 1.0, bevelAmount, bevelRatio, lightFactor, depthFactor, roundFactor, overExposure, noiseFactor);
						break;
				
				}
			}
			
			return assets;
		}
		
		protected static function fillRegion(assets:RegionRendererAssets, points:Array, g:Graphics, color:int = 16777215, alpha:Number = 1.0, gradientType:* = null, gradientFactor:Number = 0.0, noiseFactor:Number = 0):void
		{
			var n:int = points.length;
			if (n < 2)
				return;
			var point:Point;
			g.lineStyle(0, 0, 0);
			if (gradientFactor <= 0)
				g.beginFill(color, alpha);
			else
			{
				var m:Matrix = assets.matrix;
				var r:Rectangle = Geom.boundingBox(points);
				if (gradientType != GradientType.LINEAR && r.width < 300 && r.height < 300)
				{
					var pillow_offset_x:Number = 0 - assets.lightVector.x * 0.5;
					var pillow_offset_y:Number = 0 - assets.lightVector.y * 0.5;
					m.createGradientBox(r.width * 2, r.height * 2, 0, r.x - r.width * 0.5 + pillow_offset_x * r.width, r.y - r.height * 0.5 + pillow_offset_y * r.height);
					g.beginGradientFill(GradientType.RADIAL, [ColorTools.getTintedColor(color, assets.lightColor, gradientFactor), color], [alpha, alpha], [0, 255], m, SpreadMethod.PAD);
				}
				else
				{
					var light_r:Number = 0;
					if (r.width < 300 && r.height < 300)
						light_r = Math.atan2(assets.lightVector.y, assets.lightVector.x);
					else if (r.width < 300)
						light_r = 0;
					else
						light_r = Math.PI * 0.5;
					m.createGradientBox(r.width, r.height, light_r, r.x, r.y);
					g.beginGradientFill(GradientType.LINEAR, [ColorTools.getTintedColor(color, assets.lightColor, gradientFactor), color], [alpha, alpha], [0, 255], m, SpreadMethod.PAD);
				}
			}
			point = points[0];
			if (point != null)
				g.moveTo(point.x, point.y);
			{
				var _g:int = 1;
				while (_g < n)
				{
					var i:int = _g++;
					point = points[i];
					if (point != null)
						g.lineTo(point.x, point.y);
				}
			}
			g.endFill();
			if (noiseFactor > 0)
			{
				g.beginBitmapFill(assets.noiseMap, assets.noiseMapMatrix);
				point = points[0];
				if (point != null)
					g.moveTo(point.x, point.y);
				{
					var _g1:int = 1;
					while (_g1 < n)
					{
						var i1:int = _g1++;
						point = points[i1];
						if (point != null)
							g.lineTo(point.x, point.y);
					}
				}
				g.endFill();
			}
		}
		
		protected static function fillRegionBevels(assets:RegionRendererAssets, points:Array, g:Graphics, color:int = 16777215, alpha:Number = 1.0, bevelAmount:Number = 1.0, bevelRatio:int = 255, lightFactor:Number = 0.0, depthFactor:Number = 0.0, roundFactor:Number = 0.0, lightOverExposure:Number = 0, noiseFactor:Number = 0):void
		{
			points = PolygonTools.weld(points, 1);
			var offset_pts:Array = PolygonTools.getOffsetPolygon(points, bevelAmount, assets.offsetType);
			var len:int = points.length;
			var o_len:int = offset_pts.length;
			var normal:Point = null;
			var bev_dist:Number = 0;
			var m:Matrix = assets.matrix;
			if (len > 0 && offset_pts.length > 0)
			{
				var a:Point;
				var b:Point;
				var c:Point;
				var d:Point;
				var bev_color:int;
				var bev_color_a:int;
				var bev_color_b:int;
				var bev_color_c:int;
				var m_ang:Number;
				var center_pt:Point;
				{
					var _g:int = 0;
					while (_g < len)
					{
						var i:int = _g++;
						a = points[i];
						b = points[(i + 1) % len];
						c = offset_pts[(i + 1) % o_len];
						d = offset_pts[i];
						bev_dist = bevelAmount;
						normal = a.subtract(b);
						normal.normalize(1);
						Geom.rotate(normal, Math.PI * 0.5);
						bev_color_a = assets.color_a_perp;
						bev_color_b = assets.color_b_perp;
						bev_color_c = assets.color_c_perp;
						if (lightFactor > 0)
						{
							var light_amount:Number = Math.max(-1, Math.min(1, 0 - Geom.pointDottedBy(normal, assets.lightVector)));
							if (light_amount > 0)
							{
								bev_color_a = ColorTools.getColorScreen(assets.color_a_perp, assets.color_a_light, light_amount);
								bev_color_b = ColorTools.getColorScreen(assets.color_b_perp, assets.color_b_light, light_amount);
								bev_color_c = ColorTools.getColorScreen(assets.color_c_perp, assets.color_c_light, light_amount);
							}
							else
							{
								bev_color_a = ColorTools.getTintedColor(assets.color_a_perp, assets.color_a_dark, 0 - light_amount);
								bev_color_b = ColorTools.getTintedColor(assets.color_b_perp, assets.color_b_dark, 0 - light_amount);
								bev_color_c = ColorTools.getTintedColor(assets.color_c_perp, assets.color_c_dark, 0 - light_amount);
							}
						}
						m_ang = Math.atan2(0 - normal.y, 0 - normal.x);
						if (offset_pts[(i + 2) % o_len].equals(offset_pts[(i + 2) % o_len]))
							bev_dist = Geom.distanceBetween(points[(i + 1) % len], offset_pts[(i + 2) % o_len]);
						center_pt = points[i % len].add(points[(i + 1) % len]);
						center_pt.x *= 0.5;
						center_pt.y *= 0.5;
						center_pt.x -= normal.x * bev_dist * 0.5;
						center_pt.y -= normal.y * bev_dist * 0.5;
						m.createGradientBox(bev_dist, bev_dist, m_ang, center_pt.x - bev_dist / 2, center_pt.y - bev_dist / 2);
						g.beginGradientFill(GradientType.LINEAR, [bev_color_a, bev_color_b, bev_color_c], [1.0, 1.0 - roundFactor * 0.5, 1.0 - roundFactor], [0, bevelRatio * 0.5, bevelRatio], m, SpreadMethod.PAD);
						g.moveTo(a.x, a.y);
						g.lineTo(b.x, b.y);
						g.lineTo(c.x, c.y);
						g.lineTo(d.x, d.y);
						g.endFill();
						if (noiseFactor > 0)
						{
							g.beginBitmapFill(assets.noiseMap, assets.noiseMapMatrix);
							g.moveTo(a.x, a.y);
							g.lineTo(b.x, b.y);
							g.lineTo(c.x, c.y);
							g.lineTo(d.x, d.y);
							g.endFill();
						}
					}
				}
			}
		}
		
		protected static function fillRegionBevelsNormalMap(assets:RegionRendererAssets, points:Array, g:Graphics, bevelAmount:Number = 1.0, roundFactor:Number = 0):void
		{
			points = PolygonTools.weld(points, 1);
			var base_color:int = 8421631;
			RegionRenderer.fillRegion(assets, points, g, base_color);
			var surface_norm:Point = new Point(1, 0);
			var offset_pts:Array = PolygonTools.getOffsetPolygon(points, bevelAmount, assets.offsetType);
			var len:int = points.length;
			var o_len:int = offset_pts.length;
			var normal:Point = null;
			var bev_dist:Number = 0;
			var m:Matrix = assets.matrix;
			if (len > 0 && offset_pts.length > 0)
			{
				var a:Point;
				var b:Point;
				var c:Point;
				var d:Point;
				var bev_color:int;
				var m_ang:Number;
				var center_pt:Point;
				{
					var _g:int = 0;
					while (_g < len)
					{
						var i:int = _g++;
						a = points[i];
						b = points[(i + 1) % len];
						c = offset_pts[(i + 1) % o_len];
						d = offset_pts[i];
						bev_dist = bevelAmount;
						normal = a.subtract(b);
						normal.normalize(1);
						surface_norm.x = 0;
						surface_norm.y = 1;
						Geom.rotate(surface_norm, 0 - Math.atan2(normal.y, normal.x));
						bev_color = ((128 - Math.round(surface_norm.x * 127) << 16 | 128 - Math.round(surface_norm.y * 127) << 8) | 255);
						g.beginFill(bev_color, 1);
						g.moveTo(a.x, a.y);
						g.lineTo(b.x, b.y);
						g.lineTo(c.x, c.y);
						g.lineTo(d.x, d.y);
						g.endFill();
						if (roundFactor > 0)
						{
							Geom.rotate(normal, Math.PI * 0.5);
							m_ang = Math.atan2(0 - normal.y, 0 - normal.x);
							if (offset_pts[(i + 2) % o_len].equals(offset_pts[(i + 2) % o_len]))
								bev_dist = Geom.distanceBetween(points[(i + 1) % len], offset_pts[(i + 2) % o_len]);
							center_pt = points[i % len].add(points[(i + 1) % len]);
							center_pt.x *= 0.5;
							center_pt.y *= 0.5;
							center_pt.x -= normal.x * bev_dist * 0.5;
							center_pt.y -= normal.y * bev_dist * 0.5;
							m.createGradientBox(bev_dist, bev_dist, m_ang, center_pt.x - bev_dist / 2, center_pt.y - bev_dist / 2);
							g.beginGradientFill(GradientType.LINEAR, [base_color, base_color], [0, roundFactor], [0, 200], m, SpreadMethod.PAD);
							g.moveTo(a.x, a.y);
							g.lineTo(b.x, b.y);
							g.lineTo(c.x, c.y);
							g.lineTo(d.x, d.y);
							g.endFill();
						}
					}
				}
			}
		}
	
	}
}
