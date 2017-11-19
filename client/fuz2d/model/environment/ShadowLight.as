/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.model.environment {

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObjectContainer;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import fuz2d.action.play.PlayObject;
	import fuz2d.model.*;
	import fuz2d.model.object.*;
	import fuz2d.util.Map;
	
	
	public class ShadowLight extends OmniLight {
		
		override public function get width():Number { return _radius; }
		override public function set width(value:Number):void { super.width = value; }
		
		override public function get height():Number { return _radius; }
		override public function set height(value:Number):void { super.height = value; }
		
		protected var _map:Map;
		protected var _mapPadding:int = 10;
		public function get mapPadding():int { return _mapPadding; }
		
		protected var _originX:int;
		protected var _originY:int;
		public function get originX():int { return _originX; }
		public function get originY():int { return _originY; }
		
		protected var _isX:Number;
		protected var _isY:Number;
		
		protected var _shadowMapData:BitmapData;
		public function get shadowMapData():BitmapData { return _shadowMapData; }

		protected var _shadowMapMatrix:Matrix;
		protected var _shadowStrength:Number = 1;
		
		protected var _mapScale:int = 2;
		public function get mapScale():int { return _mapScale; }
		
		
		
		protected var _blurRect:Rectangle;
		
		
		//
		//
		public function ShadowLight (map:Map, brightness:Number = 1, color:uint = 0xffffff, shadowStrength:Number = 1, mapScale:uint = 2) {
			
			super(null, 0, 0, brightness, color);
		
			_map = map;
			_shadowStrength = shadowStrength;
			_mapScale = mapScale;
			
			createShadowMap();
			
		}
		
		//
		//
		protected function createShadowMap ():void {
			
			_originX = _map.minX;
			_originY = _map.minY;
			_isX = _isY = 1 / _map.size;
			
			var i:int;
			var j:int;
			var w:int = _map.width + _mapPadding * 2;
			var h:int = _map.height + _mapPadding * 2;
			w = Math.min(w, 2880 / _mapScale);
			h = Math.min(h, 2880 / _mapScale);
			
			var mapData:BitmapData = new BitmapData(w, h, false);
			var shadowData:BitmapData = new BitmapData(w, h, false);
			
			_blurRect = new Rectangle(0, 0, w, h);
			
			var free:Boolean = false;
			
			var lev:uint = Math.floor((1 - _shadowStrength) * 255);
			var shadowColor:uint = (lev << 16 | lev << 8 | lev);

			for (j = _originY; j < _map.height + _originY; j++) {
				
				for (i = _originX; i < _map.width + _originX; i++) {
					
					free = _map.isFree(i, j);
					if (!free)
					{
						var pobj:PlayObject = PlayObject(_map.objectAt(i, j));
						if (pobj != null && pobj.object != null && pobj.object.castShadow) {
							mapData.setPixel(_mapPadding + i - _originX, _mapPadding + j - _originY, shadowColor);
						}
					}
					
				}				
				
			}
			
			
			for (var s:int = 0; s < 7; s++) {
				
				shadowData.draw(mapData, null, null, BlendMode.MULTIPLY, _blurRect, false);		
				shadowData.applyFilter(shadowData, _blurRect, new Point(0, 0), new BlurFilter(8 - s, 8 - s, 2));
				shadowData.scroll(0, -1);
				
			}
			
			//shadowData.scroll(0, -1);
			
			//mapData.draw(mapData, null, null, BlendMode.INVERT, _blurRect, false);
			//shadowData.draw(mapData, null, null, BlendMode.SCREEN, _blurRect, false);
			
			mapData.fillRect(_blurRect, 0xffffff);
			
			var col:int;
			
			for (j = _originY - _mapPadding; j < 0; j++) {
				
				for (i = _originX - _mapPadding; i < _map.width + _originX + _mapPadding; i++) {
					
					col = Math.max(0, 255 + (32 * j - 1));
					col = col << 16 | col << 8 | col;
					mapData.setPixel(_mapPadding + i - _originX, _mapPadding + j - _originY, col);
					
				}				
				
			}
			
			shadowData.draw(mapData, null, null, BlendMode.MULTIPLY, _blurRect, false);
			
			mapData.dispose();
			
			_shadowMapData = new BitmapData(w * _mapScale, h * _mapScale, false);
			_shadowMapMatrix = new Matrix(_mapScale, 0, 0, _mapScale, 0, 0);
			_shadowMapData.draw(shadowData, _shadowMapMatrix, null, null, new Rectangle(0, 0, w * _mapScale, h * _mapScale), true);
			
			shadowData.dispose();
			
		}
		
		//
		//
		public function showMap (clip:DisplayObjectContainer):void {
			
			var b:Bitmap = new Bitmap(_shadowMapData);
			b.scaleY = -1;
			b.y = b.height;
			clip.addChild(b);
			
		}
		
		
		//
		//
		override public function update ():void {
			cast();
		}
		
		
		//
		//
		override public function getLightLevel (object:Object2d):Number {
		
			if ((!object.receiveShadow && object.y > 0) || object.material.self_illuminate) return _brightness;
			if (!object.receiveShadow) return Math.max(0, 1 * _brightness + (0.3 * ((object.y / Model.GRID_WIDTH))));
			
			var x:int = Math.floor(object.x * _isX * _mapScale) + (_mapPadding - _originX) * _mapScale;
			var y:int = Math.floor(object.y * _isY * _mapScale) + (_mapPadding - _originY) * _mapScale;
			
			var lightFactor:Number;
			
			x = Math.min(_shadowMapData.width - 1, Math.max(0, x));
			y = Math.min(_shadowMapData.height - 1, Math.max(0, y));
			
			lightFactor = (_shadowMapData.getPixel(x, y) >> 16);
			
			lightFactor *= _brightness;
			
			return Math.min(1, lightFactor / 255);
			
		}

		
		//
		//
		override public function destroy():void{

			_map = null;
			
			if (_shadowMapData) {
				_shadowMapData.dispose();
				_shadowMapData = null;
			}
			
			_shadowMapMatrix = null;
			
			super.destroy();
			
		}
		
	}
	
}