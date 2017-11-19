package fuz2d.action.play  {
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import fuz2d.library.ObjectFactory;
	import fuz2d.model.Model;
	
	import fuz2d.action.physics.*;
	import fuz2d.action.play.*;
	import fuz2d.model.object.*;
	import fuz2d.util.Geom2d;
	import fuz2d.util.Map;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class PlayfieldMap extends Map {
		
		protected var _playfield:Playfield;

		private var _boundsAdded:Boolean = false;
		public function get boundsAdded():Boolean { return _boundsAdded; }
		protected var _boundsObjects:Array;
		
		public static const UP:uint = 1;
		public static const DOWN:uint = 2;
		public static const LEFT:uint = 3;
		public static const RIGHT:uint = 4;
		public static const LEFT_DOUBLE:uint = 5;
		public static const RIGHT_DOUBLE:uint = 6;
		
		public static const UP_POINT:Point = new Point(0, 1);
		public static const DOWN_POINT:Point = new Point(0, -1);
		public static const LEFT_POINT:Point = new Point(-1, 0);
		public static const RIGHT_POINT:Point = new Point(1, 0);
		public static const LEFT_DOUBLE_POINT:Point = new Point(-2, 0);
		public static const RIGHT_DOUBLE_POINT:Point = new Point(2, 0);
		
		//
		//
		public function PlayfieldMap (playfield:Playfield) {
			
			super(Model.GRID_WIDTH, Model.GRID_HEIGHT);
			
			_playfield = playfield;
			
		}
		
		//
		//
		public function addBounds ():void {
			
			var playobj:PlayObject;
			
			if (_boundsObjects != null) {
				
				if (_boundsObjects.length > 0) {
					
					for each (playobj in _boundsObjects) unregister(playobj);

				}
				
			} 
			
			_boundsObjects = [];
			
			var bo:Array = BoundsBuilder.boundsObjects;
			
			for each (var simobj:SimulationObject in BoundsBuilder.boundsObjects) {
				
				playobj = new PlayObjectDummy(_playfield.main, simobj);
				_boundsObjects.push(playobj);
				register(playobj, playobj.object.x, playobj.object.y);
				
			}
			
		}
		
		//
		//
		public function registerPlayObject (obj:PlayObject):Boolean {
			
			if (_areaMap[obj] != null) return false;
			
			if (Math.floor(obj.object.width) <= _scaleX && Math.floor(obj.object.height) <= _scaleY) return register(obj, obj.object.x, obj.object.y);
			
			var cells:Array = getCellsFor(obj);

			var cell:Point;
			
			for (var i:int = cells.length-1; i >= 0; i--) {
				
				cell = cells[i];
				
				_minX = (isNaN(_minX)) ? cell.x : Math.min(_minX, cell.x);
				_maxX = (isNaN(_maxX)) ? cell.x : Math.max(_maxX, cell.x);
				_minY = (isNaN(_minY)) ? cell.y : Math.min(_minY, cell.y);
				_maxY = (isNaN(_maxY)) ? cell.y : Math.max(_maxY, cell.y);
				
				if (objectAt(cell.x, cell.y) == null) {
					
					_grid[cellID(cell.x, cell.y)] = obj;
					
				} else {
					
					cells.splice(i, 1);
					
				}
				
			}
			
			_areaMap[obj] = cells;
			

			
			return (cells.length > 0);

		}
		
		//
		//
		public function updatePlayObject (obj:PlayObject):void {
			
			if (obj.map) {
				unRegisterPlayObject(obj);
				registerPlayObject(obj);
			}
			
		}
		
		//
		//
		public function unRegisterPlayObject (obj:Object):void {
					
			var cs:Array;
			var c:Point;
			
			if (_areaMap[obj] != null) {
				
				if (_areaMap[obj] is Array) {
					
					cs = _areaMap[obj] as Array;
					
					for each (c in cs) try { if (_grid[cellID(c.x, c.y)] == obj) _grid[cellID(c.x, c.y)] = null; } catch (e:Error) { trace("PlayfieldMap unregister:", e);  }

				} else if (_areaMap[obj] is Point) {
					
					c = _areaMap[obj] as Point;
					
					try { if (_grid[cellID(c.x, c.y)] == obj) _grid[cellID(c.x, c.y)] = null; } catch (e:Error) { trace("PlayfieldMap unregister:", e); }
					
				}
			
				_areaMap[obj] == null;
				delete _areaMap[obj];

			}
			
		}
		
		
		//
		//
		protected function getCellsFor (obj:PlayObject):Array {
			
			var a:Array = [];
			var w:Number = obj.object.width * 0.4;
			var h:Number = obj.object.height * 0.4;
			
			var minX:int = Math.floor((obj.object.x - w) / _scaleX);
			var maxX:int = Math.floor((obj.object.x + w) / _scaleX);
			var minY:int = Math.floor((obj.object.y - h) / _scaleY) + 1;
			var maxY:int = Math.floor((obj.object.y + h) / _scaleY) + 1;
			
			//if (Math.round(obj.object.height / _scaleY) % 2 == 0) {
				//minY += 1;
				//maxY += 1;
			//}
			
			for (var j:int = minY; j <= maxY; j++) {
				
				for (var i:int = minX; i <= maxX; i++) {
					
					a.push(new Point(i, j));
					
				}							
				
			}
			
			return a;
			
		}
	
		//
		//
		public function canMove (obj:PlayObject, direction:uint):Boolean {
			
			var i:int;
			var j:int;
			
			var w:int;
			var h:int;
			
			var xmin:int;
			var xmax:int;
			var ymin:int;
			var ymax:int;
			
			if (obj.simObject is MotionObject) {
				
				w = Math.ceil(obj.object.width * _iSX);
				h = Math.ceil(obj.object.height * _iSY);
			
				xmin = Math.floor(Math.round(obj.object.x) * _iSX) - Math.floor(w * 0.5) + 1;
				xmax = xmin + w - 1;
				ymin = Math.floor((Math.round(obj.object.y) + _scaleY * 0.5) * _iSY) - Math.floor(h * 0.5) + 1;
				ymax = ymin + h - 1;	
			
			} else {
				
				w = Math.floor(obj.object.width * _iSX);
				h = Math.floor(obj.object.height * _iSY);
				
				xmin = Math.floor(Math.round(obj.object.x) * _iSX) - Math.floor(w * 0.5);
				if (direction == LEFT) xmin += 1;
				xmax = xmin + w - 1;
				
				ymin = Math.floor(Math.round(obj.object.y) * _iSY) - Math.floor(h * 0.5) + 1;
				if (direction == DOWN) ymin += 1;
				ymax = ymin + h - 1;
				
			}

			switch (direction) {
				
				case UP:
				
					for (i = xmin; i <= xmax; i++) {
						if (!isFree(i + UP_POINT.x, ymax + UP_POINT.y) && objectAt(i + UP_POINT.x, ymax + UP_POINT.y) != obj) {
							//ObjectFactory.effect(null, "squarefalse", true, 1000, new Point((i + UP_POINT.x) * _scaleX, (ymax + UP_POINT.y) * _scaleY)); 
							return false;
						//} else {
						//	ObjectFactory.effect(null, "square", true, 1000, new Point((i + UP_POINT.x) * _scaleX, (ymax + UP_POINT.y) * _scaleY)); 
						}
					}
					break;
					
				case DOWN:
				
					for (i = xmin; i <= xmax; i++) {
						if (!isFree(i + DOWN_POINT.x, ymin + DOWN_POINT.y) && objectAt(i + DOWN_POINT.x, ymin + DOWN_POINT.y) != obj) {
						//	ObjectFactory.effect(null, "squarefalse", true, 1000, new Point((i + DOWN_POINT.x) * _scaleX, (ymin + DOWN_POINT.y) * _scaleY)); 
							return false;
						//} else {
						//	ObjectFactory.effect(null, "square", true, 1000, new Point((i + DOWN_POINT.x) * _scaleX, (ymin + DOWN_POINT.y) * _scaleY)); 
						}
					}
					break;
					
				case LEFT:
				
					for (j = ymin; j <= ymax; j++) {
						if (!isFree(xmin + LEFT_POINT.x, j + LEFT_POINT.y) && objectAt(xmin + LEFT_POINT.x, j + LEFT_POINT.y) != obj) {
						//	ObjectFactory.effect(null, "squarefalse", true, 1000, new Point((xmin + LEFT_POINT.x) * _scaleX, (j + LEFT_POINT.y) * _scaleY)); 
							return false;
						//} else {
						//	ObjectFactory.effect(null, "square", true, 1000, new Point((xmin + LEFT_POINT.x) * _scaleX, (j + LEFT_POINT.y) * _scaleY)); 
						}
					}
					break;
					
				case RIGHT:
				
					for (j = ymin; j <= ymax; j++) {
						if (!isFree(xmax + RIGHT_POINT.x, j + RIGHT_POINT.y) && objectAt(xmax + RIGHT_POINT.x, j + RIGHT_POINT.y) != obj) {
						//	ObjectFactory.effect(null, "squarefalse", true, 1000, new Point((xmax + RIGHT_POINT.x) * _scaleX, (j + RIGHT_POINT.y) * _scaleY));
							return false;
						//} else {
						//	ObjectFactory.effect(null, "square", true, 1000, new Point((xmax + RIGHT_POINT.x) * _scaleX, (j + RIGHT_POINT.y) * _scaleY)); 
						}
					}
					break;
					
				case LEFT_DOUBLE:
				
					for (j = ymin; j <= ymax; j++) if (!isFree(xmin + LEFT_DOUBLE_POINT.x, j + LEFT_DOUBLE_POINT.y) && objectAt(xmin + LEFT_DOUBLE_POINT.x, j + LEFT_DOUBLE_POINT.y) != obj) return false;
					break;
					
				case RIGHT_DOUBLE:
				
					for (j = ymin; j <= ymax; j++) if (!isFree(xmax + RIGHT_DOUBLE_POINT.x, j + RIGHT_DOUBLE_POINT.y) && objectAt(xmax + RIGHT_DOUBLE_POINT.x, j + RIGHT_DOUBLE_POINT.y) != obj) return false;
					break;
					
			}
			
			return true;
			
		}
		
		//
		//
		public function canSee (subject:PlayObjectControllable, object:PlayObject):Boolean {
	
			return !isObjectBetween(subject, object, subject.sightPoint.worldX, subject.sightPoint.worldY, object.object.worldX, object.object.worldY);
			
		}

		//
		//
		public function canWalk (obj:PlayObjectMovable, direction:uint):Boolean {
			
			var c:Point = coordinatesFor(obj.standPoint.worldX, obj.standPoint.worldY);
			var d:Point = getDirectionPoint(direction);

			return ((!isFree(c.x + d.x, c.y + d.y) || !isFree(c.x + d.x, c.y + d.y - 1)) && canMove(obj, direction));
			
		}
		
		//
		//
		public function canSlide (obj:PlayObject, direction:uint):Boolean {
			
			if (canMove(obj, direction)) {
				
				var c:Point = coordinatesFor(obj.object.x, obj.object.y - obj.object.height / 2);
				var d:Point = getDirectionPoint(direction);

				c.y -= 1;

				return ((!isFree(c.x + d.x, c.y + d.y) || !isFree(c.x + d.x, c.y + d.y - 1)) && canMove(obj, direction));
				
			}
			
			return false;
			
		}
		
		//
		//
		public function canJump (obj:PlayObjectMovable, direction:uint):Boolean {
			
			var c:Point = coordinatesFor(obj.standPoint.worldX, obj.standPoint.worldY);
			var d:Point = getDirectionPoint(direction);

			return (!isFree(c.x + d.x * 3, c.y + d.y) && canMove(obj, direction));
			
		}
		
		//
		//
		public function isStanding (obj:PlayObjectMovable):Boolean {
			
			var c:Point = coordinatesFor(obj.standPoint.worldX, obj.standPoint.worldY);

			return (!isFree(c.x, c.y));
			
		}
		
		//
		//
		public function inOccupiedCell (obj:PlayObject, checkBounce:Boolean = false):Boolean {
			
			var c:Point = coordinatesFor(obj.object.x, obj.object.y);

			if (!checkBounce) return !isFree(c.x, c.y);
			else {
				var obj:PlayObject = objectAt(c.x, c.y) as PlayObject;
				if (obj != null && obj.simObject != null && obj.simObject.collisionObject.reactionType == ReactionType.BOUNCE) {
					return true;
				}
			}
			
			return false;
			
		}
		
		//
		//
		override public function pointInOccupiedCell(pt:Point, self:Object = null):Boolean 
		{
			if (super.pointInOccupiedCell(pt)) {
				var c:Point = coordinatesFor(pt.x, pt.y);
				var obj:PlayObject = objectAt(c.x, c.y) as PlayObject;
				if (obj != null && self != null && self == obj) return false;
				if (obj != null && obj.simObject != null && obj.simObject.collisionObject.reactionType == ReactionType.BOUNCE) {
					return true;
				}
			}
			
			return false;
			
		}
		
		//
		//
		public function objectInSameCellAs (obj:PlayObject):PlayObject {
			
			var c:Point = coordinatesFor(obj.object.worldX, obj.object.worldY);

			return PlayObject(objectAt(c.x, c.y));
			
		}
		
		//
		//
		public function getDirectionPoint (direction:uint):Point {
			
			switch (direction) {
				
				case UP:
					return UP_POINT;
					
				case DOWN:
					return DOWN_POINT;
					
				case LEFT:
					return LEFT_POINT;
					
				case RIGHT:
					return RIGHT_POINT;
					
				case LEFT_DOUBLE:
					return LEFT_DOUBLE_POINT;
				
				case RIGHT_DOUBLE:
					return RIGHT_DOUBLE_POINT;
				
			}
			
			return new Point(0, 0);
			
		}
		
		public function analyzeMapping (obj:PlayObject, buttress:Boolean = false):void {
			
			if (obj.simObject.collisionObject.type == CollisionObject.POLYGON) {
				
				var i:int;
				var j:int;
				
				var d:Shape = new Shape();
				var g:Graphics = d.graphics;
				
				var polygon:CollisionObject = obj.simObject.collisionObject;
				
				g.beginFill(0xff0000);
				
				var pt:Point = Point(polygon.vertices[0]);
				g.moveTo(pt.x, 0 - pt.y);
				
				for (i = 1; i <= polygon.vertices.length - 1; i++) {
				
					pt = polygon.vertices[i - 1];
					
					if (polygon.connections[i] == true && polygon.connections[i - 1] == true) {
						
						g.lineTo(pt.x, 0 - pt.y);
						
					} else {
						
						g.endFill();
						g.moveTo(pt.x, 0 - pt.y);
						g.beginFill(0xff0000);
					}
					
				}

				pt = Point(polygon.vertices[polygon.vertices.length - 1]);
				g.lineTo(pt.x, 0 - pt.y);
				g.endFill();
				
				var chk:Sprite = new Sprite();
				chk.addChild(d);
				chk.visible = false;
				Main.mainStage.addChild(chk);
				
				d.rotation = obj.object.rotation * Geom2d.rtd;
				
				var w:int = Math.round(chk.width / _scaleX);
				var h:int = Math.round(chk.height / _scaleY);
				
				var coord:Point = coordinatesFor(obj.object.x, obj.object.y);
				
				//trace("analyzing object", pt, w, h);
				
				var o:Point = new Point(_scaleX / 2, _scaleY / 2);
				
				var hit:Boolean;
				
				for (j = 0; j < w; j++) {
					
					for (i = 0; i < w; i++) {
						
						var ox:Number = 0 - chk.width / 2 + o.x + (i * _scaleX);
						var oy:Number = 0 - chk.height / 2 + o.y + (j * _scaleX);
						
						hit = chk.hitTestPoint(ox, 0 - oy, true);
						
						if (hit) {
								
							if (buttress) _playfield.simulation.addObject(new DummyObject(_playfield.simulation, obj.object.x + ox, obj.object.y + oy, 60, 60));
						
							var c:Point = coordinatesFor(obj.object.x + ox, obj.object.y + oy);
							
							if (objectAt(obj.object.x + ox, obj.object.y + oy) == null) {
								
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
								
							}
							
						}
						
					}					
					
				}
				
				Main.mainStage.removeChild(chk);
				
				/* DEBUG
				chk.scaleX = chk.scaleY = 0.1;
				chk.visible = true;
				chk.x = (obj.object.x + ox) / 10 + 320;
				chk.y = (0 - (obj.object.y + oy)) / 10 + 117;
				*/
				
			}
			
		}
		
	}
	
}