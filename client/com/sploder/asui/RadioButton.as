package com.sploder.asui {
    
	import com.sploder.asui.*;
	import flash.events.FocusEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;    
    
    public class RadioButton extends Component {
        
        override public function get value ():String {
			if (_grouped) return _group.value 
			else if (_checked) return _value 
			else return ""; 
		}
     
        public static var groups:Object;
        
        private var _textLabel:String;
        private var _groupName:String;
        private var _grouped:Boolean = false;
        private var _group:Object;
        
        private var _tf:TextField;
        private var _back:Sprite;
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

            if (val != _checked) toggle();
        } 
		
		public var radioSymbolName:String = "";
        
        public var validate:Function;
        
        
        public function RadioButton (container:Sprite = null, textLabel:String = "", value:String = "", groupName:String = "", checked:Boolean = false, width:Number = NaN, height:Number = NaN, altTag:String = "", position:Position = null, style:Style = null) {
            
            init_RadioButton (container, textLabel, value, groupName, checked, width, height, altTag, position, style);
            
            if (_container != null) create();
            
        }
        
        //
        //
        private function init_RadioButton (container:Sprite = null, textLabel:String = "", value:String = "", groupName:String = "", checked:Boolean = false, width:Number = NaN, height:Number = NaN, altTag:String = "", position:Position = null, style:Style = null):void {
 
            super.init(container, position, style);
			
			_type = "radiobutton";
            
            _textLabel = textLabel;
            _value = (value.length > 0) ? value : textLabel.toLowerCase();
    
            _groupName = (groupName.length > 0) ? groupName : "";
            _checkedAtStart = _checked = checked;
            _width = width;
            _height = height;
			_alt = altTag;
            
            if (_groupName.length > 0) {
                
                _grouped = true;
                
                if (RadioButton.groups == null) RadioButton.groups = { };
                
                if (RadioButton.groups[_groupName] == null) {
                    RadioButton.groups[_groupName] = { };
		 			RadioButton.groups[_groupName].buttons = { };
                    _checked = true;
                }
               
                _group = RadioButton.groups[_groupName];
                _group.buttons[value] = this;
				
                if (_checked) {
                    if (_group.activeRadioButton != null) _group.activeRadioButton.checked = false;
                    _group.activeRadioButton = this;
                    _group.value = this.value;
                }
                
            }
     
        }
        
        //
        //
        override public function create ():void {

    
            super.create();
         
            if (isNaN(_width)) {
				if (_parentCell != null) {
					_width = _parentCell.width - _position.margin_left - _position.margin_right;
				} else {
					_width = 500;
				}
			}
            
            _tf = Create.newText(_textLabel, "labelTF", _mc, _style, NaN, NaN, true);
            _tf.x = 6;
            _tf.y = 0;
            _tf.tabIndex = id;
            _tf.selectable = false;
            _tf.tabEnabled = false;
            _tf.multiline = true;
            _tf.wordWrap = true;
            _tf.x = 20;
            
            _back = new Sprite();
			_mc.addChild(_back);
			
			if (!isNaN(_width)) _tf.width = _width - 16 - 4;
			
			if (isNaN(_height)) {
				_height = _tf.height;
			} else {
				_tf.height = _height - 4;
			}
			
			if (radioSymbolName == "") {
				
				DrawingMethods.circle(_back, false, 8, 8, 6, 16, _style.backgroundColor, 100, 2,  ColorTools.getTintedColor(_style.borderColor, _style.backgroundColor, 0.7), 100);
				
				_checkSymbol = new Sprite();
				_mc.addChild(_checkSymbol);
				DrawingMethods.circle(_checkSymbol, false, 8, 8, 6, 16, _style.backgroundColor, 0, 2, _style.borderColor, 100);
				DrawingMethods.circle(_checkSymbol, false, 8, 8, 3, 16, _style.buttonColor, 100);
		
				_checkSymbol.visible = checked;
		
				_width = _mc.width;
				
				_highlight = new Sprite();
				_mc.addChild(_highlight);
				DrawingMethods.circle(_highlight, false, 8, 8, 10, 2, ColorTools.getSaturatedColor(_style.haloColor, 255), 0.60);
				_highlight.visible = false;
				
				_button = new Sprite();
				_mc.addChild(_button);
				DrawingMethods.circle(_button, false, 8, 8, 7, 2, _style.textColor, 0.2);
				
				_back.y = _checkSymbol.y = _button.y = _highlight.y = Math.max(0, Math.floor((_tf.height - 16) * 0.5));
				
			} else {
				
				var rs:Sprite = Component.library.getDisplayObject(radioSymbolName) as Sprite;
				_back.addChild(rs);
				
				var rsa:Number = _back.width / _back.height;
				
				_tf.x = rs.width + 5;
				_tf.width = _width - rs.width - 5;
				_tf.y = (rs.height - _tf.height) / 2;
				
				
				_checkSymbol = new Sprite();
				_mc.addChild(_checkSymbol);
				DrawingMethods.emptyRect(_checkSymbol, true, -2, -2, rs.width + 4, rs.height + 4, 2, _style.haloColor, 1);
				
				_checkSymbol.visible = checked;
				
				_width = _mc.width;
				
				_highlight = new Sprite();
				_mc.addChild(_highlight);
				DrawingMethods.emptyRect(_highlight, false, -2, -2, rs.width + 4, rs.height + 4, 4, ColorTools.getSaturatedColor(_style.haloColor, 255), 0.60);
				_highlight.visible = false;
				
				_button = new Sprite();
				_mc.addChild(_button);
				DrawingMethods.rect(_button, false, 0, 0, rs.width, rs.height, _style.textColor, 0.2);
				
			}
			
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
    
        }
        
        //
        //
        private function rollout (e:Event):void {
            
            Tagtip.hideTag();
            
        }
     
        //
        //
        override public function toggle (e:Event = null):void {

            if (e != null && _checked && _grouped && _group.activeRadioButton == this) return;
            
            if (!_checked && _grouped) {
                if (_group.activeRadioButton != null) RadioButton(_group.activeRadioButton).checked = false;
                _group.activeRadioButton = this;
                _group.value = _value;
            }
            
            _checked = (!_checked);
			if (_checkSymbol) _checkSymbol.visible = _checked;
			
			if (_checked) {
				_tf.textColor = _style.highlightTextColor;
			} else {
				_tf.textColor = _style.textColor;
			}

            if (_checked || !_grouped) dispatchEvent(new Event(EVENT_CHANGE));
            
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
            
            _tf.alpha = 1;
            _button.tabEnabled = true;
			_button.mouseEnabled = _fieldbutton.mouseEnabled = true;
            
        }
        
        //
        //
        override public function disable (e:Event = null):void {
            
            super.disable();
            
            _tf.alpha = 0.25;
            _highlight.visible = false;
            _button.tabEnabled = false;
			_button.mouseEnabled = _fieldbutton.mouseEnabled = false;
            
        }
        
        //
        //
        public function lock ():void {

            disable();
            
            _tf.textColor = ColorTools.getTintedColor(_style.textColor, _style.backgroundColor, 0.4);
            
        }
        
    }
}
