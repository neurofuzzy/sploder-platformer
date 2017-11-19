package com.sploder.asui {
	
    import com.sploder.asui.*;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
   
	import flash.display.Sprite;
	import flash.events.Event;
	
    /**
    * ...
    * @author $(DefaultUser)
    */
    
    public class ScrollBar extends Cell {

        private var _orientation:int;
        
        private var _btn_back:BButton;
        private var _btn_fwd:BButton;
        
        private var _slider:Slider;
    
        private var _pageRatio:Number = 1;
        
        private var _targetCell:Cell;
        public function get targetCell():Cell { return _targetCell; }
        
        public function set targetCell(value:Cell):void {
            
            _targetCell = value;
			if (_orientation == Position.ORIENTATION_VERTICAL) _targetCell.scrollable = true;
            
            if (_targetCell != null) {
                
                _targetCell.maskContent = true;
                
                clear();
                create();
                
                onTargetCellChange();
                
                _targetCell.addEventListener(EVENT_CHANGE, onTargetCellChange);
                _targetCell.addEventListener(EVENT_FOCUS, onTargetCellShow);
                _targetCell.addEventListener(EVENT_BLUR, onTargetCellHide);
				_targetCell.addEventListener(EVENT_HOVER_START, scrollBack);
				_targetCell.addEventListener(EVENT_HOVER_END, scrollForward);

            }
            
        }
        
    
        //
        //
        public function ScrollBar (container:Sprite = null, width:Number = NaN, height:Number = NaN, orientation:int = 13 , position:Position = null, style:Style = null) {
            
            init_ScrollBar(container, width, height, orientation, position, style);
            
            if (_container != null) create();
            
        }
        
        //
        //
        private function init_ScrollBar (container:Sprite = null, width:Number = NaN, height:Number = NaN, orientation:int = 13 , position:Position = null, style:Style = null):void {
  
            super.init_Cell(container, _width, _height, false, false, 0, position, style);
			
			_type = "scrollbar";
            
            _orientation = orientation;
            
            _width = width;
            _height = height;
    
        }
        
        //
        //
        override public function create ():void {
            
            super.create();
            
            if (_targetCell == null) return;
            
            var offset:Number = 0;
            
            if (_parentCell != null) {
                
                if (_parentCell.style.border) offset = _parentCell.style.borderWidth;
                
				var pad:int = (_targetCell.background == false) ? 10 : 0;
				
                if (_orientation == Position.ORIENTATION_HORIZONTAL) {
                    
                    _width = _targetCell.width;
                    _height = (_height == 0 || isNaN(_height)) ? 20 : _height;

                    //if (_parentCell.style.border && _position.margin_top + _position.margin_bottom < _parentCell.style.borderWidth && _width > _parentCell.width - _position.margin_right - _position.margin_left - _parentCell.style.borderWidth * 2) _width -= offset * 2;
                    
                    _position = new Position( { margins: [_position.margin_top, _position.margin_right, _position.margin_bottom, _position.margin_left], placement: Position.PLACEMENT_ABSOLUTE, zindex: 1000, top: _targetCell.y + _targetCell.height + pad, left: _targetCell.x } );
                    
                } else {
    
                    _width = (_width == 0 || isNaN(_width)) ? 20 : _width;
                    _height = _targetCell.height;
                    
                    //if (_parentCell.style.border && _position.margin_top + _position.margin_bottom < _parentCell.style.borderWidth && _height > _parentCell.height - _position.margin_top - _position.margin_bottom - _parentCell.style.borderWidth * 2) _height -= offset * 2;
                    
                    _position = new Position( { margins: [_position.margin_top, _position.margin_right, _position.margin_bottom, _position.margin_left], placement: Position.PLACEMENT_ABSOLUTE, zindex: 1000, top: _targetCell.y , left: _targetCell.x + _targetCell.width + pad } );
                    
                }
                
            }
			
            var _scrollbarStyle:Style = _style.clone();
            _scrollbarStyle.borderWidth = 2;
            _scrollbarStyle.borderColor = ColorTools.getTintedColor(_style.buttonColor, _style.backgroundColor, 0.5);
    
            var unselectedColor1:Number = ColorTools.getTintedColor(_style.backgroundColor, _style.borderColor, 0.3);
            var unselectedColor2:Number = ColorTools.getTintedColor(_style.backgroundColor, _style.borderColor, 0.1);
            
            var pos:Position;
            
            if (_orientation == Position.ORIENTATION_HORIZONTAL) {
                
                pos = new Position( { placement: Position.PLACEMENT_FLOAT, margin_right: 2 } );
    
                DrawingMethods.roundedRect(_mc, true, 0, 0, _height, _height, "0", [unselectedColor2, unselectedColor1], [50, 50], [0, 255]);
                DrawingMethods.roundedRect(_mc, false, _height + 2, 0, _width - (_height * 2) - 4, _height, "0", [unselectedColor2, unselectedColor1], [50, 50], [0, 255]);
                DrawingMethods.roundedRect(_mc, false, _width - _height, 0, _height, _height, "0", [unselectedColor2, unselectedColor1], [50, 50], [0, 255]);
             
                _btn_back = BButton(addChild(new BButton(null, Create.ICON_ARROW_RIGHT, -1, 20, 20, false, false, false, pos, _scrollbarStyle)));
                _slider = Slider(addChild(new Slider(null, _width - 44, _height, _orientation, 0, pos, _style)));
                _btn_fwd = BButton(addChild(new BButton(null, Create.ICON_ARROW_LEFT, -1, 20, 20, false, false, false, pos, _scrollbarStyle)));
                
            } else {
                
                pos = new Position( { margin_bottom: 2 } );
                
                DrawingMethods.roundedRect(_mc, true, 0, 0, _width, _width, "0", [unselectedColor2, unselectedColor1], [50, 50], [0, 255]);
                DrawingMethods.roundedRect(_mc, false, 0, _width + 2, _width, _height - (_width * 2) - 4, "0", [unselectedColor2, unselectedColor1], [50, 50], [0, 255]);
                DrawingMethods.roundedRect(_mc, false, 0, _height - _width, _width, _width, "0", [unselectedColor2, unselectedColor1], [50, 50], [0, 255]);
                
                _btn_back = BButton(addChild(new BButton(null, Create.ICON_ARROW_UP, -1, _width, _width, false, false, false, pos, _scrollbarStyle)));
                _slider = Slider(addChild(new Slider(null, _width, _height - (_width * 2) - 4, _orientation, 0, pos, _style)));    
                _btn_fwd = BButton(addChild(new BButton(null, Create.ICON_ARROW_DOWN, -1, _width, _width, false, false, false, pos, _scrollbarStyle)));
                
            }
            
            _btn_back.addEventListener(EVENT_CLICK, pageBack);
            _slider.addEventListener(EVENT_CHANGE, onChange);
            _btn_fwd.addEventListener(EVENT_CLICK, pageForward);
            if (_parentCell) _parentCell.addEventListener(EVENT_BLUR, onBlur);
            
            _btn_back.tabEnabled = _slider.tabEnabled = _btn_fwd.tabEnabled = false;
    
			addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
            
        }
		
		//
		//
		public function alignToTarget ():void {
			
            var contentMin:Number;
     
            if (_orientation == Position.ORIENTATION_HORIZONTAL) contentMin = targetCell.width - targetCell.contentWidth;
            else contentMin = targetCell.height - targetCell.contentHeight;
          
            if (_orientation == Position.ORIENTATION_HORIZONTAL) _slider.sliderValue = 0 - (((0 - targetCell.contentX + contentMin) / contentMin) - 1);
			else _slider.sliderValue = 0 - (((0 - targetCell.contentY + contentMin) / contentMin) - 1);
			
		}
        
        //
        //
        private function updateComponents ():void {

            
            if (_orientation == Position.ORIENTATION_HORIZONTAL) {
                
                _slider.ratio = _targetCell.width / _targetCell.contentWidth;
                
            } else {
                
                _slider.ratio = _targetCell.height / _targetCell.contentHeight;
                
            }
    
            if (_slider.ratio == 1) {
                disable();
            } else {
                enable();
            }
                
        }
        
        //
        //
        public function onChange (e:Event = null):void {

            var contentMin:Number;
            var contentMax:Number = 0;
            
			if (targetCell == null) return;
			
            if (_orientation == Position.ORIENTATION_HORIZONTAL) contentMin = targetCell.width - targetCell.contentWidth;
            else contentMin = targetCell.height - targetCell.contentHeight;
            
            if (_orientation == Position.ORIENTATION_HORIZONTAL) targetCell.contentX = Math.round(contentMin - contentMin * (1 - _slider.sliderValue));
            else targetCell.contentY = Math.round(contentMin - contentMin * (1 - _slider.sliderValue));
 
		}
        
        //
        //
        public function onTargetCellChange (e:Event = null):void {

            if (_orientation == Position.ORIENTATION_HORIZONTAL) _pageRatio = Math.min(1, Math.max(0.01, targetCell.width / (targetCell.contentWidth - targetCell.width)));
            else _pageRatio = Math.min(1, Math.max(0.01, targetCell.height / (targetCell.contentHeight - targetCell.height)));
            
			var pad:int = (_targetCell.background == false) ? 10 : 5;
			
            if (_orientation == Position.ORIENTATION_HORIZONTAL) {
                
                _position.top = _targetCell.y + _targetCell.height + _position.margin_top + pad;
                _position.left = _targetCell.x;
				
                
            } else {
                
                _position.top = _targetCell.y;
                _position.left = _targetCell.x + _targetCell.width + _position.margin_left + pad;
                
            }
            
            x = _position.left;
            y = _position.top;
			
			
            
            updateComponents();
            
            var contentMin:Number;
     
            if (_orientation == Position.ORIENTATION_HORIZONTAL) contentMin = targetCell.width - targetCell.contentWidth;
            else contentMin = targetCell.height - targetCell.contentHeight;
          
            if (_orientation == Position.ORIENTATION_HORIZONTAL) _slider.sliderValue = 0 - (((0 - targetCell.contentX + contentMin) / contentMin) - 1);
			else _slider.sliderValue = 0 - (((0 - targetCell.contentY + contentMin) / contentMin) - 1);
			
			onChange();
    
        }
        
        //
        //
        public function onTargetCellShow (e:Event):void {

    
            updateComponents();
            show();
            
        }
        
        //
        //
        public function onTargetCellHide (e:Event = null):void {
            
            if (_targetCell.visible == false) hide();
            
        }
         
        //
        //
        override public function enable (e:Event = null):void {
            
            super.enable();
            
            _btn_back.show();
            _btn_fwd.show();
            _slider.show();
            
        }
        
        //
        //
        override public function disable (e:Event = null):void {
    
            super.disable();
            
            _btn_back.hide();
            _btn_fwd.hide();
            _slider.hide();	
            
        }
        
        //
        //
        protected function pageForward (e:Event = null):void {

            
            _slider.sliderValue += _pageRatio / 3;
            onChange();
    
        }
    
		//
        //
        public function reset (e:Event = null):void {

            
            _slider.sliderValue = 0;
            onChange();
            
        }
		
        //
        //
        protected function center (e:Event = null):void {

            
            _slider.sliderValue = 0.5;
            onChange();
            
        }
        
        //
        //
        protected function pageBack (e:Event = null):void {
        
            _slider.sliderValue -= _pageRatio / 3;
            onChange();
    
        }
		
		//
		//
		public function scrollForward (e:Event = null):void {
			
			var pixel:Number;
			
			if (_orientation == Position.ORIENTATION_VERTICAL) {
				pixel = _pageRatio / _height;
				_slider.sliderValue += pixel * 20;
			} else {
				pixel = _pageRatio / _width;
				_slider.sliderValue += pixel * 20;				
			}
			
            onChange();
			
		}
		
		//
		//
		public function scrollBack (e:Event = null):void {
			
			var pixel:Number;
			
			if (_orientation == Position.ORIENTATION_VERTICAL) {
				pixel = _pageRatio / _height;
				_slider.sliderValue -= pixel * 20;
			} else {
				pixel = _pageRatio / _width;
				_slider.sliderValue -= pixel * 20;				
			}
			
            onChange();
			
		}
    
        //
        //
        protected function onMouseWheel (e:MouseEvent):void {

			var delta:int = e.delta;
            
            _slider.sliderValue -= delta / 60;
            onChange();
    
        }
		
		 //
        //
        public function applyDelta (delta:Number = 0):void {

            _slider.sliderValue -= delta / 60;
            onChange();
    
        }
        
        //
        //
        override public function onBlur (e:Event = null):void {
            
            if (_slider != null) _slider.sliderValue = 0;
            onChange();
            
        }
        
    }
}
