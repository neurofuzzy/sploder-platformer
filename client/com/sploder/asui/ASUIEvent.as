package com.sploder.asui {
	
	import flash.events.Event;

	/**
	 * The ASUIEvent is dispatched from an ASUIObject with a reference to the sub-component that triggered the event
	 * ...
	 * @author Geoff
	 */
	public dynamic class ASUIEvent extends Event {
		
		public var component:Component;

		//
		//
		public function ASUIEvent (type:String, bubbles:Boolean = false, cancelable:Boolean = false, component:Component = null) {
			
			super(type, bubbles, cancelable);
			
			this.component = component;
			
		}
		
		//
		//
		override public function clone():Event {
			return new ASUIEvent(type, bubbles, cancelable, component);	
		}
		
		//
		//
		override public function toString():String {
			return formatToString("ASUIEvent", "type", "bubbles", "cancelable", component.toString());
		}	
		
	}
	
}