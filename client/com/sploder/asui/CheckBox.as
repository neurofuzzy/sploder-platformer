package com.sploder.asui {
    
	import com.sploder.asui.*;
	import flash.events.FocusEvent;
 
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
    
    public class CheckBox extends Component {

        override public function get value ():String { return (_checked) ? _value : ""; }
        
        private var _textLabel:String;
        
        private var _tf:TextField;
        private var _box:Sprite;
        private var _checkSymbol:Sprite;
        private var _button:Sprite;
        private var _fieldbutton:Sprite;
    
        private var _highlight:Sprite;
        
        private var _checkedAtStart:Boolean = false;
        private var _checked:Boolean = false;
        
        public function get text ():String { return _tf.text; }
        public function set text (val:String):void { _tf.text = val; }

		private var _alt:String = "";
        public function get alt ():String { return _alt; }
        public function set alt (value:String):void { _alt = value; }
		
		public var showAltImmediate:Boolean = false;
		
        public function get changed ():Boolean { return (_checkedAtStart != _checked); }
        public function get checked ():Boolean { return _checked; }
        public function set checked (val:Boolean):void { 

			_checked = _checkSymbol.visible = val;
			
			if (_tf) {
				if (_checked) {
					_tf.textColor = _style.highlightTextColor;
				} else {
					_tf.textColor = _style.textColor;
				}
			}
			
			if (form != null && name.length > 0) form[name] = val;
			
        } 
        
        public var validate:Function;
        
        
        public function CheckBox (container:Sprite = null, textLabel:String = "", value:String = "", checked:Boolean = false, width:Number = NaN, height:Number = NaN, altTag:String = "", position:Position = null, style:Style = null) {
            
            init_CheckBox(container, textLabel, value, checked, width, height, altTag, position, style);
            
            if (_container != null) create();
            
        }
        
        //
        //
        private function init_CheckBox (container:Sprite = null, textLabel:String = "", value:String = "", checked:Boolean = false, width:Number = NaN, height:Number = NaN, altTag:String = "", position:Position = null, style:Style = null):void {
          
            super.init(container, position, style);
			
			 _type = "checkbox";
            
            _textLabel = textLabel;
            _value = (value.length > 0) ? value : textLabel.toLowerCase();
            
            _checkedAtStart = _checked = checked;
            _width = width;
            _height = height;
			_alt = altTag;
			
			_style = _style.clone( { borderWidth: 2 } );
     
        }
        
        //
        //
        override public function create ():void {
    
            super.create();
         
            if (isNaN(_width)) _width = _parentCell.width - _position.margin_left - _position.margin_right;
            
            _tf = Create.newText(_textLabel, "labelTF", _mc, _style, NaN, NaN, true);
            _tf.x = 6;
            _tf.y = 0;
            _tf.tabIndex = id;
            _tf.selectable = false;
            _tf.tabEnabled = false;
            _tf.multiline = true;
            _tf.wordWrap = true;
            _tf.x = 20;
            
            _box = new Sprite();
			_mc.addChild(_box);
            DrawingMethods.emptyRect(_box, false, 0, 0, 16, 16, 2, ColorTools.getTintedColor(_style.borderColor, _style.backgroundColor, 0.7));
            DrawingMethods.rect(_box, false, 2, 2, 12, 12, _style.backgroundColor);
            
            if (!isNaN(_width)) _tf.width = _width - 16 - 4;
            
            if (isNaN(_height)) {
                _height = _tf.height;
            } else {
                _tf.height = _height - 4;
            }
            
            _checkSymbol = new Sprite();
			_mc.addChild(_checkSymbol);
            DrawingMethods.emptyRect(_checkSymbol, false, 0, 0, 16, 16, 2, _style.borderColor);
            Create.newIcon(Create.ICON_CHECK, _checkSymbol, _style.titleColor, 100, _style, 1.5);
            
            _checkSymbol.visible = checked;
    
            _width = _mc.width;
            
            _highlight = new Sprite();
			_mc.addChild(_highlight);
            DrawingMethods.emptyRect(_highlight, false, 0, 0, 16, 16, 2, _style.borderColor);
            DrawingMethods.emptyRect(_highlight, false, -2, -2, 20, 20, 2, ColorTools.getSaturatedColor(_style.haloColor, 255), 60);
            _highlight.visible = false;
            
            _button = new Sprite();
			_mc.addChild(_button);
            DrawingMethods.rect(_button, false, 0, 0, 16, 16, 0xffffff, 0.2);
            
            _box.y = _checkSymbol.y = _button.y = _highlight.y = Math.max(0, Math.floor((_tf.height - 16) * 0.5));
            
            connectButton(_button);
            addEventListener(EVENT_CLICK, toggle);
            
            _mc.tabChildren = _button.tabEnabled = true;
            _button.tabIndex = _id;
    
			_button.addEventListener(FocusEvent.FOCUS_IN, onFocus);
			_button.addEventListener(FocusEvent.FOCUS_OUT, onBlur);
            
            _fieldbutton = new Sprite();
			_mc.addChild(_fieldbutton);
            DrawingMethods.rect(_fieldbutton, false, _tf.x - 4, _tf.y, _tf.width + 4, _tf.height, 0xffffff, 0);
            
            connectButton(_fieldbutton);
            _fieldbutton.tabEnabled = false;
			
			if (_checked) {
				_tf.textColor = _style.highlightTextColor;
			} else {
				_tf.textColor = _style.textColor;
			}
			
            if (_alt.length > 0) {
				
                addEventListener(EVENT_M_OVER, rollover);
                addEventListener(EVENT_M_OUT, rollout);
                 
            }
    
        }
		
        //
        //
        private function rollover (e:Event):void {
			
            if (_alt.length > 0) Tagtip.showTag(_alt, showAltImmediate);
			dispatchEvent(new Event(Component.EVENT_HOVER_START));
    
        }
        
        //
        //
        private function rollout (e:Event):void {
            
            Tagtip.hideTag();
            dispatchEvent(new Event(Component.EVENT_HOVER_END));
			
        }
     
        //
        //
        override public function toggle (e:Event = null):void {
           
            _checked = _checkSymbol.visible = (!_checked);
			
			if (_checked) {
				_tf.textColor = _style.highlightTextColor;
			} else {
				_tf.textColor = _style.textColor;
			}
            
            dispatchEvent(new Event(EVENT_CHANGE));
            
        }
        
        
        //
        //
        public function onFocus (e:Event):void {
         
            if (_enabled) {
                
                _highlight.visible = true;
                
            }
        
        }
        
        //
        //
        public function onBlur (e:Event):void {
            
            _highlight.visible = false;
            
        }
        
        
        //
        //
        override public function enable (e:Event = null):void {
            
            super.enable();
            
            _tf.textColor = _style.textColor;
			_button.mouseEnabled = true;
            _button.tabEnabled = true;
			_box.alpha = 1;
			_mc.alpha = 1;
            
        }
        
        //
        //
        override public function disable (e:Event = null):void {
            
            super.disable();
            
            _tf.textColor = ColorTools.getTintedColor(_style.textColor, _style.backgroundColor, 0.8);
            _highlight.visible = false;
			_button.mouseEnabled = false;
            _button.tabEnabled = false;
			_box.alpha = 0;
			_mc.alpha = 0.5;
            
        }
        
        //
        //
        public function lock ():void {
            
            disable();
            
            _tf.textColor = ColorTools.getTintedColor(_style.textColor, _style.backgroundColor, 0.4);
            
        }
        
    }
}
