package fuz2d.action.physics {

	import fuz2d.action.physics.*;
	import fuz2d.model.object.Object2d;
	
	public class VelocityObject extends SimulationObject {
		
		public var velocity:Vector2d;
		
		public var lockX:Boolean = false;
		public var lockY:Boolean = false;
		
		public var sticking:Boolean = false;
		public var bound:Boolean = false;
		
		protected var _maxPenetration:int = 0;
		public function get maxPenetration():int { return _maxPenetration; }

		override public function get inMotion ():Boolean { return !(velocity.negligible); }
		
		public var preIntegratePosition:Vector2d;
		
		public function VelocityObject (simulation:Simulation, obj:Object2d, collisionObjectType:uint, reactionType:uint = 1, ignoreSameType:Boolean = false, collideOnlyStatic:Boolean = false, maxPenetration:int = 0, bound:Boolean = false) {
			
			super(simulation, obj, collisionObjectType, reactionType, collideOnlyStatic);
		
			this.ignoreSameType = ignoreSameType;
			_maxPenetration = maxPenetration;
			this.bound = bound;
			
			preIntegratePosition = new Vector2d();
			
			velocity = new Vector2d();
			
		}
		
		//
		//
		public function integrate (duration:Number = 0):void {
			
			preIntegratePosition.alignToPoint(_objectRef.point);
			
			if (duration == 0) {
				duration = _simulation.currentDuration;
			}
			
			if (velocity.squareMagnitude > 0) {
				position.addScaled(velocity, duration);
				updateObjectRef();
			}
			
		}
			
		//
		//
		override public function applyImpulse (impulse:Vector2d):void {
			
			if (!impulse.angular) {
				
				var i:Vector2d = impulse.copy;
				
				if (lockX) i.x = 0;
				if (lockY) i.y = 0;
				
				velocity.addBy(i);
				
			}
			
		}
		
	}
	
}