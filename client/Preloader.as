package 
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;

	/**
	 * ...
	 * @author Geoff
	 */
	public class Preloader extends MovieClip 
	{
		
		[Embed(source = "assets/preloader.swf", symbol="preloader")]
		protected var preloaderSWF:Class;
		
		public static var url:String = "";
		
		protected var preloaderClip:Sprite;
		protected var statusText:TextField;
		
		public static var instance:Preloader;
		public static var mainInstance:DisplayObject;

		public static var testing:Boolean = false;
		
		protected var _placed:Boolean = false;
		
		protected var _started:Boolean = false;
		
		public static const GAME_LOADED:String = "game_loaded";
		public static const SFX_LOADED:String = "SFX_loaded";
		public static const SFX2_LOADED:String = "SFX2_loaded";
		
		protected static var _SFXLoaded:Boolean = false;
		public static function get SFXLoaded():Boolean { return _SFXLoaded; }
		
		protected static var _SFX2Loaded:Boolean = false;
		public static function get SFX2Loaded():Boolean { return _SFX2Loaded; }
		
		protected static var _gameLoaded:Boolean = false;
		public static function get gameLoaded():Boolean { return _gameLoaded; }
		
		public var SFXClass:Class;
		public var SFX2Class:Class;
		
		public var loader:Loader;
		
		public function Preloader() {
			
			super();
			
			_gameLoaded = _SFXLoaded = _SFX2Loaded = false;
			
			instance = this;
			
			init();
			
		}
		
		protected function init ():void {
			
			Security.allowDomain("www.sploder.com");
			Security.allowDomain("sploder.com");
			Security.allowDomain("sploder.s3.amazonaws.com");
			Security.allowDomain("sploder.home");
			
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			
		}
		
		//
		//
		public function onAdded (e:Event = null):void {

			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			
			//stage.showDefaultContextMenu = false;

			if (stage.loaderInfo != null && stage.loaderInfo.url != null) url = stage.loaderInfo.url;
			
			addEventListener(Event.ENTER_FRAME, checkFrame);
			
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);
			loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			
			preloaderClip = new preloaderSWF() as Sprite;
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			if (!_placed) place();
			
			statusText = preloaderClip["statusText"];
			
			addChild(preloaderClip);

		}
		
		protected function onLoadError (e:IOErrorEvent):void {
			
			// load not completed
			
		}
		
		//
		//
		protected function progress(e:ProgressEvent):void {
			
			// update loader
			status = "Loading " + Math.ceil((root.loaderInfo.bytesLoaded / root.loaderInfo.bytesTotal) * 100) + "%";

			if (!_placed) place();
			
			preloaderClip.visible = true;
			
		}
		
		//
		//
		protected function place ():void {
			
			var px:Number = Math.ceil((stage.stageWidth - preloaderClip.width) * 0.5);
			var py:Number = Math.ceil((stage.stageHeight - preloaderClip.height) * 0.5);
			
			if (!isNaN(px) && !isNaN(py)) {
				preloaderClip.x = px;
				preloaderClip.y = py;
				_placed = true;
			}				
			
		}
		
		protected function checkFrame(e:Event):void {
			
			if (currentFrame == 2 && !_started) {
				
				if (!_gameLoaded) {
					
					_gameLoaded = true;
					startup();
					dispatchEvent(new Event(GAME_LOADED));
					
				}
				
			} else if (currentFrame == 3) {
				
				if (!_SFXLoaded) {
					
					
					addSFX();
					trace("SFX loaded");
					_SFXLoaded = true;
					dispatchEvent(new Event(SFX_LOADED));
					
				}
				
			} else if (currentFrame == 4) {
				
				if (!_SFX2Loaded) {
					
					addSFX2();
					trace("SFX2 loaded");
					_SFX2Loaded = true;
					dispatchEvent(new Event(SFX2_LOADED));
					
				}
				
				removeEventListener(Event.ENTER_FRAME, checkFrame);
				stop();
				
			}
			
		}
		
		public function startup():void {
			
			stage.quality = StageQuality.HIGH;
			
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);
			
			if (loaderInfo.url.indexOf("testing") != -1) testing = true;
			_started = true;

			addMain();
	
		}
		
		//
		//
		public static function restart ():void {
			
			if (mainInstance != null && instance.getChildIndex(mainInstance) != -1) {
				
				instance.show();
				instance.removeChild(mainInstance);
				instance.startup();
				
			}
	
		}
		
		//
		//
		public function hide ():void {
			
			if (preloaderClip.parent != null) preloaderClip.parent.removeChild(preloaderClip);
			
		}
		
		//
		//
		public function show ():void {
			
			stage.quality = StageQuality.HIGH;
			if (preloaderClip.parent == null) addChild(preloaderClip);
			
		}

		//
		//
		public function set status (msg:String):void {
			
			if (statusText) statusText.text = msg;
			
		}
		
		public function addMain ():void {
			
			var frameClass:Class;
			
			if (loaderInfo != null && loaderInfo.applicationDomain.hasDefinition("Main")) {
				frameClass = loaderInfo.applicationDomain.getDefinition("Main") as Class;
			} else {
				frameClass = getDefinitionByName("Main") as Class;
			}
			
			mainInstance = addChild(new frameClass(this) as DisplayObject);
				
		}
		
		protected function addSFX ():void {
			
			var frameClass:Class;
			
			if (loaderInfo != null && loaderInfo.applicationDomain.hasDefinition("Sounds")) {
				frameClass = loaderInfo.applicationDomain.getDefinition("Sounds") as Class;
			} else {
				frameClass = getDefinitionByName("Sounds") as Class;
			}
			
			addChild(new frameClass(this) as DisplayObject);

		}
		
		protected function addSFX2 ():void {
			
			var frameClass:Class;
			
			if (loaderInfo != null && loaderInfo.applicationDomain.hasDefinition("Sounds2")) {
				frameClass = loaderInfo.applicationDomain.getDefinition("Sounds2") as Class;
			} else {
				frameClass = getDefinitionByName("Sounds2") as Class;
			}
			
			addChild(new frameClass(this) as DisplayObject);

		}
		
		public function setSFXClass (c:Class, libnum:int = 1):void {
			
			if (libnum == 1) SFXClass = c;
			else if (libnum == 2) SFX2Class = c;
			
		}
		
		//
		//
		protected function onRemove (e:Event):void {
			
			if (mainInstance != null && mainInstance.parent != null) {
				mainInstance.parent.removeChild(mainInstance);
			}
			
			mainInstance = null;
			
		}
		
	}
	
}