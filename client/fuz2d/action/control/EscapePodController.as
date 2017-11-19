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
	import flash.media.SoundTransform;
	
	import fuz2d.action.modifier.LockModifier;
	import fuz2d.action.physics.*;
	import fuz2d.action.play.*;
	import fuz2d.Fuz2d;
	import fuz2d.model.object.Biped;
	import fuz2d.model.object.Symbol;
	import fuz2d.TimeStep;
	
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class EscapePodController extends PlayObjectController {
		
		protected var _launched:Boolean = false;
		protected var _launchTime:int = 0;
		protected var _escaped:Boolean = false;
		protected var _escapeTime:int = 0;
		protected var _vel:Number = 1;
		protected var _player:BipedObject;
		protected var _engineSound:SoundChannel;
		protected var _engineVolume:Number = 2;
		
		//
		//
		public function EscapePodController (object:PlayObjectControllable) {
		
			super(object);
			
			if (PowerUpController.totals == null) PowerUpController.totals = { };
			if (PowerUpController.counts == null) PowerUpController.counts = { };
			
			PowerUpController.totals["escapepod"] = 1;
			PowerUpController.counts["escapepod"] = 1;

			_object.simObject.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);
			
		}
		
		//
		//
		override public function see(p:PlayObject):void {
			
		}
		
		//
		//
		override public function update (e:Event):void {
			
			if (_ended || !_active) return;
			
			super.update(e);
			
			if (_launched && _object != null && !_object.deleted && _object.object != null) {
				
				_object.object.y += _vel;
				_player.object.x = _object.object.x;
				_player.object.y = _object.object.y + 20;
				_player.simObject.getPosition();
				
				_vel += 0.01;
				
				if (!_escaped && TimeStep.realTime - _launchTime > 3000) {
					
					_escaped = true;
					_escapeTime = TimeStep.realTime;
					Symbol(_object.object).state = "escape";
					_vel += 5;
					_engineSound.soundTransform = new SoundTransform(2);
					Fuz2d.sounds.addSound(_object, "electric_door_reverse");

				}
				
				if (_escaped && _vel > 9) {
					Fuz2d.mainInstance.view.camera.stopWatching();
					_engineVolume = Math.max(0, _engineVolume - 0.03);
					_engineSound.soundTransform = new SoundTransform(_engineVolume);
					if (_engineSound.soundTransform.volume == 0) {
						_engineSound.stop();
						_object.playfield.dispatchEvent(new PlayfieldEvent(PlayfieldEvent.ESCAPED, false, false));
						end();
					}
				}
			}
			
		}
		

		
		//
		//
		protected function onCollision (e:CollisionEvent):void {
			
			if (_player != null) return;
			
			if (e.collider.objectRef != null && !e.collider.objectRef.deleted && e.collider.objectRef is Biped && e.collider.objectRef.symbolName == "player") {
				
				var pobj:PlayObjectControllable = _object.playfield.playObjects[e.collider];
				
				if (pobj != null) {
					
					if (pobj.object != null && !pobj.object.deleted) {
						
						_player = pobj as BipedObject;
						MotionObject(_player.simObject).gravity = 0;
						_player.simObject.simulation.removeObject(_player.simObject);
						_player.modifiers.add(new LockModifier(0));
						_player.simObject.collisionObject.reactionType = ReactionType.IGNORE;
						_launched = true;
						_launchTime = TimeStep.realTime;
						Symbol(_object.object).state = "launch";
						_engineSound = Fuz2d.sounds.addSoundLoop(_object, "jetpack1");
						_engineSound.soundTransform = new SoundTransform(1);
						
					}
					
				}
				
			}
			
		}
		
		//
		//
		override public function end():void {
			
			if (_object != null && _object.simObject != null) _object.simObject.removeEventListener(CollisionEvent.COLLISION, onCollision);
			super.end();
			
		}
		
	}
	
}