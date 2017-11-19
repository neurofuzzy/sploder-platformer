package com.sploder {
    /**
    * ...
    * @author Default
    * @version 0.1
    */
    
    
    public class Settings {

		import flash.events.Event;
		import flash.events.EventDispatcher;
		import flash.events.NetStatusEvent;
		import flash.net.*;
    
		public static var EVENT_ERROR:String = "so_error";
		
        public static var so:SharedObject;
        private static var _bucket:String = "sploderglobal";
		private static var minDiskSpace:int = 500000;
		private static var flushFailed:Boolean = false;
        
        public static function get bucketName ():String { return _bucket; }
        public static function set bucketName (val:String):void { 
			_bucket = (val.length > 0) ? val : _bucket;
			initialize();
		}
		
		public static var dispatcher:EventDispatcher;

        
        //
        //
        public static function initialize ():void {

            so = SharedObject.getLocal(_bucket);
			so.addEventListener(NetStatusEvent.NET_STATUS, onStatus);
			dispatcher = new EventDispatcher();
        }
        
        //
        //
        public static function loadSetting (name:String):Object {
            
            if (so == null) initialize();
            
            if (name.length > 0) return so.data[name];
            
            return null;
            
        }
        
        //
        //
        public static function saveSetting (name:String, value:Object):void {

            if (so == null) initialize();
            
            if (name.length > 0) so.data[name] = value;
            
			try {
				if (flushFailed) so.flush(minDiskSpace);
				else so.flush();
            } catch (e:Error) {
				trace("SharedObject failed to flush.");
			}
        }
        
        //
        //
        public static function clearSettings ():void {
            
            if (so == null) initialize();
            
            so.clear();
            
        }
		
		//
		//
		public static function onStatus (e:NetStatusEvent):void {
			
			trace("Sharedobject status: " + e.info.code);
			if (e.info.code == "SharedObject.Flush.Failed") {
				flushFailed = true;
				dispatcher.dispatchEvent(new Event(EVENT_ERROR));
			}
			
		}
        
    }
}
