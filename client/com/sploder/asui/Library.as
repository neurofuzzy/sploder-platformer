package com.sploder.asui {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.utils.Timer;

	
	
	/**
	 * The Library class provides access to the symbols in embedded SWFs.
	 */
	public class Library extends EventDispatcher {

		public static var scale:Number = 1;
		
		protected var _smoothing:Boolean = false;
		public function get smoothing():Boolean { return _smoothing; }
		public function set smoothing(value:Boolean):void { _smoothing = value; }
		
		public static const INITIALIZED:String = "embeddedlibrary_initialized";
		
		protected var embeddedLibrary:Class;

		protected var loader:Loader;
		
		protected function get initialized ():Boolean { return (loader.content != null); }
	
		protected var debugmode:Boolean;
		
		protected var bitmapDataCache:Object;
		
		protected var _timer:Timer;
		protected var _eventSent:Boolean = false;

		/**
		 * The constructor for the Library
		 * @param	embeddedSWF the Class assigned to the SWF using the Embed directive.
		 * @param	debug
		 */
		public function Library (embeddedSWF:Class, debug:Boolean = false) {
			
			embeddedLibrary = embeddedSWF;
			debugmode = debug;
			
			init();
			
		}
		
		/**
		 * must be initialized at least one frame before any resources are available;
		 * be sure to call init() well in advance of any attempt to access library resources.
		 */
		protected function init ():void {
			
			loader = new Loader();
			
			loader.contentLoaderInfo.addEventListener(Event.INIT, onInitialize, false, 0, true);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete, false, 0, true);
			loader.loadBytes(new embeddedLibrary());

			bitmapDataCache = { };

			_timer = new Timer(250, 0);
			_timer.addEventListener(TimerEvent.TIMER, checkEvent);
			_timer.start();

		}
		
		
		//
		//
		protected function onInitialize (evt:Event):void {
			
			loader.contentLoaderInfo.removeEventListener(Event.INIT, onInitialize);
			dispatchEvent(new Event(Event.INIT));
			_eventSent = true;
			
		} 
		
		//
		//
		protected function onComplete (evt:Event):void {
			
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);

		} 
		
		//
		//
		protected function checkEvent (e:TimerEvent):void {
			
			if (initialized) {
				if (!_eventSent) dispatchEvent(new Event(Event.INIT));
				_timer.stop();
			}
			
		}
		
		/**
		 * Retrieves a symbol from the embedded SWF library
		 * @param	symbolName The symbol identifier provided in the linkage properties in the library.
		 * @return
		 */
		public function getDisplayObject (symbolName:String):DisplayObject {
			
			var obj:Object;
			
			if (!initialized) throw new Error ("ERROR: Component Library not initialized.");
			
			try {

				obj = getSymbolInstance(symbolName);
				
				if (obj is DisplayObject) return obj as DisplayObject;
				else throw new Error();

			} catch (e:Error) {

				trace("Library Symbol '" + symbolName + "' is not a Display Object");
				
			}
			
			return null;
			
		}
		
		/**
		 * Retrieves a symbol from the embedded SWF library
		 * @param	symbolName The symbol identifier provided in the linkage properties in the library.
		 * @return
		 */
		public function getBitmapData (symbolName:String):BitmapData {
			
			var obj:Object;
			
			if (!initialized) throw new Error ("ERROR: Component Library not initialized.");
			
			try {

				obj = getSymbolInstance(symbolName);
				
				if (obj is BitmapData) return obj as BitmapData;
				else throw new Error();

			} catch (e:Error) {

				trace("Library Symbol '" + symbolName + "' is not BitmapData");
				
			}
			
			return null;
			
		}
		
		/**
		 * Retrieves a symbol from the embedded SWF library as a bitmap
		 * @param	symbolName The symbol identifier provided in the linkage properties in the library.
		 * @param	filters An array of filters to apply to the bitmap
		 * @return
		 */
		public function getDisplayObjectAsBitmap (symbolName:String, filters:Array = null):Bitmap {
			
			if (!initialized) throw new Error ("ERROR: Component Library not initialized.");
			
			if (bitmapDataCache[symbolName] != null && bitmapDataCache[symbolName] is BitmapData) return new Bitmap(bitmapDataCache[symbolName], PixelSnapping.NEVER, smoothing);
			
			var clip:DisplayObject = getDisplayObject(symbolName);
			
			if (clip != null) {
				
				//clip.scaleX = clip.scaleY = scale;
				
				var bd:BitmapData = new BitmapData(Math.floor(clip.width * scale), Math.floor(clip.height * scale), true, 0x00000000);
				
				var m:Matrix = new Matrix();	
				m.createBox(scale, scale, 0, Math.floor(clip.width * 0.5 * scale), Math.floor(clip.height * 0.5 * scale));
				
				bd.draw(clip, m);
				
				if (filters != null) {
					
					for (var i:int = 0; i < filters.length; i++) {
						
						bd.applyFilter(bd, new Rectangle(0, 0, bd.width, bd.height), new Point(0, 0), filters[i]);
						
					}
					
				}
				
				bitmapDataCache[symbolName] = bd;
				
				return new Bitmap(bd);
				
			}
			
			return null;
			
		}
		
		/**
		 * Retrieves a sound symbol from the embedded SWF library as a bitmap
		 * @param	symbolName The symbol identifier provided in the linkage properties in the library.
		 * @return
		 */
		public function getSound (symbolName:String):Sound {
			
			if (!initialized) throw new Error ("ERROR: Component Library not initialized.");
			
			var obj:Object;
			
			try {
				
				obj = getSymbolInstance(symbolName);
				
				if (obj is Sound) return obj as Sound;
				else throw new Error();
				
			} catch (e:Error) {
				
				trace("Library Symbol '" + symbolName + "' is not a Sound");
				
			}
			
			return null;
			
		}
		
		/**
		 * Retrieves a Font from the embedded SWF library as a bitmap
		 * @param	fontClassName The symbol identifier provided in the linkage properties in the library.
		 * @return A Class object which can be added to the global font list.
		 */
		public function getFont (fontClassName:String):Class {
			
			var obj:Object;
			
			try {

				return getSymbolDefinition(fontClassName);

			} catch (e:Error) {

				trace("Font '" + fontClassName + "' not found in Library");
				
			}
			
			return null;
			
		}
		
		//
		//
		private function getSymbolInstance (symbolClassName:String):Object {

			var symbolClass:Class = getSymbolDefinition(symbolClassName);
			return (symbolClass ? new symbolClass() : null);
			
		}
		
		
		//
		//
		private function getSymbolDefinition (className:String):Class {
			
			if (initialized) {
				
				if (loader.contentLoaderInfo.applicationDomain.hasDefinition(className)) {
					
					return (loader.contentLoaderInfo.applicationDomain.getDefinition(className) as Class);
					
				} else {
					
					trace("Symbol '" + className + "' not found.");
					
				}
				
			}

			return null;

		}
		
	}
	
}