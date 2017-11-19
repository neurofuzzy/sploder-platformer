package com.sploder.builder 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import fuz2d.util.TileDefinition;
	import fuz2d.util.TileGenerator;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class CreatorTextureItem extends Sprite
	{
		protected var _creator:Creator;
		protected var _tilenum:int;
		protected var _bitmap:Bitmap;
		
		public function CreatorTextureItem (creator:Creator, tilenum:int = 120) 
		{
			init(creator, tilenum);
		}
		
		protected function init (creator:Creator, tilenum:int = 120):void {
			
			_creator = creator;
			_tilenum = tilenum;
			_bitmap = new Bitmap(null);
			
			generateTexture();
			
			addChild(_bitmap);
			
			mouseEnabled = mouseChildren = false;
			
			graphics.beginFill(0, 1);
			graphics.lineTo(60, 0);
			graphics.lineTo(60, 60);
			graphics.lineTo(0, 60);
			graphics.endFill();
			
		}
		
		protected function generateTexture ():void {
			
			if (_bitmap.bitmapData) _bitmap.bitmapData.dispose();
			
			_bitmap.bitmapData = TileGenerator.makeTile(new TileDefinition(tilenum, false, "", 60, 60, 0xff998844, 0xff660000, 2, 4, 4, 0.3, 1, false, 7, false, false, 1, false, false,
			[0, 0, 0, 0, 1, 0, 0, 0, 0]));
			
		}
		
		public function get tilenum():int { return _tilenum; }
		
		public function set tilenum(value:int):void 
		{
			_tilenum = value;
			generateTexture();
		}
		
	}

}