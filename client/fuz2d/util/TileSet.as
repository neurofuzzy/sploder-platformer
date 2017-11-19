/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.util {
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	import fuz2d.util.TileDefinition;
	import fuz2d.util.TileGenerator;
	import fuz2d.util.Voronoi;
	
	public class TileSet {
		
		protected var _def:TileDefinition;
		protected var _tiles:Object;
		protected var _voronoi:Voronoi;
		
		// translate between angle units
		private static var dtr:Number = Math.PI / 180;
		private static var rtd:Number = 180 / Math.PI;
		
		//
		//
		public function TileSet (def:TileDefinition) {
			
			init(def);
			
		}
		
		//
		//
		private function init (def:TileDefinition):void {
			
			_def = def;
			
			makeTiles();
			
		}
		
		private function makeTiles ():void {
			
			_tiles = { };

			_voronoi = TileGenerator.makeVoronoi(_def);
			
			_def.tileMap = [
				1, 1, 1,
				1, 1, 1, 
				1, 1, 1
				];
			var tileData:BitmapData = _tiles["tile_" + _def.tileMap.join("")] = TileGenerator.makeTile(_def, null, _voronoi);

			_def.tileMap = [
				0, 0, 0,
				0, 1, 0, 
				0, 0, 0
				];
			var capData:BitmapData = _tiles["tile_" + _def.tileMap.join("")] = TileGenerator.makeTile(_def, null, _voronoi);
			
			var nMap:Array = [
				0, 1, 0, 0, 0, 0, 0, 0, 1, 0,
				1, 1, 1, 0, 1, 1, 1, 0, 1, 1,
				0, 0, 0, 0, 1, 1, 1, 0, 1, 0,
				0, 0, 0, 0, 1, 1, 1, 0, 0, 0,
			    0, 1, 1, 1, 1, 1, 1, 1, 1, 0,
				0, 1, 1, 1, 1, 1, 1, 1, 1, 0,
				0, 1, 1, 1, 1, 1, 1, 1, 1, 0,
				0, 0, 0, 0, 1, 1, 1, 0, 0, 0,
				0, 0, 0, 0, 1, 1, 1, 0, 1, 0,
				0, 0, 0, 0, 0, 0, 0, 0, 1, 0,
				0, 1, 1, 1, 0, 0, 1, 0, 1, 0,
				0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
				0, 1, 0, 0, 0, 0, 0, 0, 1, 0,
				1, 1, 0, 1, 1, 1, 0, 1, 1, 1,
				0, 1, 0, 0, 1, 0, 0, 0, 1, 0,
				0, 0, 0, 0, 0, 0, 1, 0, 1, 0,
				1, 1, 0, 1, 1, 1, 1, 0, 1, 1,
				0, 1, 0, 1, 0, 0, 0, 0, 0, 0,
				];
				
			for (var y:int = 1; y < 17; y++) {
				
				for (var x:int = 1; x < 10; x++) {
					
					_def.tileMap = [];
					for (var j:int = y - 1; j <= y + 1; j++) {
						for (var i:int = x - 1; i <= x + 1; i++) {
							_def.tileMap.push(nMap[j * 10 + i]);
						}
					}

					//if (_def.cap) {
						_def.tileMap[0] = (_def.tileMap[1] == 0 || _def.tileMap[3] == 0) ? 0 : _def.tileMap[0];
						_def.tileMap[2] = (_def.tileMap[1] == 0 || _def.tileMap[5] == 0) ? 0 : _def.tileMap[2];
						_def.tileMap[6] = (_def.tileMap[3] == 0 || _def.tileMap[7] == 0) ? 0 : _def.tileMap[6];
						_def.tileMap[8] = (_def.tileMap[5] == 0 || _def.tileMap[7] == 0) ? 0 : _def.tileMap[8];	
					//}
					
					if (_def.tileMap[4] == 1 && _tiles["tile_" + _def.tileMap.join("")] == null) {
						if (_def.cap) _tiles["tile_" + _def.tileMap.join("")] = TileGenerator.pasteCapTile(tileData, capData, _def);			
						else _tiles["tile_" + _def.tileMap.join("")] = TileGenerator.makeTile(_def, null, _voronoi);
					}
					
				}
				
			}
			
			_def.tileMap = [1, 1, 1, 1, 0, 1, 1, 1, 1];
			
			var cap:Boolean = _def.cap;
			_tiles["tile_" + _def.tileMap.join("")] =  TileGenerator.makeTile(_def, null, _voronoi);
			_def.cap = true;
			_def.cap = cap;
			
			
		}
		
		//
		//
		public function getTile (tileMap:Array = null, stampName:String = "", stamp:Sprite = null, rotation:Number = 0):BitmapData {
			
			if (stampName != null && stampName.length > 0 && stamp != null) {
				var tileName:String = "tile_" + stampName + "_" + Math.floor(rotation * rtd);
				if (_tiles[tileName] == undefined) {
					_def.tileMap = [1, 1, 1, 1, 1, 1, 1, 1, 1];
					_tiles[tileName] = TileGenerator.makeTile(_def, null, _voronoi, stamp, rotation); 
				}
				if (_tiles[tileName] != null) {
					return BitmapData(_tiles[tileName]);
				}
			}
			
			if (tileMap == null) {
				if (_tiles["tile_111111111"] != undefined) return _tiles["tile_111111111"]; 
				return null;
			}
			
			//if (_def.cap) {
				tileMap[0] = (tileMap[1] == 0 || tileMap[3] == 0) ? 0 : tileMap[0];
				tileMap[2] = (tileMap[1] == 0 || tileMap[5] == 0) ? 0 : tileMap[2];
				tileMap[6] = (tileMap[3] == 0 || tileMap[7] == 0) ? 0 : tileMap[6];
				tileMap[8] = (tileMap[5] == 0 || tileMap[7] == 0) ? 0 : tileMap[8];
			//}

			if (_tiles["tile_" + tileMap.join("")] == undefined) {
				if (_tiles["tile_111111111"] != undefined) return _tiles["tile_111111111"]; 
				return null;
			}
			
			return BitmapData(_tiles["tile_" + tileMap.join("")]);
			
		}
		
		public function end ():void {
			
			if (_tiles != null) {
				
				for (var tile:String in _tiles) {
					
					if (_tiles[tile] is BitmapData) {
						BitmapData(_tiles[tile]).dispose();
					}
					
				}
				
			}
			
		}
		
	}
	
}