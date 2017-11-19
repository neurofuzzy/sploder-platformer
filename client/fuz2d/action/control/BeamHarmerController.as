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
	import fuz2d.Fuz2d;
	import fuz2d.library.ObjectFactory;
	import fuz2d.model.object.Symbol;
	
	import fuz2d.action.play.*;
	import fuz2d.action.physics.*;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class BeamHarmerController extends PlayObjectController {
		
		protected var _strength:int = 0;

		protected var _sym:Symbol;
		protected var _beamSound:SoundChannel;
		
		private var _sound:String;

		//
		//
		public function BeamHarmerController (object:PlayObjectControllable, strength:int = 1, sound:String = "") {
		
			super(object);
			
			_strength = strength;
			_sound = sound;
			
			_sym = Symbol(_object.object);
			
			_object.simObject.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);
			
		}

		override public function update(e:Event):void 
		{
			super.update(e);
			
			var vol:Number = Fuz2d.sounds.getVolume(_object);
			
			if (vol > 0.1) {
				
				if (_beamSound == null) _beamSound = Fuz2d.sounds.addSoundLoop(_object, _sound);
				if (_beamSound != null) {
					var st:SoundTransform = _beamSound.soundTransform;
					st.volume = 0;
					_beamSound.soundTransform = st;
				}
				
				if (_sym.state == "z_active" && _beamSound != null) {
					Fuz2d.sounds.adjustSound(_object, _beamSound);
				}
				
			} else if (_beamSound != null) {
				_beamSound.soundTransform.volume = 0;
				_beamSound.stop();
				_beamSound = null;
			}

			
		}
		
		//
		//
		public function onCollision (e:CollisionEvent):void {
			
			if (_sym.state == "z_active" && !_object.isCreator(e.collider) && !_object.isCreator(e.collidee)) {
				
				var po:PlayObject;
				
				po = _object.playfield.playObjects[e.collider];
				if (po == null) po = _object.playfield.playObjects[e.collidee];
				if (po != null && po is PlayObjectControllable) harm(po as PlayObjectControllable, _strength);
				
			}
			
		}
		
		//
		//
		public function harm (playObj:PlayObjectControllable, amount:int = 0):void {
			
			if (playObj.health > 0) _object.harm(playObj, amount);
			
		}
		
		
		//
		//
		override public function end():void {
			
			if (_object != null && _object.simObject != null) _object.simObject.removeEventListener(CollisionEvent.COLLISION, onCollision);
			if (_beamSound != null) {
				_beamSound.stop();
				_beamSound = null;
			}
			
			super.end();
			
		}
		
	}
	
}