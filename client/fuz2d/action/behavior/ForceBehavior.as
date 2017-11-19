/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.behavior {
	
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Point;
	import fuz2d.action.physics.*;
	import fuz2d.action.play.BipedObject;
	import fuz2d.action.play.PlayObject;
	import fuz2d.action.play.PlayObjectControllable;
	import fuz2d.model.material.Material;
	import fuz2d.model.object.Bone;
	import fuz2d.model.object.Circle2d;
	import fuz2d.model.object.Handle;
	import fuz2d.model.object.Symbol;
	import fuz2d.model.object.Point2d;
	import fuz2d.model.object.Toolset;
	import fuz2d.screen.shape.Circle;
	
	import fuz2d.model.object.Biped;
	import fuz2d.model.object.Object2d;
	
	import fuz2d.util.Geom2d;

	public class ForceBehavior extends Behavior {
		
		protected var _handles:Array;
		protected var _toolset:Toolset;
		protected var _toolname:String;
		
		override public function get idle():Boolean { return super.idle; }
		
		override public function set idle(value:Boolean):void 
		{
			super.idle = value;
			if (_idle) {
				if (forceObject != null && forceObject.objectRef != null) forceObject.objectRef.material.glow = false;
				forceObject = null;
			}
			
		}
		
		protected var _forceObject:MotionObject;
		
		protected var _force:Vector2d;
		
		public function get forceObject():MotionObject { return _forceObject; }
		
		public function set forceObject(value:MotionObject):void 
		{
			if (_forceObject != null) clearObject();
			_forceObject = value;
		}
		
		public function get force():Vector2d { return _force; }
		
		public function set force(value:Vector2d):void 
		{
			_force = value;
		}
		
		//
		//
		public function ForceBehavior (handles:Array, toolset:Toolset, toolname:String, priority:int) {
			
			super(priority);
			
			_handles = [];
			_toolset = toolset;
			_toolname = toolname;
			
			_force = new Vector2d();
			
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
			if (_forceObject != null && _toolset.toolname == _toolname) idle = false;
			else idle = true;
			if (_toolset.toolname != _toolname) idle = true;
			if (!idle) resolve();
			
		}
		
		//
		//
		public function findObject ():void {
			
			if (_forceObject != null) clearObject();
			
			var loc:Point = _parentClass.modelObject.point.clone();
			var facing:int;
			
			if (_parentClass.modelObject is Biped) {
				
				facing = Biped(_parentClass.modelObject).facing;
				
				if (facing == Biped.FACING_LEFT) {
					
					loc.x -= 100;
					
				} else if (facing == Biped.FACING_RIGHT) {
					
					loc.x += 100;
					
				}
				
			}
			
			var neighbors:Array = _parentClass.simulation.getNeighborsNear(loc, true, false, 2);
			//var neighbors:Vector.<SimulationObject> = _parentClass.simulation.getNeighborsNear(loc, true, false, 2);
			var neighbor:SimulationObject;

			for (var i:int = 0; i < neighbors.length; i++) {
				
				neighbor = neighbors[i];
				
				if (neighbor is MotionObject && !neighbor.deleted) {
					
					if (isNaN(facing) || 
						(facing == Biped.FACING_LEFT && neighbor.position.x < _parentClass.simObject.position.x) || 
						(facing == Biped.FACING_RIGHT && neighbor.position.x > _parentClass.simObject.position.x)) {

						forceObject = MotionObject(neighbor);
						forceObject.objectRef.material.glow = true;
						forceObject.objectRef.material.glowColor = 0x0066ff;
						forceObject.gravity = 0;
						forceObject.damping = 0.2;
						forceObject.sleeping = false;
						return;
					
					}
					
				}
				
			}
			
		}
		
		//
		//
		public function clearObject ():void {

			if (_forceObject != null) {
					
				_forceObject.gravity = _forceObject.originalGravity;
				_forceObject.damping = _forceObject.originalDamping;
					
				if (_forceObject.objectRef != null && _forceObject.objectRef.material != null) {
					
					_forceObject.objectRef.material.glow = false;
					
				}
				
				_forceObject = null;
				
			}
			
		}
		
		//
		//
		override public function assumeControl(force:Boolean = false):void {
			
			if (_forceObject != null) for each (var handle:Handle in _handles) if (handle.controller == null || force) handle.controller = this;

		}
		
		//
		//
		override public function releaseControl():void {
			
			for each (var handle:Handle in _handles) if (handle.controller == this) handle.controller = null;
			
		}
		
		//
		//
		override public function resolve():void {
			
			super.resolve();

			if (_forceObject != null && !_forceObject.deleted) {
				
				for each (var handle:Handle in _handles) if (handle.controller == this) {
					handle.alignTo(_forceObject.objectRef);
					handle.pull(0.3);
				}
				
				if (!_force.negligible) {
					
					_forceObject.addForce(_force);
					
					_force.reset();
					
				}
				
				if (_parentClass.modelObject is Biped) {
					
					var b:Biped = Biped(_parentClass.modelObject);
					
					if (b.facing == Biped.FACING_LEFT && _forceObject.position.x > b.x) {
						b.updateStance(Biped.FACING_RIGHT);
					} else if (b.facing == Biped.FACING_RIGHT && _forceObject.position.x < b.x) {
						b.updateStance(Biped.FACING_LEFT);
					}
					
				}
				
			} else clearObject();
			
		}
		
	}
	
}