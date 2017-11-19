package fuz2d.action.control.ai {
	
	import flash.events.Event;
	
	import fuz2d.action.behavior.AimBehavior;
	import fuz2d.action.behavior.JumpBehavior;
	import fuz2d.action.behavior.PointBehavior;
	import fuz2d.action.control.PlayObjectController;
	import fuz2d.action.modifier.PushModifier;
	import fuz2d.action.physics.*;
	import fuz2d.action.play.*;
	import fuz2d.library.ObjectFactory;
	import fuz2d.model.object.Biped;
	import fuz2d.TimeStep;
	import fuz2d.util.Geom2d;
	
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class EnemyController extends PlayObjectController {
		
		private var _biped:BipedObject;
		
		private var _bipedMinDist:Number = 0;
		
		protected var _player:PlayObject;
		protected var _playerNear:Boolean = false;

		private var _pointer_lt:PointBehavior;
		
		// int between 1 and 10;
		protected var _speed:int = 5;
		// int between 1 and 100;
		protected var _aggression:int = 50;
		protected var _weaponsRange:int = 0;
		
		private var _aimer_rt:AimBehavior;
		
		private var _lastAttack:int = 0;
		private var _lastApproach:int = 0;
		private var _lastCrouch:int = 0;
		private var _lastKick:int = 0;
		private var _lastSound:int;
		

		//
		//
		public function EnemyController (object:PlayObjectControllable, speed:int = 5, aggression:int = 50, weaponsRange:int = 0) {
		
			super(object);
			
			_biped = object as BipedObject;
			_speed = speed;
			_aggression = aggression;
			_weaponsRange = weaponsRange * weaponsRange;
			
			_object.simObject.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);
			
			_aimer_rt = AimBehavior(_biped.behaviors.add(new AimBehavior([_biped.body.handles.arm_rt], Biped(_biped.object).tools_rt, "good")));
			_aimer_rt.altHandle = _biped.body.handles.arm_lt;
			_aimer_rt.idle = true;
			
			_pointer_lt = PointBehavior(_biped.behaviors.add(new PointBehavior(0, [_biped.body.handles.arm_lt], 0)));
			_pointer_lt.pointCenter = false;
			_pointer_lt.idle = true;
			
			_bipedMinDist = _object.object.width * _object.object.width + 600;
			
			if (Biped(_biped.object).tools_rt.spawn == "spear") _aimer_rt.styleToss = true;
			
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
				
				if (_aimer_rt.idle == false) {
					
					_aimer_rt.targetObject = _player.simObject;
					
				}
				
			}
			
		}
		
		//
		//
		override public function update (e:Event):void {
			
			if (_ended || !_active || _biped.locked || _biped.dying) return;
		
			super.update(e);
			
			var xf:Number;
			
			var ts:int = TimeStep.realTime;
			
			if (_biped.body.tools_rt.action == "aim") {
				
				_aimer_rt.idle = false;
				
			} else {
				
				_aimer_rt.idle = true;
				_aimer_rt.targetObject = null;
				
			}
			
			if (_player != null && _player.deleted) {
				
				_player = null;
				_playerNear = false;
				
			} else if (_playerNear && _player != null && _player.object != null) {
				
				var sqdist:Number = Geom2d.squaredDistanceBetweenPoints(_object.object.point, _player.object.point);
				
				var rangePadding:Number = 0;
				
				if (_player.object.attribs != null && _player.object.attribs.padding > 0) {
					rangePadding += _player.object.attribs.padding;
					sqdist -= (rangePadding * rangePadding);
				}

				var xv:Number = Math.abs(MotionObject(_object.simObject).velocity.x);
				
				if (sqdist - 20000 <= _weaponsRange && _aimer_rt.idle == false) {
					_aimer_rt.fire();
				}
							
				if (sqdist > Math.max(360000, _weaponsRange + 360000)) {
						
					_player = null;
					_playerNear = false;
					_pointer_lt.idle = true;
					_biped.defending = _biped.crouching = false;
					_lastApproach = _lastCrouch = 0;
					
				} else {
						
					if (sqdist > Math.max(14000, _weaponsRange)) {
						
						if (_object.type == "gator" && Math.abs(_object.object.y - _player.object.y) < 100 + rangePadding) {
							
							_biped.attack("middle", "head");
							
						}
						
						if (_object.type == "ninja" && Math.abs(_object.object.y - _player.object.y) < 100 + rangePadding) {
							
							_biped.attack("middle", "lt");
							
						}
						
						if (_player.object.x < _object.object.x) {
							
							Biped(_object.object).updateStance(Biped.FACING_LEFT);
							
							if (_object.playfield.map.canWalk(PlayObjectMovable(_object), PlayfieldMap.LEFT)) {
								
								xf = 1;
								if (_aggression < 100 && !_object.playfield.map.canWalk(PlayObjectMovable(_object), PlayfieldMap.LEFT_DOUBLE)) xf = 0.5;
							
								if (xv < 100) {
									_biped.moveLeft(xf * _biped.speedFactor);
								} else {
									_biped.moveLeft(0.25 * _biped.speedFactor);
								}
								
							} else {
								
								if (_object.playfield.map.canJump(PlayObjectMovable(_object), PlayfieldMap.LEFT)) {
									if (!_biped.crouching && !_biped.jumping && !_biped.attacking && _biped.standing) _biped.behaviors.add(new JumpBehavior(JumpBehavior.LEFT, 0.5));
								} else {
									MotionObject(_biped.simObject).velocity.x *= 0.5;
								}
								
							}
							
						} else {
							
							Biped(_object.object).updateStance(Biped.FACING_RIGHT);
							
							if (_object.playfield.map.canWalk(PlayObjectMovable(_object), PlayfieldMap.RIGHT)) {
								
								xf = 1;
								if (_aggression < 100 && !_object.playfield.map.canWalk(PlayObjectMovable(_object), PlayfieldMap.RIGHT_DOUBLE)) xf = 0.5;
								
								if (xv < 100) {
									_biped.moveRight(xf * _biped.speedFactor);
								} else {
									_biped.moveRight(0.25 * _biped.speedFactor);
								}
								
							} else {
								
								if (_object.playfield.map.canJump(PlayObjectMovable(_object), PlayfieldMap.RIGHT)) {
									if (!_biped.crouching && !_biped.jumping && !_biped.attacking && _biped.standing) _biped.behaviors.add(new JumpBehavior(JumpBehavior.RIGHT, 0.5));
								} else {
									MotionObject(_biped.simObject).velocity.x *= 0.5;
								}
								
							}
							
						}
						
						if (_biped.floating) {
							_biped.moveUp();
							if (_player.object.x < _object.object.x) _biped.moveLeft(1);
							else _biped.moveRight(1);
						}
						
						_pointer_lt.idle = true;
						_biped.defending = _biped.crouching = false;
						_lastApproach = _lastCrouch = 0;
						
					} else {
						
						if (_object.type == "gator" && Math.abs(_object.object.y - _player.object.y) < 100 + rangePadding) {
							
							_biped.attack("middle", "head");
							
						}
						
						if (_player.object.x < _object.object.x) {
							Biped(_object.object).updateStance(Biped.FACING_LEFT);
						} else {
							Biped(_object.object).updateStance(Biped.FACING_RIGHT);
						}
						
						if (sqdist < _weaponsRange * 0.25) {
							
							if (_player.object.x > _object.object.x) {
								if (_object.playfield.map.canWalk(PlayObjectMovable(_object), PlayfieldMap.LEFT_DOUBLE)) {	
									_biped.moveLeft(0.25 * _biped.speedFactor * (_aggression / 50));
								} else {
									_biped.moveRight(0.125 * _biped.speedFactor * (_aggression / 50));
								}
							} else {
								if (_object.playfield.map.canWalk(PlayObjectMovable(_object), PlayfieldMap.RIGHT_DOUBLE)) {
									_biped.moveRight(0.25 * _biped.speedFactor * (_aggression / 50));
								} else {
									_biped.moveLeft(0.125 * _biped.speedFactor * (_aggression / 50));
								}
							}
						
						}
						
						if (_lastApproach == 0) _lastApproach = ts;
						
						if (ts - _lastCrouch > 2000 && !_biped.body.tools_rt.blunt) {
							_biped.crouching = (BipedObject(_player).defending && ts - _lastApproach > 500);
							_lastCrouch = ts;
						}
						
						if (!_biped.attacking && 
							_weaponsRange > 16000 && 
							sqdist < _bipedMinDist &&
							ts - _lastKick > 2000) {
							
							_biped.attack("high", "back", "kick");
							_lastKick = ts;
							
							if (_player && _player is PlayObjectControllable &&
								!(_player is BipedObject && BipedObject(_player).rolling)) {
								var pushval:Number = (_object.object.x < _player.object.x) ? 100 : -100;
								if (_player is BipedObject && BipedObject(_player).jumping) pushval *= 0.5;
								PlayObjectControllable(_player).modifiers.add(new PushModifier(pushval, 50));
								if (Math.random() * 10 < 3 && _player is BipedObject) BipedObject(_player).fall();
							}
							
							return;
							
						}
						
						if (canAttack && _aimer_rt.idle == true) {
							var hand:String = "rt";
							if (_object.object.x < _player.object.x && (_biped.body.tools_lt.action == "scratch" || _biped.body.tools_lt.action == "punch")) {
								hand = "lt";
							}
							if (_player.object.y - rangePadding > _object.object.y) {
								if (!_biped.crouching && !_biped.jumping && !_biped.attacking && _biped.standing) _biped.behaviors.add(new JumpBehavior(JumpBehavior.CENTER, 1));
								if (_biped.crouching && !_biped.body.tools_rt.blunt) _biped.attack("low");
								else _biped.attack("high", hand);
							} else {
								if (_biped.crouching && !_biped.body.tools_rt.blunt) _biped.attack("low");
								else _biped.attack("middle", hand);
							}
						}
						
						if (BipedObject(_player).attacking && _biped.body.tools_lt.action == "point" && ts - _lastApproach > 2000) {
							_pointer_lt.idle = false;
							_biped.defending = true;
							_lastApproach = 0;
						}
						
						if (_biped.defending && _biped.body.tools_rt.spawns && sqdist < 10000) {
							if (_object.playfield.map.canJump(PlayObjectMovable(_object), PlayfieldMap.LEFT)) {
								if (!_biped.jumping && !_biped.attacking && _biped.standing) _biped.behaviors.add(new JumpBehavior(JumpBehavior.LEFT, 0.5));
							}
						}
						
					}

				}
				
			}
				
		}
		
		//
		//
		public function get canAttack ():Boolean  {

			if (_aggression > 100) return true;
			if (TimeStep.realTime - _lastAttack > (10 - _speed) * 200 && Math.random() * 100 < _aggression) {
			
				_lastAttack = TimeStep.realTime;
				return true;
				
			}
			
			return false;
			
		}
		
		
		//
		//
		protected function onCollision (e:CollisionEvent):void {
			
			if (_player == null && e.collider.objectRef.symbolName == "player") {
				
				_player = _object.playfield.playObjects[e.collider];

			}
			if (e.collider.objectRef.symbolName == "player") {
				if (e.contactSpeed > 350 && 
					e.contactPoint.y >= _biped.object.y + _biped.object.height * 0.5 - _biped.object.width * 0.25) {
					
					_biped.fall();
					
					ObjectFactory.effect(null, "headbounceeffect", true, 1000, e.contactPoint, 0);
					
				}
			}
			
			if (TimeStep.realTime - _lastSound > 1500 && e.collidee.objectRef != _biped.object) {
				if (e.contactSpeed > 500 && 
					e.contactPoint.y <= _biped.object.y - _biped.object.height * 0.5 + _biped.object.width * 0.25) {
					
					_object.eventSound("hard_landing");
					_lastSound = TimeStep.realTime;

				}
				
			}
			
		}
		
		//
		//
		override public function end():void {
			
			_biped = null;
			_player = null;
			if (_object != null && _object.simObject != null) _object.simObject.removeEventListener(CollisionEvent.COLLISION, onCollision);
			_object = null;
			
			super.end();
			
		}
		
	}
	
}