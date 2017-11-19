
package com.sploder.builder {
	
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.GradientType;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.display.Sprite;

	public class CreatorBackground {
		
		protected var _container:Sprite;
		
		protected var _width:Number;
		protected var _height:Number;
		
		protected var _skyColor:uint = 0x003366;
		protected var _groundColor:uint = 0x333333;
		protected var _ambientColor:Number = 1;
		
		protected var _skySymbol:String = "sky";
		protected var _midGroundSymbol:String = "background";
		
		protected var _mountainPoints:Array;
		
		protected var _ground:Sprite;
		protected var _background:Sprite;
		protected var _bgClip:Sprite;
		protected var _playerClip:Sprite;
		
		protected var _backgroundNum:int = 1;
		public function get backgroundNum():int { return _backgroundNum; }
		
		public function set backgroundNum(value:int):void 
		{
			_backgroundNum = value;
			draw();
		}
		
		public function get skyColor():uint { return _skyColor; }
		
		public function set skyColor(value:uint):void 
		{
			_skyColor = value;
			draw();
		}
		
		public function get groundColor():uint { return _groundColor; }
		
		public function set groundColor(value:uint):void 
		{
			_groundColor = value;
			draw();
		}
		
		public function get ambientColor():Number { return _ambientColor; }
		
		public function set ambientColor(value:Number):void 
		{
			_ambientColor = value;
			_playerClip.transform.colorTransform = new ColorTransform(_ambientColor, _ambientColor, _ambientColor);
		}
		
		
		//
		//
		public function CreatorBackground(container:Sprite, width:Number, height:Number, skyColor:int = 0x336699, groundColor:int = 0x333333, backgroundNum:int = 1) {
			
			_container = container;
			
			_width = width;
			_height = height;
			
			_ground = new Sprite();
			_background = new Sprite();
			
			_container.addChild(_background);
			_container.addChild(_ground);
			
			_playerClip = CreatorFactory.createNew("1") as Sprite;
			_playerClip.scaleX = _playerClip.scaleY = 0.33;
			_playerClip.x = _width / 2;
			_playerClip.y = _height * 0.75 - _playerClip.height / 3;
			_container.addChild(_playerClip);
			_playerClip["body"]["head"]["g2c"].gotoAndStop(1);

			draw();	
			
		}
		
		protected function draw ():void {
			
			var g:Graphics;
			
			// sky
			//
			g = _container.graphics;
			g.clear();
			g.beginFill(_skyColor, 1);
			g.drawRect(0, 0, _width, _height * 0.75 + 1);
			

			g.moveTo(0, _height * 0.75 - 20);
			g.beginFill(_groundColor, 1);
			
			var mn:int = Math.max(1, (_width) / 20);
			
			if (_mountainPoints == null) _mountainPoints = [];
			
			for (var i:int = 0; i < mn; i++) {
				if (_mountainPoints[i] == undefined) _mountainPoints.push(_height * 0.75 + Math.random() * 10 - 15);
				g.lineTo((20 * i), _mountainPoints[i]);
			}
			
			g.lineTo(_width, _height * 0.75 - 20);
			g.lineTo(_width, _height);
			g.lineTo(0, _height);
			g.endFill();			
			
			// ground
			//
			g = _ground.graphics;
			g.clear();
			g.beginFill(0, 1);
			g.drawRect(0, _height * 0.75, _width, _height * 0.25);
			
			// background
			//
			if (_bgClip == null || _bgClip.name != _midGroundSymbol + _backgroundNum) {
				
				if (Creator.creatorlibrary.getDisplayObject(_midGroundSymbol + backgroundNum) != null) {
					
					if (_bgClip != null && _bgClip.parent != null) _bgClip.parent.removeChild(_bgClip);
					
					_bgClip = Creator.creatorlibrary.getDisplayObject(_midGroundSymbol + backgroundNum) as Sprite;
					
					var a:Number = _bgClip.width / _bgClip.height;
					
					_bgClip.width = _width;
					_bgClip.height = (_width) / a;
					_bgClip.x = _width / 2;
					_bgClip.y = _height * 0.75 - _bgClip.height / 3;
					if (_bgClip.width < _bgClip.height) _bgClip.y = 100;
					_background.addChild(_bgClip);
					
				}
				
			}	
			
			_playerClip["body"]["head"]["g2c"].gotoAndStop(Creator.levels.avatar * 5 + 1);
			
		}
		
		//
		//
		public function update ():void {
			
			draw();
			
		}

		
	}
	
}
