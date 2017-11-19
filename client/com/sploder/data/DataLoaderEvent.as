package com.sploder.data
{
	import flash.events.Event;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class DataLoaderEvent extends Event {
		
		public static const METADATA_LOADED:String = "metadata_loaded";
		public static const DATA_LOADED:String = "data_loaded";
		
		public static const METADATA_ERROR:String = "metadata_error";
		public static const DATA_ERROR:String = "data_error";
		
		
		public var dataObject:Object;
		
		//
		//
		public function DataLoaderEvent (type:String, bubbles:Boolean = false, cancelable:Boolean = false, dataObject:Object = null) {
			
			super(type, bubbles, cancelable);
			
			this.dataObject = dataObject;
			
			
		}
		
		//
		//
		override public function clone():Event {
			return new DataLoaderEvent(type, bubbles, cancelable, dataObject);	
		}
		
		//
		//
		override public function toString():String {
			return formatToString("CollisionEvent", "type", "bubbles", "cancelable", "dataObject");
		}
	}
	
}