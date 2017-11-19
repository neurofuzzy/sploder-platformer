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
	import fuz2d.model.object.Object2d;
	import fuz2d.TimeStep;
	import fuz2d.util.Geom2d;
	
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class ProximityController extends PlayObjectController {
		
		protected var _searching:Boolean = false;
		
		protected var _projectileID:String;
		protected var _range:Number;
		protected var _lastResponse:int;
		protected var _responseInterval:int;
			
		//
		//
		public function ProximityController (object:PlayObjectControllable, projectileID:String, range:Number = 300, responseInterval:int = 3000) {
		
			super(object);
			
			_projectileID = projectileID;
			_range = range;
			_responseInterval = Math.max(1000, responseInterval);
			_lastResponse = 0;
			
			_object.simObject.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);

		}
		
		//
		//
		override public function see(p:PlayObject):void {
			
			super.see(p);

			if (p.simObject is MotionObject) _searching = true;
			
		}
		
		//
		//
		override public function update (e:Event):void {
			
			if (_ended || !_active) return;
			
			super.update(e);
			
			if (_searching && TimeStep.realTime - _lastResponse > _responseInterval) {
				
				if (objectIsNear) respond();
				
			}
				
		}
		
		//
		//
		protected function respond ():void {
			
			PlayObject.launchNew(_projectileID, _object);
			_lastResponse = TimeStep.realTime;
			
		}
		
		//
		//
		protected function get objectIsNear ():Boolean {
			
			if (!_object.deleted && _object.object != null) {
				
				var nearObjects:Array = _object.model.getNearObjects(_object.object, true);

				for (var i:int = nearObjects.length - 1; i >= 0; i--) {
					if (!(Object2d(nearObjects[i]).simObject is MotionObject)) nearObjects.splice(i, 1);
				}
				
				if (nearObjects.length == 0) {
					_searching = false;
					return false;
				}
				
				return (nearObjects.length > 0 && 
					Object2d(nearObjects[0]) != null &&
					!Object2d(nearObjects[0]).deleted && 
					Geom2d.distanceBetweenPoints(_object.object.point, Object2d(nearObjects[0]).point) <= _range);
				
			}
			
			return false;
			
		}
		
		//
		//
		protected function onCollision (e:CollisionEvent):void {

			if (e.collider is MotionObject) {
				
				if (TimeStep.realTime - _lastResponse > _responseInterval) {
					
					respond();

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