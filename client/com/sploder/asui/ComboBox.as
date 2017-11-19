package com.sploder.asui {
	
    import com.sploder.asui.*;
    
	import flash.display.Sprite;
	import flash.events.Event;
    
    public class ComboBox extends Cell {

        private var _textLabel:String = "";
        private var _choices:Array;
        private var _promptText:String = "";
        
        private var _open:Boolean = false;
        
        private var _field:FormField;
        private var _fieldbutton:BButton;
        private var _button:BButton;
		private var _buttons:Array;
        private var _dropdown:Cell;
        
        private var _selectionIndex:Number = -1;
        private var _activeChoice:BButton;
        
        private var _homeDepth:int = 1;
		
		protected var _startWidth:uint = 0;
		
		public var dropDownPosition:int = Position.POSITION_BELOW;

        override public function get value ():String { return (_field != null) ? _field.value : ""; }
		
		public function get choices():Array { return _choices; }
		
		public function set choices(value:Array):void 
		{
			_choices = value;
			recreate();
		}
        
        //
        //
        //
        function ComboBox (container:Sprite, textLabel:String, choices:Array, selectionIndex:Number = 0, promptText:String = "", width:Number = NaN, position:Position = null, style:Style = null) {
            
            init_ComboBox (container, textLabel, choices, selectionIndex, promptText, width, position, style);
            
            if (_container != null) create();
            
        }
        
        //
        //
        private function init_ComboBox (container:Sprite, textLabel:String, choices:Array, selectionIndex:Number = 0, promptText:String = "", width:Number = NaN, position:Position = null, style:Style = null):void {
            
            super.init_Cell(container, NaN, NaN, false, false, 0, position, style);
    
			 _type = "combobox";
			 
            _textLabel = (textLabel.length > 0) ? textLabel : _textLabel;
            _choices = choices.concat();
            _selectionIndex = (!isNaN(selectionIndex)) ? selectionIndex : -1;
            _promptText = (promptText.length > 0) ? promptText : _promptText;
            _width = (!isNaN(width)) ? width : 224;
			
			_startWidth = _width;
            
        }
        
        //
        //
        override public function create ():void {
            
            super.create();
			
			createElements();
            
        }
		
		//
		//
		protected function createElements ():void {
			
			_width = _startWidth;
			
            _field = FormField(addChild(new FormField(null, _promptText, _width - 34, NaN, false, new Position( { placement: Position.PLACEMENT_FLOAT, margins: 0, padding: 0 } ), _style)));
            _field.clear = false;
            _field.tabEnabled = false;
            _field.editable = false;
            
            var buttonStyle:Style = _style.clone();
            buttonStyle.round = 0;
            buttonStyle.borderWidth = 2;
			
			var bof:int = 9;
			
			if (_style.embedFonts) bof = 7;
            
            _button = BButton(addChild(new BButton(null, Create.ICON_ARROW_DOWN, -1, _field.height - bof, _field.height - bof, false, false, false, new Position( { placement: Position.PLACEMENT_FLOAT, margins: 0, padding: 0 } ), buttonStyle)));
            
            var dropdownStyle:Style = _style.clone();
            dropdownStyle.borderWidth = 2;
            dropdownStyle.borderColor = ColorTools.getTintedColor(_style.borderColor, _style.backgroundColor, 0.5);
    
            _dropdown = Cell(addChild(new Cell(null, _width - 38, 100, true, true, 0, new Position({ placement: Position.PLACEMENT_ABSOLUTE, top: 25, left: 0, ignoreContentPadding: true }), dropdownStyle)));
            _dropdown.maskContent = _dropdown.trapMouse = _dropdown.collapse = true;
            _dropdown.hide();
            
            var choicesStyle:Style = _style.clone();
            choicesStyle.background = choicesStyle.border = choicesStyle.gradient = false;
            choicesStyle.unselectedTextColor = ColorTools.getTintedColor(_style.textColor, _style.backgroundColor, 0.5);
            choicesStyle.inverseTextColor = ColorTools.getTintedColor(_style.textColor, _style.backgroundColor, 0.2);
            choicesStyle.round = 0;
            choicesStyle.padding = 7;
            
            var b:BButton;
			
			_buttons = [];
            
            for (var i:int = 0; i < _choices.length; i++) {
                
                b = BButton(_dropdown.addChild(new BButton(null, _choices[i], Position.ALIGN_LEFT, _width - 38, NaN, false, true, false, new Position( { margins: 0 }), choicesStyle)));
                b.addEventListener(EVENT_CLICK, onChoice);
				_buttons.push(b);
                
            }
			
			if (dropDownPosition == Position.POSITION_ABOVE) {
				_dropdown.position.top = _dropdown.y = 0 - _dropdown.height;
			}
            
            _fieldbutton = BButton(addChild(new BButton(null, "", -1, _width - 34, _field.height - bof, false, false, false, new Position( { placement: Position.PLACEMENT_ABSOLUTE, top: 0, left: 0 } ), choicesStyle)));
            
            _button.addEventListener(EVENT_CLICK, toggle);
            _fieldbutton.addEventListener(EVENT_CLICK, toggle);
            
            addEventListener(EVENT_BLUR, _dropdown.hide);
            
            _height = _field.height;
            
            if (_selectionIndex >= 0) {
                
                BButton(_dropdown.childNodes[_selectionIndex]).dispatchEvent(new Event(EVENT_CLICK));
                toggle();
                
            }			
				
		}
		
		protected function recreate ():void {
			
			clear();
			_selectionIndex = _choices.length - 1;
			createElements();
			
		}
        
        //
        //
        public function onChoice (e:Event):void {
            
            for (var i:int = 0; i < _dropdown.childNodes.length; i++) if (_dropdown.childNodes[i] != e.target) BButton(_dropdown.childNodes[i]).deselect();
            
            _activeChoice = BButton(e.target);
    
            _activeChoice.select();
			
			var changed:Boolean = (_field.text != _activeChoice.textLabel);
            
            _field.text = _activeChoice.textLabel;
    
            dispatchEvent(new Event(EVENT_CLICK));
			
			if (changed) dispatchEvent(new Event(EVENT_CHANGE));
            
            toggle();
            
            
        }
		
		public function select (index:uint = 0):void {
			
			if (index < _buttons.length) {
				
				for (var i:int = 0; i < _dropdown.childNodes.length; i++) if (i != index) BButton(_dropdown.childNodes[i]).deselect();
				
				_activeChoice = _buttons[index];
		
				_activeChoice.select();
				
				var changed:Boolean = (_field.text != _activeChoice.textLabel);
				
				_field.text = _activeChoice.textLabel;
		
				dispatchEvent(new Event(EVENT_CLICK));
				
				if (changed) dispatchEvent(new Event(EVENT_CHANGE));
			
			}
			
		}
        
        //
        //
        override public function toggle (e:Event = null):void {
            
            _dropdown.toggle();
            
            if (_dropdown.visible) {
				
				focused = this;
                
				if (_mc.parent != null) {
					_homeDepth = _mc.parent.getChildIndex(_mc);
					_mc.parent.setChildIndex(_mc, _mc.parent.numChildren - 1);
				}
                _field.onFocus();
                
                if (e == null) dispatchEvent(new Event(EVENT_FOCUS));
      
            } else {
                
				if (_mc.parent != null && _homeDepth <= _mc.parent.numChildren) {
					_mc.parent.setChildIndex(_mc, _homeDepth);
				}
                _field.onBlur();
    
                if (e == null) dispatchEvent(new Event(EVENT_BLUR));
                
            }
            
        }
        
        //
        //
        override public function onBlur (e:Event = null):void {
        
            if (_dropdown.visible) toggle(e);
    
        }
        
        
    }
}
