/**
* com.sploder: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package com.sploder.builder {
	
	import flash.events.Event;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class SelectionEvent extends Event {
		
		public static const SELECT:String = "select";
		public static const DESELECT:String = "deselect";
		public static const STARTDRAG:String = "startdrag";
		public static const DRAG:String = "drag";
		public static const STOPDRAG:String = "stopdrag";
		public static const DROP:String = "drop";
		public static const DELETE:String = "delete";
		public static const CLONE:String = "clone";
		
		public var object:Object;
		public var asValid:Boolean;

		//
		//
		public function SelectionEvent (type:String, bubbles:Boolean = false, cancelable:Boolean = false, object:Object = null, asValid:Boolean = true) {
			
			super(type, bubbles, cancelable);
			
			this.object = object;
			this.asValid = asValid;
			
		}
		
		//
		//
		override public function clone():Event {
			return new SelectionEvent(type, bubbles, cancelable, object, asValid);	
		}
		
		//
		//
		override public function toString():String {
			return formatToString("SelectionEvent", "type", "bubbles", "cancelable", "eventPhase", "object", "asValid");
		}
	}
	
}