package com.sploder.asui {
    
	import com.sploder.asui.*;
	import flash.display.SimpleButton;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
    
    /**
    * ...
    * @author $(DefaultUser)
    */
    
    
    public class Component extends EventDispatcher implements IComponent {

		public static var mainStage:Stage;
		public static var library:Library;
		
        protected var _id:int = 0;
        public function get id ():int { return _id; }
		public function set id (value:int):void { _id = value; }
        
        protected var _type:String = "comp";
        
        protected static var _nextID:int = 0;
        public static function get nextID ():int { 
            _nextID++;
            return _nextID;
        }
        
        public var name:String = "";
        
        protected var _value:String;
        public function get value ():String { return _value; }
        public function set value (val:String):void { _value = val; } 
		
		protected var _form:Object;
		public function get form():Object { return _form; }
		public function set form(value:Object):void { _form = value;  }
       
        public static const EVENT_PRESS:String = "event_press";
        public static const EVENT_RELEASE:String = "event_release";
        public static const EVENT_CLICK:String = "event_click";
        public static const EVENT_M_OVER:String = "event_m_over";
        public static const EVENT_M_OUT:String = "event_m_out";
        
        public static const EVENT_DRAG:String = "event_drag";
		public static const EVENT_MOVE:String = "event_move";
		public static const EVENT_DROP:String = "event_drop";
		public static const EVENT_HOVER_START:String = "event_hover_start";
		public static const EVENT_HOVER_END:String = "event_hover_end";
        
        public static const EVENT_FOCUS:String = "event_focus";
        public static const EVENT_BLUR:String = "event_blur";
        public static const EVENT_CHANGE:String = "event_change";
		public static const EVENT_SELECT:String = "event_select";
    
        public static const EVENT_CREATE:String = "event_create";
		public static const EVENT_REMOVE:String = "event_remove";
        public static const EVENT_DESTROY:String = "event_destroy";
        
        public static var globalStyle:Style;

        protected var _created:Boolean = false;
        public function get created():Boolean { return _created; }
		
		protected var _deleted:Boolean = false;
		public function get deleted():Boolean { return _deleted; }
		public function set deleted(value:Boolean):void 
		{
			_deleted = value;
			if (_deleted) dispatchEvent(new Event(EVENT_REMOVE));
		}	
        
        protected var _container:Sprite;
        public function get container():Sprite { return _container; }
        public function set container(value:Sprite):void { _container = value;  }

        protected var _parentCell:Cell;
        public function get parentCell():Cell { return _parentCell; }
        public function set parentCell(value:Cell):void { 

            _parentCell = value; 
            if (_parentCell != null) {
                _container = _parentCell.contents;
                create();
            }
            
        }
		
        protected var _draggable:Boolean;
        public function get draggable():Boolean { return _draggable; }
        
        protected var _position:Position;
        public function get position():Position { return _position; }
        public function set position(value:Position):void { _position = value; }    

        
        public var arranged:Boolean = false;
        
        protected var _mc:Sprite;
		public function get mc ():Sprite { return _mc; }
        
        public function get tabEnabled ():Boolean { return _mc.tabChildren; }
        public function set tabEnabled (val:Boolean):void { _mc.tabChildren = val; }
		
		public function get mouseEnabled ():Boolean { return _mc.mouseEnabled; }
		public function set mouseEnabled (val:Boolean):void { _mc.mouseEnabled = _mc.mouseChildren = val; }

        
        protected var _style:Style;
        public function get style():Style { return _style; }
        
        protected var _active:Boolean = true;
        public function get active():Boolean { return _active; }
        public function set active(value:Boolean):void { _active = value; }
        
        protected var _enabled:Boolean = true;
        public function get enabled():Boolean { return _enabled; }
        public function set enabled(value:Boolean):void { if (value) enable() else disable(); }

            
        public function get x ():Number { return (_mc != null) ? _mc.x : 0; }
        public function set x (val:Number):void { if (!isNaN(val) && _mc != null) _mc.x = val; }

        
        public function get y ():Number { return (_mc != null) ? _mc.y : 0; }
        public function set y (val:Number):void { if (!isNaN(val) && _mc != null) _mc.y = val; }

        
        public function get zindex ():Number { return _position.zindex; }
        
        public function get scale ():Number { return (_mc != null) ? _mc.scaleX : 1; }
        public function set scale (val:Number):void { if (_mc != null) _mc.scaleX = _mc.scaleY = val }

		public function get rotation ():Number { return (_mc != null) ? _mc.rotation : 0; }
        public function set rotation (val:Number):void { if (!isNaN(val) && _mc != null) _mc.rotation = val; }
        
        public function get visible ():Boolean { return _mc.visible; }
        
        protected var _width:Number = 0;
        protected var _height:Number = 0;
        
        public function get width ():uint { return Math.ceil(_width); }
        public function get height ():uint { return Math.ceil(_height); }

        //
        //
        protected function init (container:Sprite, position:Position = null, style:Style = null):void {

            _id = nextID;
            
            _container = (container != null) ? container : null;
			
			if (mainStage == null) {
				if (_container != null && _container.stage is Stage) mainStage = _container.stage;
				else throw new Error("ASUILIB ERROR: Please register stage with Component.mainStage");
			}
            
            var defaultOptions:Object = { };
            
            if (_type == "formfield" || _type == "htmlfield" || _type == "combobox" || _type == "slider" || _type == "hrule") {
            
                defaultOptions.margins = [0, 0, 15, 0];
                
            }
			
            _position = (position != null) ? position : new Position( defaultOptions );
            _style = (style != null) ? style : (globalStyle != null) ? globalStyle : new Style(); 
    
        }
        
        //
        //
        public function create ():void {
            
            if (created) return;
            
			var mc:Sprite = new Sprite();
            _mc = Sprite(_container.addChild(mc));
			_mc.name = _type + "_" + id;
			_mc.focusRect = false;
            _created = true;
            
        }
        
        //
        //
        protected function onClick (e:MouseEvent = null):void {
 
            dispatchEvent(new Event(EVENT_CLICK, true));
            
        }
		
        //
        //
        protected function onPress (e:MouseEvent = null):void {

            dispatchEvent(new Event(EVENT_PRESS, true));
			if (_draggable && Component.mainStage != null) mainStage.addEventListener(MouseEvent.MOUSE_UP, onRelease, false, 0, true);
            
        }
		
        //
        //
        protected function onRelease (e:MouseEvent = null):void {
     
            dispatchEvent(new Event(EVENT_RELEASE, true));
			if (_draggable && Component.mainStage != null) mainStage.removeEventListener(MouseEvent.MOUSE_UP, onRelease);
            
        }
        
        //
        //
        protected function onRollOver (e:MouseEvent = null):void {
			
            dispatchEvent(new Event(EVENT_M_OVER, true));
            
        }
        
        //
        //
        protected function onRollOut (e:MouseEvent = null):void {
    
            dispatchEvent(new Event(EVENT_M_OUT, true));
            
        }
        
        protected var _target:Component;
        protected var _targetEvent:String;
        protected var _targetProperty:String;
    
        //
        //
        public function connect (event:String, target:Component, property:String):void {
 
            if (_target != null && _targetEvent != null) _target.removeEventListener(_targetEvent, onTargetEvent);

            _target = target;
            _targetEvent = event;
            _targetProperty = property;
            
            if (_target != null) {
                
                _target.addEventListener(_targetEvent, onTargetEvent);
                onTargetEvent();
                
            }
            
        }
        
        //
        //
        public function onTargetEvent (e:Event = null):void {

        
            if (typeof(_target[_targetProperty]) == "function") {
            
                if (_target[_targetProperty]() != false) enable();
                else disable();     
            
            } else {
            
                if (_target[_targetProperty] != false) enable();
                else disable();
                
            }
            
        }
        
        //
        //
        protected function connectButton (btn:Sprite, dragMode:Boolean = false):void {
	
            btn.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			
            btn.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
 
            if (dragMode != true) {
				
                btn.addEventListener(MouseEvent.CLICK, onClick);

                btn.addEventListener(MouseEvent.MOUSE_OUT, onRollOut);

            } else {
				
                btn.addEventListener(MouseEvent.MOUSE_DOWN, onPress);

                btn.addEventListener(MouseEvent.MOUSE_UP, onRelease);
				
            }
			
			btn.buttonMode = true;
    
        }
		
        //
        //
        protected function connectSimpleButton (btn:SimpleButton, dragMode:Boolean = false, dragRollover:Boolean = false):void {
			
			if (dragMode != true) {
				
				btn.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
				
				btn.addEventListener(MouseEvent.ROLL_OUT, onRollOut);

				btn.addEventListener(MouseEvent.CLICK, onClick);
				
			} else {
				
				btn.addEventListener(MouseEvent.MOUSE_DOWN, onPress);

                btn.addEventListener(MouseEvent.MOUSE_UP, onRelease);	
				
				if (dragRollover) {
					
					btn.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
				
					btn.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
					
				}
				
			}
			
        }
        
        //
        //
        protected function connectTextField (tf:TextField):void {
 
			tf.addEventListener(Event.CHANGE, onTextChange);
			
            tf.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);

            tf.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);

        }	
		
		//
		//
		protected function onTextChange (e:Event):void {
			
			dispatchEvent(new Event(Component.EVENT_CHANGE));
			
		}
		
		//
		//
		protected function onFocusIn (e:FocusEvent):void {
			
			dispatchEvent(new Event(Component.EVENT_FOCUS));
			
		}
		
		//
		//
		protected function onFocusOut (e:FocusEvent):void {
			
			dispatchEvent(new Event(Component.EVENT_BLUR));
			
		}
        
        //
        //
        public function enable (e:Event = null):void {
            
            _enabled = true;
            
        }
        
        //
        //
        public function disable (e:Event = null):void {

            _enabled = false;
            
        }
        
        //
        //
        public function show (e:Event = null):void {
            
            _mc.visible = true;
            dispatchEvent(new Event(EVENT_FOCUS));
            
        }
        
        //
        //
        public function hide (e:Event = null):void {
            
            _mc.visible = false;
            dispatchEvent(new Event(EVENT_BLUR));
            
        }
        
        //
        //
        public function toggle (e:Event = null):void {

            
            if (_mc.visible) hide();
            else show();
            
        }
        
        //
        //
        public function destroy ():Boolean {
            
            if (_mc == null) return false;
            
            if (_mc.parent != null && _mc.parent.getChildIndex(mc) != -1) _mc.parent.removeChild(_mc);
            _mc = null;
			
			_deleted = true;
            
            dispatchEvent(new Event(EVENT_DESTROY));
            
            return true;
            
        }
        
    }
}
