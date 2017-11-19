package fuz2d.model.object {
	
	import com.sploder.util.Textures;
	import flash.display.*;
	import flash.geom.Matrix;
	import fuz2d.library.ObjectFactory;
	import fuz2d.model.ModelEvent;
	import fuz2d.screen.View;
	
	import fuz2d.library.EmbeddedLibrary;
	import fuz2d.model.material.Material;
	
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class Symbol extends Object2d {
		
		protected var _initialized:Boolean = false;
		
		protected var _library:EmbeddedLibrary;
		public function get library():EmbeddedLibrary { return _library; }
		
		protected var _symbolExists:Boolean = false;
		public function get symbolExists():Boolean { return _symbolExists; }
		
		protected var _cacheAsBitmap:Boolean = false;
		public function get cacheAsBitmap():Boolean { return _cacheAsBitmap; }

		protected var _bitmapData:BitmapData;
		protected var _bitmapDataFrame:String;
		public function get bitmapData():BitmapData {
			if (symbolName == null || symbolName.length == 0) return null;
			if (graphic_animation && (totalFrames == 0 || currentFrame != currentFrameCounter % totalFrames)) _bitmapData = null;
			if (_bitmapData == null || (_isMovieClip && _bitmapDataFrame != _state)) {
				if (graphic > 0) getGraphicBitmapData();
				else if (!_isMovieClip) _bitmapData = _library.getDisplayObjectBitmapData(_symbolName, "", null, _rotation);
				else {
					_bitmapDataFrame = _state;
					_bitmapData = _library.getMovieClipBitmapData(_symbolName, _state);
				}
			}
			return _bitmapData;
		}
		
		protected var currentFrame:int = 0;
		protected var totalFrames:int = 0;
		public static var currentFrameCounter:int = 0;

		protected var _state:String = "";
		public function get state():String { return _state; }
		public function set state(value:String):void { 
			_state = value;
			if (_model) _model.dispatchEvent(new ModelEvent(ModelEvent.UPDATE, false, false, this));
		}
		
		protected var _isMovieClip:Boolean = false;
		public function get isMovieClip():Boolean { return _isMovieClip; }
		
		protected var _symbolWidth:Number;
		public function get symbolWidth():Number { return _symbolWidth; }
		
		protected var _symbolHeight:Number;
		public function get symbolHeight():Number { return _symbolHeight; }
		
		override public function get scale():Number { return super.scale; }
		
		override public function set scale(value:Number):void 
		{
			super.scale = value;
			_scaleX = _scaleY = value;
		}
		
		public var fail:Boolean = false;
		
		override public function set symbolName(val:String):void {
			
			var isNew:Boolean = (val != _symbolName);
				
			_symbolName = val;
			
			if (isNew) initSymbol();
			
		}

		public var alwaysOnTop:Boolean = false;
		
		public function Symbol(symbolName:String, library:EmbeddedLibrary, material:Material = null, parentObject:Point2d = null, x:Number = 0, y:Number = 0, z:Number = 0, rotation:Number = 0, scaleX:Number = 1, scaleY:Number = 1, cacheAsBitmap:Boolean = false, castShadow:Boolean = true, receiveShadow:Boolean = true, controlled:Boolean = false, overlay:Boolean = false, rectnames:Array = null) {
			
			super(parentObject, x, y, z, rotation, scale, material, "", controlled);
			
			_symbolName = symbolName;
			_library = library;
			_cacheAsBitmap = cacheAsBitmap;
			
			_renderable = true;
			
			_scaleX = scaleX;
			_scaleY = scaleY;

			this.castShadow = castShadow;
			this.receiveShadow = receiveShadow;
			
			initSymbol();
			
			if (overlay) ObjectFactory.effect(this, symbolName.split("_")[0] + "overlay", false, 195, point, _rotation);
			this.graphic_rectnames = rectnames;
			
		}
		
		protected function initSymbol ():void {
			
			var sym:DisplayObject = clip;
			
			if (sym != null) {

				_symbolExists = true;
				
				_isMovieClip = (sym is MovieClip && MovieClip(sym).totalFrames > 1);
				
				var textureScale:Number = 1;
				
				
				if (symbolName.length > 0 && sym["texture"] != undefined) {
					textureScale = Sprite(sym["texture"]).scaleX;
					Sprite(sym["texture"]).scaleX = 0.01;
					Sprite(sym["texture"]).scaleY = 0.01;
				}
				
				_symbolWidth = sym.width * _scaleX;
				_symbolHeight = sym.height * _scaleY;
				
				if (symbolName.length > 0 && sym["bounds"] != null) {
					
					_width = Sprite(sym["bounds"]).width * _scaleX;
					_height = Sprite(sym["bounds"]).height * _scaleY;

				} else {
					
					_width = _symbolWidth;
					_height = _symbolHeight;
					
				}
				
				if (symbolName.length > 0 && sym["texture"] != undefined) {
					Sprite(sym["texture"]).scaleX = textureScale;
					Sprite(sym["texture"]).scaleY = textureScale;
				}
				
				_initialized = true;
				
			} else {

				_width = _height = 0;
				fail = true;
				
			}
			
			
			
		}
		
		public function get clip ():Sprite {
			
			if (symbolName == null || symbolName.length == 0) return new Sprite();
			if (graphic > 0)
			{
				var s:Sprite = _library.getDisplayObject(symbolName + "_graphic") as Sprite; 
				if (s != null) return s;
			}
			return _library.getDisplayObject(symbolName) as Sprite;
			
		}
		
		public function get clipAsBitmap ():Bitmap {
			
			if (symbolName == null || symbolName.length == 0) return new Bitmap();
			return _library.getDisplayObjectAsBitmap(symbolName);
			
		}
		
		protected function getGraphicBitmapData ():void {
			
			if (_initialized) {
				
				if (graphic > 0)
				{
					
					var size:String = Math.floor(_width) + "_" + Math.floor(_height);
					var texture_name:String = graphic + "_" + graphic_version;
					
					if (graphic_animation)
					{
						if (totalFrames == 0) 
						{
							var orig_frames:BitmapData = Textures.getOriginal(texture_name);
							if (orig_frames != null) totalFrames =  orig_frames.width / orig_frames.height;
							else trace("ORIGINAL NOT FOUND");
						}
						if (totalFrames > 0)
						{
							currentFrame = currentFrameCounter % totalFrames;
							size += "_" + currentFrame;
						}
					}
					
					_bitmapData = Textures.getOriginal("bitview_" + texture_name + "_" + size);
					
					if (_bitmapData != null) return;
					
					var orig_bd:BitmapData = Textures.getScaledBitmapData(texture_name, 8, currentFrame);
					
					if (orig_bd != null)
					{
						var m:Matrix = new Matrix();
						m.createBox(_width / orig_bd.width * EmbeddedLibrary.scale , _height / orig_bd.height * EmbeddedLibrary.scale );
						
						_bitmapData = new BitmapData(_width * EmbeddedLibrary.scale , _height * EmbeddedLibrary.scale , true, 0);
						_bitmapData.draw(orig_bd, m, null, null, null, true);
						Textures.setOriginal("bitview_" + texture_name + "_" + size, _bitmapData);
					}
					
					return;
					
				}
				
			}
			
		}
		
		override public function set moved(value:Boolean):void  {
			
			super.moved = value;
			if (_moved) update();
			
		}
		
		override public function set turned(value:Boolean):void	{
			
			super.turned = value;
			if (_turned) update();
			
		}
		
		override public function set z(value:Number):void 
		{
			var oldz:Number = _z;
			super.z = value;
			if (_z != oldz) {
				_model.dispatchEvent(new ModelEvent(ModelEvent.ZCHANGE));
			}
		}
		
		override public function destroy():void 
		{
			if (frozen) return;
			
			super.destroy();
			
			_bitmapData = null;
			_library = null;
			
		}

	}
	
}