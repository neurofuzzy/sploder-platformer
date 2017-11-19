package com.sploder.asui {
	
    import com.sploder.asui.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import flash.display.Sprite;

    public class BButton extends Component implements IComponent {

        protected var _textLabel:String = "";
        protected var _labelAlign:Number;
        protected var _alt:String = "";
        protected var _icon:Array;
		protected var _label:Object;
		protected var _labelToggled:Object;
		protected var _iconToggled:Array;
        
        protected var _button_mc:Sprite;
        protected var _btn:Sprite;
		protected var _btn_tf:TextField;
		protected var _btn_icon:Sprite;
		protected var _btn_icon_first:Boolean = true;
        protected var _btn_inactive:Sprite;
		protected var _btn_icon_inactive:Sprite;
        protected var _btn_selected:Sprite;
        protected var _tabMode:Boolean = false;
        protected var _groupMode:Boolean = false;
		protected var _selected:Boolean = false;
		protected var _droop:Boolean = false;
		
		public var tabSide:int = -1;
		public var forceWidth:Boolean = false;
		public var extraWidth:int = 0;
		
		public var linkedButton:BButton;
    
        public function get button():Sprite { return _btn; }
        public function get textLabel():String { return _textLabel; }
        
        public function get alt ():String { return _alt; }
        public function set alt (value:String):void { _alt = value; }
		
		override public function get value():String { return (super.value != null) ? super.value : _textLabel; }
		
        protected var _valueX:Number = 0;
        public function get valueX():Number { return _valueX; }
        
        protected var _valueY:Number = 0;
        public function get valueY():Number { return _valueY; }
        
        public function set valueX(value:Number):void {

            _valueX = Math.max(0, Math.min(1, value));
            _mc.x = _valueX * (parentCell.width - width);
        }
        
        public function set valueY(value:Number):void {

            _valueY = Math.max(0, Math.min(1, value));
            _mc.y = _valueY * (parentCell.height - height);
        }
        
		public var reselectable:Boolean = false;
			
        //
        //
        public function BButton (container:Sprite = null, label:Object = null, labelAlign:int = -1, width:Number = NaN, height:Number = NaN, tabMode:Boolean = false, groupMode:Boolean = false, dragMode:Boolean = false, position:Position = null, style:Style = null, droop:Boolean = false) {
            
            init_BButton (container, label, labelAlign, width, height, tabMode, groupMode, dragMode, position, style, droop);
            
            if (_container != null) create();
            
        }
        
        //
        //
        protected function init_BButton (container:Sprite = null, label:Object = null, labelAlign:int = -1, width:Number = NaN, height:Number = NaN, tabMode:Boolean = false, groupMode:Boolean = false, dragMode:Boolean = false, position:Position = null, style:Style = null, droop:Boolean = false):void {
  
            super.init(container, position, style);
			
			_type = "button";
            
            if (typeof(label) == "string") _textLabel = String(label);
            else if (label is Array) _icon = label as Array;
			else if (label is Object) {
				if (label.text) {
					_textLabel = label.text;
					if (label.icon is Array) _icon = label.icon;
					_btn_icon_first = !(label.first == "false");
					_label = label;
					if (label.iconToggled || label.textToggled) {
						_labelToggled = { icon: label.iconToggled, text: label.textToggled };
					}
				} else {
					if (label.icon is Array) _icon = label.icon;
					if (label.iconToggled is Array) _iconToggled = label.iconToggled;
				}
				
			}
            
            _labelAlign = (labelAlign != -1) ? labelAlign : Position.ALIGN_CENTER;
            
            _width = width;
            _height = height;
            _tabMode = tabMode;
            _groupMode = groupMode;
            _draggable = dragMode;
			_droop = droop;
            
        }
        
        //
        //
        override public function create ():void {

            super.create();

            if (_textLabel.length > 0 && _label == null) {
				
				_button_mc = Create.button(_mc, _textLabel, _labelAlign, _width, _height, _tabMode, _groupMode, false, _labelToggled, _style, forceWidth, extraWidth, _droop);

			} else if (_label != null) {
				
				_button_mc = Create.button(_mc, _label, _labelAlign, _width, _height, _tabMode, _groupMode, false, _labelToggled, _style, forceWidth, extraWidth, _droop);
				
			} else {
				
				if (isNaN(_width)) _width = 32;
            	if (isNaN(_height)) _height = 32;
				_button_mc = Create.hitArea(_mc, _icon, _width, _height, false, _iconToggled, _style, (_icon != null && tabSide == -1), tabSide);

			}
			
			_btn = _button_mc.getChildByName("button_btn") as Sprite;
			_btn_tf = _button_mc.getChildByName("_buttontext") as TextField;
			_btn_selected = _button_mc.getChildByName("button_selected") as Sprite;
			_btn_inactive = _button_mc.getChildByName("button_inactive") as Sprite;
			
			_btn_icon = _mc.getChildByName("icon") as Sprite;
			_btn_icon_inactive = _mc.getChildByName("icon_inactive") as Sprite;
   
            if (!isNaN(id)) _btn.tabIndex = id;
   
            if (isNaN(_width)) _width = _button_mc.width;
            if (isNaN(_height)) _height = _button_mc.height;
            
            connectButton(_btn, _draggable);
            
            addEventListener(EVENT_M_OVER, rollover);
            addEventListener(EVENT_M_OUT, rollout);
            
            if (draggable) {
                
                addEventListener(EVENT_PRESS, startDrag);
                addEventListener(EVENT_RELEASE, stopDrag);
                addEventListener(EVENT_DRAG, onDrag);
                
            }
    
        }
        
        //
        //
        public function resize (width:Number, height:Number):void {
            
            _width = width;
            _height = height;
            
            _mc.graphics.clear();
            
			_btn = null;
            _btn_inactive = null;
            _btn_selected = null;
            
            if (_button_mc != null && _button_mc.parent == _mc) {
				_mc.removeChild(_button_mc);
			}
    
            _button_mc = null;
            
            _created = false;
            
            create();
            
        }
        
        //
        //
        override public function enable (e:Event = null):void {
            
            super.enable();
            
            _btn.visible = true;
			if (_btn_tf != null) _btn_tf.visible = true;
			if (_btn_icon != null) _btn_icon.visible = true;
			if (_btn_icon_inactive != null) _btn_icon_inactive.visible = false;
            _btn_inactive.visible = false;
            _btn_selected.visible = false;
            
        }
        
        //
        //
        override public function disable (e:Event = null):void {
    
            super.disable();
            
            _btn.visible = false;
			if (_btn_tf != null) _btn_tf.visible = false;
			if (_btn_icon != null) _btn_icon.visible = false;
			if (_btn_icon_inactive != null) _btn_icon_inactive.visible = true;
            _btn_inactive.visible = true;
            _btn_selected.visible = false;
			
            Tagtip.hideTag();
            
        }
        
        //
        //
        public function select ():void {
    
            if (_enabled) {
				
				_selected = true;
				
				if (_parentCell == null ||
					(Cell.focused != _parentCell &&
					_parentCell.parentCell != Cell.focused)) Cell.focused = null;
				
                _btn.visible = false;
                _btn_inactive.visible = false;
                _btn_selected.visible = true;
				if (_btn_icon_inactive != null) _btn_icon_inactive.visible = false;
                
                dispatchEvent(new Event(EVENT_FOCUS));
                
            }
            
        }
        
        //
        //
        public function deselect ():void {
            
            if (_enabled) {
    
				_selected = false;
				
                _btn.visible = true;
                _btn_inactive.visible = false;
                _btn_selected.visible = false;  
				if (_groupMode && _btn_icon_inactive != null) _btn_icon_inactive.visible = true;
                
                dispatchEvent(new Event(EVENT_BLUR));
                Tagtip.hideTag();
                
            }
            
        }
        
        //
        //
        protected function rollover (e:Event = null, fromParent:Boolean = false):void {

            _btn.alpha = 0.3;
            if (!fromParent && _alt && _alt.length > 0) Tagtip.showTag(_alt);
			
			if (!fromParent && linkedButton) linkedButton.rollover(e, true);
    
        }
        
        //
        //
        protected function rollout (e:Event = null, fromParent:Boolean = false):void {
            
            _btn.alpha = 0;    
            
            Tagtip.hideTag();
			
			if (!fromParent && linkedButton) linkedButton.rollout(e, true);
            
        }
        
        //
        //
        protected function startDrag (e:Event = null):void {
            
            var self:Object = this;
    
			mainStage.addEventListener(Event.ENTER_FRAME, onDragMC, false, 0, true);
   
            _mc.startDrag(false, new Rectangle(0, 0, parentCell.width - width, parentCell.height - height));
            
        }
		
        //
        //
        protected function onDragMC (e:Event):void {
			
			dispatchEvent(new Event(EVENT_DRAG));
			
		}
        
        //
        //
        protected function onDrag (e:Event):void {
            
            if (parentCell.width - width <= 0) _valueX = 1;
            else _valueX = _mc.x / (parentCell.width - width);
            
            if (parentCell.height - height <= 0) _valueY = 1;
            else _valueY = _mc.y / (parentCell.height - height);
           
            dispatchEvent(new Event(EVENT_CHANGE));
            
        }
        
        //
        //
        protected function stopDrag (e:Event = null):void {

            mainStage.removeEventListener(Event.ENTER_FRAME, onDrag);
			mainStage.removeEventListener(Event.ENTER_FRAME, onDragMC);
            
            _mc.stopDrag();
            
        }
		
		//
		//
		public function addOnClick (callback:Function):void {
			
			addEventListener(EVENT_CLICK, callback, false, 0, true);
			
		}
        
    }
}
