package com.sploder.asui 
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Matrix;
	/**
	 * ...
	 * @author ...
	 */
	public class ProgressBar extends Component 
	{
		protected var _stage:Stage;
		
		protected var _bar:Sprite;
		protected var _barTexture:Sprite;
		
		protected var _percent:Number = 0;
		private var _texture:BitmapData;
		private var _m:Matrix;
		public function get percent():Number { return _percent; }
		public function set percent(value:Number):void 
		{
			_percent = value;
			_bar.scaleX = Math.max(0.1, Math.min(1, _percent));
		}
		
		public function ProgressBar (container:Sprite = null, width:Number = NaN, height:Number = NaN, position:Position = null, style:Style = null)
		{
			init_ProgressBar (container, width, height, position, style);
            
            if (_container != null) create();
            
        }
        
        //
        //
        protected function init_ProgressBar (container:Sprite = null, width:Number = NaN, height:Number = NaN, position:Position = null, style:Style = null):void {
  
            super.init(container, position, style);
			
			_width = width;
			_height = height;
			_type = "progressbar";
			
		}
		
		override public function create():void 
		{
			super.create();
			
			if (isNaN(_width)) _width = _parentCell.width - _parentCell.style.padding * 2;
			if (isNaN(_height)) _height = 24;
			
			DrawingMethods.emptyRect(_mc, false, 0, 0, _width, _height, 2, ColorTools.getTintedColor(_style.borderColor, _style.backgroundColor, 0.7));
            DrawingMethods.roundedRect(_mc, false, 2, 2, _width - 4, _height - 4, "0", [_style.inputColorA, _style.inputColorB]);
    
			_bar = new Sprite();
			_mc.addChild(_bar);
			
			DrawingMethods.roundedRect(_bar, false, 3, 3, _width - 6, _height - 6, "0", [style.unselectedColor], [style.backgroundAlpha], [1]);
            DrawingMethods.roundedRect(_bar, false, 3, 3, _width - 6, _height - 6, "0", [0xffffff, 0xffffff, 0x000000, 0x000000], [0.40, 0.15, 0, 0.10], [0, 128, 128, 255]);

			_texture = new BitmapData(20, 20, true, 0);
			for (var y:int = 0; y < _texture.height; y++) {
				for (var x:int = 0; x < _texture.width; x++) {
					_texture.setPixel32(x, y, ((Math.sin(x / Math.PI) + 1) * 20) << 24 | 0x00ffffff);
				}
			}
			_m = new Matrix();
			_m.createBox(1, 1);
			
			_barTexture = new Sprite();
			_mc.addChild(_barTexture);
			
			if (_mc.stage) {
				onAdded();
			} else {
				_mc.addEventListener(Event.ADDED_TO_STAGE, onAdded, false, 0, true);
			}
			
		}
		
		protected function animate (e:Event):void {
			
			_m.tx -= 1;
			_m.tx %= 20;
			_barTexture.graphics.clear();
			_barTexture.graphics.beginBitmapFill(_texture, _m);
			_barTexture.graphics.drawRect(3, 3, _bar.width, _height - 6);
			_barTexture.graphics.endFill();
			
		}
		
		protected function onAdded (e:Event = null):void {
			
			if (_mc.stage) {
				_stage = _mc.stage;
				_stage.addEventListener(Event.ENTER_FRAME, animate, false, 0, true);
				_mc.addEventListener(Event.REMOVED_FROM_STAGE, onRemoved, false, 0, true);
			}
			
		}
		
		protected function onRemoved (e:Event):void {
			
			if (_stage) {
				_stage.removeEventListener(Event.ENTER_FRAME, animate);
				_mc.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
				_mc.addEventListener(Event.ADDED_TO_STAGE, onAdded, false, 0, true);
			}
			
		}
		
	}

}