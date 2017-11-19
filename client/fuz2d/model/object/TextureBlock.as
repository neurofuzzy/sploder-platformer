package fuz2d.model.object {
	
	import com.sploder.texturegen_internal.TextureAttributes;
	import com.sploder.texturegen_internal.TextureRendering;
	import flash.display.*;
	import fuz2d.library.EmbeddedLibrary;
	import fuz2d.model.material.Material;
	import fuz2d.screen.BitView;
	import fuz2d.screen.View;
	
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class TextureBlock extends Symbol {
		
		override public function get symbolExists():Boolean { return true; }
		
		override public function get cacheAsBitmap():Boolean { return true; }

		protected var _txAttribs:TextureAttributes;
		public function get txAttribs():TextureAttributes 
		{
			return _txAttribs;
		}
		
		public function set txAttribs(value:TextureAttributes):void 
		{
			_txAttribs = value;
		}
		
		public var tileBack:Boolean;
		
		override public function get bitmapData():BitmapData { 
			if (_bitmapData == null) getTextureBitmapData();
			return _bitmapData; 
		}
		
		override public function get symbolWidth():Number { return _width; }
		override public function get symbolHeight():Number { return _height; }
		
		public function TextureBlock(tileBack:Boolean, library:EmbeddedLibrary, material:Material = null, parentObject:Point2d = null, x:Number = 0, y:Number = 0, z:Number = 0, rotation:Number = 0, castShadow:Boolean = true, receiveShadow:Boolean = true) {
			
			this.tileBack = tileBack;
			
			super("textureblock", library, material, parentObject, x, y, z, rotation, 1, 1, true, castShadow, receiveShadow);
			
		}
		
		override protected function initSymbol ():void {
			
			_width = 120;
			_height = 120;
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
		
		public function preload ():void
		{
			getTextureBitmapData();
		}
		
		protected function getTextureBitmapData ():void {
			
			if (_initialized && _txAttribs != null) {
				
				var border:int = TextureRendering.BORDER_TYPE_ALL;
				
				if (!tileBack)
				{
					var neighbors:Array = _model.getNearObjects(this);
					var tileMap:Array = [0, 0, 0, 0, 1, 0, 0, 0, 0];
					
					var ox:int = 0;
					var oy:int = 0;
					
					var idx:int = 0;
					
					for each (var neighbor:Object2d in neighbors) {
						
						if (neighbor is TextureBlock && !TextureBlock(neighbor).tileBack) {
							
							ox = (neighbor.x - x < 0) ? Math.floor((neighbor.x - x) / _width) : Math.ceil((neighbor.x - x) / _width);
							oy = (neighbor.y - y < 0) ? Math.floor((neighbor.y - y) / _height) : Math.ceil((neighbor.y - y) / _height);
							oy = 0 - oy;
							
							if (Math.abs(ox) <= 1 && Math.abs(oy) <= 1) {
								
								idx = 4 + (oy * 3) + ox;
								tileMap[idx] = 1;
							
							}
							
						}
						
					}
					
					border = TextureRendering.getBorderFromTileMap(tileMap);
				}
				
				_bitmapData = _library.getTextureBitmapData(_txAttribs, Math.floor(_width * EmbeddedLibrary.scale), border);
			}
			
		}
		
		override public function set turned (value:Boolean):void {
			
		}
		
	}
	
}