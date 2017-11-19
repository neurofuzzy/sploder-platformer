package com.sploder.data {
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public dynamic class User {
		
		public static var u:int;
		public static var c:String;
		public static var m:String;
		public static var name:String;
		public static var a:String = "0";
		
		public static var s:String;
	
		public static function get path ():String {
			
			if (u > 0 && c.length > 0) return "/users/group" + Math.floor(u / 1000) + "/user" + u + "_" + c + "/";
			return "";
			
		}
		
		public static const projectFolderName:String = "projects";
		public static const imageFolderName:String = "photos";
		public static const thumbFolderName:String = "thumbs";
		
		public static function get projectpath ():String {
			
			if (m == "temp") return path + projectFolderName + "/temp/";
			else if (parseInt(m) > 0) return path + projectFolderName + "/proj" + m + "/";
			
			return "";
			
		}
		
		public static function get imagepath ():String { return path + imageFolderName + "/"; }
		public static function get thumbspath ():String { return path + thumbFolderName + "/"; }
		
		public function User() {
			
		}
		
		public static function parseUserData (vars:Object):void {
			
			if (vars.u != undefined) u = parseInt(vars.u);
			if (vars.c != undefined) c = String(vars.c);
			if (vars.m != undefined) m = String(vars.m);
			if (vars.a != undefined) a = String(vars.a);
			
		}
		
	}
	
}