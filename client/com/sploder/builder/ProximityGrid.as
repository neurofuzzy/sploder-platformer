
package com.sploder.builder {

	import flash.utils.Dictionary;
	import com.sploder.geom.Geom2d;
	
	public class ProximityGrid {
		
		private var _scaleX:uint;
		private var _scaleY:uint;

		private var _minScale:uint;
		private var _maxScale:uint;
		
		public function get minScale():uint { return _minScale; }
		public function get maxScale():uint { return _maxScale; }
		
		private var _grid:Object;
		private var _areaMap:Dictionary;
		
		//
		//
		public function ProximityGrid (scaleX:uint = 60, scaleY:uint = 60) {
			
			_scaleX = scaleX;
			_scaleY = scaleY;
			
			_minScale = Math.min(_scaleX, _scaleY);
			_maxScale = Math.max(_scaleX, _scaleY);
		
			init();
			
		}
		
		//
		//
		private function init ():void {
			
			_grid = { };
			_areaMap = new Dictionary(true);
			
		}
		
		//
		//
		public function register (obj:Object):void {
					
			if (obj != null) {
				
				var x:int;
				var y:int;
				
				if (obj.width <= minScale && obj.height <= minScale) {
					
					x = Math.floor(obj.x / _scaleX);
					y = Math.floor(obj.y / _scaleY);
	
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
			
			var a:Array = [];
			var w:Number = obj.width * 0.5;
			var h:Number = obj.height * 0.5;
			
			var minX:int = Math.floor((obj.x - w) / _scaleX);
			var maxX:int = Math.floor((obj.x + w) / _scaleX);
			var minY:int = Math.floor((obj.y - h) / _scaleY);
			var maxY:int = Math.floor((obj.y + h) / _scaleY);
			
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
		public function update (obj:Object, remove:Boolean = false):void {
			
			var changed:Boolean = false;
			
			if (obj != null) {
				
				var x:int = Math.floor(obj.x / _scaleX);
				var y:int = Math.floor(obj.y / _scaleY);
	
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
							
							return;
							
						}
						
					}
					
				}
				
				if (changed && !remove) {
					
					if (c.indexOf(obj) == -1) c.push(obj);
					_areaMap[obj] = { x: x, y: y };
			
				}
			
			}
			
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
		public function getNeighborsOf (obj:Object, distSort:Boolean = true, removeSelf:Boolean = true, neighbors:Array = null, searchSize:int = 1):Array {
			
			if (neighbors == null) neighbors = [];
			else while (neighbors.length > 0) neighbors.pop();
			
			if (obj != null) {
				
				var x:int = Math.floor(obj.x / _scaleX);
				var y:int = Math.floor(obj.y / _scaleY);
				
				var cW:int = searchSize;
				var cH:int = searchSize;
				
				if (obj.width > _scaleX) cW = Math.ceil(obj.width / _scaleX / 2);
				if (obj.height > _scaleY) cH = Math.ceil(obj.height / _scaleY / 2);
				
				for (var j:int = y + cH; j >= y - cH; j--) {
						
					for (var i:int = x + cW; i >= x - cW; i--) {
							
						//neighbors = neighbors.concat(cellAt(i, j));
						
						var cell:Array = cellAt(i, j);
						if (cell != null) {
							var c:int = cell.length;
							while (c--) {
								var cobj:Object = cell[c];
								if (neighbors.indexOf(cobj) == -1) neighbors.push(cell[c]);
							}
						}
						
						
					}					
					
				}				

			}
			
			if (removeSelf) {
				
				while (neighbors.indexOf(obj) != -1) neighbors.splice(neighbors.indexOf(obj), 1);
				
			}
			
			if (distSort) {
				
				var nD:Array = [];
				
				for each (var neighbor:Object in neighbors) nD.push( { dist: Geom2d.squaredDistanceBetween(obj, neighbor), obj: neighbor } );
				nD.sortOn("dist", Array.NUMERIC | Array.DESCENDING);
				neighbors = [];
				for each (var dd:Object in nD) neighbors.push(dd.obj);
				
			}

			return neighbors;
			
		}
		
		
		//
		//
		public function getNeighborsNear (xpos:Number, ypos:Number, width:Number = 1, height:Number = 1, neighbors:Array = null):Array {
			
			if (neighbors == null) neighbors = [];
			else while (neighbors.length > 0) neighbors.pop();
			
			var x:int = Math.floor(xpos / _scaleX);
			var y:int = Math.floor(ypos / _scaleY);
			
			var cW:int = Math.ceil(width / _scaleX);
			var cH:int = Math.ceil(height / _scaleY);
			
			for (var j:int = y + cH; j >= y - cH; j--) {
					
				for (var i:int = x + cW; i >= x - cW; i--) {
						
					neighbors = neighbors.concat(cellAt(i, j));
					
				}					
				
			}				

			return neighbors;
			
		}	
		
	}
	
}
