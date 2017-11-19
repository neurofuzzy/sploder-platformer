/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.action.control {
	
	import flash.events.Event;
	import flash.geom.Point;
	import fuz2d.util.Geom2d;
	
	import fuz2d.action.play.*;
	import fuz2d.action.physics.*;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class SpinController extends PlayObjectController {
		
		protected var _playerNear:Boolean = false;
		protected var _spinning:Boolean = false;
		protected var _dir:Number = 0;
		protected var _freeSpin:Boolean = false;
			
		//
		//
		public function SpinController (object:PlayObjectControllable, dir:Number = 0, freeSpin:Boolean = false) {
		
			super(object);
			
			_dir = dir * Geom2d.dtr;
			_freeSpin = freeSpin;
			_object.simObject.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);

		}
		
		//
		//
		override public function see(p:PlayObject):void {
			
			super.see(p);

			if (_spinning) return;
			
			if (p.object.symbolName == "player") {
				_playerNear = true;	
			}
			
		}
		
		//
		//
		override public function update (e:Event):void {
			
			if (_ended || !_active) return;
			
			super.update(e);
			
			if (_playerNear && !_spinning) {
				
				_spinning = true;
				
			} else if (_spinning) {
				
				_object.object.rotation += _dir;
				if (_freeSpin) _dir *= 0.99;
				
			}
				
		}
		
		//
		//
		protected function onCollision (e:CollisionEvent):void {

			var spinDir:Vector2d;
			var spinPower:Number;
			var mo:MotionObject;
			
			if (e.collider is MotionObject) {
				
				_spinning = true;
				
				if (_freeSpin) {
					
					// torque baby, TORQUE!
					
					var r:Vector2d = new Vector2d(e.contactPoint.subtract(_object.object.point));
					r.rotate(Geom2d.HALFPI);
					var t:Number = e.contactNormal.getDotProduct(r);
					t *= e.contactSpeed / 100;

					t *= 0.0002;
					_dir = t;
				
				} else if (_object.simObject.collisionObject.type == CollisionObject.CIRCLE) {
					
					spinDir = e.contactNormal.copy;
					spinDir.rotate(Geom2d.HALFPI);
					
					spinPower = Geom2d.distanceBetweenPoints(_object.object.point, e.contactPoint);

					mo = MotionObject(e.collider);
					mo.velocity.addScaled(spinDir, _dir * spinPower * 35);
				
				} else if (e.collider is MotionObject) {
					
					spinDir = e.contactNormal.copy;
					spinDir.rotate(0 - Geom2d.HALFPI);
					
					spinPower = Geom2d.distanceBetweenPoints(_object.object.point, e.contactPoint);

					mo = MotionObject(e.collider);
					mo.velocity.addScaled(spinDir, _dir * spinPower * 10);
				
				}
				
			}
				
		}
		
		//
		//
		override public function end():void {
			
			if (_object != null && _object.simObject != null) _object.simObject.removeEventListener(CollisionEvent.COLLISION, onCollision);
			super.end();
			
		}
		
	}
	
}