package com.sploder.asui 
{
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class Template {
		
		public static function transform (s:String, o:Object):String {
			
			for (var param:String in o) {
				
				if (o[param] is Array && s.split("<each:" + param + ">").length > 1) {
					
					var snippet:String = s.split("<each:" + param + ">")[1].split("</each:" + param + ">")[0];
					var stringParts:Array = s.split("<each:" + param + ">" + snippet + "</each:" + param + ">");
					
					if (stringParts.length == 2) {
						
						var newSubString:String = "";
						
						var items:Array = o[param];
						
						for (var i:int = 0; i < items.length; i++) {
							
							var temp:String = snippet;
							
							for (var subparam:String in items[i]) {
								
								if (temp.indexOf("${" + subparam + "}") != -1) {
									
									temp = temp.split("${" + subparam + "}").join(items[i][subparam]);

								}
								
							}
							
							newSubString += temp + "\n";
							
						}
						
						s = stringParts[0] + newSubString + stringParts[1];

					}
					
				} else {

					if (s.indexOf("${" + param + "}") != -1) s = s.split("${" + param + "}").join(o[param]);
					
				}
				
			}
			
			return s;
			
		}
		
	}
	
}