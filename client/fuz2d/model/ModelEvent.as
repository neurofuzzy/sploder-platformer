/**
* com.sploder: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.model {
	
	import fuz2d.model.object.Object2d;
	
	import flash.events.Event;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class ModelEvent extends Event {
		
		public static const CREATE:String = "create";
		public static const UPDATE:String = "update";
		public static const DELETE:String = "delete";
		public static const FOCUS:String = "focus";
		public static const ZCHANGE:String = "zchange";
		
		public var object:Object2d;

		//
		//
		public function ModelEvent (type:String, bubbles:Boolean = false, cancelable:Boolean = false, object:Object2d = null) {
			
			super(type, bubbles, cancelable);
			
			this.object = object;
			
		}
		
		//
		//
		override public function clone():Event {
			return new ModelEvent(type, bubbles, cancelable, object);	
		}
		
		//
		//
		override public function toString():String {
			return formatToString("ModelEvent", "type", "bubbles", "cancelable", "eventPhase", "object");
		}
	}
	
}