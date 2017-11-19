package com.sploder.asui {
	
    import com.sploder.asui.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.AntiAliasType;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	
	import flash.display.Sprite;
	import flash.text.TextField;
    
    /**
    * ...
    * @author $(DefaultUser)
    */
    
    
    public class HTMLField extends Component implements IComponent {

        private var _text:String;
        private var _tf:TextField;
		protected var _alt:String = "";
		public var autoSize:String = TextFieldAutoSize.LEFT;
        
        private var _multiLine:Boolean = true;
        
        private var _textOverflowing:Boolean = false;
        public function get textOverflowing():Boolean { return _textOverflowing; }
        
        private var _otf:TextField;
        private var _otfButton:Sprite;
        
        override public function get value ():String { return _text; }
        override public function set value (val:String):void { reset(val); }
		
		public function set width (value:uint):void { _width = _tf.width = value; }
		public function set height (value:uint):void { _tf.autoSize = TextFieldAutoSize.NONE; _height = _tf.height = value; }
		
		public function set outerWidth (value:uint):void {
			_width = value;
			if (_tf) _tf.x = (_width - _tf.width) * 0.5;
		}
		
		public function set outerHeight (value:uint):void {
			_height = value;
			if (_tf) _tf.y = (_height - _tf.height) * 0.5 - 3;
		}
		
		public function set boundsWidth (value:uint):void {
			_width = value;
		}
		
		public function set boundsHeight (value:uint):void {
			_height = value;
		}
		
		public function set innerX (value:int):void {
			if (_tf) _tf.x = value;
		}
		
		public function set innerY (value:int):void {
			if (_tf) _tf.y = value;
		}
		
		override public function set rotation (value:Number):void {
			_tf.rotation = value;
		}
		
		public function get alt ():String { return _alt; }
        public function set alt (value:String):void { _alt = value; }
		
		public function get tf():TextField 
		{
			return _tf;
		}
		
		public var linkEvent:String = "";

        //
        //
        public function HTMLField (container:Sprite, text:String, width:Number = NaN, multiLine:Boolean = false, position:Position = null, style:Style = null) {
            
            init_HTMLField(container, text, width, multiLine, position, style);
	
            if (_container != null) create();
            
        }
        
        //
        //
        private function init_HTMLField (container:Sprite, text:String, width:Number = NaN, multiLine:Boolean = false, position:Position = null, style:Style = null):void {
            
            super.init(container, position, style);
			
			_type = "htmlfield";
            
            _text = text;
            _width = width;
            
            _multiLine = multiLine;
    
        }
        
        //
        //
        override public function create ():void {
 
            super.create();
            
            if (_text == null || _text == "null" || _text == "undefined") return;
            
			_tf = new TextField();
			_tf.width = 500;
			_tf.height = 10;
			_mc.addChild(_tf);
            
            _tf.selectable = false;
            _tf.autoSize = autoSize;
            _tf.multiline = _multiLine;
            _tf.wordWrap = _multiLine;
            
            _tf.condenseWhite = true;
            _tf.embedFonts = _style.embedFonts;
            
            if (_style.embedFonts) {
                
                if (_text.indexOf("<h") == -1) {
                    _tf.setTextFormat(new TextFormat(_style.font, _style.fontSize, _style.textColor, false));
					_tf.defaultTextFormat = new TextFormat(_style.font, _style.fontSize, _style.textColor, false);
                	_style.htmlFont = _style.font;
				} else {
                    _tf.setTextFormat(new TextFormat(_style.titleFont, _style.titleFontSize, _style.titleColor, true));
					_tf.defaultTextFormat = new TextFormat(_style.titleFont, _style.titleFontSize, _style.titleColor, true);
               		_style.htmlFont = _style.titleFont;
				}
              
                //_tf.text = stripTags(_text);
				
				_tf.styleSheet = _style.styleSheet;
				_tf.htmlText = _text;
				_tf.antiAliasType = AntiAliasType.ADVANCED;
    
            } else {
                
                _tf.styleSheet = _style.styleSheet;
                _tf.htmlText = _text;
                
            }
    
            // NOTE: this makes no sense. switching off autosize causes the field to collapse. flash text sizing is just broken.
            
            if (!isNaN(_width) && _width > 0) {
                
                if (!_multiLine) _height = _tf.height; // record autosize height;
                
                var oldWidth:Number = _tf.width;
                
                if (!_multiLine) _tf.autoSize = TextFieldAutoSize.NONE; // turn off autosize (collapse!)
                
                _tf.width = _width;
                
                if (!_multiLine) _tf.height = _height; // restore proper height
                if (!_multiLine && oldWidth > _width) _textOverflowing = true;
				
            } else if (isNaN(_width) && _parentCell != null) {
                
                _tf.width = _parentCell.width - _position.margin_right - _position.margin_left;

            }
			
            // set component size to textfield size
            _width = _tf.width;
            _height = _tf.height;
            
            if (textOverflowing) {
    
				_otf = new TextField();
				_mc.addChild(_otf);
				_otf.x = _tf.x + _tf.width - 15;
				_otf.y = _tf.y;
				_otf.width = 15;
				_otf.height = _tf.height;
				        
                _otf.background = true;
                _otf.backgroundColor = _style.backgroundColor;
                
                if (_text.indexOf("<h") == -1) {
                    _otf.setTextFormat(new TextFormat(_style.font, _style.fontSize, _style.textColor, true, false, false, "", "", "right"));
					_otf.defaultTextFormat = new TextFormat(_style.font, _style.fontSize, _style.textColor, false);
                } else {
                    _otf.setTextFormat(new TextFormat(_style.titleFont, _style.titleFontSize, _style.titleColor, true, false, false, "", "", "right"));
               		_otf.defaultTextFormat = new TextFormat(_style.titleFont, _style.titleFontSize, _style.titleColor, true);
				}
				
				_otf.styleSheet = _style.styleSheet;
				
				if (_style.embedFonts) {
					_otf.embedFonts = true;
					_otf.antiAliasType = AntiAliasType.ADVANCED;
				}

                _otf.selectable = false;
                _otf.htmlText = '<p><a class="litelink">...</a></p>';
                
                if (_tf.htmlText.indexOf("</p") != -1 || _tf.htmlText.indexOf("</h") != -1) {
                    _tf.htmlText = _tf.htmlText.split("</p").join("     .</p").split("</h").join("    .</h");
                } else {
                    _tf.htmlText += "       .";
                }
                
                _otfButton = new Sprite();
                DrawingMethods.rect(_otfButton, false, _tf.x, _tf.y, _tf.width, _tf.height, 0x000000, 0);
                _otfButton.useHandCursor = false;
				_mc.addChild(_otfButton);
				
                
                var field:TextField = _tf;

				_otfButton.addEventListener(MouseEvent.ROLL_OVER, onFieldRollover, false, 0, true);
				_otfButton.addEventListener(MouseEvent.ROLL_OUT, onFieldRollout, false, 0, true);
      
                if (_text.indexOf("href='") != -1) {
                    _otfButton.addEventListener(MouseEvent.CLICK, onFieldClick);
                }
                
            }
			
			_tf.addEventListener(TextEvent.LINK, dispatchLink);
			_tf.addEventListener(MouseEvent.ROLL_OUT, onFieldRollout);
            
        }
		
		//
		//
		protected function onFieldRollover (e:MouseEvent):void {
			
			if (textOverflowing) {
				mainStage.addEventListener(Event.ENTER_FRAME, scrollText);
			}
			
			if (_alt.length > 0) Tagtip.showTag(_alt);
			
		}
		
		//
		//
		protected function onFieldRollout (e:MouseEvent):void {
			
			if (textOverflowing) {
				mainStage.removeEventListener(Event.ENTER_FRAME, scrollText);
				_tf.scrollH = 0;
			}
			
			Tagtip.hideTag();
			
		}
		
		//
		//
		protected function scrollText (e:Event):void {
			
			_tf.scrollH += 1;
			
			if (_mc.mouseX < 0 || _mc.mouseY < 0 || _mc.mouseX > _width || _mc.mouseY > _height) {
				mainStage.removeEventListener(Event.ENTER_FRAME, scrollText);
				_tf.scrollH = 0;
			}
			
		}
		
		//
		//
		protected function onFieldClick (e:MouseEvent):void {
			
			var link:String = _text.split("href='")[1].split("'")[0];
			navigateToURL(new URLRequest(link), "_blank");
			
		}
		
		//
		//
		protected function dispatchLink (e:TextEvent):void {
			
			linkEvent = e.text;
			
			if (linkEvent == "showtag" && _alt.length > 0) {
				Tagtip.showTag(_alt, true);
				return;
			}
			dispatchEvent(new Event(EVENT_CLICK));
			linkEvent = "";
			
		}
        
        //
        //
        protected function reset (text:String):void {
            
			if (text.indexOf("<") == -1) {
				if (_text.indexOf('align="center"') != -1) {
					text = '<p align="center">' + text + '</p>';
				} else {
					text = '<p>' + text + '</p>';
				}
			}
			
            _text = _tf.htmlText = text;
			_height = _tf.height;
            
            //if (_tf != undefined) _tf.removeTextField();
            //if (_otf != undefined) _otf.removeTextField();
            //if (_otfButton != undefined) _otfButton.removeMovieClip();
            
            //create();
            
        }
        //
        //
        protected function stripTags (text:String):String {
            
            var i:Number;
            
            while ((i = text.indexOf("<")) != -1) text = text.split(text.substr(i, text.indexOf(">") - i + 1)).join("");
            
            return text;
            
        }
        
    }
}
