package com.sploder {
    /*
     * USAGE:
     *
     * import com.sploder.SignString;
     * var sig:String = SignString.sign("id=1&score=200");
     *
     */
    
    
    public class SignString {

    
        private static var cap:Boolean = false;
        private static var radix:Number = 8;
        
        public static var sA:String = '098e7fe5f0e70987fadfe00e70897dcd';
        public static var sB:String = 'd97f6cd9876fcd4d564f7d654fadf967';
        
        //
        //
        public static function sign (urlString:String):String {
            
            return f15(urlString);
        
        }
    
        //
        //
        private static function f1 (s:String):String {
            
            return f4(f3(f2(s), s.length * radix));
            
        }
        
        //
        //
        private static function f2 (x1:String):Array {
            
            var l1:Array = [];
            var l2:Number = (1 << radix) - 1;
            
            for(var i:uint = 0; i < x1.length * radix; i += radix) {
                l1[i >> 5] |= (x1.charCodeAt(i / radix) & l2) << (i % 32);
            }
            
            return l1;
          
        }
        
        //
        //
        private static function f3 (x:Array, x4:Number):Array {
            
          x[x4 >> 5] |= 0x80 << ((x4) % 32);
          x[(((x4 + 64) >>> 9) << 4) + 14] = x4;
    
          var a:Number =  1732584193;
          var b:Number = -271733879;
          var c:Number = -1732584194;
          var d:Number =  271733878;
    
          for (var i:Number = 0; i < x.length; i += 16)  {
              
            var z:Number = a;
            var y:Number = b;
            var q:Number = c;
            var w:Number = d;
    
            a = f5(a, b, c, d, x[i+ 0], 7 , -680876936);
            d = f5(d, a, b, c, x[i+ 1], 12, -389564586);
            c = f5(c, d, a, b, x[i+ 2], 17,  606105819);
            b = f5(b, c, d, a, x[i+ 3], 22, -1044525330);
            a = f5(a, b, c, d, x[i+ 4], 7 , -176418897);
            d = f5(d, a, b, c, x[i+ 5], 12,  1200080426);
            c = f5(c, d, a, b, x[i+ 6], 17, -1473231341);
            b = f5(b, c, d, a, x[i+ 7], 22, -45705983);
            a = f5(a, b, c, d, x[i+ 8], 7 ,  1770035416);
            d = f5(d, a, b, c, x[i+ 9], 12, -1958414417);
            c = f5(c, d, a, b, x[i+10], 17, -42063);
            b = f5(b, c, d, a, x[i+11], 22, -1990404162);
            a = f5(a, b, c, d, x[i+12], 7 ,  1804603682);
            d = f5(d, a, b, c, x[i+13], 12, -40341101);
            c = f5(c, d, a, b, x[i+14], 17, -1502002290);
            b = f5(b, c, d, a, x[i+15], 22,  1236535329);
    
            a = f6(a, b, c, d, x[i+ 1], 5 , -165796510);
            d = f6(d, a, b, c, x[i+ 6], 9 , -1069501632);
            c = f6(c, d, a, b, x[i+11], 14,  643717713);
            b = f6(b, c, d, a, x[i+ 0], 20, -373897302);
            a = f6(a, b, c, d, x[i+ 5], 5 , -701558691);
            d = f6(d, a, b, c, x[i+10], 9 ,  38016083);
            c = f6(c, d, a, b, x[i+15], 14, -660478335);
            b = f6(b, c, d, a, x[i+ 4], 20, -405537848);
            a = f6(a, b, c, d, x[i+ 9], 5 ,  568446438);
            d = f6(d, a, b, c, x[i+14], 9 , -1019803690);
            c = f6(c, d, a, b, x[i+ 3], 14, -187363961);
            b = f6(b, c, d, a, x[i+ 8], 20,  1163531501);
            a = f6(a, b, c, d, x[i+13], 5 , -1444681467);
            d = f6(d, a, b, c, x[i+ 2], 9 , -51403784);
            c = f6(c, d, a, b, x[i+ 7], 14,  1735328473);
            b = f6(b, c, d, a, x[i+12], 20, -1926607734);
    
            a = f7(a, b, c, d, x[i+ 5], 4 , -378558);
            d = f7(d, a, b, c, x[i+ 8], 11, -2022574463);
            c = f7(c, d, a, b, x[i+11], 16,  1839030562);
            b = f7(b, c, d, a, x[i+14], 23, -35309556);
            a = f7(a, b, c, d, x[i+ 1], 4 , -1530992060);
            d = f7(d, a, b, c, x[i+ 4], 11,  1272893353);
            c = f7(c, d, a, b, x[i+ 7], 16, -155497632);
            b = f7(b, c, d, a, x[i+10], 23, -1094730640);
            a = f7(a, b, c, d, x[i+13], 4 ,  681279174);
            d = f7(d, a, b, c, x[i+ 0], 11, -358537222);
            c = f7(c, d, a, b, x[i+ 3], 16, -722521979);
            b = f7(b, c, d, a, x[i+ 6], 23,  76029189);
            a = f7(a, b, c, d, x[i+ 9], 4 , -640364487);
            d = f7(d, a, b, c, x[i+12], 11, -421815835);
            c = f7(c, d, a, b, x[i+15], 16,  530742520);
            b = f7(b, c, d, a, x[i+ 2], 23, -995338651);
    
            a = f8(a, b, c, d, x[i+ 0], 6 , -198630844);
            d = f8(d, a, b, c, x[i+ 7], 10,  1126891415);
            c = f8(c, d, a, b, x[i+14], 15, -1416354905);
            b = f8(b, c, d, a, x[i+ 5], 21, -57434055);
            a = f8(a, b, c, d, x[i+12], 6 ,  1700485571);
            d = f8(d, a, b, c, x[i+ 3], 10, -1894986606);
            c = f8(c, d, a, b, x[i+10], 15, -1051523);
            b = f8(b, c, d, a, x[i+ 1], 21, -2054922799);
            a = f8(a, b, c, d, x[i+ 8], 6 ,  1873313359);
            d = f8(d, a, b, c, x[i+15], 10, -30611744);
            c = f8(c, d, a, b, x[i+ 6], 15, -1560198380);
            b = f8(b, c, d, a, x[i+13], 21,  1309151649);
            a = f8(a, b, c, d, x[i+ 4], 6 , -145523070);
            d = f8(d, a, b, c, x[i+11], 10, -1120210379);
            c = f8(c, d, a, b, x[i+ 2], 15,  718787259);
            b = f8(b, c, d, a, x[i+ 9], 21, -343485551);
    
            a = f9(a, z);
            b = f9(b, y);
            c = f9(c, q);
            d = f9(d, w);
          }
          
          return new Array(a, b, c, d);
    
        }
    
        //
        //
        private static function f4 (x1:Array):String {
            
          var l1:String = cap ? "0123456789ABCDEF" : "0123456789abcdef";
          var l2:String = "";
          
          for (var i:Number = 0; i < x1.length * 4; i++)  {
              
            l2 += l1.charAt((x1[i>>2] >> ((i%4)*8+4)) & 0xF) + l1.charAt((x1[i >> 2] >> ((i % 4) * 8  )) & 0xF);
               
          }
          
          return l2;
          
        }
        
        //
        //
        private static function f5(a:Number, b:Number, c:Number, d:Number, x:Number, s:Number, t:Number):Number {
          return f10((b & c) | ((~b) & d), a, b, x, s, t);
        }
        
        //
        //
        private static function f6(a:Number, b:Number, c:Number, d:Number, x:Number, s:Number, t:Number):Number {
          return f10((b & d) | (c & (~d)), a, b, x, s, t);
        }
        
        //
        //
        private static function f7(a:Number, b:Number, c:Number, d:Number, x:Number, s:Number, t:Number):Number {
          return f10(b ^ c ^ d, a, b, x, s, t);
        }
        
        //
        //
        private static function f8 (a:Number, b:Number, c:Number, d:Number, x:Number, s:Number, t:Number):Number {
          return f10(c ^ (b | (~d)), a, b, x, s, t);
        }
        
        //
        //
        private static function f9 (x:Number, y:Number):Number {
            
          var l1:Number = (x & 0xFFFF) + (y & 0xFFFF);
          var l2:Number = (x >> 16) + (y >> 16) + (l1 >> 16);
          
          return (l2 << 16) | (l1 & 0xFFFF);
          
        }
    
        private static function f10(q:Number, a:Number, b:Number, x:Number, s:Number, t:Number):Number {
            
          return f9(f11(f9(f9(a, q), f9(x, t)), s), b);
          
        }
        
        //
        //
        private static function f11 (x1:Number, x2:Number):Number {
          return (x1 << x2) | (x1 >>> (32 - x2));
        }
        
        //
        //
        private static function f14 ():void {

            sA = f1(sB);
        }
        
        //
        //
        private static function f15(x1:String):String {
            return f1(x1 + sA);
        }
    
    }
}
