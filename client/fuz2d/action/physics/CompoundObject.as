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
	import fuz2d.action.physics.SimulationObject;
	import fuz2d.Fuz2d;
	import fuz2d.model.object.Biped;
	import fuz2d.model.object.Object2d;
	import fuz2d.model.object.Symbol;
	import fuz2d.util.Geom2d;

	public class CompoundObject extends VelocityObject {
		
		protected var _subObjects:Array;
		protected var _subSimObjects:Array;
		protected var _vertices:Array;
		protected var _distances:Array;
		protected var _delta:Point;
		protected var _dist:Point;
		protected var _springForce:Vector2d;
		protected var _barForce:Vector2d;
		
		public function get sleeping ():Boolean {
			
			var i:int = _subSimObjects.length;
			
			while (i--) {
				if (!MotionObject(_subSimObjects[i]).sleeping) return false;
			}
			
			return true;
			
		}
		
		public function get floating ():Boolean {
			
			var i:int = _subSimObjects.length;
			
			while (i--) {
				if (!MotionObject(_subSimObjects[i]).floating) return false;
			}
			
			return true;
			
		}
		
		public function get hasContact ():Boolean {
			
			var i:int = _subSimObjects.length;
			
			while (i--) {
				if (MotionObject(_subSimObjects[i]).inContact) return true;
			}
			
			return false;
			
		}
		
		public function get subObjects():Array { return _subObjects; }
		
		public function get subSimObjects():Array { return _subSimObjects; }
		
		public function subRotate (dir:Number):void {
			
			var i:int = _subObjects.length;
			
			while (i--) {
				Object2d(_subObjects[i]).rotation += dir;
			}
			
		}
		
		//
		//
		public function CompoundObject (simulation:Simulation, obj:Object2d, collisionObjectType:uint, reactionType:uint = ReactionType.BOUNCE, mass:Number = 0, gravityMultiplier:Number = 1, damping:Number = 0.995, rotationDamping:Number = 0.1, ignoreSameType:Boolean = false, collideOnlyStatic:Boolean = false, nosleep:Boolean = false, vertices:Array = null, radius:Number = 0, subSymbolName:String = "", buoyancy:Number = 0, leakage:Number = 0) {
			
			super(simulation, obj, CollisionObject.CIRCLE, reactionType);
			
			_subObjects = [];
			_subSimObjects = [];
			_vertices = vertices;
			_distances = [];
			_dist = new Point();
			_delta = new Point();
			
			_springForce = new Vector2d();
			_barForce = new Vector2d();
			
			var pt:Point;
			var pvert:Point;
			
			if (vertices) {
				
				for (var i:int = 0; i < _vertices.length; i++) {
					
					pt = Point(_vertices[i]);
					
					if (pvert) _distances.push(Geom2d.distanceBetweenPoints(pvert, pt));
					else _distances.push(Geom2d.distanceBetweenPoints(pt, Point(_vertices[_vertices.length - 1])));
					
					var subobj:Object2d = new Symbol(subSymbolName, Fuz2d.library, null, null, obj.x + pt.x, obj.y + pt.y, 10000, 0);
					_subObjects.push(subobj);
					subobj.attribs.parentObject = objectRef;
					simulation.model.addObject(subobj);
					
					var mot:MotionObject = new MotionObject(simulation, subobj, CollisionObject.CIRCLE, reactionType, mass, gravityMultiplier, damping, rotationDamping, false, true, nosleep, buoyancy, leakage);
					subobj.simObject = mot;
					_subSimObjects.push(mot);
					
					mot.addEventListener(CollisionEvent.COLLISION, onSubCollision, false, 0, true);
					
					pvert = pt;
					
				}
				
			}

		}
		
		protected function onSubCollision (e:CollisionEvent):void 
		{
			dispatchEvent(new CollisionEvent(CollisionEvent.COLLISION, false, false, this, e.collidee));
			
			var i:int = _subSimObjects.length;
			
			var mot:MotionObject;
			var pt:Point;
			
			_delta.x = _delta.y = 0;
			
			while (i--) {
				
				mot = MotionObject(_subSimObjects[i]);
				
				if (mot != e.collidee && mot != e.collider) {
					
					var force:Vector2d = new Vector2d(e.contactNormal);
					force.scaleBy(e.contactSpeed);
					mot.addForce(force);
					
				}
				
			}

			
		}
		
		//
		//
		public function addForce (force:Vector2d, multiplier:Number = 1):void {
			
			var i:int = _subSimObjects.length;
			
			var mot:MotionObject;
			var pt:Point;
			
			_delta.x = _delta.y = 0;
			
			while (i--) {
				
				mot = MotionObject(_subSimObjects[i]);
				
				mot.addForce(force, multiplier);
				
			}
			
		}
		
		//
		//
		override public function integrate (duration:Number = 0):void {
			
			if (!sleeping) {
				
				var i:int = _subSimObjects.length;
				
				var pmot:MotionObject;
				var mot:MotionObject;
				var nmot:MotionObject;
				
				var pi:int;
				var ni:int;
				
				var pt:Point;
				
				_delta.x = _delta.y = 0;

				while (i--) {
					
					mot = MotionObject(_subSimObjects[i]);
					pi = (i > 0) ? i - 1 : _subSimObjects.length - 1;
					ni = (i < _subSimObjects.length - 1) ? i + 1 : 0;
					pmot = MotionObject(_subSimObjects[pi]);
					nmot = MotionObject(_subSimObjects[ni]);
					
					pt = Point(_vertices[i]);
					
					var pt2:Point = _objectRef.positionWorld(pt);
					_dist.x = mot.position.x - pt2.x;
					_dist.y = mot.position.y - pt2.y;

					_springForce.alignToPoint(_dist);
					_springForce.invert();
					_springForce.scaleBy(1 / duration);
					mot.addForce(_springForce);
					
					_delta.x += _dist.x / _subSimObjects.length;
					_delta.y += _dist.y / _subSimObjects.length;
					
					var olen:Number;
					var nlen:Number;
					var ang:Number;

					if (pmot == nmot) {
						
						olen = _distances[i];
						nlen = Geom2d.distanceBetweenPoints(pmot.position, mot.position);
						ang = Geom2d.angleBetweenPoints(_vertices[pi], _vertices[i]);
						
						_barForce.y = 0;
						_barForce.x = 0 - (olen - nlen) * 2;
						_barForce.rotate(ang);
						
						mot.addForce(_barForce);
						
					} else {
						
					}
					
					if (objectRef && mot.objectRef) mot.objectRef.z = objectRef.z + 1;
					
					// harmonic calming;
					mot.position.x -= _dist.x * 0.1;
					mot.updateObjectRef();
					
				}
				
				_delta.x = Math.min(collisionObject.halfX * 0.5, Math.max(0 - collisionObject.halfX * 0.5, _delta.x));
				_delta.y = Math.min(collisionObject.halfY * 0.5, Math.max(0 - collisionObject.halfY * 0.5, _delta.y));
				
				position.x += _delta.x;
				position.y += _delta.y;
				updateObjectRef();
				
				_simulation.applyCollisions(this);
				_simulation.updateObject(this);
				
				_objectRef.rotation = 0 - Geom2d.angleBetween(MotionObject(_subSimObjects[0]).objectRef, MotionObject(_subSimObjects[1]).objectRef);

			}
			
		}
		
		override public function destroy():void 
		{
			var i:int;
			
			if (_subSimObjects) {
				i = _subSimObjects.length;
				while (i--) MotionObject(_subSimObjects[i]).removeEventListener(CollisionEvent.COLLISION, onSubCollision);
			}
			
			if (_subObjects) {
				i = _subObjects.length;
				while (i--) Object2d(_subObjects[i]).destroy();
			}
			
			_subObjects = null;
			_subSimObjects = null;
			
			super.destroy();
		}
		
	}
	
}
