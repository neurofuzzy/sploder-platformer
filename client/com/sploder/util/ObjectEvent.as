package com.sploder.util {
	
	import flash.events.Event;

	/**
	 * The ObjectEvent is dispatched with a reference to the object that triggered the event
	 * ...
	 * @author Geoff
	 */
	public dynamic class ObjectEvent extends Event {
		
		public var relatedObject:Object;

		//
		//
		public function ObjectEvent (type:String, bubbles:Boolean = false, cancelable:Boolean = false, object:Object = null) {
			
			super(type, bubbles, cancelable);
			
			relatedObject = object;
			
		}
		
		//
		//
		override public function clone():Event {
			return new ObjectEvent(type, bubbles, cancelable, relatedObject);	
		}
		
		//
		//
		override public function toString():String {
			return formatToString("ObjectEvent", "type", "bubbles", "cancelable", "relatedObject");
		}	
		
	}
	
}