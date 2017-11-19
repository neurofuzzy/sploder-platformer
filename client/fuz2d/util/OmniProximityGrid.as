/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.util {

	import flash.geom.Point;
	import flash.utils.Dictionary;
	import fuz2d.model.object.Object2d;
	import fuz2d.util.Geom2d;
	
	public class OmniProximityGrid {
		
		public static const OBJECT:uint = 1;
		public static const SIMOBJECT:uint = 2;
		public static const PLAYOBJECT:uint = 3
		
		private var _scaleX:uint;
		private var _scaleY:uint;

		private var _minScale:uint;
		private var _maxScale:uint;
		
		public function get minScale():uint { return _minScale; }
		public function get maxScale():uint { return _maxScale; }
		
		private var _grid:Object;
		private var _areaMap:Dictionary;
		
		private var _cP:Object;
	
		protected var _mode:uint;
		
		//
		//
		public function OmniProximityGrid (scaleX:uint = 10, scaleY:uint = 10, mode:uint = 1) {
			
			_scaleX = scaleX;
			_scaleY = scaleY;
			
			_minScale = Math.min(_scaleX, _scaleY);
			_maxScale = Math.max(_scaleX, _scaleY);

			_mode = mode;
		
			init();
			
		}
		
		//
		//
		private function init ():void {
			
			_grid = { };
			_areaMap = new Dictionary(true);
			_cP = { x: 0, y: 0, width: 0, height: 0 };
			
		}
		
		//
		//
		protected function getPropertiesFor (obj:Object):void {
			
			switch (_mode) {
				
				case OBJECT:
				
					_cP.x = obj.x;
					_cP.y = obj.y;
					_cP.width = obj.width;
					_cP.height = obj.height;
					break;
				
				case SIMOBJECT:
				
					_cP.x = obj.objectRef.x;
					_cP.y = obj.objectRef.y;
					_cP.width = obj.objectRef.width;
					_cP.height = obj.objectRef.height;
					break;
				
				case PLAYOBJECT:
				
					_cP.x = obj.object.x;
					_cP.y = obj.object.y;
					_cP.width = obj.object.width;
					_cP.height = obj.object.height;
					break;
				
			}
			
		}
		
		//
		//
		public function register (obj:Object):void {
				
			if (obj != null) {
				
				getPropertiesFor(obj);
				
				var x:int;
				var y:int;
				
				if (_cP.width <= minScale && _cP.height <= minScale) {
					
					x = Math.floor(_cP.x / _scaleX);
					y = Math.floor(_cP.y / _scaleY);
	
					if (_areaMap[obj] == null) {
						
						if (cellAt(x, y).indexOf(obj) == -1) cellAt(x, y).push(obj);
						_areaMap[obj] = { x: x, y: y };
						
					}
				
				} else {
						
					var cells:Array = getCellsFor(obj);
					
					_areaMap[obj] = [];
					
					for each (var c:Object in cells) {
						
						if (cellAt(c.x, c.y).indexOf(obj) == -1) cellAt(c.x, c.y).push(obj);
						_areaMap[obj].push( { x: c.x, y: c.y } );	

					}
	
				}

			}
			
		}
		
		//
		//
		public function unregister (obj:Object):void {
					
			if (_areaMap[obj] != null) {
				
				update(obj, true);
				_areaMap[obj] = null;
				delete _areaMap[obj];
				
			}
			
		}
		
		//
		//
		protected function getCellsFor (obj:Object):Array {
			
			getPropertiesFor(obj);
			
			var a:Array = [];
			var w:Number = _cP.width * 0.5;
			var h:Number = _cP.height * 0.5;
			
			var minX:int = Math.floor((_cP.x - w) / _scaleX);
			var maxX:int = Math.floor((_cP.x + w) / _scaleX);
			var minY:int = Math.floor((_cP.y - h) / _scaleY);
			var maxY:int = Math.floor((_cP.y + h) / _scaleY);
			
			_areaMap[obj] = [];
			
			for (var j:int = minY; j <= maxY; j++) {
				
				for (var i:int = minX; i <= maxX; i++) {
					
					a.push({ x: i, y: j });
					
				}							
				
			}
			
			return a;
			
		}
		
		//
		//
		public function update (obj:Object, remove:Boolean = false):Boolean {
			
			var changed:Boolean = false;
	
			if (obj != null) {
					
				if (!remove) getPropertiesFor(obj);
				
				var x:int = Math.floor(_cP.x / _scaleX);
				var y:int = Math.floor(_cP.y / _scaleY);
	
				var o:Object = _areaMap[obj];
				var c:Array = cellAt(x, y);
				
				if (o != null) {
					
					var oldcell:Array;
					var idx:uint;
					
					if (o is Array) {
					
						for each (var cd:Object in o) {
							oldcell = cellAt(cd.x, cd.y);
							idx = oldcell.indexOf(obj);
							if (idx != -1) oldcell.splice(idx, 1);
						}
						
						_areaMap[obj] = null;
						delete _areaMap[obj];
						
						if (!remove) register(obj);
						
					} else {
						
						if (x != o.x || y != o.y || remove) {
							
							oldcell = cellAt(o.x, o.y);
							idx = oldcell.indexOf(obj);
							
							if (idx != -1) {
								oldcell.splice(idx, 1);
								_areaMap[obj] = null;
								delete _areaMap[obj];
							}
							
							changed = true;
							
						} else {
							
							return false;
							
						}
						
					}
					
				}
				
				if (changed && !remove) {
					
					if (c.indexOf(obj) == -1) c.push(obj);
					_areaMap[obj] = { x: x, y: y };
			
				}
			
			}
			
			return changed;
			
		}
		
		//
		//
		private function cellID (x:int, y:int):String {
			
			return "cell_" + x + "_" + y;
			
		}
		
		//
		//
		private function cellAt (x:int, y:int):Array {
			
			var id:String = cellID(x, y);
			
			if (_grid[id] == null) {
				_grid[id] = [];
			}
			
			return _grid[id];
			
		}
		
		//
		//
		public function getNeighborsOf (obj:Object, distSort:Boolean = true, removeSelf:Boolean = true, neighbors:Array = null, distX:int = 1, distY:int = 1):Array {
			
			if (neighbors == null) neighbors = [];
			else while (neighbors.length > 0) neighbors.pop();
			
			if (obj != null) {
				
				getPropertiesFor(obj);
				
				var x:int = Math.floor(_cP.x / _scaleX);
				var y:int = Math.floor(_cP.y / _scaleY);
				
				var cW:int = 1;
				var cH:int = 1;
				
				if (_cP.width > _scaleX) cW = Math.ceil(_cP.width / _scaleX / 2);
				if (_cP.height > _scaleY) cH = Math.ceil(_cP.height / _scaleY / 2);
				
				distX -= 1;
				distY -= 1;
				
				cH += distY;
				cW += distX;
				
				for (var j:int = y + cH; j >= y - cH; j--) {
						
					for (var i:int = x + cW; i >= x - cW; i--) {
							
						neighbors = neighbors.concat(cellAt(i, j));
						
					}					
					
				}				

			}
			
			if (removeSelf) {
				
				while (neighbors.indexOf(obj) != -1) neighbors.splice(neighbors.indexOf(obj), 1);
				
			}
			
			if (distSort) return sortNeighbors(obj, neighbors);

			return neighbors;
			
		}
		
		//
		//
		public function getNeighborsNear (pt:Point, distSort:Boolean = true, range:int = 1):Array {
			
			var neighbors:Array = [];
			
			var x:int = Math.round(pt.x / _scaleX);
			var y:int = Math.round(pt.y / _scaleY);		
			
			for (var j:int = y + range; j >= y - range; j--) {
					
				for (var i:int = x + range; i >= x - range; i--) {
						
					neighbors = neighbors.concat(cellAt(i, j));
					
				}					
				
			}				
			
			if (distSort) return sortNeighbors(pt, neighbors);

			return neighbors;
			
		}
		
		//
		//
		public function getNeighborsAlong (ptA:Point, ptB:Point, distSort:Boolean = true):Array {
			
			var neighbors:Array = [];
			
			var xA:int = Math.floor(((ptA.x <= ptB.x) ? ptA.x : ptB.x) / _scaleX);
			var yA:int = Math.floor(((ptA.y <= ptB.y) ? ptA.y : ptB.y) / _scaleY);
			var xB:int = Math.floor(((ptA.x > ptB.x) ? ptA.x : ptB.x) / _scaleX);
			var yB:int = Math.floor(((ptA.y > ptB.y) ? ptA.y : ptB.y) / _scaleY);	
			
			for (var j:int = yB + 1; j >= yA - 1; j--) {
					
				for (var i:int = xB + 1; i >= xA - 1; i--) {
						
					neighbors = neighbors.concat(cellAt(i, j));
					
				}					
				
			}				
			
			if (distSort) return sortNeighbors(ptA, neighbors);

			return neighbors;
			
		}
		
		//
		//
		protected function sortNeighbors(obj:Object, neighbors:Array):Array {
			
			var nD:Array = [];
					
			if (obj is Point) {
				
				for each (var neighbor:Object in neighbors) {
					getPropertiesFor(neighbor);
					nD.push( { dist: (obj.x - _cP.x) * (obj.x - _cP.x) + (obj.y - _cP.y) * (obj.y - _cP.y), obj: neighbor } );
				}
				
			} else {
				
				switch (_mode) {
					
					case OBJECT:
					
						for each (var oneighbor:Object2d in neighbors) nD.push( { dist: Geom2d.squaredDistanceBetween(obj as Object2d, oneighbor), obj: oneighbor } );
						break;
					
					case SIMOBJECT:

						for each (var sneighbor:Object in neighbors) nD.push( { dist: Geom2d.squaredDistanceBetween(obj.objectRef, sneighbor.objectRef), obj: sneighbor } );
						break;
						
					case PLAYOBJECT:
						
						for each (var pneighbor:Object in neighbors) nD.push( { dist: Geom2d.squaredDistanceBetween(obj.object, pneighbor.object), obj: pneighbor } );
						break;
					
				}				
				
			}	
			
			nD.sortOn("dist", Array.NUMERIC);
			neighbors = [];
			for each (var dd:Object in nD) neighbors.push(dd.obj);
			
			return neighbors;

		}
		
		public function end ():void {
			
			_grid = null;
			
			if (_areaMap) {
				for (var key:Object in _areaMap) {
					delete _areaMap[key];
				}
			}
			
			_areaMap = null;
			_cP = null;
			
		}
		
	}
	
}
