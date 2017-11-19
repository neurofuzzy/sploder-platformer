/**
* Fuz3d: 3d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.model.material {
	
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	public class MapManager {
		
		private static var _maps:Dictionary;
		private static var _initialized:Boolean;
		
		private static var _queue:Array;
		private static var _busy:Boolean;
		
		private static var _currentFilename:String;
		
		private static var _requesters:Dictionary;
		
		//
		//
		private static function initialize ():void {
			
			_maps = new Dictionary();
			_requesters = new Dictionary();
			_queue = [];
			_busy = false;
			_initialized = true;
			
		}
		
		//
		//
		public static function addMap (filename:String, requester:TextureMap):void {
			
			if (!_initialized) initialize();
			
			_requesters[requester] = filename;
			
			if (_maps[filename] == undefined) {
	
				loadMap(filename);
				
			}
			
		}
		
		//
		//
		private static function loadMap (filename:String):void {
			
			if (!_busy) {

				var loader:Loader = _maps[filename] = new Loader();
				configureListeners(loader.contentLoaderInfo);

				var request:URLRequest = new URLRequest(filename);
				loader.load(request);
				_currentFilename = filename;
				_busy = true;
			
			} else {
				
				_queue.push(filename);
				
			}
			
		}
		
		//
		//
		private static function doQueue ():void {
			
			if (_queue.length > 0) {
				
				loadMap(_queue.shift());
				
			} else {
				
				_busy = false;
				
			}
			
		}
		
		//
		//
		private static function notifyRequesters (filename:String, success:Boolean = true):void {
			
			for (var req:Object in _requesters) {
			
				if (_requesters[req] == filename) {
					if (success) TextureMap(req).setBitmap(_maps[filename]);
					delete _requesters[req];
				}
				
			}
			
		}
		
		//
		//
		public static function getMap (filename:String):void {
			
			if (!_initialized) initialize();
		
		}
		
        private static function configureListeners(dispatcher:IEventDispatcher):void {
			
            dispatcher.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);
            dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false, 0, true);
            dispatcher.addEventListener(Event.INIT, initHandler, false, 0, true);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);

        }

        private static function completeHandler(event:Event):void {
            //trace("completeHandler: " + event);
			_maps[_currentFilename] = event.target.content.bitmapData;
			notifyRequesters(_currentFilename);
			_busy = false;
			doQueue();
        }

        private static function httpStatusHandler(event:HTTPStatusEvent):void {
            //trace("httpStatusHandler: " + event);
        }

        private static function initHandler(event:Event):void {
            //trace("initHandler: " + event);
        }

        private static function ioErrorHandler(event:IOErrorEvent):void {
            //trace("ioErrorHandler: " + event);
			notifyRequesters(_currentFilename, false);
			_busy = false;
			doQueue();
        }
		
	}
	
}
