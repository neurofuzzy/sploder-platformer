package com.sploder.builder {
	
    import com.sploder.builder.*;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
    
    public class CreatorObjectGhost {

        protected var _creator:Creator;
		
		protected var _container:Sprite;
		public function get clip():Sprite { return _container; }
		
		protected var _homeX:Number;
		protected var _homeY:Number;
		
		protected var _snap:Boolean = false;
		
        public var validIcon:Sprite;
		public var proxy:Sprite;
		public var object:DisplayObject;
		
        
        //
        //
        //
        public function CreatorObjectGhost (creator:Creator, container:Sprite) {
            
            super();
            init(creator, container);
            
        }
        
        //
        //
        //
        protected function init (creator:Creator, container:Sprite):void {

            _creator = creator;
			_container = container;
			
			_homeX = _container.x;
			_homeY = _container.y;
			
            validIcon = _container["valid"];
			proxy = _container["proxy"];	
            
        }
        
        //
        //
        //
        public function startDrag (obj:CreatorObjectAdder):void {
			
			object = CreatorObjectAdder.getObject(obj, false);
			
			if (object != null) {
				
				_snap = CreatorFactory.getSnap(obj.id + "");
				
				if (object is Bitmap && object.scaleX != 1)
				{
					object.scaleX = object.scaleY = 1;
					object.x = 0 - object.width / 2;
					object.y = 0 - object.height / 2;
				}
				proxy.addChild(object);
				
				_container.visible = true;
				_container.scaleX = _container.scaleY = Creator.navigator.scale;
				_container.startDrag(true);
				
				CreatorMain.mainStage.addEventListener(Event.ENTER_FRAME, onDrag);
				
			}
            
        }
		
		//
		//
		protected function onDrag (e:Event):void {
			
			if (_snap) {
				
				var w:Number = proxy.width;
				var h:Number = proxy.height;
				
				if (proxy.getChildAt(0) is Sprite && Sprite(proxy.getChildAt(0)).getChildByName("bounds")) {
					var b:Sprite = Sprite(proxy.getChildAt(0)).getChildByName("bounds") as Sprite;
					w = b.width;
					h = b.height;
				}
				
				var xoffset:Number = (Math.floor(w / CreatorPlayfield.GRID_WIDTH) % 2 == 1) ? CreatorPlayfield.GRID_WIDTH / 2 : 0;
				var yoffset:Number = (Math.floor(h / CreatorPlayfield.GRID_HEIGHT) % 2 == 1) ? CreatorPlayfield.GRID_HEIGHT / 2 : 0;
				
				var newx:Number;
				if (xoffset == 0) newx = Math.round(Creator.playfield.clip.mouseX / CreatorPlayfield.GRID_WIDTH) * CreatorPlayfield.GRID_WIDTH + xoffset;
				else newx = Math.floor(Creator.playfield.clip.mouseX / CreatorPlayfield.GRID_WIDTH) * CreatorPlayfield.GRID_WIDTH + xoffset;
				
				var newy:Number;
				if (yoffset == 0) newy = Math.round(Creator.playfield.clip.mouseY / CreatorPlayfield.GRID_HEIGHT) * CreatorPlayfield.GRID_HEIGHT + yoffset;
				else newy = Math.floor(Creator.playfield.clip.mouseY / CreatorPlayfield.GRID_HEIGHT) * CreatorPlayfield.GRID_HEIGHT + yoffset;
		
				var rx:Number = newx - Creator.playfield.clip.mouseX;
				var ry:Number = newy - Creator.playfield.clip.mouseY;
				
				_container.graphics.clear();
				_container.graphics.lineStyle(1, 0xffec00, 1, true, LineScaleMode.NONE);
				_container.graphics.beginFill(0xffec00, 0.3);
				_container.graphics.drawRect(rx - w * 0.5, ry - h * 0.5, w, h);
			
			}		
			
		}
        
        //
        //
        //
        public function stopDrag ():void {

            _container.stopDrag();
			_container.graphics.clear();
			CreatorMain.mainStage.removeEventListener(Event.ENTER_FRAME, onDrag);
			
			if (object != null && proxy.getChildIndex(object) != -1) proxy.removeChild(object);
			object = null;
			validIcon.visible = false;
			
			_container.x = _homeX;
			_container.y = _homeY;
			_container.visible = false;
            
        }

    }
	
}
