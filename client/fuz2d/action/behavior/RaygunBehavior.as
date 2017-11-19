/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.behavior {
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import fuz2d.action.physics.*;
	import fuz2d.action.play.PlayObject;
	import fuz2d.action.play.PlayObjectControllable;
	import fuz2d.Fuz2d;
	import fuz2d.library.ObjectFactory;
	import fuz2d.model.object.Toolset;
	import fuz2d.TimeStep;
	
	

	public class RaygunBehavior extends AimBehavior {
		
		protected var _timer:Timer;
		
		//
		//
		public function RaygunBehavior (handles:Array, toolset:Toolset, targetGroup:String = "evil", fireDuration:int = 100, fireDelay:int = 1000, priority:int = 0) {

			super(handles, toolset, targetGroup, fireDuration, fireDelay, priority);
			
		}

		
		//
		//
		override protected function init(parentClass:BehaviorManager):void {
			
			super.init(parentClass);
			
			_timer = new Timer(250, 1);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onFireComplete);
			
		}
		
		protected function onFireComplete (e:TimerEvent):void {
			
			_toolset.count--;

		}
		

		//
		//
		override public function fire ():Boolean {
			
			if (!_firing && TimeStep.realTime - _fireTime > _fireDelay) {
				
				var v:Vector2d;
				
				_firing = true;
				_fireTime = TimeStep.realTime;
				
				var hitObj:Object = trackHitPoint();
				
				if (hitObj != null) trace(PlayObject(hitObj.obj).object.symbolName);
				else trace("nope");
				if (hitObj != null && hitObj.obj is PlayObjectControllable) {
					
					PlayObjectControllable(_parentClass.playObject).harm(hitObj.obj as PlayObjectControllable, _toolset.strength);

					if (PlayObjectControllable(hitObj.obj).simObject is MotionObject) {
						v = new Vector2d(null, 500, 0);
						v.rotate(0 - _toolset.toolRotation);
						MotionObject(PlayObjectControllable(hitObj.obj).simObject).applyImpulse(v);
					}
				
				}
				trace("tool hit point:", _toolset.toolHitPoint);
				ObjectFactory.effect(_parentClass.playObject, "clasheffect2", true, 1000, _toolset.toolHitPoint);				
				
				if (_parentClass.simObject is MotionObject) {
					v = new Vector2d(null, -100, 0);
					v.rotate(0 - _toolset.toolRotation);
					MotionObject(_parentClass.simObject).applyImpulse(v);
				}
				
				Fuz2d.sounds.addSound(_parentClass.playObject, "gun2");
				
				_timer.reset();
				_timer.start();
				
				return true;
					
			}
			
			return false;
			
		}
		
	}
	
}