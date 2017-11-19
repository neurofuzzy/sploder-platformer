/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.util {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.filters.*;

	import fuz2d.util.ColorTools;
	import fuz2d.util.TileDefinition;
	import fuz2d.util.Voronoi;
	
	/**
	 * ...
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public class TileGenerator {
		
		public static var root:Sprite;
		public static var testmap:Bitmap;
		public static var sampleScale:int = 2;

		public static function makeVoronoi (def:TileDefinition):Voronoi {
			
			var vclip:Sprite = new Sprite();
			
			var dw:int = def.width / TileDefinition.scale;
			var dh:int = def.height / TileDefinition.scale;
			
			var v:Voronoi = new Voronoi(vclip, dw * sampleScale, dh * sampleScale, 0xffffff, 0x000000, def.edgeThickness * sampleScale, def.cellsX, def.cellsY, def.perturbation, def.randomSeed, def.bond);
			v.background = false;
			v.create( -1, false);
				
			return v;
			
		}
		//
		//
		public static function makeTile (def:TileDefinition = null, destination:BitmapData = null, voronoi:Voronoi = null, stamp:Sprite = null, stampRotation:Number = 0):BitmapData {
			
			var dw:int = def.width / TileDefinition.scale;
			var dh:int = def.height / TileDefinition.scale;
			var dws:int = dw * sampleScale;
			var dhs:int = dh * sampleScale;
			
			if (root != null) {
				testmap = new Bitmap();
				root.addChild(testmap);
			}
			
			if (def == null) def = new TileDefinition();

			var ox:int = Math.floor((dws) / (def.cellsX + 2));
			var oy:int = Math.floor((dhs) / (def.cellsY + 2));
			
			var fw:int = dws + (ox * 2);
			var fh:int = dhs + (oy * 2);
			
			var rect:Rectangle = new Rectangle(0, 0, dws, dhs);
			
			var vclip:Sprite;

			// define tiles
			//
			
			if (voronoi == null) {
				vclip = new Sprite();
				var v:Voronoi = new Voronoi(vclip, dws, dhs, 0xffffff, 0x000000, def.edgeThickness * sampleScale, def.cellsX, def.cellsY, def.perturbation, def.randomSeed);
				v.background = false;
				v.create( -1, false);
			} else {
				v = voronoi;
				vclip = v.clip;
			}
			
			var container:Sprite = new Sprite();
			
			var mapdata:BitmapData = new BitmapData(fw, fh, true, 0xff000000);
			var mapdata2:BitmapData = new BitmapData(fw, fh, true, 0xff000000);
			
			mapdata.fillRect(new Rectangle(0, 0, fw, fh), def.backgroundColor);
			
			// add noise
			//
			if (def.noiseLevel > 0) {
				mapdata2.noise(def.randomSeed, Math.max(0, 128 - def.noiseLevel * 3 * sampleScale), Math.min(255, 128 + def.noiseLevel * 3 * sampleScale), BitmapDataChannel.BLUE | BitmapDataChannel.GREEN | BitmapDataChannel.RED, true);
				if (def.smooth) {
					mapdata2.applyFilter(mapdata2, new Rectangle(0, 0, fw, fh), new Point(0, 0), new BlurFilter(2, 2, 2));
				}
				mapdata.draw(mapdata2, null, null, BlendMode.HARDLIGHT);
			}
			
			mapdata2.fillRect(new Rectangle(0, 0, fw, fh), 0xffffffff);

			// cut edge areas
			//
			if (def.tileMap.join("") != "111111111") {
			
				var cutData:BitmapData = new BitmapData(fw, fh, true);
				
				if (!def.cap) {
					
					v.thickness = 1;
					v.alpha = 0.5;
					v.background = true;
					v.redraw(-1, false);	

					cutData.draw(vclip, null, null, null, new Rectangle(0, 0, fw, fh));

					if (def.tileMap[0] == 0 || def.tileMap[1] == 0) cutTile(cutData, v.topLeftPoints);
					if (def.tileMap[1] == 0) cutTile(cutData, v.topPoints);
					if (def.tileMap[2] == 0 || def.tileMap[1] == 0) cutTile(cutData, v.topRightPoints);

					if (def.tileMap[3] == 0) cutTile(cutData, v.leftPoints);
					if (def.tileMap[4] == 0) cutTile(cutData, v.centerPoints);
					if (def.tileMap[5] == 0) cutTile(cutData, v.rightPoints);				
					
					if (def.tileMap[6] == 0 || def.tileMap[7] == 0) cutTile(cutData, v.bottomLeftPoints);	
					if (def.tileMap[7] == 0) cutTile(cutData, v.bottomPoints);
					if (def.tileMap[8] == 0 || def.tileMap[7] == 0) cutTile(cutData, v.bottomRightPoints);	
					
					v.thickness = def.edgeThickness * sampleScale;
					v.background = false;
					v.alpha = 1;
					
				} else {
					
					capTile(cutData, def, ox, oy);
					
				}

				mapdata2.draw(cutData);
			
			}
			
			if (def.smooth) {
				v.alpha = 0.05;
				v.thickness *= 0.5;
			}
			v.redraw(-1, false);	

			// paste mortar
			//
				
			if (stamp == null) {
				
				mapdata2.draw(vclip, null, null, BlendMode.MULTIPLY);
				
			} else {
				
				mapdata2.fillRect(new Rectangle(0, 0, fw, fh), 0x00000000);

				var m:Matrix = new Matrix();
				
				m.tx = (ox / 2 + dw / 2) / (dw / 60);
				m.ty = (oy / 2 + dh / 2) / (dh / 60);
				m.tx /= (Math.floor(TileDefinition.grid_width) / 60);
				m.ty /= (Math.floor(TileDefinition.grid_height) / 60);
				
				if (stampRotation != 0) {
					
					m.a = Math.cos(stampRotation);
					m.b = Math.sin(stampRotation);
					m.c = -Math.sin(stampRotation);
					m.d = Math.cos(stampRotation);

				}
				
				m.scale(sampleScale * (dw / 60), sampleScale * (dh / 60));
				
				mapdata2.draw(vclip, null, null, BlendMode.MULTIPLY);

				m.scale(Math.floor(TileDefinition.grid_width) / 60, Math.floor(TileDefinition.grid_height) / 60);
				mapdata2.draw(stamp, m, null, BlendMode.MULTIPLY);

			}
				
			if (def.smooth) mapdata2.applyFilter(mapdata2, new Rectangle(0, 0, fw, fh), new Point(0, 0), new BlurFilter(6, 6, 2));
			
			mapdata.copyChannel(mapdata2, new Rectangle(0, 0, fw, fh), new Point(0, 0), BitmapDataChannel.BLUE, BitmapDataChannel.ALPHA);
			mapdata2.fillRect(new Rectangle(0, 0, mapdata2.width, mapdata2.height), 0x00000000);
			
			mapdata2.draw(mapdata, new Matrix(1 / sampleScale, 0, 0, 1 / sampleScale), null, null, null, true);
			mapdata = mapdata2.clone();
	
			// create 3x3 tile for correct snapshot of filtered tile
			var tile:Bitmap;
			
			tile = new Bitmap();
			tile.bitmapData = mapdata;
			container.addChild(tile);
			
			var colorA:Number = def.backgroundColor - 0xff000000;
			var colorB:Number = def.backgroundColor - 0xff000000;
			
			colorA = ColorTools.getTintedColor(colorA, 0xffffff, 0.8);
			colorB = ColorTools.getTintedColor(colorB, 0x000000, 0.5);
			
			var hAlpha:Number = (def.recess) ? 0.2 : 0.6;
			
			if (def.edgeDepth > 0) {
				var edgeColor:Number = 0x000000;
				if (def.smooth) edgeColor = ColorTools.getTintedColor(edgeColor, 0x000000, 0.3);
				container.filters = [new BevelFilter(def.edgeDepth, 45, colorA, hAlpha, colorB, 0.3, def.edgeDepth + 1, def.edgeDepth + 1, 50, 2),
				new GlowFilter(colorB, 1, def.edgeDepth + 1, def.edgeDepth + 1, 3, 2, true),
				new GlowFilter(edgeColor, 1, def.edgeThickness + 2, def.edgeThickness + 2, 30, 3)
				];
			} else {
				container.filters = [new GlowFilter(colorB, 1, sampleScale * 0.75, sampleScale * 0.75, 30, 3, true),
					new GlowFilter(def.edgeColor, 1, def.edgeThickness + 1, def.edgeThickness + 1, 30, 3)];
			}

			var snapshot:BitmapData = destination;
			if (snapshot != null) snapshot.fillRect(new Rectangle(0, 0, snapshot.width, snapshot.height), 0x00000000);
			else snapshot = new BitmapData(dw, dh, true, 0x00000000);
			
			snapshot.draw(container, new Matrix(1, 0, 0, 1, 0 - ox / sampleScale, 0 - oy / sampleScale), null, null, new Rectangle(0, 0, dw, dh));
			
			mapdata.dispose();
			mapdata2.dispose();
			
			if (TileDefinition.scale != 1) {
				
				if (m == null) m = new Matrix();
				m.createBox(TileDefinition.scale, TileDefinition.scale);
				
				var snapshot2:BitmapData = new BitmapData(snapshot.width * TileDefinition.scale, snapshot.height * TileDefinition.scale, true, 0);
				
				snapshot2.draw(snapshot, m, null, null, null, true);
				return snapshot2;
				
			}
			
			return snapshot;

		}
		
		private static function cutTile (mapdata:BitmapData, points:Array, offsetX:int = 0, offsetY:int = 0):void {
			
			for each (var pt:Point in points) {
				mapdata.floodFill(Math.min(mapdata.width - 2, Math.max(1, pt.x - offsetX)), Math.min(mapdata.height - 2, Math.max(1, pt.y - offsetY)), 0xff000000);
				mapdata.setPixel(Math.min(mapdata.width - 2, Math.max(1, pt.x - offsetX)), Math.min(mapdata.height - 2, Math.max(1, pt.y - offsetY)), 0xffff0000);
			}
			
		}
		
		private static function capTile (mapdata:BitmapData, def:TileDefinition, ox:int = 0, oy:int = 0):void {

			var dw:int = def.width / TileDefinition.scale;
			var dh:int = def.height / TileDefinition.scale;
			
			var oxt:int = ox + def.edgeThickness * sampleScale;
			var oyt:int = oy + def.edgeThickness * sampleScale;

			oxt += 2;
			oyt += 2;

			var fw:int = dw * sampleScale + ox + ox;
			var fh:int = dh * sampleScale + oy + oy;
			
			var cw:int = dw / 4;
			var ch:int = dh / 4;
			
			var capColor:Number = 0xff000000;

			if (def.tileMap[0] == 0 || def.tileMap[1] == 0) mapdata.fillRect(new Rectangle(0, 0, oxt, oyt), capColor);
			if (def.tileMap[1] == 0) mapdata.fillRect(new Rectangle(0, 0, fw, oyt), capColor);
			if (def.tileMap[2] == 0 || def.tileMap[1] == 0) mapdata.fillRect(new Rectangle(fw - oxt, 0, oxt, oyt), capColor);

			if (def.tileMap[3] == 0) mapdata.fillRect(new Rectangle(0, 0, oxt, fh), capColor);
			if (def.tileMap[4] == 0) mapdata.fillRect(new Rectangle(oxt + cw, oyt + ch, fw - cw - cw - oxt * 2, fh - ch - ch - oyt * 2), capColor);
			if (def.tileMap[5] == 0) mapdata.fillRect(new Rectangle(fw - oxt, 0, oxt, fh), capColor);				
			
			if (def.tileMap[6] == 0 || def.tileMap[7] == 0) mapdata.fillRect(new Rectangle(0, fh - oyt, oxt, oyt), capColor);
			if (def.tileMap[7] == 0) mapdata.fillRect(new Rectangle(0, fh - oyt, fw, oyt), capColor);
			if (def.tileMap[8] == 0 || def.tileMap[7] == 0) mapdata.fillRect(new Rectangle(fw - oxt, fh - oyt, oxt, oyt), capColor);				
			
		}
		
		public static function pasteCapTile (tileData:BitmapData, capData:BitmapData, def:TileDefinition):BitmapData {

			var dw:int = def.width;
			var dh:int = def.height;
			
			var oxt:int = def.edgeThickness;
			var oyt:int = def.edgeThickness;
			
			oxt += 2;
			oyt += 2;

			var fw:int = dw;
			var fh:int = dh;
			
			var cw:int = dw / 4;
			var ch:int = dh / 4;

			var newData:BitmapData = tileData.clone();
			
			// remove cap section
			if (def.tileMap[0] == 0 || def.tileMap[1] == 0) newData.fillRect(new Rectangle(0, 0, oxt, oyt), 0x00000000);
			if (def.tileMap[1] == 0) newData.fillRect(new Rectangle(0, 0, fw, oyt), 0x00000000);
			if (def.tileMap[2] == 0 || def.tileMap[1] == 0) newData.fillRect(new Rectangle(fw - oxt, 0, oxt, oyt), 0x00000000);

			if (def.tileMap[3] == 0) newData.fillRect(new Rectangle(0, 0, oxt, fh), 0x00000000);
			if (def.tileMap[4] == 0) newData.fillRect(new Rectangle(cw, ch, fw - cw, fh - ch), 0x00000000);
			if (def.tileMap[5] == 0) newData.fillRect(new Rectangle(fw - oxt, 0, oxt, fh), 0x00000000);				
			
			if (def.tileMap[6] == 0 || def.tileMap[7] == 0) newData.fillRect(new Rectangle(0, fh - oyt, oxt, oyt), 0x00000000);
			if (def.tileMap[7] == 0) newData.fillRect(new Rectangle(0, fh - oyt, fw, oyt), 0x00000000);
			if (def.tileMap[8] == 0 || def.tileMap[7] == 0) newData.fillRect(new Rectangle(fw - oxt, fh - oyt, oxt, oyt), 0x00000000);				
			
			// paste cap
			if (def.tileMap[0] == 0 || def.tileMap[1] == 0) newData.draw(capData, null, null, null, new Rectangle(0, 0, oxt, oyt));
			if (def.tileMap[1] == 0) newData.draw(capData, null, null, null, new Rectangle(0, 0, fw, oyt));
			if (def.tileMap[2] == 0 || def.tileMap[1] == 0) newData.draw(capData, null, null, null, new Rectangle(fw - oxt, 0, oxt, oyt));

			if (def.tileMap[3] == 0) newData.draw(capData, null, null, null, new Rectangle(0, 0, oxt, fh));
			if (def.tileMap[4] == 0) newData.draw(capData, null, null, null, new Rectangle(oxt, oyt, fw - oxt, fh - oyt));
			if (def.tileMap[5] == 0) newData.draw(capData, null, null, null, new Rectangle(fw - oxt, 0, oxt, fh));				
			
			if (def.tileMap[6] == 0 || def.tileMap[7] == 0) newData.draw(capData, null, null, null, new Rectangle(0, fh - oyt, oxt, oyt));
			if (def.tileMap[7] == 0) newData.draw(capData, null, null, null, new Rectangle(0, fh - oyt, fw, oyt));
			if (def.tileMap[8] == 0 || def.tileMap[7] == 0) newData.draw(capData, null, null, null, new Rectangle(fw - oxt, fh - oyt, oxt, oyt));				
			
			return newData;
			
		}
		
	}
	
}