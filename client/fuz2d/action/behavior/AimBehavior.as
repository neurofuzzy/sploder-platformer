/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.behavior {
	
	import flash.events.Event;
	import flash.geom.Point;
	import fuz2d.action.physics.*;
	import fuz2d.action.play.PlayObject;
	import fuz2d.library.ObjectFactory;
	import fuz2d.model.object.Biped;
	import fuz2d.model.object.Handle;
	import fuz2d.model.object.Symbol;
	import fuz2d.model.object.Toolset;
	import fuz2d.TimeStep;
	import fuz2d.util.Geom2d;
	
	

	public class AimBehavior extends Behavior {
		
		protected var _handles:Array;
		protected var _toolset:Toolset;

		protected var _firing:Boolean = false;
		public function get firing():Boolean { return _firing; }
		protected var _fireTime:int = 0;
		protected var _fireDuration:int = 100;
		protected var _fireDelay:int = 1000;
		
		protected var _released:Boolean = false;
		
		override public function get idle():Boolean { return super.idle; }
		
		override public function set idle(value:Boolean):void 
		{
			super.idle = value;
			if (_idle) {
				targetObject = null;
				_hitPoint = null;
				_toolset.toolHitPoint = null;
			}
			
		}
		
		protected var _targetObject:SimulationObject;
		
		public function get targetObject():SimulationObject { return _targetObject; }
		
		public function set targetObject(value:SimulationObject):void 
		{
			if (_targetObject != null) clearObject();
			_targetObject = value;		
		}
		
		protected var _targetGroup:String;
		
		protected var _hitPoint:Point;
		
		protected var _projectileDrop:int = 0;
		protected var _projectileSpeed:int = 0;
		protected var _lastTool:String = "";
		
		public var styleToss:Boolean = false;
		public var tossOffset:Number = 0;
		public var altHandle:Handle;

		
		//
		//
		public function AimBehavior (handles:Array, toolset:Toolset, targetGroup:String = "evil", fireDuration:int = 100, fireDelay:int = 1000, priority:int = 0) {
			
			super(priority);
			
			_handles = [];
			_toolset = toolset;
			_targetGroup = targetGroup;
			_fireDuration = fireDuration;

			if (_toolset.spawns) _fireDelay = _toolset.spawnDelay;
			else _fireDelay = fireDelay;

			if (handles != null) {
				for (var i:int = 0; i < handles.length; i++) {
					if (handles[i] is Handle) addHandle(Handle(handles[i]));
				}
			}	
			
		}

		
		//
		//
		override protected function init(parentClass:BehaviorManager):void {
			
			super.init(parentClass);
			
			assign();

		}
		
		//
		//
		public function addHandle (handle:Handle):void {
			if (_handles.indexOf(handle) == -1) _handles.push(handle);
		}
		
		//
		//
		public function removeHandle (handle:Handle):void {
			if (_handles.indexOf(handle) != -1) _handles.splice(_handles.indexOf(handle), 1);
		}
		
		//
		//
		override public function assign():void {
			
			for each (var handle:Handle in _handles) handle.controller = this;
			
		}
		
		//
		//
		override public function update(e:Event):void {
			
			super.update(e);
			if (_targetObject != null && _toolset.action == "aim") idle = false;
			if (_toolset.action != "aim") idle = true;
			if (idle == false && !_firing) _toolset.toolHitPoint = null;
			if (!idle) resolve();
			
		}
		
		//
		//
		public function findObject ():Boolean {
			
			var loc:Point = _parentClass.modelObject.point.clone();
			var facing:int;
			
			if (_parentClass.modelObject is Biped) {
				
				facing = Biped(_parentClass.modelObject).facing;
				
				if (facing == Biped.FACING_LEFT) {
					
					loc.x -= 250;

				} else if (facing == Biped.FACING_RIGHT) {
					
					loc.x += 250;
					
				}
				
				loc.y += 250;
				
			}
			
			var neighbors:Array = _parentClass.simulation.getNeighborsNear(loc, true, false, 3);
			//var neighbors:Vector.<SimulationObject> = _parentClass.simulation.getNeighborsNear(loc, true, false, 3);
			var neighbor:SimulationObject;
			
			neighbors.reverse();

			for (var i:int = 0; i < neighbors.length; i++) {
				
				neighbor = neighbors[i];

				if (!neighbor.isProjectile && neighbor.objectRef is Symbol && neighbor.group == _targetGroup) {
				
					if (isNaN(facing) || 
						(facing == Biped.FACING_LEFT && neighbor.position.x < _parentClass.simObject.position.x) || 
						(facing == Biped.FACING_RIGHT && neighbor.position.x > _parentClass.simObject.position.x)) {

						targetObject = neighbor;
						_fireTime = TimeStep.realTime;
						return true;
					
					}
					
				}
				
			}
			
			return false;
			
		}
		
		//
		//
		public function clearObject ():void {

			if (_targetObject != null) {
					
				_targetObject = null;
				_hitPoint = null;
				
			}
			
		}
		
		//
		//
		public function fire ():Boolean {
			

			if (!_firing && TimeStep.realTime - _fireTime > _fireDelay) {

				_firing = true;
				_fireTime = TimeStep.realTime;
				
				PlayObject.launchNew(_toolset.spawn, _parentClass.playObject, _toolset, 200);
				
				_toolset.active = false;
				return true;
					
			}
			
			return false;
			
		}
		
		//
		//
		protected function adjustAim (handle:Handle):void {
			
			if (_projectileDrop != 0 && _targetObject != null) {
				
				var ptA:Point = _toolset.tooltip;
				var ptB:Point = _targetObject.objectRef.point;
				ptB = ptB.subtract(ptA);
				var dx:Number = ptB.x;

				var newVel:Vector2d = new Vector2d(null, _projectileSpeed, 0);
				newVel.rotate(0 - _toolset.toolRotation);
				
				if (Math.abs(newVel.x) > 0) {
					
					var t:Number = dx / newVel.x;
					var dist:Number = 0 - (1 / 2) * (_projectileDrop * 30) * t * t;
						
					handle.y -= dist;
				
				}
				
			}
			
		}
		
		//
		//
		protected function trackHitPoint ():Object {
		
			var v:Vector2d;
			
			try {
				
				var hitObj:Object = PlayObject.hitTestSegment(_parentClass.playObject, _toolset, 300);

				if (hitObj != null) {
					trace("HIT", hitObj.obj, hitObj.pt);

					_hitPoint = hitObj.pt;

					_toolset.toolHitPoint = new Point(_hitPoint.x, _hitPoint.y);
					
					v = new Vector2d(null, PlayObject(hitObj.obj).object.width * 0.5, 0);
					v.rotate(0 - _toolset.toolRotation);
					_toolset.toolHitPoint.x += v.x;
					_toolset.toolHitPoint.y += v.y;
					
					return hitObj;
					
				} else {
					trace("NO HITTO");
					var ptA:Point = _toolset.tooltip;
					var ptB:Point = Point.polar(300, 0 - _toolset.toolRotation);
					ptB = ptB.add(ptA);
					_toolset.toolHitPoint = ptB;
						
				}
			
			} catch (e:Error) {
				
				_toolset.toolHitPoint = null;
				trace("AimBehavior:", e);
			}
			
			return null;

		}
		
		
		//
		//
		override public function assumeControl(force:Boolean = false):void {

			for each (var handle:Handle in _handles) if (handle.controller == null || force) handle.controller = this;
			
			if (altHandle) altHandle.controller = this;
			
			_released = false;

		}
		
		//
		//
		override public function releaseControl():void {

			for each (var handle:Handle in _handles) if (handle.controller == this) handle.controller = null;
			
			if (altHandle) altHandle.controller = null;
			
			_released = true;
			
		}
		
		//
		//
		override public function resolve():void {
			
			super.resolve();
			
			if (styleToss) {
				if (!_toolset.active) {
					if (TimeStep.realTime - _fireTime > _fireDelay - 2000) {
						assumeControl(true);
						_toolset.active = true;
					} else if (!_released) {
						releaseControl();
						return;
					}
				}
			}

			if (_lastTool != _toolset.spawn) {
				
				_lastTool = _toolset.spawn;
				
				var spawnDef:XML = ObjectFactory.getNodeByNameAndID("playobj", _toolset.spawn);
				
				_projectileDrop = 0;
				if ("@drop" in spawnDef..ctrl) _projectileDrop = parseInt(spawnDef..ctrl.attribute("drop"));
				_projectileSpeed = 0;
				if ("@speed" in spawnDef..ctrl) _projectileSpeed = parseInt(spawnDef..ctrl.attribute("speed"));

			}

			var handle:Handle;
			var facing:int = 0;
			
			if (_firing && TimeStep.realTime - _fireTime > _fireDuration) {
				
				_firing = false;
				_hitPoint = null;
				_toolset.toolHitPoint = null;
				
			} else if (_firing) {
				
				trackHitPoint();
				
			}
							
			if (_targetObject != null && !_targetObject.deleted) {
				
				if (_parentClass.modelObject is Biped) {
					
					facing = Biped(_parentClass.modelObject).facing;			
					
					if ((facing == Biped.FACING_LEFT && _targetObject.position.x > _parentClass.simObject.position.x) || 
						(facing == Biped.FACING_RIGHT && _targetObject.position.x < _parentClass.simObject.position.x)) {
							
						clearObject();
						return;
							
					}
						
				}
				
				for each (handle in _handles) if (handle.controller == this) {
					
					if (_toolset.localToolRotation == 0) {
						handle.alignTo(_targetObject.objectRef);
					} else {
						var tt:Point = _toolset.tooltip;
						var hpt:Point = _targetObject.objectRef.point.subtract(tt);
						if (facing == Biped.FACING_LEFT) {
							Geom2d.rotatePoint(hpt, 0 - _toolset.localToolRotation);
						} else {
							Geom2d.rotatePoint(hpt, _toolset.localToolRotation);
						}
						hpt.x += tt.x;
						hpt.y += tt.y;
						handle.alignToPoint(hpt);
					}
					
					if (styleToss && facing) {
						var t:int = 0;
						var d:Number = 0;
						t = (TimeStep.realTime - _fireTime) - _fireDelay;
						if (t > -1000 && t < 0) {
							d= (500 - Math.abs(t + 500)) * 5;
							handle.y += d;
							if (facing == Biped.FACING_LEFT) handle.x += d * 2;
							else handle.x -= d * 2;
						}
					}
					
					handle.pull(10);
					adjustAim(handle);
					handle.pull(10);
					
				}
				
				if (styleToss && altHandle) {
					altHandle.x = _parentClass.playObject.object.x + _parentClass.playObject.object.x - _toolset.tooltip.x;
					altHandle.y = _parentClass.playObject.object.y + _parentClass.playObject.object.y - _toolset.tooltip.y;
					altHandle.pull(10);
				}
	
			} else clearObject();
			

			if (_targetObject == null) {
				
				var result:Boolean = findObject();
				
				if (!result && _parentClass.modelObject is Biped) {
				
					var body:Biped = Biped(_parentClass.modelObject);
					
					for each (handle in _handles) if (handle.controller == this) {
						
						handle.center();
						
						if (body.facing == Biped.FACING_LEFT) handle.x -= 100;
						else if (body.facing == Biped.FACING_RIGHT) handle.x += 100;
						else handle.y -= 100;

						handle.y -= 2;
						handle.pull(10);
						
					}
					
				}
				
			}
			
		}
		
		override public function end():void 
		{
			altHandle = null;
			super.end();
		}
		
	}
	
}