/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.physics {

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import fuz2d.action.physics.*;
	import fuz2d.model.object.Object2d;
	import fuz2d.util.Geom2d;

	public class SimulationObject extends EventDispatcher {
	
		public var type:String;
		public var group:String;
		public var controlled:Boolean = false;
		
		public var ignoreSameType:Boolean = false;
		
		protected var _simulation:Simulation;
		public function get simulation():Simulation { return _simulation; }
		public function set simulation(value:Simulation):void { _simulation = value; }
		
		public var checked:Boolean = false;
		public var resolved:Boolean = false;
		
		protected var _objectRef:Object2d;
		public function get objectRef ():Object2d { return _objectRef; }
		public function set objectRef (obj:Object2d):void { if (obj != null) { _objectRef = obj; getPosition(); getOrientation(); } }

		protected var _deleted:Boolean = false;
		public function get deleted ():Boolean { return _deleted; }
		public function set deleted (val:Boolean):void { _deleted = (val) ? true : false; }
				
		protected var _inverseMass:Number = 0;
		public function set mass (val:Number):void { _inverseMass = (!isNaN(val)) ? 1 / val : 0; }
		public function get inverseMass ():Number { return _inverseMass; }
		public function set inverseMass (val:Number):void { _inverseMass = (!isNaN(val)) ? val : _inverseMass; }
		public function get hasFiniteMass ():Boolean { return (_inverseMass > 0); }
	
		protected var _cor:Number = 0.8;
		public function get cor():Number { return (!isNaN(objectRef.material.cor)) ? objectRef.material.cor : _cor; }
		public function set cor(value:Number):void { _cor = value; }
		
		protected var _cof:Number = 0.5;
		public function get cof():Number { return (objectRef != null && objectRef.material != null && !isNaN(objectRef.material.cof)) ? objectRef.material.cof : _cof; }
		public function set cof(value:Number):void { _cof = value; }
		
		protected var _pressureC:Number = 1;
		
		protected var _collisionObject:CollisionObject;
		
		public function get collisionObject ():CollisionObject {
			return _collisionObject;
		}
		
		public var position:Vector2d;
		public var prevPosition:Vector2d;

		public var orientation:Vector2d;
		public var orientationRight:Vector2d;
		public var orientationTop:Vector2d;
		
		private var orientationPoint:Point;
		
		public function get rotation ():Number {
			return (_objectRef != null) ? _objectRef.rotation : 0;
		}
		
		public function get inMotion ():Boolean { return false; }

		public function get propped ():Boolean { return _wasInContact; }
		protected var _wasInContact:Boolean = false;
		public var inContact:Boolean = false;
		public var onGround:Boolean = false;
		public var contactPressure:Number = 0;
		protected var _contacts:Array;
		public function get contacts():Array { return _contacts; }

		public var isProjectile:Boolean = false;
		
		public var controllerActive:Boolean = false;
		
		public var checkForward:Boolean = false;
		
		public var forceStatic:Boolean = false;
		
		public function get x ():Number {
			return position.x;
		}
		
		public function get y ():Number {
			return position.y;
		}

		//
		//
		public function SimulationObject (simulation:Simulation, obj:Object2d, collisionObjectType:uint = 3, reactionType:uint = 1, collideOnlyStatic:Boolean = false, vertices:Array = null, connections:Array = null) {
			
			_simulation = simulation;
			
			position = new Vector2d();
			prevPosition = new Vector2d();
	
			orientation = new Vector2d();
			orientationRight = new Vector2d();
			orientationTop = new Vector2d();
			
			orientationPoint = new Point(0, 0);
			
			_objectRef = obj;
			
			// swap height and width on rotated static objects
			//
			if (collisionObjectType == CollisionObject.OBB && obj.rotation != 0 && !(this is VelocityObject)) {
				if (obj.rotation == Geom2d.HALFPI || obj.rotation == Geom2d.HALFPI + Geom2d.PI) {
					var temp:Number = obj.width;
					obj.width = obj.height;
					obj.height = temp;
				}
			}
			
			_collisionObject = new CollisionObject(this, collisionObjectType, reactionType, collideOnlyStatic, vertices, connections);
			
			if (_simulation != null) {
				_simulation.addObject(this);
				init();	
			}
			
		}
		
		//
		//
		protected function init ():void {
			
			_pressureC = (1 / _cof) * (1 / _simulation.gravity);
			
			getPosition();
			getOrientation();
			
			_inverseMass = 0;
			
		}
		
		//
		//
		public function destroy ():void {
			
			_objectRef = null;
			_collisionObject = null;
			
			_deleted = true;
			
			_simulation.removeObject(this);
			
			delete this;
			
		}

		//
		//
		public function getPosition ():void {
			
			position.alignToPoint(_objectRef.point);
			_simulation.updateObject(this);
			
		}
		
		//
		//
		public function setPrevPosition ():void {
			
			prevPosition.x = position.x;
			prevPosition.y = position.y;			
			
		}
		
		//
		//
		public function setPositionToPrevious ():void {
			
			position.x = prevPosition.x;
			position.y = prevPosition.y;
			
			updateObjectRef();
			
		}
		
		//
		//
		public function getOrientation ():void {
			
			orientation.identityFront();
			orientation.rotate(_objectRef.rotation);
			
			orientationRight.identityRight();
			orientationRight.rotate(_objectRef.rotation);
			
			orientationTop.identityTop();
			orientationTop.rotate(_objectRef.rotation);
			
		}
		
		//
		//
		public function localize (v:Vector2d):void {
			
		}
		
		//
		//
		public function updateObjectRef ():void {
			
			_objectRef.x = position.x;
			_objectRef.y = position.y;

		}
		
		//
		//
		public function applyImpulse (impulse:Vector2d):void {
			
		}
		
		//
		//
		public function onCollision (collidee:SimulationObject):void {
			
			dispatchEvent(new CollisionEvent(CollisionEvent.COLLISION, false, false, this, collidee));
			
		}
		
	}
	
}
