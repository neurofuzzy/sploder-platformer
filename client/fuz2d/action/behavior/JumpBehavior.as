/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.behavior {
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import fuz2d.action.physics.*;
	import fuz2d.action.play.*;
	import fuz2d.library.ObjectFactory;
	import fuz2d.TimeStep;
	

	public class JumpBehavior extends BipedBehavior {
			
		public static const CENTER:int = 0;
		public static const LEFT:int = -1;
		public static const RIGHT:int = 1;
		
		protected var _timer:Timer;
		protected var _power:Number = 1;
		protected var _jumpTimes:int = 10;
		protected var _startTime:int = 0;
		
		protected var _rotate:Boolean = false;
		public function get rotate():Boolean { return _rotate; }
		
		protected var _direction:int = CENTER;
		public function get direction():int { return _direction; }
		
		protected var _doubleJumped:Boolean = false;
		public function get doubleJumped():Boolean { return _doubleJumped; }
		
		//
		//
		public function JumpBehavior (direction:int = CENTER, power:Number = 1, rotate:Boolean = false) {
			
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
			
			_startTime = TimeStep.realTime;
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerEnd, false, 0, true);
			_timer.start();
			
			beginJump();
			
		}
		
		//
		//
		protected function beginJump ():void {
			
			_jumpTimes = 10;
			
			BipedObject(_parentClass.playObject).jumping = true;
			if (_rotate) BipedObject(_parentClass.playObject).flipping = true;
			
			if (MotionObject(_parentClass.playObject.simObject).velocity.y > 100) _power += 2;
			
			MotionObject(_parentClass.playObject.simObject).acceleration.x *= 0.5;
			MotionObject(_parentClass.playObject.simObject).acceleration.y = 0;
			MotionObject(_parentClass.playObject.simObject).velocity.y = 300;

			if (!rotate) {
				if (_direction == LEFT) MotionObject(_parentClass.playObject.simObject).velocity.x += 60;
				if (_direction == RIGHT) MotionObject(_parentClass.playObject.simObject).velocity.x += -60;
				if (_direction == LEFT || _direction == RIGHT) {
					MotionObject(_parentClass.playObject.simObject).velocity.clamp(500);
				} else {
					MotionObject(_parentClass.playObject.simObject).velocity.y = 360;
				}
			} else {
				if (_direction == LEFT) MotionObject(_parentClass.playObject.simObject).velocity.x += -120;
				if (_direction == RIGHT) MotionObject(_parentClass.playObject.simObject).velocity.x += 120;				
			}			
			
		}
		
		public function doubleJump ():void {
			
			if (!_doubleJumped && 
				_direction != CENTER && 
				_timer && 
				_jumpTimes <= 1 && 
				_parentClass.modelObject.attribs.doublejump &&
				TimeStep.realTime - _startTime > 300 &&
				_parentClass.playObject is BipedObject &&
				BipedObject(_parentClass.playObject).stamina > 25) {
				
				_timer.reset();
				_timer.start();
				
				if (!_rotate) {
					_timer.addEventListener(TimerEvent.TIMER, onTimer, false, 0, true);
					_rotate = true;
				}
				
				BipedObject(_parentClass.playObject).flipping = true;
				beginJump();
				_doubleJumped = true;
				
				BipedObject(_parentClass.playObject).stamina -= 25;
				
				var pt:Point = _parentClass.modelObject.point.clone();
				pt.y -= _parentClass.modelObject.height * 0.5;
				ObjectFactory.effect(_parentClass.playObject, "doublejumpeffect", true, 1000, pt);
				_parentClass.playObject.eventSound("doublejump");
				
			}
			
		}
		
		//
		//
		protected function onTimer (e:TimerEvent):void {
			
			if (!(_parentClass.playObject == null) && !_parentClass.playObject.deleted) {
				
				if (!MotionObject(_parentClass.playObject.simObject).inContact) {
					
					if (_direction == RIGHT) {
						BipedObject(_parentClass.playObject).object.rotation += 0.8;
					} else if (_direction == LEFT) {
						BipedObject(_parentClass.playObject).object.rotation -= 0.8;
					}
				
				} else {
					
					_rotate = false;
					BipedObject(_parentClass.playObject).object.rotation = 0;
					
				}
			
			}
			
		}
		

		//
		//
		protected function onTimerEnd (e:TimerEvent):void {
			
			_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerEnd);
			_timer.stop();
			
			if (_parentClass != null && _parentClass.playObject != null) {
				
				BipedObject(_parentClass.playObject).jumping = false;
				BipedObject(_parentClass.playObject).flipping = false;
				if (_parentClass.playObject.object != null) BipedObject(_parentClass.playObject).object.rotation = 0;	
				
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
				
				BipedObject(_parentClass.playObject).jump(_direction, _power);	
				_jumpTimes--;	
				
				_handle_leg_lt.reset();
				_handle_leg_lt.x += 30;
				_handle_leg_lt.y += 30;
				_handle_leg_lt.pull(0.5);

				_handle_leg_lt.reset();
				_handle_leg_rt.x -= 30;
				_handle_leg_rt.y += 30;
				_handle_leg_rt.pull(0.5);
				
			} else if (_jumpTimes == 0) {
				
				
				releaseControl();
				
			}

		}
		
	}
	
}