package com.sploder.asui {
    
	import com.sploder.asui.*;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
    import flash.display.Sprite;
	import flash.events.Event;
    
    
    public class Cell extends Component {
		
		private static var _focused:Cell;
		static public function get focused():Cell { return _focused; }
		static public function set focused(value:Cell):void 
		{
			if (_focused && value != _focused) _focused.onBlur();
			_focused = value;
		}

        protected var _background:Boolean = true;
		public function get background():Boolean { return _background; }
		public function set background(value:Boolean):void { 
			_background = value;
			redraw(true);
		}
        protected var _border:Boolean = true;
        protected var _round:Number = 0;
        
        protected var _bkgd:Sprite;
		public function get bkgd():Sprite { return _bkgd; }
		public function set bkgd(value:Sprite):void 
		{
			if (_bkgd != null && _bkgd.parent == _mc) _mc.removeChild(_bkgd);
			_bkgd = value;
			if (_bkgd != null) _mc.addChildAt(_bkgd, 0);
		}		
		
        protected var _childrenContainer:Sprite;
		
		public function set mouseChildren (val:Boolean):void {
			_childrenContainer.mouseChildren = val;
		}
    
        protected var _mask:Sprite;
        
        protected var _maskContent:Boolean = false;
        public function get maskContent():Boolean { return _maskContent; }
        public function set maskContent(value:Boolean):void { 

            _maskContent = value; 
            if (_maskContent && _created) {
                createMask();
            } else if (_created) {
                _childrenContainer.mask = null;
            }
        }
        
        override public function get width ():uint {
           
            if (_width == 0) return _mc.width;
            else return _width;
            
        }
        
        override public function get height ():uint {
            
            if (_height == 0) return _mc.height;
            else return _height;
            
        }
		
		public var fixedContentSize:Boolean = false;
        
        public function get contentWidth ():Number { if (fixedContentSize) return _width else return Position.getCellContentWidth(this); }
        public function get contentHeight ():Number { if (fixedContentSize) return _height else return Position.getCellContentHeight(this); }
        
        public function get contentX ():Number { return _childrenContainer.x; }
        public function set contentX (value:Number):void {
			if (!isNaN(value)) _childrenContainer.x = Math.min(0, Math.max(value, 0 - Position.getCellContentWidth(this) + _width));
		}
        
        public function get contentY ():Number { return _childrenContainer.y; }
        public function set contentY (value:Number):void {
			if (!isNaN(value)) _childrenContainer.y = Math.min(0, Math.max(value, 0 - Position.getCellContentHeight(this) + _height));
		}

		protected var _wrap:Boolean = true;
		public function get wrap():Boolean { return _wrap; }
		
		public function set wrap(value:Boolean):void {
			_wrap = value;
			Position.arrangeContent(this, true);
		}
            
        protected var _collapse:Boolean = false;
        public function get collapse():Boolean { return _collapse; }
        public function set collapse(value:Boolean):void { _collapse = value; }
		
		protected var _scrollable:Boolean = false;
		public function get scrollable():Boolean { return _scrollable; }
		public function set scrollable(value:Boolean):void { _scrollable = value; }

        public function get trapMouse ():Boolean { return _bkgd.mouseEnabled; }
        public function set trapMouse (val:Boolean):void {

            if (val) {
                if (_background == false) DrawingMethods.rect(_bkgd, true, 0, 0, _width, _height, 0x000000, 0);
                _bkgd.useHandCursor = false;
                _bkgd.mouseEnabled = true;

            } else {
                _bkgd.mouseEnabled = false;
                _bkgd.useHandCursor = true;
            }
        }
        
		protected var _childNodes:Array;
        public function get childNodes():Array { return _childNodes; }
        
        protected var _sortChildNodes:Boolean = false;
        public function get sortChildNodes():Boolean { return _sortChildNodes; }
		
		protected var _mouseWentOver:Boolean = false;
		
		public var hideOnlyAfterMouseOver:Boolean = false;
		
		protected var _hideOnMouseOut:Boolean = false;
        public function get hideOnMouseOut():Boolean { return _hideOnMouseOut; }
		public function set hideOnMouseOut(value:Boolean):void 
		{
			if (_hideOnMouseOut) {
				if (_mc) _mc.removeEventListener(MouseEvent.MOUSE_OVER, markMouseOver);
				Component.mainStage.removeEventListener(MouseEvent.MOUSE_MOVE, checkMouseForHide);
			}
			_hideOnMouseOut = value;
			if (_hideOnMouseOut) {
				if (_mc) _mc.addEventListener(MouseEvent.MOUSE_OVER, markMouseOver);
				Component.mainStage.addEventListener(MouseEvent.MOUSE_MOVE, checkMouseForHide);
			}
		}
		
        public var lastArrangedChildIndex:Number = -1;
        public var lastArrangedChildX:Number = 0;
        public var lastArrangedChildY:Number = 0;
		
        public function get contents ():Sprite { return _childrenContainer; }
		
        protected var _title_tf:TextField;
        
        //
        //
        public function Cell (container:Sprite = null, width:Number = NaN, height:Number = NaN, background:Boolean = false, border:Boolean = false, round:Number = 0, position:Position = null, style:Style = null) {
            
            init_Cell (container, width, height, background, border, round, position, style);
			  
            if (_container != null) create();
            
        }
		
		protected function init_Cell (container:Sprite, width:Number = NaN, height:Number = NaN, background:Boolean = false, border:Boolean = false, round:Number = 0, position:Position = null, style:Style = null):void {
			
			super.init(container, position, style);
			 
			_type = "cell";
			
            _width = (!isNaN(width)) ? width : _width;
            _height = (!isNaN(height)) ? height : _height;
            
            _background = background;
            _border = border;
            
            _round = (round > 0) ? round : 0;
    
            _childNodes = [];			
			
		}
        
        //
        //
        override public function create ():void {

            super.create();
            
            if (_parentCell != null) {
                if (_width == 0) _width = _parentCell.width - _position.margin_left - _position.margin_right;
                if (_height == 0 && !_position.collapse) _height = _parentCell.height - _position.margin_top - _position.margin_bottom;
                _parentCell.addEventListener(EVENT_BLUR, onBlur);
            }
            
            _bkgd = Sprite(_mc.addChild(new Sprite()));
            
            drawBackground();
            
            _childrenContainer = Sprite(_mc.addChild(new Sprite()));
			_childrenContainer.name = _mc.name + "_childContainer";
            
            if (_maskContent) createMask();
            
            _mc.x = _position.margin_top;
            _mc.y = _position.margin_left;
            
            for (var i:int = 0; i < _childNodes.length; i++) Component(childNodes[i]).parentCell = this;    
			
			//if (!isNaN(_width) && !isNaN(_height)) {
			//	_mc.graphics.lineStyle(1, 0x0099ff);
			//	_mc.graphics.drawRect(0, 0, _width, _height);
			//}
            
        }
        
        //
        //
        protected function drawBackground ():void {
            
            _bkgd.graphics.clear();
            
            if (_background && _round > 0) {
                
				Create.background(_bkgd, _width, _height, _style, _border, _round);
   
            } else {
                
                if (_border && !_background) DrawingMethods.emptyRect(_bkgd, false, 0, 0, _width, _height, _style.borderWidth, _style.borderColor, _style.borderAlpha);
                else if (_background) Create.background(_bkgd, _width, _height, _style, _border, _round);
				
            }  
            
        }
        
        //
        //
        private function createMask ():void {
			
            if (_mask == null) _mask = Sprite(_mc.addChild(new Sprite()));
            
            _mask.graphics.clear();
            
            if (_border) DrawingMethods.rect(_mask, false, _style.borderWidth, _style.borderWidth, _width - _style.borderWidth * 2, _height - _style.borderWidth * 2, _style.backgroundColor);
            else DrawingMethods.rect(_mask, false, 0, 0, _width, _height);
    
            _mask.visible = false;
            
            _childrenContainer.mask = _mask;
            
        }
		
		//
		//
		public function resizeCell (width:uint, height:uint):void {
			
			_width = width;
			_height = height;
			if (_maskContent) {
				createMask();
			}
			drawBackground();
			
		}
        
        //
        //
        private function redraw (force:Boolean = false):void {

            if (_container != null && (force || _collapse || _position.collapse)) {
                
				if (!fixedContentSize && (_collapse || _position.collapse)) {
					
					if (isNaN(_width)) _width = 0;
					
					_width = Math.max(_width, Position.getCellContentWidth(this) + _style.borderWidth * 2);
					_height = Position.getCellContentHeight(this) + _style.borderWidth * 2 + _style.padding;
					if (_maskContent) createMask();
					
				}
 
                drawBackground();
                
            }
            
        }
		
		//
		//
		public function update (updateWidth:Boolean = false):void {
			
			_height = Position.getCellContentHeight(this);
			if (updateWidth) _width = Position.getCellContentWidth(this);
			redraw();
			
		}
        
        //
        //
        public function addChild (child:Component):Component {
            
            if (child.created) {
				if (child.mc.parent == null) {
					_childrenContainer.addChild(child.mc);
					return child;
				}
				return null;
			}
            
            for (var i:int = 0; i < _childNodes.length; i++) if (_childNodes[i] == child) return child;
    
            _childNodes.push(child);
    
            child.parentCell = this;
            child.addEventListener(EVENT_FOCUS, onChildFocus);
			child.addEventListener(EVENT_CHANGE, onChildChange);
			child.addEventListener(EVENT_CLICK, onChildClick);
            
            if (child.position.zindex != 1) _sortChildNodes = true;
                    
            Position.arrangeContent(this);
            redraw();
    
            dispatchEvent(new Event(EVENT_CHANGE));
            
            return child;
    
        }
    
        
        //
        //
        public function removeChild (child:Component, destroy:Boolean = true):Boolean {
            
            for (var i:int = _childNodes.length - 1; i >= 0; i--) {
            
                if (_childNodes[i] == child) {
                
                    _childNodes.splice(i, 1);
                    
                    Position.arrangeContent(this);
                    
                    dispatchEvent(new Event(EVENT_CHANGE));
                    
                    if (destroy) return child.destroy();
					else {
						if (child.mc.parent == _childrenContainer) _childrenContainer.removeChild(child.mc);
						else if (child.parentCell == this && child.mc.parent != null) child.mc.parent.removeChild(child.mc); 
						return true;
					}
                    
                }
                
            }
            
            return false;
            
        }
        
        //
        //
        public function clear ():void {
            
            for (var i:int = _childNodes.length - 1; i >= 0; i--) removeChild(Component(_childNodes[i]), true);
            
            lastArrangedChildIndex = -1;
            lastArrangedChildX = lastArrangedChildY = 0;
            
            dispatchEvent(new Event(EVENT_CHANGE));
            
        }
        
        //
        //
        public function onChildFocus (e:Event):void {

            
            for (var i:int = 0; i < _childNodes.length; i++) {
                
                if (_childNodes[i] != e.target) if (_childNodes[i] is Cell) Cell(_childNodes[i]).onBlur();
    
            }
    
        }
		
        //
        //
        public function onChildChange (e:Event):void {

            dispatchEvent(new Event(EVENT_CHANGE));
    
        }
		
		//
        //
        public function onChildClick (e:Event):void {

            dispatchEvent(new Event(EVENT_CLICK));
    
        }
        
        //
        //
        override public function enable (e:Event = null):void {
            
            super.enable();
            
            for (var i:int = _childNodes.length - 1; i >= 0; i--) Component(_childNodes[i]).enable();
            
        }
        
        //
        //
        override public function disable (e:Event = null):void {

    
            super.disable();
            
            for (var i:int = _childNodes.length - 1; i >= 0; i--) Component(_childNodes[i]).disable();
            
        }
		
		override public function show(e:Event = null):void 
		{
			super.show(e);
			_mouseWentOver = false;
		}
        
        //
        //
        override public function hide (e:Event = null):void {
            
			_mouseWentOver = false;
            if (_mc != null) _mc.visible = false;
            dispatchEvent(new Event(EVENT_BLUR));
            for (var i:int = _childNodes.length - 1; i >= 0; i--) Component(_childNodes[i]).dispatchEvent(new Event(EVENT_BLUR));
            
        }
        
        //
        //
        public function onBlur (e:Event = null):void {
            
            dispatchEvent(new Event(EVENT_BLUR));
            
        }
		
		protected function markMouseOver (e:MouseEvent):void {
			
			_mouseWentOver = true;
			
		}
		
		//
		//
		protected function checkMouseForHide (e:MouseEvent):void {
			
			if (!visible) return;
			
			if (hideOnlyAfterMouseOver && !_mouseWentOver) return;
			
			var minX:Number = -40
			var maxX:Number = 40 + _width;
			var minY:Number = -40
			var maxY:Number = 40 + _height;
				
			if (_mc.mouseX < minX || _mc.mouseX > maxX || _mc.mouseY < minY || _mc.mouseY > maxY) {
				hide();
			}
			
		}
		
		public function allowCellDrag (mouseOut:Boolean = true, addDragArea:Boolean = false):void {
			
			if (!_draggable) {
				
				_draggable = true;
				if (_background == false) {
					_bkgd.graphics.lineStyle(0, 0, 0);
					_bkgd.graphics.beginFill(_style.borderColor, 0.75);
					_bkgd.graphics.drawCircle(_style.round + _style.borderWidth, _style.round + _style.borderWidth, 3); 
				}
				_mc.addEventListener(MouseEvent.MOUSE_DOWN, startDrag);
				_mc.addEventListener(MouseEvent.MOUSE_UP, stopDrag);
				if (mouseOut) _mc.addEventListener(MouseEvent.MOUSE_OUT, stopDrag);
				
				if (addDragArea) {
					var d:Sprite = new Sprite();
					_bkgd.addChild(d);
					Create.dragArea(d, _width - 12, 24, _style);
					d.x = 6;
					d.y = _height - 30;
					d.mouseEnabled = false;
				}
			
			}
				
				
		}
		
		protected function startDrag (e:Event):void {
			if (e.target == _bkgd) _mc.startDrag();
		}
		
		protected function stopDrag (e:Event):void {
			_mc.stopDrag();
		}
        
        
    }
}
