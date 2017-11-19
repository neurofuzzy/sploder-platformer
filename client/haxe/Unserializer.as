package haxe {
	
	public class Unserializer {
		public function Unserializer(buf : String = null) : void {
			this.buf = buf;
			this.length = buf.length;
			this.pos = 0;
			this.scache = new Array();
			this.cache = new Array();
			var r : * = haxe.Unserializer.DEFAULT_RESOLVER;
			if(r == null) {
				r = Type;
				haxe.Unserializer.DEFAULT_RESOLVER = r;
			}
			this.setResolver(r);
		}
		
		public function unserialize() : * {
			switch(this.get(this.pos++)) {
			case 110:
			return null;
			break;
			case 116:
			return true;
			break;
			case 102:
			return false;
			break;
			case 122:
			return 0;
			break;
			case 105:
			return this.readDigits();
			break;
			case 100:
			{
				var p1 : int = this.pos;
				while(true) {
					var c : int = this.get(this.pos);
					if(c >= 43 && c < 58 || c == 101 || c == 69) this.pos++;
					else break;
				}
				return Std._parseFloat(this.buf.substr(p1,this.pos - p1));
			}
			break;
			case 121:
			{
				var len : int = this.readDigits();
				if(this.get(this.pos++) != 58 || this.length - this.pos < len) throw "Invalid string length";
				var s : String = this.buf.substr(this.pos,len);
				this.pos += len;
				s = StringTools.urlDecode(s);
				this.scache.push(s);
				return s;
			}
			break;
			case 107:
			return NaN;
			break;
			case 109:
			return Number.NEGATIVE_INFINITY;
			break;
			case 112:
			return Number.POSITIVE_INFINITY;
			break;
			case 97:
			{
				var buf : String = this.buf;
				var a : Array = new Array();
				this.cache.push(a);
				while(true) {
					var c1 : int = this.get(this.pos);
					if(c1 == 104) {
						this.pos++;
						break;
					}
					if(c1 == 117) {
						this.pos++;
						var n : int = this.readDigits();
						a[a.length + n - 1] = null;
					}
					else a.push(this.unserialize());
				}
				return a;
			}
			break;
			case 111:
			{
				var o : * = { }
				this.cache.push(o);
				this.unserializeObject(o);
				return o;
			}
			break;
			case 114:
			{
				var n1 : int = this.readDigits();
				if(n1 < 0 || n1 >= this.cache.length) throw "Invalid reference";
				return this.cache[n1];
			}
			break;
			case 82:
			{
				var n2 : int = this.readDigits();
				if(n2 < 0 || n2 >= this.scache.length) throw "Invalid string reference";
				return this.scache[n2];
			}
			break;
			case 120:
			throw this.unserialize();
			break;
			case 99:
			{
				var name : String = this.unserialize();
				var cl : Class = this.resolver.resolveClass(name);
				if(cl == null) throw "Class not found " + name;
				var o1 : * = Type.createEmptyInstance(cl);
				this.cache.push(o1);
				this.unserializeObject(o1);
				return o1;
			}
			break;
			case 119:
			{
				var name1 : String = this.unserialize();
				var edecl : Class = this.resolver.resolveEnum(name1);
				if(edecl == null) throw "Enum not found " + name1;
				var e : * = this.unserializeEnum(edecl,this.unserialize());
				this.cache.push(e);
				return e;
			}
			break;
			case 106:
			{
				var name2 : String = this.unserialize();
				var edecl1 : Class = this.resolver.resolveEnum(name2);
				if(edecl1 == null) throw "Enum not found " + name2;
				this.pos++;
				var index : int = this.readDigits();
				var tag : String = Type.getEnumConstructs(edecl1)[index];
				if(tag == null) throw "Unknown enum index " + name2 + "@" + index;
				var e1 : * = this.unserializeEnum(edecl1,tag);
				this.cache.push(e1);
				return e1;
			}
			break;
			case 108:
			{
				var l : List = new List();
				this.cache.push(l);
				var buf1 : String = this.buf;
				while(this.get(this.pos) != 104) l.add(this.unserialize());
				this.pos++;
				return l;
			}
			break;
			case 98:
			{
				var h : Hash = new Hash();
				this.cache.push(h);
				var buf2 : String = this.buf;
				while(this.get(this.pos) != 104) {
					var s1 : String = this.unserialize();
					h.set(s1,this.unserialize());
				}
				this.pos++;
				return h;
			}
			break;
			case 113:
			{
				var h1 : IntHash = new IntHash();
				this.cache.push(h1);
				var buf3 : String = this.buf;
				var c2 : int = this.get(this.pos++);
				while(c2 == 58) {
					var i : int = this.readDigits();
					h1.set(i,this.unserialize());
					c2 = this.get(this.pos++);
				}
				if(c2 != 104) throw "Invalid IntHash format";
				return h1;
			}
			break;
			case 118:
			{
				var d : Date = Date["fromString"](this.buf.substr(this.pos,19));
				this.cache.push(d);
				this.pos += 19;
				return d;
			}
			break;
			
			case 67:
			{
				var name3 : String = this.unserialize();
				var cl1 : Class = this.resolver.resolveClass(name3);
				if(cl1 == null) throw "Class not found " + name3;
				var o2 : * = Type.createEmptyInstance(cl1);
				this.cache.push(o2);
				o2.hxUnserialize(this);
				if(this.get(this.pos++) != 103) throw "Invalid custom data";
				return o2;
			}
			break;
			default:
			break;
			}
			this.pos--;
			throw "Invalid char " + this.buf.charAt(this.pos) + " at position " + this.pos;
			return null;
		}
		
		protected function unserializeEnum(edecl : Class,tag : String) : * {
			if(this.get(this.pos++) != 58) throw "Invalid enum format";
			var nargs : int = this.readDigits();
			if(nargs == 0) return Type.createEnum(edecl,tag);
			var args : Array = new Array();
			while(nargs-- > 0) args.push(this.unserialize());
			return Type.createEnum(edecl,tag,args);
		}
		
		protected function unserializeObject(o : *) : void {
			while(true) {
				if(this.pos >= this.length) throw "Invalid object";
				if(this.get(this.pos) == 103) break;
				var k : String = this.unserialize();
				if(!Std._is(k,String)) throw "Invalid object key";
				var v : * = this.unserialize();
				Reflect.setField(o,k,v);
			}
			this.pos++;
		}
		
		protected function readDigits() : int {
			var k : int = 0;
			var s : Boolean = false;
			var fpos : int = this.pos;
			while(true) {
				var c : int = this.get(this.pos);
				if(StringTools.isEOF(c)) break;
				if(c == 45) {
					if(this.pos != fpos) break;
					s = true;
					this.pos++;
					continue;
				}
				if(c < 48 || c > 57) break;
				k = k * 10 + (c - 48);
				this.pos++;
			}
			if(s) k *= -1;
			return k;
		}
		
		protected function get(p : int) : int {
			return StringTools.fastCodeAt(this.buf,p);
		}
		
		public function getResolver() : * {
			return this.resolver;
		}
		
		public function setResolver(r : *) : void {
			if(r == null) this.resolver = { resolveClass : function(_ : String) : Class {
				return null;
			}, resolveEnum : function(_1 : String) : Class {
				return null;
			}}
			else this.resolver = r;
		}
		
		protected var resolver : *;
		protected var scache : Array;
		protected var cache : Array;
		protected var length : int;
		protected var pos : int;
		protected var buf : String;
		public static var DEFAULT_RESOLVER : * = Type;
		
		public static function run(v : String) : * {
			return new haxe.Unserializer(v).unserialize();
		}
		
	}
}
