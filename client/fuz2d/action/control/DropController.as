/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.action.control {
	
	import flash.events.Event;
	import fuz2d.library.ObjectFactory;
	
	import fuz2d.action.play.*;
	import fuz2d.action.physics.*;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class DropController extends PlayObjectController {
		
		protected var _velObject:VelocityObject;
		
		protected var _playerNear:Boolean = false;
		protected var _dropping:Boolean = false;
		
		protected var _player:PlayObject;
		
		protected var _dropHome:Number = 0;
		protected var _dropVelocity:Number = 0;
		protected var _terminalVelocity:Number = -1000;
		
		protected var _strength:int = 0;
		protected var _effect:String = "droptoucheffect";
		protected var _count:int = 0;

		//
		//
		public function DropController (object:PlayObjectControllable, strength:int = 1, effect:String = "harmtoucheffect") {
		
			super(object);
		
			_velObject = VelocityObject(_object.simObject);
			
			_velObject.lockX = true;
			_velObject.lockY = false;
			
			_dropHome = _velObject.objectRef.y;
			
			_strength = strength;
			_effect = effect;
			
		}
		
		//
		//
		override public function see(p:PlayObject):void {
			
			super.see(p);

			if (_dropping) return;
			
			if (p.object.symbolName == "player") {
				_player = p;
				_playerNear = true;
				
			}
			
		}
		
		//
		//
		override public function update (e:Event):void {
			
			if (_ended || !_active) return;
			
			super.update(e);
			
			if (_player != null && _player.deleted) {
				
				_player = null;
				_playerNear = false;
				
			} else if (_playerNear && !_dropping) {
				
				if (_object.playfield.map.canSee(_object as PlayObjectControllable, _player)) {
					
					if (_velObject.objectRef.y > _player.object.y && Math.abs(_velObject.objectRef.x - _player.object.x) < 40) {
						
						_dropping = true;
						_object.simObject.addEventListener(CollisionEvent.PENETRATION, onCollision, false, 0, true);
						
					}
					
				}
				
			} else if (_dropping) {
				
				if (!_velObject.sticking) {
					
					_velObject.velocity.y = _dropVelocity;
					if (_dropVelocity > _terminalVelocity) _dropVelocity -= 20;
					
					if (_velObject.objectRef.y < _dropHome - 900) {
						
						_object.destroy();
						return;
					}
				

				} else {
					
					_velObject.velocity.y = 0;
					
				}
				
			}
				
		}
		
		//
		//
		public function onCollision (e:CollisionEvent):void {
			
			_count++;
			
			if (_count % 5 == 0 &&  !_object.isCreator(e.collider) && !_object.isCreator(e.collidee)) {
				
				var po:PlayObject;
				
				po = _object.playfield.playObjects[e.collider];
				if (po == null) po = _object.playfield.playObjects[e.collidee];
				if (po != null && po is PlayObjectControllable) harm(po as PlayObjectControllable, _strength);
				
				ObjectFactory.effect(_object, _effect, true, 1000, e.contactPoint);
				
				_count = 0;
				
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
			
			_player = null;
			if (_object != null && _object.simObject != null) _object.simObject.removeEventListener(CollisionEvent.PENETRATION, onCollision);
			super.end();
			
		}
		
	}
	
}