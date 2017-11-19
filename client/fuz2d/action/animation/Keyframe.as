/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.animation {

	public class Keyframe {
		
		private var _frame:uint;
		
		public function get frame ():uint {
			return _frame;
		}
		public function set frame (val:uint):void {
			_frame = (!isNaN(val)) ? val : _frame;
		}
		
		public var attributes:Object;
		
		//
		//
		public function Keyframe(frame:uint, attributes:Object) {
			
			_frame = frame;
			_attributes = {};
			
			if (attributes != undefined) {
				for (attrib:String in attributes) {
					_attributes[attrib] = attributes[attrib];
				}
			}
			
		}
		
	}
	
}
