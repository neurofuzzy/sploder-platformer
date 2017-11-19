package fuz2d.action.physics 
{
	import fuz2d.model.object.Object2d;
	
	/**
	 * ...
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public class DummyObject extends SimulationObject {
		
		public function DummyObject (simulation:Simulation, x:Number, y:Number, width:Number, height:Number) {
			
			var obj:Object2d = new Object2d(null, x, y);
			obj.symbolName = "_dummy";

			obj.width = width;
			obj.height = height;
			
			super(simulation, obj, CollisionObject.OBB, ReactionType.BOUNCE);

		}
		
	}
	
}