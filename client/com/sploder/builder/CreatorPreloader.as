package com.sploder.builder {
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	
	/**
	 * ...
	 * @author ...
	 */
	public class CreatorPreloader extends MovieClip 
	{
		
		[Embed(source = "../../../assets/preloader.swf", symbol="preloader")]
		protected var preloaderSWF:Class;
		
		public static var url:String = "";
		
		protected var preloaderClip:Sprite;
		protected var statusText:TextField;
		
		public static var instance:CreatorPreloader;
		public static var mainInstance:DisplayObject;
		
		protected var _placed:Boolean = false;
		
		public function CreatorPreloader() {
			
			super();
			
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
			
			if (stage.loaderInfo != null && stage.loaderInfo.url != null) url = stage.loaderInfo.url;
			
			addEventListener(Event.ENTER_FRAME, checkFrame);
			
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);
			
			preloaderClip = new preloaderSWF() as Sprite;
			
			if (!_placed) place();
			
			statusText = preloaderClip["statusText"];
			
			addChild(preloaderClip);

		}
		
		//
		//
		protected function progress(e:ProgressEvent):void {
			
			// update loader
			statusText.text = "Loading " + Math.ceil((root.loaderInfo.bytesLoaded / root.loaderInfo.bytesTotal) * 100) + "%";

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
		
		//
		//
		protected function checkFrame(e:Event):void {
			
			if (currentFrame == totalFrames) {
				
				removeEventListener(Event.ENTER_FRAME, checkFrame);
				if (root.loaderInfo.loaderURL.indexOf("http://www.sploder.com") == 0 || 
					root.loaderInfo.loaderURL.indexOf("http://sploder.com") == 0 || 
					root.loaderInfo.loaderURL.indexOf("http://sploder.s3.amazonaws.com") == 0 || 
					root.loaderInfo.loaderURL.indexOf("http://sploder.home") == 0 || 
					root.loaderInfo.loaderURL.indexOf("http://192.168.") == 0 || 
					root.loaderInfo.loaderURL.indexOf("file://") == 0) startup();
				else statusText.text = "Sitelock activated.";
				
			}
			
		}
		
		//
		//
		protected function startup():void {
			
			stop();
			
			stage.quality = StageQuality.HIGH;
			
			if (stage.loaderInfo != null && stage.loaderInfo.url != null) url = stage.loaderInfo.url;
			
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);
			
			var mainClass:Class = getDefinitionByName("com.sploder.builder.CreatorMain") as Class;
			mainInstance = new mainClass(stage, this) as DisplayObject;
			addChild(mainInstance);
			
		}
		
		//
		//
		public function done ():void {
			
			if (preloaderClip != null && getChildIndex(preloaderClip) != -1) removeChild(preloaderClip);
			preloaderClip = null;
			
		}
		
		//
		//
		public function set status (msg:String):void {
			
			statusText.text = msg;
			
		}
		
	}
	
}