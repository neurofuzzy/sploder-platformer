/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.action.control {
	
	import flash.events.Event;
	
	import fuz2d.action.play.*;
	import fuz2d.action.physics.*;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class PlatformController extends PlayObjectController {
		
		protected var _velObject:VelocityObject;
		
		protected var _dirX:int = 0;
		protected var _dirY:int = 0;
		
		protected var _dirs:Array;
		protected var dir:int = -1;
		
		protected var _stickMax:int = 40;
		protected var _stickTimes:int = 0;
		
		protected var _is2way:Boolean = false;
		protected var _velMag:Number = 0;
		
		//
		//
		public function PlatformController (object:PlayObjectControllable, velocity:Vector2d, lockX:Boolean = false, lockY:Boolean = false) {
		
			super(object);
			
			_dirs = [PlayfieldMap.UP, PlayfieldMap.RIGHT, PlayfieldMap.DOWN, PlayfieldMap.LEFT];
		
			_velObject = VelocityObject(_object.simObject);
			
			_velObject.velocity = velocity;
			_velObject.lockX = lockX;
			_velObject.lockY = lockY;
			_velObject.forceStatic = true;
			
			if (lockX && lockY) {
				
				_is2way = true;
				_velMag = Math.max(Math.abs(velocity.x), Math.abs(velocity.y));
				chooseDir();

			} else {
			
				_dirX = (velocity.x == 0) ? 0 : (velocity.x > 0) ? 1 : -1;
				_dirY = (velocity.y == 0) ? 0 : (velocity.y > 0) ? 1 : -1;
				
				if (_dirX != 0) {
					
					if (_dirX > 0) dir = PlayfieldMap.RIGHT;
					else dir = PlayfieldMap.LEFT;
					
					_velMag = Math.abs(velocity.x);
					
				} else {
					
					if (_dirY > 0) dir = PlayfieldMap.UP;
					else dir = PlayfieldMap.DOWN;
					
					_velMag = Math.abs(velocity.y);
					
				}
			
			}
			
			_velObject.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);
			
		}
		
		//
		//
		override public function update (e:Event):void {
			
			if (_ended || !_active) return;
			
			super.update(e);

			if (!_object.playfield.map.canMove(_object, dir) || _stickTimes > _stickMax) {
				
				if (!_is2way) {
					
					if (dir == PlayfieldMap.UP) dir = PlayfieldMap.DOWN;
					else if (dir == PlayfieldMap.DOWN) dir = PlayfieldMap.UP;
					
					if (dir == PlayfieldMap.RIGHT) dir = PlayfieldMap.LEFT;
					else if (dir == PlayfieldMap.LEFT) dir = PlayfieldMap.RIGHT;
					
					_velObject.velocity.x = 0 - _velObject.velocity.x;
					_velObject.velocity.y = 0 - _velObject.velocity.y;
					
					_object.simObject.position.x = Math.round(_object.simObject.position.x / 30) * 30;
					_object.simObject.position.y = Math.round(_object.simObject.position.y / 30) * 30;
					_object.simObject.updateObjectRef();
					
				} else {
					
					chooseDir();
	
				}
				
				_stickTimes = 0;
					
			}
			
			if (_velObject.sticking) {
				_stickTimes++;
				_velObject.sticking = false;
			}
			
			_object.playfield.map.updatePlayObject(_object);
			
		}
		
		//
		//
		protected function chooseDir ():void {
			
			var nd:int = dir;
			
			while (nd == dir) {
				
				nd = _dirs[Math.floor(Math.random() * _dirs.length)];
				
			}
			
			dir = nd;
			
			switch (dir) {
				
				case PlayfieldMap.LEFT:
					_dirX = -1;
					_dirY = 0;
					_velObject.lockX = false;
					_velObject.lockY = true;
					_velObject.velocity.x = 0 - _velMag;
					_velObject.velocity.y = 0;
					break;
					
				case PlayfieldMap.RIGHT:
					_dirX = 1;
					_dirY = 0;
					_velObject.lockX = false;
					_velObject.lockY = true;
					_velObject.velocity.x = _velMag;
					_velObject.velocity.y = 0;				
					break;
					
				case PlayfieldMap.UP:
					_dirX = 0;
					_dirY = 1;
					_velObject.lockX = true;
					_velObject.lockY = false;
					_velObject.velocity.x = 0;
					_velObject.velocity.y = _velMag;
					break;
					
				case PlayfieldMap.DOWN:
					_dirX = 0;
					_dirY = -1;
					_velObject.lockX = true;
					_velObject.lockY = false;
					_velObject.velocity.x = 0;
					_velObject.velocity.y = 0 - _velMag;
					break;
				
			}
			
			_object.simObject.position.x = Math.round(_object.simObject.position.x / 30) * 30;
			_object.simObject.position.y = Math.round(_object.simObject.position.y / 30) * 30;
			_object.simObject.updateObjectRef();
			
		}
		
		//
		//
		protected function onCollision (e:CollisionEvent):void {
			
			// slow player sliding on landing
			
			if (e.contactNormal.x == 0 && e.contactNormal.y < 0 && e.contactSpeed > 400) {
				
				if (e.collider is MotionObject) {
					
					MotionObject(e.collider).velocity.x *= 0.25;
					
				}
				
			}
			
		}
		
	}
	
}