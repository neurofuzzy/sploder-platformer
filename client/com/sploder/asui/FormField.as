package com.sploder.asui {
	
    import com.sploder.asui.*;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
    
    
    public class FormField extends Component {

        private var _textLabel:String;
    
        private var _selectable:Boolean = true;
		public function get selectable():Boolean { return _selectable; }
		public function set selectable(value:Boolean):void 
		{
			_selectable = value;
			if (_tf) {
				_tf.selectable = _tf.mouseEnabled = value;
				_tf.defaultTextFormat = new TextFormat("Verdana", _style.fontSize, _style.textColor, false, false, false, "", "", "left");
				if (_tf.selectable) _tf.addEventListener(MouseEvent.CLICK, onClick);
				else _tf.removeEventListener(MouseEvent.CLICK, onClick);
			}
		}		
        
        private var _tf:TextField;
        
        private var _highlight:Sprite;
        
        private var _useHTMLtext:Boolean = false;
        public function get useHTMLtext():Boolean { return _useHTMLtext; }
        public function set useHTMLtext(value:Boolean):void {

            _useHTMLtext = value;
        }
        
        public function get text ():String { return _tf.text; }
        public function set text (val:String):void { 
			if (_useHTMLtext) {
				_tf.htmlText = val;
			} else {
				_tf.text = val;
			}
			if (!_style.embedFonts) _tf.defaultTextFormat = new TextFormat("_sans", _style.fontSize, _style.textColor, false, false, false, "", "", "left");
   			
		}

        
        private var _clear:Boolean = true;
        public function get clear():Boolean { return _clear; }
        public function set clear(value:Boolean):void { _clear = value; }

        
        public function get changed ():Boolean { return (_tf.text != _textLabel); }
        override public function get value ():String { return ((_textLabel.indexOf("...") != -1) && _tf.text == _textLabel) ? "" : _tf.text; }
        override public function set value (val:String):void { 

            if (_useHTMLtext) _tf.htmlText = (val.length > 0) ? val : "";
            else _tf.text = (val.length > 0) ? val : "";
			
			if (form != null && name.length > 0) form[name] = val;
			checkText();
			
        } 
        
		private var _tftype:String = "dynamic";
        public function set editable (value:Boolean):void {

			if (_tf) {
				if (value) _tftype = _tf.type = "input";
				else _tftype = _tf.type = "dynamic";
			} else {
				if (value) _tftype = "input";
				else _tftype = "dynamic";
			}
			
			if (value) {
				addEventListener(EVENT_FOCUS, onFocus);
                addEventListener(EVENT_BLUR, onBlur);
			} else {
				removeEventListener(EVENT_FOCUS, onFocus);
                removeEventListener(EVENT_BLUR, onBlur);
			}
		
        }
		
		protected var _restrict:String = "";
		
		public function set restrict (val:String):void {
			
			if (_tf) _restrict = _tf.restrict = val + ".";
			else _restrict = val + ".";
			
		}
		
		public function set password (val:Boolean):void {
			
			_tf.displayAsPassword = val;
			
		}
		
		
		protected var _maxChars:int = 0;
		public function set maxChars (val:int):void {
			
			if (_tf) _maxChars = _tf.maxChars = val;
			else _maxChars = val;
			
		}
		
        public var validate:Function;
        
        
        public function FormField (container:Sprite = null, textLabel:String = "", width:Number = NaN, height:Number = NaN, selectable:Boolean = true, position:Position = null, style:Style = null) {
            
            init_FormField (container, textLabel, width, height, selectable, position, style);
            
            if (_container != null) create();
            
        }
        
        //
        //
        private function init_FormField (container:Sprite = null, textLabel:String = "", width:Number = NaN, height:Number = NaN, selectable:Boolean = true, position:Position = null, style:Style = null):void {
            
            super.init(container, position, style);
			
			_type = "formfield";
            
            _textLabel = textLabel;
            _width = width;
            _height = height;
            _selectable = selectable;
            
        }
        
        //
        //
        override public function create ():void {

    
            super.create();
            
            if (isNaN(_width)) _width = _parentCell.width - _position.margin_left - _position.margin_right;
            
            _tf = Create.inputText(_textLabel, "formTF", _mc, _width - 6, NaN, _style);
            _tf.x = 6;
            _tf.tabIndex = id;
			_tf.restrict = _restrict;
			_tf.maxChars = _maxChars;
			
			_tf.width = _width - 6;

            if (isNaN(_height)) {
				_tf.y = Math.floor(Math.max(2, _style.padding / 2));
				_height = _tf.height - _style.borderWidth;
            } else {
				_tf.text = "MMM";
				_tf.autoSize = TextFieldAutoSize.LEFT;
                _tf.y = Math.floor((_height - _tf.height) * 0.5);
                if (_height > 30) {
                    _tf.multiline = true;
                    _tf.wordWrap = true;
					_tf.autoSize = TextFieldAutoSize.NONE;
					_tf.text = "";
					_tf.width = _width - 6;
					_tf.height = _height - 6;
					_tf.y = 3;
                } else {
					_tf.text = "";
					_tf.autoSize = TextFieldAutoSize.NONE;
					_tf.width = _width - 6;
				}
            }
            
            DrawingMethods.emptyRect(_mc, false, 0, 0, _width, _height, 2, ColorTools.getTintedColor(_style.borderColor, _style.backgroundColor, 0.7));
            DrawingMethods.roundedRect(_mc, false, 2, 2, _width - 4, _height - 4, "0", [_style.inputColorA, _style.inputColorB]);
    
            connectTextField(_tf);
            
            if (_selectable || _tftype == "input") {
				
				_tf.type = TextFieldType.INPUT;
            
                addEventListener(EVENT_FOCUS, onFocus);
                addEventListener(EVENT_BLUR, onBlur);
            
            } else {
                
				_tf.type = TextFieldType.DYNAMIC;
                _tf.selectable = false;
                
            }
            

            _highlight = new Sprite();
			_mc.addChild(_highlight);
            DrawingMethods.emptyRect(_highlight, false, 0, 0, _width, _height, 2, _style.borderColor);
            DrawingMethods.emptyRect(_highlight, false, -2, -2, _width + 4, _height + 4, 2, ColorTools.getSaturatedColor(_style.haloColor, 255), 0.60);
            _highlight.visible = false;
			_width = _mc.width;
            _height = _mc.height;
			
			if (_useHTMLtext) {
				_tf.htmlText = _textLabel;
			} else {
				_tf.text = _textLabel;
			}
			
			if (_tf.selectable) _tf.addEventListener(MouseEvent.CLICK, onClick);
    
        }
        
        //
        //
        public function focus ():void {

			mainStage.focus = _tf;
            onFocus();
            if (_tf.text.length > 0) _tf.setSelection(0, _tf.text.length);
            
        }
        
        //
        //
        public function onFocus (e:Event = null):void {

            
            if (_enabled) {
                
                _highlight.visible = true;
                
                if (_tf.text == _textLabel && _tf.text.indexOf("...") != -1 && _clear) {
                    
                    _tf.text = _tf.htmlText = "";
					
                    
                } else if (_selectable) {
                
					_highlight.addEventListener(MouseEvent.MOUSE_UP, onSelect);
                
                }
                
            }
        
        }
		
		//
		//
		protected function onSelect (e:MouseEvent):void {
                            
			if (_tf.selectionBeginIndex == _tf.selectionEndIndex) focus();
			dispatchEvent(new Event(EVENT_SELECT));
		}
        
        //
        //
        public function onBlur (e:Event = null):void {

            
            _highlight.visible = false;
            _highlight.removeEventListener(MouseEvent.MOUSE_UP, onSelect);
            
            checkText();
			dispatchEvent(new Event(EVENT_CHANGE));
            
        }
		
		protected function checkText ():void
		{
			if (_tf.text == "" && _clear) {
                _tf.text = _textLabel;
				if (!_style.embedFonts) _tf.defaultTextFormat = new TextFormat("_sans", _style.fontSize, _style.textColor, false, false, false, "", "", "left"); 
            }
		}
        
        //
        //
        override public function enable (e:Event = null):void {

            
            super.enable();
            
            _tf.textColor = _style.textColor;
            _tf.selectable = true;
			_tf.type = TextFieldType.INPUT;
            _tf.tabEnabled = true;
            
        }
        
        //
        //
        override public function disable (e:Event = null):void {

            
            super.disable();
            
            _tf.textColor = ColorTools.getTintedColor(_style.textColor, _style.backgroundColor, 0.8);
            _tf.selectable = false;
			_tf.type = TextFieldType.DYNAMIC;
            _tf.tabEnabled = false;
            _highlight.visible = false;
            
        }
        
        //
        //
        public function lock ():void {

            
            disable();
            
            _tf.textColor = ColorTools.getTintedColor(_style.textColor, _style.backgroundColor, 0.4);
            
        }
        
    }
}
