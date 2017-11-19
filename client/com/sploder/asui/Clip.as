package com.sploder.asui {
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Rectangle;
	import flash.net.navigateToURL;
	import flash.system.LoaderContext;

	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.net.URLRequest;

    /**
    * ...
    * @author $(DefaultUser)
    */
    
    public class Clip extends Component {
        
        public static const SCALEMODE_NOSCALE:int = 1;
        public static const SCALEMODE_CENTER:int = 2;
        public static const SCALEMODE_FILL:int = 3;
        public static const SCALEMODE_FIT:int = 4;
        public static const SCALEMODE_STRETCH:int = 5;
		
		public static const EMBED_REMOTE:int = 1;
		public static const EMBED_LOCAL:int = 2;
		public static const EMBED_SMART:int = 3;
        
        public static var baseURL:String = "";
        
        public static var clipsLoading:int = 0;
        
        private var _scaleMode:Number = 1;
        
        private var _url:String = "";
        
        private var _linkURL:String = "";
        
        private var _newWindow:Boolean = false;
        
        private var _alt:String = "";
        public function get alt ():String { return _alt; }
        public function set alt (value:String):void { _alt = value; }
		
		public var showAltImmediate:Boolean = false;
        
        private var _embedded:Boolean = false;
        
        private var _loaderclip:Sprite;
		private var _request:URLRequest;
        private var _loader:Loader;
        
        private var _btn:Sprite;
        private var _clickable:Boolean = false;
        
        private var _loading:Boolean = false;
        
        private var _loaded:Boolean = false;
        public function get loaded():Boolean { return _loaded; }
        
        private var _debugmode:Boolean = false;
        
        public function get loadedClip():Sprite { return _loaderclip; }
		
		public function get embedded():Boolean { return _embedded; }
		
		public var forceCentered:Boolean = false;
		public var forceBorder:Boolean = false;
		
		public function set underClipMouseEnabled(value:Boolean):void 
		{
			super.mouseEnabled = value;
			_mc.mouseEnabled = _mc.mouseChildren = true;
			if (_loaderclip) _loaderclip.mouseEnabled = _loaderclip.mouseChildren = true;
			if (_btn) _btn.visible = false;
		}
        
        //
        //
        public function Clip(container:Sprite, url:String, embedded:int = EMBED_SMART, width:Number = NaN, height:Number = NaN, scaleMode:Number = SCALEMODE_NOSCALE, linkURL:String = "", newWindow:Boolean = false, altTag:String = "", position:Position = null, style:Style = null) {
            
            init_Clip (container, url, embedded, width, height, scaleMode, linkURL, newWindow, altTag, position, style);
            
            if (_container != null) create();
            
        }
        
        //
        //
		protected function init_Clip (container:Sprite, url:String, embedded:int, width:Number, height:Number, scaleMode:Number, linkURL:String, newWindow:Boolean, altTag:String, position:Position, style:Style):void {

            super.init(container, position, style);
			
			_type = "clip";
            
            _url = url;
            if (embedded == EMBED_SMART) {
				_embedded = (url.indexOf("/") == -1);
			} else {
				_embedded = (embedded == EMBED_LOCAL);
			}
            _width = width;
            _height = height;
            _scaleMode = (!isNaN(scaleMode) && _width > 0 && _height > 0) ? scaleMode : SCALEMODE_NOSCALE;
            _linkURL = (linkURL.length > 0) ? linkURL : "";
            _newWindow = (newWindow == true);
    
            if (altTag.length > 0) _alt = altTag;
            
        }
        
        //
        //
        override public function create ():void {
            
            super.create();
            
            if (_url != null && _url.length > 0) {
                
				_loaderclip = new Sprite(); 
				_mc.addChild(_loaderclip); 
				
                if (!_embedded) load();
                else embed();
 
            }
            
        }
        
        //
        //
        private function rollover (e:Event):void {
			
            if (_alt.length > 0) Tagtip.showTag(_alt, showAltImmediate);
    
        }
        
        //
        //
        private function rollout (e:Event):void {
            
            Tagtip.hideTag();
            
        }
        
        
        //
        //
        private function load ():void {
            
            if (!_loading && !_loaded) {
                
                clipsLoading++;
                
				if (baseURL.length > 0 && baseURL.charAt(baseURL.length - 1) != "/") baseURL += "/";
				_request = new URLRequest(baseURL + _url);
                _loader = new Loader();
				
				_loaderclip.addChild(_loader);
				
				configureListeners(_loader.contentLoaderInfo);
				
				var context:LoaderContext = new LoaderContext();
				context.checkPolicyFile = true;
				
                _loader.load(_request, context);
                
                _loading = true;
            
            }
            
        }
		
		//
		//
        private function configureListeners(dispatcher:IEventDispatcher):void {
			
            dispatcher.addEventListener(Event.COMPLETE, completeHandler);
            dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            dispatcher.addEventListener(Event.INIT, initHandler);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            dispatcher.addEventListener(Event.OPEN, openHandler);
            dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            dispatcher.addEventListener(Event.UNLOAD, unLoadHandler);
			
        }
		
		//
		//
		protected function embed ():void {
			
			if (library == null) {
				throw new Error("Register a library with Component in order to embed clips!");
			} else {
				var edo:DisplayObject = library.getDisplayObject(_url)
				_loaderclip.addChild(edo);
				if (isNaN(_width) || _width == 0) _width = edo.width;
				if (isNaN(_height) || _height == 0) _height = edo.height;
				initHandler(edo);
			}
			
		}
		
		private function completeHandler(event:Event):void {
            trace("completeHandler: " + event);
        	clipsLoading--;
            
            _loading = false;
            _loaded = true;	
        }

        private function httpStatusHandler(event:HTTPStatusEvent):void {
            trace("httpStatusHandler: " + event);
        }

        private function ioErrorHandler(event:IOErrorEvent):void {
            trace("ioErrorHandler: " + event);
        }

        private function openHandler(event:Event):void {
            trace("openHandler: " + event);
        }

        private function progressHandler(event:ProgressEvent):void {
            trace("progressHandler: bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
        }

        private function unLoadHandler(event:Event):void {
            trace("unLoadHandler: " + event);
        }

        //
        //
        private function initHandler(obj:Object):void {

			//trace("initHandler: " + obj);
			
			var target:DisplayObject;
			
			if (obj is Event) target = LoaderInfo(obj.target).loader as DisplayObject;
			else if (obj is DisplayObject) target = obj as DisplayObject;
			else return;

            if (target.width == 0) return;
    
            //trace("DisplayObject " + target + " is now initialized.");
    
            _btn = new Sprite();
			_mc.addChild(_btn);
            DrawingMethods.rect(_btn, false, 0, 0, _width, _height, 0x000000, 0.2);
            _btn.alpha = 0;
            connectButton(_btn, false);
                
            if (_alt.length > 0) {
				
                addEventListener(EVENT_M_OVER, rollover);
                addEventListener(EVENT_M_OUT, rollout);
                 
            }
            
            if (_linkURL.length == 0) _btn.useHandCursor = false;
			
            var targetAspect:Number = target.width / target.height;
            var clipAspect:Number = _width / _height;
			
			if (target is Loader) {
				if (Loader(target).content is Bitmap) {
					Bitmap(Loader(target).content).smoothing = true;
				}
			}
            
            switch (_scaleMode) {
                
                case SCALEMODE_NOSCALE:
                    break;
              
                case SCALEMODE_FILL:
                    if (targetAspect > clipAspect) {
                        target.height = _height;
                        target.width = target.height * targetAspect;
                    } else {
                        target.width = width;
                        target.height = target.width / targetAspect;
                    }
                    break;
                    
                case SCALEMODE_FIT:
                    if (targetAspect < clipAspect) {
                        target.height = _height;
                        target.width = target.height * targetAspect;
                    } else {
                        target.width = width;
                        target.height = target.width / targetAspect;
                    }
                    
                case SCALEMODE_CENTER:
                    if (target.width > 0 && target.width < _width) target.x = Math.floor((_width - target.width) * 0.5);
                    if (target.height > 0 && target.height < _height) target.y = Math.floor((_height - target.height) * 0.5);
                    break;
                    
                case SCALEMODE_STRETCH:
                    target.width = _width;
                    target.height = _height;
         
            }
			
            if (_scaleMode == SCALEMODE_FILL) {
                
				var mask:Sprite = new Sprite();
				_mc.addChild(mask);
                DrawingMethods.rect(mask, false, 0, 0, _width, _height, _style.backgroundColor, 0);
    
                target.mask = mask;
                
            }
			var br:Rectangle = target.getRect(_mc);
			
			if (forceCentered) {
				br = target.getRect(_mc);
				target.x = (0 - target.width) * 0.5 - br.x;
                target.y = (0 - target.height) * 0.5 - br.y;
			}
    
			if (forceBorder) {
				var border:Sprite = new Sprite();
				_mc.addChild(border);
				br = target.getRect(_mc);
				DrawingMethods.emptyRect(border, false, br.x, br.y, br.width, br.height, 2, _style.borderColor, 1);
			}
        }
		
		//
		//
		override protected function onClick(e:MouseEvent = null):void {
			
			if (_linkURL.indexOf("event:") == 0) {
				if (form != null && name != null && name.length > 0) form[name] = value;
			} else {
				launchURL(e);
			}
			
			super.onClick(e);
			
		}
        
        //
        //
        protected function launchURL (e:Event = null):void {
           
			if (_linkURL.length) {
				var req:URLRequest = new URLRequest(_linkURL);
				if (_newWindow) navigateToURL(req, "_blank");
				else navigateToURL(req);
			}

        }
        
        //
        //
        protected function debug (msg:String):void {
            
            if (_debugmode) trace(msg);
            
        }
        
    }
}
