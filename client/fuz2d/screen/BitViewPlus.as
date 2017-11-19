/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.screen {

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.filters.ConvolutionFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import fuz2d.Fuz2d;
	import fuz2d.library.EmbeddedLibrary;
	import fuz2d.model.Model;
	import fuz2d.model.environment.Camera2d;
	import fuz2d.model.object.Biped;
	import fuz2d.model.object.Object2d;
	import fuz2d.model.object.Symbol;
	import fuz2d.model.object.Tile;
	import fuz2d.screen.shape.Background;
	import fuz2d.screen.shape.ScreenPoint;
	import fuz2d.screen.shape.ViewLayer;
	import fuz2d.screen.shape.ViewObject;
	import fuz2d.screen.shape.ViewSprite;
	import fuz2d.screen.shape.ViewTile;
	import fuz2d.util.OmniProximityGrid;
	import fuz2d.util.ReduceColors;
	import fuz2d.util.TileDefinition;
	import fuz2d.TimeStep;
	
	public class BitViewPlus extends View {
		
		protected const ZERO_POINT:Point = new Point(0, 0);
		protected function get layer ():ViewLayer { return _viewport as ViewLayer; }
		
		protected static var _pixelScale:uint = 1;
		static public function get pixelScale():uint { return _pixelScale; }
		static public function set pixelScale(value:uint):void 
		{
			_pixelScale = value;
			TileDefinition.scale = 1 / value * View.scale;
			EmbeddedLibrary.scale = View.scale / value;

		}
		
		override public function get bleed():Number { return _bleed / _pixelScale; }
		
		protected var origin:Point;
		protected var reg:Point;
		protected var m:Matrix;
		
		protected var _colorTransform:ColorTransform;
		protected var _rect:Rectangle;

		//
		//
		public function BitViewPlus (main:Object, model:Model, camera:Camera2d, viewRange:Number = 800, width:Number = 0, height:Number = 0, x:Number = 0, y:Number = 0, roughSort:Boolean = true, container:Sprite = null, pixelSnap:Boolean = false, fastDraw:Boolean = false, isMain:Boolean = false) {
	
			super(main, model, camera, viewRange, width, height, x, y, true, container, true, fastDraw, isMain);
			
		}
		
		//
		//
		override protected function init (main:Object, model:Model, camera:Camera2d, viewRange:Number = 800, width:Number = 0, height:Number = 0, x:Number = 0, y:Number = 0, container:Sprite = null, pixelSnap:Boolean = false, fastDraw:Boolean = false, isMain:Boolean = false):void {
			
			_main = main;
			_model = model;
			_container = container;
			_fastDraw = fastDraw;
			_isMain = isMain;
			
			register();
			
			_objectSprites = new Dictionary(true);
			_renderQueue = [];

			_camera = (camera != null) ? camera : new Camera2d();
			
			_width = _innerWidth = (width > 0) ? width : (mainStage.stageWidth < 240) ? 480 : mainStage.stageWidth;
			_height = _innerHeight = (height > 0) ? height : (mainStage.stageHeight < 240) ? 480 : mainStage.stageHeight;
			
			origin = new Point(_width * 0.5, _height * 0.5);
			reg = new Point();
			m = new Matrix();
			
			_colorTransform = new ColorTransform();
			_rect = new Rectangle();
			
			_viewGrid = new OmniProximityGrid(Math.ceil(_width / 2), Math.ceil(_height / 2));
			_visibleObjects = [];
			
			_anchor = new Sprite();
			_anchor.x = 0
			_anchor.y = 0;
			_anchor.name = "__anchor";
			
			if (_container == null) mainStage.addChild(_anchor);
			else _container.addChild(_anchor);
			
			_backdrop = new Sprite();
			_backdrop.scaleX = _backdrop.scaleY = View.scale;
			_backdrop.scrollRect = new Rectangle(0 - _width / 2, 0 - _height / 2, _width, _height);
			_backdrop.name = "_backdrop";
			
			_background = new Background(this, _backdrop);
			
			_pixelSnap = _camera.pixelSnap = true;
			
			_viewport = new ViewLayer(this);
			
			_viewport.screenPt = new ScreenPoint(0,0,1);
			
			_anchor.addChild(_viewport.dobj);	
			_anchor.focusRect = false;
			
			build();

			enabled = true;
			
		}
		
		override public function setViewSize(width:uint, height:uint, bleed:uint = 0):void {

			_bleed = (!isNaN(bleed)) ? bleed : _bleed;

			_width = (width > 0) ? width : (mainStage.scaleMode != StageScaleMode.NO_SCALE) ? _width : mainStage.stageWidth;
			_height = (height > 0) ? height : (mainStage.scaleMode != StageScaleMode.NO_SCALE) ? _height : mainStage.stageHeight;

			_innerWidth = _width;
			_innerHeight = _height;

			_viewGrid = new OmniProximityGrid(Math.ceil(_width / 2 + _bleed) / View.scale, Math.ceil(_height / 2 + _bleed) / View.scale);
			
			for each (var obj:Object2d in _model.objects) _viewGrid.register(obj);
			
			origin = new Point(_width * 0.5, _height * 0.5);
			
			layer.setSize(this);

			_backdrop.scrollRect = new Rectangle(0 - _innerWidth / 2 / View.scale, 0 - _innerHeight / 2 / View.scale, _innerWidth / View.scale, _innerHeight / View.scale);
			
			_background.redraw();
			
			
		}
		
		override public function checkChanged(e:Event = null, force:Boolean = false):void {
			
			if (!playing && !force) return;
			
			_camera.update();

			render();

		}
		
		override protected function render(object:Object2d = null):void {
			
			if (object != null) return;
			
			if (_background != null) _background.update();	
			
			Symbol.currentFrameCounter = Math.floor(TimeStep.realTime / 250);
				
			_oX = Math.floor(_camera.x / Model.GRID_WIDTH);
			_oY = Math.floor(_camera.y / Model.GRID_HEIGHT);
				
			if (_oX != _vX || _oY != _vY || _zSortQueued) {
				_vX = _oX;
				_vY = _oY;
				_visibleObjects = _viewGrid.getNeighborsOf(_camera, false, false);
				zSort();
				_zSortQueued = false;
			}

			var src:BitmapData;
			
			var b:BitmapData = layer.bitmapData;
			
			b.fillRect(b.rect, 0);

			reg.x = origin.x;
			reg.y = origin.y;
			reg.x -= Math.ceil(_camera.x * View.scale);
			reg.y += Math.ceil(_camera.y * View.scale);
			
			var loc:Point = new Point();
			
			var obj:Object2d;
			var vo:ViewObject;
			
			b.lock();
			
			m.a = m.d = View.scale / BitView.pixelScale;
			m.b = m.c = 0;
			m.tx = m.ty = 0;
				
			b.draw(_backdrop, m);
			
			var s1:Number = 1 / BitView.pixelScale;
			var s2:Number = m.d;
			
			var v:int = _visibleObjects.length;
			
			for (var i:int = 0; i < v; i++) {
				
				obj = _visibleObjects[i];
				
				if (_objectSprites[obj] != null) {

					vo = _objectSprites[obj];
					
					vo.updateGraphics();
					vo.updateLocation();
					
					var sp:ScreenPoint = vo.screenPt;
					
					if (sp != null) {
				
						loc.x = Math.round(reg.x * s1);
						loc.y = Math.round(reg.y * s1);
						loc.x += Math.ceil(sp.x * s2);
						loc.y += Math.ceil(sp.y * s2);
						
						if (obj is Tile) {
							src = Tile(obj).bitmapData;
						} else if (!obj.controlled) {
							src = Symbol(obj).bitmapData;
						}
						
						if ((!obj.controlled || obj is Tile) && (obj is Symbol && Symbol(obj).cacheAsBitmap)) {
							
							loc.x -= Math.ceil(src.rect.width * 0.5);
							loc.y -= Math.ceil(src.rect.height * 0.5);

							if (loc.x < b.width && loc.y < b.height &&
							loc.x + src.rect.width > 0 && loc.y + src.rect.height > 0) {
								
								b.copyPixels(src, src.rect, loc, null, null, true);
								
							}
							
						} else {
							
							if (vo.polygon && vo.polygon.cacheAsBitmap) {
								m.a = m.d = s2;
							} else {
								m.a = m.d = s2;
							}
							m.b = m.c = 0;
							m.tx = m.ty = 0;
							if (obj.rotation != 0) m.rotate(obj.rotation);
							m.translate(loc.x, loc.y);

							b.draw(vo.dobj, m);
						
						}
						
					}
				
				}
				
			}
			
			b.unlock();
		
		}
		
		//
		//
		//
		override public function zSort (viewNode:ViewObject = null):void {
			
			_visibleObjects.sortOn("zDepth", Array.NUMERIC);

		}

	}
	
}
