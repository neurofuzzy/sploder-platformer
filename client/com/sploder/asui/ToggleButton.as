package com.sploder.asui {
	
    import com.sploder.asui.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import flash.display.Sprite;

    public class ToggleButton extends Component implements IComponent {

        private var _textLabel:String = "";
		private var _textLabelToggled:String = "";
        private var _labelAlign:Number;
        private var _alt:String = "";
		private var _toggledAlt:String = "";
        private var _icon:Array;
		private var _iconToggled:Array;
        
        private var _button_mc:Sprite;
        private var _btn:Sprite;
        private var _btn_inactive:Sprite;
        private var _btn_selected:Sprite;
		private var _btn_icon:Sprite;
		private var _toggled:Boolean = false;
    
        public function get button():Sprite { return _btn; }
        public function get textLabel():String { return _textLabel; }
        
        public function get alt ():String { return _alt; }
        public function set alt (value:String):void { _alt = value; }
		
		public function get toggledAlt():String { return _toggledAlt; }
		public function set toggledAlt(value:String):void { _toggledAlt = value; }
		
		override public function get value():String { return (super.value != null) ? super.value : _textLabel; }
		
        private var _valueX:Number = 0;
        public function get valueX():Number { return _valueX; }
        
        private var _valueY:Number = 0;
        public function get valueY():Number { return _valueY; }
        
        public function set valueX(value:Number):void {

            _valueX = Math.max(0, Math.min(1, value));
            _mc.x = _valueX * (parentCell.width - width);
        }
        
        public function set valueY(value:Number):void {

            _valueY = Math.max(0, Math.min(1, value));
            _mc.y = _valueY * (parentCell.height - height);
        }
		
		public function get toggled():Boolean { return _toggled; }
		


        //
        //
        public function ToggleButton (container:Sprite, label:Object, toggledLabel:Object = null, toggled:Boolean = false, labelAlign:int = -1, width:Number = NaN, height:Number = NaN, position:Position = null, style:Style = null) {
            
            init_ToggleButton (container, label, toggledLabel, toggled, labelAlign, width, height, position, style);
            
            if (_container != null) create();
            
        }
        
        //
        //
        private function init_ToggleButton (container:Sprite, label:Object, toggledLabel:Object = null, toggled:Boolean = false, labelAlign:int = -1, width:Number = NaN, height:Number = NaN, position:Position = null, style:Style = null):void {
  
            super.init(container, position, style);
			
			_type = "togglebutton";
            
            if (typeof(label) == "string") _textLabel = String(label);
            else if (label is Array) _icon = label as Array;
			
			if (typeof(toggledLabel) == "string") _textLabelToggled = String(toggledLabel);
            else if (toggledLabel is Array) _iconToggled = toggledLabel as Array;
            
            _labelAlign = (labelAlign != -1) ? labelAlign : Position.ALIGN_CENTER;
            
            _width = width;
            _height = height;
            _toggled = toggled;
            
        }
        
        //
        //
        override public function create ():void {

            super.create();
            
            if (_textLabel.length > 0) {
				
				_button_mc = Create.button(_mc, _textLabel, _labelAlign, _width, _height, false, true, true, _textLabelToggled, _style);
				
			} else {
				
				if (isNaN(_width)) _width = 32;
            	if (isNaN(_height)) _height = 32;
				_button_mc = Create.hitArea(_mc, _icon, _width, _height, true, _iconToggled, _style);
	
			}
			
			_btn = _button_mc.getChildByName("button_btn") as Sprite;
			_btn_selected = _button_mc.getChildByName("button_selected") as Sprite;
			_btn_inactive = _button_mc.getChildByName("button_inactive") as Sprite;
			_btn_icon = _mc.getChildByName("icon") as Sprite;
			
            if (!isNaN(id)) _btn.tabIndex = id;
   
            if (isNaN(_width)) _width = _button_mc.width;
            if (isNaN(_height)) _height = _button_mc.height;
            
            connectButton(_btn, _draggable);
            
            addEventListener(EVENT_M_OVER, rollover);
            addEventListener(EVENT_M_OUT, rollout);
    
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
            _btn_inactive.visible = false;
            _btn_selected.visible = false;
            
        }
        
        //
        //
        override public function disable (e:Event = null):void {
    
            super.disable();
            
			deselect();
			
            _btn.visible = false;
            _btn_inactive.visible = true;
            _btn_selected.visible = false;
			
            Tagtip.hideTag();
            
        }
        
        //
        //
        public function select ():void {
    
            if (_enabled && !_toggled) {
                
               //_btn.visible = false;
                _btn_inactive.visible = false;
                _btn_selected.visible = true;
				_btn_selected.mouseEnabled = false;
				if (_btn_icon != null) _btn_icon.visible = false;
                
				_toggled = true;
				
                dispatchEvent(new Event(EVENT_FOCUS));	
				
            }
            
        }
        
        //
        //
        public function deselect ():void {
            
            if (_enabled && _toggled) {
    
                _btn.visible = true;
                _btn_inactive.visible = false;
                _btn_selected.visible = false;  
				if (_btn_icon != null) _btn_icon.visible = true;
				
				_toggled = false;
                
                dispatchEvent(new Event(EVENT_BLUR));
                Tagtip.hideTag();
                
            }
            
        }
        
        //
        //
        protected function rollover (e:Event = null):void {

            _btn.alpha = 0.3;
            if (_alt.length > 0 || _toggledAlt.length > 0) {
				if (toggled && _toggledAlt.length > 0) {
					Tagtip.showTag(_toggledAlt);
				} else {
					Tagtip.showTag(_alt);
				}
			}
    
        }
        
        //
        //
        protected function rollout (e:Event = null):void {
            
            _btn.alpha = 0;    
            
            Tagtip.hideTag();
            
        }

		//
		//
		public function addOnClick (callback:Function):void {
			
			addEventListener(EVENT_CLICK, callback, false, 0, true);
			
		}
		
		//
		//
		override protected function onClick(e:MouseEvent = null):void 
		{
			
			if (_toggled) deselect();
			else select();
			
			super.onClick(e);
			
		}
		
		//
        //
        override public function toggle (e:Event = null):void {

            if (_toggled) deselect();
			else select();
			
			dispatchEvent(new Event(EVENT_CHANGE));
			
        }
        
    }
}
