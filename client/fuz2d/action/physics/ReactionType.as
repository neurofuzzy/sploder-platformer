package fuz2d.action.physics {
	
	public class ReactionType {
		
		public static const BOUNCE:uint = 1;
		public static const BOUNCE_ALL_BUT_FOCUSOBJ:uint = 2;
		public static const ABOVE_ONLY:uint = 3;
		public static const DEFY_GRAVITY:uint = 4;
		public static const SLOW:uint = 5;
		public static const FLOAT:uint = 6;
		public static const CLIMB:uint = 7;
		public static const REPORT_ONLY:uint = 8;
		public static const PASSTHROUGH:uint = 9;
		public static const IGNORE:uint = 10;
		
		public static function getType (collider:CollisionObject, collidee:CollisionObject):uint {
			
			return Math.max(collider.reactionType, collidee.reactionType);
			
		}
		
		public static function parseType (type:String):uint {
			
			switch (type) {
				
				case "BOUNCE": return 1;
				case "BOUNCE_ALL_BUT_FOCUSOBJ": return 2;
				case "ABOVE_ONLY": return 3;
				case "DEFY_GRAVITY": return 4;
				case "SLOW": return 5;
				case "FLOAT": return 6;
				case "CLIMB": return 7;
				case "REPORT_ONLY": return 8;
				case "PASSTHROUGH": return 9;
				case "IGNORE": return 10;
				
				default: return 1;
				
			}
			
		}
		
	}
	
}