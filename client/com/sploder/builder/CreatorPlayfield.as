package com.sploder.builder {
	
	import com.sploder.builder.*;
	import com.sploder.builder.CreatorFactory;
	import com.sploder.texturegen_internal.TextureRenderingCache;
	import flash.display.*;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import fuz2d.library.EmbeddedLibrary;
	
    
    public class CreatorPlayfield {
        
		public static const GRID_WIDTH:int = 60;
		public static const GRID_HEIGHT:int = 60;
		
        private var _parentClass:Creator;
		protected var _container:Sprite;
		public function get clip():Sprite { return _container; }
		
        public var navigator:CreatorNavigator;
    
        public var background:Sprite;
        public var grid:Sprite;
        
		public var map:ProximityGrid;
		
        private var _objects:Array;
		private var _objectsContainer:Sprite;
		
		public function get objectsContainer ():Sprite { return _objectsContainer; }
        
        private var _minx:Number = 0;
        private var _maxx:Number = 0;
        private var _miny:Number = 0;
        private var _maxy:Number = 0;
        
        private var _centerx:Number = 0;
        private var _centery:Number = 0;
        
        private var _width:Number;
        private var _height:Number;
        
		public var selection:CreatorSelection;
		public var selectionPrompt:TextField;
		
        private var totalObjects:Number = 0;
        
        public var populating:Boolean = false;
		protected var _popIndex:int = 0;
		
		public var clearing:Boolean = false;
        
        private var _defaultScale:Number;
        
		public var player:CreatorPlayfieldObject;
		
		protected var _mountainPoints:Array;
		
		protected var _initialized:Boolean = false;
    
        
        //
        //
        //
        public function CreatorPlayfield (creator:Creator, container:Sprite) {
            
			_parentClass = creator;
            _container = container;
			
        }
        
        
        //
        //
        //
        public function init ():void {
            
			navigator = Creator.navigator;
			selectionPrompt = _parentClass.ui["selectionprompt"];
			selectionPrompt.mouseEnabled = false;

            _width = 1200;
            _height = 800;

			background = new Sprite();
			grid = new Sprite();
			_container.addChild(background);
			_container.addChild(grid);
			
			_objectsContainer = new Sprite();
			_container.addChild(_objectsContainer);
			
            background.mouseEnabled = grid.mouseEnabled = false;
			
			grid.addChild(Creator.UIlibrary.getDisplayObject("playfieldGrid") as Sprite);
			
            _objects = [];
            selection = new CreatorSelection(_container.parent as Sprite, _container, _parentClass.ui["playmask"]), 
			selection.addEventListener(CreatorSelection.SELECTED, onSelect);
			selection.addEventListener(SelectionEvent.DELETE, onDelete);
			selection.proxy = _objectsContainer;
			
            setDefaultScale();
			
			map = new ProximityGrid(120, 120);
 
			player = null;
            getCreatorPlayfieldObjects();
			
			_container.mouseEnabled = false;
			if (_container.parent != null) _container.parent.mouseEnabled = false;

			CreatorMain.mainStage.addEventListener(Event.ENTER_FRAME, checkValid);
			
			_parentClass.project.addEventListener(CreatorProject.EVENT_LOAD, reset);
			_parentClass.project.addEventListener(CreatorProject.EVENT_NEW, reset);
            
			_initialized = true;

        }
        
        //
        //
        //
        public function reset (e:Event = null):void {

			selection.selectNone();
			player = null;
			
			clearing = true;
			
			if (_objectsContainer && _objectsContainer.parent) _objectsContainer.parent.removeChild(_objectsContainer);
			var t:Object = { objs: _objectsContainer };
			_objectsContainer = null;
			delete t["objs"];
			_objectsContainer = new Sprite();
			_container.addChild(_objectsContainer);
			selection.proxy = _objectsContainer;
			if (_objects) {
				var i:int = _objects.length;
				while (i--) {
					CreatorPlayfieldObject(_objects[i]).endClip();
				}
			}
			_objects = [];
			map = new ProximityGrid(120, 120);
			
			clearing = false;
			
			_parentClass.cleanBitmapData();
			
			getCreatorPlayfieldObjects();
  
        }
    
        //
        //
        //
        public function getCreatorPlayfieldObjects (e:Event = null):void {
            
			if (Creator.levels.objects == null || Creator.levels.objects.length == 0) return;
			
			if (!populating) {
				Creator.creatorlibrary.cleanTextureQueue();
				CreatorMain.mainStage.addEventListener(Event.ENTER_FRAME, getCreatorPlayfieldObjects);
				_parentClass.ddprogress.show("Building game level. Please wait");
				_popIndex = 0;
				populating = true;
				_container.visible = false;
				return;
			} else {
				if (Creator.levels.objects.length > 0) {
					_parentClass.ddprogress.percentComplete = _popIndex / Creator.levels.objects.length;
				}
			}
			
            var objects:Array = Creator.levels.objects.concat();
            var obj:Array;
            
			var id:int;
            var x:int;
			var y:int;
			var z:int;
			var r:int;
			var t:int;
			var g:int = 0;
			var gv:int = 0;
			var ga:int = 0;
			var data:Array;
			
			var startTime:int = getTimer();

			var i:Number;
			
            for (i = _popIndex; i < objects.length; i++) {
                    
                obj = objects[i].split(",");
				
				id = parseInt(obj[0]);
				x = parseInt(obj[1]);
				y = 0 - parseInt(obj[2]);
				z = CreatorFactory.getZIndex(obj[0]);
				r = (obj.length > 3) ? parseInt(obj[3]) : 0;
				t = (obj.length > 4) ? parseInt(obj[4]) : 0;
				
				if (_parentClass.project.hasGraphics) {
					g = (obj.length > 5) ? parseInt(obj[5]) : 0;
					gv = (obj.length > 6) ? parseInt(obj[6]) : 0;
					ga = (obj.length > 7) ? parseInt(obj[7]) : 0;
					data = (obj.length > 8) ? obj.slice(8, obj.length) : null;
				} else {
					data = (obj.length > 5) ? obj.slice(5, obj.length) : null;
				}
				
                // trace("adding object:", id, x, y, z, r, t);

                if (!isNaN(id) && !isNaN(x) && !isNaN(y) && !isNaN(z) && !isNaN(r)) addObject(id, x, y, z, r, t, data, g, gv, ga);
				
				_popIndex++;
				
				if (getTimer() - startTime > 500) {
					return;
				}
                
            }    
            
            populating = false;
			_container.visible = true;
			
			var has_textureblocks:Boolean = false;
			
			var cpobj:CreatorPlayfieldObject;
			
			for (i = 0; i < _objects.length; i++) {
				
				cpobj = CreatorPlayfieldObject(_objects[i]);
				if (cpobj.tile || cpobj.textureAttribs != null)
				{
					cpobj.updateClip();
					if (cpobj.textureAttribs != null) has_textureblocks = true;
				}
			}
			
			CreatorMain.mainStage.removeEventListener(Event.ENTER_FRAME, getCreatorPlayfieldObjects);
			
			if (has_textureblocks) CreatorMain.mainStage.addEventListener(Event.ENTER_FRAME, checkTextureProgress);

			_parentClass.ddprogress.hide();
			
			_popIndex = 0;
			
			setExtents();
			createBounds();
			zSort();
			center();
			Creator.mainInstance.objTray.updateAdders();
			
			if (player == null) addObject(1, 0, 0, 205);
			
			if (player != null) {
				player.setAvatar(Creator.levels.avatar);
			}
            
        }
		
		private function checkTextureProgress (e:Event):void
		{
			if (EmbeddedLibrary.textureQueue.percentComplete < 1) {
				_parentClass.ddprogress.percentComplete = 1 - EmbeddedLibrary.textureQueue.percentComplete;
				_parentClass.ddprogress.show();
			} else {
				CreatorMain.mainStage.removeEventListener(Event.ENTER_FRAME, checkTextureProgress);
				_parentClass.ddprogress.hide();
			}
		}
        

        //
        //
        //
        public function createBounds ():void {
            
            var g:Graphics = background.graphics;
			
			g.clear();
			//trace(Creator.levels.bgColor.toString(16), Creator.levels.gdColor.toString(16));
			g.moveTo(_minx, 0);
			g.beginFill(Creator.levels.bgColor, 1);
			g.lineTo(_maxx, 0);
			g.lineTo(_maxx, _miny);
			g.lineTo(_minx, _miny);
			g.endFill();
			g.moveTo(_minx, -80);
			g.beginFill(Creator.levels.gdColor, 1);
			
			var mn:int = Math.max(1, (_maxx - _minx) / 100);
			
			if (_mountainPoints == null) _mountainPoints = [];
			
			for (var i:int = 0; i < mn; i++) {
				if (_mountainPoints[i] == undefined) _mountainPoints.push(Math.random() * 30 - 95);
				g.lineTo(_minx + (100 * i), _mountainPoints[i]);
			}
			
			g.lineTo(_maxx, -80);
			g.lineTo(_maxx, _maxy);
			g.lineTo(_minx, _maxy);
			g.endFill();
			g.moveTo(_minx, 0);
			g.beginFill(0, 1);
			g.lineTo(_maxx, 0);
			g.lineTo(_maxx, _maxy);
			g.lineTo(_minx, _maxy);
			g.endFill();
    
        }
        
        //
        //
        //
        public function setExtents():void {
       
            _minx = 100000;
            _maxx = -100000;
            _miny = 100000;
            _maxy = -100000;
            
			var obj:CreatorPlayfieldObject;
			
            for (var i:int = 0; i < _objects.length; i++) {
                
				obj = CreatorPlayfieldObject(_objects[i]);
				
                _minx = Math.min(_minx, obj.x);
                _maxx = Math.max(_maxx, obj.x);
                
                _miny = Math.min(_miny, obj.y);
                _maxy = Math.max(_maxy, obj.y);
    
            }
			
			_minx -= 60 * 10;
			_maxx += 60 * 10;
			_miny -= 60 * 10;
			_maxy += 60 * 10;
            
            _width = _maxx - _minx;
            _height = _maxy - _miny;
            
            _centerx = (_minx + _maxx) / 2;
            _centery = (_miny + _maxy) / 2;
			
			setDefaultScale();
            
        }

        
        //
        //
        //
        public function redrawBounds ():void {
   
			createBounds();
            
        }
        
        
        //
        //
        //
        public function center ():void {
           
            navigator.focusMap(centerx, centery, _defaultScale * 2);
            
        }
        
        
        //
        //
        //
        public function setDefaultScale ():void {
            
            _defaultScale = _container.scaleX = _container.scaleY = 1;
            _defaultScale = Math.min((CreatorMain.mainStage.stageWidth - 190) / (width + 200), (CreatorMain.mainStage.stageHeight - 80) / (height + 200));
            
            if (navigator.defaultScale > _defaultScale) {
                navigator.zoomall.gotoAndStop(2);
                navigator.zoomout.gotoAndStop(2);
            }
            
            navigator.defaultScale = _defaultScale;
            navigator.minScale = Math.min(_defaultScale, 1);
            
        }
          
        
        //
        //
        //
        public function addObject (id:int, x:Number, y:Number, z:int = 0, rotation:Number = 0, tileID:int = 0, dataArray:Array = null, graphic:int = 0, graphic_version:int = 0, graphic_animation:int = 0):CreatorPlayfieldObject {
  
			var symbol:DisplayObject;
			
			symbol = CreatorFactory.createNew(id + "", null, 0, 0, 0, { tile: tileID }, (graphic > 0));
			
            var obj:CreatorPlayfieldObject = new CreatorPlayfieldObject(this, symbol, id, x, y, z, rotation, tileID, dataArray, graphic, graphic_version, graphic_animation);
			
			_objectsContainer.addChild(obj);
            _objects.push(obj);
			
			if (obj.id == 1) player = obj;
			
			if (!populating && !selection.copying) {
				setExtents();
				redrawBounds();
			}
			
			totalObjects++;
			
			map.register(obj);
			
			if (!populating && !selection.copying && (CreatorFactory.isTile(id + "") || CreatorFactory.isTextureBlock(id + ""))) obj.updateClip(true);
			
			if (!populating && !selection.copying) zSort();
            
            return CreatorPlayfieldObject(obj);
                
        }
        
        
        //
        //
        //
        public function removeObjects ():void {

			if (selection.objects.length > 0) {
				
				var selectedObjects:Array = selection.objects.concat();
				selection.selectNone();
				
				var obj:CreatorPlayfieldObject;
				var contains_tile:Boolean = false;
				var contains_textureblock:Boolean = false;
				
				if (selectedObjects != null)
				{
					if (selectedObjects.length == 1)
					{
						obj = selectedObjects[0];
						if (obj.graphic > 0) 
						{
							obj.resetSymbol();
						} else {
							if (!obj.permanent)
							{
								if (obj.tile) contains_tile = true;
								if (obj.textureAttribs != null) contains_textureblock = true;
								removeObject(obj, false, true);	
							}
						}
					
					} else {
						for each (obj in selectedObjects)
						{
							if (!obj.permanent)
							{
								if (obj.tile) contains_tile = true;
								if (obj.textureAttribs != null) contains_textureblock = true;
								removeObject(obj, false, true);	
							}
						}
					}
				}
				
				for (var i:int = 0; i < _objects.length; i++) 
				{
					obj = _objects[i];
					if (contains_tile && obj.tile) obj.updateClip();
					if (contains_textureblock && obj.textureAttribs != null) obj.updateClip();
				}
				
			}
			
        }
		
        //
        //
        //
        public function removeObject (obj:CreatorPlayfieldObject, force:Boolean = false, removingAll:Boolean = false):void {

			if (obj.id == 1 && !force) return;
			
			if (_objects.indexOf(obj) != -1) _objects.splice(_objects.indexOf(obj), 1);
			map.unregister(obj);
			
			if (obj.unique || obj.uniquegroup) Creator.mainInstance.objTray.updateAdders();
			
			obj.endClip();
			totalObjects--;
			
			selection.selectNone();
		
        }
        
        //
        //
        //
        public function checkValid (e:Event = null):Boolean {
            
			grid.graphics.clear();
            return true;
            
        }
		
		//
		//
		protected function onSelect (e:Event):void {
			
			if (selection.objects.length > 1) selectionPrompt.text = selection.objects.length + " objects selected";
			else if (selection.objects.length > 0) {
				if (selection.objects[0] is CreatorPlayfieldObject && CreatorPlayfieldObject(selection.objects[0]).tileID > 0) {
					selectionPrompt.text = "Selected tile texture is " + CreatorPlayfieldObject(selection.objects[0]).tileID;
				} else {
					selectionPrompt.text = selection.objects.length + " object selected";
				}
			} else selectionPrompt.text = "";
			
			if (selection.objects.length > 0 && CreatorPlayfieldObject(selection.objects[0]).textureAttribs != null) 
			{
				Creator.mainInstance.objTray.updateTextureAdders(CreatorPlayfieldObject(selection.objects[0]).textureAttribs.serialize(), CreatorPlayfieldObject(selection.objects[0]).tileBack);
			}

			if (_initialized && !populating) zSort();
			
		}
		
		//
		//
		protected function onDelete (e:SelectionEvent):void {
			
			if (e.object != null && e.object is CreatorPlayfieldObject) removeObject(e.object as CreatorPlayfieldObject);
			
		}
        
        //
        //
        //
        public function get creator ():Creator {
            
            return _parentClass;
            
        }
       
  
        //
        //
        //
        public function get width ():Number {
            
            return _width;
            
        }
    
        //
        //
        //
        public function get height ():Number {
            
            return _height;
            
        }
 
        //
        //
        //
        public function get minx ():Number {
            
            return _minx;
            
        }
        
        //
        //
        //
        public function get maxx ():Number {
            
            return _maxx;
            
        }
        
        //
        //
        //
        public function get miny ():Number {
            
            return _miny;
            
        }    
        
        //
        //
        //
        public function get maxy ():Number {
            
            return _maxy;
            
        }    
        
    
        //
        //
        //
        public function get centerx ():Number {
            
            return _centerx;
            
        }
        
        //
        //
        //
        public function get centery ():Number {
            
            return _centery;
            
        }    
        
        //
        //
        //
        public function get defaultScale ():Number {
            
            return _defaultScale;
            
        }     
    
        //
        //
        //
        public function get objects ():Array {
            
            return _objects;
            
        }  
		
		//
		//
		//
		public function zSort ():void {
			
			_container.setChildIndex(background, 0);
			_container.setChildIndex(grid, 1);
			_container.setChildIndex(_objectsContainer, 2);
			
			_objects.sortOn("zz", Array.NUMERIC);
			
			var i:int = _objects.length;
			
			while (i--) {
				_objectsContainer.setChildIndex(_objects[i], i);
			}
			
		} 
        
        //
        //
        //
        public static function getAngle (x1:Number, y1:Number, x2:Number, y2:Number):Number {
            
            var x:Number,
                y:Number,
                a:Number;
                
            x = x1 - x2;
            y = y1 - y2;
            
            if (x > 0) {
                a = (180/Math.PI) * Math.atan(y/x);
            } else if (x < 0) {
                a = ((180/Math.PI) * Math.atan(y/x)) - 180;
            } else {
                // prevent divide by zero
                a = (180/Math.PI) * Math.atan(y/0.00000000000000001);
            }
            
            //rotation = Math.floor(a);
            return a;
            
        }
        
        
        //
        //
        //
        public static function normalizeAngle (angle:Number):Number {
            
            angle %= 360;
            
            if (angle > 180) {
             angle -= 360 ;
            } else if (angle <= -180 ) {
             angle += 360;
            }
            
            return angle;
            
        }
    
        
        //
        //
        //
        public static function pointAtMouse (obj:CreatorPlayfieldObject):Number {
            
            var a:Number = getAngle(obj.parent.mouseX, obj.parent.mouseY, obj.x, obj.y);
            obj.rotation = Math.floor(a);
            return (Math.PI/180) * obj.rotation;
            
        }
    
        
        //
        //
        //
        public static function pointAtPoint (obj:CreatorPlayfieldObject, x:Number, y:Number):Number {
            
            var a:Number = getAngle(x, y, obj.x, obj.y);
            obj.rotation = Math.floor(a);
            return (Math.PI/180) * obj.rotation;
            
        }
        
        
        //
        //
        //
        public static function distanceBetween (obj1:MovieClip, obj2:MovieClip):Number {
    
            if (obj1._radius != undefined && obj2._radius != undefined) {
                
                return Math.abs(Math.sqrt(Math.pow(obj1.x - obj2.x, 2) + Math.pow(obj1.y - obj2.y, 2))) - obj1._radius - obj2._radius;
        
            } else {
                
                return Math.abs(Math.sqrt(Math.pow(obj1.x - obj2.x, 2) + Math.pow(obj1.y - obj2.y, 2)));
            }
            
        }
        
        
        //
        //
        //
        public static function angleBetween (obj1:MovieClip, obj2:MovieClip):Number {
    
            return getAngle(obj1.x, obj1.y, obj2.x, obj2.y);
            
        }
            
    }
}
