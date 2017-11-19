package fuz2d.util {
	
	import flash.display.Sprite;
	import flash.geom.Point;
	import fuz2d.util.Geom2d;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class ShrinkWrap {
		
		protected var _container:Sprite;
		
		public var rotation:Number;
		
		protected var _hullOffset:Number;
		protected var _angleSeparation:int;
		protected var _precision:int;
		protected var _optimize:Boolean;
		protected var _optimizeThreshold:Number;
		
		protected var _points:Array;
		protected var _angles:Array;
		
		protected var _startWidth:Number;
		protected var _startHeight:Number;
		
		protected var _clip:Sprite;

		protected var _bounds:Array;
		public function get bounds():Array { return _bounds; }
		
		//
		//
		function ShrinkWrap (clip:Sprite, hullOffset:Number = 0, angleSeparation:int = 3, precision:int = 1, optimize:Boolean = true, optimizeThreshold:Number = 0.7) {
		
			init(clip, hullOffset, angleSeparation, precision, optimize, optimizeThreshold);
			
		}
		
		//
		//
		protected function init (clip:Sprite, hullOffset:Number = 0, angleSeparation:int = 3, precision:int = 1, optimize:Boolean = true, optimizeThreshold:Number = 0.7):void {
			
			_clip = clip;
			_hullOffset = hullOffset;
			_angleSeparation = angleSeparation;
			_precision = precision;
			_optimize = optimize;
			_optimizeThreshold = optimizeThreshold;
			
			_startWidth = _clip.width;
			_startHeight = _clip.height;
				
			createBounds();
			
		}
		
		//
		//
		public function createBounds ():void {
			
			var pa:Number;
			var pp:Point;
			var op:Point;
			var np:Point;
			var fp:Point;
			
			var i:int;
			
			_points = new Array(361);
			_angles = [];
			
			var errorDist:Number = 20 + Math.max(20, (Math.max(_startWidth + 10, _startHeight + 10) * Math.PI) / (360 / _angleSeparation) + (_hullOffset / Math.PI));
			
			var sweep:Function = function (mc:Sprite, startAngle:Number, endAngle:Number, angleSeparation:Number, precision:Number, offset:Number, maxCheck:Number, points:Array, angles:Array, recursionDepth:int = 1):void {
				
				var cp:Point;
				var mp:Point;
				
				var minDist:Number;
				var maxDist:Number;
				var testDist:Number
				var diffDist:Number;
				
				var myPoint:Point;
				
				for (var angle:Number = startAngle; angle < endAngle; angle += angleSeparation) {
					
					minDist = 0;
					maxDist = maxCheck;
					
					if (points[angle] == undefined) {
						
						do {
							
							testDist = minDist + ((maxDist - minDist) / 2);
							
							myPoint = Point.polar(testDist, angle * Geom2d.dtr);

							myPoint = mc.localToGlobal(myPoint);

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
					
					if (mp != null && Point.distance(mp, cp) >= errorDist) {
							
						if (Math.floor(angleSeparation / 3) > 1 && recursionDepth < 3) {
							
							arguments.callee(mc, angle - angleSeparation, angle - Math.floor(angleSeparation / 3), Math.floor(angleSeparation / 3), precision, offset, maxCheck, _points, angles, recursionDepth + 1);
							
						} 
	
					}
					
					if (points[angle] == null) {

						points[angle] = cp;
						angles.push(angle);

					}
					
					mp = cp;
					
				}			
				
			}
			
			sweep(_clip, 0, 360, _angleSeparation, _precision, _hullOffset, Math.max(_startWidth + 10, _startHeight + 10), _points, _angles);

			var accum:Number = 0;
			
			// optimize
			
			for (i = _angles.length - 2; i > 0; i--) {
				
				op = _points[_angles[i + 1]];
				np = _points[_angles[i]];
				pp = _points[_angles[i - 1]];	
	
				var a1:Number = Geom2d.angleBetweenPoints(pp, np);
				var a2:Number = Geom2d.angleBetweenPoints(np, op);
				
				if (accum + Math.abs(a1) - Math.abs(a2) < _optimizeThreshold) {
					
					_points[_angles[i]] = null;
					_angles.splice(i, 1);
					
					accum += Math.abs(Math.abs(a1) - Math.abs(a2));
					
				} else {
					
					accum = 0;
					
				}
			
			}
				
			_bounds = [];
			
			for (i = _angles.length - 1; i >= 0; i--) if (_points[_angles[i]] is Point) _bounds.unshift(_points[_angles[i]]);

		}
		
	}
	
}