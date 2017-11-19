package com.sploder.texturegen_internal.util
{
	
	public class PM_PRNG
	{
		public var seed:int;
		
		public function PM_PRNG():void
		{
			this.seed = 1;
		}
		
		public function initWithSeed(seed:int):*
		{
			this.seed = seed;
			nextDouble();
			nextDouble();
			return this;
		}
		
		protected function gen():int
		{
			var hi:int = 16807 * (this.seed >> 16);
			var lo:int = 16807 * (this.seed & 65535) + ((hi & 32767) << 16) + (hi >> 15);
			var g1:int = this.seed = ((lo > 2147483647) ? lo - 2147483647 : lo);
			return ((g1 >= 0) ? g1 : 0 - g1);
		}
		
		public function nextDoubleRange(min:Number, max:Number):Number
		{
			return min + (max - min) * this.nextDouble();
		}
		
		public function nextIntRange(min:Number, max:Number):int
		{
			min -= .4999;
			max += .4999;
			return Math.round(min + (max - min) * this.nextDouble());
		}
		
		public function nextDouble():Number
		{
			return gen() / 2147483647;
		}
		
		public function nextInt():int
		{
			return gen();
		}
	}
}
