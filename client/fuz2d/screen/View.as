/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.screen {
	
	import flash.display.BlendMode;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.StageScaleMode;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.media.Microphone;
	import fuz2d.*;
	import fuz2d.action.control.*;
	import fuz2d.library.EmbeddedLibrary;
	import fuz2d.model.*;
	import fuz2d.model.environment.*;
	import fuz2d.model.object.*;
	import fuz2d.screen.effect.*;
	import fuz2d.screen.shape.*;
	import fuz2d.util.*;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	public class View {
		
		public static const SCALE:String = "scale";
		
		public static var mainStage:Stage;
		public static var frameRate:uint;
		
		protected var _main:Object;
		protected var _container:Sprite;
		
		protected var _viewGrid:OmniProximityGrid;
		protected var _visibleObjects:Array;
		
		protected var _model:Model;
		protected var _camera:Camera2d;

		protected var _anchor:Sprite;
		protected var _backdrop:Sprite;
		protected var _viewport:ViewObject;

		protected var _pixelSnap:Boolean;
		public function get pixelSnap():Boolean { return _pixelSnap; }
		
		protected var _fastDraw:Boolean;
		public function get fastDraw():Boolean { return _fastDraw; }
		
		protected var _background:Background;
		
		protected var _originX:Number;
		protected var _originY:Number;
		
		protected static var _scale:Number = 1;
		public static function get scale():Number { return _scale; }
		public static function set scale(value:Number):void 
		{
			var gridScale:Number = Math.floor(Model.GRID_WIDTH * value);
			if (gridScale % 2 != 0) gridScale += 1;
			
			_scale = gridScale / Model.GRID_WIDTH;
			
			EmbeddedLibrary.scale = TileDefinition.scale = _scale;
			
		}
		
		protected var _width:Number;
		public function get width ():Number { return _width; }
		protected var _height:Number;
		public function get height ():Number { return _height; }
		protected var _bleed:Number = 0;
		public function get bleed():Number { return _bleed; }
		
		protected var _innerWidth:int;
		public function get innerWidth():int { return _innerWidth; }
		
		protected var _innerHeight:int;
		public function get innerHeight():int { return _innerHeight; }
		
		public var extentX:Number;
		public var extentY:Number;
		
		protected var _oX:int;
		protected var _oY:int;
		protected var _vX:int;
		protected var _vY:int;
		
		protected var _zSortQueued:Boolean = false;
		
		protected var _objectSprites:Dictionary;
		protected var _renderQueue:Array;
		
		public function get objectSprites ():Dictionary { return _objectSprites; }
		
		public var numSprites:uint;

		protected var _updater:MovieClip;
	
		
		public function get model ():Model { return _model; }
		public function get camera ():Camera2d { return _camera; }
		public function get stage ():Stage { return mainStage; }
		public function get viewport ():ViewObject { return _viewport; }
		
		
		protected var _enabled:Boolean = true;
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void { 
			_enabled = value; 
			
			if (_enabled) {
				mainStage.addEventListener(Event.ENTER_FRAME, checkChanged, false, 3, true);
			} else {
				mainStage.removeEventListener(Event.ENTER_FRAME, checkChanged);
			}
		
		}
		
		protected var _isMain:Boolean = false;
		public function get isMain():Boolean { return _isMain; }
		
		private var _playing:Boolean = true;
		
		public function get playing ():Boolean {
			
			if (_main.playfield != null && !_main.playfield.playing) {
				
				if (_playing == true) {
					_playing = false;
					toggleSpritesPlaying(_playing);
				}
				
				return false;
			}
			
			if (_playing == false) {
				_playing = true;
				toggleSpritesPlaying(_playing);
			}
			
			return true;
			
		}
		
		public function get container():Sprite { return _anchor; }
		
		public function get background():Background { return _background; }
	
		
		//------------------
		
		//
		//
		public function View (main:Object, model:Model, camera:Camera2d, viewRange:Number = 800, width:Number = 0, height:Number = 0, x:Number = 0, y:Number = 0, roughSort:Boolean = true, container:Sprite = null, pixelSnap:Boolean = false, fastDraw:Boolean = false, isMain:Boolean = false) {
	
			init(main, model, camera, viewRange, width, height, x, y, container, pixelSnap, fastDraw, isMain);
			
		}
		
		//
		//
		protected function init (main:Object, model:Model, camera:Camera2d, viewRange:Number = 800, width:Number = 0, height:Number = 0, x:Number = 0, y:Number = 0, container:Sprite = null, pixelSnap:Boolean = false, fastDraw:Boolean = false, isMain:Boolean = false):void {
			
			_main = main;
			_model = model;
			_container = container;
			_pixelSnap = pixelSnap;
			_fastDraw = fastDraw;
			_isMain = isMain;
			
			register();
			
			_objectSprites = new Dictionary(true);
			_renderQueue = [];

			_camera = (camera != null) ? camera : new Camera2d();
			
			_width = _innerWidth = (width > 0) ? width : (mainStage.stageWidth < 240) ? 480 : mainStage.stageWidth;
			_height = _innerHeight = (height > 0) ? height : (mainStage.stageHeight < 240) ? 480 : mainStage.stageHeight;
			
			_originX = extentX = _width * 0.5;
			_originY = extentY = _height * 0.5;
			
			_originX *= View.scale;
			_originY *= View.scale;
			
			_viewGrid = new OmniProximityGrid(Math.ceil(_width / 2), Math.ceil(_height / 2));
			_visibleObjects = [];
			
			_anchor = new Sprite();
			_anchor.x = _originX;
			_anchor.y = _originY;
			_anchor.scaleX = _anchor.scaleY = scale;
			_anchor.name = "__anchor";
			
			if (_container == null) mainStage.addChild(_anchor);
			else _container.addChild(_anchor);
			
			_backdrop = new Sprite();
			_backdrop.x = 0;
			_backdrop.y = 0;
			_backdrop.name = "_backdrop";
			
			_backdrop.x = 0 - _width / 2;
			_backdrop.y = 0 - _height / 2;
			_backdrop.scrollRect = new Rectangle(0 - _width / 2, 0 - _height / 2, _width, _height);
	
			_background = new Background(this, _backdrop);
			
			_anchor.addChild(_backdrop);
			
			_camera.pixelSnap = _pixelSnap;
			
			_viewport = new ViewSprite(this);
			_viewport.dobj.x = 0;
			_viewport.dobj.y = 0;
			_viewport.dobj.scrollRect = new Rectangle(0 - _width / 2, 0 - _height / 2, _width, _height);

			_viewport.screenPt = new ScreenPoint(0,0,1);
			
			_anchor.addChild(_viewport.dobj);	
			_anchor.focusRect = false;
			
			build();

			enabled = true;
			
		}
		
		//
		//
		public function setViewSize (width:uint, height:uint, bleed:uint = 0):void {
			
			_bleed = (!isNaN(bleed)) ? bleed : _bleed;
			
			_width = (width > 0) ? width + _bleed + _bleed : (mainStage.scaleMode != StageScaleMode.NO_SCALE) ? _width + _bleed + _bleed : mainStage.stageWidth + _bleed + _bleed;
			_height = (height > 0) ? height + _bleed + _bleed : (mainStage.scaleMode != StageScaleMode.NO_SCALE) ? _height + _bleed + _bleed : mainStage.stageHeight + _bleed + _bleed;
			
			_innerWidth = _width - _bleed - _bleed;
			_innerHeight = _height - _bleed - _bleed;
			_innerWidth /= View.scale;
			_innerHeight /= View.scale;
			
			_viewGrid = new OmniProximityGrid(Math.ceil(_width / 2) / View.scale, Math.ceil(_height / 2) / View.scale);
			
			for each (var obj:Object2d in _model.objects) _viewGrid.register(obj);
			
			_originX = extentX = _width * 0.5;
			_originY = extentY = _height * 0.5;
			
			_originX *= View.scale;
			_originY *= View.scale;
			
			_anchor.x = _originX;
			_anchor.y = _originY;

			//_anchor.scaleX = _anchor.scaleY = View.scale * scale;
			
			extentX += bleed;
			extentY += bleed;

			_backdrop.x = 0;
			_backdrop.y = 0;
			
			_backdrop.x -= _width / 2;
			_backdrop.y -= _height / 2;
			
			_viewport.dobj.x = _backdrop.x;
			_viewport.dobj.y = _backdrop.y;
			
			_backdrop.scrollRect = new Rectangle(0 - _innerWidth / 2, 0 - _innerHeight / 2, _innerWidth, _innerHeight);
			_viewport.dobj.scrollRect = new Rectangle(0 - _innerWidth / 2, 0 - _innerHeight / 2, _innerWidth, _innerHeight);
			
			_background.redraw();

		}
		
		//
		//
		public function onScale (e:Event):void {
			
			
		}
		
		//
		//
		public function register ():void {
			
			if (_model) {
				_model.addEventListener(ModelEvent.CREATE, update, false, 0, true);
				_model.addEventListener(ModelEvent.UPDATE, update, false, 0, true);
				_model.addEventListener(ModelEvent.DELETE, update, false, 0, true);
			}
			
		}
		
		//
		//
		public function unregister ():void {
		
			if (_model) {
				_model.removeEventListener(ModelEvent.CREATE, update);
				_model.removeEventListener(ModelEvent.UPDATE, update);
				_model.removeEventListener(ModelEvent.DELETE, update);
			}
			
		}		
		
		//
		//
		//
		protected function build ():void {
			
			buildNode(_viewport, model.objects);
			zSort(_viewport);
			
		}
		
		//
		//
		protected function buildNode (parentVS:ViewObject, c:Array):void {
			
			var child:Object2d;
			var childVS:ViewObject;

			var i:uint = c.length;
			
			while (i--) {
				
				if (c[i] is Object2d) {
					
					child = c[i];
					
					if (child.renderable) {
						childVS = addSprite(parentVS, child);
						if (childVS == null) return;
					}
					
					if (!child.ignoreChildNodes) {
						if (child.childObjects.length > 0) {
							arguments.callee(childVS, child.childObjects);
						}
					}
					
				}
				
			}
			
			zSort(parentVS);			
			
		}
		
		//
		//
		protected function addSprite (parentVS:ViewObject, childObject:Object2d):ViewObject {
			
			var childVS:ViewObject;
			
			if (childObject is Tile) {
				childVS = new ViewTile(this, parentVS, childObject);
			} else {
				childVS = new ViewSprite(this, parentVS, childObject);
			}
			
			_viewport.addChildNode(childVS);
			_viewGrid.register(childObject);
			
			childVS.updateLocation();
			childVS.updateGraphics();
			checkBounds(childVS);
			
			_objectSprites[childObject] = childVS;
			numSprites++;
			
			return childVS;
			
		}
		
		//
		//
		public function removeSprite (vs:ViewObject):void {
			if (vs.parentNode != null) {
				if (vs.parentNode.removeChildNode(vs)) numSprites--;
			} else {
				if (_viewport.removeChildNode(vs)) numSprites--;
			}
			
			delete _objectSprites[vs];
		}
		
		//
		//
		public function checkChanged (e:Event = null, force:Boolean = false):void {
				
			if (!playing && !force) return;
	
			_camera.update();

			if (!_fastDraw) {
				_model.environment.update();
			}
			
			// update camera view
			
			var r:Rectangle = _viewport.dobj.scrollRect;
			r.x = _camera.x - _innerWidth * 0.5;
			r.y = 0 - _camera.y - _innerHeight * 0.5;
			_viewport.dobj.scrollRect = r;
			
			if (_background != null) _background.update();	
				
			_oX = Math.floor(_viewport.dobj.scrollRect.x / Model.GRID_WIDTH);
			_oY = Math.floor(_viewport.dobj.scrollRect.y / Model.GRID_HEIGHT);
			
			if (_oX != _vX || _oY != _vY || _zSortQueued) {
				_vX = _oX;
				_vY = _oY;
				_visibleObjects = _viewGrid.getNeighborsOf(_camera, false, false);
				
				zSort();
				_zSortQueued = false;
			}

			var v:int = _visibleObjects.length;
		
			for (var i:int = 0; i < v; i++) render(Object2d(_visibleObjects[i]));

			_camera.changed = false;

		}
		
		//
		//
		protected function checkBounds (vs:ViewObject):Boolean {
			
			if (vs == null) return false;
			
			if (vs.screenPt == null || Math.abs(vs.screenPt.x - _camera.x) > extentX || Math.abs(vs.screenPt.y + _camera.y) > extentY) {

				vs.hide();
				return false;
				
			} 
			
			vs.show();
			return true;
	
		}
		
		
		//
		//
		protected function update (e:ModelEvent = null):void {

			if (e == null || e.object == null) return;
			
			var type:String = e.type;

			switch (type) {
				
				case ModelEvent.CREATE:
			
					var parentVS:ViewObject = _viewport;

					buildNode(parentVS, [e.object]);
					updateObject(e.object);
					_visibleObjects.push(e.object);
			
					break;
				
				case ModelEvent.DELETE:
				
					removeObject(e.object);
					break;
				
				case ModelEvent.UPDATE:
				default:
			
					if (e.object is OmniLight) {
						render();
					} else {
						updateObject(e.object);
					}
					
					break;
					
				case ModelEvent.ZCHANGE:
				
					updateObject(e.object, false, true);
		
			}
			
		}
		
		//
		//
		public function updateObject (object:Object2d, deleted:Boolean = false, force:Boolean = false):void {
			
			if (!deleted) {
				if (force || _viewGrid.update(object)) _zSortQueued = true;
				if (force) {
					var vs:ViewObject = _objectSprites[object] as ViewObject;
					if (vs) vs.updateLocation();
				}
			} else {
				removeObject(object);
			}
	
		}
		
		//
		//
		protected function removeObject (object:Object2d):void {
			
			if (_objectSprites[object] != null) ViewObject(_objectSprites[object]).destroy();
			if (_visibleObjects.indexOf(object) != -1) _visibleObjects.splice(_visibleObjects.indexOf(object), 1);
			_viewGrid.unregister(object);
			
			delete _objectSprites[object];
			
		}
		
		//
		//
		public function forceRender ():void {
			_vX = _vY = NaN;
			render();
		}
		
		//
		//
		protected function render (object:Object2d = null):void {
			
			if (object == null) return;
			
			var viewNode:ViewObject = _objectSprites[object];
			if (viewNode == null) return;
			
			viewNode.updateLocation();
			
			if (checkBounds(viewNode)) {
				
				viewNode.updateGraphics();
				
			}
			
		}
		
		/**
		 * Method: translate2d
		 * Takes a 2d point and returns a 2d point based on the current camera location
		 * @param	pt2d The 2d point to translate
		 * @return  A ScreenPoint object with the translated x and y screen coordinates
		 */
		public function translate2d (pt2d:Object, oldScreenPoint:ScreenPoint = null):ScreenPoint {

			if (pt2d == null) return null;
			
			var newx:Number = pt2d.x;
			var newy:Number = 0 - pt2d.y;
			var newscale:Number = 1;
			
			// if (Faster.abs(newx - _camera.x) > extentX || Faster.abs(newy + _camera.y) > extentY) return null;
	
			if (_pixelSnap) {
				
				newx = Math.round(newx);
				newy = Math.round(newy);
				
			}
			
			if (oldScreenPoint == null) {

				var ns:ScreenPoint = new ScreenPoint(newx, newy, newscale);	
				return ns;		
			
			} else {

				oldScreenPoint.x = newx;
				oldScreenPoint.y = newy;
				oldScreenPoint.scale = newscale;
				
				return oldScreenPoint;
				
			}
			
		}
		
		
		//
		//
		//
		public function zSort (viewNode:ViewObject = null):void {
			
			if (viewNode == null) viewNode = _viewport;
			
			viewNode.childNodes.sortOn("screenDist", Array.NUMERIC);
			
			if (viewNode.dobj is Sprite) {
				
				var s:Sprite = viewNode.dobj as Sprite;
				
				var len:int = s.numChildren;
				var i:int = 0;
				
				//s.removeChildren(0, s.numChildren - 1);
				//while (s.numChildren > 0) s.removeChildAt(0);
				
				while (i < len) 
				{
					//if (viewNode.childNodes[i] != null) s.addChild(viewNode.childNodes[i].dobj);
					if (viewNode.childNodes[i] != null) s.setChildIndex(viewNode.childNodes[i].dobj, i);
					
					i++;
				}
				
			}
			
		}
		
		//
		//
		private function toggleSpritesPlaying (playing:Boolean):void {
			
			_visibleObjects = _viewGrid.getNeighborsOf(_camera, false, false, _visibleObjects);
			
			for each (var obj:Object2d in _visibleObjects) {
				
				var viewNode:ViewObject = _objectSprites[obj];
				
				if (viewNode != null) {

					viewNode.playing = playing;
				
				}
				
			}
			
		}
		
		public function end ():void {
			
			unregister();
			
			enabled = false;
			
			for each (var vo:ViewObject in _objectSprites) {
				vo.destroy();
			}
			
			_objectSprites = null;
			_visibleObjects = null;
			_renderQueue = null;

			if (_backdrop && _backdrop.parent) _backdrop.parent.removeChild(_backdrop);
			if (_viewport && _viewport.dobj && _viewport.dobj.parent) _viewport.dobj.parent.removeChild(_viewport.dobj);
			if (_anchor && _anchor.parent) _anchor.parent.removeChild(_anchor);
			
			if (_viewGrid) {
				_viewGrid.end();
				_viewGrid = null;
			}
			
			if (_background) _background.end();
			
			_background = null;
			_model = null;
			_camera = null;
			
			if (_updater && _updater.parent) _updater.parent.removeChild(_updater);
			
			_backdrop = null;
			
			if (_viewport && _viewport.dobj && _viewport.dobj is Sprite) {
				var d:Sprite = Sprite(_viewport.dobj);
				var i:uint = d.numChildren;
				while (i--) d.removeChildAt(i);
			}
			
			_viewport = null;
			_anchor = null;
			
		}
		
	}
	
}
