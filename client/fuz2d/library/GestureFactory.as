package fuz2d.library 
{
	import com.adobe.serialization.json.JSON;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.xml.*;
	import fuz2d.*;
	import fuz2d.action.behavior.*;
	import fuz2d.action.physics.Simulation;
	import fuz2d.action.play.*;
	import fuz2d.model.Model;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class GestureFactory {
		
		private static var _main:Fuz2d;
		private static var _manifest:XML;

		private static var _initialized:Boolean = false;
		
		private static var _cache:Array;
		
		public static function get main ():Fuz2d { return _main; }
		public static function set main(value:Fuz2d):void { _main = value; }
		public static function get model ():Model { return _main.model; }
		public static function get simulation ():Simulation { return _main.simulation; }
		public static function get playfield ():Playfield { return _main.playfield; }
		
		public static function get initialized ():Boolean {
			
			if (!_initialized) throw new Error("GestureFactory not initialized.  Please supply a definitions XML to the initialize method.");
			
			return _initialized;
			
		}
		
		public static function get isInitialized ():Boolean { return _initialized; }
		
		//
		//
		public static function initialize (main:Fuz2d, manifest:String):Boolean {
			
			if (_initialized) return true;
			
			_main = main;
			_manifest = new XML(manifest);
			_cache = [];
			
			var gestures:XMLList = _manifest..gesture;
			
			var i:int = 0;
			for each (var g:XML in gestures)
			{
				_cache.push(JSON.decode(g.toString()));
				g.@idx = i;
				i++;
			}
			
			_initialized = true;
			
			return true;
			
		}
		
		//
		//
		public static function createNew (playobj:PlayObjectControllable, gesture_name:String, facing:String = "", action:String = ""):GestureBehavior {
			
			var match:XMLList;
			
			if (!initialized) return null;
			
			var objType:String = "";
			
			if (playobj is BipedObject) objType = "biped";
			else if (playobj is PlayObjectMovable) objType = "playobj";
			else if (playobj is PlayObjectControllable) objType = "playobj";
			else if (playobj is PlayObject) objType = "playobj";
			
			match = _manifest..playobj.(@type == objType);

			if (action.length > 0) match = match..biped.(@action == action);
			
			if (facing.length > 0) match = match..facing.(@direction == facing);
			
			if (match..gesture.(@name == gesture_name).toString() != "") match = match..gesture.(@name == gesture_name);
			else match = match..gesture.(@name == "all");
			
			if (match == null || match.toString() == "") return null;
			
			var hold:Number = 0;
			if (match.@hold != undefined) hold = parseInt(match.@hold);

			var relax:Number = 0;
			if (match.@relax != undefined) relax = parseInt(match.@relax);
			
			var g:XML = match[0];
			
			var gesture_data:Object = _cache[g.@idx];
			
			return playobj.behaviors.add(new GestureBehavior(gesture_name, gesture_data, false, hold, relax)) as GestureBehavior;
			
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