package fuz2d.util 
{
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class MathUtils {
		
		public static function getNextHighestPowerOf2 (v:Number):int {
			
			v--;
			v |= v >> 1;
			v |= v >> 2;
			v |= v >> 4;
			v |= v >> 8;
			v |= v >> 16;
			v++;
			
			return v;
						
		}
		
		
	}
	
}