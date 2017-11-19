package haxe {
	public class Reflect {
		public static function hasField(o : *,field : String) : Boolean {
			return o.hasOwnProperty(field);
		}
		
		public static function field(o : *,field : String) : * {
			return function() : * {
				var $r : *;
				try {
					$r = o[field];
				}
				catch( e : * ){
					$r = null;
				}
				return $r;
			}();
		}
		
		public static function setField(o : *,field : String,value : *) : void {
			o[field] = value;
		}
		
		public static function getProperty(o : *,field : String) : * {
			try {
				return o["get_" + field]();
			}
			catch( e : * ){
				return o[field];
			}
			catch( e1 : * ){
				return null;
			}
			return null;
		}
		
		public static function setProperty(o : *,field : String,value : *) : void {
			try {
				o["set_" + field](value);
			}
			catch( e : * ){
				o[field] = value;
			}
		}
		
		public static function callMethod(o : *,func : *,args : Array) : * {
			return func.apply(o,args);
		}
		
		public static function fields(o : *) : Array {
			if(o == null) return new Array();
			var a : Array = function() : Array {
				var $r : Array;
				$r = new Array();
				for(var $k2 : String in o) $r.push($k2);
				return $r;
			}();
			var i : int = 0;
			while(i < a.length) if(!o.hasOwnProperty(a[i])) a.splice(i,1);
			else ++i;
			return a;
		}
		
		public static function isFunction(f : *) : Boolean {
			return typeof f == "function";
		}
		
		public static function compare(a : *,b : *) : int {
			var a1 : * = a;
			var b1 : * = b;
			return ((a1 == b1)?0:((a1 > b1)?1:-1));
		}
		
		public static function compareMethods(f1 : *,f2 : *) : Boolean {
			return f1 == f2;
		}
		
		public static function isObject(v : *) : Boolean {
			if(v == null) return false;
			var t : String = typeof v;
			if(t == "object") {
				try {
					if(v.__enum__ == true) return false;
				}
				catch( e : * ){
				}
				return true;
			}
			return t == "string";
		}
		
		public static function deleteField(o : *,f : String) : Boolean {
			if(o.hasOwnProperty(f) != true) return false;
			delete(o[f]);
			return true;
		}
		
		public static function copy(o : *) : * {
			var o2 : * = { }
			{
				var _g : int = 0, _g1 : Array = Reflect.fields(o);
				while(_g < _g1.length) {
					var f : String = _g1[_g];
					++_g;
					Reflect.setField(o2,f,Reflect.field(o,f));
				}
			}
			return o2;
		}
		
		public static function makeVarArgs(f : Function) : * {
			return function(__arguments__ : Array) : * {
				return f(__arguments__);
			}
		}
		
	}
}
