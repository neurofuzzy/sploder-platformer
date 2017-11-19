/**
* Fuz3d: 3d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.model.material {
	
	import flash.display.BitmapData;

	public class TextureMap {
		
		public var name:String;
		public var type:String;
		public var filename:String;
		public var loaded:Boolean;
		public var bitmap:BitmapData;
		
		public var width:uint;
		public var height:uint;
		
		public var shade:Boolean = false;
		
		protected var _bleed:Boolean = false;
		
		//
		//
		public function TextureMap (name:String, type:String, filename:String = null) {
			
			init(name, type, filename);
			
		}
		
		//
		//
		private function init (name:String, type:String, filename:String = null):void {
			
			this.name = name;
			this.type = type;
			this.filename = filename;
			loaded = false;
		
			if (filename != null && filename.length > 0) MapManager.addMap(filename, this);
			
		}
		
		//
		//
		public function setBitmap (bitmap:BitmapData, bleed:Boolean = false):void {
			
			loaded = true;
			this.bitmap = bitmap;
			
			width = bitmap.width;
			height = bitmap.height;
			
			_bleed = bleed;
			
			if (_bleed) {
				width -= 2;
				height -= 2;
			}
			
		}
		
	}
	
}
