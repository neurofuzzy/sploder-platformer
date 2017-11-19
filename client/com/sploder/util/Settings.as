package com.sploder.util {
    /**
    * ...
    * @author Default
    * @version 0.1
    */
    
    
    public class Settings {

		import flash.net.*;
    
        public static var so:SharedObject;
        private static var _bucket:String = "sploderglobal";
        
        public static function get bucketName ():String { return _bucket; }
        public static function set bucketName (val:String):void { 
			_bucket = (val.length > 0) ? val : _bucket;
			initialize();
		}

        
        //
        //
        public static function initialize ():void {

            so = SharedObject.getLocal(_bucket);
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
            
            so.flush();
            
        }
        
        //
        //
        public static function clearSettings ():void {

            
            if (so == null) initialize();
            
            so.clear();
            
        }
        
    }
}
