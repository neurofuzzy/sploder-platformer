package com.sploder.util 
{
	
	/**
	 * ...
	 * @author ...
	 */
	public class StringUtils {
		
		public static var monthNames:Array = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
		public static var monthShortNames:Array = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
		public static var dayNames:Array = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
		
		public static const RESTRICT_ALNUM:String = "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz";
		public static const RESTRICT_BASIC:String = "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz.,!?#$-";
		
        // 
        // 
        // PRETTYDATESTRING formats a date into display format and returns it
        public static function prettydatestring(theDate:Date):String {
            
            return dayNames[theDate.getDay()] + ", " + monthNames[theDate.getMonth()] + " " + theDate.getDate() + ", " + theDate.getFullYear();

        }
        
        
        // 
        // 
        // CGIDATESTRING formats a date into CGI encoded format and returns it
        public static function cgidatestring(theDate:Date):String {
            
            var theDay:String = "" + theDate.getDate();
            
            if (theDate.getDate() < 10) {
                theDay = "0" + theDay;
            }
            
            var theMonth:String = "" + theDate.getMonth() + 1;
   
            if ((theDate.getMonth() + 1) < 10) {
                theMonth = "0" + theMonth;
            }
            
            var theYear:String = "" + theDate.getFullYear();
            
            return theMonth + "." + theDay + "." + theYear;
            
        }
		
		public static function timeInMinutes (secs:int):String {
			
			var m:int = Math.floor(secs / 60);
			var s:int = secs % 60;
			
			return m + ":" + (s < 10 ? "0" : "") + s;
			
		}
		
		//
		//
		public static function titleCase (s:String):String {
			
			var words:Array = s.split(" ");
			
			var i:int = words.length;
			
			while (i--) {
				
				var wrd:String = words[i];
				var doCap:Boolean = (i == 0);
				
				if (!doCap) {
					switch (wrd) {
						case "a":
						case "and":
						case "the":
						case "at":
						case "to":
						case "for":
						case "or":
						case "that":
						case "in":
						case "on":
						case "which":
						case "what":
						case "that":
						case "they":
						case "their":
						case "into":
						case "onto":
							break;
						default:
							doCap = true;
					}
				}
				
				if (doCap) words[i] = wrd.charAt(0).toUpperCase() + wrd.substr(1, wrd.length - 1);
				
			}
			
			return words.join(" ");
			
		}
		
	}
	
}