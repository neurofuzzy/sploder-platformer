/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.physics {
	
	import flash.events.Event;
	import flash.geom.Point;
	import fuz2d.model.object.Biped;
	import fuz2d.model.object.Object2d;
	import fuz2d.util.Geom2d;

	public class MotionObject extends VelocityObject {
		
		public static const EPSILON:Number = 0.00001;
		
		public var acceleration:Vector2d;
		
		public var contactObjVelocity:Vector2d;
		public var contactObjFriction:Number = 0.5;
		
		public function get relativeVelocity ():Vector2d {
			
			return velocity.getDifference(contactObjVelocity);
			
		}
		
		public static var zeroVelocity:Vector2d;

		public var torque:Number;
		public function get torqueNegligible ():Boolean { return Math.abs(torque) < EPSILON; }
		public var angularAcceleration:Number;
		public function get angularAccelerationNegligible ():Boolean { return Math.abs(angularAcceleration) < EPSILON; }
			
		public var forces:Vector2d;
		public var angularForces:Number;
		public function get angularForcesNegligible ():Boolean { return Math.abs(angularForces) < EPSILON; }
		
		protected var _originalGravity:Number = 1;
		public function get originalGravity():Number { return _originalGravity; }
		
		public var gravity:Number = 1;
		public var defyGravity:Boolean = false;
		
		public function get floating ():Boolean { return _wasBuoyant; }
		protected var _wasBuoyant:Boolean = false;
		public var buoyant:Boolean = false;
		protected var _originalBuoyancy:Number = 0;
		protected var _buoyancy:Number = 0;
		public function get buoyancy():Number { return _buoyancy; }
		public function set buoyancy(value:Number):void 
		{
			if (_buoyancy == 0) _originalBuoyancy = value;
			_buoyancy = Math.min(_originalBuoyancy, value);
		}
		public var leakage:Number = 0;
		
		protected var _floatPenetration:Number = 0;
		public function get floatPenetration():Number { return _floatPenetration; }
		public function set floatPenetration(value:Number):void {
			_floatPenetration = Math.max(_floatPenetration, value);
		}
		
		
		public function get isClimbing ():Boolean { return _wasNearClimbable && climbEngaged; }
		public function get canClimb ():Boolean { return _wasNearClimbable; }
		protected var _wasNearClimbable:Boolean = false;
		public var nearClimbable:Boolean = false;
		
		public function get canBoard ():Boolean { return _wasNearBoardable; }
		protected var _wasNearBoardable:Boolean = false;
		public var nearBoardable:Boolean = false;
		
		public var climbEngaged:Boolean = false;
		
		protected var _swingPoint:Point;
		
		protected var _desiredSwingLength:Number = 0;
		protected var _swingLength:Number = 0;
		
		public function get swingPoint():Point { return _swingPoint; }
		
		public function set swingPoint(value:Point):void 
		{
			_swingPoint = value;
			if (_swingPoint == null) {
				_desiredSwingLength = _swingLength = 0;
			} else {
				_desiredSwingLength = _swingLength = Geom2d.distanceBetweenPoints(_swingPoint, objectRef.point);
			}
			
		}
	
		public function get swingLength():Number { return _swingLength; }
		
		public function set swingLength(value:Number):void 
		{
			_desiredSwingLength = value;
		}
		
		public function get swinging ():Boolean { return (_swingPoint != null); }
		
		protected var _originalDamping:Number;
		public function get originalDamping():Number { return _originalDamping; }
		public var damping:Number;
		public var rotationDamping:Number;
		
		public var inertialThresholdSquared:Number = 400;
		public var frictionThresholdSquared:Number = 32000;
		
		public var nosleep:Boolean = false;
		public var noroll:Boolean = false;
		
		private var _sleeping:Boolean = true;
		private var _readyToSleep:Boolean = false;
		public function get sleeping():Boolean { return _sleeping; }
		
		private var _pCache:Object;
		
		public function set sleeping(value:Boolean):void 
		{
			
			if (!value) _sleeping = false;
			else if (!_sleeping) _readyToSleep = true;
			if (nosleep) _sleeping = _readyToSleep = false;
			
		}

		
		public var restingVelocity:Number = 400;
		
		public var maxVel:Number = 650;
		
		protected var _bankAmount:Number = 0;
		public function get bankAmount():Number { return _bankAmount; }
		public function set bankAmount(value:Number):void { _bankAmount = value; }
		
		override public function get inMotion ():Boolean {
			return !(sleeping || (velocity.negligible && forces.negligible && torqueNegligible && angularForcesNegligible));
		}
		
		public var ignoreOtherMotionObjects:Boolean = false;
		
		//
		//
		public function MotionObject (simulation:Simulation, obj:Object2d, collisionObjectType:uint, reactionType:uint = ReactionType.BOUNCE, mass:Number = 0, gravityMultiplier:Number = 1, damping:Number = 0.995, rotationDamping:Number = 0.1, ignoreSameType:Boolean = false, collideOnlyStatic:Boolean = false, nosleep:Boolean = false, buoyancy:Number = 0, leakage:Number = 0) {
			
			super(simulation, obj, collisionObjectType, reactionType, ignoreSameType, collideOnlyStatic);
		
			if (zeroVelocity == null) zeroVelocity = new Vector2d(null, 0, 0);
		
			contactObjVelocity = zeroVelocity;
			
			velocity = new Vector2d();
			acceleration = new Vector2d();
			
			torque = 0;
			angularAcceleration = 0;		
			
			forces = new Vector2d();
			angularForces = 0;
			
			_pCache = { };
			
			if (mass == 0) {
				_inverseMass = 0;
			} else {
				this.mass = mass;
			}
			
			_originalGravity = gravity = (!isNaN(gravityMultiplier)) ? gravityMultiplier : gravity;
			
			_originalDamping = this.damping = damping;
			this.rotationDamping = rotationDamping;
			
			restingVelocity = 0 - _simulation.gravity * gravity / _inverseMass;

			this.ignoreSameType = ignoreSameType;
			
			if (nosleep) sleeping = false;
			this.nosleep = nosleep;
			
			this.buoyancy = buoyancy;
			this.leakage = leakage;
			
		}
		
		//
		//
		public function addForce (force:Vector2d, multiplier:Number = 1):void {
			
			if (_sleeping) _sleeping = false;
			
			if (hasFiniteMass) {
		
				if (force.angular) {
					angularForces += force.x;
				} else {
					forces.addScaled(force, multiplier);
				}

			}			
			
		}
		
		//
		//
		override public function applyImpulse (impulse:Vector2d):void {
			
			if (_sleeping) _sleeping = false;
			
			if (impulse.angular) {
				
				torque += impulse.x;
				
			} else {
				
				velocity.addBy(impulse);
				
			}
			
		}
		
		//
		//
		public function addOrientedForce (force:Vector2d):void {
			
			if (_sleeping) _sleeping = false;
			
			if (hasFiniteMass) {
		
				if (force.angular) {
					angularForces += force.x;
				} else {
					forces.addRotated(force, _objectRef.rotation);
				}
				
			}			
			
		}
		
		//
		//
		public function addForceScaled (force:Vector2d, magnitude:Number):void {
			
			if (_sleeping) _sleeping = false;
			
			if (hasFiniteMass) {
				
				if (force.angular) {
					angularForces += force.x * magnitude;
				} else {
					forces.addScaled(force, magnitude);
				}
				
			}			
			
		}
		
		//
		//
		protected function pull (duration:Number = 0):void {

			if (_swingPoint != null) {
				
				var pt:Point = _swingPoint;
				var len:Number = _swingLength;
				var dist:Number = Geom2d.distanceBetweenPoints(pt, objectRef.point);
				
				var pullForce:Vector2d = new Vector2d();
				pullForce.alignToPoint(pt);
				pullForce.subtractBy(position);
				
				if (pt.y > objectRef.y && (dist >= len || _desiredSwingLength < _swingLength)) {
				
					var g:Vector2d = new Vector2d(null, 0, 0 - _simulation.gravity);
					//g.invert();
					var tension:Number = g.getMagnitudeInDirectionOf(pullForce);
					pullForce.normalize(1);
					if (_desiredSwingLength < _swingLength) tension *= 2;
					pullForce.scaleBy(tension);
					addForce(pullForce);
					
				}
				
				if (_desiredSwingLength < _swingLength || dist > len) {
					tension = velocity.getMagnitudeInDirectionOf(pullForce);
					pullForce.normalize(1);
					if (_desiredSwingLength < _swingLength && pt.y > objectRef.y) tension += (_swingLength - _desiredSwingLength) * 33;
					pullForce.scaleBy(tension);
					velocity.subtractBy(pullForce);
				}
				
				if (inContact && !swinging && velocity.x < EPSILON) velocity.x = 0;
				if (inContact && !swinging && velocity.y < EPSILON) velocity.y = 0;
				
				if (_desiredSwingLength > _swingLength && dist > _swingLength) _swingLength = Math.min(_desiredSwingLength, dist);
				else if (_desiredSwingLength < _swingLength && dist < _swingLength) _swingLength = Math.max(dist, _desiredSwingLength);

			}
			
		}
		
		//
		//
		override public function integrate (duration:Number = 0):void {
			
			if (_sleeping) return;
			
			preIntegratePosition.alignToPoint(_objectRef.point);
			
			if (duration == 0) {
				duration = _simulation.currentDuration;
			}
			
			if (swinging) pull(duration);
			
			//
			if (velocity.squareMagnitude > inertialThresholdSquared) {
				position.addScaled(velocity, duration);
			}
			
			acceleration.addScaled(forces, _inverseMass);
			
			if (buoyant) {
				acceleration.scaleBy(0.5);
				acceleration.addScaled(velocity.getInverse().getScaled(1 + velocity.squareMagnitude * 0.00002), 1.8);
				position.y += Simulation.sineTime * 0.3;
				objectRef.y += Simulation.sineTime * 0.3;
			}
			
			if (climbEngaged && !canClimb) climbEngaged = false;
			
			velocity.addScaled(acceleration, duration);
			velocity.scaleBy(Math.pow(damping, duration));
			
			velocity.clamp(maxVel);

			//

			_objectRef.rotation += torque / duration;
			
			angularAcceleration += angularForces * _inverseMass;
			torque += (angularAcceleration / duration);
			torque *= rotationDamping;
			
			if (!noroll && rotationDamping > 0 && collisionObject.type == CollisionObject.CIRCLE && !_wasBuoyant) {
				_objectRef.rotation = _objectRef.x % 360 * Geom2d.dtr * 120 / _objectRef.width;	
			}
			
			if (_bankAmount > 0) {
				_objectRef.rotation = Math.max(-0.5, Math.min(0.5, velocity.x / 1000 * _bankAmount));
			}

			//
			clearForces();	
			updateObjectRef();
			
			if (_readyToSleep && _wasInContact) {

				_pCache.oox = _pCache.ox;
				_pCache.ooy = _pCache.oy;
				_pCache.ox = _pCache.x;
				_pCache.oy = _pCache.y;
				_pCache.x = _objectRef.x >> 0;
				_pCache.y = _objectRef.y >> 0;

				if (_pCache.oox == _pCache.ox && _pCache.ox == _pCache.x && _pCache.ooy == _pCache.oy && _pCache.oy == _pCache.y) {

					_simulation.applyCollisions(this);
					_readyToSleep = false;
					_sleeping = true;
					
				}
				
			}

		}
		
		//
		//
		public function clearForces ():void {
			
			forces.x = forces.y = 0;
			acceleration.x = acceleration.y = 0;
			
			angularForces  = 0;
			if (inContact) angularAcceleration = 0;
			
			if (buoyant) {
				acceleration.y = Math.max(-200, Math.min(600, buoyancy) * (_floatPenetration / 30));
				if (buoyancy > 0) buoyancy -= leakage;
			} else if (leakage > 0 && _buoyancy < _originalBuoyancy) {
				_buoyancy += leakage;
			}
			
			_wasBuoyant = buoyant;
			buoyant = false;
			_floatPenetration = 0;
			
			_wasNearClimbable = nearClimbable;
			nearClimbable = false;
			
			_wasNearBoardable = nearBoardable;
			nearBoardable = false;
			
			if (!inContact) contactObjVelocity = zeroVelocity;
			
			if (velocity.negligible) velocity.reset();
			if (torqueNegligible) torque = 0;
			
			_wasInContact = inContact;
			inContact = controllerActive = false;
			contactPressure = 0;
			

		}
		
	}
	
}
