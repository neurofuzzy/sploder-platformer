package com.sploder.asui
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	/**
	 * The LibraryObject class is used to instantiate new symbols from an embedded library.
	 * It provides the ability to find SimpleButtons and MovieClips within the symbol in order to 
	 * connect them to Event listeners.
	 * @author Geoff
	 */
	public class LibraryObject {
		
		protected var _library:Library;
		protected var _container:Sprite;
		
		protected var _mc:Sprite;
		public function get mc():Sprite { return _mc; }
		
		public function LibraryObject (container:Sprite, library:Library, symbolName:String) {
			
			init(container, library, symbolName);
			
		}
		
		//
		//
		protected function init (container:Sprite, library:Library, symbolName:String):void {
			
			_container = container;
			_library = library;
			
			_mc = library.getDisplayObject(symbolName) as Sprite;
			assign();
			
			if (_mc != null && _container != null) _container.addChild(_mc);
			else if (_mc != null) _mc.addEventListener(Event.ADDED_TO_STAGE, onAdded);

		}
		
		//
		//
		protected function onAdded (e:Event):void {
			
			_mc.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			_container = _mc.parent as Sprite;
			
		}
		
		//
		//
		protected function assign (rootmc:Sprite = null):void {
			
			if (rootmc == null) rootmc = _mc;
			
			var child:DisplayObject;
			
			for (var i:int = 0; i < rootmc.numChildren; i++) {
				
				child = rootmc.getChildAt(i);
				
				try {
					if (child.name.length > 0 && child.name.indexOf("instance") != 0 && this[child.name] == null) {
						this[child.name] = child;
					}
				} catch (e:Error) {
					trace("Warning: LibraryObject does not contain property '" + child.name + "'");
					if (!(e is ReferenceError)) trace(e.getStackTrace());
				}
				
			}
			
		}

		//
		//
		public function connect (listener:Function, clip:Sprite = null):void {
			
			var child:DisplayObject;
			
			if (clip == null) clip = _mc;
			
			for (var i:int = 0; i < clip.numChildren; i++) {
				
				child = clip.getChildAt(i);
				
				if (child is Sprite) {
				
					connect(listener, child as Sprite);
					
				} else if (child is SimpleButton) {
					
					SimpleButton(child).addEventListener(MouseEvent.CLICK, listener);
					
				}
				
			}
	
		}
		
		//
		//
		public function connectInstance (listener:Function, clip:Sprite = null, instanceName:String = "", eventType:String = null):DisplayObject {
			
			var child:DisplayObject;
			
			if (clip == null) clip = _mc;
			
			for (var i:int = 0; i < clip.numChildren; i++) {
				
				child = clip.getChildAt(i);

				if (child.name == instanceName) {
					
					if (eventType != null) {
						DisplayObject(child).addEventListener(eventType, listener);
					} else {
						DisplayObject(child).addEventListener(MouseEvent.CLICK, listener);
					}
					
					if (child is Sprite) Sprite(child).mouseEnabled = Sprite(child).buttonMode = true;
					
					return child;
					
				} else if (child is Sprite) {

					connectInstance(listener, child as Sprite, instanceName, eventType);
					
				}
				
			}
			
			return null;
	
		}
		
		//
		//
		protected function getInstance (clip:Sprite = null, instanceName:String = ""):DisplayObject {
			
			var child:DisplayObject;
			
			if (clip == null) clip = _mc;

			for (var i:int = 0; i < clip.numChildren; i++) {
				
				child = clip.getChildAt(i);
				
				if (child.name == instanceName) return child;
				
				if (child is Sprite) {
					var res:DisplayObject = getInstance(child as Sprite, instanceName);
					if (res != null) return res;
				}

			}
			
			return null;
	
		}
		
		//
		//
		protected function getInstances (obj:Object = null, clip:Sprite = null, searchTerm:String = ""):Object {
			
			var child:DisplayObject;
			
			if (clip == null) clip = _mc;
			if (obj == null) obj = { };
			
			for (var i:int = 0; i < clip.numChildren; i++) {
				
				child = clip.getChildAt(i);
				
				if (searchTerm.length > 0) {
					if (child.name.indexOf(searchTerm) != -1) {
						obj[child.name] = child;
					}
				} else {
					obj[child.name] = child;
				}

				if (child is Sprite) getInstances(obj, child as Sprite, searchTerm);

			}
			
			return obj;
	
		}
		
		//
		//
		protected function getTopLevelInstances (searchTerm:String = ""):Object {
			
			var child:DisplayObject;
			
			var obj:Object = { };
			
			for (var i:int = 0; i < _mc.numChildren; i++) {
				
				child = _mc.getChildAt(i);
				
				if (searchTerm.length > 0) {
					if (child.name.indexOf(searchTerm) != -1) obj[child.name] = child;
				} else {
					obj[child.name] = child;
				}
				
			}
			
			return obj;
	
		}
		
		//
		//
		protected function getButtons (obj:Object = null, clip:Sprite = null, searchTerm:String = ""):Object {
			
			var child:DisplayObject;
			
			if (clip == null) clip = _mc;
			if (obj == null) obj = { };
			
			for (var i:int = 0; i < clip.numChildren; i++) {
				
				child = clip.getChildAt(i);
				
				if (child is Sprite) getButtons(obj, child as Sprite, searchTerm);
				else if (child is SimpleButton) {
					if (searchTerm.length > 0) {
						if (child.name.indexOf(searchTerm) != -1) obj[child.name] = child
					} else {
						obj[child.name] = child;
					}
				}

			}
			
			return obj;
	
		}
	
	}
	
}