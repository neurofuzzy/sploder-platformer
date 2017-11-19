/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.action.control {
	
	import flash.events.Event;
	import flash.media.SoundChannel;
	
	import fuz2d.action.physics.*;
	import fuz2d.action.play.*;
	import fuz2d.library.ObjectFactory;
	import fuz2d.TimeStep;
	
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class HarmTouchController extends PlayObjectController {
		
		protected var _strength:int = 0;
		protected var _pressure:Boolean = false;
		protected var _effect:String = "";
		protected var _count:int = 0;
		
		protected var _touchSound:SoundChannel;
		protected var _lastEffect:int = 0;

		//
		//
		public function HarmTouchController (object:PlayObjectControllable, strength:int = 1, pressure:Boolean = false, effect:String = "") {
		
			super(object);
			
			_strength = strength;
			_pressure = pressure;
			_effect = effect;
			
			_object.simObject.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);
			
		}

		
		
		//
		//
		public function onCollision (e:CollisionEvent):void {
			
			_count++;
			
			if (_count % 5 == 0 &&  !_object.isCreator(e.collider) && !_object.isCreator(e.collidee)) {
				
				if (!_pressure || e.contactSpeed > 325 || (e.collider is VelocityObject && Math.abs(VelocityObject(e.collider).velocity.x) > 100)) {
					
					var po:PlayObject;
					
					var isChildObject:Boolean = false;
					
					if (e.collider && 
						e.collider.objectRef && 
						e.collider.objectRef.attribs.parentObject && 
						e.collider.objectRef.attribs.parentObject.simObject) {
						po = _object.playfield.playObjects[e.collider.objectRef.attribs.parentObject.simObject];
						isChildObject = true;
					} else {
						po = _object.playfield.playObjects[e.collider];
					}
					
					if (po == null) po = _object.playfield.playObjects[e.collidee];
					if (po != null && po is PlayObjectControllable) {
						harm(po as PlayObjectControllable, (isChildObject) ? _strength / 10 : _strength);
					}
					
					if (_effect.length > 0 && TimeStep.realTime - _lastEffect > 250) {
						ObjectFactory.effect(_object, _effect, true, 1000, e.contactPoint);
						_lastEffect = TimeStep.realTime;
					}
					
					_count = 0;
					
				}
				
			}
			
		}
		
		//
		//
		public function harm (playObj:PlayObjectControllable, amount:int = 0):void {
			
			try {
				
				if (playObj == null || playObj.deleted) return;
				
				if (playObj.health > 0) _object.harm(playObj, amount);
				
				
				if (_touchSound == null) {
					_touchSound = _object.eventSound("collide");
					_touchSound.addEventListener(Event.SOUND_COMPLETE, touchSoundComplete);
				}
			
			} catch (e:Error) {
				trace("HarmTouchController harm:", e);
			}

		}
		
		protected function touchSoundComplete (e:Event):void {
			
			_touchSound = null;
			
		}
		
		//
		//
		override public function end():void {
			
			if (_object != null && _object.simObject != null) _object.simObject.removeEventListener(CollisionEvent.COLLISION, onCollision);
			
			super.end();
			
		}
		
	}
	
}