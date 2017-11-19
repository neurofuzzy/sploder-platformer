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
	import fuz2d.action.behavior.BehaviorManager;
	
	import fuz2d.Fuz2d;
	import fuz2d.action.physics.*;
	import fuz2d.action.play.PlayObject;

	public class CollisionBehavior extends Behavior {
				
		//
		//
		public function CollisionBehavior () {
			
			super();
			
		}
		
		//
		//
		override protected function init(parentClass:BehaviorManager):void {
			
			super.init(parentClass);
			
			if (_parentClass.playObject != null && _parentClass.playObject.simObject != null) {
				_parentClass.playObject.simObject.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);
			}
			
		}
		
		//
		//
		public function onCollision (e:CollisionEvent):void {
			
			//trace(e.contactPoint.x, e.contactPoint.y);
			
		}
		
		override public function end():void {
			
			if (_parentClass.playObject != null && _parentClass.playObject.simObject != null) _parentClass.playObject.simObject.removeEventListener(CollisionEvent.COLLISION, onCollision);
			super.end();
			
		}
		
	}
	
}