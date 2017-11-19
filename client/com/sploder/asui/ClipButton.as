package com.sploder.asui 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.JointStyle;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class ClipButton extends BButton
	{
	
		protected var _symbolName:String = "";
		protected var _toggleSymbolName:String = "";
		protected var _toggleMode:Boolean = false;
		protected var _cancelToggleMode:Boolean = false;
		protected var _clip:DisplayObject;
		protected var _toggleClip:DisplayObject;
		protected var _clipScale:Number = -1;
		protected var _toggled:Boolean = false;
		protected var _toggledAlt:String = "";
		
		public function get toggledAlt():String { return _toggledAlt; }
		public function set toggledAlt(value:String):void { _toggledAlt = value; }
		
		protected var _minPadding:int = 10;
		
		protected var _lineMode:Boolean = false;
		
		public function ClipButton (container:Sprite = null, symbolName:String = "", toggleSymbolName:String = "", clipScale:Number = -1, width:Number = NaN, height:Number = NaN, minPadding:int = 10, tabMode:Boolean = false, groupMode:Boolean = false, dragMode:Boolean = false, lineMode:Boolean = false, position:Position = null, style:Style = null, droop:Boolean = false) 
		{
			
			init_ClipButton(container, symbolName, toggleSymbolName, clipScale, width, height, minPadding, tabMode, groupMode, dragMode, lineMode, position, style, droop);
			
			if (_container != null) create();
		}
		
		protected function init_ClipButton (container:Sprite = null, symbolName:String = "", toggleSymbolName:String = "", clipScale:Number = -1, width:Number = NaN, height:Number = NaN, minPadding:int = 10, tabMode:Boolean = false, groupMode:Boolean = false, dragMode:Boolean = false, lineMode:Boolean = false, position:Position = null, style:Style = null, droop:Boolean = false):void {
			
			super.init_BButton(container, "", -1, width, height, tabMode, groupMode, dragMode, position, style, droop);
			
			_type = "clipbutton";
			
			_symbolName = _value = symbolName;
			_toggleSymbolName = toggleSymbolName;
			_clipScale = clipScale;
			_minPadding = minPadding;
			_lineMode = lineMode;

			if (_toggleSymbolName && _toggleSymbolName.length) _toggleMode = true;
			if (_symbolName) getSymbol();
			
		}
		
		//
		//
		protected function getSymbol ():void {
			
			if (_clip && _clip.parent) _clip.parent.removeChild(_clip);
			if (_toggleClip && _toggleClip.parent) _toggleClip.parent.removeChild(_toggleClip);
			
			if (library == null) {
				
				throw new Error("Register a library with Component in order to embed clips!");
				
			} else {
				
				if (!isNaN(parseInt(_symbolName))) {
				
					var g:Graphics;
					var c:uint = parseInt(_symbolName);
					
					// create color chip
					_clip = new Sprite();
					g = Sprite(_clip).graphics;
					
					if (!_lineMode) {
						g.beginFill(c, 1);
						g.lineStyle(1, 0, 1, true);
						g.drawRect(0 - _width / 2 + 1, 0 - _height / 2 + 1, _width - 2, _height - 2);
						g.endFill();
					} else {
						g.beginFill(0, 0);
						g.lineStyle(4, c, 1, true, "normal", null, JointStyle.MITER);
						g.drawRect(0 - _width / 2 + 2, 0 - _height / 2 + 2, _width - 4, _height - 4);
						g.endFill();
					}
					
					if (!_cancelToggleMode) _toggleMode = true;
					
					if (_toggleMode) {
						_toggleClip = new Sprite();
						g = Sprite(_toggleClip).graphics;
						
						if (!_lineMode) {
							g.beginFill(c, 1);
							g.lineStyle(1, 0xffffff, 1, true);
							g.drawRect(0 - _width / 2 + 1, 0 - _height / 2 + 1, _width - 2, _height - 2);
							g.endFill();
						} else {
							g.beginFill(0, 0);
							g.lineStyle(4, c, 1, true, "normal", null, JointStyle.MITER);
							g.drawRect(0 - _width / 2 + 2, 0 - _height / 2 + 2, _width - 4, _height - 4);
							g.endFill();
						}
					}
				
				} else {
					
					_toggleMode = (_toggleSymbolName && _toggleSymbolName.length);
					_clip = library.getDisplayObject(_symbolName);
					
					if (_toggleMode && _toggleSymbolName) {
						_toggleClip = library.getDisplayObject(_toggleSymbolName);
					}
				
				}
				
				if (_clipScale > 0) {
					
					_clip.scaleX = _clip.scaleY = _clipScale;
					if (_toggleClip) _toggleClip.scaleX = _toggleClip.scaleY = _clipScale;
				
				} else {
					
					var padding:Number = Math.max(_minPadding, _style.borderWidth * 2 + (_style.round - _style.borderWidth) * 2);
					padding = Math.max(_style.padding * 2, padding);
					
					if (isNaN(_width) || _width == 0) _width = _clip.width + padding;
					if (isNaN(_height) || _height == 0) _height = _clip.height + padding;
					
					var symbolAspect:Number = _clip.width / _clip.height;
					var buttonAspect:Number = _width / _height;
				
					if (symbolAspect < buttonAspect) {
						_clip.height = _height - padding;
						_clip.width = _clip.height * symbolAspect;
					} else {
						_clip.width = _width - padding;
						_clip.height = _clip.width / symbolAspect;
					}
					
					if (_toggleClip) {
						_toggleClip.width = _clip.width;
						_toggleClip.height = _clip.height;
					}
				
				}
				
				if (_clip is DisplayObjectContainer) DisplayObjectContainer(_clip).mouseEnabled = false;
				if (_toggleClip is DisplayObjectContainer) DisplayObjectContainer(_toggleClip).mouseEnabled = false;
				
			}
			
		}
		
		public function setSymbol (symbolName:String):void {
			
			if (_clip) {
				if (_clip.parent != null) _clip.parent.removeChild(_clip);
				_clip = null;
			}
			
			_symbolName = _value = symbolName;
			
			getSymbol();
			addClip();
			
		}
		
		protected function addClip ():void {
			
			if (_clip == null) return;
			
			_clip.x = _width / 2;
			_clip.y = _height / 2;
			_clip.alpha = (_enabled) ? 1 : 0.5;
			_button_mc.addChild(_clip);
			_button_mc.setChildIndex(_btn, _button_mc.getChildIndex(_clip));
			
			if (_toggleMode && _toggleClip) {
				_toggleClip.x = _clip.x;
				_toggleClip.y = _clip.y;
				_toggleClip.alpha = (_enabled) ? 1 : 0.5;
				_button_mc.addChild(_toggleClip);
				_button_mc.setChildIndex(_btn, _button_mc.getChildIndex(_toggleClip));
				_toggleClip.visible = false;
			}
			
		}
		
		//
		override public function create():void 
		{
			super.create();
			
			addClip();
			
		}
		
		override public function disable(e:Event = null):void 
		{
			super.disable(e);
			_clip.alpha = 0.5;
			if (_toggleClip) _toggleClip.alpha = 0.5;
		}
		
		override public function enable(e:Event = null):void 
		{
			super.enable(e);
			_clip.alpha = 1;
			if (_toggleClip) _toggleClip.alpha = 1;
		}
		
		public function get symbolName():String { return _symbolName; }
		public function get toggleSymbolName():String { return _toggleSymbolName; }
		
		public function get toggled():Boolean { return _toggled; }
		
		public function set toggled(value:Boolean):void 
		{
			if (_toggled == value) {
				if (value) select();
				else deselect();
				return;
			}
			else toggle();
		}
		
		public function get toggleMode():Boolean { return _toggleMode; }
		
		public function set toggleMode(value:Boolean):void 
		{
			if (!value) {
				_toggleMode = value;
				_cancelToggleMode = !value;
			}
			
		}
		
		override public function toggle(e:Event = null):void 
		{
			if (_toggled) deselect();
			else select();
			dispatchEvent(new Event(EVENT_CHANGE));
		}
		
		override protected function onClick(e:MouseEvent = null):void 
		{
			if (_toggleMode) {
				if (_toggled) deselect();
				else select();
				dispatchEvent(new Event(EVENT_CLICK));
			} else {
				super.onClick(e);
			}
		}
		
        //
        //
        override public function select ():void {
    
            if (_enabled && _toggleMode) {
				
				if (_toggleClip) {
					_clip.visible = false;
					_toggleClip.visible = true;
					_value = _toggleSymbolName;
				}
				_toggled = true;

            }
			
			super.select();
			if (_toggleMode || reselectable) _btn.visible = true;
            
        }
        
        //
        //
        override public function deselect ():void {
            
            if (_enabled && _toggleMode) {
				
				if (_toggleClip) {
					_clip.visible = true;
					_toggleClip.visible = false;
					_value = _symbolName;
				}
				_toggled = false;
				
            }
			
			super.deselect();
			if (_toggleMode) _btn.visible = true;
            
        }
		
		override protected function onRollOver(e:MouseEvent = null):void 
		{
			if (_alt == null || _toggledAlt == null) return;
			if (_alt.length > 0 || _toggledAlt.length > 0) {
				if (toggled && _toggledAlt.length > 0) {
					Tagtip.showTag(_toggledAlt);
				} else {
					Tagtip.showTag(_alt);
				}
			}
		}
		
		
	}

}