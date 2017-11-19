package com.sploder.asui {
	
    import com.sploder.asui.*;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import flash.display.DisplayObject;
	import flash.display.Sprite;

    /**
    * ...
    * @author $(DefaultUser)
    */
    
    
    public class ColorSpectrum extends Component {
        
		protected var _btn:Sprite;
		protected var _bitmapData:BitmapData;
		protected var _bitmap:Bitmap;
		protected var _bitmapMask:Sprite;
		
		protected var _color:Number = 0x000000;
		protected var _brightness:Number = 1;
		
		public var dimColorWheel:Boolean = true;
        
        //
        //
        public function ColorSpectrum (container:Sprite, width:int, height:int, position:Position = null, style:Style = null) {
            
            init_ColorSpectrum (container, width, height, position, style);
            
            if (_container != null) create();
            
        }
        
        //
        //
        private function init_ColorSpectrum (container:Sprite, width:int, height:int, position:Position = null, style:Style = null):void {
            
            super.init(container, position, style);

			_type = "spectrum";
			
            _width = width;
            _height = height;
     
        }
        
        //
        //
        override public function create ():void {
            
            super.create();
            
			_bitmapData = new BitmapData(_width, _height, true, 0xff000000 + _style.backgroundColor);
			
			_bitmap = new Bitmap(_bitmapData);
			
			_mc.addChild(_bitmap);
			
			_bitmapMask = new Sprite();
			_bitmapMask.graphics.beginFill(0xff00000, 1);
			_bitmapMask.graphics.drawCircle(width / 2, height / 2, Math.min(width / 2, height / 2));
			_bitmap.mask = _bitmapMask;
			
			_mc.addChild(_bitmapMask);
			
			_btn = new Sprite();
			_btn.graphics.lineStyle(2, _style.borderColor);
			_btn.graphics.beginFill(0xffffff, 0);
			_btn.graphics.drawCircle(width / 2, height / 2, Math.min(width / 2, height / 2));
			_btn.buttonMode = true;
			_mc.addChild(_btn);
			
			_btn.addEventListener(MouseEvent.CLICK, pickColor);
			_btn.addEventListener(MouseEvent.MOUSE_DOWN, onBtnPress);
			_btn.addEventListener(MouseEvent.MOUSE_OUT, onBtnRelease);
			_btn.addEventListener(MouseEvent.MOUSE_UP, onBtnRelease);
			drawSpectrum();
			
        }
		
		protected function onBtnPress (e:MouseEvent):void {
			
			_btn.addEventListener(MouseEvent.MOUSE_MOVE, pickColor);
			
		}
		
		protected function onBtnRelease (e:MouseEvent):void {
			
			_btn.removeEventListener(MouseEvent.MOUSE_MOVE, pickColor);
			
		}
		
		//
		//
		protected function drawSpectrum ():void {
			
			var c:int;
			var r:int = Math.min(_width, _height) * 0.5;
			var a:Number;
			var p:Point = new Point();
			var s:Number = 0;
			var out:Boolean = false;
			
			for (var j:int = 0; j < _height; j++) {
				
				for (var i:int = 0; i < _width; i++) {
					
					p.x = i - r;
					p.y = j - r;
					
					s = Math.abs(p.length / r);
					a = (Math.PI + Math.atan2(p.y, p.x)) * (180 / Math.PI);
					
					out = (s > 1);
					
					if (s > 1) s = 1;

					if (dimColorWheel) c = ColorTools.hsv2hex(a, s * 100, _brightness * 100);
					else c = ColorTools.hsv2hex(a, s * 100, 100);
					
					if (s > 1) c = _style.backgroundColor;
					
					_bitmapData.setPixel(i, j, c);
					
				}
	
			}
			
		}

		
		protected function pickColor (e:MouseEvent):void {
			
			var c:int;
			var r:int = Math.min(_width, _height) * 0.5;
			var a:Number;
			var p:Point = new Point();
			var s:Number = 0;
			var out:Boolean = false;
				
			p.x = e.localX - r;
			p.y = e.localY - r;
					
			s = Math.abs(p.length / r);
			a = (Math.PI + Math.atan2(p.y, p.x)) * (180 / Math.PI);
					
			if (s > 1) s = 1;

			_color = ColorTools.hsv2hex(a, s * 100, _brightness * 100);

			dispatchEvent(new Event(EVENT_CHANGE));
			
		}
		
		public function get color():Number { return _color; }
		
		public function set color(val:Number):void 
		{
			_color = val;

			var hsv:Object = ColorTools.hex2hsv(_color);
			_brightness = hsv.v / 100;

			drawSpectrum();
			
		}
		
		public function get brightness():Number { return _brightness; }
		
		public function set brightness(val:Number):void {
			
			_brightness = val;
			
			var hsv:Object = ColorTools.hex2hsv(_color);
			hsv.v = _brightness * 100;
			_color = ColorTools.hsv2hex(hsv.h, hsv.s, hsv.v);
			
			drawSpectrum();

		}
   
    }
	
}
