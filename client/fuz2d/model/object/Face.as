/**
* Fuz3d: 3d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.model.object {

	import flash.geom.Point;
	
	import fuz2d.model.material.*;
	import fuz2d.util.NodeSet;
	
	public class Face extends Object2d {
		
		public var uvCoords:UVCoords;
		
		//
		protected var _nodes:NodeSet;
		public function get nodes ():NodeSet { return _nodes; }
			
		//
		//
		public function Face (parentObject:Point2d, x:Number, y:Number, scale:Number, material:Material, points:Array, nodes:NodeSet = null, flip:Boolean = false, renderable:Boolean = true, uvCoords:UVCoords = null) {
		
			super(parentObject, x, y, scale);

			for each (var pt:Point2d in points) if (pt is Point2d) addPoint(pt);
			
			_nodes = nodes;

			if (material == null) {
				_material = new Material();
			} else {
				_material = material;
			}
			
			_renderable = renderable;

			if (uvCoords != null) this.uvCoords = uvCoords;
			
		}	
		
	}
	
}
