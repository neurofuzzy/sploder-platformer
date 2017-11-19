package fuz2d.screen.shape {
	
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.filters.BevelFilter;
	import flash.filters.ConvolutionFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import fuz2d.util.Geom2d;

	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class PolyWrap {
		
		protected var _container:Sprite;
		
		public var rotation:Number;
		
		protected var _hullOffset:Number = 0;
		protected var _angleSeparation:Number = 5;
		protected var _precision:Number = 10;
		protected var _angleTolerance:Number = 0.7;
		
		public var points:Array;
		public var angles:Array;
		
		protected var _startWidth:Number;
		protected var _startHeight:Number;
		
		protected var _clipY:Number = 0;
		
		protected var _boundsSprite:Sprite;
		
		protected var _wrapSprite:Sprite;
		
		public var draw:Boolean = true;
		
		protected var _g:Graphics;
		
		//
		//
		function PolyWrap (boundsSprite:Sprite, container:Sprite, hullOffset:Number = 0, clipY:Number = 0) {
		
			init(boundsSprite, container, hullOffset, clipY);
			
		}
		
		//
		//
		protected function init (boundsSprite:Sprite, container:Sprite, hullOffset:Number = 0, clipY:Number = 0):void {
			
			_boundsSprite = boundsSprite;
			_container = container;
			
			_wrapSprite = new Sprite();
			_wrapSprite.blendMode = BlendMode.SCREEN;
			var m:Array = [0, -1, 0, -1, 5, -1, 0, -1, 0];
			_wrapSprite.filters = [
				new BevelFilter(20, 135, 0x99ccff, 0.8, 0x003366, 1, 0, 0, 10),
				new BevelFilter(60, 45, 0x99ccff, 1, 0x003366, 1, 0, 0, 10),
				new BevelFilter(20, 45, 0x99ccff, 0.9, 0x0066ff, 1, 0, 0, 2),
				new GlowFilter(0xcccccc, 0.7, 16, 16, 2, 1, true),
				new ConvolutionFilter(3, 3, m)
				];
			_container.addChild(_wrapSprite);
			_hullOffset = hullOffset;
			_clipY = clipY;
			
			_startWidth = _boundsSprite.width;
			_startHeight = _boundsSprite.height;
			
			_g = _wrapSprite.graphics;
			
			drawBounds();
			
		}
		
		//
		//
		public function drawBounds ():void {
			
			var pa:Number;
			var pp:Point;
			var op:Point;
			var np:Point;
			var fp:Point;
			
			var i:int;
			
			points = new Array(361);
			angles = [];
			
			var errorDist:Number = 20 + Math.max(20, (Math.max(_startWidth + 10, _startHeight + 10) * Math.PI) / (360 / _angleSeparation) + (_hullOffset / Math.PI));

			if (draw) {
				_g.clear();
				_g.beginFill(0x0099ff, 1);
			}
			
			var sweep:Function = function (mc:Sprite, startAngle:Number, endAngle:Number, angleSeparation:Number, precision:Number, offset:Number, maxCheck:Number, points:Array, angles:Array, recursionDepth:int = 1):void {
				
				var cp:Point;
				var mp:Point;
				
				var minDist:Number;
				var maxDist:Number;
				var testDist:Number
				var diffDist:Number;
				
				var myPoint:Point;
				
				for (var angle:int = startAngle; angle < endAngle; angle += angleSeparation) {
					
					minDist = 0;
					maxDist = maxCheck;
					
					if (points[angle] == undefined) {
						
						do {
							
							testDist = minDist + ((maxDist - minDist) / 2);
							
							myPoint = Point.polar(testDist, angle * Geom2d.dtr);

							myPoint = mc.parent.localToGlobal(myPoint);

							if (mc.hitTestPoint(myPoint.x, myPoint.y, true)) {
								
								minDist = testDist;

							} else {
								
								maxDist = testDist;
								
							}
							
							diffDist = maxDist - minDist;
							
						} while (diffDist > precision);
					
						cp = Point.polar(minDist + offset, angle * Geom2d.dtr);

					} else {
						
						cp = points[angle];
						
					}
					
					if (mp != null) {

						if (Point.distance(mp, cp) >= errorDist) {
							
							if (Math.floor(angleSeparation / 3) > 1 && recursionDepth < 3) {
								
								arguments.callee(mc, angle - angleSeparation, angle - Math.floor(angleSeparation / 3), Math.floor(angleSeparation / 3), precision, offset, maxCheck, points, angles, recursionDepth + 1);
								
							} 

						} else {
							//trace("skipping " + angle + " " + Point.distance(mp, cp) + " " + mp.x + " " + mp.y + " " + cp.x + " " + cp.y);
						}
						
					}
					
					if (points[angle] == null) {

						points[angle] = cp;
						angles.push(angle);

					}
					
					mp = cp;
					
				}			
				
			}
			
			sweep(_boundsSprite, 0, 360, _angleSeparation, _precision, _hullOffset, Math.max(_startWidth + 10, _startHeight + 10), points, angles);

			var accum:Number = 0;
			
			// optimize
			
			for (i = angles.length - 2; i > 0; i--) {
				
				op = points[angles[i + 1]];
				np = points[angles[i]];
				pp = points[angles[i - 1]];	
	
				var a1:Number = Geom2d.angleBetweenPoints(pp, np);
				var a2:Number = Geom2d.angleBetweenPoints(np, op);
				
				if (accum + Math.abs(a1) - Math.abs(a2) < _angleTolerance) {
					
					points[angles[i]] = null;
					angles.splice(i, 1);
					
					accum += Math.abs(Math.abs(a1) - Math.abs(a2));
					
				} else {
					
					accum = 0;
					
				}
			
			}
				
			for (i = angles.length - 1; i > 0; i--) {
				
				np = points[angles[i]];
				pp = points[angles[i - 1]];
				
				if (i == angles.length - 1) {
					
					//trace("0 1 " + (i - 1) + " " + i);
					//playfield.addEdge(_x + parseInt(points[0]._x), _y + parseInt(points[0]._y), 
					//	_x + parseInt(np._x), _y + parseInt(np._y));
					//playfield.addEdge(_x + parseInt(np._x), _y + parseInt(np._y), 
					//	_x + parseInt(pp._x), _y + parseInt(pp._y));
					
				} else {
					
					//trace((i - 1) + " " + i + " " + (i - 3) + " " + (i - 2));
					//playfield.addEdge(_x + parseInt(np._x), _y + parseInt(np._y), 
					//	_x + parseInt(pp._x), _y + parseInt(pp._y));
						
				}
				
			}
			if (_clipY != 0) {
				
				for (i = 0; i < angles.length; i++) {		
					np = points[angles[i]];
					if (_clipY > 0) np.y = Math.min(_clipY, np.y);
					else np.y = Math.max(_clipY, np.y);
				}
				
			}
				
			if (draw) {

				// draw
				fp = points[0];
				_g.moveTo(fp.x, fp.y);
						
				for (i = 0; i < angles.length; i++) {
						
					np = points[angles[i]];
				
					if (Point.distance(pp, np) > errorDist) {	
						//_g.lineStyle(1, 0xff0000, 100);	
					} else {
						//_g.lineStyle(1, 0x000000, 100);
					}
					_g.lineTo(np.x, np.y);
					pp = points[angles[i]];

				
				}
				
				_g.lineTo(fp.x, fp.y);
			
			}
			
		}
		
	}
	
}