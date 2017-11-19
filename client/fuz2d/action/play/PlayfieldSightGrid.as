//
//
package fuz2d.action.play {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import fuz2d.model.object.Object2d;
	import fuz2d.util.OmniProximityGrid;
	
	import fuz2d.util.ProximityGrid;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class PlayfieldSightGrid extends EventDispatcher {
		
		private var _playfield:Playfield;
		
		private var _scaleX:uint;
		private var _scaleY:uint;
		
		public function get size ():int {
			
			return Math.max(_scaleX, _scaleY);
			
		}
		
		private var _grid:OmniProximityGrid;
		
		private var _objects:Array;
		private var _objectMap:Dictionary;

		private var _neighbors:Array;
		
		private var _sightInterval:int = 10;
		private var _counter:int = 0;
		
		public var sightDistX:int = 1;
		public var sightDistY:int = 1;
		
		//
		//
		public function PlayfieldSightGrid (playfield:Playfield, scaleX:uint = 10, scaleY:uint = 10) {
			
			_playfield = playfield;
			
			_scaleX = scaleX;
			_scaleY = scaleY;
			
			_grid = new OmniProximityGrid(scaleX, scaleY, OmniProximityGrid.PLAYOBJECT);
			
			_objects = [];
			_objectMap = new Dictionary(true);
			
			_neighbors = [];
			
			//_playfield.addEventListener(PlayfieldEvent.UPDATE, update);
			
		}
		
		//
		//
		public function update (e:Event = null):void {
			
			//_counter++;
			
			//if (_counter % 10 != 0) {
			//	return;
			//}
			
			//_counter = 0;
			
			for each (var playObj:PlayObjectControllable in _objects) {
				
				if (playObj == null || playObj.deleted || playObj.controller == null) {
					
					_objects.splice(_objects.indexOf(playObj), 1);
					
				} else {
			
					if (map(playObj) != _objectMap[playObj]) {
						
						_objectMap[playObj] = map(playObj);
						
						_grid.update(playObj);
						
						_neighbors = _grid.getNeighborsOf(playObj, false, true, _neighbors, sightDistX, sightDistY);
						
						for each (var neighbor:PlayObject in _neighbors) {
							
							if (neighbor != null && PlayObjectControllable(neighbor).controller != null) PlayObjectControllable(neighbor).controller.see(playObj);
							
						}

					}
					
				}
				
			}

		}
		
		//
		//
		public function register (playObj:PlayObjectControllable):void {
			
			if (_objects.indexOf(playObj) == -1) _objects.push(playObj);
			_objectMap[playObj] = map(playObj);
			_grid.register(playObj);
			
		}
		
		//
		//
		public function unregister (playObj:PlayObjectControllable):void {
			
			if (_objects.indexOf(playObj) != -1) _objects.splice(_objects.indexOf(playObj), 1);		
			delete _objectMap[playObj];

			_grid.unregister(playObj);
			
		}
		
		//
		//
		public function map (playObj:PlayObjectControllable):String {
			
			return  Math.floor(playObj.object.x / _scaleX) + "_" + Math.floor(playObj.object.y / _scaleY);

		}
		
		//
		//
		public function getNeighborsOf (playObj:PlayObjectControllable, distSort:Boolean = true, removeSelf:Boolean = true, neighbors:Array = null, distX:int = 1, distY:int = 1):Array {
			
			return _grid.getNeighborsOf(playObj, distSort, removeSelf, neighbors, distX, distY);
			
		}
		
		//
		//
		public function end ():void {
			
			if (_playfield) {
				//_playfield.removeEventListener(PlayfieldEvent.UPDATE, update);
			}
			
			if (_grid) {
				_grid.end();
				_grid = null;
			}
			
			_objects = null;
			_neighbors = null;
			
			if (_objectMap) {
				for (var key:Object in _objectMap) {
					delete _objectMap[key];
				}
			}
			
			_objectMap = null;
			
			_playfield = null;
			
		}
		
		
	}
	
}