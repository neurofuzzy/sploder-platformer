/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.physics {

	public class Contact {
		
		public static const POINT_POINT:int = 1;
		
		public static const EDGE_POINT:int = 21;
		public static const EDGE_EDGE:int = 22;
		
		public static const FACE_POINT:int = 31;
		public static const FACE_EDGE:int = 32;
		public static const FACE_FACE:int = 33;
		
		public var position:Vector2d;
		public var normal:Vector2d;
		public var penetration:Number;
		
		public function Contact (objA:CollisionObject, objB:CollisionObject, contactPoint:Vector2d, normal:Vector2d, invert:Boolean = false) 
			
			this.position = position;
			this.normal = normal;
			this.penetration = penetration;
			
		}
		
	}
	
}
