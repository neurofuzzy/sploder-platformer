package fuz2d.action.control.ai {
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import fuz2d.action.control.PlayObjectController;
	import fuz2d.action.physics.CollisionEvent;
	import fuz2d.action.physics.MotionObject;
	import fuz2d.action.physics.ReactionType;
	import fuz2d.action.physics.SimulationObject;
	import fuz2d.action.physics.Vector2d;
	import fuz2d.action.play.*;
	import fuz2d.library.ObjectFactory;
	import fuz2d.model.object.Mech;
	import fuz2d.TimeStep;
	import fuz2d.util.*;

	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class MechEnemyController extends PlayObjectController {
		
		private var _playObj:PlayObjectMovable;
		
		protected var _mot:MotionObject;
		protected var _left:Vector2d;
		protected var _right:Vector2d;
		protected var _lastJump:Number = 0;
		protected var _jumpCount:Number = 10;
		
		protected var _player:PlayObject;
		protected var _playerNear:Boolean = false;

		protected var _hasTurret:Boolean = false;
		protected var _mech:Mech;
		
		// int between 1 and 10;
		protected var _speed:int = 5;
		// int between 1 and 100;
		protected var _aggression:int = 50;
		protected var _weaponsRange:int = 0;
		
		protected var _projectile:String = "";
		protected var _fireDelay:Number = 0;
		protected var _lastFire:Number = 0;
		protected var _lastStep:int = 0;
		
		//
		//
		public function MechEnemyController (object:PlayObjectControllable, speed:int = 5, aggression:int = 50, weaponsRange:int = 0, projectile:String = "", fireDelay:Number = 0) {
			
			super(object);
			
			_playObj = object as PlayObjectMovable;
			
			_speed = speed;
			_aggression = aggression;
			_weaponsRange = weaponsRange * weaponsRange;
			
			_projectile = projectile;
			_fireDelay = fireDelay;
			
		}
		
		override protected function init(object:PlayObjectControllable):void {
			
			super.init(object);
			
			_mot = MotionObject(object.simObject);
			_left = new Vector2d(null, -1200, 2400);
			_right = new Vector2d(null, 1200, 2400);
			
			_object.simObject.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);
			
			_mech = Mech(_object.object);

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
				
				if (_player == null) _object.eventSound("see", 1.5);
				_player = p;
				_playerNear = true;
				
			}
			
		}
		
		//
		//
		override public function update (e:Event):void {
			
			if (_ended || !_active || _object.locked) return;
			
			super.update(e);
			
			var xf:Number;
			
			if (_jumpCount < 10) applyJump();
			else _mot.gravity = 1;
			
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

				var xv:Number = Math.abs(MotionObject(_object.simObject).velocity.x);
							
				if (sqdist > Math.max(400000, _weaponsRange + 400000)) {
						
					_player = null;
					_playerNear = false;
					
					_mech.state = Mech.STATE_IDLE;
					
				} else {
					
					if (_player.object.x < _object.object.x) {
						_mech.facing = Mech.FACING_LEFT;
					} else {
						_mech.facing = Mech.FACING_RIGHT;
					}
						
					if (sqdist > 14000 + _weaponsRange) {
						
						
						if (_player.object.x < _object.object.x) {
							
							if (_object.playfield.map.canWalk(PlayObjectMovable(_object), PlayfieldMap.LEFT)) {
								
								xf = 1;
								if (!_object.playfield.map.canWalk(PlayObjectMovable(_object), PlayfieldMap.LEFT_DOUBLE)) xf = 0.5;
							
								if (_mot.inContact) _mot.addForce(_left, xf);
								
							}
							
						} else {
							
							if (_object.playfield.map.canWalk(PlayObjectMovable(_object), PlayfieldMap.RIGHT)) {
								
								xf = 1;
								if (!_object.playfield.map.canWalk(PlayObjectMovable(_object), PlayfieldMap.RIGHT_DOUBLE)) xf = 0.5;
								
								if (xv < 200) {
									if (_mot.inContact) _mot.addForce(_right, xf);
								}
								
							}
							
						}
						
						_mech.state = Mech.STATE_IDLE;
						
					} else {
						
						if (sqdist < _weaponsRange) {
							
							if (_player.object.y - 60 > _object.object.y && TimeStep.realTime - _lastJump > 1000 && _mot.inContact) {
								
								_jumpCount = 0;
								_lastJump = TimeStep.realTime;
								_object.eventSound("jump");
								
								applyJump();

							}
							
							if (_player.object.x > _object.object.x) {
								if (_object.playfield.map.canWalk(PlayObjectMovable(_object), PlayfieldMap.LEFT_DOUBLE)) {	
									if (_mot.inContact) _mot.addForce(_left, 0.5);
								}
							} else {
								if (_object.playfield.map.canWalk(PlayObjectMovable(_object), PlayfieldMap.RIGHT_DOUBLE)) {
									_playObj.moveRight(0.25);
									if (_mot.inContact) _mot.addForce(_right, 0.5);
								}
							}
						
						}
						
						_mech.state = Mech.STATE_PUNCHING;
						
					}

				}
				
			}			
			
			_mech.updateStance();
		
			if (_mech.attribs.punchPoint) {
				
				var pt:Point = _mech.attribs.punchPoint;
				
				punch(pt);
				
				_mech.attribs.punchPoint = null;
				
			}
			
			if (_object && _object.object) {
				
				if (_object.object.attribs.stepped && TimeStep.realTime - _lastStep > 500) {
					_object.eventSound("step");
					_object.object.attribs.stepped = false;
					_lastStep = TimeStep.realTime;
				}
				
				if (_object.object.attribs.switchedfeet) {
					_object.eventSound("walk");
					_object.object.attribs.switchedfeet = false;
				}
				
			}

		}
		
		protected function punch (pt:Point):void {
			
			var obj:SimulationObject = _object.simObject.simulation.getObjectAtPoint(pt, _object.simObject, -1, ReactionType.BOUNCE, 90 + Math.random() * 12);
					
			if (obj) {
				
				var pobj:PlayObject = _object.playfield.playObjects[obj];
				
				if (pobj is PlayObjectControllable) {

					if (obj is MotionObject) {
					
						var pv:Vector2d = new Vector2d();
						pv.x = (_mech.facing == Mech.FACING_LEFT) ? -10000 : 10000;
						if (MotionObject(obj).inverseMass > 0) pv.x /= MotionObject(obj).inverseMass;
						
						MotionObject(obj).addForce(pv);
						
					}
					
					_object.harm(PlayObjectControllable(pobj), 25, pt);
					ObjectFactory.effect(null, "puncheffect", true, 1000, pt);
					_object.eventSound("punch");
					
				} else {
					
					if (pobj.simObject && pobj.simObject.collisionObject.reactionType == ReactionType.BOUNCE) {
						_object.eventSound("punch");
					} else {
						_object.eventSound("miss");
					}
					
				}
				
			} else {
				
				_object.eventSound("miss");
				
			}
			
		}

		
		//
		//
		protected function applyJump ():void {

			if (_mech.facing == Mech.FACING_LEFT) {
				_mot.addForce(new Vector2d(null, -3500, 3500));
			} else {
				_mot.addForce(new Vector2d(null, 3500, 3500));
			}
			_mot.gravity = 0.5;
			
			_jumpCount++;
			
		}

		
		//
		//
		protected function onCollision (e:CollisionEvent):void {
			
			if (_player == null && e.collider.objectRef.symbolName == "player") {
				
				_player = _object.playfield.playObjects[e.collider];
				
			}
			
			if (e.collider.objectRef.symbolName == "player") {
				
				if (e.collider.position.x > e.collidee.position.x) {
					_mot.addForce(_right, 1.5);
				} else {
					_mot.addForce(_left, 1.5);
				}
				
			}
			
		}
		
		
		//
		//
		override public function end():void {
			
			if (_object != null && _object.simObject != null) _object.simObject.removeEventListener(CollisionEvent.COLLISION, onCollision);
			
			_mech = null;
			_playObj = null;
			_mot = null;
			_player = null;
			_object = null;
			
			super.end();
			
		}

	}
	
}