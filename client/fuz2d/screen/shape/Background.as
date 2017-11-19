/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.screen.shape {
	
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.GradientType;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import fuz2d.Fuz2d;
	
	import fuz2d.model.environment.Environment;
	import fuz2d.screen.*;
	import fuz2d.util.*;


	public class Background {
		
		protected var _view:View;
		protected var _container:Sprite;
		protected var _farGround:Sprite;
		protected var _sky:Sprite;
		protected var _midGround:Sprite;
		protected var _nearGround:Sprite;
		protected var _environment:Environment;
		
		protected var _alphas:Array;
		protected var _horizonAlphas:Array;
		protected var _distAlphas:Array;
		
		protected var _skyColors:Array;
		protected var _horizonColors:Array;
		protected var _groundColors:Array;
		protected var _distColors:Array;
		
		protected var _ratios:Array;
		protected var _horizonRatios:Array;
		protected var _distRatios:Array;
		
		protected var _skyMatrix:Matrix;
		protected var _horizonMatrix:Matrix;
		protected var _groundMatrix:Matrix;
		protected var _distMatrix:Matrix;
		
		protected var stars:Sprite;
		protected var horizon:Sprite;
		protected var cue:Sprite;
		
		protected var _skyAdded:Boolean = false;
		protected var _midGroundAdded:Boolean = false;
		
		protected var _midGroundWidth:Number = 0;
		
		//
		//
		public function Background(view:View, container:Sprite) {
			
			_view = view;
			_container = container;
			_environment = _view.model.environment;
			
			_alphas = [1, 1];
			_horizonAlphas = [0,1];
			_distAlphas = [0, _environment.distanceCueAmount, _environment.distanceCueAmount, 0];
			
			_skyColors = [_environment.skyColor, _environment.skyColor2];
			_horizonColors = [ _environment.skyColor2, _environment.horizonColor];
			_groundColors = [_environment.groundColorNear, _environment.groundColorFar];
			_distColors = [_environment.distanceCueColor, _environment.distanceCueColor, _environment.distanceCueColor, _environment.distanceCueColor];
			
			_ratios = [100, 255];
			_horizonRatios = [0, 255];
			_distRatios = [0, 100, 156, 255];
			
			_skyMatrix = new Matrix;
			_skyMatrix.createGradientBox(_view.width * 4, _view.height * 4, 0, 0 - _view.width * 2, 0 - _view.height * 4);
			_horizonMatrix = new Matrix;
			_horizonMatrix.createGradientBox(_view.width * 4, 50, 90 * Geom2d.dtr, 0 - _view.width * 2, 0 - 50);
			_groundMatrix = new Matrix();
			_groundMatrix.createGradientBox(_view.width * 4, _view.height * 4, 0, 0 - _view.width * 2, 0 - _view.height / 2);
			_distMatrix = new Matrix();
			_distMatrix.createGradientBox(_view.width * 4, _view.height * 2, 90 * Geom2d.dtr, 0 - _view.width * 2, 0 - _view.height);
		
			_farGround = new Sprite();
			_sky = new Sprite();
			_midGround = new Sprite();
			_nearGround = new Sprite();
			
			_container.addChild(_farGround);
			_container.addChild(_sky);
			_container.addChild(_midGround);
			_container.addChild(_nearGround);
			
			draw(_farGround, _nearGround);	
			
		}

		//
		//
		public function update ():void {
			
			if (horizon != null) horizon.x = ((0 - _view.camera.x) * 0.25) % (horizon.width / 3);
			
			_nearGround.x = (0 - _view.camera.x) % (_nearGround.width / 3);
			_nearGround.y = Math.max( 0 - _view.innerHeight, _view.camera.y);
		
			_midGround.x = (0 - _view.camera.x * 0.8) % (_midGroundWidth / 3);
			_midGround.y = (_view.camera.y * 0.8) - _view.bleed + 40;
			
			_sky.x = (0 - _view.camera.x * 0.5) % (_sky.width / 3);
			_sky.y = (_view.camera.y * 0.35) - _view.bleed;
			
			_farGround.y = Math.max(0 - _view.height, Math.min(_view.height, ((_view.camera.y) * 0.25))) - _view.bleed;
			
			var filters:Array;
			
			if (!_midGroundAdded && _environment.midGroundSymbol.length > 0) {
				
				_midGroundAdded = true;
				
				filters = [new BlurFilter(2, 2, 3)];
				
				var testClip:DisplayObject = Fuz2d.library.getDisplayObject(_environment.midGroundSymbol);
				
			
				
				var clip:DisplayObject;
	
				try {
					
					if (testClip.height < testClip.width) clip = Fuz2d.library.getDisplayObjectAsBitmap(_environment.midGroundSymbol, filters);
					else clip = Fuz2d.library.getDisplayObject(_environment.midGroundSymbol);
					_midGround.addChild(clip);
					if (testClip.height < testClip.width) {
						clip.scaleX = clip.scaleY = 1 / View.scale * BitView.pixelScale;
						clip.x = 0 - clip.width * 1.5;
						clip.y = 0 - clip.height * 0.65;
					} else {
						clip.scaleX = clip.scaleY = 1 / View.scale;
						clip.x = 0 - clip.width;
						clip.y = 0;
					}
					
					
					if (testClip.height < testClip.width) clip = Fuz2d.library.getDisplayObjectAsBitmap(_environment.midGroundSymbol, filters);
					else clip = Fuz2d.library.getDisplayObject(_environment.midGroundSymbol);
					_midGround.addChild(clip);
					if (testClip.height < testClip.width) {
						clip.scaleX = clip.scaleY = 1 / View.scale * BitView.pixelScale
						clip.x = 0 - clip.width * 0.5;
						clip.y = 0 - clip.height * 0.65;
					} else {
						clip.scaleX = clip.scaleY = 1 / View.scale
						clip.x = 0;
						clip.y = 0;
					}
					
					
					if (testClip.height < testClip.width) clip = Fuz2d.library.getDisplayObjectAsBitmap(_environment.midGroundSymbol, filters);
					else clip = Fuz2d.library.getDisplayObject(_environment.midGroundSymbol);
					_midGround.addChild(clip);
					if (testClip.height < testClip.width) {
						clip.scaleX = clip.scaleY = 1 / View.scale * BitView.pixelScale;
						clip.x = clip.width * 0.5;
						clip.y = 0 - clip.height * 0.65;
					} else {
						clip.scaleX = clip.scaleY = 1 / View.scale;
						clip.x = clip.width;
						clip.y = 0;
					}
					
					_midGroundWidth = _midGround.width;
				
				} catch (e:Error) {
					
					trace("background not found");
					
				}
				
			}
			
			if (!_skyAdded && _environment.skySymbol.length > 0) {
				
				_skyAdded = true;
				
				filters = [new BlurFilter(6, 6, 1)];
				
				var clip2:Bitmap;
				
				clip2 = Fuz2d.library.getDisplayObjectAsBitmap(_environment.skySymbol, filters) as Bitmap;
				_sky.addChild(clip2);
				clip2.scaleX = clip2.scaleY = 1 / View.scale * BitView.pixelScale;
				clip2.x = 0 - clip2.width * 1.5;
				clip2.y = 0 - Math.floor(300 * View.scale) - clip2.height;
				
				
				clip2 = Fuz2d.library.getDisplayObjectAsBitmap(_environment.skySymbol, filters) as Bitmap;
				_sky.addChild(clip2);
				clip2.scaleX = clip2.scaleY = 1 / View.scale * BitView.pixelScale;
				clip2.x = 0 - clip2.width * 0.5;
				clip2.y = 0 - Math.floor(300 * View.scale) - clip2.height;
				
				
				clip2 = Fuz2d.library.getDisplayObjectAsBitmap(_environment.skySymbol, filters) as Bitmap;
				_sky.addChild(clip2);
				clip2.scaleX = clip2.scaleY = 1 / View.scale * BitView.pixelScale;
				clip2.x = clip2.width * 0.5;
				clip2.y = 0 - Math.floor(300 * View.scale) - clip2.height;
				
				
			}
			
		}
		
		//
		//
		public function redraw ():void {
			
			draw(_farGround, _nearGround);
			
		}
		
		//
		//
		protected function draw (c:Sprite, d:Sprite):void {
			
			var horizonWidth:uint = _view.width;
			var numMountains:uint = 12;
			var mountainMaxHeight:uint = 96;
			var mountainAvHeight:Number = 40;
			var mountainPoints:Array = [];
			var mountainWidth:Number = horizonWidth / (numMountains - 1);
			var i:int;
			var j:int;
			
			var mxo:Number;
			var myo:Number;
		
			var g:Graphics = c.graphics;
			
			g.clear();
			
			var colorA:uint;
			var colorB:uint;
			
			g.clear();

			if (stars != null) {
				c.removeChild(stars);
			}
			
			if (horizon != null) {
				c.removeChild(horizon);
			}
			
			if (cue != null) {
				c.removeChild(cue);
			}
			
			
			// sky
			
			if (_environment.showSkyGradient) {
				
				g.moveTo(0 - _view.width / 2 - _view.bleed, 0);
				g.beginGradientFill(GradientType.RADIAL, _skyColors, _alphas, _ratios, _skyMatrix); 
				g.lineTo(_view.width / 2 + _view.bleed, 0);
				g.lineTo(_view.width / 2 + _view.bleed, 0 - _view.height * 2.2 - _view.bleed);
				g.lineTo(0 - _view.width / 2 - _view.bleed, 0 - _view.height * 2.2 - _view.bleed);
				g.endFill();
				
				// sky near horizon
				
				g.moveTo(0 - _view.width / 2 - _view.bleed, 0);
				g.beginGradientFill(GradientType.LINEAR, _horizonColors, _horizonAlphas, _horizonRatios, _horizonMatrix); 
				g.lineTo(_view.width / 2 + _view.bleed, 0);
				g.lineTo(_view.width / 2 + _view.bleed, 0 - 50);
				g.lineTo(0 - _view.width / 2 - _view.bleed, 0 - 50);
				g.endFill();
				
				c.scaleX = c.scaleY = 1 / View.scale;
			
			}
			
			// stars 
			
			if (_environment.showStars) {
				
				stars = new Sprite();
				stars.y = 0 - _view.height * 2.2;
				
				var numStars:uint = 120 + Math.floor(Math.random() * 90);
				var sx:Number;
				var sy:Number;
				
				var starColors:Array = [0xffffff, 0xbbffff, 0xffffcc, 0xeebbff, 0xffffff];
				
				for (i = 0; i < numStars; i++) {
					
					sx = Math.floor(Math.random() * _view.width * 2) - _view.width;
					sy = Math.floor(Math.random() * _view.width * 2) - _view.width;
					
					stars.graphics.beginFill(starColors[Math.round(Math.random() * (starColors.length - 1))] , 100);
					stars.graphics.drawCircle(sx, sy, Math.random());
					stars.graphics.endFill();
					
				}
				
				c.addChild(stars);
				
			}
			
			// ground
			
			if (_environment.showGroundGradient) {
				
				g.moveTo(0 - _view.width / 2 - _view.bleed, _view.height * 2.2 + _view.bleed);
				g.beginGradientFill(GradientType.RADIAL, _groundColors, _alphas, _ratios, _groundMatrix); 
				g.lineTo(_view.width / 2 + _view.bleed, _view.height * 2.2 + _view.bleed);
				g.lineTo(_view.width / 2 + _view.bleed, 0);
				g.lineTo(0 - _view.width / 2 - _view.bleed, 0);
				g.endFill();
			
				// mountains
			
				if (_environment.showMountains) {
					
					horizon = new Sprite();
			
					for (i = 0; i < numMountains; i++) {
						
						if (i == 0) {
							mxo = 0;
						} else if (i == numMountains - 1) {
							mxo = mountainWidth * i;
						} else {
							mxo = (mountainWidth * i) + (Math.random() * mountainWidth / 100);
						}
						
						myo = Math.random() * mountainAvHeight;
						
						mountainAvHeight = Math.max(2, Math.min(mountainMaxHeight, mountainAvHeight + (Math.random() * 2 - 1)));
			
						mountainPoints.push({x: mxo, y: myo});
						
					}
		
					mountainPoints[mountainPoints.length - 1].y = mountainPoints[0].y;
					//mountainPoints.push( { x: mxo, y: -10 } );
					//mountainPoints.push( { x: 0, y: -20 } );
					
					var ms:Sprite;
					var mg:Graphics;
					
					for (j = -1; j <= 1; j++) {
						
						ms = new Sprite();
						horizon.addChild(ms);
						mg = ms.graphics;
						
						mg.moveTo(horizonWidth * j + horizonWidth / 2 + 10, 10);
						mg.beginFill(ColorTools.getTintedColor(_environment.groundColorFar, _environment.groundColorNear, 0.4));
						mg.lineTo(horizonWidth * j - horizonWidth / 2 - 10, 10);
						
						for (i = 0; i < mountainPoints.length; i++) {
							mg.lineTo(horizonWidth * j - horizonWidth / 2 + mountainPoints[i].x, 0 - mountainPoints[i].y);
						}
						
						mg.endFill();
						
						ms.filters = [new BlurFilter(10,10,1)]
						
					}

					c.addChild(horizon);
					
				}
				
			}
			
			// distance cue
			
			if (_environment.distanceCue) {
				
				cue = new Sprite();
				
				cue.graphics.moveTo(0 - _view.width / 2 - _view.bleed, _view.height);
				cue.graphics.beginGradientFill(GradientType.LINEAR, _distColors, _distAlphas, _distRatios, _distMatrix); 
				cue.graphics.lineTo(_view.width / 2 + _view.bleed, _view.height);
				cue.graphics.lineTo(_view.width / 2 + _view.bleed, 0 - _view.height);
				cue.graphics.lineTo(0 - _view.width / 2 - _view.bleed, 0 - _view.height);
				cue.graphics.endFill();	
				
				c.addChild(cue);
				
			}
			
			
			// near ground
			
			g = d.graphics;
			
			horizonWidth = _view.width * 4;
			numMountains = 128;
			mountainMaxHeight = 12;
			mountainAvHeight = 6;
			mountainPoints = [];
			mountainWidth = horizonWidth / (numMountains - 1);
			
			for (i = 0; i < numMountains; i++) {
				
				if (i == 0) {
					mxo = 0;
				} else if (i == numMountains - 1) {
					mxo = mountainWidth * i;
				} else {
					mxo = (mountainWidth * i) + (Math.random() * mountainWidth / 100);
				}
				
				myo = Math.random() * mountainAvHeight;
				
				mountainAvHeight = Math.max(2, Math.min(mountainMaxHeight, mountainAvHeight + (Math.random() * 2 - 1)));
	
				mountainPoints.push({x: mxo, y: myo});
				
			}

			mountainPoints[mountainPoints.length - 1].y = mountainPoints[0].y;
			
				
			for (j = -1; j <= 1; j++) {
				g.moveTo(horizonWidth * j + horizonWidth / 2, 0);
				g.beginFill(0x000000);
				g.lineTo(horizonWidth * j - horizonWidth / 2, 0);
				
				for (i = 0; i < numMountains; i++) {
					g.lineTo(horizonWidth * j - horizonWidth / 2 + mountainPoints[i].x, 0 - mountainPoints[i].y);
				}
				
				g.lineTo(horizonWidth * j + horizonWidth / 2, 1500);
				g.lineTo(horizonWidth * j - horizonWidth / 2, 1500);
				g.lineTo(horizonWidth * j - horizonWidth / 2, 0);
				g.endFill();
				
			}
			
		}
		
		public function end ():void {
			
			if (_farGround && _farGround.parent) _farGround.parent.removeChild(_farGround);
			if (_sky && _sky.parent) _sky.parent.removeChild(_sky);
			if (_midGround && _midGround.parent) _midGround.parent.removeChild(_midGround);
			if (_nearGround && _nearGround.parent) _nearGround.parent.removeChild(_nearGround);
			
			_farGround = _sky = _midGround = _nearGround = null;
			_alphas = _horizonAlphas = _distAlphas = _skyColors = _horizonColors = _groundColors = _distColors = _ratios = _horizonRatios = _distRatios = null;
			_skyMatrix = _horizonMatrix = _groundMatrix = _distMatrix = null;
			
			_environment = null;
			
		}
		
	}
	
}
