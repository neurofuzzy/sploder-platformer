/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.screen.effect {

	import flash.display.BitmapDataChannel;
	import flash.display.Sprite;
	import flash.filters.BitmapFilter;
	import flash.filters.GlowFilter;
	import fuz2d.screen.shape.ViewSprite;
	import fuz2d.screen.View;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Graphics;
	
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.ColorTransform;
	
	
	public class Halo {
		
		private var _clip:Sprite;
		private var _created:Boolean = false;
		private var _active:Boolean = false;
		
		private var _width:int;
		private var _height:int;
		
		private var _effect:Sprite;
		private var _sourceBMP:BitmapData;
		private var _midBMP:BitmapData;
		private var _effectBMP:BitmapData;
		private var _effectImage:Bitmap;
		private var _effectMatrix:Matrix;
		private var _effectColorTransform:ColorTransform;
		private var _sourceClipRect:Rectangle;
		private var _effectClipRect:Rectangle;
		
		private var _scaleFactor:int = 3;
		
		private var _redArray:Array;
		private var _greenArray:Array;
		private var _blueArray:Array;
		private var _alphaArray:Array;
		
		private var _matrix:Array;
		
		private var _view:View;
		
		private var _border:Sprite;
		
		private var _cameraX:Number;
		private var _cameraY:Number;
		
		private var _render:Boolean = true;
		private var _renderSkip:int = 0;
		
		private var _origin:Point;
			
		public function Halo(clip:Sprite, view:View) {
			
			if (clip != null) {
				
				_clip = clip;
				_view = view;
				
				if (_clip.parent != null) {
				
					_effect = new Sprite();
					_effect.name = "__effectLayer";
					_clip.parent.addChild(_effect);
					
					_width = Math.ceil((_view.innerWidth) / _scaleFactor);
					_height = Math.ceil((_view.innerHeight) / _scaleFactor);
					
					_origin = new Point(0, 0);

					create();
					
				}
				
			}
			
		}
		
		//
		//
		//
		protected function create ():void {
			
			if (_sourceBMP == null) {
		
				_sourceBMP = new BitmapData(_width * View.scale, _height * View.scale, false, 0x666666);
				_midBMP = new BitmapData(_width * View.scale, _height * View.scale, true, 0x000000);
				_effectBMP = new BitmapData(_width * View.scale, _height * View.scale, true, 0x000000);
				
				_sourceClipRect = new Rectangle(0, 0, _width * View.scale, _height * View.scale);
				_effectClipRect = new Rectangle(0, 0, _width * View.scale, _height * View.scale);

				_effectMatrix = new Matrix(1 / _scaleFactor * View.scale, 0, 0, 1 / _scaleFactor * View.scale, _view.width / (_scaleFactor * 2) * View.scale, _view.height / (_scaleFactor * 2) * View.scale);
				_effectImage = new Bitmap(_effectBMP, "auto", false);
				_effectImage.blendMode = BlendMode.ADD;
				
				_effect.addChild(_effectImage);
				_effectImage = new Bitmap(_effectBMP, "auto", false);
				_effectImage.blendMode = BlendMode.ADD;
				
				_effect.addChild(_effectImage);
				_effect.scaleX = _effect.scaleY = _scaleFactor;
				_effect.blendMode = BlendMode.ADD;
				
				_redArray = new Array(256);
				_greenArray = new Array(256);
				_blueArray = new Array(256);
				_alphaArray = new Array(256);
				
				_matrix = new Array();
				_matrix = _matrix.concat([0.75, 0, 0, 0, 0]); // red
				_matrix = _matrix.concat([0, 0.8, 0, 0, 0]); // green
				_matrix = _matrix.concat([0, 0, 0.85, 0, 0]); // blue
				_matrix = _matrix.concat([0, 0, 0, 1, 0]); // alpha

				var i:uint;
				
				for (i = 0; i < 255; i++) {
					
					_redArray[i] = 0x00000000;
					_greenArray[i] = 0x00000000;
					_blueArray[i] = 0x00000000;
					_alphaArray[i] = 0x66000000;
					
				}
				
				for (i = 245; i <= 255; i++) {
					
					_redArray[i] = 0xFFFF0000;
					_greenArray[i] = 0xFF00FF00;
					_blueArray[i] = 0xFF0000FF;
					
				}

				_created = true;
				_active = true;
				
				_cameraX = _view.camera.x;
				_cameraY = _view.camera.y;
				
				_border = new Sprite();
				_clip.addChild(_border);
				
				var g:Graphics = _border.graphics;
				
				g.lineStyle(_scaleFactor * 2, 0x000000, 1);
				g.moveTo(0 - _view.width * 0.5, 0 - _view.height * 0.5);
				g.lineTo(_view.width * 0.5 - _view.bleed * 2, 0 - _view.height * 0.5);
				g.lineTo(_view.width * 0.5 - _view.bleed * 2, _view.height * 0.5 - _view.bleed * 2);
				g.lineTo(0 - _view.width * 0.5, _view.height * 0.5 - _view.bleed * 2);
				g.lineTo(0 - _view.width * 0.5, 0 - _view.height * 0.5);
				
				_border.filters = [new BlurFilter(10, 10)];
				_border.visible = false;
				
				draw();
				
			}			
			
		}
		
		//
		//
		//
		public function draw (points:Array = null, container:ViewSprite = null, graphics:Graphics = null):void {
			
			if (_created && _active) {
				
				if (_sourceBMP != null) {

					// flicker
					_effectImage.alpha = 0.4 + Math.random() * 0.2;
					
					_renderSkip++;
					_render = false;
					
					if (_renderSkip % 3 == 0) {
						_renderSkip = 0;
						_render = true;
					}
					
					if (_render) {
					
						_border.visible = true;
						_sourceBMP.draw(_clip, _effectMatrix, _effectColorTransform, BlendMode.NORMAL, _sourceClipRect, true);
						_border.visible = false;
						
						_midBMP.paletteMap(_sourceBMP, _effectClipRect, _origin, _redArray, _greenArray, _blueArray);

						_effectBMP.lock();
						_effectBMP.draw(_midBMP, null, _effectColorTransform, BlendMode.SCREEN, _effectClipRect, false);

						_effectBMP.applyFilter(_effectBMP, _effectClipRect, _origin, new ColorMatrixFilter(_matrix));
						_effectBMP.applyFilter(_effectBMP, _effectClipRect, _origin, new BlurFilter(8, 8, 1));

					}
					
					_effectBMP.scroll((_cameraX - _view.camera.x) / _scaleFactor,(_view.camera.y - _cameraY) / _scaleFactor);
					_cameraX = _view.camera.x;
					_cameraY = _view.camera.y;

					if (_render) {
						
						_midBMP.fillRect(_effectClipRect, 0xFF000000);
						_midBMP.copyChannel(_effectBMP, _effectClipRect, _origin, BitmapDataChannel.RED, BitmapDataChannel.RED);
						_midBMP.copyChannel(_effectBMP, _effectClipRect, _origin, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
					
						_midBMP.scroll(0, -4);

						_effectBMP.draw(_midBMP, null, null, BlendMode.SCREEN, _effectClipRect, false);
						
					}

					_effectBMP.unlock();

					
				}
			
			}
			
		}
		
		//
		//
		//
		public function end ():void {
			
			if (_created) {
				
				_created = _active = false;
				
				if (_border != null && _clip.getChildIndex(_border) != -1) _clip.removeChild(_border);
				
				_effect.parent.removeChild(_effect);
				_effect.removeChild(_effectImage);
				
				_sourceBMP.dispose();
				_midBMP.dispose();
				_effectBMP.dispose();
			
			}
			
		}
		
	}
	
}
