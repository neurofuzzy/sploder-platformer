package com.sploder.builder {
	
    import com.sploder.builder.*;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import flash.utils.getTimer;
    
    
    public class CreatorNavigator {

		protected var _active:Boolean = false;
		
		public function get active():Boolean { return _active; }
				
		public function set active(value:Boolean):void 
		{
			_active = value;
			
			if (_active) {
				
				_navButton.addEventListener(MouseEvent.MOUSE_DOWN, startDrag);
				_navButton.addEventListener(MouseEvent.MOUSE_UP, stopDrag);
				_navButton.useHandCursor = true;
	
			} else {
				
				_navButton.removeEventListener(MouseEvent.MOUSE_DOWN, startDrag);
				_navButton.removeEventListener(MouseEvent.MOUSE_UP, stopDrag);
				_navButton.useHandCursor = false;
				stopDrag();
		
			}
			
		}
		
        public var defaultScale:Number = 1;
        public var sourceScale:Number = 1;
        public var targetScale:Number = 1;
		public var dragscale:Number;
    
        public var sourcex:Number = 0;
        public var sourcey:Number = 0;
        public var targetx:Number = 0;
        public var targety:Number = 0;
    
        public var spanTime:Number = 750;
    
        public var startScale:Number;
        public var startPan:Number;
    
        private var _container:MovieClip;
		public function get container():MovieClip { return _container; }
		
        public var _playfield:CreatorPlayfield;
        public var _backgroundmc:MovieClip;
    
        public var zoomInterval:Number;
        public var panInterval:Number;
    
        public var draggable:Boolean = false;
    
        public var zoomin:MovieClip;
        public var zoomout:MovieClip;
        public var zoomall:MovieClip;
    
        public var minScale:Number = 0.05;
        public var maxScale:Number = 1;
		
		protected var _navButton:SimpleButton;
		public function get navButton():SimpleButton { return _navButton; }
		
		public function get scale ():Number { return _container.scaleX; }

        //
        //
        //
        public function CreatorNavigator (creator:Creator, container:MovieClip, targetclip:CreatorPlayfield, navbutton:SimpleButton) {
    
            _container = container;
            _playfield = targetclip;
			
			_container.x = 0;
			_container.y = 0;
			_container.scrollRect = new Rectangle( -280, -270, 860, 540);

            _navButton = navbutton;
			_navButton.doubleClickEnabled = true;
			_navButton.addEventListener(MouseEvent.DOUBLE_CLICK, creator.buttons.toggleNavMode);
    
			active = true;

            defaultScale = container.scaleX;

            zoomin = _playfield.creator.buttons.zoomInToggle;
            zoomout = _playfield.creator.buttons.zoomOutToggle;
            zoomall = _playfield.creator.buttons.zoomAllToggle;
			
            zoomin.gotoAndStop(2);
            zoomout.gotoAndStop(1);
            zoomall.gotoAndStop(1);
    
        }
		
		//
		//
		protected function startDrag (e:MouseEvent):void {

			_playfield.selection.selectNone();
			//CreatorMain.mainStage.quality = StageQuality.MEDIUM;
			_navButton.addEventListener(MouseEvent.ROLL_OUT, stopDrag);
			CreatorMain.mainStage.addEventListener(Event.MOUSE_LEAVE, stopDrag);
			_playfield.clip.startDrag();

		}

		//
		//
		protected function stopDrag (e:Event = null):void {
			
			_playfield.clip.stopDrag();
			_navButton.removeEventListener(MouseEvent.ROLL_OUT, stopDrag);
			CreatorMain.mainStage.removeEventListener(Event.MOUSE_LEAVE, stopDrag);
			CreatorMain.mainStage.quality = StageQuality.HIGH;

		}
    
        //
        //
        public function focusMap(centerx:Number = 0, centery:Number = 0, zoomfactor:Number = 1):void {
  
            zoomMap(zoomfactor);
			if (!isNaN(centerx) && !isNaN(centery)) panMap(0 - centerx, 0 - centery);
    
        }
    
        //
        //
        public function zoomFull():void {
    
            focusMap(_playfield.centerx, _playfield.centery, _playfield.defaultScale);
    
            zoomin.gotoAndStop(2);
            zoomout.gotoAndStop(1);
            zoomall.gotoAndStop(1);
    
        }

        //
        //
        public function zoomMap(factor:Number):void {
   
            var ts:Number;
            
            if (factor == 1) {
    
                factor = 2;
                draggable = true;
    
            } else if (factor == 0) {
    
                factor = 1/2;
    
            } else {
    
                ts = factor;
                factor = 1;
    
            }
    
            if (targetScale * factor < defaultScale) {
    
                factor = defaultScale / targetScale;
    
            }
    
            if ((Math.ceil(targetScale * factor) >= minScale) && (Math.floor(targetScale * factor) <= maxScale)) {
    
                sourceScale = _container.scaleX;
                targetScale *= factor;
    
                if (!isNaN(ts)) {
                    targetScale = Math.min(maxScale,Math.max(minScale,ts));
                }
    
                startScale = getTimer();
                clearInterval(zoomInterval);
                zoomInterval = setInterval(zoomImage, 10);
    
                // check button states
                if (Math.ceil(targetScale / 2) >= minScale) {
                    zoomout.gotoAndStop(2);
                    zoomall.gotoAndStop(2);
                } else {
                    zoomout.gotoAndStop(1);
                    zoomall.gotoAndStop(1);
                }
    
                if (Math.floor(targetScale * 2) <= maxScale) {
                    zoomin.gotoAndStop(2);
                } else {
                    zoomin.gotoAndStop(1);
                }
    
                if (targetScale <= 101) {
                    draggable = false;
                } else {
                    draggable = true;
                }
    
            }
    
        }
    
        //
        //
        // ZOOMIMAGE zooms an image with ease
        public function zoomImage():void {
    
			//CreatorMain.mainStage.quality = StageQuality.MEDIUM;
			
            var currTime:int = getTimer() - startScale;
            _container.scaleX = _container.scaleY = easeImage(currTime, sourceScale, targetScale - sourceScale, spanTime, "zoom");
            // check x,y position after scale
			
			var r:Rectangle = _container.scrollRect;
			r.width = 860 / _container.scaleX;
			r.height = 540 / _container.scaleY;
			r.x = 0 - (430 + 80) / _container.scaleX
			r.y = 0 - 270 / _container.scaleY;
			_container.scrollRect = r;

            var dragscale:Number = _container.scaleX;
    
            var _mc:CreatorPlayfield = _playfield;
    
            if (currTime >= spanTime) {
    
				CreatorMain.mainStage.quality = StageQuality.HIGH;
                clearInterval(zoomInterval);
    
            }
    
        }
    
        //
        //
        //
        public function panMap(x:Number, y:Number):void {

            startPan = getTimer();
            sourcex = _playfield.clip.x;
            sourcey = _playfield.clip.y;
            targetx = x;
            targety = y;
            clearInterval(panInterval);
            panInterval = setInterval(panImage, 10);
    
        }
    
        //
        //
        // PANIMAGE pans an image with ease
        public function panImage():void {
    
            var currTime:int = getTimer() - startPan;
    
            var dragscale:Number = _container.scaleX;

            _playfield.clip.x = easeImage(currTime, sourcex, targetx - sourcex, spanTime, "pan");
            _playfield.clip.y = easeImage(currTime, sourcey, targety - sourcey, spanTime, "pan");
    
            if (currTime >= spanTime) {
                clearInterval(panInterval);
            }
    
        }
    
        //
        //
        // EASEIMAGE eases the panning on an image, slowing it down at the beginning and end
        public function easeImage(currTime:Number, anchor:Number, span:Number, duration:Number, type:String):Number {
    
            var idelta:Number;
    
            if ((currTime /= (duration/2))<1) {
    
                idelta = Math.pow(currTime, 2)*(span/2)+anchor;
    
            } else {
    
                idelta = ((--currTime)*(currTime-2)-1)*(0-span/2)+anchor;
    
            }
    
            return idelta;
    
        }
		
    }
	
}
