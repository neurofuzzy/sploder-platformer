package fuz2d.library {
	
	import com.adobe.serialization.json.JSON;
	import com.adobe.crypto.MD5;
	import com.sploder.texturegen_internal.TextureAttributes;
	import com.sploder.texturegen_internal.TextureRenderingCache;
	import com.sploder.texturegen_internal.TextureRenderingJob;
	import com.sploder.texturegen_internal.TextureRenderingQueue;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import fuz2d.util.Geom2d;
	import fuz2d.util.ReduceColors;

	import fuz2d.util.TileSet;
	import fuz2d.util.TileDefinition;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	
	//
	//
	public class EmbeddedLibrary extends EventDispatcher {
		
		public static var grid_width:int = 60;
		public static var grid_height:int = 60;
		public static var scale:Number = 1;
		
		protected var _smoothing:Boolean = false;
		public function get smoothing():Boolean { return _smoothing; }
		public function set smoothing(value:Boolean):void { _smoothing = value; }
		
		public static const INITIALIZED:String = "embeddedlibrary_initialized";
		
		protected var embeddedLibrary:Class;

		protected var loader:Loader;
		
		protected function get initialized ():Boolean { return (loader.content != null); }
		
		protected static var _ignore8bit:Boolean = false;
		public var use8bitStyle:Boolean = false;

		protected var debugmode:Boolean;
		
		protected static var bitmapDataCache:Object;
		
		protected static var tileDefinitionCache:Object;
		protected static var tileSetCache:Object;
		
		public static var textureQueue:TextureRenderingQueue;
		
		protected var _timer:Timer;
		protected var _eventSent:Boolean = false;

		//
		//
		public function EmbeddedLibrary (embeddedSWF:Class, ignore8bit:Boolean = false, debug:Boolean = false) {
			
			embeddedLibrary = embeddedSWF;
			_ignore8bit = ignore8bit;
			debugmode = debug;
			
			textureQueue = new TextureRenderingQueue().init();
			textureQueue.pauseInterval = 1;
			textureQueue.tasksPerFrame = 2;
			
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

			if (bitmapDataCache == null) bitmapDataCache = { };
			if (tileDefinitionCache == null) tileDefinitionCache = { };
			if (tileSetCache == null) tileSetCache = { };
			
			_timer = new Timer(250, 0);
			_timer.addEventListener(TimerEvent.TIMER, checkEvent);
			_timer.start();

		}
		
		public static function purge (protectedIDs:Array = null):void {
			
			var param:String;
			
			if (tileSetCache != null) {
				var t:TileSet;
				var tileID:int = 0;
				for (param in tileSetCache) {
					t = tileSetCache[param];
					if (t is TileSet) {
						tileID = parseInt(param.split("_")[0]);
						if (!isNaN(tileID) && (protectedIDs == null || protectedIDs.indexOf(tileID) == -1)) {
							//trace("Clearing tile ID", param);
							t.end();
							tileSetCache[param] = null;
							delete tileSetCache[param];
						}
					}
				}
			}
		
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
		
		//
		//
		//
		public function getDisplayObject (symbolName:String):DisplayObject {
			
			var obj:Object;
			
			try {

				obj = getSymbolInstance(symbolName);
				
				if (obj is Sprite) {
					if (obj["texture"] != undefined) {
						Sprite(obj["texture"]).scaleX = 1 / scale;
						Sprite(obj["texture"]).scaleY = 1 / scale;
					}
				}
				
				if (obj is DisplayObject) return obj as DisplayObject;
				else throw new Error();

			} catch (e:Error) {

				trace("Library Symbol '" + symbolName + "' is not a Display Object");
				
			}
			
			return null;
			
		}
		
		//
		//
		public function getDisplayObjectAsBitmap (symbolName:String, filters:Array = null, constrainBounds:Boolean = false):Bitmap {
			
			return new Bitmap(getDisplayObjectBitmapData(symbolName, "", filters, 0, constrainBounds), PixelSnapping.ALWAYS, smoothing);
			
		}
		
		//
		//
		public function getMovieClipAsBitmap (symbolName:String, frameLabel:String = "", filters:Array = null):Bitmap {
			
			return new Bitmap(getDisplayObjectBitmapData(symbolName, frameLabel, filters), PixelSnapping.ALWAYS, smoothing);
			
		}
		
		//
		//
		public function getMovieClipBitmapData (symbolName:String, frameLabel:String = "", filters:Array = null, rotation:Number = 0):BitmapData {
			
			return getDisplayObjectBitmapData(symbolName, frameLabel, filters, rotation);
			
		}
		
		//
		//
		public function getDisplayObjectBitmapData (symbolName:String, frameLabel:String = "", filters:Array = null, rotation:Number = 0, constrainBounds:Boolean = false):BitmapData {
			
			var frameID:String = (frameLabel != "") ? "__" + frameLabel : "";
			
			var deg:int = (rotation == 0) ? 0 : Math.floor(Geom2d.dtr * rotation);
			
			if (bitmapDataCache[symbolName + frameID + "_" + deg] != null && bitmapDataCache[symbolName + frameID + "_" + deg] is BitmapData) return BitmapData(bitmapDataCache[symbolName + frameID + "_" + deg]);
			
			var clip:DisplayObject = getDisplayObject(symbolName);
			
			if (frameLabel != "" && clip is MovieClip) MovieClip(clip).gotoAndStop(frameLabel);
			
			if (clip != null) {
				
				//clip.scaleX = clip.scaleY = scale;
				
				var bw:int = clip.width;
				var bh:int = clip.height;
				
				if (clip is Sprite) {
					if (clip["texture"] != undefined) {
						Sprite(clip["texture"]).scaleX = 0.01;
						Sprite(clip["texture"]).scaleY = 0.01;
					}
					if (clip["bounds"] != undefined) {
						if (constrainBounds) {
							bw = Sprite(clip["bounds"]).width;
							bh = Sprite(clip["bounds"]).height;
						}
						Sprite(clip["bounds"]).visible = false;
					}
				}
	
				var bd:BitmapData = new BitmapData(Math.floor(bw * scale), Math.floor(bh * scale), true, 0x00000000);
				
				var m:Matrix = new Matrix();	
				m.createBox(scale, scale, rotation, Math.floor(bw * 0.5 * scale), Math.floor(bh * 0.5 * scale));
				
				if (clip is Sprite) {
					if (clip["texture"] != undefined) {
						Sprite(clip["texture"]).scaleX = 1 / scale;
						Sprite(clip["texture"]).scaleY = 1 / scale;
					}
				}
				
				bd.draw(clip, m);
				
				if (filters != null) {
					
					for (var i:int = 0; i < filters.length; i++) {
						
						bd.applyFilter(bd, new Rectangle(0, 0, bd.width, bd.height), new Point(0, 0), filters[i]);
						
					}
					
				}
				
				bitmapDataCache[symbolName] = bd;
				
				if (!_ignore8bit && use8bitStyle) ReduceColors.toVGA(bd);
				
				return bd;
				
			}
			
			return null;
			
		}
		
		//
		//
		public function createTileSet (seedID:int, back:Boolean = false, overrides:Object = null, size:int = -1, tilescale:int = 1):String {
			
			var def:TileDefinition;
			
			if (size == -1) size = Math.ceil(TileDefinition.grid_width * scale);
			
			size *= tilescale;
			
			var backDef:String = (back) ? "_back" : "";
			
			var defID:String = seedID + "_" + size + backDef;

			if (overrides != null) defID = defID + "_" + MD5.hash(com.adobe.serialization.json.JSON.encode(overrides));
			
			if (tileSetCache[defID] == null) {
				
				if (tileDefinitionCache[defID] != null) {
					def = tileDefinitionCache[defID];
				} else {
					def = tileDefinitionCache[defID] = new TileDefinition(seedID, back, null, size, size);
					if (overrides != null) {
						def = def.clone();
						def.inject(overrides);	
					}
				}
				
				tileSetCache[defID] = new TileSet(def);
			
			}
			
			return defID;
	
		}
		
		//
		//
		public function getTileDefinition (defID:String):TileDefinition {
			
			if (tileDefinitionCache[defID] != null) return tileDefinitionCache[defID];
			
			return null;
			
		}
		
		//
		//
		public function getTileDefID (seedID:int, back:Boolean = false, overrides:Object = null, size:int = -1, tilescale:int = 1):String {
			
			var def:TileDefinition;
			
			if (size == -1) size = Math.ceil(TileDefinition.grid_width * scale);
			
			size *= tilescale;
			
			var backDef:String = (back) ? "_back" : "";
			
			var defID:String = seedID + "_" + size + backDef;

			if (overrides != null) defID = defID + "_" + MD5.hash(com.adobe.serialization.json.JSON.encode(overrides));
			
			return defID;
			
		}
			
		
		//
		//
		public function getTileAsBitmap (definitionID:String, tileMap:Array = null, stampName:String = "", rotation:Number = 0, back:Boolean = false, tilescale:int = 1):Bitmap {
			
			return new Bitmap(getTileBitmapData(definitionID, tileMap, stampName, rotation, back, tilescale), PixelSnapping.ALWAYS, false);
	
		}
		
		//
		//
		public function getTileBitmapData (definitionID:String, tileMap:Array = null, stampName:String = "", rotation:Number = 0, back:Boolean = false, tilescale:int = 1):BitmapData {
			
			if (tileSetCache[definitionID] == null) definitionID = createTileSet(definitionID.split("_")[0], back, null, -1, tilescale);

			if (tileSetCache[definitionID] != null) {
				
				var tileset:TileSet = tileSetCache[definitionID];
				var stamp:Sprite;
				
				if (stampName != null && stampName.length > 0) stamp = getDisplayObject(stampName) as Sprite;

				var tb:BitmapData = tileset.getTile(tileMap, stampName, stamp, rotation);
				if (!_ignore8bit && use8bitStyle) ReduceColors.toVGA(tb);
				
				return tb;
				
			}
			
			return null;
			
		}
		
		
		//
		//
		public function getTextureAsBitmap (attribs:TextureAttributes, size:int = 120, borderType:int = 0):Bitmap {
			
			return new Bitmap(getTextureBitmapData(attribs, size, borderType), PixelSnapping.ALWAYS, false);
	
		}
		
		//
		//
		public function getTextureBitmapData (attribs:TextureAttributes, size:int = 120, borderType:int = 0):BitmapData {
			
			var bd:BitmapData;
			
			if (!TextureRenderingCache.hasTexture(attribs, size, borderType))
			{
				bd = new BitmapData(size, size, true, 0);
				bd.fillRect(bd.rect, 0xff000000 + attribs.mortarColor);
				bd.fillRect(new Rectangle(12, 12, 96, 96), 0xff000000 + attribs.diffuseColor);
				
				var job:TextureRenderingJob = new TextureRenderingJob().initWithProperties(attribs, bd, bd.rect, borderType, true, true, true);
				//textureQueue.renderImmediately(job);
				textureQueue.queueObject(job);
				TextureRenderingCache.setTexture(bd, attribs, size, borderType);
			} else {
				
				// texture may not be rendered yet, but using the same BitmapData will allow for it to update automatically.
				bd = TextureRenderingCache.getTexture(attribs, size, borderType);
			}
			
			return bd;
			
		}
		
		public function cleanTextureQueue ():void
		{
			TextureRenderingCache.queue = textureQueue;
			TextureRenderingCache.clearCache();
		}
		
		//
		//
		public function updateTexture (b:Bitmap, attribs:TextureAttributes, size:int = 120, borderType:int = 0):void {
			
			var bd:BitmapData = b.bitmapData;
			
			bd = getTextureBitmapData(attribs, size, borderType);
			if (bd != null) b.bitmapData = bd;
		}
		
		
		//
		//
		//
		public function getSound (symbolName:String):Sound {
			
			var obj:Object;
			
			try {
				
				obj = getSymbolInstance(symbolName);
				
				if (obj is Sound) return obj as Sound;
				else throw new Error();
				
			} catch (e:Error) {
				
				trace("Library Symbol '" + symbolName + "' is not a Display Object");
				
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