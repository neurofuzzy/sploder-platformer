package com.sploder.texturegen_internal 
{
	import com.adobe.crypto.MD5;
	import flash.display.BitmapData;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Geoff Gaudreault
	 */
	public class TextureRenderingCache 
	{
		private static var _cache:Dictionary;
		
		public static var queue:TextureRenderingQueue;
		
		public static function initialize ():void
		{
			if (_cache == null) _cache = new Dictionary();
		}
		
		
		public static function clearCache (dispose:Boolean = false):void
		{
			if (_cache == null) return;
			
			for (var hash:String in _cache)
			{
				var bd:BitmapData = _cache[hash];
				
				if (queue != null && queue.hasJobWithBitmapData(bd)) continue;
				
				try {
					if (dispose) bd.dispose();
				} catch (e:*) {
					
				}
			}
			
			_cache = null;
			initialize();
		}
		
		
		public static function getHash (attribs:TextureAttributes, size:int = 64, borderType:int = 0):String
		{
			return MD5.hash(attribs.serialize()) + "_" + size + "_" + borderType;
		}
		
		public static function hasTexture (attribs:TextureAttributes, size:int = 64, borderType:int = 0):Boolean
		{
			if (_cache == null) initialize();
			
			return _cache[getHash(attribs, size, borderType)] != null;
		}
		
		public static function getTexture (attribs:TextureAttributes, size:int = 64, borderType:int = 0):BitmapData
		{
			if (_cache == null) initialize();
			
			return _cache[getHash(attribs, size, borderType)];
		}
		
		public static function setTexture (bd:BitmapData, attribs:TextureAttributes, size:int = 64, borderType:int = 0):void
		{
			if (_cache == null) initialize();
			
			_cache[getHash(attribs, size, borderType)] = bd;
		}
		
	}

}