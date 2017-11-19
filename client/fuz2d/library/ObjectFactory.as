package fuz2d.library {
	
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.xml.*;
	import fuz2d.*;
	import fuz2d.action.physics.Simulation;
	import fuz2d.action.physics.SimulationObject;
	import fuz2d.action.play.Playfield;
	import fuz2d.action.play.PlayObject;
	import fuz2d.model.material.Material;
	import fuz2d.model.Model;
	import fuz2d.model.object.Object2d;
	import fuz2d.model.object.Symbol;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public final class ObjectFactory {
		
		private static var _main:Fuz2d;
		private static var _manifest:XML;
		
		public static var cache:Object;

		private static var _initialized:Boolean = false;
		
		public static function get main ():Fuz2d { return _main; }
		public static function set main(value:Fuz2d):void { _main = value; }
		public static function get model ():Model { return (_main) ? _main.model : null; }
		public static function get simulation ():Simulation { return (_main) ? _main.simulation : null; }
		public static function get playfield ():Playfield { return (_main) ? _main.playfield : null; }
		
		public static function get initialized ():Boolean {
			
			if (!_initialized) throw new Error("ObjectFactory not initialized.  Please supply a definitions XML to the initialize method.");
			
			return _initialized;
			
		}
		
		public static function get isInitialized ():Boolean { return _initialized; }
		
		//
		//
		public static function initialize (main:Fuz2d, manifest:String):Boolean {
			
			_main = main;
			_manifest = new XML(manifest);

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
				if (!isNaN(parseInt(id as String))) {
					match = cache[id] = _manifest..playobj.(@cid == id);
				} else {
					match = cache[id] = _manifest..playobj.(@id == id);
				}
			}
			return match;
		}

		//
		//
		public static function createNew (objID:String, creator:Object = null, x:Number = 0, y:Number = 0, z:Number = 0, options:Object = null):Object {
			
			if (!initialized) return null;
			
			var match:XMLList;
			
			match = getMatch(objID);
			
			if (match == null) return null;
			
			var o:ObjectDefinition = new ObjectDefinition(match, x, y, z, options);
			
			return o.getObjectTemplate(objID, creator);
			
		}
		
		//
		//
		public static function effect (creator:Object, name:String, self_illuminate:Boolean = false, z:Number = 10, location:Point = null, rotation:Number = 0):Symbol {
			
			if (!initialized) return null;
			
			if (model == null) return null;
			
			var x:Number = 0;
			var y:Number = 0;
			
			if (location != null) {
				
				x = location.x,
				y = location.y;
				
			} else if (creator is PlayObject) {
				
				x = PlayObject(creator).object.x;
				y = PlayObject(creator).object.y;
				
			} else if (creator is SimulationObject) {
				
				x = SimulationObject(creator).objectRef.x;
				y = SimulationObject(creator).objectRef.y;
				
			} else if (creator is Object2d) {
				
				x = Object2d(creator).x;
				y = Object2d(creator).y;
				
			}
			
			var material:Material = null;
			if (self_illuminate) material = new Material( { self_illuminate: 1 } );
			
			var s:Symbol = Symbol(model.addObject(new Symbol(name, Fuz2d.library, material, null, x, y, z, rotation)));
			s.controlled = true;
			return s;
			
		}
		
		//
		//
		public static function getNodeByNameAndID (elementName:String, nodeID:String):XML {
			
			if (!initialized) return null;

			return new XML(_manifest[elementName].(@id == nodeID).toString());
			
		}
		
		//
		//
		public static function getZIndex (id:String):int {
			
			var match:XMLList = getMatch(id); // _manifest..playobj.(@cid == id);
			
			if (match == null) return 0;
			
			var matchobj:XMLList = match..obj;
			
			return (matchobj.@z != undefined) ? parseInt(matchobj.@z) : 0;

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