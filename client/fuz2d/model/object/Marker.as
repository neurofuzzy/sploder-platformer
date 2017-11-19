/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.model.object  {

	import fuz2d.model.environment.*;
	import fuz2d.model.material.*;
	
	public class Marker extends Object2d {
		
		private var _markerSize:Number;
		private var _label:String;
		
		public var alwaysOnTop:Boolean = false;

		//
		//
		public function Marker (parentObject:Point2d = null, size:Number = NaN, label:String = "", x:Number = 0, y:Number = 0, z:Number = 0, scale:Number = 1, material:Material = null) {
			
			super(parentObject, x, y, z, 0, scale);
			
			_markerSize = (!isNaN(size)) ? size : (_parentObject is Object2d) ? Math.max(6, Object2d(_parentObject).width, Object2d(_parentObject).height) * 0.5 : 3;
			
			_label = label;

			if (material == null) {
				_material = new Material();
			} else {
				_material = material;
			}
			
			_renderable = true;
			_zSortChildNodes = false;
			
			idx = z;
			
		}
		
		public function get markerSize():Number { return _markerSize; }
		
		public function set markerSize(value:Number):void 
		{
			_markerSize = value;
		}
		
		public function get label():String { return _label; }
		
		public function set label(value:String):void 
		{
			_label = value;
		}
		
	}
	
}
