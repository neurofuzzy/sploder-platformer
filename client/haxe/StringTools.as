package haxe {
	import flash.utils.getQualifiedClassName;
	public class StringTools {
		public static function urlEncode(s : String) : String {
			return encodeURIComponent(s);
		}
		
		public static function urlDecode(s : String) : String {
			return decodeURIComponent(s.split("+").join(" "));
		}
		
		public static function htmlEscape(s : String) : String {
			return s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
		}
		
		public static function htmlUnescape(s : String) : String {
			return s.split("&gt;").join(">").split("&lt;").join("<").split("&amp;").join("&");
		}
		
		public static function startsWith(s : String,start : String) : Boolean {
			return s.length >= start.length && s.substr(0,start.length) == start;
		}
		
		public static function endsWith(s : String,end : String) : Boolean {
			var elen : int = end.length;
			var slen : int = s.length;
			return slen >= elen && s.substr(slen - elen,elen) == end;
		}
		
		public static function isSpace(s : String,pos : int) : Boolean {
			var c : * = s["charCodeAtHX"](pos);
			return c >= 9 && c <= 13 || c == 32;
		}
		
		public static function ltrim(s : String) : String {
			var l : int = s.length;
			var r : int = 0;
			while(r < l && StringTools.isSpace(s,r)) r++;
			if(r > 0) return s.substr(r,l - r);
			else return s;
			return null;
		}
		
		public static function rtrim(s : String) : String {
			var l : int = s.length;
			var r : int = 0;
			while(r < l && StringTools.isSpace(s,l - r - 1)) r++;
			if(r > 0) return s.substr(0,l - r);
			else return s;
			return null;
		}
		
		public static function trim(s : String) : String {
			return StringTools.ltrim(StringTools.rtrim(s));
		}
		
		public static function rpad(s : String,c : String,l : int) : String {
			var sl : int = s.length;
			var cl : int = c.length;
			while(sl < l) if(l - sl < cl) {
				s += c.substr(0,l - sl);
				sl = l;
			}
			else {
				s += c;
				sl += cl;
			}
			return s;
		}
		
		public static function lpad(s : String,c : String,l : int) : String {
			var ns : String = "";
			var sl : int = s.length;
			if(sl >= l) return s;
			var cl : int = c.length;
			while(sl < l) if(l - sl < cl) {
				ns += c.substr(0,l - sl);
				sl = l;
			}
			else {
				ns += c;
				sl += cl;
			}
			return ns + s;
		}
		
		public static function replace(s : String,sub : String,by : String) : String {
			return s.split(sub).join(by);
		}
		
		public static function hex(n : int,digits : * = null) : String {
			var n1 : uint = n;
			var s : String = n1.toString(16);
			s = s.toUpperCase();
			if(digits != null) while(s.length < digits) s = "0" + s;
			return s;
		}
		
		public static function fastCodeAt(s : String,index : int) : int {
			return s.charCodeAt(index);
		}
		
		public static function isEOF(c : int) : Boolean {
			return c == 0;
		}
		
		public static function enum_to_string(e : *) : String {
			if(e.params == null) return e.tag;
			var pstr : Array = [];
			{
				var _g : int = 0, _g1 : Array = e.params;
				while(_g < _g1.length) {
					var p : * = _g1[_g];
					++_g;
					pstr.push(__string_rec(p,""));
				}
			}
			return e.tag + "(" + pstr.join(",") + ")";
		}
		
		public static function __string_rec(v : *,str : String) : String {
			var cname : String = flash.utils.getQualifiedClassName(v);
			switch(cname) {
			case "Object":
			{
				var k : Array = function() : Array {
					var $r : Array;
					$r = new Array();
					for(var $k2 : String in v) $r.push($k2);
					return $r;
				}();
				var s : String = "{";
				var first : Boolean = true;
				{
					var _g1 : int = 0, _g : int = k.length;
					while(_g1 < _g) {
						var i : int = _g1++;
						var key : String = k[i];
						if(key == "toString") try {
							return v.toString();
						}
						catch( e : * ){
						}
						if(first) first = false;
						else s += ",";
						s += " " + key + " : " + __string_rec(v[key],str);
					}
				}
				if(!first) s += " ";
				s += "}";
				return s;
			}
			break;
			case "Array":
			{
				if(v == Array) return "#Array";
				var s1 : String = "[";
				var i1 : *;
				var first1 : Boolean = true;
				var a : Array = v;
				{
					var _g11 : int = 0, _g2 : int = a.length;
					while(_g11 < _g2) {
						var i2 : int = _g11++;
						if(first1) first1 = false;
						else s1 += ",";
						s1 += __string_rec(a[i2],str);
					}
				}
				return s1 + "]";
			}
			break;
			default:
			switch(typeof v) {
			case "function":
			return "<function>";
			break;
			}
			break;
			}
			return new String(v);
		}
		
	}
}
