package fuz2d.util 
{
	import fuz2d.action.physics.Vector2d;
	/**
	 * ...
	 * @author Geoff Gaudreault
	 */
	public class ClosestSegmentResult 
	{
		public var s:Number;
		public var t:Number;
		public var c1:Vector2d;
		public var c2:Vector2d;
		public var dist:Number;
			
		public function ClosestSegmentResult() 
		{
			
		}
		
		public function init (c1:Vector2d, c2:Vector2d, dist:Number, s:Number, t:Number):void
		{
			this.c1 = c1;
			this.c2 = c2;
			this.dist = dist;
			this.s = s;
			this.t = t;
		}
		
	}

}