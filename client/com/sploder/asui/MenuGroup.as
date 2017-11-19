package com.sploder.asui {
	
    import com.sploder.asui.*;
	import com.sploder.asui.StringUtils;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.StyleSheet;
    
	import flash.display.Sprite;
	import flash.events.Event;
    
    public class MenuGroup extends Cell {

		public static var currentMenu:MenuGroup;
		
        private var _textLabel:String = "";
        private var _choices:Array;
        private var _promptText:String = "";
        
        private var _open:Boolean = false;
        
        private var _button:BButton;
        private var _dropdown:Cell;
		private var _dropdownPosition:int;
        
        private var _homeDepth:int = 1;
		
		private var _items:Object;
		public function get items():Object { return _items; }
		
		public var menuStyle:Style;

        //
        //
        //
        function MenuGroup (container:Sprite, textLabel:String, choices:Array, menuPosition:int = Position.POSITION_BELOW, width:Number = NaN, height:Number = NaN, position:Position = null, style:Style = null) {
            
            init_Menu (container, textLabel, choices, menuPosition, width, height, position, style);
            
            if (_container != null) create();
            
        }
        
        //
        //
        private function init_Menu (container:Sprite, textLabel:String, choices:Array, menuPosition:int = Position.POSITION_BELOW, width:Number = NaN, height:Number = NaN, position:Position = null, style:Style = null):void {
            
            super.init_Cell(container, NaN, NaN, false, false, 0, position, style);
    
			 _type = "menugroup";
			 
            _textLabel = (textLabel.length > 0) ? textLabel : _textLabel;
            _choices = choices.concat();
			_dropdownPosition = menuPosition;
            _width = (!isNaN(width)) ? width : NaN;
			_height = (!isNaN(height)) ? height : NaN;
			_items = [];
            
        }
        
        //
        //
        override public function create ():void {
            
            super.create();
            
			var buttonStyle:Style = _style.clone();
			
            _button = BButton(addChild(new BButton(null, _textLabel, -1, _width, _height, false, false, false, new Position( { placement: Position.PLACEMENT_FLOAT, margins: 0 } ), buttonStyle)));
            
            var dropdownStyle:Style = _style.clone();
            dropdownStyle.borderWidth = 1;
            dropdownStyle.borderColor = ColorTools.getTintedColor(_style.borderColor, _style.backgroundColor, 0.5);
    
			var pos:Position = new Position({ placement: Position.PLACEMENT_ABSOLUTE });
			
			switch (_dropdownPosition) {
						
				case Position.POSITION_ABOVE:
					pos.top = 0 - _choices.length * 30;
					break;
					
				case Position.POSITION_LEFT:
					pos.left = _button.width;
					break;
					
				case Position.POSITION_RIGHT:
					pos.left = 0 - _width + 24;
					break;
					
				case Position.POSITION_BELOW:
				default:
					pos.top = _button.height;
					break;
				
			}
			
            _dropdown = Cell(addChild(new Cell(null, NaN, NaN, true, true, 0, pos, dropdownStyle)));
            _dropdown.trapMouse = _dropdown.collapse = true;
			
            _dropdown.hide();
			_dropdown.mc.filters = [new DropShadowFilter(6, 45, 0x000000, 0.25, 8, 8, 1, 2)];
            
            var choicesStyle:Style;
			if (menuStyle) {
				choicesStyle = menuStyle.clone();
			} else {
				choicesStyle = _style.clone();
				choicesStyle.background = choicesStyle.border = choicesStyle.gradient = false;
				choicesStyle.buttonDropShadow = false;
				choicesStyle.round = 0;
				choicesStyle.padding -= 2;
				choicesStyle.buttonFontSize -= 2;
			}
			
            var b:BButton;
			
			var i:int;
			var mw:Number = _width;
			var ts:Sprite = new Sprite();
			
			for (i = 0; i < _choices.length; i++) {
				
                b = BButton(new BButton(ts, _choices[i], Position.ALIGN_LEFT, NaN, NaN, false, false, false, new Position( { margins: "0 2 0 2" }), choicesStyle));
				mw = Math.max(mw, b.width);
                
            }
			
            for (i = 0; i < _choices.length; i++) {
				
                _items[i] = _items[StringUtils.clean(_choices[i])] = b = BButton(_dropdown.addChild(new BButton(null, _choices[i], Position.ALIGN_LEFT, mw, NaN, false, false, false, new Position( { margins: "0 2 0 2" }), choicesStyle)));
                b.addEventListener(EVENT_CLICK, onChoice);
                
            }
			
			_dropdown.update(true);
			
			switch (_dropdownPosition) {
						
				case Position.POSITION_ABOVE:
					_dropdown.y = 0 - _dropdown.height;
					break;
					
				case Position.POSITION_RIGHT:
					_dropdown.x = 0 - _dropdown.width;
					break;
					
				default:
					break;
				
			}
            
            _button.addEventListener(EVENT_CLICK, toggle);

            addEventListener(EVENT_BLUR, _dropdown.hide);
            
			if (isNaN(_width)) _width = _button.width;
            _height = _button.height;
            
        }
        
        //
        //
        public function onChoice (e:Event):void {
            
			_value = e.target.value;
			dispatchEvent(new Event(EVENT_CLICK));
            toggle();
              
        }
		
		//
		//
		public function addMenuListener(type:String = null, listener:Function = null, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void 
		{
			for each (var button:BButton in _items) button.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

        //
        //
        public function getItemByLabel (textLabel:String):BButton {
            
            for (var i:int = 0; i < _items.length; i++) if (BButton(_items[i]).textLabel == StringUtils.clean(textLabel)) return BButton(_items[i]);
    
            return null;
            
        }
        
        //
        //
        override public function toggle (e:Event = null):void {
            
            _dropdown.toggle();
            
            if (_dropdown.visible) {
                
				if (_mc.parent != null) {
					_homeDepth = _mc.parent.getChildIndex(_mc);
					_mc.parent.setChildIndex(_mc, _mc.parent.numChildren - 1);
				}
				
				if (currentMenu != null) currentMenu.onBlur();
				currentMenu = this;

                if (e == null) dispatchEvent(new Event(EVENT_FOCUS));
				
				mainStage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
      
            } else {
                
				if (_mc.parent != null && _homeDepth <= _mc.parent.numChildren) {
					_mc.parent.setChildIndex(_mc, _homeDepth);
				}
				
				if (currentMenu == this) currentMenu = null;

                if (e == null) dispatchEvent(new Event(EVENT_BLUR));
				
				mainStage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
                
            }
  
        }
		
		//
		//
		override public function disable(e:Event = null):void 
		{
			super.disable(e);
			_button.disable(e);
		}
		
		//
		//
		override public function enable(e:Event = null):void 
		{
			super.enable(e);
			
			_button.enable(e);
		}
		
		//
		//
		protected function onMouseMove (e:MouseEvent):void {
			
			var minX:Number = Math.min(0, _dropdown.x);
			var maxX:Number = Math.max(_width, _dropdown.x + _dropdown.width);
			var minY:Number = Math.min(0, _dropdown.y);
			var maxY:Number = Math.max(_height, _dropdown.y + _dropdown.height);
				
			minX -= 30;
			maxX += 30;
			minY -= 30;
			maxY += 30;
			
			if (_mc.mouseX < minX || _mc.mouseX > maxX || _mc.mouseY < minY || _mc.mouseY > maxY) onBlur();
			
		}

        //
        //
        override public function onBlur (e:Event = null):void {
        
            if (_dropdown.visible) toggle(e);
			
			mainStage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
    
        }
		
		override public function onChildClick(e:Event):void 
		{
			if (e.target != _button) super.onChildClick(e);
		}

    }
}
