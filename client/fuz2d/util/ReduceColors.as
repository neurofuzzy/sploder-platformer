package fuz2d.util {

	/**
	 * @author nicoptere
	 */
	 
	import flash.display.*;
	public class ReduceColors 
	{
		
		public static var dither:Boolean = false;
		
		public function ReduceColors(){}
		static public function reduceColors( img:BitmapData, number:int = 16, grayScale:Boolean = false, affectAlpha:Boolean = false ):void
		{
			var i:int;
			var j:int=0;
			
			var val:int = 0;
			
			
			var total:int = 255;
			number -= 2;
			if( number <= 0 ) number = 1;
			if( number >= 255) number = 254;
			
			var step:Number = total / number;
			var offset:Number = ( total - ( total / ( number + 1 ) ) ) / total;
			var values:Array = [];
			for ( i = 0; i < total; i++ )
			{
				
				if( i >= ( j * step * offset ) )
				{
					j++;
				}
				values.push( Math.floor( ( Math.ceil( j*step )-step ) ) );
				
			}
			var a:int;
			var r:int;
			var g:int;
			var b:int;
			var c:int;
			
			var iw:int = img.width;
			var ih:int = img.height;
		
			img.lock();
			
			if( affectAlpha )
			{
				// GRAYSCALE WITH ALPHA AFFECTED
				if( grayScale )
				{
					for ( i = 0; i < iw; i++ )
					{
						for ( j = 0; j < ih; j++ )
						{
							
							val = img.getPixel32( i, j );
							
							a = values[ ( val >>> 24 )- 1 ];
							r = values[ ( val >>> 16 & 0xFF )- 1 ];
							g = values[ ( val >>> 8  & 0xFF )- 1 ];
							b = values[ ( val & 0xFF )- 1 ];
							c = Math.ceil( ( ( r + g + b ) / 3 ) );
							img.setPixel32( i, j, ( a<<24 | c << 16 | c << 8 | c ) );
						
						}
					}
					
				}else{
					
					// COLORS WITH ALPHA AFFECTED
					for ( i = 0; i < iw; i++ )
					{
						for ( j = 0; j < ih; j++ )
						{
							
							val = img.getPixel32( i, j );
							
							a = values[( val >>> 24 )- 1 ];
							r = values[ ( val >>> 16 & 0xFF )- 1 ];
							g = values[ ( val >>> 8  & 0xFF )- 1 ];
							b = values[ ( val & 0xFF )- 1 ];
							
							img.setPixel32( i, j, ( a<<24 | r << 16 | g << 8 | b ) );
						
						}
					}
				}
				
			}else{
				
				// GRAYSCALE WITH ALPHA NOT AFFECTED
				if( grayScale ) 
				{
					for ( i = 0; i < iw; i++ )
					{
						for ( j = 0; j < ih; j++ )
						{
							
							val = img.getPixel32( i, j );
							
							r = values[ ( val >>> 16 & 0xFF )- 1 ];
							g = values[ ( val >>> 8  & 0xFF )- 1 ];
							b = values[ ( val & 0xFF )- 1 ];
							c = Math.ceil( ( ( r + g + b ) / 3 ) );
							img.setPixel32( i, j, ( (val >>> 24 )<<24 | c << 16 | c << 8 | c ) );
						
						}
					}
					
				}else{ 

					// COLORS WITH ALPHA NOT AFFECTED
					for ( i = 0; i < iw; i++ )
					{
						for ( j = 0; j < ih; j++ )
						{
							
							val = img.getPixel32( i, j );
							
							r = values[ ( val >>> 16 & 0xFF )- 1 ];
							g = values[ ( val >>> 8  & 0xFF )- 1 ];
							b = values[ ( val & 0xFF ) - 1 ];
							
							if (dither) {
								if (r < 0xEE) {
									r += ((i + j) % 2 == 0) ? 0x12 : 0;
								} else {
									r -= ((i + j) % 2 == 0) ? 0x12 : 0;
								}
								if (g < 0xEE) {
									g += ((i + j) % 2 == 0) ? 0x12 : 0;
								} else {
									g -= ((i + j) % 2 == 0) ? 0x12 : 0;
								}
								if (b < 0xEE) {
									b += ((i + j) % 2 == 0) ? 0x12 : 0;
								} else {
									b -= ((i + j) % 2 == 0) ? 0x12 : 0;
								}
							}
							
							img.setPixel32( i, j, ( (val >>> 24 )<<24 | r << 16 | g << 8 | b ) );
						
						}
					}
				}
			}
			img.unlock();
			
		}
		
		
		//SHORTCUTS
		
		static public function toCGA( bmpd:BitmapData, grayscale:Boolean = false, alpha:Boolean = false ):void
		{
			 reduceColors( bmpd, 0, grayscale, alpha );
		}	
		
		static public function toEGA( bmpd:BitmapData, grayscale:Boolean = false, alpha:Boolean = false ):void
		{
			 reduceColors( bmpd, 4, grayscale, alpha  );
		}
		
		static public function toHAM( bmpd:BitmapData, grayscale:Boolean = false, alpha:Boolean = false ):void
		{
			 reduceColors( bmpd, 6, grayscale, alpha  );
		}	
		
		static public function toVGA( bmpd:BitmapData, grayscale:Boolean = false, alpha:Boolean = false ):void
		{
			 reduceColors( bmpd, 8, grayscale, alpha  );
		}
		
		static public function toSVGA( bmpd:BitmapData, grayscale:Boolean = false, alpha:Boolean = false ):void
		{
			 reduceColors( bmpd, 16, grayscale, alpha  );
		}
		
	}
}