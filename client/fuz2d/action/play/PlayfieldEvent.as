/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.action.play
{
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class PlayfieldEvent extends Event {
		
		public static const UPDATE:String = "update";
		public static const PAUSE:String = "pause";
		public static const SIGHTING:String = "sighting";
		public static const POWERUP:String = "powerup";
		public static const DEATH:String = "death";
		public static const HARM:String = "harm";
		public static const ESCAPED:String = "escaped";
		public static const REMOVE:String = "remove";

		public var playObject:PlayObject;
		public var amount:Number;
		public var contactPoint:Point;
		
		//
		//
		public function PlayfieldEvent (type:String, bubbles:Boolean = false, cancelable:Boolean = false, playObject:PlayObject = null, amount:Number = 0, contactPoint:Point = null) {
			
			super(type, bubbles, cancelable);
			
			this.playObject = playObject;
			this.amount = amount;
			this.contactPoint = contactPoint;
			
		}
		
		//
		//
		override public function clone():Event {
			return new PlayfieldEvent(type, bubbles, cancelable, playObject, amount, contactPoint);	
		}
		
		//
		//
		override public function toString():String {
			return formatToString("PlayfieldEvent", "type", "bubbles", "cancelable", "playObject", "amount", "contactPoint");
		}
	}
	
}