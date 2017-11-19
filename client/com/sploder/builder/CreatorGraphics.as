package com.sploder.builder
{
	import com.sploder.util.Textures;
	import com.sploder.util.ObjectEvent;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Geoff
	 */
	public class CreatorGraphics 
	{
		protected var _base:String = "";
		
		protected var _graphics:Dictionary;
		protected var _requestedGraphics:Array;
		protected var _waitingObjects:Dictionary;
		protected var _loaders:Dictionary;
		
		public function CreatorGraphics () 
		{
			init();
		}
		
		protected function init ():void {
			
			_graphics = new Dictionary();
			_requestedGraphics = [];
			_waitingObjects = new Dictionary(true);
			_loaders = new Dictionary();
			
			Textures.dispatcher.addEventListener(Textures.TEXTURE_REQUEST, onTextureRequest);
			
			if (CreatorMain.preloader.loaderInfo.url.indexOf("sploder") == -1 || CreatorMain.preloader.loaderInfo.url.indexOf("file") != -1) {
				_base = "http://sploder_dev.s3.amazonaws.com/gfx/png/";
			} else {
				_base = "http://sploder.s3.amazonaws.com/gfx/png/";
			}
			
		}
		
		public function clean ():void
		{
			Textures.cleanCache();
			Textures.dispatcher.removeEventListener(Textures.TEXTURE_REQUEST, onTextureRequest);
			init();
		}
		
		private function onTextureRequest (e:ObjectEvent):void {
			
			if (e.relatedObject is CreatorPlayfieldObject)
			{
				assignGraphicToObject(
					CreatorPlayfieldObject(e.relatedObject).graphic, 
					CreatorPlayfieldObject(e.relatedObject).graphic_version, 
					e.relatedObject
					);
			}
			
		}
		
		protected function getGraphicKey (id:uint, version:uint):String {
			
			return id + "_" + version;
			
		}
		
		protected function loadGraphic (id:uint, version:uint):void {
			trace("LOADING GRAPHIC", id, "FROM SERVER");
			var loader:Loader = new Loader();
			_loaders[loader.contentLoaderInfo] = getGraphicKey(id, version);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onGraphicLoaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onGraphicError);
			loader.load(new URLRequest(_base + getGraphicKey(id, version) + ".png"));
			
		}
		
		protected function onGraphicLoaded (e:Event):void {
			
			var key:String = _loaders[e.target];
			var bitmapData:BitmapData = Bitmap(LoaderInfo(e.target).content).bitmapData;

			if (key && bitmapData) {
				var animate:Boolean = bitmapData.width > bitmapData.height;
				_graphics[key] = bitmapData;
				Textures.addBitmapDataToCache(key, bitmapData);
				handleWaitingObjects(animate);
			}
			
			_loaders[e.target] = null;
			delete _loaders[e.target];
			clearRequest(key);
			
		}
		
		protected function onGraphicError (e:Event):void {
			
			var key:String = _loaders[e.target];
			
			_loaders[e.target] = null;
			delete _loaders[e.target];
			clearRequest(key);
			
		}
		
		protected function clearRequest (key:String):void {
			
			if (_requestedGraphics.indexOf(key) != -1) {
				_requestedGraphics.splice(_requestedGraphics.indexOf(key), 1);
			}
			
		}
		
		protected function handleWaitingObjects (animate:Boolean = false):void {
			
			for (var obj:Object in _waitingObjects) {
				
				if (_waitingObjects[obj] is String && isLoaded(_waitingObjects[obj])) {
					
					if (obj is CreatorPlayfieldObject) {
						CreatorPlayfieldObject(obj).updateClip();
						if (animate && CreatorPlayfieldObject(obj).graphic_animation == 0) {
							CreatorPlayfieldObject(obj).graphic_animation = 1;
						}
					}
					
					_waitingObjects[obj] = null;
					delete _waitingObjects[obj];
					
				}
				
			}
			
		}
		
		protected function isLoaded (key:String):Boolean {
			
			return (_graphics[key] is BitmapData);
			
		}
		
		public function assignGraphicToObject (graphicID:uint, graphicVersion:uint, obj:Object):void {
			
			var key:String = getGraphicKey(graphicID, graphicVersion);
			
			if (isLoaded(key)) {
				if (obj is CreatorPlayfieldObject) {
					CreatorPlayfieldObject(obj).updateClip();
				}
			} else {
				_waitingObjects[obj] = key;
				if (_requestedGraphics.indexOf(key) == -1) {
					loadGraphic(graphicID, graphicVersion);
					_requestedGraphics.push(key);
				}
				
			}
			
		}
		
		public function removeUnused ():void {
			
			
		}
		
		public function fromString (textures:String):void {
			
			
		}
		
		public function toString ():String {
			
			return "";
			
		}
		
		
	}

}