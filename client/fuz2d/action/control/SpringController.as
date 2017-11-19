/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.action.control {
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	import fuz2d.model.object.Biped;
	import fuz2d.util.Geom2d;
	
	import fuz2d.action.play.*;
	import fuz2d.action.physics.*;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class SpringController extends PlayObjectController {
		
		protected var _velObject:VelocityObject;
	
		protected var _homeX:Number = 0;
		protected var _homeY:Number = 0;
		
		protected const DURATION:Number = 0.033;
		protected var _springConstant:Number = 1;
		protected var _springForce:Vector2d;

		protected var _springDelta:Vector2d;
		
		protected var _bounce:Boolean = false;
		
		protected var _lastContact:MotionObject;

		protected var _correctionForce:Vector2d;
		
		//
		//
		public function SpringController (object:PlayObjectControllable, springConstant:Number = 1, bounce:Boolean = false, lockX:Boolean = false, lockY:Boolean = false) {
		
			super(object);
		
			_velObject = VelocityObject(_object.simObject);
			
			_velObject.lockX = lockX;
			_velObject.lockY = lockY;
			_velObject.forceStatic = true;
			
			_homeX = _velObject.position.x;
			_homeY = _velObject.position.y;
			
			_springConstant = springConstant;
			_bounce = bounce;
			
			_springForce = new Vector2d();
			_springDelta = new Vector2d();
			_correctionForce = new Vector2d();
			
			
			_object.simObject.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);
	
		}
		
		//
		//
		override public function update (e:Event):void {
			
			if (_ended || !_active) return;
			
			super.update(e);	
			
			if (!_velObject.velocity.negligible) _velObject.velocity.scaleBy(0.9);
			
			if (_lastContact != null) {
				if (_lastContact.deleted || _bounce) {
					_lastContact = null;
				} else {
					if (_lastContact.sleeping) {
						if (!_velObject.velocity.negligible) _lastContact.sleeping = false;
						return;
					}
				}
			}
			
			_springDelta.x = _velObject.position.x - _homeX;
			_springDelta.y = _velObject.position.y - _homeY;

			if (!_springDelta.negligible) {
				
				_springForce.reset();
				_springForce.subtractBy(_springDelta);
				_springForce.scaleBy(_springConstant);
				
				_springForce.scaleBy(DURATION * _springConstant);
				
				if (_velObject.lockX) _springForce.x = 0;
				if (_velObject.lockY) _springForce.y = 0;
				
				if (!_springForce.negligible) {
					
					_velObject.velocity.addBy(_springForce);
					
					if (_lastContact != null) {
						_lastContact.velocity.addScaled(_springForce, 1 / _lastContact.inverseMass);
					}
					
				}
				
			}
			
		}
		
		//
		//
		protected function onCollision (e:CollisionEvent):void {
			
			if (!_springDelta.negligible) {
				
				if (_object == null || _object.deleted) return;
				
				_springForce.reset();
				_springForce.addBy(e.contactNormal);
				_springForce.scaleBy(_springConstant * 3);

				if (_velObject.lockX) _springForce.x = 0;
				if (_velObject.lockY) _springForce.y = 0;
				
				_lastContact = MotionObject(e.collider);
				
				if (_lastContact.deleted || _lastContact.sleeping) return;
				
				_lastContact.velocity.x *= 0.9 + _object.simObject.cof * 0.1;
				
				if (_bounce) {
					_springForce.y -= 400 * 0.033;
					_velObject.velocity.subtractBy(_springForce);
				} else {
					_velObject.velocity.addBy(_springForce);
				}
				
				if (_bounce) {
					_springForce.scaleBy(0.5 * (_object.object.width * _object.object.width + _object.object.height * _object.object.height) / Geom2d.squaredDistanceBetweenPoints(_object.object.point, e.contactPoint));
				}

				if ((_lastContact.position.y > _velObject.position.y) && !_bounce) {
					_lastContact.velocity.addBy(_springForce);
				} else {
					if (_lastContact.velocity.y < 0) _lastContact.velocity.y = 0 - _lastContact.velocity.y;
					_lastContact.velocity.subtractBy(_springForce);
				}
				
			}

		}
		
	}
	
}