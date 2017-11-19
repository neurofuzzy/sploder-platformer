/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.action.modifier
{
	import flash.events.Event;

	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class ModifierEvent extends Event {
		
		public static const START:String = "start";
		public static const COMPLETE:String = "complete";
		public static const END:String = "end";
		public static const UPDATE:String = "update";

		public var modifier:Modifier;

		//
		//
		public function ModifierEvent (type:String, bubbles:Boolean = false, cancelable:Boolean = false, modifier:Modifier = null) {
			
			super(type, bubbles, cancelable);
			
			this.modifier = modifier
	
		}
		
		//
		//
		override public function clone():Event {
			return new ModifierEvent(type, bubbles, cancelable, modifier);	
		}
		
		//
		//
		override public function toString():String {
			return formatToString("ModifierEvent", "type", "bubbles", "cancelable", "modifier");
		}
	}
	
}