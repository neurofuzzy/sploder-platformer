package fuz2d.action.physics {
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import fuz2d.Fuz2d;
	import fuz2d.model.Model;
	import fuz2d.model.object.Object2d;
	import fuz2d.model.object.Symbol;
	import fuz2d.util.Map;
	
	/**
	 * ...
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public class BoundsBuilder {
		
		protected static var _boundsObjects:Array;
		public static function get boundsObjects():Array { return _boundsObjects; }
		
		public static function get built ():Boolean { return (_boundsObjects != null); }

		private static var _debug:Boolean = false;
		//
		//
		public static function build (model:Model, simulation:Simulation, gridSize:Number = 60):void {
			
			//trace("BUILDING");
			
			var obj:Object2d;
			var simobj:SimulationObject;
			
			if (_boundsObjects != null) {
				
				if (_boundsObjects.length > 0) {
					
					for each (simobj in _boundsObjects) simulation.removeObject(simobj);

				}
				
			} 
			
			_boundsObjects = [];
			
			var objMap:Map = new Map(gridSize, gridSize);
			
			// register static objects for building ground
			
			for each (obj in model.objects) {
				
				if (obj is Symbol) {
					objMap.register(obj, obj.x, obj.y, Symbol(obj).symbolWidth, Symbol(obj).symbolHeight);
				} else {
					objMap.register(obj, obj.x, obj.y, obj.width, obj.height);
				}
				if (obj.simObject && (obj.simObject is VelocityObject || obj.simObject.collisionObject.reactionType == ReactionType.PASSTHROUGH)) { // affect only bound limits, so remove
					objMap.unregister(obj);
				}
				
			}
			
			var lastY:int = 1;
			var lastJ:int = 0;
			var k:int;
			
			for (var i:int = objMap.minX - 11; i < objMap.minX + objMap.width + 11; i++) {
				
				for (var j:int = objMap.minY - 1; j <= 1; j++) {
					
					lastJ = j;
					
					if (!objMap.isFree(i, j) || j == 1) {
						
						_boundsObjects.push(new DummyObject(simulation, i * gridSize + gridSize * 0.5, (j - 1) * gridSize - gridSize * 0.5, gridSize, gridSize));
						
						if (j != lastY) {
							
							if (j < lastY) {
								
								for (k = j + 1; k <= lastY; k++) {
									
									_boundsObjects.push(new DummyObject(simulation, (i - 1) * gridSize + gridSize * 0.5, (k - 1) * gridSize - gridSize * 0.5, gridSize, gridSize));
												
								}
								
							} else {
								
								for (k = lastY; k <= j - 1; k++) {

									_boundsObjects.push(new DummyObject(simulation, i * gridSize + gridSize * 0.5, (k - 1) * gridSize - gridSize * 0.5, gridSize, gridSize));
												
								}								
								
							}
							
						}
						
						lastY = j;
						
						break;
						
					}
					
				}
				
				//if (lastJ < 1) {
				
					if (objMap.isFree(i, 0)) {
						
						_boundsObjects.push(new DummyObject(simulation, i * gridSize + gridSize * 0.5, 0 - gridSize * 0.5, gridSize, gridSize));
						
					}
					
				//}
				
			}
			
			simulation.setBounds((objMap.minX - 9) * gridSize, (objMap.minX + objMap.width + 9) * gridSize, (objMap.minY - 9) * gridSize, (objMap.minY + objMap.height + 9) * gridSize);			
			
			if (_debug) {
				
				for (var y:int = -100; y < 100; y++) {
					
					for (var x:int = -100; x < 100; x++) {
						
						if (!objMap.isFree(x, y)) {
							
							var g:Graphics = Sprite(Fuz2d.mainInstance.view.viewport.dobj).graphics;
							g.lineStyle(1, 0x00ffff);
							g.drawRect(x * 60, -y * 60, 60, 60);
							
						}
						
					}
					
				}
				
			}
			
		}
		
		public static function clear ():void {
			
			_boundsObjects = null;
			
		}
		
	}
	
}