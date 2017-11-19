package haxe {
	
	public class Std {
		public static function _is(v : *,t : *) : Boolean {
			try {
				if(t == Object) return true;
				return v is t;
			}
			catch( e : * ){
			}
			return false;
		}
		
		public static function string(s : *) : String {
			return StringTools.__string_rec(s,"");
		}
		
		public static function _int(x : Number) : int {
			return int(x);
		}
		
		public static function _parseInt(x : String) : * {
			var v : * = parseInt(x);
			if(isNaN(v)) return null;
			return v;
		}
		
		public static function _parseFloat(x : String) : Number {
			return parseFloat(x);
		}
		
		public static function random(x : int) : int {
			return Math.floor(Math.random() * x);
		}
		
	}
}
