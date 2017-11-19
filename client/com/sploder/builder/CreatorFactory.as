package com.sploder.builder {
	
	import com.adobe.serialization.json.JSON;
	import com.sploder.builder.Creator;
	import com.sploder.geom.Geom2d;
	import com.sploder.texturegen_internal.TextureAttributes;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.geom.Matrix;
	
	import fuz2d.library.EmbeddedLibrary;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.xml.*;


	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class CreatorFactory {
		
		private static var _main:Creator;
		private static var _manifest:XML;
		private static var _library:EmbeddedLibrary;
		
		public static var cache:Object;

		private static var _initialized:Boolean = false;
		
		public static function get main ():Creator { return _main; }

		public static function get initialized ():Boolean {
			
			if (!_initialized) throw new Error("ObjectFactory not initialized.  Please supply a definitions XML to the initialize method.");
			
			return _initialized;
			
		}
		
		//
		//
		public static function initialize (main:Creator, manifest:String, library:EmbeddedLibrary):Boolean {
			
			_main = main;
			_manifest = new XML(manifest);
			_library = library;

			cache = { };
			
			_initialized = true;
			
			return true;
			
		}
		
		//
		//
		public static function getMatch (id:Object):XMLList {
			var match:XMLList;
			if (cache[id]) { 
				match = cache[id]; 
			} else {
				match = cache[id] = _manifest..playobj.(@cid == id);
			}
			return match;
		}
		
		//
		//
		public static function createNew (objID:String, creator:Object = null, x:Number = 0, y:Number = 0, z:Number = 0, options:Object = null, checkForGraphicSymbol:Boolean = false):DisplayObject {
			
			var c:Sprite;
			
			if (!initialized) return null;
			
			var name:String;
			
			var match:XMLList = getMatch(objID);
			
			if (match == null) return null;
			
			var matchobj:XMLList = match..obj;
			
			name = (matchobj.@creatorsymbolname != undefined) ? matchobj.@creatorsymbolname : 
				(matchobj.@symbolname != undefined) ? matchobj.@symbolname : match.@id;
			
			if (matchobj.@type == "biped") {
				
				var biped:Sprite;
				if (checkForGraphicSymbol) biped = _library.getDisplayObject(name + "_graphic") as Sprite;
				if (biped == null) biped = _library.getDisplayObject(name) as Sprite;
				
				var i:int;
				
				if (biped["bounds"] != null) Sprite(biped["bounds"]).visible = false;
				if (biped["healthmeter"] != null) Sprite(biped["healthmeter"]).visible = false;
				
				if (biped["body"] != null) {
					
					if (biped["body"]["torso"] != null) {
						
						for (i = 0; i < Sprite(biped["body"]["torso"]).numChildren; i++) {
							if (Sprite(biped["body"]["torso"]).getChildAt(i) is Sprite && Sprite(biped["body"]["torso"]).getChildAt(i).name != "g2c") {
								Sprite(biped["body"]["torso"]).getChildAt(i).visible = false;
							}
						}
						
					}
					
					if (biped["body"]["arm_rt"] != null) {
						
						Sprite(biped["body"]["arm_rt"]).rotation = 120;
						
						if (biped["body"]["arm_rt"]["hand_rt"] != null) {
							
							for (i = 0; i < Sprite(biped["body"]["arm_rt"]["hand_rt"]).numChildren; i++) {
								if (Sprite(biped["body"]["arm_rt"]["hand_rt"]).getChildAt(i) is Sprite && 
									Sprite(biped["body"]["arm_rt"]["hand_rt"]).getChildAt(i).name != "hand" && 
									Sprite(biped["body"]["arm_rt"]["hand_rt"]).getChildAt(i).name != "g2c") {
									Sprite(biped["body"]["arm_rt"]["hand_rt"]).getChildAt(i).visible = false;
								}
							}							
							
						}
						
					}
					
					if (biped["body"]["arm_lt"] != null) {
						
						Sprite(biped["body"]["arm_lt"]).rotation = 60;
						
						if (biped["body"]["arm_lt"]["hand_lt"] != null) {
							
							for (i = 0; i < Sprite(biped["body"]["arm_lt"]["hand_lt"]).numChildren; i++) {
								if (Sprite(biped["body"]["arm_lt"]["hand_lt"]).getChildAt(i) is Sprite &&
									Sprite(biped["body"]["arm_lt"]["hand_lt"]).getChildAt(i).name != "g2c") {
									Sprite(biped["body"]["arm_lt"]["hand_lt"]).getChildAt(i).visible = false;
								}
							}							
							
						}
						
					}
					
					if (biped["body"]["leg_rt"] != null) {
						Sprite(biped["body"]["leg_rt"]).scaleY = 0 - Sprite(biped["body"]["leg_rt"]).scaleY;
					}
					
				}
				
				return biped;
				
				/*
				var bd:BitmapData = new BitmapData(Math.floor(biped.width), Math.floor(biped.height), true, 0x00000000);
				
				var m:Matrix = new Matrix();	
				m.createBox(1, 1, 0, Math.floor(biped.width * 0.5), Math.floor(biped.height * 0.5));
				
				bd.draw(biped, m);
				
				var b:Bitmap = new Bitmap(bd, PixelSnapping.ALWAYS, false);
				
				c = new Sprite();
				b.x = 0 - b.width / 2;
				b.y = 0 - b.height / 2;
				c.addChild(b);
				*/

				return c;
				
			} else if (matchobj.@type == "tile") {
				
				var tileID:int = parseInt(matchobj.@tile);
				
				var back:Boolean = String(matchobj.@back) == "1";
				
				if (options != null && options.tile && !isNaN(parseInt(options.tile)) && options.tile > 0) {
					tileID = parseInt(options.tile);
					if (options.back != undefined) back = (options.back == true);
				}
				
				
				
				var defID:String;
				
				var tilescale:int = (matchobj.@tilescale != undefined) ? parseInt(matchobj.@tilescale) : 1;
				
				if (matchobj.children()[0] != undefined && matchobj.children()[0].toString().length > 0) {
					defID = _library.createTileSet(tileID, back, JSON.decode(matchobj.children()[0].toString()), -1, tilescale)
					match.obj.@defID = defID;
				} else if (matchobj.@tile != undefined) {
					defID = _library.createTileSet(tileID, back, null, -1, tilescale);
					match.obj.@defID = defID;
				}
				//trace(objID, "FACTORY TILE ID", tileID, "TILESCALE", tilescale, "DEFID", defID);
				var bitmap:Bitmap = _library.getTileAsBitmap(defID, null, matchobj.@stamp, 0, back, tilescale);
				bitmap.x = (0 - bitmap.width * 0.5);
				bitmap.y = (0 - bitmap.height * 0.5);
				bitmap.smoothing = false;
				
				bitmap.rotation = (matchobj.@r != undefined) ? parseInt(matchobj.@r) : 0;
				
				bitmap.x = 0 - Math.sin(Geom2d.dtr * bitmap.rotation) * (0 - bitmap.width / 2) + Math.cos(Geom2d.dtr * bitmap.rotation) * (0 - bitmap.width / 2);
				bitmap.y = Math.cos(Geom2d.dtr * bitmap.rotation) * (0 - bitmap.height / 2) + Math.sin(Geom2d.dtr * bitmap.rotation) * (0 - bitmap.height / 2);
				
				return bitmap;
				
			} else if (matchobj.@type == "textureblock") {
				
				return new Bitmap();
				
			} else if (matchobj.@type == "symbol" || 
						matchobj.@type == "turretsymbol" ||
						matchobj.@type == "segsymbol" || 
						matchobj.@type == "mech") {
				
				var dobj:DisplayObject;
				
				if (getCache(objID)) {
					
					dobj = new Sprite();
					var bb:Bitmap = _library.getDisplayObjectAsBitmap(name, null, true);
					bb.x = (0 - bb.width * 0.5);
					bb.y = (0 - bb.height * 0.5);				
					Sprite(dobj).addChild(bb);
					
				} else {
					
					if (checkForGraphicSymbol) {
						dobj = _library.getDisplayObject(name + "_graphic");
					}
					if (dobj == null) dobj = _library.getDisplayObject(name);
					
					if (dobj is Sprite && Sprite(dobj["bounds"]) != null) Sprite(dobj["bounds"]).visible = false;

					if (dobj is MovieClip) {
						if (match.@cframe != undefined && !isNaN(parseInt(match.@cframe))) {
							MovieClip(dobj).gotoAndStop(parseInt(match.@cframe));
						} else {
							MovieClip(dobj).gotoAndStop(1);
						}
					}
					
				}
				
				dobj.rotation = (matchobj.@r != undefined) ? parseInt(matchobj.@r) : 0;
				
				return dobj;
				
			}
			
			return null;

		}
		
		//
		//
		public static function getNodeByNameAndID (elementName:String, nodeID:String):XML {
			
			if (!initialized) return null;

			return new XML(_manifest[elementName].(@id == nodeID).toString());
			
		}
		
		//
		//
		public static function getCreatorTypes ():Array {
			
			var c:XMLList = _manifest..playobj.(@ctype != "none");
			var types:Array = [];
			
			for each (var p:XML in c) if (types.indexOf(String(p.@ctype)) == -1) types.push(String(p.@ctype));

			return types;
			
		}
		
		//
		//
		public static function get objects ():XMLList {
			
			return _manifest..playobj.(@ctype != "none");
			
		}
		
		static public function get library():EmbeddedLibrary { return _library; }
		
		//
		//
		public static function getSymbolName (id:String):String {
			
			var match:XMLList = getMatch(id);
			
			if (match == null) return "";
			
			var matchobj:XMLList = match..obj;
			
			var name:String = (matchobj.@symbolname != undefined) ? matchobj.@symbolname : match.@id;
			
			return name;
			
		}
		
		//
		//
		public static function getCreatorSymbolName (id:String):String {
			
			var match:XMLList = getMatch(id);
			
			if (match == null) return "";
			
			var matchobj:XMLList = match..obj;
			
			var name:String = (matchobj.@cname != undefined) ? matchobj.@cname : "object";
			
			return name;
			
		}
		
		//
		//
		public static function getCache (id:String):Boolean {
			
			var match:XMLList = getMatch(id);
			
			if (match == null) return false;
			
			return (match.@ccache != undefined);
			
		}
		
		
		//
		//
		public static function getZIndex (id:String):int {
			
			var match:XMLList = getMatch(id);
			
			if (match == null) return 0;
			
			var matchobj:XMLList = match..obj;
			
			return (matchobj.@z != undefined) ? parseInt(matchobj.@z) : 0;

		}
		
		//
		//
		public static function getObjType (id:String):String {
			
			if (!initialized) return "";
			
			var match:XMLList = getMatch(id);
			
			if (match == null) return "";
			
			return match..obj.@type;
			
		}
		
		//
		//
		public static function getSnap (id:String):Boolean {
			
			if (!initialized) return true;
			
			var match:XMLList = getMatch(id);
			
			if (match == null) return true;
			
			return (match..obj.@type != "biped");
			
		}

		//
		//
		public static function getUnique (id:uint):Boolean {
			
			if (!initialized) return true;
			
			var match:XMLList = getMatch(id);
			
			if (match == null) return false;
			
			return (match.@unique == "true");
			
		}
		
		//
		//
		public static function getUniqueGroup (id:uint):Array {
			
			if (!initialized) return null;
			
			var match:XMLList = getMatch(id);
			
			if (match == null) return null;
			
			if ("@uniquegroup" in match) {
				
				return String(match.@uniquegroup).split(",");
				
			}
			
			return null;
			
		}
		
		//
		//
		public static function getRotatable (id:uint):Boolean {
			
			if (!initialized) return true;
			
			var match:XMLList = getMatch(id);
			
			if (match == null) return false;
			
			return (match.@rotate == "true");
			
		}
		
		//
		//
		public static function getLinkable (id:uint):Boolean {
			
			if (!initialized) return true;
			
			var match:XMLList = getMatch(id);
			
			if (match == null) return false;
			
			return (match.@linkable == "1");
			
		}
		
		//
		//
		public static function getLimitRotate (id:uint):Boolean {
			
			if (!initialized) return true;
			
			var match:XMLList = getMatch(id);
			
			if (match == null) return false;
			
			return (match.@limit180 == "true");
			
		}

		
		//
		//
		public static function isTile (id:String):Boolean {
			
			if (!initialized) return false;
			
			var match:XMLList = getMatch(id);
			
			if (match == null) return false;
			
			return (match..obj.@type == "tile");
			
		}
		
		//
		//
		public static function isTextureBlock (id:String):Boolean {
			
			if (!initialized) return false;
			
			var match:XMLList = getMatch(id);
			
			if (match == null) return false;
			
			return (match..obj.@type == "textureblock");
			
		}
		
		//
		//
		public static function getCacheAsBitmap (id:String):Boolean {
			
			if (!initialized) return false;
			
			var match:XMLList = getMatch(id);
			
			if (match == null) return false;
			
			return (match..obj.@type == "tile" || match..obj.@cache == "1");
			
		}
		
		//
		//
		public static function tileID (id:String):int {
			
			if (!initialized) return 0;
			
			var match:XMLList = getMatch(id);
			
			if (match == null) return 0;
			
			return parseInt(match..obj.@tile);
			
		}
		
		//
		//
		public static function tileBack (id:String):Boolean {
			
			if (!initialized) return false;
			
			var match:XMLList = getMatch(id);
			
			if (match == null) return false;
			
			return (match..obj.@back == "1");
			
		}
		
		//
		//
		public static function tileScale (id:String):int {
			
			if (!initialized) return 1;
			
			var match:XMLList = getMatch(id);
			
			if (match == null) return 1;
			
			var matchobj:XMLList = match..obj;
			
			return (matchobj.@tilescale != undefined) ? parseInt(matchobj.@tilescale) : 1;
			
		}
		
		//
		//
		public static function tileDefID (id:String, tileID:int, back:Boolean, tilescale:int = 1):String {
			
			var match:XMLList = getMatch(id);
			
			if (match..obj.children()[0] != undefined && match..obj.children()[0].toString().length > 0) {
				return _library.getTileDefID(tileID, back, JSON.decode(match..obj.children()[0].toString()), -1, tilescale);
			} else if (match..obj.@tile != undefined) {
				return _library.getTileDefID(tileID, back, null, -1, tilescale);
			}

			return null;
			
		}
		
		//
		//
		public static function stampName (id:String):String {
			
			if (!initialized) return null;
			
			var match:XMLList = getMatch(id);
			
			if (match == null) return null;
			
			return match..obj.@stamp;
			
		}
		
		//
		//
		public static function tileRotation (id:String):int {
			
			if (!initialized) return 0;
			
			var match:XMLList = getMatch(id);
			
			if (match == null) return 0;
			
			var matchobj:XMLList = match..obj;
			
			return (matchobj.@r != undefined) ? parseInt(matchobj.@r) : 0;
			
		}
		
		//
		//
		public static function getTextEntry (id:uint):Boolean {
			
			if (!initialized) return true;
			
			var match:XMLList = getMatch(id);
			
			if (match == null) return false;
			
			return (match.@textentry == "true");
			
		}

		//
		//
		public static function getEmbeddedString (embeddedText:Class):String {
			
			var ba:ByteArray = (new embeddedText()) as ByteArray;
			var s:String = ba.readUTFBytes(ba.length);
			if (s.charAt(0) != "<") s = s.substring(1, s.length);
			return s;
			
		}
		
		
	}
	
}