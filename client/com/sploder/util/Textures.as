package com.sploder.util 
{
	import com.sploder.util.ObjectEvent;
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Textures
	{
		public static const TEXTURE_REQUEST:String = "texture_request";
		protected static var _dispatcher:EventDispatcher;
		protected static var _textureCache:Object;
		protected static var _rectCache:Object;
		protected static var _m:Matrix;
		
		public static function getCacheKey (name:String, scale:int = 2, frame:uint = 0):String {
			return name + "_" + scale + "_" + frame;
		}
		
		public static function getOriginal (name:String):BitmapData {
			
			if (_textureCache == null) _textureCache = { };
			return _textureCache[name];
			
		}
		
		public static function setOriginal (name:String, bd:BitmapData):void {
			
			if (_textureCache == null) _textureCache = { };
			_textureCache[name] = bd;
			
		}
		
		public static function getScaledBitmapData (name:String, scale:int = 2, frame:uint = 0, obj:Object = null):BitmapData {
			
			var key:String = getCacheKey(name, scale, frame);
			
			if (_textureCache == null) _textureCache = { };
			else if (_textureCache[key] is BitmapData) return BitmapData(_textureCache[key]);
			
			var orig_bd:BitmapData;
			
			if (isLoaded(name)) {
				orig_bd = _textureCache[name];
			} else if (!isNaN(parseInt(name.charAt(0)))) {
				if (obj != null) dispatcher.dispatchEvent(new ObjectEvent(TEXTURE_REQUEST, false, false, obj)); 
				return null;
			}
			
			try {
				if (orig_bd) {
					
					var scaled_bd:BitmapData = new BitmapData(orig_bd.height * scale, orig_bd.height * scale, true, 0);
				
					if (_m == null) _m = new Matrix();
					
					_m.createBox(scale, scale, 0, 0, 0);
					_m.tx = 0 - orig_bd.height * scale * frame;
					
					/*
					if (flipped) {
						_m.scale( -1, 1);
						_m.translate(orig_bd.height * scale, 0);
					}
					*/
					
					scaled_bd.draw(orig_bd, _m);
					
					_textureCache[key] = scaled_bd;
					return scaled_bd;
					
				}
			} catch (e:Error) {
				trace("Textures:", e);
			}

			return null;
			
		}
		
		
		public static function addRectFor (name:String, key:String, rect:Rectangle):void {
			//trace("ADDING RECT", key, "FOR", name, rect);
			if (_rectCache == null) _rectCache = { };
			if (_rectCache[name] == null) _rectCache[name] = { };
			_rectCache[name][key] = rect;
		}
		
		public static function getRectsFor (name:String):Object {
			
			if (_rectCache == null) _rectCache = { };
			return _rectCache[name];
		}
		
		
		public static function getTrimmedRect (bd:BitmapData, x:int, y:int, width:int, height:int):Rectangle {
			
			var i:int;
			var s:uint;
			var n:int;
			var t:int;
			var top:int = 0;
			var left:int = 0;
			
			var r:Rectangle = new Rectangle(x, y, Math.min(width, bd.width - x), Math.min(height, bd.height - y));
			var w:int = r.width;
			var h:int = r.height;
			
			// top
			t = y;
			while (t < y + h - 1) {
				s = 0;
				for (n = x; n < x + w; n++) {
					s += bd.getPixel32(n, t);
				}
				if (s != 0) break;
				else t++;
			}
			
			top = t;
			
			// bottom
			t = y + h;
			while (t > y) {
				s = 0;
				for (n = x; n < x + w; n++) {
					s += bd.getPixel32(n, t);
				}
				if (s != 0) break;
				else t--;
			}
			
			h = t - top + 1;
			
			// left
			t = x;
			
			while (t < x + w - 1) {
				s = 0;
				for (n = top; n < top + h; n++) {
					s += bd.getPixel32(t, n);
				}
				if (s != 0) break;
				else t++;
			}
			
			
			left = t;
			
			// right
			t = x + w;
			
			while (t > x) {
				s = 0;
				for (n = top; n < top + h; n++) {
					s += bd.getPixel32(t, n);
				}
				if (s != 0) break;
				else t--;
			}
			w = t - left + 1;
			
			//trace(r.x, "=>", left, r.y, "=>", top, r.width, "=>", w, r.height, "=>", h);
			
			r.x = left;
			r.y = top;
			r.width = w;
			r.height = h;
			
			return r;
			
		}
		
		public static function isLoaded (name:String):Boolean {
			
			if (_textureCache == null) _textureCache = { };
			return (_textureCache[name] is BitmapData);
			
		}
		
		public static function addBitmapDataToCache (name:String, bd:BitmapData):void {
			
			if (_textureCache == null) _textureCache = { };
			_textureCache[name] = bd;
			
		}
		
		public static function cleanCache ():void {
			
			if (_textureCache) {
				
				for each (var bd:Object in _textureCache) {
					
					if (bd is BitmapData) BitmapData(bd).dispose();
					
				}
				
				_textureCache = { };
				
			}
			
		}
		
		static public function get dispatcher():EventDispatcher 
		{
			if (_dispatcher == null) _dispatcher = new EventDispatcher();
			return _dispatcher;
		}
		
	}

}