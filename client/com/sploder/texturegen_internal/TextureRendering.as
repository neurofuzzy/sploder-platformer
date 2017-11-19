package com.sploder.texturegen_internal
{
	import com.sploder.texturegen_internal.util.ColorTools;
	import com.sploder.texturegen_internal.util.Geom;
	import com.sploder.texturegen_internal.util.ReduceColors;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class TextureRendering
	{
		
		public static var mainStage:Stage;
		
		public static var BORDER_TYPE_NONE:int = 0;
		public static var BORDER_TYPE_TOP:int = 1;
		public static var BORDER_TYPE_LEFT:int = 2;
		public static var BORDER_TYPE_RIGHT:int = 4;
		public static var BORDER_TYPE_BOTTOM:int = 8;
		public static var BORDER_TYPE_CORNER_TOPLEFT:int = 16;
		public static var BORDER_TYPE_CORNER_TOPRIGHT:int = 32;
		public static var BORDER_TYPE_CORNER_BOTTOMLEFT:int = 64;
		public static var BORDER_TYPE_CORNER_BOTTOMRIGHT:int = 128;
		public static var BORDER_TYPE_ALLSIDES:int = 256;
		public static var BORDER_TYPE_ALL:int = 512;
		public static var BORDER_TYPE_RAMP_TL:int = 1024;
		public static var BORDER_TYPE_RAMP_TR:int = 2048;
		public static var BORDER_TYPE_RAMP_BR:int = 4096;
		public static var BORDER_TYPE_RAMP_BL:int = 8192;
		
		protected var destroyed:Boolean;
		protected var tbuffer:BitmapData;
		protected var abuffer:BitmapData;
		protected var blurFilter:flash.filters.BlurFilter;
		protected var bevelsContainer:Shape;
		protected var fillsContainer:Shape;
		protected var mortarsContainer:Shape;
		
		public var nonBorderRegions:Array;
		public var centers:Array;
		public var offsetRegions:Array;
		public var regions:Array;
		
		
		/*
		 * Returns a proper border value given a 3x3 array of border information
		 * center cell is always 1. others, 1 is occupied, 0 is empty, so border needed
		 */
		public static function getBorderFromTileMap (map:Array):int
		{
			var border:int = 0;
			
			// 012
			// 345
			// 678
			
			if (map[1] == 0 && map[3] == 0 && map[5] == 0 && map[7] == 0)
			{
				border = BORDER_TYPE_ALLSIDES;
			} else if (map.join("") == "111111111")
			{
				border = BORDER_TYPE_ALL;
			} else {
				if (map[1] == 0) border += BORDER_TYPE_TOP;
				if (map[3] == 0) border += BORDER_TYPE_LEFT;
				if (map[5] == 0) border += BORDER_TYPE_RIGHT;
				if (map[7] == 0) border += BORDER_TYPE_BOTTOM;
				
				if (map[0] == 0 && map[1] == 1 && map[3] == 1) border += BORDER_TYPE_CORNER_TOPLEFT;
				if (map[2] == 0 && map[1] == 1 && map[5] == 1) border += BORDER_TYPE_CORNER_TOPRIGHT;
				if (map[6] == 0 && map[3] == 1 && map[7] == 1) border += BORDER_TYPE_CORNER_BOTTOMLEFT;
				if (map[8] == 0 && map[5] == 1 && map[7] == 1) border += BORDER_TYPE_CORNER_BOTTOMRIGHT;
			}
			
			return border;
		}
		
		protected var attribs:TextureAttributes;
		
		public function TextureRendering():void
		{
		
		}
		
		public function initWithAttributes(attribs:TextureAttributes):*
		{
			this.attribs = attribs;
			this.mortarsContainer = new Shape();
			this.fillsContainer = new Shape();
			this.bevelsContainer = new Shape();
			this.mortarsContainer.scrollRect = new flash.geom.Rectangle(128, 128, 512, 512);
			this.fillsContainer.scrollRect = new flash.geom.Rectangle(128, 128, 512, 512);
			this.bevelsContainer.scrollRect = new flash.geom.Rectangle(128, 128, 512, 512);
			this.abuffer = new BitmapData(512, 512, false, 0);
			this.tbuffer = new BitmapData(512, 512, true, 0);
			this.destroyed = false;
			
			return this;
		}
		
	
		public function generate (clipBorderType:int = 0):void
		{
			if (destroyed) return;
			
			nonBorderRegions = null;
			
			var r:Rectangle = null;
			
			if (clipBorderType > BORDER_TYPE_NONE && clipBorderType != BORDER_TYPE_ALL)
			{
				if ((clipBorderType & BORDER_TYPE_ALLSIDES) == BORDER_TYPE_ALLSIDES)
				{
					r = new Rectangle(256, 256, 256, 256);
					
				} else {
					
					r = new Rectangle( -256, -256, 1536, 1536);
					
					if ((clipBorderType & BORDER_TYPE_BOTTOM) == BORDER_TYPE_BOTTOM) r.height -= 768;
					if ((clipBorderType & BORDER_TYPE_RIGHT) == BORDER_TYPE_RIGHT) r.width -= 768;
					if ((clipBorderType & BORDER_TYPE_TOP) == BORDER_TYPE_TOP)
					{
						r.y = 256;
						r.height -= 512;
					}
						
					if ((clipBorderType & BORDER_TYPE_LEFT) == BORDER_TYPE_LEFT)
					{
						r.x = 256;
						r.width -= 512;
					}
				}
			}
			
			switch (attribs.type)
			{
				case TextureAttributes.TYPE_BRICK:
					regions = BrickGenerator.generateFrom(attribs, r);
					break;
					
				case TextureAttributes.TYPE_STONE:
					regions = StoneGenerator.generateFrom(attribs, r);
					break;
			}
			
			centers = PolygonTools.getCenters(regions);
			
			if (clipBorderType >= BORDER_TYPE_RAMP_TL)
			{	
				var clip_type:int = 0;
				
				switch (clipBorderType)
				{
					case BORDER_TYPE_RAMP_TL: 
						clip_type = PolygonTools.CLIP_TYPE_RAMP_TL;
						break;
					case BORDER_TYPE_RAMP_TR:
						clip_type = PolygonTools.CLIP_TYPE_RAMP_TR;
						break;
					case BORDER_TYPE_RAMP_BL: 
						clip_type = PolygonTools.CLIP_TYPE_RAMP_BL;
						break;
					case BORDER_TYPE_RAMP_BR:
						clip_type = PolygonTools.CLIP_TYPE_RAMP_BR;
						break;
				}
				
				regions = PolygonTools.getClippedPolygons(regions, clip_type, 384, 384);
				centers = PolygonTools.getCenters(regions);
			}
		}
		

		public function setBorderRegions (type:int = 0):void
		{
			if (destroyed) return;
			
			nonBorderRegions = null;
			
			if (type == BORDER_TYPE_NONE) return;
			
			nonBorderRegions = [];
			
			if (type == BORDER_TYPE_ALLSIDES) type = BORDER_TYPE_TOP + BORDER_TYPE_LEFT + BORDER_TYPE_RIGHT + BORDER_TYPE_BOTTOM;
			
			var region:Array;
			var r:Rectangle = new Rectangle(256, 256, 256, 256);
			var rb:Rectangle = null;
			var pt:Point;
			
			var border_hit:Boolean;
			
			for (var i:int = 0;  i < regions.length; i++)
			{
				region = regions[i];
				
				border_hit = false;
				rb = Geom.boundingBox(region);
				
				if (type >= BORDER_TYPE_RAMP_TL)
				{
					for each (pt in region)
					{
						if (type == BORDER_TYPE_RAMP_TR || type == BORDER_TYPE_RAMP_BL)
						{
							if (pt.x == pt.y) {
								border_hit = true;
								break;
							}
						} else {
							if (pt.x - 384 == 384 - pt.y) 
							{
								border_hit = true;
								break;
							}
						}
					}
				}
				else if (type != BORDER_TYPE_NONE) 
				{
					if ((type & BORDER_TYPE_BOTTOM) == BORDER_TYPE_BOTTOM)
					{
						if (rb.y + rb.height >= 500) border_hit = true;
					}
					
					if (!border_hit && (type & BORDER_TYPE_RIGHT) == BORDER_TYPE_RIGHT)
					{
						if (rb.x + rb.width >= 500) border_hit = true;
					}
					
					if (!border_hit && (type & BORDER_TYPE_TOP) == BORDER_TYPE_TOP)
					{
						if (rb.y <= 268) border_hit = true;
					}
					
					if (!border_hit && (type & BORDER_TYPE_LEFT) == BORDER_TYPE_LEFT)
					{
						if (rb.x <= 268) border_hit = true;
					}
					
					if (!border_hit && (type & BORDER_TYPE_CORNER_TOPLEFT) == BORDER_TYPE_CORNER_TOPLEFT)
					{
						if (rb.x <= 268 && rb.y <= 268) border_hit = true;
					}
					
					if (!border_hit && (type & BORDER_TYPE_CORNER_TOPRIGHT) == BORDER_TYPE_CORNER_TOPRIGHT)
					{
						if (rb.x + rb.width >= 500 && rb.y <= 268) border_hit = true;
					}
					
					if (!border_hit && (type & BORDER_TYPE_CORNER_BOTTOMLEFT) == BORDER_TYPE_CORNER_BOTTOMLEFT)
					{
						if (rb.x <= 268 && rb.y + rb.height >= 500) border_hit = true;
					}
					
					if (!border_hit && (type & BORDER_TYPE_CORNER_BOTTOMRIGHT) == BORDER_TYPE_CORNER_BOTTOMRIGHT)
					{
						if (rb.x + rb.width >= 500 && rb.y + rb.height >= 500) border_hit = true;
					}
				}
				
				if (!border_hit && (rb.width >= 512 && rb.x < 256) || (rb.height >= 512 && rb.y < 256) ) 
				{
					border_hit = true; // spanning course
				}
				
				if (!border_hit) nonBorderRegions.push(region);
				
			}
		}
		
			

		public function renderToBitmap (bd:BitmapData, highQuality:Boolean = false, clipBorderType:int = 0):void
		{
			if (destroyed) return;
			if (mainStage == null) return;
			
			var buffer:BitmapData = (bd.transparent) ? tbuffer : abuffer;
			
			var qual:* = mainStage.quality;
			
			if (highQuality) mainStage.quality = StageQuality.HIGH;
			else mainStage.quality = StageQuality.LOW;
			
			mortarsContainer.graphics.clear();
			fillsContainer.graphics.clear();
			bevelsContainer.graphics.clear();
			
			bd.lock();
			buffer.lock();
			
			bd.fillRect(bd.rect, 0);

			if (!bd.transparent) buffer.fillRect(buffer.rect, attribs.mortarColor);
			else buffer.fillRect(buffer.rect, 0);
			
			var noise_map_scale:Number = Math.max(1, Math.min(16, attribs.noiseScale));
			var fill_gradient_type:* = (attribs.gradientRadial) ? GradientType.RADIAL : GradientType.LINEAR;
			var offset_type:int = (attribs.type == TextureAttributes.TYPE_BRICK) ? PolygonTools.OFFSET_TYPE_BRICK : PolygonTools.OFFSET_TYPE_POLY_CENTERSCALING;
			
			if (clipBorderType >= BORDER_TYPE_CORNER_TOPLEFT) offset_type = PolygonTools.OFFSET_TYPE_POLY_CENTERSCALING;
			
			var render_scale:Number = bd.width / 256;
			var draw_scale:Number = highQuality ? 1 : render_scale;
			
			var m:Matrix = new Matrix();
			if (!highQuality) {
				m.identity();
				m.scale(render_scale, render_scale);
			}
			
			var assets:RegionRendererAssets = null;
			
			// render mortars
			
			if (attribs.mortarAmount > 0)
			{
				if (bd.transparent || attribs.lightFactor > 0 || attribs.noiseFactor > 0)
				{
					assets = RegionRenderer.fillRegions(
						regions, 
						mortarsContainer.graphics, 
						RegionRenderer.TYPE_FAKE_LIGHTING_FILL_ONLY, 
						0,
						255,
						attribs.lightFactor * 0.5, 
						0, 
						0, 
						attribs.mortarColor,
						attribs.lightColor,
						attribs.lightAngle + Math.PI,
						attribs.shadowColor,
						attribs.depthColor,
						attribs.highlightColor,
						attribs.overExposure, 
						attribs.noiseFactor * 0.25,
						noise_map_scale,
						fill_gradient_type,
						offset_type
						);
				}
				
				var mortar_offset_type:int = PolygonTools.OFFSET_TYPE_POLY_CENTERSCALING;
				if (offset_type == PolygonTools.OFFSET_TYPE_BRICK) mortar_offset_type = PolygonTools.OFFSET_TYPE_BRICK;
				
				offsetRegions = PolygonTools.getOffsetPolygons(regions, attribs.mortarAmount, mortar_offset_type);
				
				buffer.draw(mortarsContainer, m, null, null, null, highQuality);
				
				if (assets != null)
				{
					assets.destroy();
					assets = null;
				}
				
			}
			else offsetRegions = regions;
			
			// render fills
			
			if (attribs.bevelAmount < 100 || attribs.roundFactor > 0)
			{
				assets = RegionRenderer.fillRegions(
					offsetRegions, 
					fillsContainer.graphics, 
					RegionRenderer.TYPE_FAKE_LIGHTING_FILL_ONLY, 
					attribs.bevelAmount,
					attribs.bevelRatio,
					attribs.lightFactor, 
					attribs.depthFactor, 
					attribs.roundFactor, 
					attribs.diffuseColor,
					attribs.lightColor,
					attribs.lightAngle,
					attribs.shadowColor,
					attribs.depthColor,
					attribs.highlightColor,
					attribs.overExposure, 
					attribs.noiseFactor,
					noise_map_scale,
					fill_gradient_type,
					offset_type
					);
					
				buffer.draw(fillsContainer, m, null, null, null, highQuality);
				
				assets.destroy();
				assets = null;
			}
			
			// render bevels
			
			var bevel_color:int = ColorTools.getTintedColor(attribs.diffuseColor, 0x808080, 0.5);
			
			if (attribs.bevelAmount > 0)
			{
				assets = RegionRenderer.fillRegions(
					offsetRegions, 
					bevelsContainer.graphics, 
					RegionRenderer.TYPE_FAKE_LIGHTING_BEVEL_ONLY,
					attribs.bevelAmount, 
					attribs.bevelRatio,
					attribs.lightFactor, 
					attribs.depthFactor,
					attribs.roundFactor, 
					bevel_color,
					attribs.lightColor,
					attribs.lightAngle,
					attribs.shadowColor,
					attribs.depthColor,
					attribs.highlightColor,
					attribs.overExposure, 
					attribs.noiseFactor * 0.25,
					noise_map_scale,
					fill_gradient_type,
					offset_type
					);
					
				buffer.draw(bevelsContainer, m, null, null, null, highQuality);
				assets.destroy();
				assets = null;
					
			}
			
			// render unclipped region shading
			
			if (nonBorderRegions != null)
			{
				fillsContainer.graphics.clear();
				
				RegionRenderer.fillRegions(
					nonBorderRegions, 
					fillsContainer.graphics, 
					RegionRenderer.TYPE_DIFFUSE_TINT,
					0,
					0,
					0, 
					attribs.depthFactor,
					0,
					0,
					attribs.lightColor,
					attribs.lightAngle,
					attribs.shadowColor,
					attribs.depthColor,
					attribs.highlightColor
					);
					
				buffer.draw(fillsContainer, m, null, null, null, highQuality);
			}
			
			if (attribs.blurAmount > 0)
			{
				if (bd.transparent)
				{
					var b_size:Number = attribs.blurAmount * 0.1;
					var c_size:Number = render_scale * (128 + attribs.blurAmount * 0.2);
					
					if ((clipBorderType & BORDER_TYPE_CORNER_TOPLEFT) == BORDER_TYPE_CORNER_TOPLEFT)
					{
						buffer.fillRect(new Rectangle(0, 0, c_size, c_size), 0);
					}
					
					if ((clipBorderType & BORDER_TYPE_CORNER_TOPRIGHT) == BORDER_TYPE_CORNER_TOPRIGHT)
					{
						buffer.fillRect(new Rectangle(render_scale * (256 + 128) - b_size, 0, c_size, c_size), 0);
					}
					
					if ((clipBorderType & BORDER_TYPE_CORNER_BOTTOMLEFT) == BORDER_TYPE_CORNER_BOTTOMLEFT)
					{
						buffer.fillRect(new Rectangle(0, render_scale * (256 + 128) - b_size, c_size, c_size), 0);
					}
					
					if ((clipBorderType & BORDER_TYPE_CORNER_BOTTOMRIGHT) == BORDER_TYPE_CORNER_BOTTOMRIGHT)
					{
						buffer.fillRect(new Rectangle(render_scale * (256 + 128) - b_size, render_scale * (256 + 128) - b_size, c_size, c_size), 0);
					}
				}
				
				blurFilter = new BlurFilter(attribs.blurAmount * draw_scale, attribs.blurAmount * draw_scale, (attribs.blurAmount * draw_scale > 4) ? 2 : 1);
				buffer.applyFilter(buffer, buffer.rect, new Point(), blurFilter);
				if (buffer.transparent)
				{
					var glowFilter:GlowFilter = new GlowFilter(attribs.mortarColor, 1, attribs.blurAmount * draw_scale * 0.5, attribs.blurAmount * draw_scale * 0.5, 3, BitmapFilterQuality.HIGH, true);
					buffer.applyFilter(buffer, buffer.rect, new Point(), glowFilter); 
				}
			}
			
			buffer.unlock();
			
			if (!highQuality) bd.copyPixels(buffer, new Rectangle(128 * render_scale, 128 * render_scale, 256 * render_scale, 256 * render_scale), new Point());
			else 
			{
				m.identity();
				m.scale(render_scale, render_scale);
				m.translate(0 - 128 * render_scale, 0 - 128 * render_scale);
				bd.draw(buffer, m, null, null, null, highQuality);
			}
			
			if (attribs.contrastPower > 0)
			{
				var cb:Sprite = new Sprite();
				var cs:Shape = new Shape();
				cb.graphics.beginBitmapFill(bd);
				cb.graphics.drawRect(0, 0, bd.width, bd.height);
				cb.graphics.endFill();
				
				cs.alpha = attribs.contrastPower / 4;
				cs.blendMode = BlendMode.SCREEN;
				cs.graphics.beginBitmapFill(bd);
				cs.graphics.drawRect(0, 0, bd.width, bd.height);
				cs.graphics.endFill();
				cb.addChild(cs);
				buffer.fillRect(buffer.rect, 0);
				buffer.draw(cb, null, null, null, bd.rect);
				bd.copyPixels(buffer, bd.rect, new Point());
			}
			
			mainStage.quality = qual;
			
			bd.unlock();
		}
		
		
		public function postProcessBitmap (bd:BitmapData):void
		{
			if (destroyed) return;
			
			if (attribs.reducedColors > 1)
			{
				ReduceColors.reduceColors(bd, attribs.reducedColors, attribs.ditherMode);
				
				if (attribs.reducedColors < 6)
				{
					var red:int = attribs.diffuseColor >> 16;
					var green:int = attribs.diffuseColor >> 8 & 0xff;
					var blue:int = attribs.diffuseColor & 0xff;
					bd.colorTransform(bd.rect, new ColorTransform(0.5 + (red / 255) * 0.5, 0.5 + (green / 255) * 0.5, 0.5 + (blue / 255) * 0.5, 1, red * 0.5, green * 0.5, blue * 0.5)); 
				}
			}
		}
		
		
		public function destroy():void
		{
			if (destroyed) return;
			
			attribs = null;
			abuffer.dispose();
			abuffer = null;
			tbuffer.dispose();
			tbuffer = null;
			mortarsContainer.graphics.clear();
			fillsContainer.graphics.clear();
			bevelsContainer.graphics.clear();
			mortarsContainer = null;
			fillsContainer = null;
			bevelsContainer = null;
			blurFilter = null;
			destroyed = true;
		}
	}
}
