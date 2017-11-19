/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.play {
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import fuz2d.ObjectMaster;
	import fuz2d.action.control.*;
	import fuz2d.action.physics.*;
	import fuz2d.model.object.Object2d;

	public class Projectile extends PlayObject {
		
		protected var _launcher:Object2d;
		protected var _timer:Timer;
		protected var _lifeSpan:Number;
		
		//
		//
		public function Projectile (type:String, playfield:Playfield, obj:SimulationObject, sim:Simulation, controller:Controller = null) {
		
			super(type, playfield, obj, sim, controller);
			
		}
		
		//
		//
		override protected function init ():void {
			
			_fwdPower = 2000;
			_backPower = 0;
			_sidePower = _risePower = 0;
			_turnPower = 0;
			_pitchPower = 0;
			_rollPower = 0;
			
			_lifeSpan = 2000;
			
		}
		
		override public function spawnFrom (spawner:PlayObject):void {
			
			super.spawnFrom(spawner);
			// match parent velocity
			if (spawner.simObjectRef is MotionObject) {
				_obj.applyImpulse(MotionObject(spawner.simObjectRef).velocity.copy);
			}
			start();
			
		}
		
		//
		//
		protected function start ():void {
			
			_timer = new Timer(_lifeSpan, 1);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, end, false, 0, true);
			_timer.start();
			
			moveForward();
			
		}
		
		//
		//
		protected function end (e:TimerEvent):void {
			
			_launcher = null;
			if (_timer) {
				_timer.stop
				_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, end);
			}
			_timer = null;
			
			destroy();
			
		}
		
	}
	
}
