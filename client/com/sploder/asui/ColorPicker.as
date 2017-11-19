package com.sploder.asui {
	
    import com.sploder.asui.*;
    
	import flash.display.Sprite;
	import flash.events.Event;
    
    public class ColorPicker extends Cell {
		
		protected var _title:HTMLField;
        protected var _spectrum:ColorSpectrum;
		protected var _slider:Slider;
		protected var _field:FormField;
		public function get field():FormField { return _field; }
		
		protected var _chip:ColorChip;
		
		protected var _color:int = 0x999999;
		protected var _size:int = 100;
		protected var _textLabel:String = "";
		
		protected var _sliderStyle:Style;
		
		public var showFullPicker:Boolean = true;
		public var showColorWheelOnly:Boolean = false;
		public var dimColorWheel:Boolean = true;
        
        override public function get value ():String { return ColorTools.numberToHTMLColor(_color); }
		
		override public function set value(value:String):void 
		{
			super.value = value;
			if (value != "") color = ColorTools.HTMLColorToNumber(value);
			else color = -1;
			
			if (form != null && name.length > 0) form[name] = value;
			
		}
		
		public function get color():int { return _color; }
		
		public function set color(value:int):void {
			
			if (value >= 0 && value <= 0xffffff) {
				
				_color = value;
				if (showFullPicker) _slider.sliderValue = 1 - ColorTools.hex2hsv(_color).v / 100;
				if (showFullPicker) _spectrum.color = _color;
				setFieldValue();
				//setSliderColors();
				if (_chip) _chip.color = _color;
				if (_chip) _chip.mc.alpha = 1;

			} else if (value == -1) {
				
				if (_field) _field.value = "";
				_color = -1;
				if (_chip) _chip.color = 0xcccccc;
				if (_chip) _chip.mc.alpha = 0.3;
				
			}
			
		}

        //
        //
        //
        function ColorPicker (container:Sprite, color:int = 0x999999, size:int = 100, textLabel:String = "", position:Position = null, style:Style = null) {
            
            init_ColorPicker (container, color, size, textLabel, position, style);
            
            if (_container != null) create();
            
        }
        
        //
        //
        private function init_ColorPicker (container:Sprite, color:int = 0x999999, size:int = 100, textLabel:String = "", position:Position = null, style:Style = null):void {
            
            super.init_Cell(container, NaN, NaN, false, false, 0, position, style);
    
			 _type = "colorpicker";
			 
			_color = color;
			_size = size;
            _textLabel = (textLabel.length > 0) ? textLabel : _textLabel;

        }
        
        //
        //
        override public function create ():void {
            
            super.create();
			
			var contentStyle:Style = _style.clone( { embedFonts: false } );
			
			var brightness:Number = ColorTools.hex2hsv(_color).v / 100;

			if (_textLabel != "") {
				_title = new HTMLField(null, "<p><b>"+_textLabel+"<b></p>", _size + 10 + 16, false, new Position({ margin_bottom: 4 }), _style);
				addChild(_title);
			}
			
			if (showFullPicker || showColorWheelOnly) {
				_spectrum = new ColorSpectrum(null, _size, _size, new Position( { placement: Position.PLACEMENT_FLOAT, margin_right: 10, margin_bottom: 10 } ), contentStyle);
				_spectrum.dimColorWheel = dimColorWheel;
				addChild(_spectrum);
				_spectrum.color = _color;
				_spectrum.addEventListener(EVENT_CHANGE, onSpectrumChange);
				
				_sliderStyle = contentStyle.clone();
				_sliderStyle.bgGradient = true;
				setSliderColors();

				_slider = new Slider(null, 20, _size, Position.ORIENTATION_VERTICAL, 0, new Position( { placement: Position.PLACEMENT_FLOAT, margin_left: 4 } ), _sliderStyle);
				_slider.showGradient = true;
				addChild(_slider);
	
				_slider.ratio = 0.01;
				_slider.sliderValue = 1 - brightness;
				_slider.addEventListener(EVENT_CHANGE, onSliderChange);
			}
			
			if (!showColorWheelOnly) {
				_field = new FormField(null, "", _size, 26, true, new Position( { placement: Position.PLACEMENT_FLOAT, margin_right: 4, margin_bottom: 10, clear: Position.CLEAR_LEFT } ), contentStyle);
				addChild(_field);
				_field.value = _color.toString(16);
				_field.addEventListener(EVENT_CHANGE, onFieldChange);
				_field.restrict = "0123456789abcdef";
				_field.maxChars = 6;
				
				_chip = new ColorChip(null, _color, 26, 26, new Position({ margin_top: 0 }, Position.ALIGN_LEFT, Position.PLACEMENT_FLOAT), contentStyle);
				addChild(_chip);
			}
			
			_width = Position.getCellContentWidth(this);
			_height = Position.getCellContentHeight(this);

        }
		
		//
		//
		protected function setSliderColors ():void {
			
			var bc_hsv:Object = ColorTools.hex2hsv(_color);
			bc_hsv.v = 90;
			
			var dc_hsv:Object = ColorTools.hex2hsv(_color);
			dc_hsv.v = 10;
			
			_sliderStyle.bgGradientColors = [
				ColorTools.hsv2hex(bc_hsv.h, bc_hsv.s, bc_hsv.v),
				ColorTools.hsv2hex(dc_hsv.h, dc_hsv.s, dc_hsv.v)
				];
				
			if (_slider != null) _slider.background = true;
			
		}
		
		//
		//
		protected function setFieldValue ():void {
			
			if (_color != -1) {
				if (_field) {
					_field.value = _color.toString(16);
					while (_field.value.length < 6) _field.value = "0" + _field.value;
				}
			} else {
				if (_field) _field.value = "";
			}
			
		}

		//
		//
		protected function onSliderChange (e:Event):void {
			
			if (_spectrum.brightness != 1 - _slider.sliderValue) {
				
				_spectrum.brightness = 1 - _slider.sliderValue;
				_color = _spectrum.color;
				setFieldValue();
				setSliderColors();
				if (_chip) _chip.color = _color;

			}
			
			dispatchEvent(new Event(EVENT_CHANGE));
			
		}
		
		//
		//
		protected function onSpectrumChange (e:Event):void {
			if (_slider.sliderValue > 0.8) {
				_slider.sliderValue = 0.6;
				_spectrum.brightness = 1 - _slider.sliderValue;
			}
			_color = _spectrum.color;
			
			
			setFieldValue();
			setSliderColors();
			if (_chip) _chip.color = _color;

			dispatchEvent(new Event(EVENT_CHANGE));

		}
		
		//
		//
		protected function onFieldChange (e:Event):void {
			
			if (_field.value.length == 6 && 
				parseInt(_field.value, 16) >= 0 &&
				parseInt(_field.value, 16) <= 0xffffff) {
					
					_color = parseInt(_field.value, 16);
					if (showFullPicker) _slider.sliderValue = 1 - ColorTools.hex2hsv(_color).v / 100;
					if (showFullPicker) _spectrum.color = _color;
					if (_chip) {
						_chip.color = _color;
						_chip.mc.alpha = 1;
					}
					

			} else {
				
				if (_chip) _chip.mc.alpha = 0.3;
			}
				
			dispatchEvent(new Event(EVENT_CHANGE));

		}
 
    }
	
}
