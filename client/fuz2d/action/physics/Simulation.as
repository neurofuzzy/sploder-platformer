/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.physics {

	import flash.events.*;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import fuz2d.action.physics.*;
	import fuz2d.Fuz2d;
	import fuz2d.model.Model;
	import fuz2d.model.object.Biped;
	import fuz2d.screen.View;
	import fuz2d.TimeStep;
	import fuz2d.util.OmniProximityGrid;
	
	
	

	public class Simulation extends EventDispatcher {
		
		public static const CYCLE_START:String = "cycle_start";
		public static const SIMULATE:String = "simulate";
		public static const CYCLE_END:String = "cycle_end";
		public static const INTEGRATE:String = "integrate";
		
		private var _main:Fuz2d;
		public function get main ():Fuz2d { return _main };
		
		public static var sineTime:Number;
		public static var sineTimeDouble:Number;
		public static var cosTime:Number;
		public static var cosTimeDouble:Number;
		
		private var eventStart:Event;
		private var eventSimulate:Event;
		private var eventEnd:Event;
		
		private var _gravityForce:Force;
		public function get gravityForce():Force { return _gravityForce; }
		
		private var _gravity:int = 0;
		
		public function get gravity():int { return _gravity; }	
		public function set gravity(value:int):void 
		{
			_gravity = value;

			if (_gravityForce != null) if (_generalForces.indexOf(_gravityForce) != -1) _generalForces.splice(_generalForces.indexOf(_gravityForce), 1);
		
			if (value != 0) {
				
				_gravityForce = new Force(0, 0 - _gravity, false, true);
				
				_generalForces.push(_gravityForce);
				
			} 
			
		}
		
		private var _model:Model;
		public function get model ():Model { return _model; }
		
		public static var xDimension:Vector2d;
		public static var yDimension:Vector2d;
		
		protected var _minX:Number;
		protected var _minY:Number;
		protected var _maxX:Number;
		protected var _maxY:Number;

		private var _staticObjects:Array;
		private var _velocityObjects:Array;
		private var _motionObjects:Array;
		private var _compoundObjects:Array;
		
		private var _neighbors:Array;
		private var _collidingObjects:Array;
		
		private var _grid:SimulationGrid;
		private var _collisionDetector:CollisionDetector;
		
		private var _generalForces:Array;
		private var _generalBoundaries:Array;

		private var _forces:Dictionary;

		private var _duration:Number;
		private var _inverseDuration:Number;
		public function get currentDuration ():Number { return _duration; }
	
		private static var _threshold:Number;
		public static function get threshold():Number { return _threshold; }

		private var _running:Boolean = false;
		public function get running ():Boolean { return _running; }
		
		private var _locked:Boolean = false;
		public function get locked():Boolean { return _locked; }
		public function set locked(value:Boolean):void 
		{
			_locked = value;
		}
	
		protected var _focalPoint:SimulationObject;
		protected var _focalNeighbors:Array;
		protected var _motionObjectGrid:OmniProximityGrid;
		
		protected var _sorted:Boolean = false;
		
		public function get focalPoint():SimulationObject { return _focalPoint; }
		
		public function set focalPoint(value:SimulationObject):void {
			
			_focalPoint = value;
			
			if (_focalPoint is MotionObject) MotionObject(_focalPoint).sleeping = false;
			
			wakeTheNeighbors();
			
		}

		//
		//
		public function Simulation (main:Fuz2d, model:Model, gridSize:int, gravity:int = 0) {
			
			_main = main;
			_model = model;
			BoundsBuilder.clear();

			xDimension = new Vector2d(null, 1, 0);
			yDimension = new Vector2d(null, 0, 1);

			_grid = new SimulationGrid(gridSize, gridSize);
			
			_staticObjects = [];
			_velocityObjects = [];
			_motionObjects = [];
			_compoundObjects = [];
			
			_collidingObjects = [];
			
			_generalForces = [];
			_generalBoundaries = [];
			
			this.gravity = gravity;
			
			if (Math.abs(gravity) > 0) {
				_gravityForce = new Force(0, 0 - gravity);
				_generalForces.push(_gravityForce);
			}

			_forces = new Dictionary(false);
			
			_focalNeighbors = [];
			_motionObjectGrid = new OmniProximityGrid(480, 320, OmniProximityGrid.SIMOBJECT);
			
			eventStart = new Event(CYCLE_START);
			eventSimulate = new Event(SIMULATE);
			eventEnd = new Event(CYCLE_END);
			
			CollisionDetector.initialize(this);
			
		}
		
		public function simulateTwice (e:Event):void {
			
			dispatchEvent(eventStart);
			dispatchEvent(eventStart);
			
			TimeStep.step();
			
			if (!_locked) simulate(e, false);
			dispatchEvent(eventEnd);
			
			if (TimeStep.stepValue % 20 == 0) wakeTheNeighbors();
			
			TimeStep.step();
			
			if (!_locked) simulate(e);
			dispatchEvent(eventEnd);
			
			if (TimeStep.stepValue % 20 == 0) wakeTheNeighbors();
			
			//checkCollidedObjects();
			
		}
		
		/**
		 * Method: startSimulation
		 * Starts the simulation loop.
		 */
		public function start ():void {

			if (!_running) {
				
				if (!BoundsBuilder.built) BoundsBuilder.build(_model, this, Model.GRID_WIDTH);
				
				View.mainStage.addEventListener(Event.ENTER_FRAME, simulateTwice, false, 0, true);
				_running = true;
				
				if (_sorted) sort();
				
			}
			
		}
		
		/**
		 * Method: stopSimulation
		 * Stops the simulation loop.
		 */
		public function stop ():void {
			
			if (_running) {
				View.mainStage.removeEventListener(Event.ENTER_FRAME, simulateTwice);
				_running = false;
			}
			
		}
		
		public function end ():void {
			
			stop();
			BoundsBuilder.clear();
			CollisionDetector.uninitialize();
			
			if (_grid) {
				_grid.end();
				_grid = null;	
			}
			
			if (_motionObjectGrid) {
				_motionObjectGrid.end();
				_motionObjectGrid = null;
			}
			
			_staticObjects = null;
			_velocityObjects = null;
			_motionObjects = null;
			_compoundObjects = null;
			_neighbors = null;
			_generalForces = null;
			_generalBoundaries = null;
			_forces = null;
			
			_model = null;
			_main = null;
			
		}
		
		//
		//
		private function clearResolveFlags ():void {
			
			for each (var obj:MotionObject in _motionObjects) obj.resolved = false;
			
		}
		
		//
		//
		protected function wakeTheNeighbors ():void {
			
			if (_focalPoint != null && _focalPoint.objectRef != null) {
				
				var neighbor:SimulationObject;
				
				for each (neighbor in _focalNeighbors) if (neighbor is MotionObject) MotionObject(neighbor).sleeping = true;
				
				_focalNeighbors = _grid.getNeighborsNear(_focalPoint.objectRef.point, false, false, 2);
				
				for each (neighbor in _focalNeighbors) if (neighbor is MotionObject) MotionObject(neighbor).sleeping = false;

			}
			
		}
		
		//
		//
		protected function sort ():void {
			
			for each (var mo:MotionObject in _motionObjects) {
				_grid.unregister(mo);
			}
			
			for (var i:int = 0; i < _motionObjects.length; i++) {
				_grid.register(MotionObject(_motionObjects[i]));
			}
			
			_sorted = true;
			
		}
		
		//
		//
		private function simulate (e:Event, collisions:Boolean = true):void {
			
			var i:int;
			var j:int;
			
			var currentForce:Force;
			var forceArray:Array;
			
			//_duration = 0.043;
			_duration = TimeStep.speed / 370;
			
			
			var ts:int = TimeStep.realTime;
			
			sineTime = Math.sin(ts / 250);
			sineTimeDouble = Math.sin(ts / 100);
			cosTime = Math.cos(ts / 250);
			cosTimeDouble = Math.cos(ts / 100);
			
			_threshold = _gravity * _duration * 5;
			
			clearResolveFlags();
			// apply general forces to all objects
			
			if (_generalForces == null) return;
			
			j = _generalForces.length;
			
			while (j--) {
				
				currentForce = Force(_generalForces[j]);
				
				i = _motionObjects.length;
				
				while (i--) {
					
					mobj = MotionObject(_motionObjects[i]);
					
					if ((currentForce.isGravity && mobj.defyGravity) || (currentForce.isGravity && mobj.gravity == 0)) {
	
					} else {
						
						if (!mobj.sleeping || _focalPoint == null) {
								
							currentForce.applyForce(mobj);
							
						}

					}
					
					mobj.defyGravity = false;
					
				}
			
			}
				
			for (var force:* in _forces) {
				
				currentForce = Force(force);
				
				if (_forces[force] is MotionObject) {
					
					// apply force to object
					currentForce.applyForce(MotionObject(_forces[force]));
					
				} else if (_forces[force] is Array) {
					
					// apply force to all objects in array
					forceArray = _forces[force] as Array;
					i = forceArray.length;
					
					while (i--) {
						
						currentForce.applyForce(MotionObject(_forces[force][i]));
						
					}
					
				} 
				
			}
			
			// resolve applied forces on all objects
					
			i = _motionObjects.length;
			var mobj:MotionObject;
			
			while (i--) {
				
				mobj = MotionObject(_motionObjects[i]);

				if (mobj.inMotion || _focalPoint == null) {
						
					if (!mobj.sleeping || _focalPoint == null) { // && (_generalForces.length > 0 || Fuz2d.fpsOK)) {
						
						mobj.onGround = false;
						applyBoundaries(mobj);
						mobj.integrate(_duration);	
						applyCollisions(mobj, true);
						applyBoundaries(mobj);
						updateObject(mobj);
						mobj.setPrevPosition();
						
						
						
					}
					
	
				}
				
				mobj.resolved = true;
				
			}
			
			// integrate velocity on velocity objects
			
			i = _velocityObjects.length;
			var vobj:VelocityObject;
			
			while (i--) {
				
				vobj = VelocityObject(_velocityObjects[i]);

				if (vobj.inMotion) {
					
					vobj.integrate(_duration);
					applyBoundaries(vobj);
					updateObject(vobj);
					vobj.setPrevPosition();
					
				}
				
			}
			
			i = _compoundObjects.length;
			var cobj:CompoundObject;
			
			while (i--) {
				
				cobj = CompoundObject(_compoundObjects[i]);
				
				cobj.integrate(_duration);
				applyCollisions(cobj);
				
			}
			
			clearForces();
			
			dispatchEvent(eventSimulate);
			
			_motionObjects.reverse();

			_model.update();
			
		}
		
		private function sortOnDist(a:SimulationObject, b:SimulationObject):Number 
		{
			var aDist:Number = Math.abs(a.position.x - _focalPoint.position.x);
			var bDist:Number = Math.abs(b.position.x - _focalPoint.position.x);

			if(aDist < bDist) {
				return 1;
			} else if(aDist > bDist) {
				return -1;
			} else  {
				//aDist == bDist
				return 0;
			}
		}
		
		
		//
		//
		public function applyCollisions (obj:SimulationObject, firstPass:Boolean = true, onlyClass:Class = null):void {
			
			var neighbor:SimulationObject;
			//var neighbors:Array = _grid.getNeighborsOf(obj, false, _neighbors);
			var neighbors:Array = _grid.getNeighborsOf(obj, obj == focalPoint, obj == focalPoint, _neighbors);
			var collided:Boolean;
			
			// check both ways only when not crouching.
			if (obj.objectRef is Biped)
			{
				if (!obj.checkForward && obj.collisionObject.dimY > 90) neighbors.reverse();
				if (obj == _focalPoint) neighbors.sort(sortOnDist); // if player, sort collision objects closest x first
			}
			
			var i:int = neighbors.length;

			while (i--) {
				
				neighbor = neighbors[i];
				
				if (!neighbor.checked && neighbor != obj && neighbor.collisionObject) {
					
					if (!neighbor.collisionObject.collideOnlyStatic && !(obj.collisionObject.collideOnlyStatic && (neighbor is VelocityObject && !neighbor.forceStatic))) {
					
						if (!(neighbor.type == obj.type && (obj.ignoreSameType || neighbor.ignoreSameType))) {
							
							collided = (obj.collisionObject.type > neighbor.collisionObject.type) ? 
								CollisionDetector.detect(obj.collisionObject, neighbor.collisionObject, true) :
								CollisionDetector.detect(neighbor.collisionObject, obj.collisionObject, true);

						}
						
						if (collided && neighbor is MotionObject) {
							if (MotionObject(neighbor).sleeping) MotionObject(neighbor).sleeping = false;
							//if (firstPass && _collidingObjects.indexOf(neighbor) == -1) _collidingObjects.push(neighbor);
						}

					}
				
				}
				
				neighbor.checked = true;

			}
			
			for each (neighbor in neighbors) neighbor.checked = false;
			
			obj.checkForward = !obj.checkForward;
			
		}
		
		//
		//
		protected function checkCollidedObjects ():void {
			
			_collidingObjects.reverse();
			for (var i:int = _collidingObjects.length - 1; i >= 0; i--) applyCollisions(_collidingObjects.pop(), false);

		}
		
		//
		//
		public function getObjectAtPoint (pt:Point, self:SimulationObject, collisionObjectType:int = -1, reactionType:int = -1, tolerance:Number = 0):SimulationObject {
			
			var neighbors:Array = _grid.getNeighborsNear(pt, true);
			var collided:Boolean;
			var neighbor:SimulationObject;

			for (var i:int = 0; i < neighbors.length; i++) {
				
				neighbor = neighbors[i];
				
				if (neighbor != self) {
					
					if (!(neighbor is DummyObject) && (collisionObjectType == -1 || collisionObjectType == neighbor.collisionObject.type) && 
						(reactionType == -1 || reactionType == neighbor.collisionObject.reactionType)) {
						
						if (CollisionDetector.pointCheck(pt, neighbor.collisionObject, tolerance)) {
								
							self.dispatchEvent(new CollisionEvent(CollisionEvent.POINT_HIT, false, false, self, neighbor, pt));	
							return neighbor;
							
						}
					
				}
					
				}
				
			}
			
			return null;
			
		}
		
		//
		//
		public function getObjectAtSegment (ptA:Point, ptB:Point, self:SimulationObject, onlyStatic:Boolean = false):Object {
			
			var neighbors:Array = _grid.getNeighborsAlong(ptA, ptB, true);
			var result:Point;
			var neighbor:SimulationObject;

			for (var i:int = 0; i < neighbors.length; i++) {
				
				neighbor = neighbors[i];
				
				if (neighbor != self && neighbor.collisionObject.reactionType == ReactionType.BOUNCE && (!onlyStatic || !(neighbor is VelocityObject))) {
					
					result = CollisionDetector.lineSegmentCheck(ptA, ptB, neighbor.collisionObject);
					
					if (result != null) return { obj: neighbor, pt: result };

				}
				
			}
			
			return null;
			
		}
		
		
		//
		//
		public function getNeighborsNear (pt:Point, distSort:Boolean = true, horizDist:Boolean = false, range:int = 1):Array {
			
			return _grid.getNeighborsNear(pt, distSort, horizDist, range);
			
		}		
		
		//
		//
		private function applyBoundaries (obj:SimulationObject):void {
			
			if (!isNaN(_minX) && obj.position.x < _minX) {
				obj.position.x = _minX;
				if (obj is VelocityObject) {
					VelocityObject(obj).velocity.x = Math.max(0, VelocityObject(obj).velocity.x);
					if (VelocityObject(obj).bound && obj.objectRef != null) obj.objectRef.destroy();
				}
			}else if (!isNaN(_maxX) && obj.position.x > _maxX) {
				obj.position.x = _maxX;
				if (obj is VelocityObject) {
					VelocityObject(obj).velocity.x = Math.min(0, VelocityObject(obj).velocity.x);
					if (VelocityObject(obj).bound && obj.objectRef != null) obj.objectRef.destroy();
				}
			}
			
			if (!isNaN(_minY) && obj.position.y < _minY) {
				obj.position.y = _maxY;
			} else if (!isNaN(_maxY) && obj.position.y > _maxY) {
				obj.position.y = _maxY;
			}

		}
		

		//
		//
		private function getArrayFor (obj:SimulationObject):Array {
			
			if (obj is MotionObject) return _motionObjects;
			else if (obj is VelocityObject) return _velocityObjects;
			else return _staticObjects;	
			
		}
		
		//
		//
		public function addObject (obj:SimulationObject):SimulationObject {
			
			if (obj.collisionObject.type == 3)
			{
				var t:int = 1;
			}
			var objArray:Array = getArrayFor(obj);

			if (objArray.indexOf(obj) == -1) {
				
				objArray.push(obj);
				_grid.register(obj);
				if (obj is MotionObject) _motionObjectGrid.register(obj);

			}
			
			if (obj is CompoundObject && _compoundObjects.indexOf(obj) == -1) _compoundObjects.push(obj);
			
			obj.simulation = this;
			
			return obj;
			
		}
		
		//
		//
		public function removeObject (obj:SimulationObject):Boolean {
			
			_grid.unregister(obj);
			if (obj is MotionObject) _motionObjectGrid.unregister(obj);
			
			var objArray:Array = getArrayFor(obj);
			
			if (objArray.indexOf(obj) != -1) {
					
				objArray.splice(objArray.indexOf(obj), 1);	
				
				if (obj is CompoundObject && _compoundObjects.indexOf(obj) != -1) _compoundObjects.splice(_compoundObjects.indexOf(obj), 1);

				return true;
					
			}
			
			return false;
			
		}
		
		//
		//
		public function updateObject (obj:SimulationObject):void {
			
			_grid.update(obj);
			if (obj is MotionObject) _motionObjectGrid.update(obj);
			
		}
		
		//
		//
		public function addForce (force:Force, obj:SimulationObject = null):void {
			
			if (!running) return;
			
			if (obj == null) {
				
				_generalForces.push(force);
				
			} else {
				
				if (obj is MotionObject) {
				
					if (_forces[force] == null) {
						
						_forces[force] = obj;
						
					} else if (_forces[force] != obj) {
						
						if (_forces[force] is SimulationObject) {
							
							var forceObject:SimulationObject = _forces[force];
							
							_forces[force] = [forceObject, obj];
							
						}
						
						if (_forces[force] is Array) {
						
							var forceObjects:Array = _forces[force];
							
							if (forceObjects.indexOf(obj) == -1) forceObjects.push(obj);
							
						} 

					}
					
				}
			
			}

		}
		
		//
		//
		public function removeForce (force:Force):Boolean {
			
			if (_generalForces.indexOf(force) != -1) {
			
				_generalForces.splice(_generalForces.indexOf(force), 1);
				return true;
				
			}
			
			if (_forces[force] != null) {
				
				delete _forces[force];
				return true;
				
			}
			
			return false;
			
		}
		
		//
		//
		public function clearForces ():void {
			
			_forces = new Dictionary(false);
			
		}
		
		//
		//
		public function setBounds (minX:Number = NaN, maxX:Number = NaN, minY:Number = NaN, maxY:Number = NaN):void {

			_minX = minX;
			_maxX = maxX;
			_minY = minY;
			_maxY = maxY;
	
		}
		
		//
		//
		public function addBoundary (obj:SimulationObject):void {
			

			if (_generalBoundaries.indexOf(obj) == -1) {
				
				_generalBoundaries.push(obj);
				
			}
			
		}
		
		//
		//
		public function removeBoundary (obj:SimulationObject):void {
			

			if (_generalBoundaries.indexOf(obj) != -1) {
				
				_generalBoundaries.splice(_generalBoundaries.indexOf(obj), 1);
				
			}
			
		}
		
	}
	
}
