package com.sploder.asui {
	
    import com.sploder.asui.*;
	import flash.events.FocusEvent;
    
	import flash.display.Sprite;
	import flash.events.Event;
    
    public class ClipChooser extends Cell {

        private var _textLabel:String = "";
        private var _choices:Array;
		private var _alts:Array;
        private var _promptText:String = "";
		
		protected var _alt:String = "";
        public function get alt ():String { return _alt; }
        public function set alt (value:String):void { _alt = value; }
        
        private var _open:Boolean = false;
        
		private var _choiceButton:ClipButton;
        private var _button:BButton;
		private var _buttons:Array;
        private var _dropdown:Cell;
		private var _dropdownPosition:int;
		private var _textField:HTMLField;
        
        private var _selectionIndex:Number = -1;
        private var _activeChoice:ClipButton;
        
        private var _homeDepth:int = 1;
		
		protected var _startWidth:uint = 0;
		
		public var rowLength:int = 3;
		public var choicesPadding:int = -1;
		public var choicesShrink:int = 0;
		public var choicesOffsetX:int = 0;
		public var choicesOffsetY:int = 0;
		public var choicesLineMode:Boolean = false;
		
		protected var _choicesCreated:Boolean = false;
		protected var _firstCall:Boolean = true;

        override public function get value ():String { return (_choiceButton != null) ? _choiceButton.symbolName : ""; }
		
		override public function set value(val:String):void 
		{
			if (val == value) return;
			if (_buttons == null) return;
			for (var i:int = 0; i < _buttons.length; i++) {
				if (ClipButton(_buttons[i]).symbolName == val) {
					_activeChoice = _buttons[i];
					_activeChoice.select();
					_choiceButton.setSymbol(_activeChoice.symbolName);
					dispatchEvent(new Event(EVENT_CHANGE))
					return;
				}
			}
		}
		
		public function get choices():Array { return _choices; }
		
		public function set choices(value:Array):void 
		{
			_choices = value;
			recreate();
		}
        
        //
        //
        //
        function ClipChooser (container:Sprite, textLabel:String, choices:Array, alts:Array, selectionIndex:Number = 0, promptText:String = "", width:Number = NaN, height:Number = NaN, menuPosition:int = Position.POSITION_RIGHT, position:Position = null, style:Style = null) {
            
            init_ComboBox (container, textLabel, choices, alts, selectionIndex, promptText, width, height, menuPosition, position, style);
            
            if (_container != null) create();
            
        }
        
        //
        //
        private function init_ComboBox (container:Sprite, textLabel:String, choices:Array, alts:Array, selectionIndex:Number = 0, promptText:String = "", width:Number = NaN, height:Number = NaN, menuPosition:int = Position.POSITION_RIGHT, position:Position = null, style:Style = null):void {
            
            super.init_Cell(container, NaN, NaN, false, false, 0, position, style);
    
			 _type = "combobox";
			 
            _textLabel = (textLabel.length > 0) ? textLabel : _textLabel;
            _choices = choices.concat();
			_alts = alts;
            _selectionIndex = (!isNaN(selectionIndex)) ? selectionIndex : -1;
            _promptText = (promptText.length > 0) ? promptText : _promptText;
            _width = (!isNaN(width)) ? width : 80;
			_height = (!isNaN(height)) ? height : 60;
			_dropdownPosition = menuPosition;
			
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
			
			var cpos:Position = new Position( { placement: Position.PLACEMENT_FLOAT, clear: Position.CLEAR_NONE, margins: 0, padding: 0 } );
			
			var buttonStyle:Style = _style.clone();
            buttonStyle.borderWidth = _style.borderWidth / 2;
			
			var cStyle:Style = buttonStyle.clone();
			cStyle.padding = _style.padding;
			cStyle.bgGradient = false;
			cStyle.buttonColor = cStyle.unselectedColor = _style.backgroundColor;
			
			_choiceButton = new ClipButton(null, _choices[_selectionIndex], "", -1, _width - 20, _height, 10, false, false, false, choicesLineMode, cpos, cStyle);
			_choiceButton.tabSide = Position.POSITION_RIGHT;
			_choiceButton.alt = _alt;
			addChild(_choiceButton);
			_choiceButton.toggleMode = false;
			_choiceButton.addEventListener(EVENT_CLICK, toggle);
			
			var bi:Array;

			switch (_dropdownPosition) {
				
				case Position.POSITION_ABOVE:
					bi = Create.ICON_ARROW_UP;
					break;
				
				case Position.POSITION_RIGHT:
					bi = Create.ICON_ARROW_RIGHT;
					break;
				
				case Position.POSITION_BELOW:
					bi = Create.ICON_ARROW_DOWN;
					break;
				
				case Position.POSITION_LEFT:
					bi = Create.ICON_ARROW_LEFT;
					break;
				
				
			}
			
			_button = new BButton(null, { icon: Create.ICON_ARROW_LEFT, iconToggled: bi }, -1, 20, _height, false, false, false, cpos, buttonStyle);
			_button.tabSide = Position.POSITION_LEFT;
			_button.alt = _alt;
			addChild(_button);
			
			_choiceButton.linkedButton = _button;
			_button.linkedButton = _choiceButton;
				
		}
		
		protected function createChoices ():void {
			
			if (_choicesCreated) return;
			_choicesCreated = true;
			
			var cpos:Position = new Position( { placement: Position.PLACEMENT_FLOAT, clear: Position.CLEAR_NONE, margins: 0, padding: 0 } );

			var bi:Array;
			var dt:Number = 0;
			var dl:Number = 0;
			var dw:Number = Math.min(_choices.length, rowLength) * (_height - choicesShrink);
			var dh:Number = Math.ceil(_choices.length / rowLength) * (_height - choicesShrink);
			
			switch (_dropdownPosition) {
				
				case Position.POSITION_ABOVE:
					bi = Create.ICON_ARROW_UP;
					dt = 0 - dh;
					dl = 0;
					break;
				
				case Position.POSITION_RIGHT:
					bi = Create.ICON_ARROW_RIGHT;
					dt = 0;
					dl = _width;
					break;
				
				case Position.POSITION_BELOW:
					bi = Create.ICON_ARROW_DOWN;
					dt = _height;
					dl = 0;
					break;
				
				case Position.POSITION_LEFT:
					bi = Create.ICON_ARROW_LEFT;
					dt = 0;
					dl = 0 - dw;
					dw = Math.min(_choices.length, rowLength) * _height;
					break;
				
				
			}
			
			dl += choicesOffsetX;
			dt += choicesOffsetY;
            
            var dropdownStyle:Style = _style.clone();
			dropdownStyle.padding = 0;
			dropdownStyle.bgGradient = true;
			dropdownStyle.bgGradientColors = [ColorTools.getTintedColor(dropdownStyle.inactiveColor, 0xffffff, 0.2), dropdownStyle.inactiveColor];
			dropdownStyle.borderColor = ColorTools.getTintedColor(_style.borderColor, _style.backgroundColor, 0.5);
    
            _dropdown = Cell(addChild(new Cell(null, dw, dh, true, true, (choicesPadding == 0) ? 0 : _style.round, new Position({ placement: Position.PLACEMENT_ABSOLUTE, top: dt, left: dl, ignoreContentPadding: true }), dropdownStyle)));
            _dropdown.maskContent = _dropdown.trapMouse = _dropdown.collapse = true;
            _dropdown.hide();
            
            var choicesStyle:Style = _style.clone();
            choicesStyle.background = choicesStyle.border = false;
			choicesStyle.gradient = false;
            choicesStyle.unselectedTextColor = ColorTools.getTintedColor(_style.textColor, _style.backgroundColor, 0.5);
            choicesStyle.inverseTextColor = ColorTools.getTintedColor(_style.textColor, _style.backgroundColor, 0.2);
			if (choicesPadding >= 0 && choicesPadding < choicesStyle.round) {
				choicesStyle.round = choicesPadding;
			}
			cpos.margin = 0;
            var b:BButton;
			var a:String = "";
			var cb:ClipButton;
			
			_buttons = [];
            
            for (var i:int = 0; i < _choices.length; i++) {
                
				a = "";
				if (_alts && _alts[i]) a = _alts[i];
				cb = new ClipButton(null, _choices[i], "", -1, _height - choicesShrink, _height - choicesShrink, (choicesPadding >= 0) ? choicesPadding : 10, false, true, false, false, cpos, choicesStyle);
                b = BButton(_dropdown.addChild(cb));
                b.alt = a;
				b.reselectable = true;
				b.addEventListener(EVENT_CLICK, onChoice);
				_buttons.push(b);
                
            }
            
            _button.addEventListener(EVENT_CLICK, toggle);

            addEventListener(EVENT_BLUR, _dropdown.hide);
			
            if (_textLabel.length) {
				_textField = new HTMLField(null, "<p align=\"center\">" + _textLabel + "</p>", _width, true, null, _style);
				addChild(_textField);
				_height += _textField.height;
			}
            
            if (_selectionIndex >= 0) {
                
				if (BButton(_dropdown.childNodes[_selectionIndex])) {
                	BButton(_dropdown.childNodes[_selectionIndex]).dispatchEvent(new Event(EVENT_CLICK));
				}
                toggle();
                
            }	

		}
		
		protected function recreate ():void {
			
			clear();
			_choicesCreated = false;
			_selectionIndex = _choices.length - 1;
			createElements();
			
		}
        
        //
        //
        public function onChoice (e:Event):void {
            
            for (var i:int = 0; i < _dropdown.childNodes.length; i++) if (_dropdown.childNodes[i] != e.target) ClipButton(_dropdown.childNodes[i]).deselect();
            
            _activeChoice = ClipButton(e.target);
    
            _activeChoice.select();

			var changed:Boolean = (_choiceButton.symbolName != _activeChoice.symbolName);
            
            if (changed) _choiceButton.setSymbol(_activeChoice.symbolName);
    
            dispatchEvent(new Event(EVENT_CLICK));
			if (!_firstCall) dispatchEvent(new Event(EVENT_SELECT));
			_firstCall = false;
			if (changed) dispatchEvent(new Event(EVENT_CHANGE));
            
            toggle();

        }
		
		public function select (index:uint = 0):void {
			
			if (index < _buttons.length) {
				
				for (var i:int = 0; i < _dropdown.childNodes.length; i++) if (i != index) BButton(_dropdown.childNodes[i]).deselect();
				
				_activeChoice = _buttons[index];
		
				_activeChoice.select();
				
				var changed:Boolean = (_choiceButton.symbolName != _activeChoice.symbolName);
				
				if (changed) _choiceButton.setSymbol(_activeChoice.symbolName);
		
				dispatchEvent(new Event(EVENT_CLICK));
				
				if (changed) dispatchEvent(new Event(EVENT_CHANGE));
			
			}
			
		}
        
        //
        //
        override public function toggle (e:Event = null):void {
            
			if (!_choicesCreated) createChoices();
            if (_dropdown) _dropdown.toggle();
            
            if (_dropdown && _dropdown.visible) {
				
				focused = this;
				
				if (_mc.parent != null) {
					_homeDepth = _mc.parent.getChildIndex(_mc);
					_mc.parent.setChildIndex(_mc, _mc.parent.numChildren - 1);
				}
               _button.select();
                if (e == null) dispatchEvent(new Event(EVENT_FOCUS));
      
            } else {
                
				if (_mc.parent != null && _homeDepth <= _mc.parent.numChildren) {
					_mc.parent.setChildIndex(_mc, _homeDepth);
				}
               _button.deselect();
                if (e == null) dispatchEvent(new Event(EVENT_BLUR));
                
            }
            
        }
		
		override public function enable(e:Event = null):void 
		{
			super.enable(e);
			if (_activeChoice) _activeChoice.enable();
		}
		
		override public function disable(e:Event = null):void 
		{
			 if (_dropdown && _dropdown.visible) toggle(e);
			 super.disable(e);
			 if (_activeChoice) _activeChoice.disable();
		}
        
        //
        //
        override public function onBlur (e:Event = null):void {
        
            if (_dropdown && _dropdown.visible) toggle(e);
    
        }
          
    }

}
