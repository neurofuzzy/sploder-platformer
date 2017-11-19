/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.behavior {
	
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	import fuz2d.Fuz2d;
	
	import fuz2d.action.physics.*;
	import fuz2d.action.play.*;
	import fuz2d.model.material.Material;
	import fuz2d.model.object.Point2d;
	
	import fuz2d.model.object.Object2d;
	
	import fuz2d.util.Geom2d;

	public class HopBehavior extends Behavior {
			
		public static const CENTER:int = 0;
		public static const LEFT:int = -1;
		public static const RIGHT:int = 1;
		
		protected var _timer:Timer;
		protected var _power:Number = 1;
		protected var _jumpTimes:int = 10;
		
		protected var _rotate:Boolean = false;
		public function get rotate():Boolean { return _rotate; }
		
		protected var _direction:int = CENTER;
		public function get direction():int { return _direction; }
		
		//
		//
		public function HopBehavior (direction:int = CENTER, power:Number = 1, rotate:Boolean = false) {
			
			super();

			_direction = direction;
			_power = power;
			_rotate = rotate;
			
		}
		
		//
		//
		override protected function init(parentClass:BehaviorManager):void {
			
			super.init(parentClass);

			_priority = 10;
			
			_timer = new Timer(33, 15);
			
			if (_rotate) {
				_timer.addEventListener(TimerEvent.TIMER, onTimer, false, 0, true);
			}
			
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerEnd, false, 0, true);
			_timer.start();

			if (MotionObject(_parentClass.playObject.simObject).velocity.y > 100) _power += 2;
				
			MotionObject(_parentClass.playObject.simObject).acceleration.y = 0;
			MotionObject(_parentClass.playObject.simObject).velocity.y = 300;

			if (_direction == LEFT) MotionObject(_parentClass.playObject.simObject).velocity.x += -100;
			if (_direction == RIGHT) MotionObject(_parentClass.playObject.simObject).velocity.x += 100;

		}
		
		//
		//
		protected function onTimer (e:TimerEvent):void {
			
			if (!(_parentClass.playObject == null) && !_parentClass.playObject.deleted) {
				
				if (MotionObject(_parentClass.playObject.simObject).inContact) {
					
					_rotate = false;
					
				}
			
			}
			
		}
		

		//
		//
		protected function onTimerEnd (e:TimerEvent):void {
			
			_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerEnd);
			_timer.stop();
			
			if (_parentClass != null && _parentClass.playObject != null) {
				
				if (_parentClass.playObject.object != null) _parentClass.playObject.object.rotation = 0;	
				
			}
			
			end();
			
		}
		
		
		//
		//
		override public function update(e:Event):void {
			
			super.update(e);
			
			resolve();

		}


		//
		//
		override public function resolve():void {
			
			super.resolve();
			
			if (_jumpTimes > 0) {
				
				PlayObjectMovable(_parentClass.playObject).jump(_direction, _power);	
				_jumpTimes--;	
				
			} else if (_jumpTimes == 0) {
				
				
				releaseControl();
				
			}

		}
		
	}
	
}