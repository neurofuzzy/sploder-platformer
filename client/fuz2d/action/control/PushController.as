/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.action.control {
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import fuz2d.model.object.Biped;
	import fuz2d.util.Geom2d;
	
	import fuz2d.action.play.*;
	import fuz2d.action.physics.*;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class PushController extends PlayObjectController {
		
		protected var _velObject:VelocityObject;
	
		protected var _homeX:Number = 0;
		protected var _homeY:Number = 0;
		
		protected var _lastX:Number = 0;
		protected var _lastY:Number = 0;
		
		protected var _chk:Point;
		
		//
		//
		public function PushController (object:PlayObjectControllable, lockX:Boolean = false, lockY:Boolean = false) {
		
			super(object);
		
			_velObject = VelocityObject(_object.simObject);
			
			_velObject.lockX = lockX;
			_velObject.lockY = lockY;
			
			_homeX = _lastX = _velObject.position.x;
			_homeY = _lastY = _velObject.position.y;
			
			_chk = new Point();
			
			_object.simObject.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);
	
		}
		
		//
		//
		override public function update (e:Event):void {
			
			if (_ended || !_active) return;
			
			super.update(e);
			
			_lastX = _velObject.objectRef.x;
			_lastY = _velObject.objectRef.x;
		
		}
		
		//
		//
		protected function onCollision (e:CollisionEvent):void {
			
			var dx:Number;
			var dy:Number;
			
			if (_velObject == null || _velObject.deleted || _object == null || _object.deleted) return;
			
			if (!_velObject.lockY) {
				
				dy = _velObject.position.y - _lastY;
				
				if (dy > 0) {
					
					if (!_object.playfield.map.canSlide(_object, PlayfieldMap.UP)) {
						_velObject.objectRef.y = _lastY;
						_velObject.getPosition();
					}
					
				} else if (dy < 0) {
					
					if (!_object.playfield.map.canSlide(_object, PlayfieldMap.DOWN)) {
						_velObject.objectRef.y = _lastY;
						_velObject.getPosition();
					}					
					
				}
				
			}
			
			if (!_velObject.lockX) {
				
				_chk.y = _object.object.y - _object.object.width / 2;
				
				dx = _velObject.position.x - _lastX;
				
				if (dx > 0) {
					
					_chk.x = _object.object.x + _object.object.width / 2;
					
					if (!_object.playfield.map.canSlide(_object, PlayfieldMap.RIGHT) || 
						_object.playfield.map.pointInOccupiedCell(_chk, _object)) {
						_velObject.objectRef.x = _lastX;
						_velObject.getPosition();
					}
					
				} else if (dx < 0) {
					
					_chk.x = _object.object.x - _object.object.width / 2;
					
					if (!_object.playfield.map.canSlide(_object, PlayfieldMap.LEFT) || 
						_object.playfield.map.pointInOccupiedCell(_chk, _object)) {
						_velObject.objectRef.x = _lastX;
						_velObject.getPosition();
					}					
					
				}
				
				_object.playfield.map.updatePlayObject(_object);
				
			}

		}
		
	}
	
}