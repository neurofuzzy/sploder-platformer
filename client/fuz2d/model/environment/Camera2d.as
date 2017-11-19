/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.model.environment {

	import flash.geom.Point;
	
	import fuz2d.*;
	import fuz2d.model.*;
	import fuz2d.model.object.*;
	import fuz2d.util.Geom2d;
	import fuz2d.*;
	
	
	public class Camera2d extends Object2d {
		
		protected var _target:Point;
		
		protected var _pixelSnap:Boolean = false;
		public function get pixelSnap():Boolean { return _pixelSnap; }
		public function set pixelSnap(value:Boolean):void {	_pixelSnap = value; }
		
		protected var _watching:Boolean = false;
		public function get watching ():Boolean { return _watching; }
		
		protected var _chasing:Boolean = false;
		public function get chasing ():Boolean { return _chasing; }
		
		protected var _alignToTarget:Boolean = false;
		public function get alignToTarget():Boolean { return _alignToTarget; }
		public function set alignToTarget(value:Boolean):void { _alignToTarget = value; }
		
		protected var _fl:Number = 300;
		public var fl:Number = 300;
		public var ivfl:Number = 1 / 300;
		
		//
		override public function set rotation (val:Number):void { }
		
		//
		public function get focalLength ():Number { return _fl; }
		public function set focalLength (val:Number):void { 
			if (!isNaN(val)) {
				_fl = val;
			} else {
				_fl = Geom2d.distanceBetweenPoints(pt, _target); 
			}
			ivfl = 1 / _fl; 
		}
		
		//
		public function get source ():Point2d { return this; }
		public function get target ():Point { return _target; }
		
		protected var _lastTime:Number = 0;
		protected var _duration:Number;
		protected var _delta:Number = 1;
		
		private var _watchObject:Point2d;
		private var _watchOffsetPoint:Point;
		private var _watchElasticity:Number;
	
		private var _shakeTime:Number = -3000;
		
		override public function get y():Number 
		{
			if (TimeStep.realTime -_shakeTime < 500) {
				return super.y + Math.sin((TimeStep.realTime - _shakeTime - 100) / 15) * 20 * (500 -(TimeStep.realTime - _shakeTime)) / 500;
			} else {
				return super.y;
			}
		}

		//
		//
		public function Camera2d (x:Number = 0, y:Number = 0, target:Point = null) {
			
			super(null, x, y, 1);
		
			if (target != null) {
				_target = new Point(target.x, target.y);
			} else {
				_target = new Point(0, 0);
			}

		}
		
		//
		//
		override public function update ():void {

			doActions();
			
		}
		
		//
		//
		private function doActions ():void {
			
			_duration = TimeStep.realTime - _lastTime;
			_delta = Math.min(1, _duration / 33);

			_lastTime = TimeStep.realTime;
			
			if (_watching) {
				watch();
			}
				
		}
		
		//
		public function startWatching (target:Point2d, elasticity:Number = 1, offsetPoint:Point = null, alignToTarget:Boolean = false):void {
			
			_watchObject = target;
			_watchElasticity = Math.max(1, elasticity);
			
			_alignToTarget = alignToTarget;
			
			if (offsetPoint == null) {
				_watchOffsetPoint = new Point(0, 0);
			} else {
				_watchOffsetPoint = offsetPoint.clone();
			}

			_watching = true;
	
		}
		
		//
		public function stopWatching (newFocus:Point = null):void {
			
			_watching = false;

			if (newFocus != null) _target = newFocus.clone();
			
		}
		
		//
		private function watch ():void {
			
			// scene paging test
			//x = Math.floor((_watchObject.x + 254) / 508) * 508;
			//y = Math.floor((_watchObject.y + 180) / 360) * 360;			
			
			//return;
			
			if (target == null) { stopWatching(); return; }
			if (target is Object2d && Object2d(target).deleted) { stopWatching(); return; }
			
			var ease:Number = _watchElasticity / _delta;

			var deltaX:Number = (_watchObject.x - _target.x) / ease;
			var deltaY:Number = (_watchObject.y - _target.y) / ease;


			if (_pixelSnap) {
				
				deltaX = Math.round(deltaX)
				deltaY = Math.round(deltaY);
		
			}
			
			_target.x += deltaX;
			_target.y += deltaY;
			
			x = _target.x;
			y = _target.y;	

		}
		
		//
		override public function alignTo(pt:Point2d, position:Boolean = true, rotate:Boolean = true):void 
		{

			x = _target.x = pt.x;
			y = _target.y = pt.y;
			
			_moved = true;
			
		}
		
		public function shake ():void {
			
			_shakeTime = TimeStep.realTime;
			
		}
				
	}
	
}
