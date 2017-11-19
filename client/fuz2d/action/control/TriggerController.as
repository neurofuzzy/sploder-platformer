/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.action.control {
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
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
	public class TriggerController extends PlayObjectController {
		
		protected var _switchName:String = "";
		public function get switchName():String { return _switchName; }
		
		public function get triggered():Boolean { return _triggered; }

		protected var _triggerTime:int;
		protected var _triggerEndTime:int;
		protected var _triggerCascadeTime:int;
		protected var _triggerCascadeTimer:Timer;
		protected var _onAtStart:Boolean = false;
		
		protected var _triggered:Boolean = false;
		protected var _reactionType:int;

		//
		//
		public function TriggerController (object:PlayObjectControllable, switchName:String = "none", triggerEndTime:int = 0, triggerCascadeTime:int = 500, onAtStart:Boolean = false) {
		
			super(object);
			
			_switchName = switchName;
			_triggerEndTime = triggerEndTime;
			_triggerCascadeTime = Math.max(10, triggerCascadeTime);
			_triggerCascadeTimer = new Timer(_triggerCascadeTime, 1);
			_triggerCascadeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, triggerNeighbors);
			_reactionType = _object.simObject.collisionObject.reactionType;
			_onAtStart = onAtStart;
			if (_onAtStart) trigger();
			else untrigger();
			_triggerTime = 0;
				
		}
		
		//
		//
		override public function update (e:Event):void {
			
			super.update(e);
			
			if (_ended) return;
			
			if (!_triggered) {
				_object.simObject.collisionObject.reactionType = ReactionType.PASSTHROUGH;
				Symbol(_object.object).state = "f_inactive";
				return;
			}
			
			if (_triggerEndTime > 0 && TimeStep.realTime - _triggerTime > _triggerEndTime) {

				_triggerTime = TimeStep.realTime;
				if (_triggered) _object.eventSound("untrigger");
				_triggered = false;
				_object.simObject.collisionObject.reactionType = ReactionType.PASSTHROUGH;
				Symbol(_object.object).state = "idle";
				
			} else {
				
				if (_triggerEndTime > 0) {
					
					_object.simObject.collisionObject.reactionType = _reactionType;
					Symbol(_object.object).state = "" + (2 + Math.ceil(100 * ((TimeStep.realTime - _triggerTime) / _triggerEndTime)));
					
				} else {
					
					if (_triggered) Symbol(_object.object).state = "f_active";
				}
				
			}
			
		}
		
		//
		//
		public function trigger (cascade:Boolean = false):void {

			if (!_triggered && TimeStep.realTime - _triggerTime > 250) {

				_triggerTime = TimeStep.realTime;
				_triggered = true;
				_object.simObject.collisionObject.reactionType = _reactionType;
				_object.playfield.map.register(_object, _object.object.x, _object.object.y);
				
				if (cascade) {
					_triggerCascadeTimer.start();
					_object.eventSound("trigger");
				}
				
			}

		}
		
		//
		//
		public function untrigger (cascade:Boolean = false):void {

			if (_triggered && TimeStep.realTime - _triggerTime > 250) {

				_triggerTime = TimeStep.realTime;
				_triggered = false;
				_object.simObject.collisionObject.reactionType = ReactionType.PASSTHROUGH;
				
				_object.playfield.map.unregister(_object);
				
				if (cascade) {
					_triggerCascadeTimer.start();
					_object.eventSound("untrigger");
				}
				
			}

		}
		
		//
		//
		//
		//
		public function triggerNeighbors (e:TimerEvent):void {
				
			var playObj:PlayObjectControllable;
			
			var triggerObjects:Array = getTriggerObjects(_object.model.getNearObjects(_object.object));
				
			for each (var obj:Object2d in triggerObjects) {
				
				if (obj != null && !obj.deleted && obj.simObject != null && _object.playfield.playObjects[obj.simObject] != null) {
					
					playObj = _object.playfield.playObjects[obj.simObject];
					
					if (playObj.controller != null && Geom2d.distanceBetweenPoints(_object.object.point, obj.point) < Model.GRID_WIDTH * 1.9) {
						
						if (_triggered) TriggerController(playObj.controller).trigger(true);
						else TriggerController(playObj.controller).untrigger(true);
						
					}
					
				}
				
			}
			
			_triggerCascadeTimer.reset();
			
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
				element != _object.object &&
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
		override public function end():void 
		{
			if (_triggerCascadeTimer) {
				_triggerCascadeTimer.stop();
				_triggerCascadeTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, triggerNeighbors);
			}
			super.end();
		}
		
		
	}

}