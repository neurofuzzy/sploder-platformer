/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2007 Geoffrey P. Gaudreault
* 
*/

package fuz2d.screen.shape {
	
	import flash.display.Sprite;
	import fuz2d.model.*;
	import fuz2d.model.environment.*;
	import fuz2d.model.object.*;
	import fuz2d.screen.*;
	import fuz2d.util.Faster;
	
	import fuz2d.util.Geom2d;
	
	import flash.display.Graphics;
	import flash.filters.ColorMatrixFilter;
	import flash.utils.*;

	public class Polygon {
		
		protected var _view:View;
		protected var _container:ViewSprite;
		protected var _screenPoints:Array;
		protected var _adjustedColor:uint = 0;

		protected var _drawingPoints:Array;
		
		protected var maxX:Number;
		protected var maxY:Number;
		
		protected var _cacheAsBitmap:Boolean = false;
		public function get cacheAsBitmap():Boolean { return _cacheAsBitmap; }
		
		//
		public function get container ():ViewSprite {
			return _container;
		}
		
		//
		public function get obj ():Object2d {
			return _container.objectRef;
		}
		
		//
		public function get drawingPoints ():Array {
			return _drawingPoints;
		}
		
		//
		public function get adjustedColor ():uint {
			
			var dist:Number = (_container.screenPt != null) ? _container.screenDist : 0;

			_adjustedColor = _view.model.environment.getAdjustedColor(_container.objectRef.computedColor, dist, _container.objectRef.y);
		
			return _adjustedColor;
			
		}

		//
		//
		public function Polygon (view:View, container:ViewSprite) {
			
			init(view, container);
			
		}
		
		//
		//
		protected function init (view:View, container:ViewSprite):void {
			
			_view = view;
			_container = container;

			maxX = maxY = 1400;
			draw(Sprite(_container.dobj).graphics);
			
		}
		
		//
		//
		public function setPoints ():Boolean {
			
			var o:Object2d = _container.objectRef;
			var c:Array = o.points;
			var i:uint = c.length;
			
			_screenPoints = [];
					
			if (i > 0) {
				
				//if (o.parentObject == null && o is Face) for each (var pt:Point2d in c) _view.screenPoints[pt] = _view.translate2d(pt);
				
			}

			while (i--) {
				if (c[i] is Point2d) {
					
					//_screenPoints.push(_view.screenPoints[c[i]]);

					//if (_screenPoints[_screenPoints.length - 1] == null) return false;

				}
			}

			return true;

		}
		
		//
		//
		public function redraw ():void {
			
			draw(Sprite(_container.dobj).graphics);
			
		}
		
		//
		//
		protected function draw(g:Graphics, clear:Boolean = true):void {
			
			
			
			if (clear) g.clear();
			
			if (setPoints()) {
				
				_drawingPoints = _screenPoints;
				
				var doLine:Boolean = true;
				
				var c:ViewSprite = _container;
				var i:uint;
				
				if (_drawingPoints.length > 2) {
			
					g.moveTo(_drawingPoints[0].x - c.screenPt.x, _drawingPoints[0].y - c.screenPt.y);

					g.beginFill(adjustedColor, _container.objectRef.material.opacity);
									
					for (i = 1; i < _drawingPoints.length; i++) {
						
						doLine = true;
						
						if (_container.objectRef is Face && Face(_container.objectRef).nodes != null) {
							doLine = Face(_container.objectRef).nodes.connectionAt(_drawingPoints[i-1].nodeIndex);
						}
						
						if (doLine) {
							g.lineTo(_drawingPoints[i].x - c.screenPt.x, _drawingPoints[i].y - c.screenPt.y);
						} else {
							g.moveTo(_drawingPoints[i].x - c.screenPt.x, _drawingPoints[i].y - c.screenPt.y);
						}
					
					}

					g.endFill();
					
				}
			
			}
			
		}
		
		//
		//
		public function clear ():void {
			
			Sprite(_container.dobj).graphics.clear();
			
		}
		
		//
		//
		public function destroy ():void {
			
			if (_container.dobj != null) Sprite(_container.dobj).graphics.clear();

		}
		
	}
	
}
