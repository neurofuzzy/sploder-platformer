package com.sploder.texturegen_internal.util
{
	import flash.display.BitmapData;
	
	public class PerlinNoise
	{		
		protected var baseFactor:Number;
		protected var iZoffset:Number;
		protected var iYoffset:Number;
		protected var iXoffset:Number;
		protected var fPersMax:Number;
		protected var aOctPers:Array;
		protected var aOctFreq:Array;
		protected var octaves:int;
		protected static var P:Array = [151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23, 190, 6, 148, 247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33, 88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134, 139, 48, 27, 166, 77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41, 55, 46, 245, 40, 244, 102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169, 200, 196, 135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64, 52, 217, 226, 250, 124, 123, 5, 202, 38, 147, 118, 126, 255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42, 223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43, 172, 9, 129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104, 218, 246, 97, 228, 251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162, 241, 81, 51, 145, 235, 249, 14, 239, 107, 49, 192, 214, 31, 181, 199, 106, 157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254, 138, 236, 205, 93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180, 151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23, 190, 6, 148, 247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33, 88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134, 139, 48, 27, 166, 77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41, 55, 46, 245, 40, 244, 102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169, 200, 196, 135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64, 52, 217, 226, 250, 124, 123, 5, 202, 38, 147, 118, 126, 255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42, 223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43, 172, 9, 129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104, 218, 246, 97, 228, 251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162, 241, 81, 51, 145, 235, 249, 14, 239, 107, 49, 192, 214, 31, 181, 199, 106, 157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254, 138, 236, 205, 93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180];

		
		public function PerlinNoise(seed:* = null, octaves:* = null, falloff:* = null, baseFactor:* = null):void
		{
			
			if (seed == null)
				seed = 123;
			if (falloff == null)
				falloff = .5;
			this.octaves = ((octaves == null) ? 4 : octaves);
			if (baseFactor == null)
				baseFactor = 0.015625;
			this.baseFactor = baseFactor;
			this.seedOffset(seed);
			this.octFreqPers(falloff);
		}
		
		protected function seedOffset(iSeed:int):void
		{
			this.iXoffset = iSeed = (iSeed * 16807. % 2147483647);
			this.iYoffset = iSeed = (iSeed * 16807. % 2147483647);
			this.iZoffset = iSeed = (iSeed * 16807. % 2147483647);
		}
		
		protected function octFreqPers(fPersistence:Number):void
		{
			var fFreq:Number, fPers:Number;
			this.aOctFreq = [];
			this.aOctPers = [];
			this.fPersMax = 0;
			{
				var _g1:int = 0, _g:int = this.octaves;
				while (_g1 < _g)
				{
					var i:int = _g1++;
					fFreq = Math.pow(2, i);
					fPers = Math.pow(fPersistence, i);
					this.fPersMax += fPers;
					this.aOctFreq.push(fFreq);
					this.aOctPers.push(fPers);
				}
			}
			this.fPersMax = 1 / this.fPersMax;
		}
		
		public function fill(bitmap:flash.display.BitmapData, _x:Number, _y:Number, _z:Number, brightnessOffset:int = 0):void
		{
			var baseX:Number;
			baseX = _x * this.baseFactor + this.iXoffset;
			_y = _y * this.baseFactor + this.iYoffset;
			_z = _z * this.baseFactor + this.iZoffset;
			var width:int = bitmap.width;
			var height:int = bitmap.height;
			var p:Array = PerlinNoise.P;
			var octaves:int = this.octaves;
			var aOctFreq:Array = this.aOctFreq;
			var aOctPers:Array = this.aOctPers;
			{
				var _g:int = 0;
				while (_g < height)
				{
					var py:int = _g++;
					_x = baseX;
					{
						var _g1:int = 0;
						while (_g1 < width)
						{
							var px:int = _g1++;
							var s:Number = 0.;
							{
								var _g2:int = 0;
								while (_g2 < octaves)
								{
									var i:int = _g2++;
									var fFreq:Number = aOctFreq[i];
									var fPers:Number = aOctPers[i];
									var x:Number = _x * fFreq;
									var y:Number = _y * fFreq;
									var z:Number = _z * fFreq;
									var xf:Number = x - x % 1;
									var yf:Number = y - y % 1;
									var zf:Number = z - z % 1;
									var X:int = (xf) & 255;
									var Y:int = (yf) & 255;
									var Z:int = (zf) & 255;
									x -= xf;
									y -= yf;
									z -= zf;
									var u:Number = x * x * x * (x * (x * 6 - 15) + 10);
									var v:Number = y * y * y * (y * (y * 6 - 15) + 10);
									var w:Number = z * z * z * (z * (z * 6 - 15) + 10);
									var A:int = p[X] + Y;
									var AA:int = p[A] + Z;
									var AB:int = p[A + 1] + Z;
									var B:int = p[X + 1] + Y;
									var BA:int = p[B] + Z;
									var BB:int = p[B + 1] + Z;
									var x1:Number = x - 1;
									var y1:Number = y - 1;
									var z1:Number = z - 1;
									var hash:int = p[BB + 1] & 15;
									var g1:Number = ((((hash & 1) == 0) ? ((hash < 8) ? x1 : y1) : ((hash < 8) ? -x1 : -y1))) + ((((hash & 2) == 0) ? ((hash < 4) ? y1 : ((hash == 12) ? x1 : z1)) : ((hash < 4) ? -y1 : ((hash == 14) ? -x1 : -z1))));
									hash = (p[AB + 1] & 15);
									var g2:Number = ((((hash & 1) == 0) ? ((hash < 8) ? x : y1) : ((hash < 8) ? -x : -y1))) + ((((hash & 2) == 0) ? ((hash < 4) ? y1 : ((hash == 12) ? x : z1)) : ((hash < 4) ? -y1 : ((hash == 14) ? -x : -z1))));
									hash = (p[BA + 1] & 15);
									var g3:Number = ((((hash & 1) == 0) ? ((hash < 8) ? x1 : y) : ((hash < 8) ? -x1 : -y))) + ((((hash & 2) == 0) ? ((hash < 4) ? y : ((hash == 12) ? x1 : z1)) : ((hash < 4) ? -y : ((hash == 14) ? -x1 : -z1))));
									hash = (p[AA + 1] & 15);
									var g4:Number = ((((hash & 1) == 0) ? ((hash < 8) ? x : y) : ((hash < 8) ? -x : -y))) + ((((hash & 2) == 0) ? ((hash < 4) ? y : ((hash == 12) ? x : z1)) : ((hash < 4) ? -y : ((hash == 14) ? -x : -z1))));
									hash = (p[BB] & 15);
									var g5:Number = ((((hash & 1) == 0) ? ((hash < 8) ? x1 : y1) : ((hash < 8) ? -x1 : -y1))) + ((((hash & 2) == 0) ? ((hash < 4) ? y1 : ((hash == 12) ? x1 : z)) : ((hash < 4) ? -y1 : ((hash == 14) ? -x1 : -z))));
									hash = (p[AB] & 15);
									var g6:Number = ((((hash & 1) == 0) ? ((hash < 8) ? x : y1) : ((hash < 8) ? -x : -y1))) + ((((hash & 2) == 0) ? ((hash < 4) ? y1 : ((hash == 12) ? x : z)) : ((hash < 4) ? -y1 : ((hash == 14) ? -x : -z))));
									hash = (p[BA] & 15);
									var g7:Number = ((((hash & 1) == 0) ? ((hash < 8) ? x1 : y) : ((hash < 8) ? -x1 : -y))) + ((((hash & 2) == 0) ? ((hash < 4) ? y : ((hash == 12) ? x1 : z)) : ((hash < 4) ? -y : ((hash == 14) ? -x1 : -z))));
									hash = (p[AA] & 15);
									var g8:Number = ((((hash & 1) == 0) ? ((hash < 8) ? x : y) : ((hash < 8) ? -x : -y))) + ((((hash & 2) == 0) ? ((hash < 4) ? y : ((hash == 12) ? x : z)) : ((hash < 4) ? -y : ((hash == 14) ? -x : -z))));
									g2 += u * (g1 - g2);
									g4 += u * (g3 - g4);
									g6 += u * (g5 - g6);
									g8 += u * (g7 - g8);
									g4 += v * (g2 - g4);
									g8 += v * (g6 - g8);
									s += (g8 + w * (g4 - g8)) * fPers;
								}
							}
							var color:int = ((s * this.fPersMax + 1) * 128);
							if (brightnessOffset != 0)
								color = Math.floor(Math.min(255, Math.max(0, color + brightnessOffset)));
							bitmap.setPixel32(px, py, ((-16777216 | color << 16) | color << 8) | color);
							_x += this.baseFactor;
						}
					}
					_y += this.baseFactor;
				}
			}
		}
	}
}
