package fuz2d.model.object {
	
	import com.sploder.util.Textures;
	import flash.display.*;
	import flash.geom.Matrix;
	import fuz2d.library.EmbeddedLibrary;
	import fuz2d.model.material.Material;
	import fuz2d.model.Model;
	import fuz2d.screen.BitView;
	import fuz2d.screen.View;
	import fuz2d.util.TileDefinition;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class Tile extends Symbol {
		
		override public function get symbolExists():Boolean { return true; }
		
		override public function get cacheAsBitmap():Boolean { return true; }

		protected var _definitionID:String;
		public function get definitionID():String { return _definitionID; }
		
		protected var _stampName:String = "";
		public function get stampName():String { return _stampName; }
		
		override public function get bitmapData():BitmapData { 
			if (_bitmapData == null) getTileBitmapData();
			return _bitmapData; 
		}
		
		override public function get symbolWidth():Number { return _width; }
		override public function get symbolHeight():Number { return _height; }
		
		protected var _tileScale:int = 1;
		
		public function Tile(definitionID:String, stampName:String, library:EmbeddedLibrary, material:Material = null, parentObject:Point2d = null, x:Number = 0, y:Number = 0, z:Number = 0, rotation:Number = 0, castShadow:Boolean = true, receiveShadow:Boolean = true, tilescale:int = 1) {

			_definitionID = definitionID;
			_stampName = stampName;
			_tileScale = tilescale;
			
			super(definitionID, library, material, parentObject, x, y, z, rotation, 1, 1, true, castShadow, receiveShadow);

		}
		
		override protected function initSymbol ():void {
			
			var def:TileDefinition = _library.getTileDefinition(_definitionID);

			if (def.width > 0 && def.height > 0) {
				
				_width = Math.floor(def.width / View.scale * BitView.pixelScale);
				_height = Math.floor(def.height / View.scale * BitView.pixelScale);
				
			} else {
				
				_width = _height = Math.floor(Model.GRID_WIDTH * View.scale);
				
			}
			
			_initialized = true;
			
		}
		
		override public function get clip ():Sprite {
			
			var s:Sprite = new Sprite();
			s.addChild(clipAsBitmap);
		
			return s;
			
		}
		
		override public function get clipAsBitmap ():Bitmap {
			
			return new Bitmap(bitmapData, PixelSnapping.ALWAYS, false);

		}
		
		protected function getTileBitmapData ():void {
			
			var tileMap:Array = null;
			
			if (_initialized) {
				
				if (graphic > 0)
				{
					var size:int = _width;
					var texture_name:String = graphic + "_" + graphic_version;
					
					_bitmapData = Textures.getOriginal("bitview_" + texture_name + "_" + size);
					
					if (_bitmapData != null) return;
					
					var orig_bd:BitmapData = Textures.getScaledBitmapData(texture_name, 8, 0);
					
					if (orig_bd != null)
					{
						var m:Matrix = new Matrix();
						m.createBox(_width / orig_bd.width * EmbeddedLibrary.scale , _height / orig_bd.height * EmbeddedLibrary.scale );
						
						_bitmapData = new BitmapData(_width * EmbeddedLibrary.scale , _height * EmbeddedLibrary.scale , true, 0);
						_bitmapData.draw(orig_bd, m, null, null, null, true);
						Textures.setOriginal("bitview_" + texture_name + "_" + size, _bitmapData);
					}
					
					return;
					
				}
				
				var neighbors:Array = _model.getNearObjects(this);

				tileMap = [0, 0, 0, 0, 1, 0, 0, 0, 0];
				
				var ox:int = 0;
				var oy:int = 0;
				
				var idx:int = 0;
				
				for each (var neighbor:Object2d in neighbors) {
					
					if (neighbor is Tile && Tile(neighbor).symbolName == _symbolName) {
						
						ox = (neighbor.x - x) / _width;
						oy = (neighbor.y - y) / _height;
						oy = 0 - oy;
						
						if (Math.abs(ox) <= 1 && Math.abs(oy) <= 1) {

							idx = 4 + (oy * 3) + ox;
							tileMap[idx] = 1;
						
						}
						
					}
					
				}
				
			}
			
			_bitmapData = _library.getTileBitmapData(symbolName, tileMap, _stampName, rotation, false, _tileScale);
			
		}
		
		override public function set turned (value:Boolean):void {
			
		}
		
		/*
		override public function get moved ():Boolean {
			return false;
		}
		
		override public function get turned ():Boolean {
			return false;
		}
		*/
		
	}
	
}