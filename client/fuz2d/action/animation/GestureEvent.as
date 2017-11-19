/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.action.animation {
	
	import flash.events.Event;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class GestureEvent extends Event {
		
		public static const GESTURE_START:String = "gesture_start";
		public static const GESTURE_MID:String = "gesture_mid";
		public static const GESTURE_KEYFRAME:String = "gesture_keyframe";
		public static const GESTURE_HOLD:String = "gesture_hold";
		public static const GESTURE_END:String = "gesture_end";
		
		public var gesture:Gesture;
		public var poseIndex:int
		
		//
		//
		public function GestureEvent (type:String, bubbles:Boolean = false, cancelable:Boolean = false, gesture:Gesture = null, poseIndex:int = 0) {
			
			super(type, bubbles, cancelable);
			
			this.gesture = gesture;
			this.poseIndex = poseIndex;
			
		}
		
		//
		//
		override public function clone():Event {
			return new GestureEvent(type, bubbles, cancelable, gesture, poseIndex);	
		}
		
		//
		//
		override public function toString():String {
			return formatToString("GestureEvent", "type", "bubbles", "cancelable", "eventPhase", "gesture", "poseIndex");
		}
	}
	
}