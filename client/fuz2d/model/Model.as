/**
* com.sploder: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.model {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import fuz2d.util.ProximityGrid;
	
	import fuz2d.*;
	import fuz2d.model.environment.*;
	import fuz2d.model.material.*;
	import fuz2d.model.object.*;

	import flash.utils.Dictionary;


	/** ----------------------------------------------------------------
	 * Class: Model
	 * Manages the model and all aspects of the static 2d space.
	 ---------------------------------------------------------------- */
	
	public class Model extends EventDispatcher {
		
		public static const GRID_WIDTH:int = 60;
		public static const GRID_HEIGHT:int = 60;
		
		private var _objects:Array;
		private var _grid:ProximityGrid;
		private var _environment:Environment;
		
		private var _objIdx:Number = 0;
		public function get objIdx():Number { 
			_objIdx += 0.0000001;
			return _objIdx; 
		}
		
		
		private var _focus:Point2d;
		public function get focus():Point2d { return _focus; }
		public function set focus(value:Point2d):void {
			
			_focus = value;
			dispatchEvent(new ModelEvent(ModelEvent.FOCUS));
			
		}
		
		private static var _objectRotations:Dictionary;
		
		//
		public function get objects ():Array {
			return _objects;
		}
		
		//
		public function get cameras ():Array {
			return _environment.cameras;
		}
		
		//
		public function get environment ():Environment {
			return _environment;
		}
		
		//
		public static function get objectRotations ():Dictionary {
			return _objectRotations;
		}
		
		//
		public static function get rots ():Dictionary {
			return _objectRotations;
		}

		/**
		 * Constructor: Model
		 * @param	main
		 * ----------------------------------------------------------------
		 */
		public function Model () {
	
			init();
			
		}

		//
		//
		private function init ():void {

			_grid = new ProximityGrid(200, 200);
	
			_objects = [];
			_objectRotations = new Dictionary(true);
		
			_environment = new Environment(this);
			
			_focus = new Point2d(null, 0, 0);

		}
		
		//
		//
		public function addObject (obj:Object2d, light:OmniLight = null):Object2d {
			
			if (obj is Symbol && Symbol(obj).fail) {
				obj.destroy();
				return null;
			}
			
			_objects.push(obj);
			obj.model = this;
			
			if (light != null) obj.attribs.light = light;
			
			_grid.register(obj);
			
			_environment.castLightsOn(obj);
				
			dispatchEvent(new ModelEvent(ModelEvent.CREATE, false, false, obj));
			
			return obj;
			
		}
		
		//
		//
		public function removeObject (obj:Object2d, doDelete:Boolean = true):void {
			
			try {
				
				if (obj != null && _objects.indexOf(obj) != -1) {

					_objects.splice(_objects.indexOf(obj), 1);
					_objectRotations[obj] = null;
					
					delete _objectRotations[obj];
					
					_grid.unregister(obj);
					
					obj.clearLights();
					
					if (doDelete) {
						dispatchEvent(new ModelEvent(ModelEvent.DELETE, false, false, obj));
						obj.deleted = true;
					}
		
				}
			
			} catch (e:Error) {
				trace("Model removeObject:", e);
			}
			
		}	
		
		//
		//
		public function getNearObjects (obj:Object2d, distSort:Boolean = true):Array {
			
			if (_grid) return _grid.getNeighborsOf(obj, distSort);
			
			return [];
			
		}
		
		
		//
		//
		public function update (object:Object2d = null, deleted:Boolean = false):void {

			var eventType:String;
			if (!deleted) eventType = ModelEvent.UPDATE;
			else eventType = ModelEvent.DELETE;
			
			dispatchEvent(new ModelEvent(eventType, false, false, object));
			
		}
		
		//
		//
		public function end ():void {

			if (_environment) {
				_environment.end();
				_environment = null;
			}
			
			for each (var obj:Object2d in _objects) if (obj != null) obj.destroy();
			_objectRotations = null;
			_objects = null;
			
			if (_grid) {
				_grid.end();
				_grid = null;
			}
			
			_focus = null;
					
		}
		
	}
	
}
