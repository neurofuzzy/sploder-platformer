/**
* ...
* @author Default
* @version 0.1
*/

package com.sploder.simulation {

	import com.sploder.*;
	import com.sploder.geom.*;
	
	import flash.utils.Dictionary;
	
	public class SimulationGrid {
		
		public function get scaleX ():int { return (1 / _iScaleX) >> 0; }
		public function set scaleX (val:int):void {
			_iScaleX = (!isNaN(val)) ? 1 / val : _iScaleX;
			_scaleX = (!isNaN(val)) ? val : _scaleX;
		}
		
		public function get scaleY ():int { return (1 / _iScaleY) >> 0; }
		public function set scaleY (val:int):void {
			_iScaleY = (!isNaN(val)) ? 1 / val : _iScaleY;
			_scaleY = (!isNaN(val)) ? val : _scaleY;
		}
		
		private var _scaleX:int = 10;
		private var _scaleY:int = 10;		
		private var _iScaleX:Number = 0.1;
		private var _iScaleY:Number = 0.1;
	
		private var _grid:Object;
		private var _areaMap:Dictionary;
		
		var x:int;
		var y:int;
		
		//
		//
		public function get objects ():Array {
			
			var objlist:Array = [];
			for (var obj:Object in _areaMap) objlist.push(_areaMap[obj]);
			return objlist;
			
		}
		
		//
		//
		public function SimulationGrid(scaleX:uint = 10, scaleY:uint = 10) {
			
			this.scaleX = scaleX;
			this.scaleY = scaleY;

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
		private function setCoords (obj:PlayfieldObject):void {
			
			x = (obj.x * _iScaleX) >> 0;
			y = (obj.y * _iScaleY) >> 0;
				
		}
		
		//
		//
		public function register (obj:PlayfieldObject):void {
			
			if (obj is PlayfieldEdge) registerEdge(PlayfieldEdge(obj));
			
			if (obj != null && !isNaN(obj.x) && !isNaN(obj.y)) {
				
				setCoords(obj);
	
				if (_areaMap[obj] == null) {
					
					if (cellAt(x, y).indexOf(obj) == -1) cellAt(x, y).push(obj);
					_areaMap[obj] = { x: x, y: y };
					
				} else {
					
					update(obj);
					
				}
				
			}
			
		}
		
		//
		//
		public function unregister (obj:PlayfieldObject):void {
			
			if (_areaMap[obj] != null) {
				
				update(obj, true);
				delete _areaMap[obj];
				
			}
			
		}
		
        //
        //
        //
        public function registerEdge (edge:PlayfieldEdge):void {

			setCoords(edge);
			
			if (_areaMap[edge] != null) unregisterEdge(edge);
			
			var edges:Array = getEdgeCells(edge);
			
			for each (var c:Object in edges) {
				if (cellAt(c.x, c.y).indexOf(edge) == -1) cellAt(c.x, c.y).push(edge);
			}
			
			_areaMap[edge] = { x: x, y: y };
            
        }
		
        //
        //
        //
        public function unregisterEdge (edge:PlayfieldEdge):void {

			var edgeIndex:int;
			var edges:Array = getEdgeCells(edge);
			
			for each (var c:Object in edges) {
				edgeIndex = cellAt(c.x, c.y).indexOf(edge);
				if (edgeIndex != -1) cellAt(c.x, c.y).splice(edgeIndex, 1);
			}
            
        }
		
		//
		//
		//
		function getEdgeCells (edge:PlayfieldEdge):Array {
			
			var cells:Array = [];
			
			var x1:Number = edge.x1;
			var y1:Number = edge.y1;
			var x2:Number = edge.x2;
			var y2:Number = edge.y2;
			
            var minxa:Number;
            var maxxa:Number;
            var minya:Number;
            var maxya:Number;
            
            var intersects:Boolean;
            var contained:Boolean;

            // get bounds
			//
            minxa = Math.min(Math.floor(x1 / _scaleX), Math.floor(x2 / _scaleX));
            maxxa = Math.max(Math.floor(x1 / _scaleX), Math.floor(x2 / _scaleX));
            minya = Math.min(Math.floor(y1 / _scaleY), Math.floor(y2 / _scaleY));
            maxya = Math.max(Math.floor(y1 / _scaleY), Math.floor(y2 / _scaleY));
			
			// check all cells with rectangular bounding area for edge intersect or containment
			//
            for (var j:int = maxya; j >= minya; j--) {
            
                for (var i:int = maxxa; i >= minxa; i--) {
                        
                    // check or intersection of line and area
    
                    intersects = false;
                    
                    if (Geom2d.twoLinesIntersect(i * _scaleX, j * _scaleY, (i + 1) * _scaleX, j * _scaleY, x1, y1, x2, y2)) {
                        intersects = true;
                    }
                    
                    if (Geom2d.twoLinesIntersect((i + 1) * _scaleX, j * _scaleY, (i + 1) * _scaleX, (j + 1) * _scaleY, x1, y1, x2, y2)) {
                        intersects = true;
                    }
                    
                    if (Geom2d.twoLinesIntersect((i + 1) * _scaleX, (j + 1) * _scaleY, i * _scaleX, (j + 1) * _scaleY, x1, y1, x2, y2)) {
                        intersects = true;
                    }
                    
                    if (Geom2d.twoLinesIntersect(i * _scaleX, (j + 1) * _scaleY, i * _scaleX, j * _scaleY, x1, y1, x2, y2)) {
                        intersects = true;
                    }
                    
                    contained = false;
                    
                    if (Geom2d.lineWithinBounds(i * _scaleX, j * _scaleY, (i + 1) * _scaleX, (j + 1) * _scaleY, x1, y1, x2, y2)) {
                        contained = true;
                    }
                    
                    if (intersects || contained) {

						cells.push( { x: i, y: j } );

                    }
    
                }
            
            }  
			
			return cells;
			
		}
		
        //
        //
        //
        public function getNeighborsBetween (obj1:Object, obj2:Object):Array {

			var cells:Array = getCellsBetween(obj1, obj2);
			var neighbors:Array = [];
			
			for each (var c:Object in cells) neighbors = neighbors.concat(cellAt(c.x, c.y));
            
			return neighbors;
			
        }
		
		//
		//
		//
		function getCellsBetween (obj1:Object, obj2:Object):Array {
			
			if (obj1 == null || obj2 == null || isNaN(obj1.x) || isNaN(obj1.y) || isNaN(obj2.x) || isNaN(obj2.y)) return [];
			var cells:Array = [];
			
			var x1:Number = obj1.x;
			var y1:Number = obj1.y;
			var x2:Number = obj2.x;
			var y2:Number = obj2.y;
			
            var minxa:Number;
            var maxxa:Number;
            var minya:Number;
            var maxya:Number;
            
            var intersects:Boolean;
            var contained:Boolean;

            // get bounds
			//
            minxa = Math.min(Math.floor(x1 / _scaleX), Math.floor(x2 / _scaleX));
            maxxa = Math.max(Math.floor(x1 / _scaleX), Math.floor(x2 / _scaleX));
            minya = Math.min(Math.floor(y1 / _scaleY), Math.floor(y2 / _scaleY));
            maxya = Math.max(Math.floor(y1 / _scaleY), Math.floor(y2 / _scaleY));
			
			// check all cells with rectangular bounding area for edge intersect or containment
			//
            for (var j:int = maxya; j >= minya; j--) {
            
                for (var i:int = maxxa; i >= minxa; i--) {
                        
                    // check or intersection of line and area
    
                    intersects = false;
                    
                    if (Geom2d.twoLinesIntersect(i * _scaleX, j * _scaleY, (i + 1) * _scaleX, j * _scaleY, x1, y1, x2, y2)) {
                        intersects = true;
                    }
                    
                    if (Geom2d.twoLinesIntersect((i + 1) * _scaleX, j * _scaleY, (i + 1) * _scaleX, (j + 1) * _scaleY, x1, y1, x2, y2)) {
                        intersects = true;
                    }
                    
                    if (Geom2d.twoLinesIntersect((i + 1) * _scaleX, (j + 1) * _scaleY, i * _scaleX, (j + 1) * _scaleY, x1, y1, x2, y2)) {
                        intersects = true;
                    }
                    
                    if (Geom2d.twoLinesIntersect(i * _scaleX, (j + 1) * _scaleY, i * _scaleX, j * _scaleY, x1, y1, x2, y2)) {
                        intersects = true;
                    }
                    
                    contained = false;
                    
                    if (Geom2d.lineWithinBounds(i * _scaleX, j * _scaleY, (i + 1) * _scaleX, (j + 1) * _scaleY, x1, y1, x2, y2)) {
                        contained = true;
                    }
                    
                    if (intersects || contained) {

						cells.push( { x: i, y: j } );

                    }
    
                }
            
            }  
			
			return cells;
			
		}

		
		//
		//
		public function update (obj:PlayfieldObject, remove:Boolean = false):Boolean {
			
			var changed:Boolean = false;
			
			if (obj != null) {
				
				setCoords(obj);

				var o:Object = _areaMap[obj];
				var c:Array = cellAt(x, y);
				
				if (o != null) {
					
					if (x != o.x || y != o.y || remove) {
						
						var oldcell:Array = cellAt(o.x, o.y);
						var idx:int = oldcell.indexOf(obj);
						
						if (idx != -1) {
							oldcell.splice(idx, 1);
							_areaMap[obj] = null;
						}
						
						changed = true;
						
					} else {
						
						return false;
						
					}
					
				}
				
				if (changed && !remove) {
					
					if (c.indexOf(obj) == -1) c.push(obj);
					_areaMap[obj] = { x: x, y: y };
					
					return true;
			
				}
			
			}
			
			return false;
			
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
		public function getNeighborsOf (obj:PlayfieldObject, unique:Boolean = false, type:String = ""):Array {
			
			var i:int;
			var neighbors:Array = [];
			
			if (obj != null) {
				
				setCoords(obj);
			
				for (var j:int = y + 1; j >= y - 1; j--) {
						
					for (i = x + 1; i >= x - 1; i--) {
							
						neighbors = neighbors.concat(cellAt(i, j));
						
					}					
					
				}				

			}
			
			var objIndex:int = neighbors.indexOf(obj);
			if (objIndex != -1) neighbors.splice(objIndex, 1);			
			
			// get only of type
			//
			if (type != "") {
				
				i = neighbors.length;
				while (i--) if (neighbors[i].type == null || neighbors[i].type != type) neighbors.splice(i, 1);
				
			}
			
			// get unique neighbors
			//
			if (unique) {
				
				i = neighbors.length;
				var uniqueNeighbors:Array = [];
				while (i--) if (uniqueNeighbors.indexOf(neighbors[i]) == -1) uniqueNeighbors.push(neighbors[i]);				
					
				return uniqueNeighbors;
				
			}
			
			return neighbors;
			
		}
		
		//
		//
		public function tellNeighbors (obj:PlayfieldObject, func:String):void {
			
			var neighbors:Array = getNeighborsOf(obj);
			
			for each (var neighbor:PlayfieldObject in neighbors) {
				if (neighbor[func] is Function) {

					neighbor[func](obj);
				}
			}
			
		}
		
	}
	
}
