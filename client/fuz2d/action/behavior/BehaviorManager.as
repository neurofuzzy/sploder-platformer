/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.behavior {

	import fuz2d.action.physics.MotionObject;
	import fuz2d.action.physics.Simulation;
	import fuz2d.action.physics.SimulationObject;
	import fuz2d.action.play.IPlayfieldUpdatable;
	import fuz2d.action.play.Playfield;
	import fuz2d.action.play.PlayfieldEvent;
	import fuz2d.action.play.PlayObject;
	import fuz2d.model.object.Object2d;
	
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	
	public class BehaviorManager implements IPlayfieldUpdatable {
		
		protected var _simulation:Simulation;
		
		protected var _modelObject:Object2d;
		protected var _simObject:SimulationObject;
		protected var _playObject:PlayObject;
		
		public function get simulation():Simulation { return _simulation; }	
		public function get modelObject():Object2d { return _modelObject; }	
		public function get simObject():SimulationObject { return _simObject; }	
		public function get playObject():PlayObject { return _playObject; }
			
		protected var _behaviors:Array;
		
		//
		//
		public function BehaviorManager (playObj:PlayObject = null) {
		
			init(playObj);
			
		}
		
		//
		//
		protected function init (playObj:PlayObject = null):void {
			
			try {
			_playObject = playObj;
			_simObject = playObj.simObject;
			_modelObject = playObj.simObject.objectRef;
			_simulation = playObj.simObject.simulation;
			} catch (e:Error) {
				trace("BehaviorManager init:", e);
			}
			_behaviors = [];
			
			//_playObject.playfield.addEventListener(PlayfieldEvent.UPDATE, update, false, 0, true);
			_playObject.playfield.listen(this);
		}
		
		//
		//
		public function update (e:Event):void {
			
			if (_playObject.object == null || _playObject.object.deleted) _playObject.destroy();
			if (_behaviors.length == 0) return;		
			if (_playObject.simObject is MotionObject && MotionObject(_playObject.simObject).sleeping) return;
			try {
				for each (var behavior:Behavior in _behaviors) if (!behavior.sleeping && !behavior.ended) behavior.update(e);
			} catch (e:Error) {
				trace("BehaviorManager update:", e);
			}
		}
		
		//
		//
		public function add (behavior:Behavior):Behavior {
			
			_behaviors.push(behavior);
			behavior.parentClass = this;
			behavior.addEventListener(Behavior.END, ended, false, 0, true);
			
			return behavior;
			
		}
		
		//
		//
		public function remove (behavior:Behavior):Boolean {
			
			if (_behaviors.indexOf(behavior) != -1) {
				_behaviors.splice(_behaviors.indexOf(behavior), 1);
				return true;
			}
			
			return false;
			
		}
		
		//
		//
		public function contains (behavior:Behavior):Boolean {
			
			if (_behaviors.indexOf(behavior) != -1) return true;
	
			return false;
			
		}
		
		//
		//
		public function containsClass (c:Class):Boolean {
			
			for each (var behavior:Behavior in _behaviors) if (getQualifiedClassName(behavior) == getQualifiedClassName(c)) return true;
			
			return false;
			
		}
		
		//
		//
		public function removeAllOfClass (c:Class):Boolean {
			
			for each (var behavior:Behavior in _behaviors) if (getQualifiedClassName(behavior) == getQualifiedClassName(c)) remove(behavior);
			
			return false;
			
		}
		
		//
		//
		public function ended (e:Event):void {
			
	
		}
		
		//
		//
		public function reset ():void {
			_behaviors = [];
		}
		
		//
		//
		public function end ():void {
			
			for each (var behavior:Behavior in _behaviors) {
				behavior.end()
				remove(behavior);
			}

			reset();
			
			//_playObject.playfield.removeEventListener(PlayfieldEvent.UPDATE, update)
			_playObject.playfield.unlisten(this);
		}
		
		/* INTERFACE fuz2d.action.play.IPlayfieldUpdatable */
		
		public function onPlayfieldUpdate():void 
		{
			update(null);
		}
		
	}
	
}