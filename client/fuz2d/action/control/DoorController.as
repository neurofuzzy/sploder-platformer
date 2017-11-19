/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.action.control {
	
	import flash.events.Event;
	
	import fuz2d.action.physics.*;
	import fuz2d.action.play.*;
	import fuz2d.model.object.Symbol;
	import fuz2d.TimeStep;
	import fuz2d.util.Geom2d;
	
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class DoorController extends PlayObjectController {
		
		protected var _player:PlayObject;
		protected var _playerNear:Boolean = false;
		protected var _open:Boolean = false;
		
		protected var _openWhenNear:Boolean = false;
		protected var _keyName:String = "";
		protected var _oneWay:String = "";
		protected var _openTime:Number;
		protected var _lockedSoundTime:int = 0;
		
		public var stuck:Boolean = false;
		
		protected var _justCollided:Boolean = false;
		protected var _collided:Boolean = false;
		protected var _cleared:Boolean = false;

		//
		//
		public function DoorController (object:PlayObjectControllable, openWhenNear:Boolean = false, keyName:String = "", oneWay:String = "") {
		
			super(object);
			
			_openWhenNear = openWhenNear;
			_keyName = keyName;
			_oneWay = oneWay;
			
			_object.simObject.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);
			_object.simObject.addEventListener(CollisionEvent.PENETRATION, onPenetration, false, 0, true);
			
		}
		
		//
		//
		override public function see(p:PlayObject):void {
			
			super.see(p);

			if (_open) return;
			
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
				
			} else if (_playerNear && !_open) {
				
				if (_openWhenNear) {
					
					if (_keyName.length > 0 && _player.object != null && _player.object.attribs[_keyName] == undefined) return;
					
					if (_object.playfield.map.canSee(_object as PlayObjectControllable, _player)) {
						
						if (Geom2d.squaredDistanceBetweenPoints(_object.object.point, _player.object.point) < (_object.simObject.collisionObject.radius * 2) * (_object.simObject.collisionObject.radius * 2)) {
							
							open();
							
						}
						
					}
				
				}
				
			} else if (_open) {
				
				if (TimeStep.realTime - _openTime > 200 && TimeStep.realTime - _openTime < 2000) {
					
					_object.simObject.collisionObject.reactionType = ReactionType.REPORT_ONLY;
					
				} else if (TimeStep.realTime - _openTime > 2000) {

					if (!_collided) {
						close();
					}
					
				}
				
			} else if (_playerNear) {
				
				if (Geom2d.squaredDistanceBetweenPoints(_object.object.point, _player.object.point) > _object.playfield.sightGrid.size * _object.playfield.sightGrid.size) {
					
					_playerNear = false;
					
				}				
				
			}
			
			if (!_justCollided) {
				_collided = false;
				_cleared = true;
			}
			_justCollided = false;
				
		}
		
		public function open ():void {
			
			if (!_open && !stuck) {
				
				_open = true;
				Symbol(_object.object).state = "f_open";
				_object.simObject.collisionObject.reactionType = ReactionType.REPORT_ONLY;
				_object.playfield.map.unregister(_object);
				_openTime = TimeStep.realTime;	
				_object.eventSound("open");
				
			}
			
		}
		
		public function close ():void {
			
			if (_open && !stuck) {
				
				_open = false;
				Symbol(_object.object).state = "f_close";
				_object.simObject.collisionObject.reactionType = ReactionType.BOUNCE;
				_object.playfield.map.register(_object, _object.object.x, _object.object.y);
				_object.eventSound("close");
				
			}
			
		}
		
		//
		//
		protected function onPenetration (e:CollisionEvent):void {
			
			_justCollided = _collided = true;

		}
		
		//
		//
		protected function onCollision (e:CollisionEvent):void {
			
			_justCollided = _collided = true;

			if (!_open) {
				
				var canOpen:Boolean = false;
				
				if (_keyName.length > 0 && _player != null && _player.object != null) {
					
					if (_player.object.attribs[_keyName] == undefined) {
						
						if (TimeStep.realTime - _lockedSoundTime > 1000 && e.collider.type == "player") {
							_object.eventSound("locked");
							Symbol(_object.object).state = "f_locked";
							_lockedSoundTime = TimeStep.realTime;
						}
						
					} else {
						
						canOpen = true;
						
					}
					
				} else if (_keyName.length == 0) {
					
					canOpen = true;
					
				}
				
				var v:Vector2d = e.contactNormal;
				
				if (_object.object.rotation != 0) {
					v = e.contactNormal.copy;
					v.rotate(_object.object.rotation);
				}
				
				if (canOpen && _oneWay) {
					trace(v.x, v.y);
					switch (_oneWay) {
						
						case "0":
							canOpen = (v.x == 0 && v.y < 0);
							break;
						
						case "90":
							canOpen = (v.x < 0 && v.y == 0);
							break;
							
						case "180":
							canOpen = (v.x == 0 && v.y > 0);
							break;
							
						case "270":
							canOpen = (v.x > 0 && v.y == 0);
							break;
						
					}
					
				}
				
				if (canOpen) {
					
					open();
					
					if (_object.playfield.playObjects[e.collider] is PlayObject) {
							
						if (e.collider is MotionObject) MotionObject(e.collider).velocity.scaleBy(0);
						
					}					
					
				}
				
			}
			
		}
		
		//
		//
		override public function end():void {
			_player = null;
			if (_object != null && _object.simObject != null) {
				_object.simObject.removeEventListener(CollisionEvent.PENETRATION, onCollision);
				_object.simObject.removeEventListener(CollisionEvent.COLLISION, onCollision);
			}
			super.end();
			
		}
		
	}
	
}