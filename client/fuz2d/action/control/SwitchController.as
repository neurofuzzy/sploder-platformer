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
	import fuz2d.model.Model;
	import fuz2d.model.object.Object2d;
	import fuz2d.model.object.Symbol;
	import fuz2d.TimeStep;
	import fuz2d.util.Geom2d;
	
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class SwitchController extends PlayObjectController {
		
		public static var switches:Object;
		
		protected var _switchName:String = "";
		public function get switchName():String { return _switchName; }
		
		protected var _localize:Boolean = false;

		protected var _switchTime:int;
		protected var _switchTimeInterval:int;
		protected var _switched:Boolean = false;

		//
		//
		public function SwitchController (object:PlayObjectControllable, switchName:String = "none", localize:Boolean = false, switchTimeInterval:int = 1000) {
		
			super(object);
			
			if (switches == null) switches = { };
			
			_switchName = switchName;
			_localize = localize;
			_switchTimeInterval = switchTimeInterval;
			
			if (_switchName.length > 0 && switches[_switchName] == null) switches[_switchName] = false;
			
			_object.simObject.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);
			
		}
		
		//
		//
		override public function update (e:Event):void {
			
			super.update(e);
			
			if (_switched && TimeStep.realTime - _switchTime >= _switchTimeInterval) {
				
				Symbol(_object.object).state = "f_idle";
				_switched = false;
				
			}

		}
		
		//
		//
		public function trigger (state:Boolean = true):void {
				
			var obj:Object2d;
			
			switches[_switchName] = state;
			
			var playObj:PlayObjectControllable;
			
			var triggerObjects:Array;
			
			if (_localize) {
				
				var totalBlocks:int = 0;
				
				triggerObjects = getTriggerObjects(_object.model.getNearObjects(_object.object));
				
				for each (obj in triggerObjects) {
					
					if (obj != null && !obj.deleted && obj.simObject != null && _object.playfield.playObjects[obj.simObject] != null) {
						
						playObj = _object.playfield.playObjects[obj.simObject];
						
						if (playObj.controller != null && Geom2d.distanceBetweenPoints(_object.object.point, obj.point) < Model.GRID_WIDTH * 1.9) {
						
							if (state) TriggerController(playObj.controller).trigger(true);
							else TriggerController(playObj.controller).untrigger(true);
							
							totalBlocks++;
							
						}
						
					}
					
				}
				
				if (totalBlocks > 0) return;
				
			}
				
			triggerObjects = getTriggerObjects(_object.model.objects);
			
			for each (obj in triggerObjects) {
				
				if (obj != null && !obj.deleted && obj.simObject != null && _object.playfield.playObjects[obj.simObject] != null) {
					
					playObj = _object.playfield.playObjects[obj.simObject];
					
					if (playObj.controller != null) {
						
						if (state) TriggerController(playObj.controller).trigger(true);
						else TriggerController(playObj.controller).untrigger(true);
						
					}
					
				}
				
			}
				
			
		}
		
		
		//
		//
		public function getTriggerObjects (objects:Array):Array {
			
			return objects.filter(hasTrigger);
	
		}
		
		//
		//
		public function hasTrigger(element:*, index:int, arr:Array):Boolean {
			
			if (element != null && 
				element is Object2d && 
				Object2d(element).simObject != null && 
				_object.playfield.playObjects[Object2d(element).simObject] is PlayObjectControllable &&
				PlayObjectControllable(_object.playfield.playObjects[Object2d(element).simObject]).controller is TriggerController
				) {
					return TriggerController(PlayObjectControllable(_object.playfield.playObjects[Object2d(element).simObject]).controller).switchName == switchName;
				}
				
			return false;
			
		}
		
		//
		//
		protected function onCollision (e:CollisionEvent):void {
	
			if (!_switched && TimeStep.realTime - _switchTime >= _switchTimeInterval) {
				
				var triggerObjects:Array = getTriggerObjects(_object.model.objects);
				var playObj:PlayObjectControllable;
				
				var allSwitchesState:Boolean = false;
				
				for each (var obj:Object2d in triggerObjects) {
					
					if (obj != null && !obj.deleted && obj.simObject != null && _object.playfield.playObjects[obj.simObject] != null) {
						
						playObj = _object.playfield.playObjects[obj.simObject];
						
						if (playObj.controller != null) {
							
							if (TriggerController(playObj.controller).triggered) allSwitchesState = true;
							
						}
						
					}
					
				}
				
				switches[_switchName] = allSwitchesState;
	
				_switchTime = TimeStep.realTime;

				trigger(!(switches[_switchName]));
				
				_switched = true;

				Symbol(_object.object).state = "f_switched";
				_object.eventSound("switch");
				if (!_localize) _object.eventSound("trigger");
				
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