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
	import fuz2d.library.ObjectFactory;
	import fuz2d.TimeStep;
	import fuz2d.util.Geom2d;
	
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class ProjectileController extends PlayObjectController {
		
		protected var _velObject:VelocityObject;
		protected var _strength:int = 0;
		protected var _lifeSpan:int = 3;
		protected var _drop:int = 0;
		protected var _bounce:Boolean = false;
		protected var _startTime:int = 0;
		protected var _pushFactor:Number = 1;
		protected var _hitEffect:String = "";
		protected var _bounceEffect:String = "";
		protected var _collided:Boolean = false;
		
		//
		//
		public function ProjectileController (object:PlayObjectControllable, velocity:Vector2d, strength:int, lifeSpan:int = 3, drop:int = 0, pushFactor:Number = 1, hitEffect:String = "", bounce:Boolean = false, bounceEffect:String = "") {
		
			super(object);
			
			_velObject = VelocityObject(_object.simObject);
				
			_velObject.velocity = velocity;
			
			_velObject.isProjectile = true;
			
			_strength = strength;
			
			_lifeSpan = (!isNaN(lifeSpan)) ? lifeSpan * 1000 : _lifeSpan;
			
			_drop = drop;
			
			_pushFactor = pushFactor;
			
			_hitEffect = hitEffect
			
			_bounce = bounce;
			
			_bounceEffect = bounceEffect;
			
			_startTime = TimeStep.realTime;
			
			if (_velObject != null) {
				_velObject.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);
				_velObject.addEventListener(CollisionEvent.PENETRATION, onCollision, false, 0, true);
			} else {
				end();
			}
			
		}

		
		//
		//
		override public function update (e:Event):void {
			
			if (_ended || !_active) return;
			
			super.update(e);
			
			if (_drop != 0 && _velObject != null && _velObject.objectRef != null) {
				_velObject.velocity.y -= _drop;
				_velObject.objectRef.rotation = Math.atan2(_velObject.velocity.x, _velObject.velocity.y) - Geom2d.HALFPI;
			}
			
			var mapCollide:Boolean = _object.playfield.map.inOccupiedCell(_object, true);
			
			if (mapCollide) {
				
				var obj:PlayObject = _object.playfield.map.objectInSameCellAs(_object);
				
				if (obj is PlayObjectControllable) {
					harm(obj as PlayObjectControllable, _strength);
					PlayObjectControllable(obj).onHarmed(_object as PlayObjectControllable, _strength);
					if (_hitEffect.length > 0) ObjectFactory.effect(_object, _hitEffect, true, 1000, _object.object.point);
					_object.eventSound("hit");
				}
			}

			if (TimeStep.realTime - _startTime > _lifeSpan || mapCollide) {
				_object.destroy();
				end();
			}
			
		}
		
		//
		//
		public function onCollision (e:CollisionEvent):void {
			
			if (_collided) return;
			
			if (!_object.isCreator(e.collider) && !_object.isCreator(e.collidee)) {
				
				var po:PlayObject;
				
				po = _object.playfield.playObjects[e.collider];
				if (po == null || po == _object) po = _object.playfield.playObjects[e.collidee];
				
				var ricochet:Boolean = (_bounce && po is BipedObject && BipedObject.defendSuccess(_object as PlayObjectControllable, po as BipedObject));

				if (po != null && 
					po.simObject != null && 
					po.simObject.collisionObject.reactionType == ReactionType.BOUNCE && 
					po.group != _object.group) {
					
					if (po is PlayObjectControllable) harm(po as PlayObjectControllable, _strength);
					
					if (po.simObject is MotionObject) {
						var v:Vector2d = new Vector2d(null, _velObject.velocity.x, _velObject.velocity.y);
						v.scaleBy(0.5);
						v.scaleBy(_pushFactor);
						if (ricochet) {
							v.scaleBy(0.5);
							if (po is BipedObject && BipedObject(po).crouching) v.scaleBy(0.25);
						}
						var iv:Number = MotionObject(po.simObject).inverseMass;
						if (iv < 1) {
							v.scaleBy(iv);
							v.scaleBy(iv);
						}
						MotionObject(po.simObject).applyImpulse(v);
					}
					
					_collided = true;
					
					if (ricochet) {
						
						_velObject.velocity.x = (0 - _velObject.velocity.x) * 0.5;
						_velObject.velocity.y *= 0.5;
						if (_bounceEffect.length > 0) ObjectFactory.effect(_object, _bounceEffect, true, 1000, e.contactPoint);
						_object.eventSound("bounce");
						
					} else {
						
						if (_hitEffect.length > 0) ObjectFactory.effect(_object, _hitEffect, true, 1000, e.contactPoint);
						_object.eventSound("hit");
						_object.destroy();
						end();
	
					}
					
				}
				
			}
			
		}
		
		//
		//
		public function harm (playObj:PlayObjectControllable, amount:Number = 0):void {
			
			if (_bounce && playObj is BipedObject) {
				if (BipedObject.defendSuccess(_object, playObj as BipedObject)) {
					amount = 0;
				}
			}
			
			_object.harm(playObj, amount);

		}
		
		//
		//
		override public function end():void {
			
			_velObject.removeEventListener(CollisionEvent.COLLISION, onCollision);
			
			super.end();
			
		}
		
	}
	
}