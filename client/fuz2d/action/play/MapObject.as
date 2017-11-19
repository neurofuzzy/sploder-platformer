/**
* ...
* @author Default
* @version 0.1
*/

package fuz2d.action.play {
	
	import fuz2d.Fuz2d;

	import fuz2d.action.control.*;
	import fuz2d.action.physics.*;
	import fuz2d.action.play.*;
	
	import fuz2d.model.*;
	import fuz2d.model.object.*;
	
	import fuz2d.util.Geom2d;

	public class MapObject extends ObjectTemplate {

		protected var _model:Model;
		protected var _simulation:Simulation;
		
		//
		//
		public function MapObject (type:String, creator:Object, main:Fuz2d, def:ObjectDefinition) {
			
			super(type, creator, main, def);
			
			_model = main.model;
			_simulation = main.simulation;
			
		}
		
		//
		//
		override protected function create():void {
			
			_modelObjectRef = _def.newModelObject();
			_simObjectRef = _def.newSimulationObject();
			
			_modelObjectRef.simObject = _simObjectRef;

		}
		
	}
	
}
