package haxe {
	
	public class enum {
		public var tag : String;
		public var index : int;
		public var params : Array;
		public function toString() : String { return StringTools.enum_to_string(this); }
	}
}
