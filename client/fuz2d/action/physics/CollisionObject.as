/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.physics {

	import flash.display.Sprite;
	import flash.geom.Point;
	import fuz2d.screen.View;

	import fuz2d.util.ShrinkWrap;
	import fuz2d.util.NodeSet;
	
	import fuz2d.model.object.*;
	
	public class CollisionObject {
		
		protected var _obj:SimulationObject;
		public function get simObjectRef ():SimulationObject { return _obj; }

		public static const POINT:uint = 1;
		public static const LINE:uint = 2;
		public static const CIRCLE:uint = 3;
		public static const CAPSULE:uint = 4;
		public static const OBB:uint = 5;
		public static const POLYGON:uint = 6;
		public static const POLYGON2:uint = 7;
		public static const BOX:uint = 8;
		public static const RAMP:uint = 9;
		public static const STAIR:uint = 10;
		
		private var _type:uint;
		public function get type ():uint { return _type };
		public function set type(value:uint):void { _type = value; }
		
		private var _reactionType:uint;
		public function get reactionType():uint { return _reactionType; }
		public function set reactionType(value:uint):void { _reactionType = value; }
		
		public var collideOnlyStatic:Boolean = false;
		public var ignoreFocusObj:Boolean = false;
	
		public var radius:Number;
		public var minRadius:Number;
		public var maxRadius:Number;
		
		public var dimX:Number = 0;
		public var dimY:Number = 0;
		
		public var halfX:Number = 0;
		public var halfY:Number = 0;

		public var a:Point;
		public var b:Point;
		
		public function get direction ():Vector2d {
			return (simObjectRef != null) ? simObjectRef.orientation : null;
		}
		
		public function get position ():Vector2d {
			return (simObjectRef != null) ? simObjectRef.position : null;
		}
		
		public function get offset ():Number {
			return (simObjectRef != null) ? simObjectRef.position.magnitude : 0;
		}
		
		protected var _vertices:Array;
		public function get vertices():Array { return _vertices; }
		
		protected var _connections:Array;
		public function get connections():Array { return _connections; }
		
		//
		//
		public function CollisionObject (simObj:SimulationObject, type:uint = POINT, reactionType:uint = 1, collideOnlyStatic:Boolean = false, vertices:Array = null, connections:Array = null) {

			_obj = simObj;
			_type = type;
			_reactionType = reactionType;
			
			this.collideOnlyStatic = collideOnlyStatic;
			
			if (_reactionType == ReactionType.BOUNCE_ALL_BUT_FOCUSOBJ) {
				ignoreFocusObj = true;
				_reactionType = ReactionType.BOUNCE;
			}
			
			_vertices = vertices;
			_connections = connections;
			
			if (_obj != null && _obj.objectRef != null) {
				init();
				setObjectProps();
			}
			
		}
		
		//
		//
		private function init ():void {
			
			// set radius for all early outs
			
			switch (type) {
				
				case LINE:
				
					if (_obj.objectRef is Line2d) {
						radius = minRadius = maxRadius = dimY / 2;
					}
					break;
					
				case CIRCLE: 
				
					radius = minRadius = maxRadius = Math.max(_obj.objectRef.width, _obj.objectRef.height) * 0.5;
					dimX = dimY = radius * 2;
					break;
					
				case CAPSULE: 
				
					dimX = _obj.objectRef.width;
					dimY = _obj.objectRef.height;
					radius = maxRadius = Math.max(dimX, dimY) * 0.5;
					minRadius = Math.min(dimX, dimY) * 0.5;
					break;
					
				case OBB:
				case BOX:
				case RAMP:
				case STAIR:
				
					dimX = _obj.objectRef.width;
					dimY = _obj.objectRef.height;				
					radius = maxRadius = Math.max(dimX, dimY) * 0.5;
					minRadius = Math.min(dimX, dimY) * 0.5;
					break;
					
				case POLYGON:
				case POLYGON2:
				
					dimX = _obj.objectRef.width;
					dimY = _obj.objectRef.height;	
					
					if (_obj.objectRef is Symbol) {
					
						var s:Symbol = Symbol(_obj.objectRef);
						
						var c:Sprite = s.clip;
						c.x = View.mainStage.stageWidth * 0.5;
						c.y = View.mainStage.stageHeight * 0.5;
						
						if (false && _vertices == null) {
							
							View.mainStage.addChild(c);
							
							var w:ShrinkWrap = new ShrinkWrap(c, -5);

							View.mainStage.removeChild(c);
							
							_vertices = w.bounds.concat();

							for each (var pt:Point in _vertices) pt.y = 0 - pt.y;
						
						}
						
					} else {
						
						_vertices = [];
						_connections = [];
						
					}
					
					break;
					
				default:
					break;
				
			}
			
			halfX = dimX * 0.5;
			halfY = dimY * 0.5;
			
		}
		
		//
		//
		public function setObjectProps ():void {
			
			switch (type) {
				
				case LINE:
				
					var line:Line2d = Line2d(simObjectRef.objectRef);
				
					a = new Point(line.startPoint.x, line.startPoint.y);
					b = new Point(line.endPoint.x, line.endPoint.y);

					break;
					
				
			}
			
		}
		
		public static function parseType (type:String):uint {
			
			switch (type) {
				
				case "POINT": return 1;
				case "LINE": return 2;
				case "CIRCLE": return 3;
				case "CAPSULE": return 4;
				case "OBB": return 5;
				case "POLYGON": return 6;
				case "POLYGON2": return 7;
				case "BOX": return 8;
				case "RAMP": return 9;
				case "STAIR": return 10;
				
				default: return 1;
				
			}
			
		}

	}
	
}
