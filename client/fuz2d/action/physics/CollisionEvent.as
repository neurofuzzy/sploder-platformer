/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.action.physics 
{
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class CollisionEvent extends Event {
		
		public static const COLLISION:String = "collision";
		public static const PENETRATION:String = "penetration";
		public static const POINT_HIT:String = "point_hit";
		public static const SEGMENT_HIT:String = "segment_hit";
		
		public var collider:SimulationObject;
		public var collidee:SimulationObject;
		public var contactPoint:Point;
		public var contactSpeed:Number;
		public var contactNormal:Vector2d;
		public var reactionType:uint;
		
		//
		//
		public function CollisionEvent (type:String, bubbles:Boolean = false, cancelable:Boolean = false, collider:SimulationObject = null, collidee:SimulationObject = null, contactPoint:Point = null, contactSpeed:Number = NaN, contactNormal:Vector2d = null, reactionType:uint = 1) {
			
			super(type, bubbles, cancelable);
			
			this.collider = collider;
			this.collidee = collidee;
			this.contactPoint = contactPoint;
			this.contactSpeed = contactSpeed;
			this.contactNormal = contactNormal;
			this.reactionType = reactionType;
			
		}
		
		//
		//
		
		override public function clone():Event {
			return new CollisionEvent(type, bubbles, cancelable, collider, collidee, contactPoint, contactSpeed, contactNormal, reactionType);	
		}
		
		//
		//
		override public function toString():String {
			return formatToString("CollisionEvent", "type", "bubbles", "cancelable", "eventPhase", "collider", "collidee", "contactPoint", "contactSpeed", "contactNormal", "reactionType");
		}
	}
	
}