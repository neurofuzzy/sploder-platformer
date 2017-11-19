package com.sploder.builder {
	
	import com.sploder.builder.*;
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.display.SimpleButton;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author ...
	 */
	public class CreatorSelection extends EventDispatcher {
		
		public static const SELECTED:String = "selected";
		
		public static var mainStage:Stage;
		
		protected var _active:Boolean = false;
		
		public function get active():Boolean { return _active; }
		
		public function set active(value:Boolean):void 
		{
			_active = value;
			
			if (_active) {
				
				_btn.addEventListener(MouseEvent.MOUSE_DOWN, startSelect, false, 0, true);
				_btn.addEventListener(MouseEvent.MOUSE_UP, endSelect, false, 0, true);

			} else {
				
				_btn.removeEventListener(MouseEvent.MOUSE_DOWN, startSelect);
				_btn.removeEventListener(MouseEvent.MOUSE_UP, endSelect);
				endSelect();
				
			}
			
		}
		
		public function get length ():Number
		{
			if (objects != null) return objects.length;
			return 0;
		}
		
		protected var _container:Sprite;
		protected var _all:Sprite;
		protected var _btn:SimpleButton;
		
		protected var _window:Sprite;
		
		protected var _rect:Rectangle;
		protected var _testPoint:Point;
		
		protected var _selecting:Boolean = false;
		
		protected var _objects:Array;
		public function get objects():Array { return _objects; }
		
		protected var _clonedObjects:Array;
		
		protected var _multiSelect:Boolean = false;
		
		protected var _copying:Boolean = false;
		public function get copying():Boolean { return _copying; }
		
		public function set objectsContainer (value:Sprite):void 
		{
			_all = value;
		}
		
		public var proxy:Sprite;
		
		protected var _dragPoint:Point;
		
		public var updateTime:int = 0;
		
		public var focusObject:CreatorPlayfieldObject;

		
		//
		//
		public function CreatorSelection (container:Sprite, objectsContainer:Sprite, selectButton:SimpleButton) {
		
			init(container, objectsContainer, selectButton);
			
		}
		
		//
		//
		public function init (container:Sprite, objectsContainer:Sprite, selectButton:SimpleButton):void {
			
			_container = container;
			_all = objectsContainer;
			_btn = selectButton;
			
			if (_all.parent != _container) throw new Error("CreatorSelection ERROR: Selection container must be parent of objects container.");
			
			if (_container.stage != null) mainStage = _container.stage;
			
			if (mainStage == null) throw new Error("CreatorSelection ERROR: Please add a reference to the stage to static var mainStage.");
			
			_window = new Sprite();
			_window.mouseEnabled = _window.mouseChildren = false;
			_container.addChild(_window);
			
			_rect = new Rectangle();
			_testPoint = new Point();
			_dragPoint = new Point();
			_objects = [];
			
			active = true;
			
			mainStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			mainStage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
				
		}
		
		//
		//
		protected function startSelect (e:MouseEvent):void {
			
			if (!_selecting) {
				
				selectNone();
				
				_window.x = _all.x;
				_window.y = _all.y;
				_window.scaleX = _all.scaleX;
				_window.scaleY = _all.scaleY;
				
				_rect.x = _all.mouseX;
				_rect.y = _all.mouseY;
				
				mainStage.addEventListener(Event.ENTER_FRAME, doSelect);
				mainStage.addEventListener(MouseEvent.MOUSE_UP, endSelect);
				
				_window.graphics.clear();
				
				_selecting = true;
			
			}
			
		}
		
		//
		//
		protected function doSelect (e:Event):void {
			
			if (_selecting) {
				
				_rect.width = _all.mouseX - _rect.x;
				_rect.height = _all.mouseY - _rect.y;
				
				var g:Graphics = _window.graphics;
				
				g.clear();
				
				g.lineStyle(1, 0x00ffff, 1, true, LineScaleMode.NONE);
				g.beginFill(0x00ffff, 0.3);
				g.drawRect(_rect.x, _rect.y, _rect.width, _rect.height);
				
				//selectContainedObjects();
		
			}
			
		}
		
		//
		//
		protected function endSelect (e:MouseEvent = null):void {
			
			if (_selecting) {
				
				_btn.removeEventListener(MouseEvent.MOUSE_UP, endSelect);
				mainStage.removeEventListener(MouseEvent.MOUSE_UP, endSelect);
				mainStage.removeEventListener(Event.ENTER_FRAME, doSelect);
				
				_window.graphics.clear();
				
				selectContainedObjects();
				
				_rect.x = _rect.y = _rect.width = _rect.height = 0;
				
				_selecting = false;
				
				dispatchEvent(new Event(SELECTED));
				
			}
			
		}
		
		//
		//
		protected function selectContainedObjects ():void {
			
			if (_selecting) {
				
				selectNone();
				
				if (Math.abs(_rect.width) < 10 || Math.abs(_rect.height) < 10) return;
				
				var child:DisplayObject;
				
				var o:Sprite = _all;
				if (proxy) o = proxy;
				
				for (var i:int = 0; i < o.numChildren; i++) {
					
					child = o.getChildAt(i);

					_testPoint.x = child.x;
					_testPoint.y = child.y;
					
					if (	
							( 
							(child.x > _rect.x && child.x < _rect.x + _rect.width) && 
							(child.y > _rect.y && child.y < _rect.y + _rect.height)
							) ||
							( 
							(child.x < _rect.x && child.x > _rect.x + _rect.width) && 
							(child.y < _rect.y && child.y > _rect.y + _rect.height)
							) ||
							( 
							(child.x < _rect.x && child.x > _rect.x + _rect.width) && 
							(child.y > _rect.y && child.y < _rect.y + _rect.height)
							) ||
							( 
							(child.x > _rect.x && child.x < _rect.x + _rect.width) && 
							(child.y < _rect.y && child.y > _rect.y + _rect.height)
							)
						)
						{
						
						if (child is Sprite && Sprite(child).mouseEnabled) {
							_objects.push(child);
							dispatchEvent(new SelectionEvent(SelectionEvent.SELECT, false, false, child));
						}
							
					}
					
				}

			}
			
		}	
		
		public function selectAll (e:Event = null):void {
			
			selectNone();
			
			var child:DisplayObject;
			
			var o:Sprite = _all;
			if (proxy) o = proxy;
			
			for (var i:int = 0; i < o.numChildren; i++) {
				
				child = o.getChildAt(i);

				_objects.push(child);
				dispatchEvent(new SelectionEvent(SelectionEvent.SELECT, false, false, child));

			}
			
			dispatchEvent(new Event(SELECTED));
							
			
		}
		
		//
		//
		public function selectNone (e:Event = null):void {
			
			var i:int = _objects.length;
			var obj:Object;
			
			while (i--) {
				
				obj = _objects[i];
				dispatchEvent(new SelectionEvent(SelectionEvent.DESELECT, false, false, obj));
				_objects.pop()
				
			}

			dispatchEvent(new Event(SELECTED));
			
		}
		
		//
		//
		public function select (obj:Object, forceMultiSelect:Boolean = false, asValid:Boolean = true):void {
				
			if (_multiSelect || forceMultiSelect) {
				
				if (_objects.indexOf(obj) == -1) {
					
					_objects.push(obj);
					dispatchEvent(new SelectionEvent(SelectionEvent.SELECT, false, false, obj, asValid));
					
				}
				
			} else {

				selectNone();
				_objects.push(obj);
				dispatchEvent(new SelectionEvent(SelectionEvent.SELECT, false, false, obj, asValid));
				
			}
			
			dispatchEvent(new Event(SELECTED));
			
		}
		
		//
		//
		public function deselect (obj:Object):void {
			
			if (_objects.indexOf(obj) != -1) {
				
				_objects.splice(_objects.indexOf(obj), 1);
				dispatchEvent(new SelectionEvent(SelectionEvent.DESELECT, false, false, obj));
				
				dispatchEvent(new Event(SELECTED));
				
			}
			
		}
		
		//
		//
		public function startDrag (e:Event = null):void {
			
			var i:int;
			
			if (_multiSelect) {
				_clonedObjects = _objects.concat();
				for (i = _objects.length - 1; i >= 0; i--) {
					dispatchEvent(new SelectionEvent(SelectionEvent.CLONE, false, false, _objects[i]));
				}
				_copying = true;
			}
			
			if (_objects.length > 0 && _objects[0] is CreatorPlayfieldObject) {
				_dragPoint.x = CreatorPlayfieldObject(_objects[0]).x;
				_dragPoint.y = CreatorPlayfieldObject(_objects[0]).y;
			} else {
				_dragPoint.x = _dragPoint.y = -100000;
			}
			
			for (i = _objects.length - 1; i >= 0; i--) {
				
				dispatchEvent(new SelectionEvent(SelectionEvent.STARTDRAG, false, false, _objects[i]));
				mainStage.addEventListener(Event.ENTER_FRAME, drag);
				mainStage.addEventListener(MouseEvent.MOUSE_UP, stopDrag);
				
			}
			
		}
		
		//
		//
		protected function drag (e:Event = null):void {
			
			for (var i:int = _objects.length - 1; i >= 0; i--) {
				
				dispatchEvent(new SelectionEvent(SelectionEvent.DRAG, false, false, _objects[i]));
				
			}		
			
		}
		
		//
		//
		public function stopDrag (e:Event = null):void {
			
			updateTime = getTimer();
			
			var i:int;
			
			i = _objects.length;
			
			while (i--) {
				
				dispatchEvent(new SelectionEvent(SelectionEvent.STOPDRAG, false, false, _objects[i]));
				
			}
			
			i = _objects.length;
			
			while (i--) {
				
				dispatchEvent(new SelectionEvent(SelectionEvent.DROP, false, false, _objects[i]));
				
			}
			
			
			mainStage.removeEventListener(Event.ENTER_FRAME, drag);
			mainStage.removeEventListener(MouseEvent.MOUSE_UP, stopDrag);
			
			if (_copying) {
				
				if (_objects.length > 0 && _objects[0] is CreatorPlayfieldObject) {
					
					if (_dragPoint.x == CreatorPlayfieldObject(_objects[0]).x &&
						_dragPoint.y == CreatorPlayfieldObject(_objects[0]).y) {
						
						var copiedObjects:Array = _objects.concat();
						
						_objects = [];
							
						for (i = copiedObjects.length - 1; i >= 0; i--) {
							
							dispatchEvent(new SelectionEvent(SelectionEvent.DELETE, false, false, copiedObjects[i]));
							
						}
						
						for (i = 0; i < _clonedObjects.length; i++) {
							select(_clonedObjects[i] as CreatorPlayfieldObject, true);
						}		
						
					}

				}
				
				_clonedObjects = null;
				
			}
			
			_copying = false;
			
			dispatchEvent(new Event(SELECTED));
			
		}
		
		//
		//
		public function clear (e:Event = null):void {
			
			var child:DisplayObject;
			
			var o:Sprite = _all;
			if (proxy) o = proxy;
			
			for (var i:int = 0; i < o.numChildren; i++) {
				
				child = o.getChildAt(i);

				_objects.push(child);
				dispatchEvent(new SelectionEvent(SelectionEvent.DESELECT, false, false, child));

			}
			
			dispatchEvent(new Event(SELECTED));
			
		}
		
		//
		//
		protected function onKeyDown (e:KeyboardEvent):void {

			if (e.charCode == 0 && e.shiftKey) {
				_multiSelect = true;
			}
			
		}
		
		//
		//
		protected function onKeyUp (e:KeyboardEvent):void {

			if (!e.shiftKey) {
				_multiSelect = false;
			}
			
		}
		
	}
	
}