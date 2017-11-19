/**
* Fuz3d: 3d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.model.material {
	
	import flash.geom.Matrix;
	
	public class UVCoords {
		
		private var _texture:TextureMap;
		
		public function get texture ():TextureMap { return _texture; }
		public function set texture (obj:TextureMap):void { _texture = (obj != null) ? obj : _texture; }
		
		public var u_a:Number;
		public var v_a:Number;
		
		public var u_b:Number;
		public var v_b:Number;
		
		public var u_c:Number; 
		public var v_c:Number;
		
		public var uvMatrix:Matrix;
		
		public function UVCoords(u_a:Number, v_a:Number, u_b:Number, v_b:Number, u_c:Number, v_c:Number) {
			
			init(u_a, v_a, u_b, v_b, u_c, v_c);
			
		}
		
		private function init (u_a:Number, v_a:Number, u_b:Number, v_b:Number, u_c:Number, v_c:Number):void {
			
			this.u_a = u_a;
			this.v_a = v_a;
			
			this.u_b = u_b;
			this.v_b = v_b;
			
			this.u_c = u_c;
			this.v_c = v_c;
			
		}
		
		//
		//
        public function transformUV ():void {
			
            if (isNaN(u_a) || isNaN(u_b) || isNaN(u_c) || isNaN(v_a) || isNaN(v_b) || isNaN(v_c) || _texture.bitmap == null) return;

            var u0:Number = _texture.width * u_a;
            var u1:Number = _texture.width * u_b;
            var u2:Number = _texture.width * u_c;
            var v0:Number = _texture.height * v_a;
            var v1:Number = _texture.height * v_b;
            var v2:Number = _texture.height * v_c;
      
            // Fix perpendicular projections
            if ((u0 == u1 && v0 == v1) || (u0 == u2 && v0 == v2)) {
                u0 -= (u0 > 0.05) ? 0.05 : -0.05;
                v0 -= (v0 > 0.07) ? 0.07 : -0.07;
            }
    
            if (u2 == u1 && v2 == v1) {
                u2 -= (u2 > 0.05) ? 0.04 : -0.04;
                v2 -= (v2 > 0.06) ? 0.06 : -0.06;
            }
 
            uvMatrix = new Matrix(u1 - u0, v1 - v0, u2 - u0, v2 - v0, u0, v0);
			uvMatrix.invert();
           
        }
		
	}
	
}
