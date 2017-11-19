/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.physics {

	public class CollisionType {
		
		public static const NONE:uint = 0;
		
		public static const POINT_POINT:uint = 11;
		
		public static const LINE_POINT:uint = 21;
		public static const LINE_LINE:uint = 22;
		
		public static const CIRCLE_POINT:uint = 31;
		public static const CIRCLE_LINE:uint = 32;
		public static const CIRCLE_CIRCLE:uint = 33;
		
		public static const CAPSULE_POINT:uint = 41;
		public static const CAPSULE_LINE:uint = 42;
		public static const CAPSULE_CIRCLE:uint = 43;
		public static const CAPSULE_CAPSULE:uint = 44;
		
		public static const OBB_POINT:uint = 51;
		public static const OBB_LINE:uint = 52;
		public static const OBB_CIRCLE:uint = 53;
		public static const OBB_CAPSULE:uint = 54;
		public static const OBB_OBB:uint = 55;
		
		public static const POLYGON_POINT:uint = 61;
		public static const POLYGON_LINE:uint = 62;
		public static const POLYGON_CIRCLE:uint = 63;
		public static const POLYGON_CAPSULE:uint = 64;
		public static const POLYGON_OBB:uint = 65;
		public static const POLYGON_POLYGON:uint = 66;
		
		public static const POLYGON2_CIRCLE:uint = 73;
		public static const POLYGON2_CAPSULE:uint = 74;
		
		public static const BOX_POINT:uint = 81; 
		public static const BOX_LINE:uint = 82;
		public static const BOX_CIRCLE:uint = 83;
		public static const BOX_CAPSULE:uint = 84;
		public static const BOX_OBB:uint = 85;
		public static const BOX_POLYGON:uint = 86;
		public static const BOX_BOX:uint = 87;
		
		public static const RAMP_CIRCLE:uint = 93;
		public static const RAMP_CAPSULE:uint = 94;
		
		public static const STAIR_CIRCLE:uint = 103;
		public static const STAIR_CAPSULE:uint = 104;
		
		
		public static function getType (objA:CollisionObject, objB:CollisionObject):uint {
			
			if (objA.type > objB.type) {
				
				return (objA.type * 10) + objB.type;
				
			} else {
				
				return (objB.type * 10) + objA.type;
				
			}
			
		}
		
	}
	
}
