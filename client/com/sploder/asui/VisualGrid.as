package com.sploder.asui 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class VisualGrid extends Cell
	{
		
		protected var _spacing:int;
		
		public function VisualGrid (container:Sprite, width:Number = NaN, height:Number = NaN, spacing:Number = 10, position:Position = null, style:Style = null):void
		{
			init_VisualGrid(container, width, height, spacing, position, style);
            if (_container != null) create();
		}
		
		protected function init_VisualGrid (container:Sprite, width:Number = NaN, height:Number = NaN, spacing:Number = 10, position:Position = null, style:Style = null):void
		{
			super.init_Cell(container, width, height, false, false, 0, position, style);
			
			_spacing = spacing;
			
		}
		
		//
        //
        override public function create ():void
		{
            super.create();
			
			if (isNaN(_width) || isNaN(_height) || _width <= 0 || _height <= 0) {
				
				if (_mc && _mc.stage) {
					
					if (_parentCell && _parentCell.width > 0 && _parentCell.height > 0) {
						
						_width = _parentCell.width;
						_height = _parentCell.height;
						
					} else {
					
						_width = _mc.stage.stageWidth;
						_height = _mc.stage.stageHeight;
						
					}
					
				}
				
			}
			
			if (_width > 0 && _height > 0) {
				
				var bm:Bitmap = new Bitmap(new BitmapData(_width, _height, true, 0));
				var bd:BitmapData = bm.bitmapData;
				bm.smoothing = true;
				
				for (var y:int = 0; y < _height; y += _spacing) {
					
					for (var x:int = 0; x < _width; x += _spacing) {
					
						if (x > 0 && y > 0) bd.setPixel32(x, y, 0xff000000 + _style.borderColor);
					
					}				
					
				}
				
				_mc.addChild(bm);
				
			}
			
		}
			
		
	}

}