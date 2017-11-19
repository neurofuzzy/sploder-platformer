package com.sploder.asui {
    
	import com.sploder.asui.*;
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.StyleSheet;
	import flash.text.TextFieldAutoSize;

	import flash.display.Sprite;
	import flash.events.Event;
	
    /**
    * ...
    * @author $(DefaultUser)
    */
    
    
    public class DialogueBox extends Cell {

		protected var _buttonMask:Sprite;
		protected var _closeButton:BButton;
		protected var _title:String;
		protected var _titleField:HTMLField;
		protected var _controls:Array;
		protected var _controlsCell:Cell;
		protected var _contentCell:Cell;
		protected var _scroll:Boolean;
		protected var _scrollbar:ScrollBar;
		
		protected var _buttons:Array;
		public function get buttons():Array { return _buttons; }
		
		public var pointer:Boolean = false;
		public var pointerPosition:int = 0;
		public var pointerSize:int = 0;
		
		public var useBackgroundMask:Boolean = true;
		
		public var offsetX:int = 0;
		public var offsetY:int = 0;
		
		public var contentHasBackground:Boolean = false;
		public var contentHasBorder:Boolean = false;
		public var contentPadding:int = 20;
		public var contentBottomMargin:Number = 20;
		public var contentStyle:Style;
		
		public function get contentCell():Cell { return _contentCell; }
		
		public function get titleField():HTMLField 
		{
			return _titleField;
		}
		
		public function get scrollbar():ScrollBar 
		{
			return _scrollbar;
		}
		
        //
        //
        public function DialogueBox (container:Sprite, width:Number, height:Number, title:String = "", controls:Array = null, scroll:Boolean = false, round:Number = 0, position:Position = null, style:Style = null) {
            
            init_DialogueBox(container, width, height, title, controls, scroll, round, position, style);
            
            if (_container != null) create();
            
        }
        
        //
        //
        private function init_DialogueBox (container:Sprite, width:Number, height:Number, title:String = "", controls:Array = null, scroll:Boolean = false, round:Number = 0, position:Position = null, style:Style = null):void {

            super.init_Cell(container, _width, _height, true, true, 0, position, style);
            
			_type = "dialoguebox";

            _width = width;
            _height = height;
			_title = title;
			_controls = controls;
			_scroll = scroll;
			_buttons = [];
			
			_round = round;
			_position.zindex = 10000;

        }
        
        //
        //
        override public function create ():void {
           
			if (isNaN(_width)) _width = Math.floor(_parentCell.width / 2);
			if (isNaN(_height)) _height = Math.floor(_parentCell.height / 2);
			
			if (_position == null || _position.placement != Position.PLACEMENT_ABSOLUTE) {
				
				_position = new Position( { placement: Position.PLACEMENT_ABSOLUTE, top: (_parentCell.height - _height) / 2 + offsetY, left: (_parentCell.width - _width) / 2 + offsetX} );
				
			}
			
			_position.zindex = 10000;
			
			super.create();
			
			if (useBackgroundMask) {
				
				_buttonMask = new Sprite();
				_mc.addChild(_buttonMask);
				
				var g:Graphics = _buttonMask.graphics;
				
				g.beginFill(_style.maskColor, _style.maskAlpha);
				g.drawRect(0, 0, _parentCell.width, _parentCell.height);
				_buttonMask.x = 0 - _position.left;
				_buttonMask.y = 0 - _position.top;
				
				_mc.setChildIndex(_buttonMask, 0);
				
				connectButton(_buttonMask, false);
				_buttonMask.useHandCursor = false;
				
			}

			_mc.filters = [new DropShadowFilter(6, 45, 0x000000, 0.25, 8, 8, 1, 2)];
			
			if (_title.length > 0) {
				
				_titleField = new HTMLField(null, '<p align="center"><h3>' + _title + '</h3></p>', _width - _style.borderWidth * 2 - _round * 2, false, 
				new Position (null, -1, -1, -1, (_style.borderWidth + 10) + " 0 0 " + (_style.borderWidth + _round)), 
				_style);
				addChild(_titleField);
				
			}
			
			var cbStyle:Style = _style.clone();
			cbStyle.border = false;
			cbStyle.background = false;
			cbStyle.gradient = false;
			cbStyle.buttonTextColor = _style.buttonColor;

			_closeButton = addChild(new BButton(null, Create.ICON_CLOSE, -1, 20, 20, false, false, false, new Position( { zindex: 1000, placement: Position.PLACEMENT_ABSOLUTE, top: _style.borderWidth + _round / 3, left: _width - 20 - _style.borderWidth - _round / 3 } ), cbStyle)) as BButton;
    
			_closeButton.name = name + "_close";
			
			_closeButton.addEventListener(Component.EVENT_CLICK, hide);
			
			if (_controls != null) {
				
				var btn:BButton;
				var btnStyle:Style = _style.clone();
				btnStyle.borderWidth = Math.min(2, _style.borderWidth / 2);
				btnStyle.round = Math.min(10, _style.round);
			
				_controlsCell = new Cell(null, _width, 50, false, false, 0, new Position( { placement: Position.PLACEMENT_ABSOLUTE, top: _height - 50 }, Position.ALIGN_CENTER ), _style);
				addChild(_controlsCell);
				
				for (var i:int = 0; i < _controls.length; i++) {
					
					btn = _controlsCell.addChild(new BButton(null, _controls[i], -1, NaN, NaN, false, false, false, new Position( { placement: Position.PLACEMENT_FLOAT, margin_right: 5 } ), btnStyle)) as BButton;
					
					btn.name = name + "_" + btn.value.toLowerCase().split(" ").join("_");
					
					_buttons.push(btn);
					
				}
				
				_controlsCell.y = _height - _controlsCell.height - Math.max(10, _round / 2);
				
			}

			var cCellWidth:Number = _width - Math.max(35, (_round * 2 + _style.borderWidth * 2));
			var cCellHeight:Number;
			var topMargin:int = 0;
			if (_titleField != null) {
				cCellHeight = _height - _titleField.y - _titleField.height;
			} else {
				cCellHeight = _height;
				topMargin = Math.max(25, _style.borderWidth + _round / 2);
			}
			if (_controlsCell != null) cCellHeight -= _controlsCell.height + Math.max(10, _round / 2);
			cCellHeight -= contentBottomMargin;
			
			if (_scroll) cCellWidth -= 20; 
			
			if (contentStyle == null) contentStyle = _style;
			
			_contentCell = new Cell(null, cCellWidth, cCellHeight, contentHasBackground, contentHasBorder, 0, 
				new Position(null, -1, -1, -1, topMargin + " 0 0 " + Math.max(contentPadding, (_style.borderWidth + _round))),
				contentStyle);
				
			_contentCell.name = name + "_content";

			addChild(_contentCell);
			
			if (_scroll) {
				
				_scrollbar = new ScrollBar(null, NaN, NaN, Position.ORIENTATION_VERTICAL, null, _style);
				
				addChild(_scrollbar);
				_scrollbar.targetCell = _contentCell;

			}
			
        }
		
		override protected function onClick(e:MouseEvent = null):void 
		{
			super.onClick(e);
			hide();
			
		}
		
        //
        //
        override protected function drawBackground ():void {
            
			super.drawBackground();
			
			var pX:int;
			var pY:int;
			var pS:int = pointerSize;
			var pB:int = _style.borderWidth;
			var pH:Number = pB * 0.5;
			
			var g:Graphics = _bkgd.graphics;
			
			if (!pointer) return;
			
			if (isNaN(pointerPosition) || pointerPosition == 0) {
				pointerPosition = _width * 1.5 + _height;
			}

			if (pointerPosition < _width) {
				
				pX = Math.max(pointerSize + pB, Math.min(_width - pointerSize - pB, pointerPosition));
				pY = 0;
				
				if (_border) {
					
					g.moveTo(pX - pS + pB - pH, pY);
					
					g.beginFill(_style.borderColor, _style.borderAlpha);
					g.lineTo(pX - pS, pY);
					g.lineTo(pX, pY - pS);
					g.lineTo(pX + pS, pY);
					g.lineTo(pX + pS - pB - pH, pY);
					g.lineTo(pX, pY - pS + pB + pH);
					g.lineTo(pX - pS + pB + pH, pY);
					g.endFill();
					
					g.moveTo(pX - pS + pB - pH, pY + pB);
					
					g.beginFill(_style.backgroundColor, _style.backgroundAlpha);
					g.lineTo(pX, pY - pS + pB + pH);
					g.lineTo(pX + pS - pB + pH, pY + pB);
					g.lineTo(pX - pS + pB - pH, pY + pB);
					g.endFill();
					
				} else {
					
					g.moveTo(pX - pS, pY);
					
					g.beginFill(_style.backgroundColor, _style.backgroundAlpha);
					g.lineTo(pX, pY - pS);
					g.lineTo(pX + pS, pY);
					g.lineTo(pX - pS, pY);
					g.endFill();
					
				}
				
			} else if (pointerPosition < _width + _height) {
				
				pX = _width;
				pY = Math.max(pointerSize + pB, Math.min(_height - pointerSize - pB, pointerPosition - _width));
				
				if (_border) {
					
					g.moveTo(pX, pY - pS + pB - pH);
					
					g.beginFill(_style.borderColor, _style.borderAlpha);
					g.lineTo(pX, pY - pS);
					g.lineTo(pX + pS, pY);
					g.lineTo(pX, pY + pS);
					g.lineTo(pX, pY + pS - pB - pH);
					g.lineTo(pX + pS - pB - pH, pY);
					g.lineTo(pX, pY - pS + pB + pH);
					g.endFill();
					
					g.moveTo(pX - pB, pY - pS + pB - pH);
					
					g.beginFill(_style.backgroundColor, _style.backgroundAlpha);
					g.lineTo(pX + pS - pB - pH, pY);
					g.lineTo(pX - pB, pY + pS - pB + pH);
					g.lineTo(pX - pB, pY - pS + pB - pH);
					g.endFill();
					
				} else {
					
					g.moveTo(pX - pS, pY);
					
					g.beginFill(_style.backgroundColor, _style.backgroundAlpha);
					g.lineTo(pX + pS, pY);
					g.lineTo(pX, pY + pS);
					g.lineTo(pX, pY - pS);
					g.endFill();
					
				}
				
			} else if (pointerPosition < _width * 2 + _height) {
				
				pX = Math.max(pointerSize + pB, Math.min(_width - pointerSize - pB, pointerPosition - _width - _height));
				pX = _width - pX;
				pY = _height;	
				
				if (_border) {
					
					g.moveTo(pX - pS + pB - pH, pY);
					
					g.beginFill(_style.borderColor, _style.borderAlpha);
					g.lineTo(pX - pS, pY);
					g.lineTo(pX, pY + pS);
					g.lineTo(pX + pS, pY);
					g.lineTo(pX + pS - pB - pH, pY);
					g.lineTo(pX, pY + pS - pB - pH);
					g.lineTo(pX - pS + pB + pH, pY);
					g.endFill();
					
					g.moveTo(pX - pS + pB - pH, pY - pB);
					
					g.beginFill(_style.backgroundColor, _style.backgroundAlpha);
					g.lineTo(pX, pY + pS - pB - pH);
					g.lineTo(pX + pS - pB + pH, pY - pB);
					g.lineTo(pX - pS + pB - pH, pY - pB);
					g.endFill();
					
				} else {
					
					g.moveTo(pX - pS, pY);
					
					g.beginFill(_style.backgroundColor, _style.backgroundAlpha);
					g.lineTo(pX, pY + pS);
					g.lineTo(pX + pS, pY);
					g.lineTo(pX - pS, pY);
					g.endFill();
					
				}
				
			} else {
				
				pX = 0;
				pY = Math.max(pointerSize + pB, Math.min(_height - pointerSize - pB, pointerPosition - _width * 2 - _height));
				pY = _height - pY;
				
				if (_border) {
					
					g.moveTo(pX, pY - pS + pB - pH);
					
					g.beginFill(_style.borderColor, _style.borderAlpha);
					g.lineTo(pX, pY - pS);
					g.lineTo(pX - pS, pY);
					g.lineTo(pX, pY + pS);
					g.lineTo(pX, pY + pS - pB - pH);
					g.lineTo(pX - pS + pB + pH, pY);
					g.lineTo(pX, pY - pS + pB + pH);
					g.endFill();
					
					g.moveTo(pX + pB, pY - pS + pB - pH);
					
					g.beginFill(_style.backgroundColor, _style.backgroundAlpha);
					g.lineTo(pX - pS + pB + pH, pY);
					g.lineTo(pX + pB, pY + pS - pB + pH);
					g.lineTo(pX + pB, pY - pS + pB - pH);
					g.endFill();
					
				} else {
					
					g.moveTo(pX - pS, pY);
					
					g.beginFill(_style.backgroundColor, _style.backgroundAlpha);
					g.lineTo(pX - pS, pY);
					g.lineTo(pX, pY + pS);
					g.lineTo(pX, pY - pS);
					g.endFill();
					
				}
				
			}
            
        }
		
		public function addButtonListener(type:String = null, listener:Function = null, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			
			for each (var btn:BButton in _buttons) {
				btn.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}
			
		}

    }
	
}
