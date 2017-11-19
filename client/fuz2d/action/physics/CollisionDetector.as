/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.physics {

	import flash.geom.Point;

	import fuz2d.action.physics.*;
	import fuz2d.model.object.Object2d;
	import fuz2d.util.*;
	
	public class CollisionDetector {
		
		protected static const EPSILON:Number = 0.00001;
		
		private static var _len:Number;
		private static var _offset:Number;
		private static var _dist:Number;
		private static var _separation:Number
		private static var _contactDistance:Number;
		private static var _penetration:Number;
		private static var _stuckPossible:Boolean;
		private static var _stuck:Boolean;
		
		private static var _closestPoints:Object;
		
		private static var _closestPt:Vector2d;
		private static var _contactNormal:Vector2d;
		private static var _relCenter:Vector2d;
		private static var _delta:Vector2d;
		private static var _loc:Vector2d;
		
		private static var _capPtA:Vector2d;
		private static var _capPtB:Vector2d;
		private static var _linePtA:Vector2d;
		private static var _linePtB:Vector2d;
		private static var _linePtA2:Vector2d;
		private static var _linePtB2:Vector2d;
		private static var _closestPtA:Vector2d;
		private static var _closestPtB:Vector2d;
		
		private static var _pt:Point;
		
		private static var _initialized:Boolean = false;
		
		private static var _oRef:Object2d;
		private static var _pRef:Vector2d;
		private static var _rad:Number;
		private static var _dx:Number;
		private static var _dy:Number;
		
		private static var _circle:SimulationObject;
		
		//
		//
		public static function initialize (simulation:Simulation):void {
			
			_len = _offset = _dist = _separation = _contactDistance = _penetration = 0;
			
			_closestPoints = { };
			
			_closestPt = new Vector2d();
			_contactNormal = new Vector2d();
			_relCenter = new Vector2d();
			_delta = new Vector2d();
			_loc = new Vector2d();
			
			_pt = new Point();
			
			_capPtA = new Vector2d();
			_capPtB = new Vector2d();
			_linePtA = new Vector2d();
			_linePtB = new Vector2d();
			_linePtA2 = new Vector2d();
			_linePtB2 = new Vector2d();
			_closestPtA = new Vector2d();
			_closestPtB = new Vector2d();
			
			_initialized = true;
			
			_circle = new SimulationObject(simulation, new Object2d(null), CollisionObject.CIRCLE, ReactionType.BOUNCE);
			_circle.objectRef.width = _circle.objectRef.height = 20;
			_circle.collisionObject.dimX = _circle.collisionObject.dimY = 10;
			_circle.collisionObject.halfX = _circle.collisionObject.halfY = 10;
			_circle.collisionObject.radius = 10;
			_circle.position.y = 10000;
			
			
		}
		
		public static function uninitialize ():void {
			
			_closestPoints = { };
			
			_closestPt = null;
			_contactNormal = null;
			_relCenter = null;
			_delta = null;
			_loc = null;
			
			_pt = null;
			
			_capPtA = null;
			_capPtB = null;
			_linePtA = null;
			_linePtB = null;
			_linePtA2 = null;
			_linePtB2 = null;
			_closestPtA = null;
			_closestPtB = null;
			
			if (_circle) _circle.destroy();
			
			_initialized = false;
			
		}
		
		
		//
		//
		public static function detect (objA:CollisionObject, objB:CollisionObject, resolve:Boolean = true):Boolean {

			var type:uint = CollisionType.getType(objA, objB);
			var collided:Boolean = false;
			
			if (!_initialized || objA == null || objB == null) return false;
			
			_oRef = null;
			_pRef = null;
			
			switch (type) {
				
				case CollisionType.CIRCLE_LINE:
				
					collided = detectCircleOnLine(objB, objA, resolve);
					break;
				
				case CollisionType.CIRCLE_CIRCLE:

					if (objB.simObjectRef is MotionObject) collided = detectCircleOnCircle(objB, objA, resolve);
					else if (objA.simObjectRef is MotionObject) collided = detectCircleOnCircle(objA, objB, resolve);
					else if (objB.simObjectRef is CompoundObject && objA.simObjectRef is VelocityObject) {
						collided = detectCircleOnCircle(objA, objB, resolve, true);
					}
					break;
					
				case CollisionType.CAPSULE_CIRCLE:
					
					collided = detectCapsuleOnCircle(objA, objB, resolve);
					break;
					
				case CollisionType.CAPSULE_CAPSULE:
					
					collided = detectCapsuleOnCapsule(objB, objA, resolve);
					break;
					
				case CollisionType.OBB_CIRCLE:
					
					collided = detectCircleOnOBB(objA, objB, resolve);
					break;
					
				case CollisionType.OBB_OBB:
					
					collided = detectCircleOnOBB(objA, objB, resolve);
					break;
					
				case CollisionType.OBB_CAPSULE:
					
					collided = detectCapsuleOnOBB(objA, objB, resolve);
					break;
					
				case CollisionType.POLYGON_CIRCLE:
				
					collided = detectCircleOnPolygon(objA, objB, resolve);
					break;
				
				case CollisionType.POLYGON_CAPSULE:
				
					collided = detectCapsuleOnPolygon(objA, objB, resolve);
					break;
					
				case CollisionType.POLYGON2_CIRCLE:
				
					collided = detectCircleOnPolygon2(objA, objB, resolve);
					break;
				
				case CollisionType.POLYGON2_CAPSULE:
				
					collided = detectCapsuleOnPolygon2(objA, objB, resolve);
					break;
					
				case CollisionType.BOX_CIRCLE:
					
					collided = detectCircleOnBox(objA, objB, resolve);
					break;
					
				case CollisionType.BOX_CAPSULE:
					
					collided = detectCapsuleOnBox(objA, objB, resolve);
					break;
					
				case CollisionType.RAMP_CIRCLE:
					
					collided = detectCircleOnRamp(objA, objB, resolve);
					break;
					
				case CollisionType.RAMP_CAPSULE:
					
					collided = detectCapsuleOnRamp(objA, objB, resolve);
					break;
					
				case CollisionType.STAIR_CIRCLE:
					
					collided = detectCircleOnStair(objA, objB, resolve);
					break;
					
				case CollisionType.STAIR_CAPSULE:
					
					collided = detectCapsuleOnStair(objA, objB, resolve);
					break;

			}
			
			return collided;
			
		}
		
		//
		//
		public static function positionRelative (source:CollisionObject, obj:Point):Point {
			
			_pt.x = obj.x - source.position.x;
			_pt.y = obj.y - source.position.y;
			
			var mag:Number = _pt.length;
			var rot:Number = Math.atan2(_pt.y, _pt.x);
			
			return Point.polar(mag, source.simObjectRef.objectRef.rotation + rot);
			
		}
		
		//
		//
		public static function positionWorld (source:CollisionObject, pt:Point):Point {
			
			_pt.x = pt.x;
			_pt.y = pt.y;
			
			var mag:Number = _pt.length;
			var rot:Number = Math.atan2(_pt.y, _pt.x);
			
			_pt = Point.polar(mag, rot - source.simObjectRef.objectRef.rotation);
			_pt.x += source.position.x;
			_pt.y += source.position.y;
			
			return _pt;
			
		}
		
		//
		//
		public static function pointCheck (pt:Point, obj:CollisionObject, withinDist:Number = 0):Boolean {

			_loc.alignToPoint(pt);
			
			switch (obj.type) {
				
				case CollisionObject.CIRCLE:
				default:
				
					return (_loc.getDifference(obj.position).squareMagnitude < obj.radius * obj.radius + withinDist * withinDist);
					
				case CollisionObject.CAPSULE:
				
					var pt1:Vector2d = obj.position;

					var linePtA:Point = pt1.clone();
					var linePtB:Point = pt1.clone();
					var len:Number;
					
					if (obj.dimX > obj.dimY) {
						len = obj.dimX - obj.dimY;
						linePtA.x -= len * 0.5;
						linePtB.x += len * 0.5;
					} else {
						len = obj.dimY - obj.dimX;
						linePtA.y -= len * 0.5;
						linePtB.y += len * 0.5;
					}

					var closestPt:Vector2d = new Vector2d(Closest.pointClosestTo(_loc, linePtA, linePtB));	
					
					return (_loc.getDifference(closestPt).squareMagnitude < obj.minRadius * obj.minRadius + withinDist * withinDist);
					
				case CollisionObject.OBB:
			
					_loc.subtractBy(obj.position);
					
					return (Math.abs(_loc.x) <= obj.halfX && Math.abs(_loc.y) <= obj.halfY + withinDist);
					
			}
			
		}		
		
		//
		//
		public static function lineSegmentCheck (startPoint:Point, endPoint:Point, obj:CollisionObject):Point {

			var pt:Point;
			//_loc.alignToPoint(pt);
//clearTest();
			switch (obj.type) {
				
				case CollisionObject.CIRCLE:
				default:
				
					pt = Closest.pointClosestTo(obj.position as Point, startPoint, endPoint);
					if (pt.equals(obj.position)) return null;
					_closestPt.alignToPoint(pt);
					
					_delta.alignTo(_closestPt);
					_delta.subtractBy(obj.position);
					
					if (_delta.magnitude <= obj.radius) {
						//trace("hit circle");
						_closestPt.alignToPoint(Geom2d.intersectCircleLine(obj.position.x, obj.position.y, obj.radius, startPoint.x, startPoint.y, endPoint.x, endPoint.y));
						//showSegment(startPoint, endPoint, _closestPt);
						return _closestPt;
					}
					
					return null;
					
				case CollisionObject.CAPSULE:
				
					_linePtA.alignTo(obj.position);
					_linePtB.alignTo(obj.position);

					if (obj.dimX > obj.dimY) {
						_len = obj.dimX - obj.dimY;
						_linePtA.x -= _len * 0.5;
						_linePtB.x += _len * 0.5;
					} else {
						_len = obj.dimY - obj.dimX;
						_linePtA.y -= _len * 0.5;
						_linePtB.y += _len * 0.5;
					}

					_closestPt.alignToPoint(Closest.pointClosestTo(startPoint, _linePtA, _linePtB));
					
					if (!_closestPt.equals(startPoint)) {
						
						pt = Closest.pointClosestTo(_closestPt as Point, startPoint, endPoint);
						_delta.alignToPoint(pt);
						_delta.subtractBy(_closestPt);

						if (_delta.magnitude <= obj.minRadius) {
							//showPoint(pt);
							_closestPt.alignToPoint(Geom2d.intersectCircleLine(pt.x, pt.y, obj.minRadius, startPoint.x, startPoint.y, endPoint.x, endPoint.y));
							//showSegment(startPoint, endPoint, _closestPt, false);
							//trace("close hit", _delta.magnitude);
							return _closestPt;

						}
					
					}
					
					_closestPoints = Closest.closestPtSegmentSegment(_linePtA, _linePtB, startPoint, endPoint);
					
					if (_closestPoints.c1 == undefined || _closestPoints.c2 == undefined) return null;
						
					_closestPt = _closestPoints.c1;
					_delta = _closestPoints.c2;
					_delta.subtractBy(_closestPt);
					_contactNormal = _delta.normalizedCopy;
					
					_separation = _delta.magnitude;
					_contactDistance = obj.minRadius;
					_penetration = _contactDistance - _separation;
					
					if (_separation < _contactDistance) {

						_closestPt.addScaled(_contactNormal, obj.minRadius);
						//showSegment(startPoint, endPoint, _closestPt);	
						return _closestPt;
						
					}
					
					return null;
					
				case CollisionObject.OBB:
			
					pt = Closest.pointClosestTo(obj.position as Point, startPoint, endPoint);
					if (pt.equals(obj.position)) return null;

					_closestPt.alignToPoint(pt);
					
					_delta.alignTo(_closestPt);
					_delta.subtractBy(obj.position);

					if (_delta.magnitude <= obj.radius) {
						//trace("hit obb");
						_closestPt.alignToPoint(Geom2d.intersectCircleLine(obj.position.x, obj.position.y, obj.radius, startPoint.x, startPoint.y, endPoint.x, endPoint.y));
						_delta.alignTo(_closestPt);
						_delta.subtractBy(obj.position);
						if (Math.abs(_delta.x) > Math.abs(_delta.y)) {
							if (_delta.x > 0) {
								_closestPt.x = obj.position.x + obj.dimX * 0.5;
							} else {
								_closestPt.x = obj.position.x - obj.dimX * 0.5;
							}
						} else {
							if (_delta.y > 0) {
								_closestPt.y = obj.position.y + obj.dimY * 0.5;
							} else {
								_closestPt.y = obj.position.y - obj.dimY * 0.5;
							}							
						}
						
						//showSegment(startPoint, endPoint, _closestPt);
						return _closestPt;
					}
					
					return null;
					
			}
			
		}
		
		//
		//
		private static function detectCircleOnLine (line:CollisionObject, circle:CollisionObject, resolve:Boolean = true):Boolean {

			var closestPt:Vector2d = new Vector2d(Closest.ptPointSegment(circle.position, line));
			
			var separation:Number = closestPt.getDifference(circle.position).magnitude;
			var contactDistance:Number = circle.radius;

			if (separation > contactDistance) return false; // no collision
			
			var penetration:Number = contactDistance - separation;

			if (resolve) {
				
				var contactNormal:Vector2d = closestPt.getDifference(circle.position);
				contactNormal.normalize(1);
				
				if (penetration > 0) CollisionResolver.resolvePenetration(circle, line, contactNormal, penetration);

				var contactPoint:Vector2d = circle.position.copy;
				contactPoint.addScaled(contactNormal, 0 - contactDistance);

				CollisionResolver.resolveCollision(circle, line, contactPoint, contactNormal);
				
			}
	
			return true;
			
		}
		
		// 33
		//
		private static function detectCircleOnCircle (objA:CollisionObject, objB:CollisionObject, resolve:Boolean = true, onlyPenetration:Boolean = false):Boolean {

			_delta.alignTo(objB.position);
			_delta.subtractBy(objA.position);
			
			_separation = _delta.squareMagnitude;
			_contactDistance = objA.radius + objB.radius;

			if (_separation >= _contactDistance * _contactDistance) return false; // no collision

			if (resolve) {
				
				_separation = Math.sqrt(_separation);
				_penetration = _contactDistance - _separation;
				
				if (_penetration > EPSILON) {
					
					_contactNormal = _delta.normalizedCopy;
					
					CollisionResolver.resolvePenetration(objA, objB, _contactNormal, _penetration, false, onlyPenetration);
				
					if (!onlyPenetration) {
						
						_offset = 2 * (objB.radius / objA.radius);
						
						_closestPt.alignTo(objB.position);
						
						_closestPt.addScaled(_contactNormal, 0 - objA.radius);

						CollisionResolver.resolveCollision(objA, objB, _closestPt, _contactNormal);
						
					}
				}
	
			}
	
			return true;
			
		}
		
		
		// 43
		//
		private static function detectCapsuleOnCircle (capsule:CollisionObject, circle:CollisionObject, resolve:Boolean = true, onlyPenetration:Boolean = false):Boolean {

			// early out goes here
			if (Math.abs(circle.position.x - capsule.position.x) - capsule.radius > circle.radius ||
				Math.abs(circle.position.y - capsule.position.y) - capsule.radius > circle.radius) {
					return false;
				}
			
			_linePtA.alignTo(capsule.position);
			_linePtB.alignTo(capsule.position);

			if (capsule.dimX > capsule.dimY) {
				_len = capsule.dimX - capsule.dimY;
				_linePtA.x -= _len * 0.5;
				_linePtB.x += _len * 0.5;
			} else {
				_len = capsule.dimY - capsule.dimX;
				_linePtA.y -= _len * 0.5;
				_linePtB.y += _len * 0.5;
			}

			_closestPt.alignToPoint(Closest.pointClosestTo(circle.position, _linePtA, _linePtB));	
			_delta.alignTo(circle.position);
			_delta.subtractBy(_closestPt);
			
			_separation = _delta.squareMagnitude;
			_contactDistance = capsule.minRadius + circle.radius;
			
			if (!onlyPenetration && _separation < circle.radius && circle.reactionType == ReactionType.BOUNCE) {
				if (circle.ignoreFocusObj && capsule.simObjectRef == capsule.simObjectRef.simulation.focalPoint) return true; 
				capsule.position.alignTo(capsule.simObjectRef.prevPosition);
				capsule.simObjectRef.updateObjectRef();
				return detectCapsuleOnCircle(capsule, circle, true, true);
			}
			
			if (_separation >= _contactDistance * _contactDistance) return false; // no collision

			if (resolve) {
				
				_separation = Math.sqrt(_separation);
				_penetration = _contactDistance - _separation;
				
				if (_penetration > EPSILON) {
					
					_contactNormal = _delta.normalizedCopy;
					CollisionResolver.resolvePenetration(capsule, circle, _contactNormal, _penetration);
					
					if (!onlyPenetration) {
						_closestPt.addScaled(_contactNormal, capsule.minRadius);
						CollisionResolver.resolveCollision(capsule, circle, _closestPt, _contactNormal);
					}
					
				}
				
			}
	
			return true;
			
		}
		
		
		// 44
		//
		private static function detectCapsuleOnCapsule (capsule1:CollisionObject, capsule2:CollisionObject, resolve:Boolean = true):Boolean {

			// early out
			_delta.alignTo(capsule1.position);
			_delta.subtractBy(capsule2.position);

			if (_delta.squareMagnitude >= (capsule1.radius + capsule2.radius) * (capsule1.radius + capsule2.radius)) return false; // no collision
			//
			
			_linePtA.alignTo(capsule1.position);
			_linePtB.alignTo(capsule1.position);
			
			if (capsule1.dimX > capsule1.dimY) {
				_len = capsule1.dimX - capsule1.dimY;
				_linePtA.x -= _len * 0.5;
				_linePtB.x += _len * 0.5;
			} else {
				_len = capsule1.dimY - capsule1.dimX;
				_linePtA.y -= _len * 0.5;
				_linePtB.y += _len * 0.5;
			}
			
			_linePtA2.alignTo(capsule2.position);
			_linePtB2.alignTo(capsule2.position);
			
			if (capsule2.dimX > capsule2.dimY) {
				_len = capsule2.dimX - capsule2.dimY;
				_linePtA2.x -= _len * 0.5;
				_linePtB2.x += _len * 0.5;
			} else {
				_len = capsule2.dimY - capsule2.dimX;
				_linePtA2.y -= _len * 0.5;
				_linePtB2.y += _len * 0.5;
			}
			
			_closestPoints = Closest.closestPtSegmentSegment(_linePtA, _linePtB, _linePtA2, _linePtB2);
			
			if (_closestPoints.c1 == undefined || _closestPoints.c2 == undefined) return false;
				
			_closestPt = _closestPoints.c1;
			_delta = _closestPoints.c2;
			_delta.subtractBy(_closestPt);
			_contactNormal = _delta.normalizedCopy;
			
			_separation = _delta.squareMagnitude;
			_contactDistance = capsule1.minRadius + capsule2.minRadius;
			
			if (_separation >= _contactDistance * _contactDistance) return false; // no collision

			if (resolve) {
				
				_separation = Math.sqrt(_separation);
				_penetration = _contactDistance - _separation;
				
				if (_penetration > EPSILON) CollisionResolver.resolvePenetration(capsule1, capsule2, _contactNormal, _penetration);
				
				_closestPt.addScaled(_contactNormal, capsule1.minRadius);

				CollisionResolver.resolveCollision(capsule1, capsule2, _closestPt, _contactNormal);
	
			}
	
			return true;
			
		}
		
		
		// 53
		//
		private static function detectCircleOnOBB (box:CollisionObject, circle:CollisionObject, resolve:Boolean = true):Boolean {

			_relCenter.alignTo(circle.position);
			_relCenter.subtractBy(box.position);
			
			// early out goes here
			if (Math.abs(_relCenter.x) - circle.radius > box.halfX ||
				Math.abs(_relCenter.y) - circle.radius > box.halfY) {
					return false;
				}
				
			_dist = _relCenter.x;
			if (_dist > box.halfX) _dist = box.halfX;
			if (_dist < -box.halfX) _dist = -box.halfX;
			_closestPt.x = _dist;
			
			_dist = _relCenter.y;
			if (_dist > box.halfY) _dist = box.halfY;
			if (_dist < -box.halfY) _dist = -box.halfY;
			_closestPt.y = _dist;
			
			if (box.reactionType == ReactionType.BOUNCE && 
				circle.reactionType == ReactionType.BOUNCE &&
				_closestPt.x == _relCenter.x && _closestPt.y == _relCenter.y) {
				detectCircleOnCircle(circle, box, true, true);
			}
			
			_delta.alignTo(_closestPt);
			_delta.subtractBy(_relCenter);
			_dist = _delta.squareMagnitude;

			if (_dist > circle.radius * circle.radius) return false;

			if (resolve) {
				
				_penetration = circle.radius - Math.sqrt(Math.abs(_dist));

				if (_penetration > EPSILON) {
					_contactNormal.alignTo(_relCenter);
					_contactNormal.subtractBy(_closestPt);
					_contactNormal.normalize(1);
					_contactNormal.invert();
					_closestPt.addBy(box.position);
					CollisionResolver.resolvePenetration(circle, box, _contactNormal, _penetration);
					CollisionResolver.resolveCollision(circle, box, _closestPt, _contactNormal);
				}	
				
			}

			return true;
			
		}
		
		// 54
		//
		private static function detectCapsuleOnOBB (box:CollisionObject, capsule:CollisionObject, resolve:Boolean = true):Boolean {
			
			_relCenter.alignTo(capsule.position);
			_relCenter.subtractBy(box.position);
			
			// early out goes here
			if (Math.abs(_relCenter.x) - capsule.radius > box.halfX ||
				Math.abs(_relCenter.y) - capsule.radius > box.halfY) {
					return false;
				}

			_linePtA.alignTo(_relCenter);
			_linePtB.alignTo(_relCenter);
			
			if (capsule.dimX > capsule.dimY) {
				_len = capsule.dimX - capsule.dimY;
				_linePtA.x -= _len * 0.5;
				_linePtB.x += _len * 0.5;
			} else {
				_len = capsule.dimY - capsule.dimX;
				_linePtA.y -= _len * 0.5;
				_linePtB.y += _len * 0.5;
			}
			
			_closestPt.alignTo(_relCenter);

			if (_linePtA.x >= box.halfX) _closestPt.x = box.halfX;
			else if (_linePtB.x <= 0 - box.halfX) _closestPt.x = 0 - box.halfX;
			else if (_linePtA.y == _linePtB.y) _closestPt.x = Math.min(_linePtB.x, Math.max(0, _linePtA.x));
			
			if (_linePtA.y >= box.halfY) _closestPt.y = box.halfY;
			else if (_linePtB.y <= 0 - box.halfY) _closestPt.y = 0 - box.halfY;
			else if (_linePtA.x == _linePtB.x) _closestPt.y = Math.min(_linePtB.y, Math.max(0, _linePtA.y));
			
			if (_linePtA.y == _linePtB.y) _relCenter.x = Math.min(_linePtB.x, Math.max(0, _linePtA.x));
			else if (_linePtA.x == _linePtB.x) _relCenter.y = Math.min(_linePtB.y, Math.max(0, _linePtA.y));
			
			_dist = _closestPt.getDifference(_relCenter).squareMagnitude;
			
			if (_dist > capsule.minRadius * capsule.minRadius) {
				return false;
			}
			
			if (box.reactionType == ReactionType.BOUNCE && 
				capsule.reactionType == ReactionType.BOUNCE &&
				_closestPt.x == _relCenter.x && _closestPt.y == _relCenter.y) {
				return detectCapsuleOnCircle(capsule, box, true);
			}
			

			if (resolve) {
				
				_penetration = capsule.minRadius - Math.sqrt(Math.abs(_dist));

				if (_penetration > EPSILON) {
					_contactNormal.alignTo(_relCenter);
					_contactNormal.subtractBy(_closestPt);
					_contactNormal.normalize(1);
					_contactNormal.invert();
					_closestPt.addBy(box.position);
					
					CollisionResolver.resolvePenetration(capsule, box, _contactNormal, _penetration);
					CollisionResolver.resolveCollision(capsule, box, _closestPt, _contactNormal);
					
					if (box.reactionType == ReactionType.BOUNCE && 
						capsule.reactionType == ReactionType.BOUNCE &&
						_penetration > 20) {
						
						var cpx:Number = capsule.simObjectRef.prevPosition.x;
						var cpy:Number = capsule.simObjectRef.prevPosition.y;
						var cx:Number = capsule.position.x;
						var cy:Number = capsule.position.y;
						var bx:Number = box.position.x;
						var by:Number = box.position.y;
						
						if (_contactNormal.x == 0) {
							if ((cy < by && cpy > by) || (cy > by && cpy < by)) {
								capsule.simObjectRef.setPositionToPrevious();
								return detectCapsuleOnCircle(capsule, box, true);
							}
						}
						
						if (_contactNormal.y == 0) {
							if ((cx < bx && cpx > bx) || (cx > bx && cpx < bx)) {
								capsule.simObjectRef.setPositionToPrevious();
								return detectCapsuleOnCircle(capsule, box, true);
							}
						}
					
					}

				}
				
			}

			return true;
			
		}
		
		// 63
		//
		private static function detectCircleOnPolygon (polygon:CollisionObject, circle:CollisionObject, resolve:Boolean = true):Boolean {

			var n:Number;
			var cradius:Number = circle.radius;
		
			_relCenter.alignToPoint(positionRelative(polygon, circle.position));
			
			// early out goes here
			if (Math.abs(_relCenter.x) - circle.radius > polygon.halfX ||
				Math.abs(_relCenter.y) - circle.radius > polygon.halfY) {
					return false;
				}
				
			//if (circle is CompoundObject) return false;
		
			var minSeparation:Number = 100000000000;
			var contact:Boolean = false;
			var pen:Number = 0;
			
			var vm:Number = VelocityObject(circle.simObjectRef).velocity.magnitude;
			var danger:Boolean = (vm * 0.033 > circle.radius);
			
			if (danger) cradius = vm * 0.033;
			if (danger) VelocityObject(circle.simObjectRef).velocity.scaleBy(circle.radius / cradius);
			
			var cr:Number = cradius * cradius * 3;
			
			var didContact:Boolean = false;
			
			for (var i:int = polygon.vertices.length - 1; i > 0; i--) {
				
				if (polygon.connections[i] == true) {
					
					contact = false;
					
					_linePtA.alignToPoint(polygon.vertices[i - 1]);
					_linePtB.alignToPoint(polygon.vertices[i]);
					
					_delta.alignTo(_linePtA);
					_delta.subtractBy(_linePtB);
		
					_closestPt.alignToPoint(Closest.pointClosestTo(_relCenter, _linePtA, _linePtB));

					_delta.alignTo(_relCenter);
					_delta.subtractBy(_closestPt);
					
					_separation = _delta.squareMagnitude;
					_contactDistance = cradius;
					
					if (_separation < _contactDistance * _contactDistance) {
						
						if (_separation < minSeparation * minSeparation) {
							
							_closestPtB.alignTo(_closestPt);
							_contactNormal = _delta.normalizedCopy;
							
							didContact = contact = true;
							
							if (contact && resolve) {
								
								if (polygon.simObjectRef.objectRef.rotation != 0) {
									
									_contactNormal.rotate(0 - polygon.simObjectRef.objectRef.rotation);
									_closestPtB.alignToPoint(positionWorld(polygon, _closestPtB as Point));
								
								} else {
									
									_closestPtB.addBy(polygon.position);
									
								}
								
								_circle.position.x = _closestPtB.x;
								_circle.position.y = _closestPtB.y;
								
								_offset = Geom2d.angleBetweenPoints(_circle.position, circle.position);
								_circle.position.x += _contactNormal.x * 10;
								_circle.position.y -= _contactNormal.y * 10;
								_circle.updateObjectRef();
								
								detectCircleOnCircle(circle, _circle.collisionObject, true, false);
								
							}	
							
						}
						
					}
					
				}
				
			}

			return didContact;
			
		}
		
		// 64
		//
		private static function detectCapsuleOnPolygon (polygon:CollisionObject, capsule:CollisionObject, resolve:Boolean = true):Boolean {

			var n:Number;
			var cradius:Number = capsule.radius;
		
			_relCenter.alignToPoint(positionRelative(polygon, capsule.position));
			
			// early out goes here
			if (Math.abs(_relCenter.x) - capsule.radius > polygon.halfX ||
				Math.abs(_relCenter.y) - capsule.radius > polygon.halfY) {
					return false;
				}
				
			var minSeparation:Number = 100000000000;
			var contact:Boolean = false;
			var pen:Number = 0;
			
			var vm:Number = VelocityObject(capsule.simObjectRef).velocity.magnitude;
			var danger:Boolean = (vm * 0.033 > capsule.radius);
			
			if (danger) cradius = vm * 0.033;
			if (danger) VelocityObject(capsule.simObjectRef).velocity.scaleBy(capsule.radius / cradius);
			
			var cr:Number = cradius * cradius * 3;
			
			var didContact:Boolean = false;
			
			var totalContacts:int = 0;
			
			for (var i:int = polygon.vertices.length - 1; i > 0; i--) {
				
				if (polygon.connections[i] == true) {
					
					contact = false;
					
					_linePtA.alignToPoint(polygon.vertices[i - 1]);
					_linePtB.alignToPoint(polygon.vertices[i]);
					
					_delta.alignTo(_linePtA);
					_delta.subtractBy(_linePtB);
		
					_closestPt.alignToPoint(Closest.pointClosestTo(_relCenter, _linePtA, _linePtB));

					_delta.alignTo(_relCenter);
					_delta.subtractBy(_closestPt);
					
					_separation = _delta.squareMagnitude;
					_contactDistance = cradius;
					
					if (_separation < _contactDistance * _contactDistance) {
						
						if (_separation < minSeparation * minSeparation) {
							
							_closestPtB.alignTo(_closestPt);
							_contactNormal = _delta.normalizedCopy;
							
							didContact = contact = true;
							
							if (contact && resolve) {
								
								if (polygon.simObjectRef.objectRef.rotation != 0) {
									
									_contactNormal.rotate(0 - polygon.simObjectRef.objectRef.rotation);
									_closestPtB.alignToPoint(positionWorld(polygon, _closestPtB as Point));
								
								} else {
									
									_closestPtB.addBy(polygon.position);
									
								}
								
								_circle.position.x = _closestPtB.x;
								_circle.position.y = _closestPtB.y;
								
								_offset = Geom2d.angleBetweenPoints(_circle.position, capsule.position);
								_circle.position.x += _contactNormal.x * 10;
								_circle.position.y -= _contactNormal.y * 10;

								detectCircleOnCircle(capsule, _circle.collisionObject, true, false);
								
								totalContacts++;
								
								if (totalContacts > 1) return true;
								
							}	
							
						}
						
					}
					
				}
				
			}

			return didContact;
			
		}

		
		
		
		
		

		// 63
		//
		private static function detectCircleOnPolygon2 (polygon:CollisionObject, circle:CollisionObject, resolve:Boolean = true):Boolean {

			var n:Number;
			var cradius:Number = circle.radius;
		
			_relCenter.alignToPoint(positionRelative(polygon, circle.position));
			
			// early out goes here
			if (Math.abs(_relCenter.x) - circle.radius > polygon.halfX ||
				Math.abs(_relCenter.y) - circle.radius > polygon.halfY) {
					return false;
				}
		
			var minSeparation:Number = 100000000000;
			var contact:Boolean = false;
			var pen:Number = 0;
			
			var vm:Number = MotionObject(circle.simObjectRef).velocity.magnitude;
			var danger:Boolean = (vm * 0.033 > circle.radius);
			
			if (danger) cradius = vm * 0.033;
			if (danger) MotionObject(circle.simObjectRef).velocity.scaleBy(circle.radius / cradius);
			
			for (var i:int = polygon.vertices.length - 1; i > 0; i--) {
				
				_linePtA.alignToPoint(polygon.vertices[i - 1]);
				_linePtB.alignToPoint(polygon.vertices[i]);
				
				_delta.alignTo(_linePtA);
				_delta.subtractBy(_linePtB);
	
				if (_delta.squareMagnitude >= Geom2d.squaredDistanceBetweenPoints(_linePtA, _relCenter) - cradius * cradius) {
				
					_closestPt.alignToPoint(Closest.pointClosestTo(_relCenter, _linePtA, _linePtB));

					_delta.alignTo(_relCenter);
					_delta.subtractBy(_closestPt);
					
					_separation = _delta.squareMagnitude;
					_contactDistance = cradius;
					
					if (_separation < _contactDistance * _contactDistance) {
						
						if (_separation < minSeparation * minSeparation) {
							
							_loc.alignTo(_linePtA);
							_loc.subtract(_linePtB);
							n = _loc.getDotProduct(_relCenter);

							if (n > 0 || !contact) {
								
								_separation = Math.sqrt(_separation);
								_penetration = _contactDistance - _separation;
								
								_linePtA2.alignTo(_linePtA);
								
								_linePtB2.alignTo(_linePtB);
								
								_contactNormal = _delta.normalizedCopy;
								pen = _penetration;	
								
								minSeparation = _separation;
								_closestPtB.alignTo(_closestPt);
								
								contact = true;
							
							}
							
						}
						
					}
				
				}
				
			}
				
			if (contact && resolve) {
			
				if (polygon.simObjectRef.objectRef.rotation != 0) {
					
					_contactNormal.rotate(0 - polygon.simObjectRef.objectRef.rotation);

					_closestPtB.alignToPoint(positionWorld(polygon, _closestPtB as Point));
				
				} else {
					
					_closestPtB.addBy(polygon.position);
					
				}

				
				if (pen > 0) CollisionResolver.resolvePenetration(polygon, circle, _contactNormal, pen);
				
				_closestPtB.addScaled(_contactNormal, cradius);

				CollisionResolver.resolveCollision(polygon, circle, _closestPtB, _contactNormal);

				MotionObject(circle.simObjectRef).angularForces *= 0;	

				return true;

			}
			
			return false;
			
		}
		
		// 64
		//
		private static function detectCapsuleOnPolygon2 (polygon:CollisionObject, capsule:CollisionObject, resolve:Boolean = true):Boolean {
			
			_relCenter.alignToPoint(positionRelative(polygon, capsule.position as Point));
			
			// early out goes here
			if (Math.abs(_relCenter.x) - capsule.radius > polygon.halfX ||
				Math.abs(_relCenter.y) - capsule.radius > polygon.halfY) {
					return false;
				}
			
			_pRef = capsule.position;
			
			_capPtA.alignTo(_pRef);
			_capPtB.alignTo(_pRef);
			
			if (capsule.dimX > capsule.dimY) {
				_len = capsule.dimX - capsule.dimY;
				_capPtA.x -= _len * 0.5;
				_capPtB.x += _len * 0.5;
			} else {
				_len = capsule.dimY - capsule.dimX;
				_capPtA.y -= _len * 0.5;
				_capPtB.y += _len * 0.5;
			}
			
			_capPtA.alignToPoint(positionRelative(polygon, _capPtA));
			_capPtB.alignToPoint(positionRelative(polygon, _capPtB));
			
			var minSeparation:Number = 100000000000;
			var contact:Boolean = false;
			var pen:Number = 0;
			
			for (var i:int = polygon.vertices.length - 1; i > 0; i--) {
				
				_linePtA.alignToPoint(polygon.vertices[i - 1]);
				_linePtB.alignToPoint(polygon.vertices[i]);
				
				_delta.alignTo(_linePtA);
				_delta.subtractBy(_linePtB);
	
				if (_delta.squareMagnitude >= Geom2d.squaredDistanceBetweenPoints(_linePtA, _relCenter) - capsule.radius * capsule.radius) {
				
					_closestPoints = Closest.closestPtSegmentSegment(_capPtA, _capPtB, _linePtA, _linePtB);
				
					if (_closestPoints.c1 == undefined || _closestPoints.c2 == undefined) return false;
								
					_relCenter.alignToPoint(_closestPoints.c1);

					_delta.alignTo(_linePtA);
					_delta.subtractBy(_linePtB);
		
					if (_delta.squareMagnitude >= Geom2d.squaredDistanceBetweenPoints(_linePtA, _relCenter) - capsule.minRadius * capsule.minRadius) {
					
						_closestPt.alignToPoint(Closest.pointClosestTo(_relCenter, _linePtA, _linePtB));

						_delta.alignTo(_relCenter);
						_delta.subtractBy(_closestPt);
						
						_separation = _delta.squareMagnitude;
						_contactDistance = capsule.minRadius;

						if (_separation < _contactDistance * _contactDistance) {
							
							if (_separation < minSeparation * minSeparation) {

								_separation = Math.sqrt(_separation);
								_penetration = _contactDistance - _separation;
								
								_linePtA2.alignTo(_linePtA);
								
								_linePtB2.alignTo(_linePtB);
								
								_contactNormal = _delta.normalizedCopy;
								pen = _penetration;	
								
								minSeparation = _separation;
								_closestPtB.alignTo(_closestPt);

								contact = true;
								
							}
							
						}
					
					}
					
				}
				
			}
				
			if (contact && resolve) {
		
				if (polygon.simObjectRef.objectRef.rotation != 0) {
					
					_contactNormal.rotate(0 - polygon.simObjectRef.objectRef.rotation);

					_closestPtB.alignToPoint(positionWorld(polygon, _closestPtB as Point));
				
				} else {
					
					_closestPtB.addBy(polygon.position);
	
				}

				if (pen > 0) CollisionResolver.resolvePenetration(polygon, capsule, _contactNormal, pen);
				
				_closestPtB.addScaled(_contactNormal, capsule.minRadius);

				CollisionResolver.resolveCollision(polygon, capsule, _closestPtB, _contactNormal);
				
				return true;

			}
			
			return false;
			
		}	
		
		// 73
		//
		private static function detectCircleOnBox (box:CollisionObject, circle:CollisionObject, resolve:Boolean = true):Boolean {

			var rC:Point = positionRelative(box, circle.position);
			var relCenter:Vector2d = new Vector2d(rC);
			
			var dist:Number;
			var closestPt:Vector2d = new Vector2d();
			
			dist = relCenter.x;
			if (dist > box.halfX) dist = box.halfX;
			if (dist < -box.halfX) dist = -box.halfX;
			closestPt.x = dist;
			
			dist = relCenter.y;
			if (dist > box.halfY) dist = box.halfY;
			if (dist < -box.halfY) dist = -box.halfY;
			closestPt.y = dist;
			
			if (ReactionType.getType(circle, box) == ReactionType.BOUNCE && closestPt.x == relCenter.x && closestPt.y == relCenter.y) {
				closestPt.y = box.halfY;
				circle.position.y += box.halfY;
			}
			
			dist = closestPt.getDifference(relCenter).squareMagnitude;

			if (dist > circle.radius * circle.radius) return false;

			if (resolve) {
				
				closestPt = new Vector2d(positionWorld(box, closestPt as Point));

				var contactNormal:Vector2d = circle.position.copy;
				
				contactNormal.subtractBy(closestPt);
				contactNormal.normalize(1);
				contactNormal.invert();
				
				var penetration:Number = circle.radius - Math.sqrt(Math.abs(dist));

				if (penetration > 0) CollisionResolver.resolvePenetration(circle, box, contactNormal, penetration);
			
				var ii:Number = CollisionResolver.resolveCollision(circle, box, closestPt, contactNormal);
				
			}

			return true;
			
		}
		
		// 84
		//
		private static function detectCapsuleOnBox (box:CollisionObject, capsule:CollisionObject, resolve:Boolean = true):Boolean {

			var stuckPossible:Boolean = false;
			var stuck:Boolean = false;
			
			var rC:Point = positionRelative(box, capsule.position);
			
			var relCenter:Vector2d = new Vector2d(rC);
			
			// early out goes here
			if (Math.abs(relCenter.x) - capsule.radius > box.halfX ||
				Math.abs(relCenter.y) - capsule.radius > box.halfY) {
					return false;
				}
				
			var linePtA:Point = relCenter.clone();
			var linePtB:Point = relCenter.clone();
			var len:Number;
			
			if (capsule.dimX > capsule.dimY) {
				len = capsule.dimX - capsule.dimY;
				linePtA = Point.polar(len * 0.5, box.simObjectRef.objectRef.rotation).add(relCenter);
				linePtB = Point.polar(0 - len * 0.5, box.simObjectRef.objectRef.rotation).add(relCenter);
			} else {
				len = capsule.dimY - capsule.dimX;
				linePtA = Point.polar(len * 0.5, box.simObjectRef.objectRef.rotation + Geom2d.dtr * 90).add(relCenter);
				linePtB = Point.polar(0 - len * 0.5, box.simObjectRef.objectRef.rotation + Geom2d.dtr * 90).add(relCenter);				
			}
			
			var dist:Number;
			var closestPtA:Vector2d = new Vector2d();
			var closestPtB:Vector2d = new Vector2d();
			
			dist = linePtA.x;
			if (dist > box.halfX) dist = box.halfX;
			if (dist < -box.halfX) dist = -box.halfX;
			closestPtA.x = dist;
			
			dist = linePtA.y;
			if (dist > box.halfY) dist = box.halfY;
			if (dist < -box.halfY) dist = -box.halfY;
			closestPtA.y = dist;
			
			dist = linePtB.x;
			if (dist > box.halfX) dist = box.halfX;
			if (dist < -box.halfX) dist = -box.halfX;
			closestPtB.x = dist;
			
			dist = linePtB.y;
			if (dist > box.halfY) dist = box.halfY;
			if (dist < -box.halfY) dist = -box.halfY;
			closestPtB.y = dist;
			
			var closestPt:Vector2d = (closestPtA.squareMagnitude < closestPtB.squareMagnitude) ? closestPtA : closestPtB;
			
			if (ReactionType.getType(capsule, box) == ReactionType.BOUNCE && closestPt.x == relCenter.x && closestPt.y == relCenter.y) {
				closestPt.y = box.halfY;
				capsule.position.y += box.halfY;
			}
		
			relCenter = new Vector2d(Closest.pointClosestTo(closestPt, linePtA, linePtB));
			
			dist = closestPt.getDifference(relCenter).squareMagnitude;

			closestPt = new Vector2d(positionWorld(box, closestPt as Point));

			if (dist > capsule.minRadius * capsule.minRadius) return false;
			
			if (resolve) {		

				var contactNormal:Vector2d = capsule.position.copy;
				
				contactNormal.subtractBy(closestPt);
				contactNormal.scaleBy(100);

				contactNormal.normalize(1);
				contactNormal.invert();

				var penetration:Number = capsule.minRadius - Math.sqrt(Math.abs(dist));

				if (penetration > 0) CollisionResolver.resolvePenetration(capsule, box, contactNormal, penetration);
			
				var ii:Number = CollisionResolver.resolveCollision(capsule, box, closestPt, contactNormal);
				
			}

			return true;
			
		}
		
		// 83
		//
		private static function detectCircleOnRamp (box:CollisionObject, circle:CollisionObject, resolve:Boolean = true):Boolean {

			_relCenter.alignTo(circle.position);
			_relCenter.subtractBy(box.position);
			
			// early out goes here
			if (Math.abs(_relCenter.x) - circle.radius > box.halfX ||
				Math.abs(_relCenter.y) - circle.radius > box.halfY) {
					return false;
				}
				
			_linePtA.reset();
			_linePtB.reset();
			_linePtA.x -= box.halfX;
			_linePtB.x += box.halfX;
			
			if (box.simObjectRef.rotation == 0 || box.simObjectRef.rotation == Math.PI || box.simObjectRef.rotation == 0 - Math.PI) {
				
				_linePtA.y += box.halfY;
				_linePtB.y -= box.halfY;
				
			} else {
				
				_linePtA.y -= box.halfY;
				_linePtB.y += box.halfY;
				
			}
				
			if (_closestPt == null) _closestPt = new Vector2d();
			
			_closestPt.alignToPoint(Closest.pointClosestTo(_relCenter, _linePtA, _linePtB));
			
			_delta.alignTo(_closestPt);
			_delta.subtractBy(_relCenter);
			
			_separation = _delta.magnitude;
			_contactDistance = circle.radius;
			
			if (_separation >= _contactDistance) return false; // no collision
			
			if (resolve) {
				
				_penetration = _contactDistance - _separation;
				
				if (_penetration > EPSILON) {
					
					_contactNormal = _delta.normalizedCopy;
					
					CollisionResolver.resolvePenetration(circle, box, _contactNormal, _penetration);
					_closestPt.addBy(box.position);
					CollisionResolver.resolveCollision(circle, box, _closestPt, _contactNormal);
				}
	
			}
	
			return true;
			
		}
		

		// 84
		//
		private static function detectCapsuleOnRamp (box:CollisionObject, capsule:CollisionObject, resolve:Boolean = true):Boolean {
			
			_relCenter.alignTo(capsule.position);
			_relCenter.subtractBy(box.position);
			
			// early out goes here
			if (Math.abs(_relCenter.x) - capsule.radius > box.halfX ||
				Math.abs(_relCenter.y) - capsule.radius > box.halfY) {
					return false;
				}
					
			_linePtA.alignTo(_relCenter);
			_linePtB.alignTo(_relCenter);
			
			if (capsule.dimX > capsule.dimY) {
				_len = capsule.dimX - capsule.dimY;
				_linePtA.x -= _len * 0.5;
				_linePtB.x += _len * 0.5;
			} else {
				_len = capsule.dimY - capsule.dimX;
				_linePtA.y -= _len * 0.5;
				_linePtB.y += _len * 0.5;
			}
			
			_linePtA2.reset();
			_linePtB2.reset();
			_linePtA2.x -= box.halfX;
			_linePtB2.x += box.halfX;
			
			if (box.simObjectRef.rotation == 0 || box.simObjectRef.rotation == Math.PI || box.simObjectRef.rotation == 0 - Math.PI) {
				
				_linePtA2.y += box.halfY;
				_linePtB2.y -= box.halfY;
				
			} else {
				
				_linePtA2.y -= box.halfY;
				_linePtB2.y += box.halfY;
				
			}
				
			_closestPoints = Closest.closestPtSegmentSegment(_linePtA, _linePtB, _linePtA2, _linePtB2);
			
			if (_closestPoints.c1 == undefined || _closestPoints.c2 == undefined) return false;
				
			_closestPt = _closestPoints.c1;
			_delta = _closestPoints.c2;
			_delta.subtractBy(_closestPt);
			
			_separation = _delta.magnitude;
			_contactDistance = capsule.minRadius;
			
			if (_separation >= _contactDistance) return false; // no collision
			
			if (resolve) {
				
				_penetration = _contactDistance - _separation;
				
				if (_penetration > EPSILON) {
					
					_contactNormal = _delta.normalizedCopy
					
					CollisionResolver.resolvePenetration(capsule, box, _contactNormal, _penetration);
					_closestPt.addBy(box.position);
					CollisionResolver.resolveCollision(capsule, box, _closestPt, _contactNormal);
					
					if (_penetration > 5) {
						
						if (Geom2d.twoLinesIntersect(capsule.simObjectRef.prevPosition.x, capsule.simObjectRef.prevPosition.y, 
					 		capsule.position.x, capsule.position.y, _linePtA2.x, _linePtA2.y, _linePtB2.x, _linePtB2.y)) {

							capsule.simObjectRef.setPositionToPrevious();
								
						}
						
					}
					
				}
	
			}
	
			return true;
			
		}
		
		// 93
		//
		private static function detectCircleOnStair (box:CollisionObject, circle:CollisionObject, resolve:Boolean = true):Boolean {

			_relCenter.alignTo(circle.position);
			_relCenter.subtractBy(box.position);
			
			// early out goes here
			if (Math.abs(_relCenter.x) - circle.radius > box.halfX ||
				Math.abs(_relCenter.y) - circle.radius > box.halfY) {
					return false;
				}
				
			_linePtA.reset();
			_linePtB.reset();
			_linePtA.x -= box.halfX;
			_linePtB.x += box.halfX;
			
			if (box.simObjectRef.rotation == 0 || box.simObjectRef.rotation == Math.PI || box.simObjectRef.rotation == 0 - Math.PI) {
				
				_linePtA.y += box.halfY;
				_linePtB.y -= box.halfY;
				
			} else {
				
				_linePtA.y -= box.halfY;
				_linePtB.y += box.halfY;
				
			}
				
			if (_closestPt == null) _closestPt = new Vector2d();
			_closestPt.alignToPoint(Closest.pointClosestTo(_relCenter, _linePtA, _linePtB));
			
			_delta.alignTo(_closestPt);
			_delta.subtractBy(_relCenter);
			
			_separation = _delta.magnitude;
			_contactDistance = circle.minRadius;
			
			if (_separation >= _contactDistance) return false; // no collision
			
			if (resolve) {
				
				_penetration = _contactDistance - _separation;
				
				if (_penetration > EPSILON) {
					
					_contactNormal = _delta.copy;
					if (circle.position.y - circle.dimY / 2 + 10 > box.position.y - box.halfY) {
						_contactNormal.y = -1;
						_contactNormal.x = 0;
						_separation /= 2;
						_penetration *= 2;
					} else {
						_contactNormal.normalize(1);
					}
					
					CollisionResolver.resolvePenetration(circle, box, _contactNormal, _penetration);
					_closestPt.addBy(box.position);
					CollisionResolver.resolveCollision(circle, box, _closestPt, _contactNormal);
				}
	
			}
	
			return true;
			
		}
		
		// 94
		//
		private static function detectCapsuleOnStair (box:CollisionObject, capsule:CollisionObject, resolve:Boolean = true):Boolean {

			_relCenter.alignTo(capsule.position);
			_relCenter.subtractBy(box.position);
			
			// early out goes here
			if (Math.abs(_relCenter.x) - capsule.radius > box.halfX ||
				Math.abs(_relCenter.y) - capsule.radius > box.halfY) {
					return false;
				}
					
			_linePtA.alignTo(_relCenter);
			_linePtB.alignTo(_relCenter);
			
			if (capsule.dimX > capsule.dimY) {
				_len = capsule.dimX - capsule.dimY;
				_linePtA.x -= _len * 0.5;
				_linePtB.x += _len * 0.5;
			} else {
				_len = capsule.dimY - capsule.dimX;
				_linePtA.y -= _len * 0.5;
				_linePtB.y += _len * 0.5;
			}
			
			_linePtA2.reset();
			_linePtB2.reset();
			_linePtA2.x -= box.halfX;
			_linePtB2.x += box.halfX;
			
			if (box.simObjectRef.rotation == 0 || box.simObjectRef.rotation == Math.PI || box.simObjectRef.rotation == 0 - Math.PI) {
				
				_linePtA2.y += box.halfY;
				_linePtB2.y -= box.halfY;
				
			} else {
				
				_linePtA2.y -= box.halfY;
				_linePtB2.y += box.halfY;
				
			}
				
			_closestPoints = Closest.closestPtSegmentSegment(_linePtA, _linePtB, _linePtA2, _linePtB2);
			
			if (_closestPoints.c1 == undefined || _closestPoints.c2 == undefined) return false;
				
			_closestPt = _closestPoints.c1;
			_delta = _closestPoints.c2;
			_delta.subtractBy(_closestPt);
			
			_separation = _delta.magnitude;
			_contactDistance = capsule.minRadius;
			
			if (_separation >= _contactDistance) return false; // no collision
			
			if (resolve) {
				
				_penetration = _contactDistance - _separation;
				
				if (_penetration > EPSILON) {
					
					_contactNormal = _delta.copy;
					if (capsule.position.y - capsule.dimY / 2 + 10 > box.position.y - box.halfY) {
						_contactNormal.y = -1;
						_contactNormal.x = 0;
						_separation /= 2;
						_penetration *= 2;
					} else {
						_contactNormal.normalize(1);
					}
					
					CollisionResolver.resolvePenetration(capsule, box, _contactNormal, _penetration);
					_closestPt.addBy(box.position);
					CollisionResolver.resolveCollision(capsule, box, _closestPt, _contactNormal);
					
					if (_penetration > 5) {
						
						if (Geom2d.twoLinesIntersect(capsule.simObjectRef.prevPosition.x, capsule.simObjectRef.prevPosition.y, 
					 		capsule.position.x, capsule.position.y, _linePtA2.x, _linePtA2.y, _linePtB2.x, _linePtB2.y)) {

							capsule.simObjectRef.setPositionToPrevious();
								
						}
						
					}
					
				}
	
			}
	
			return true;
			
		}
		
	}
	
}
