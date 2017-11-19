/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.physics {
	
	import fuz2d.action.physics.*;
	import fuz2d.Fuz2d;
	import fuz2d.util.Geom2d;
	
	public class CollisionResolver {
		
		private static var _velocityLimit:Number = 300;
		private static var _penetrationThreshold:Number = 30;
		
		private static var _impulse:Vector2d;
		private static var _frictionReaction:Vector2d;
		private static var _offset:Vector2d;
		
		private static var _pX:Number;
		private static var _pY:Number;
		private static var _scaleX:Number;
		private static var _scaleY:Number;
		
		private static var _massDifference:Number;
		private static var _contactSpeed:Number;
		
		private static var _resolveB:Boolean;
		
		private static var _reactionType:uint;
		
		private static var _initialized:Boolean = false;
		
		private static var _torque:Number;
		private static var _torqueForce:Vector2d;
		private static var _correctionForce:Vector2d;
		
		private static var _ce:CollisionEvent;
		private static var _pe:CollisionEvent;
		
		//
		//
		private static function initialize ():void {
			
			_pX = _pY = _scaleX = _scaleY = 0;
			
			_massDifference = 1;
			_resolveB = false;
			
			_impulse = new Vector2d();
			_frictionReaction = new Vector2d();
			_offset = new Vector2d();
			_torqueForce = new Vector2d(null, 0, 0, true)
			_correctionForce = new Vector2d();
			
			_ce = new CollisionEvent(CollisionEvent.COLLISION);
			_pe = new CollisionEvent(CollisionEvent.PENETRATION);
			
			_initialized = true;
			
		}
		
		//
		//
		public static function resolvePenetration (objA:CollisionObject, objB:CollisionObject, normal:Vector2d, penetration:Number, invert:Boolean = false, report:Boolean = false):void {
		
			if (!_initialized) initialize();
			
			var simA:SimulationObject = objA.simObjectRef;
			var simB:SimulationObject = objB.simObjectRef;
			
			var aM:Boolean = (simA is MotionObject);
			var bM:Boolean = (simB is MotionObject);
			
			_reactionType = ReactionType.getType(objA, objB);

			if (penetration > _penetrationThreshold && (report || (_reactionType <= ReactionType.BOUNCE || _reactionType == ReactionType.REPORT_ONLY))) {
				
				_pe.collider = simA;
				_pe.collidee = simB;
				_pe.contactPoint = null;
				_pe.contactSpeed = NaN;
				_pe.contactNormal = normal;
				
				simA.dispatchEvent(_pe);
				simB.dispatchEvent(_pe);
				simA.simulation.dispatchEvent(_pe);	

			}
			if (_reactionType == ReactionType.FLOAT && simA is MotionObject) {
				if (simA.position.y > simB.position.y) {
					MotionObject(simA).floatPenetration = penetration;
				}
			}
			
			if (_reactionType > ReactionType.ABOVE_ONLY) return;

			if ((objA.ignoreFocusObj && simB == simB.simulation.focalPoint) || 
				(objB.ignoreFocusObj && simA == simA.simulation.focalPoint)) return;
			
			if (_reactionType == ReactionType.ABOVE_ONLY && objA.position.y - objA.halfY < objB.position.y + objB.halfY && (simA is VelocityObject && VelocityObject(simA).velocity.y > 0)) return;

			if (!(aM) && simB is MotionObject) return resolvePenetration(objB, objA, normal, penetration, !invert);
			
			_pX = normal.x * penetration;
			_pY = normal.y * penetration;
				
			_resolveB = false;
			_massDifference = 1;
			
			if (simA.inverseMass > 0 && simB.inverseMass > 0) _massDifference = simA.inverseMass / simB.inverseMass;

			//if (objB.type == CollisionObject.POLYGON) _massDifference = 1;
			
			if (aM && penetration > 10 && 
				objB.reactionType == ReactionType.BOUNCE &&
				objB.type != CollisionObject.RAMP &&
				objB.type != CollisionObject.STAIR) {
				MotionObject(simA).swingLength += penetration / 2;
				MotionObject(simA).sticking = true;
			}

			if (aM && bM) {
				
				_pX *= 0.5;
				_pY *= 0.5;
				_resolveB = true;
				
			} else if (simB is VelocityObject) {
				
				if (VelocityObject(simB).lockX == false) {
					_pX *= 0.5;
					if (Math.abs(normal.x) > 0.5) VelocityObject(simB).sticking = true;
				}
				
				if (VelocityObject(simB).lockY == false && penetration > VelocityObject(simB).maxPenetration) {
					_pY *= 0.5;
					//MotionObject(simA).velocity.y *= 0.5;
					VelocityObject(simB).sticking = true;
				}
				
				_resolveB = true;
				
			}
				
			_scaleX = _pX;
			_scaleY = _pY;
			
			if (aM && bM) {
				
				_scaleX *= _massDifference;
				//if (!simB.onGround)
				_scaleY *= _massDifference;
				
			}
			
			if (invert) {
				_scaleX *= -1;
				_scaleY *= -1;
			}
			
			if (aM) {
				
				simA.objectRef.x -= _scaleX;
				simA.objectRef.y -= _scaleY;
				simA.getPosition();
				
			} else if (simA is VelocityObject && simA is CompoundObject) {
				
				simA.objectRef.x -= _scaleX;
				simA.objectRef.y -= _scaleY;
				simA.getPosition();
				
				return;
			}
			
			if (_resolveB) {

				_scaleX = _pX / _massDifference;
				_scaleY = _pY / _massDifference;
				
				if (invert) {
					_scaleX *= -1;
					_scaleY *= -1;
				}
				
				if (simB is MotionObject) {
					
					simB.objectRef.x += _scaleX;
					//if (!simB.onGround)
					simB.objectRef.y += _scaleY;
								
				} else {
					
					if (VelocityObject(simB).lockX == false) simB.objectRef.x += _scaleX;
					if (VelocityObject(simB).lockY == false && penetration > VelocityObject(simB).maxPenetration) simB.objectRef.y += _scaleY;
				
				}

				simB.getPosition();
					
			}
			
		}
		
		private static function clamp (val:Number, min:Number = -30, max:Number = 30):Number {
			return Math.max(min, Math.min(max, val));
		}
		
		//
		//
		public static function resolveCollision (objA:CollisionObject, objB:CollisionObject, contactPoint:Vector2d, normal:Vector2d, invert:Boolean = false):Number {

			if (!_initialized) initialize();
			
			var simA:SimulationObject = objA.simObjectRef;
			var simB:SimulationObject = objB.simObjectRef;
			
			if (!(simA is MotionObject) && simB is MotionObject) return resolveCollision(objB, objA, contactPoint, normal);
			
			if (!(simA is MotionObject)) return 0;
			var mA:MotionObject = MotionObject(simA);
			
			_reactionType = ReactionType.getType(objA, objB);
			
			if ((objA.ignoreFocusObj && simB == simB.simulation.focalPoint) || 
				(objB.ignoreFocusObj && simA == simA.simulation.focalPoint)) _reactionType = ReactionType.REPORT_ONLY;
				
			_contactSpeed = mA.velocity.getMagnitudeInDirectionOf(normal);
			
			if (isNaN(_contactSpeed)) _contactSpeed = 0;
			
			if (_reactionType == ReactionType.ABOVE_ONLY && mA.velocity.y > 0) _contactSpeed = Math.min(_contactSpeed, 50);
			
			_impulse.alignTo(normal);
			
			_impulse.scaleBy(_contactSpeed);
			
			_frictionReaction.alignTo(mA.velocity);
			_frictionReaction.x += _impulse.x;
			_frictionReaction.y += _impulse.y;
			
			if (_contactSpeed >= _velocityLimit) {
				_impulse.scaleBy((_contactSpeed > Simulation.threshold) ? 15 * simA.cor * simB.cor : 0.8);
			}
			
			_contactSpeed = Math.abs(_contactSpeed);
			
			_ce.collider = simA;
			_ce.collidee = simB;
			_ce.contactPoint = contactPoint;
			_ce.contactSpeed = _contactSpeed;
			_ce.contactNormal = normal;
			_ce.reactionType = _reactionType
			
			if (simA.hasEventListener(CollisionEvent.COLLISION)) simA.dispatchEvent(_ce);
			if (simB.hasEventListener(CollisionEvent.COLLISION)) simB.dispatchEvent(_ce);
			simA.simulation.dispatchEvent(_ce);
			
			_frictionReaction.invert();
			_torque = _frictionReaction.magnitude;
			
			_frictionReaction.scaleBy(1 - Math.max(simA.cof, simB.cof));
			
			if (simB.cof == 0) _frictionReaction.scaleBy(0);
			
			switch (_reactionType) {

				case ReactionType.ABOVE_ONLY:
				
					if (objA.position.y - objA.halfY < objB.position.y + objB.halfY && (simA is VelocityObject && VelocityObject(simA).velocity.y > 0)) return 0;

					
				case ReactionType.BOUNCE: 
				case ReactionType.BOUNCE_ALL_BUT_FOCUSOBJ:
					
					mA.addForceScaled(_frictionReaction, 1 / mA.inverseMass);
			
					if (_impulse.y < 0) simA.inContact = true;
					simA.contactPressure += _contactSpeed;
					mA.contactObjFriction = simB.cof;

					_impulse.invert();
					
					mA.addForceScaled(_impulse, 1 / mA.inverseMass);
					
					if (simB is MotionObject) {
						
						_massDifference = mA.inverseMass / MotionObject(simB).inverseMass;
						
						_impulse.scaleBy(0.5);
						
						_impulse.invert();
						_impulse.scaleBy(1 / _massDifference);
						
						//if (simA.onGround || simB.onGround) _impulse.y = 0;
						
						MotionObject(simB).addForce(_impulse);
						_impulse.invert();
						_impulse.scaleBy(_massDifference);
						_impulse.scaleBy(_massDifference);
						
						MotionObject(simA).addForce(_impulse);
						
					} else if (simB is VelocityObject) {
						
						if (simB.inMotion) {
							
							if (VelocityObject(simB).velocity.y >= 0) {
								
								mA.acceleration.addScaled(VelocityObject(simB).velocity, 1 / mA.inverseMass);
								mA.contactObjVelocity = VelocityObject(simB).velocity;
								
							}
							
							if (mA.objectRef && mA.objectRef.attribs.parentObject) {
								if (mA.objectRef.attribs.parentObject.simObject is VelocityObject && simB is VelocityObject) {
									mA.velocity.x += VelocityObject(simB).velocity.x * 0.19;
								}
							}
							
						}
						
						if (Math.abs(objB.position.x - objA.position.x) < objB.halfX && objA.position.y > objB.position.y) {
							_correctionForce.y = 800 / mA.inverseMass;
							mA.acceleration.addScaled(_correctionForce, 1);
						}
						
						
					}
					
					if (normal.x == 0 && normal.y == -1) {
						//if (!(objB is VelocityObject)) {
							simA.onGround = true;
						//}
					}
					
						
					return _impulse.squareMagnitude;
					
				case ReactionType.SLOW:
				
					_frictionReaction.alignTo(mA.velocity);
					_frictionReaction.invert();
					_frictionReaction.scaleBy(0.5);
					
					mA.addForce(_frictionReaction);
					
					simA.inContact = true;
					simA.contactPressure += _contactSpeed;

					return 0;
				
				case ReactionType.CLIMB:
				
					mA.nearClimbable = true;
					
					if (mA.isClimbing) {
						if (!mA.defyGravity) {
							mA.defyGravity = true;
							mA.velocity.x *= 0.85;
							if (mA.velocity.y > 0) {
								mA.velocity.y *= 0.65;
							} else {
								mA.velocity.y *= 0.55;
							}
						}
					}

					
					return 0;
				
				case ReactionType.DEFY_GRAVITY:
				
					mA.addForce(_frictionReaction);
					
					simA.inContact = true;
					simA.contactPressure += _contactSpeed;

					mA.defyGravity = true;
					return 0;
					
				case ReactionType.FLOAT:

					if (objA.radius < objB.radius || simA.position.y < simB.position.y) {

						mA.buoyant = true;
						mA.defyGravity = true;

					} else {
						mA.buoyant = true;
					}
					
					return 0;
					
			}
				
			return 0;
		
		}		
		
	}
	
}