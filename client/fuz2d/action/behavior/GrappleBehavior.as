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
	import flash.media.SoundChannel;
	import fuz2d.action.physics.*;
	import fuz2d.action.play.BipedObject;
	import fuz2d.action.play.PlayObject;
	import fuz2d.action.play.PlayObjectControllable;
	import fuz2d.Fuz2d;
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

	public class GrappleBehavior extends Behavior {
		
		protected var _handles:Array;
		protected var _toolset:Toolset;
		protected var _toolname:String;
		
		protected var _grappleSound:SoundChannel;
		
		override public function get idle():Boolean { return super.idle; }
		
		override public function set idle(value:Boolean):void 
		{
			super.idle = value;
			if (_idle) targetObject = null;
			
		}
		
		protected var _targetObject:SimulationObject;
		
		public function get targetObject():SimulationObject { return _targetObject; }
		
		public function set targetObject(value:SimulationObject):void 
		{
			
			if (_targetObject != null) clearObject();
			
			_targetObject = value;
			
			if (_targetObject != null && _targetObject.objectRef != null) {
				MotionObject(_parentClass.simObject).swingPoint = _targetObject.objectRef.point;
				_toolset.toolHitPoint = _targetObject.objectRef.point;
			} else {
				MotionObject(_parentClass.simObject).swingPoint = null;
				_toolset.toolHitPoint = null;
			}
			
		}
		
		
		//
		//
		public function GrappleBehavior (handles:Array, toolset:Toolset, toolname:String, priority:int) {
			
			super(priority);
			
			_handles = [];
			_toolset = toolset;
			_toolname = toolname;
			
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
			if (_targetObject != null && _toolset.toolname == _toolname) idle = false;
			else idle = true;
			if (_toolset.toolname != _toolname) idle = true;
			if (!idle) resolve();
			
		}
		
		//
		//
		public function findObject ():void {
			
			var loc:Point = _parentClass.modelObject.point.clone();
			var facing:int;
			
			if (_parentClass.modelObject is Biped) {
				
				facing = Biped(_parentClass.modelObject).facing;
				
				if (facing == Biped.FACING_LEFT && MotionObject(_parentClass.simObject).velocity.x < -20) {
					
					loc.x -= 150;

				} else if (facing == Biped.FACING_RIGHT && MotionObject(_parentClass.simObject).velocity.x > 20) {
					
					loc.x += 150;
					
				}
				
				loc.y += 250;
				
			}
			
			var neighbors:Array = _parentClass.simulation.getNeighborsNear(loc, true, false, 2);
			//var neighbors:Vector.<SimulationObject> = _parentClass.simulation.getNeighborsNear(loc, true, false, 2);
			var neighbor:SimulationObject;

			for (var i:int = 0; i < neighbors.length; i++) {
				
				neighbor = neighbors[i];
				
				if (neighbor is VelocityObject) {
					
				} else {
					
					if (neighbor.collisionObject.reactionType == ReactionType.BOUNCE && neighbor.position.y > _parentClass.simObject.position.y) {
					
						if (isNaN(facing) || 
							(facing == Biped.FACING_LEFT && neighbor.position.x < _parentClass.simObject.position.x) || 
							(facing == Biped.FACING_RIGHT && neighbor.position.x > _parentClass.simObject.position.x)) {

							targetObject = neighbor;
							return;
						
						}
					
					}
					
				}
				
			}
			
		}
		
		//
		//
		public function clearObject ():void {

			if (_targetObject != null) {
					
				_targetObject = null;

			}
			
			if (_grappleSound != null) {
				_grappleSound.stop();
				_grappleSound = null;
			}
			
		}
		
		//
		//
		public function climb ():void {
			
			var mo:MotionObject = MotionObject(_parentClass.simObject);
			
			if (mo.swingLength > 100) {
				
				mo.swingLength -= 6;
	
			}
			
		}
		
		//
		//
		public function repel ():void {
			
			var mo:MotionObject = MotionObject(_parentClass.simObject);
			
			if (mo.swingLength < 800) {
				
				mo.swingLength += 6;
				
			}
			
		}
		
		//
		//
		override public function assumeControl(force:Boolean = false):void {
			
			if (_targetObject != null) for each (var handle:Handle in _handles) if (handle.controller == null || force) handle.controller = this;

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

			if (_targetObject != null && !_targetObject.deleted) {
				
				for each (var handle:Handle in _handles) if (handle.controller == this) {
					handle.alignTo(_targetObject.objectRef);
					handle.pull(10);
				}
				
				if (_grappleSound == null) {
					_grappleSound = Fuz2d.sounds.addSoundLoop(_parentClass.playObject, "grapple1");
				}
	
			} else clearObject();
			
		}
		
	}
	
}