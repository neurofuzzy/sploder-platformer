package haxe
{
	
	import flash.utils.describeType;
	
	public class Serializer
	{
		public function Serializer():void
		{
			this.buf = new StringBuf();
			this.cache = new Array();
			this.useCache = haxe.Serializer.USE_CACHE;
			this.useEnumIndex = haxe.Serializer.USE_ENUM_INDEX;
			this.shash = new Hash();
			this.scount = 0;
		}
		
		public function serializeException(e:*):void
		{
			this.buf.add("x");
			if (e is Error)
			{
				var e1:Error = e;
				var s:String = e1.getStackTrace();
				if (s == null)
					this.serialize(e1.message);
				else
					this.serialize(s);
				return;
			}
			this.serialize(e);
		}
		
		public function serialize(v:*):void
		{
			{
				var $e:enum = (Type._typeof(v));
				switch ($e.index)
				{
					case 0: 
						this.buf.add("n");
						break;
					case 1: 
					{
						if (v == 0)
						{
							this.buf.add("z");
							return;
						}
						this.buf.add("i");
						this.buf.add(v);
					}
						break;
					case 2: 
						if (isNaN(v))
							this.buf.add("k");
						else if (!isFinite(v))
							this.buf.add(((v < 0) ? "m" : "p"));
						else
						{
							this.buf.add("d");
							this.buf.add(v);
						}
						break;
					case 3: 
						this.buf.add(((v) ? "t" : "f"));
						break;
					case 6: 
						var c:Class = $e.params[0];
					{
						if (c == String)
						{
							this.serializeString(v);
							return;
						}
						if (this.useCache && this.serializeRef(v))
							return;
						switch (c)
						{
							case Array: 
							{
								var ucount:int = 0;
								this.buf.add("a");
								var v1:Array = v;
								var l:int = v1.length;
								{
									var _g:int = 0;
									while (_g < l)
									{
										var i:int = _g++;
										if (v1[i] == null)
											ucount++;
										else
										{
											if (ucount > 0)
											{
												if (ucount == 1)
													this.buf.add("n");
												else
												{
													this.buf.add("u");
													this.buf.add(ucount);
												}
												ucount = 0;
											}
											this.serialize(v1[i]);
										}
									}
								}
								if (ucount > 0)
								{
									if (ucount == 1)
										this.buf.add("n");
									else
									{
										this.buf.add("u");
										this.buf.add(ucount);
									}
								}
								this.buf.add("h");
							}
								break;
							case List: 
							{
								this.buf.add("l");
								var v2:List = v;
								{
									var $it2:* = v2.iterator();
									while ($it2.hasNext())
									{
										var i1:* = $it2.next();
										this.serialize(i1);
									}
								}
								this.buf.add("h");
							}
								break;
							case Date: 
							{
								var d:Date = v;
								this.buf.add("v");
								this.buf.add(d["toStringHX"]());
							}
								break;
							case Hash: 
							{
								this.buf.add("b");
								var v3:Hash = v;
								{
									var $it3:* = v3.keys();
									while ($it3.hasNext())
									{
										var k:String = $it3.next();
										{
											this.serializeString(k);
											this.serialize(v3.get(k));
										}
									}
								}
								this.buf.add("h");
							}
								break;
							case IntHash: 
							{
								this.buf.add("q");
								var v4:IntHash = v;
								{
									var $it4:* = v4.keys();
									while ($it4.hasNext())
									{
										var k1:int = $it4.next();
										{
											this.buf.add(":");
											this.buf.add(k1);
											this.serialize(v4.get(k1));
										}
									}
								}
								this.buf.add("h");
							}
								break;
							
							default: 
							{
								this.cache.pop();
								if ((function($this:Serializer):Boolean
									{
										var $r5:Boolean;
										try
										{
											$r5 = v.hxSerialize != null;
										}
										catch (e:*)
										{
											$r5 = false;
										}
										return $r5;
									}(this)))
								{
									this.buf.add("C");
									this.serializeString(Type.getClassName(c));
									this.cache.push(v);
									v.hxSerialize(this);
									this.buf.add("g");
								}
								else
								{
									this.buf.add("c");
									this.serializeString(Type.getClassName(c));
									this.cache.push(v);
									this.serializeClassFields(v, c);
								}
							}
								break;
						}
					}
						break;
					case 4: 
					{
						if (this.useCache && this.serializeRef(v))
							return;
						this.buf.add("o");
						this.serializeFields(v);
					}
						break;
					case 7: 
						var e1:Class = $e.params[0];
					{
						if (this.useCache && this.serializeRef(v))
							return;
						this.cache.pop();
						this.buf.add(((this.useEnumIndex) ? "j" : "w"));
						this.serializeString(Type.getEnumName(e1));
						if (this.useEnumIndex)
						{
							this.buf.add(":");
							this.buf.add(v.index);
						}
						else
							this.serializeString(v.tag);
						this.buf.add(":");
						var pl:Array = v.params;
						if (pl == null)
							this.buf.add(0);
						else
						{
							this.buf.add(pl.length);
							{
								var _g1:int = 0;
								while (_g1 < pl.length)
								{
									var p:* = pl[_g1];
									++_g1;
									this.serialize(p);
								}
							}
						}
						this.cache.push(v);
					}
						break;
					case 5: 
						throw "Cannot serialize function";
						break;
					default: 
						throw "Cannot serialize " + Std.string(v);
						break;
				}
			}
		}
		
		protected function serializeFields(v:*):void
		{
			{
				var _g:int = 0, _g1:Array = Reflect.fields(v);
				while (_g < _g1.length)
				{
					var f:String = _g1[_g];
					++_g;
					this.serializeString(f);
					this.serialize(Reflect.field(v, f));
				}
			}
			this.buf.add("g");
		}
		
		protected function serializeClassFields(v:*, c:Class):void
		{
			var xml:XML = flash.utils.describeType(c);
			var vars:XMLList = xml.factory[0].child("variable");
			{
				var _g1:int = 0, _g:int = vars.length();
				while (_g1 < _g)
				{
					var i:int = _g1++;
					var f:String = vars[i].attribute("name").toString();
					if (!v.hasOwnProperty(f))
						continue;
					this.serializeString(f);
					this.serialize(Reflect.field(v, f));
				}
			}
			this.buf.add("g");
		}
		
		protected function serializeRef(v:*):Boolean
		{
			{
				var _g1:int = 0, _g:int = this.cache.length;
				while (_g1 < _g)
				{
					var i:int = _g1++;
					if (this.cache[i] == v)
					{
						this.buf.add("r");
						this.buf.add(i);
						return true;
					}
				}
			}
			this.cache.push(v);
			return false;
		}
		
		protected function serializeString(s:String):void
		{
			var x:* = this.shash.get(s);
			if (x != null)
			{
				this.buf.add("R");
				this.buf.add(x);
				return;
			}
			this.shash.set(s, this.scount++);
			this.buf.add("y");
			s = StringTools.urlEncode(s);
			this.buf.add(s.length);
			this.buf.add(":");
			this.buf.add(s);
		}
		
		public function toString():String
		{
			return this.buf.toString();
		}
		
		public var useEnumIndex:Boolean;
		public var useCache:Boolean;
		protected var scount:int;
		protected var shash:Hash;
		protected var cache:Array;
		protected var buf:StringBuf;
		public static var USE_CACHE:Boolean = false;
		public static var USE_ENUM_INDEX:Boolean = false;
		
		public static function run(v:*):String
		{
			var s:haxe.Serializer = new haxe.Serializer();
			s.serialize(v);
			return s.toString();
		}
	
	}
}
