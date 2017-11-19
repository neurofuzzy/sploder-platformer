package fuz2d.util {
	
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	
	import fuz2d.util.Geom2d;

	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class Map {
		
		protected var _scaleX:uint;
		protected var _scaleY:uint;
		
		public function get size ():Number { return Math.max(_scaleX, _scaleY); }
		
		protected var _iSX:Number;
		protected var _iSY:Number;	
		
		protected var _grid:Object;
		protected var _areaMap:Dictionary;
		
		protected var _minX:int;
		protected var _maxX:int;
		protected var _minY:int;
		protected var _maxY:int;
		
		public function get width ():int { return _maxX - _minX + 1; }
		public function get height ():int { return _maxY - _minY + 1; }
		
		public function get minX():int { return _minX; }
		public function get minY():int { return _minY; }
				
		
		public function Map (scaleX:uint = 10, scaleY:uint = 10) {
			
			_scaleX = scaleX;
			_scaleY = scaleY;
			
			_iSX = 1 / _scaleX;
			_iSY = 1 / _scaleY;
			
			init();
			
		}
		
		//
		//
		protected function init ():void {
			
			_grid = { };
			_areaMap = new Dictionary(true);
			
		}
		
		//
		//
		public function register (obj:Object, xpos:Number, ypos:Number, width:Number = 0, height:Number = 0):Boolean {
			
			var c:Point;
			var filled:Boolean = false;
			
			if (width == 0) width = _scaleX;
			if (height == 0) height = _scaleY;
			
			var tilesX:int = Math.round(width / _scaleX);
			var tilesY:int = Math.round(height / _scaleY);
			
			if (obj != null && _areaMap[obj] == null) {
				
				for (var j:int = 0 - Math.floor(tilesY / 2); j <= Math.max(0, Math.floor((tilesY - 1) / 2)); j++) {
					
					for (var i:int = 0 - Math.floor(tilesX / 2); i <= Math.max(0, Math.floor((tilesX - 1) / 2)); i++) {
					
						c = coordinatesFor(xpos + (i * _scaleX), ypos + (j * _scaleY));
						
						if (objectAt(c.x, c.y) == null) {
							
							_grid[cellID(c.x, c.y)] = obj;
							
							if (_areaMap[obj] == null) {
								_areaMap[obj] = new Point(c.x, c.y);
							} else {
								if (_areaMap[obj] is Array) {
									var a:Array = _areaMap[obj] as Array;
									a.push(new Point(c.x, c.y));
								} else {
									_areaMap[obj] = [_areaMap[obj], new Point(c.x, c.y)];
								}
							}
							
							_minX = (isNaN(_minX)) ? c.x : Math.min(_minX, c.x);
							_maxX = (isNaN(_maxX)) ? c.x : Math.max(_maxX, c.x);
							_minY = (isNaN(_minY)) ? c.y : Math.min(_minY, c.y);
							_maxY = (isNaN(_maxY)) ? c.y : Math.max(_maxY, c.y);
							
							filled = true;
							
						}
						
					}
					
				}
				
			}
			
			return filled;
			
		}
		
		//
		//
		public function isRegistered (obj:Object):Boolean {
			
			return (_areaMap[obj] != null);
			
		}
		
		//
		//
		public function unregister (obj:Object):void {
					
			if (_areaMap[obj] != null) {
				var c:Point;
				
				if (_areaMap[obj] is Point) {
					
					c = _areaMap[obj] as Point;

					try { 
						if (_grid[cellID(c.x, c.y)] == obj) {
							_grid[cellID(c.x, c.y)] = null;
						}
					} catch (e:Error) { }
					
				} else if (_areaMap[obj] is Array) {
					
					var a:Array = _areaMap[obj] as Array;
					
					var i:int = a.length;
					
					while (i--) {
						
						c = a.pop() as Point;
						
						try { 
							if (_grid[cellID(c.x, c.y)] == obj) {
								_grid[cellID(c.x, c.y)] = null; 
							}
						} catch (e:Error) { }
						
					}
					
				}
				
				_areaMap[obj] == null;
				delete _areaMap[obj];
				
			}
			
		}
		
		//
		//
		public function coordinatesFor (x:Number, y:Number):Point {
			
			return new Point(Math.floor(x * _iSX), Math.floor(y * _iSY) + 1);
			
		}
		
		//
		//
		public function locationFor (obj:Object):Point {
			return _areaMap[obj];
		}
		
		//
		//
		protected function cellID (x:int, y:int):String {
			
			return "cell_" + x + "_" + y;
			
		}
		
		//
		//
		public function objectAt (x:int, y:int, caller:Object = null):Object {
			
			var id:String = cellID(x, y);
			
			if (_grid[id] == null) return null;
			if (caller != null && _grid[id] == caller) return null;

			return _grid[id];
			
		}
		
		//
		//
		public function getNeighbor (obj:Object, xpos:Number, ypos:Number, offset:Point = null):Object {
			
			var c:Point = coordinatesFor(xpos, ypos);
			
			if (offset == null) return objectAt(c.x, c.y);
			else return objectAt(c.x + offset.x, c.y + offset.y);
			
		}
		
		//
		//
		public function getNeighbors (obj:Object, xpos:Number, ypos:Number, offset:Point = null):Object {
			
			var c:Point = coordinatesFor(xpos, ypos);
			
			if (offset == null) return objectAt(c.x, c.y);
			else return objectAt(c.x + offset.x, c.y + offset.y);
			
		}
		
		//
		//
		public function isFree (x:int, y:int):Boolean {
			
			return (_grid[cellID(x, y)] == null);
			
		}
		
		//
		//
		public function pointInOccupiedCell (pt:Point, self:Object = null):Boolean {
			
			var c:Point = coordinatesFor(pt.x, pt.y);
			return !isFree(c.x, c.y);
			
		}

		//
		//
		//
		public function getNearestObjectBetween (subject:Object, object:Object, subjectX:Number, subjectY:Number, objectX:Number, objectY:Number):Object {
			
			var s:Point = coordinatesFor(subjectX, subjectY);
			var o:Point = coordinatesFor(objectX, objectY);
			
			s.x += 0.5;
			s.y += 0.5;
			o.x += 0.5;
			o.y += 0.5;
			
			var jit:int = (s.y <= o.y) ? 1 : -1;
			var iit:int = (s.x <= o.x) ? 1 : -1;
	
			var intersects:Boolean;
			
			var jStart:int = Math.floor(s.y);
			var jEnd:int = Math.floor(o.y);
			var iStart:int = Math.floor(s.x);
			var iEnd:int = Math.floor(o.x);
			
			// check all cells with rectangular bounding area for edge intersect
			//
            for (var j:int = jStart; (jStart <= jEnd) ? (j <= jEnd) : (j >= jEnd) ; j += jit) {
            
                for (var i:int = iStart; (iStart <= iEnd) ? (i <= iEnd) : (i >= iEnd); i += iit) {
                        
                    // check or intersection of line and area
    
                    intersects = false;
                    
					if (jStart == jEnd || iStart == iEnd) { // if ray is orthogonal, line always intersects bounding cells
						intersects = true;
                    } else if (Geom2d.intersectLineLine(i, j, i + 1, j, s.x, s.y, o.x, o.y)) {
                        intersects = true;
                    } else if (Geom2d.intersectLineLine(i + 1, j, i + 1, j + 1, s.x, s.y, o.x, o.y)) {
                        intersects = true;
                    } else if (Geom2d.intersectLineLine(i + 1, j + 1, i, j + 1, s.x, s.y, o.x, o.y)) {
						intersects = true;
					} else if (Geom2d.intersectLineLine(i, j + 1, i, j, s.x, s.y, o.x, o.y)) {
						intersects = true;
                    }
                    
                    if (intersects && !isFree(i, j) && objectAt(i, j) != subject && objectAt(i, j) != object) return objectAt(i, j);
    
                }
            
            }  
			
			return null;
			
		}
		
		//
		//
		public function isObjectBetween (subject:Object, object:Object, subjectX:Number, subjectY:Number, objectX:Number, objectY:Number):Boolean {

			return (getNearestObjectBetween(subject, object, subjectX, subjectY, objectX, objectY) != null);
			
		}
		
		//
		//
		public function end ():void {
			
			_grid = null;
			
			if (_areaMap) {
				for (var key:Object in _areaMap) {
					delete _areaMap[key];
				}
			}
			
			_areaMap = null;
			
		}
		
	}
	
}