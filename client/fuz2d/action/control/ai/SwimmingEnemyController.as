package fuz2d.action.control.ai {
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import fuz2d.action.behavior.HopBehavior;
	import fuz2d.action.control.PlayObjectController;
	import fuz2d.action.physics.CollisionEvent;
	import fuz2d.action.physics.MotionObject;
	import fuz2d.action.physics.ReactionType;
	import fuz2d.action.physics.Vector2d;
	import fuz2d.action.physics.VelocityObject;
	import fuz2d.action.play.*;
	import fuz2d.library.ObjectFactory;
	import fuz2d.model.object.Symbol;
	import fuz2d.TimeStep;
	import fuz2d.util.*;

	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class SwimmingEnemyController extends PlayObjectController {
		
		public static const FACING_RIGHT:uint = 1;
		public static const FACING_LEFT:uint = 2;
		
		public static const STATE_IDLE:String = "f_idle_stop";
		public static const STATE_BITING:String = "f_bite";	
		
		private var _playObj:PlayObjectMovable;
		
		protected var _mot:MotionObject;
		protected var _left:Vector2d;
		protected var _right:Vector2d;
		protected var _lastJump:Number = 0;
		protected var _jumpCount:Number = 10;
		
		protected var _player:PlayObject;
		protected var _playerNear:Boolean = false;

		// int between 1 and 10;
		protected var _speed:int = 5;
		// int between 1 and 100;
		protected var _aggression:int = 50;
		protected var _weaponsRange:int = 0;
		
		protected var _projectile:String = "";
		protected var _fireDelay:Number = 0;
		protected var _lastFire:Number = 0;
		
		protected var _facing:uint = FACING_LEFT;
		
		//
		//
		public function SwimmingEnemyController (object:PlayObjectControllable, speed:int = 5, aggression:int = 50, weaponsRange:int = 0, projectile:String = "", fireDelay:Number = 0) {
			
			super(object);
			
			_playObj = object as PlayObjectMovable;
			
			_speed = speed;
			_aggression = aggression;
			_weaponsRange = weaponsRange * weaponsRange;
			
			_projectile = projectile;
			_fireDelay = fireDelay;
			
			_object.object.attribs.facing = FACING_RIGHT;
			_object.object.attribs.showHealth = true;
			
		}
		
		override protected function init(object:PlayObjectControllable):void {
			
			super.init(object);
			
			_mot = MotionObject(object.simObject);
			_left = new Vector2d(null, -600, 0);
			_right = new Vector2d(null, 600, 0);
			
			_object.simObject.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);

		}
		
		//
		//
		override public function see(p:PlayObject):void {
			
			super.see(p);
			
			if (_object == null || _object.deleted) {
				end();
				return;
			}
			
			if (p.object.symbolName == "player") {
				
				if (_player == null) _object.eventSound("see");
				_player = p;
				_playerNear = true;
				
			}
			
		}
		
		//
		//
		override public function update (e:Event):void {
			
			if (_ended || !_active || _object.locked) return;
			
			super.update(e);
			
			if (!_mot.sleeping && !_mot.floating) {
				
				if (TimeStep.realTime - _lastFire > 100) Symbol(_object.object).state = STATE_IDLE;
				
				_object.object.attribs.facing = _facing;
			
				if (_mot.inContact && Math.random() * 30 < 2) _playObj.behaviors.add(new HopBehavior());
				
				_object.harm(_object, 0.2);
				
				return;
				
			}
			
			var xv:Number = 0.5 * (_speed / 10);
			
			if (_player != null && _player.deleted) {
				
				_player = null;
				_playerNear = false;
				
			} else if (_playerNear) {
				
				var sqdist:Number = Geom2d.squaredDistanceBetweenPoints(_object.object.point, _player.object.point);
				
				var rangePadding:Number = 0;
				
				if (_player.object.attribs.padding > 0) {
					rangePadding += _player.object.attribs.padding;
					sqdist -= (rangePadding * rangePadding);
				}

							
				if (sqdist > Math.max(200000, _weaponsRange + 200000)) {
						
					_player = null;
					_playerNear = false;
					
					Symbol(_object.object).state = STATE_IDLE;
					
				} else {
					
					if (_object.playfield.map.canSee(_object, _player)) {
							
						var ydist:Number = Math.abs(_player.object.x - _object.object.x);
						
						if (ydist > 300) {
							if (_player.object.x < _object.object.x) {
								_facing = FACING_LEFT;
							} else {
								_facing = FACING_RIGHT;
							}
						}
						
						if (ydist > 50) {
							
							if (_player.object.y + 50 > _object.object.y) {
								_playObj.moveUp(0.5);
							} else {
								_playObj.moveDown(0.5);
							}

						}
						
						if (_player.object.x < _object.object.x - 100 && _facing != FACING_LEFT) {
							Symbol(_object.object).state = STATE_IDLE;
						} else if (_player.object.x > _object.object.x + 100 && _facing != FACING_RIGHT) {
							Symbol(_object.object).state = STATE_IDLE;
						}
						
						xv *= 4;
						
					} else {
						
						_player = null;
						_playerNear = false;
						
					}

				}
				
			}	
			
			_object.object.attribs.facing = _facing;
			
			if (_facing == FACING_RIGHT) {
				_playObj.moveRight(xv);
			} else {
				_playObj.moveLeft(xv);
			}

		}
		
		protected function bite ():void {
			
			if (TimeStep.realTime - _lastFire > _fireDelay) {
				
				var pt:Point = _object.object.point.clone();
				
				if (_facing == FACING_LEFT) pt.x -= _object.simObject.collisionObject.halfX;
				else pt.x += _object.simObject.collisionObject.halfX;
				
				_object.harm(PlayObjectControllable(_player), 25, pt);
				ObjectFactory.effect(null, "puncheffect", true, 1000, pt);	
				_object.eventSound("bite");
				
				_lastFire = TimeStep.realTime;
				
			}
			
		}

		
		//
		//
		protected function onCollision (e:CollisionEvent):void {
			
			if (e.collidee.objectRef.symbolName == "player") {
				
				_player = _object.playfield.playObjects[e.collidee];
				_playerNear = true;
				
				if (_player.object.y - 50 < _object.object.y && (_mot.floating || !_mot.inContact)) {
					
					var biting:Boolean = false;
					
					if (e.contactPoint.x > _object.object.x && _facing == FACING_RIGHT) {
						
						Symbol(_object.object).state = STATE_BITING;
						biting = true;
						
					} else if (e.contactPoint.x < _object.object.x && _facing == FACING_LEFT) {
						
						Symbol(_object.object).state = STATE_BITING;
						biting = true;
						
					}
					
					if (biting) bite();
					
				}

			} else if (!(e.collidee is VelocityObject) && e.collidee.collisionObject.reactionType == ReactionType.BOUNCE) {
				
				if (e.contactPoint.x > _object.object.x + _object.simObject.collisionObject.halfX - 10) {
					
					_facing = FACING_LEFT;
					
					
				} else if (e.contactPoint.x < _object.object.x - _object.simObject.collisionObject.halfX / 2 + 10) {
					
					_facing = FACING_RIGHT;
					
					
				}

			}
			
		}
		
		
		//
		//
		override public function end():void {
			
			if (_object != null && _object.simObject != null) _object.simObject.removeEventListener(CollisionEvent.COLLISION, onCollision);
			
			_playObj = null;
			_mot = null;
			_player = null;
			_object = null;
			
			super.end();
			
		}

	}
	
}