/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.physics {

	public class Force implements ForceInterface {
		
		protected var _force:Vector2d;
		
		protected var _isGravity:Boolean;
		public function get isGravity():Boolean { return _isGravity; }
		
		//
		//
		public function Force (x:Number = 0, y:Number = 0, isAngular:Boolean = false, isGravity:Boolean = false) {
			
			_force = new Vector2d(null, x, y, isAngular);
			_isGravity = isGravity;
	
		}
		
		//
		//
		public function applyForce (obj:MotionObject):void {
				
			if (!isGravity) {
				obj.addForce(_force);
			} else {
				obj.addForce(_force, obj.gravity / obj.inverseMass);
			}

		}
		
		
		
	}
	
}
