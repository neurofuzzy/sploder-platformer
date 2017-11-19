package com.sploder.texturegen_internal
{
	import flash.geom.Point;
	import com.sploder.texturegen_internal.util.Geom;
	import com.sploder.texturegen_internal.util.PerlinNoise;
	import flash.geom.Rectangle;
	import flash.display.BitmapData;
	
	public class BrickGenerator
	{
		
		public static function generateFrom(attribs:TextureAttributes, clippingBounds:Rectangle = null):Array
		{
			return BrickGenerator.generateBricks(clippingBounds, attribs.isVertical, attribs.bricksA, attribs.bricksB, attribs.bricksFactorA, attribs.bricksFactorB, attribs.courses, attribs.coursingOffset, attribs.coursingABFactor, attribs.perturbFactor, attribs.perturbAngle * Math.PI / 180, attribs.seed);
		}
		
		public static function generateBricks(clippingBounds:Rectangle = null, vertical:Boolean = false, bricksA:int = 2, bricksB:int = 2, bricksFactorA:Number = 0.5, bricksFactorB:Number = 0.5, courses:int = 4, coursingOffset:Number = 0.5, coursingABFactor:Number = 0.5, perturbFactor:Number = 0, perturbAngle:Number = 0, perturbSeed:int = 1):Array
		{
			
			var regions:Array = [];
			var clip:Boolean = true;
			
			if (clippingBounds == null)
			{
				clippingBounds = new Rectangle(256, 256, 256, 256);
				clip = false;
			}
			
			if (vertical)
			{
				var c:Rectangle = clippingBounds;
				clippingBounds = new Rectangle(c.y, c.x, c.height, c.width);
			}
			
			var left:Number = 256;
			var top:Number = 256;
			var width:Number = 256;
			var height:Number = 256;
			
			courses = Math.floor(Math.max(1, Math.min(64, courses)));
			bricksA = Math.floor(Math.max(0, Math.min(64, bricksA)));
			bricksB = Math.floor(Math.max(0, Math.min(64, bricksB)));
			bricksFactorA = Math.max(0.1, Math.min(0.9, bricksFactorA));
			bricksFactorB = Math.max(0.1, Math.min(0.9, bricksFactorB));
			coursingABFactor = Math.max(0.1, Math.min(0.9, coursingABFactor));
			coursingOffset = Math.max(0, Math.min(1.0, coursingOffset));
			
			var brickAHeight:Number = Math.min(height, height / courses * coursingABFactor * 2);
			var brickBHeight:Number = Math.min(height, height / courses * (1 - coursingABFactor) * 2);
			
			if (courses > 1)
			{
				var a_num:int = Math.ceil(courses / 2);
				var b_num:int = courses - a_num;
				var a_height:Number = a_num * coursingABFactor * 2;
				var b_height:Number = b_num * (1 - coursingABFactor) * 2;
				var scale_factor:Number = height / (a_height + b_height);
				brickAHeight = a_height / a_num * scale_factor;
				brickBHeight = b_height / b_num * scale_factor;
			}
			
			var brickAAWidth:Number = ((bricksA == 1) ? width : width * 2);
			var brickABWidth:Number = ((bricksA == 1) ? width : width * 2);
			
			if (bricksA > 1)
			{
				var aa_num:int = Math.ceil(bricksA / 2);
				var ab_num:int = bricksA - aa_num;
				var aa_width:Number = aa_num * bricksFactorA * 2;
				var ab_width:Number = ab_num * (1 - bricksFactorA) * 2;
				var scale_factor1:Number = width / (aa_width + ab_width);
				brickAAWidth = aa_width / aa_num * scale_factor1;
				brickABWidth = ab_width / ab_num * scale_factor1;
			}
			
			var brickBAWidth:Number = ((bricksB == 1) ? width : width * 2);
			var brickBBWidth:Number = ((bricksB == 1) ? width : width * 2);
			
			if (bricksB > 1)
			{
				var ba_num:int = Math.ceil(bricksB / 2);
				var bb_num:int = bricksB - ba_num;
				var ba_width:Number = ba_num * bricksFactorB * 2;
				var bb_width:Number = bb_num * (1 - bricksFactorB) * 2;
				var scale_factor2:Number = width / (ba_width + bb_width);
				brickBAWidth = ba_width / ba_num * scale_factor2;
				brickBBWidth = bb_width / bb_num * scale_factor2;
			}
			
			var coursingBOffset:Number = Math.min(width / 2, width / bricksB * coursingOffset);
			var x:Number = 0;
			var y:Number = 0 - brickAHeight - brickBHeight;
			var i:int = -2;
			var j:int = -2;
			var markers:Array = [];
			
			i = -2;
			x = 0 - brickAAWidth - brickABWidth;
			
			if (bricksA >= 0)
				while (x < width + 64)
				{
					if (!clip || x < clippingBounds.x + clippingBounds.width)
						markers.push(new Point(left + x, top + y));
					x += ((i % 2 == 0) ? brickAAWidth : brickABWidth);
					i++;
				}
			
			i = -2;
			x = 0 - brickBAWidth - brickBBWidth;
			
			if (bricksB > 0)
			{
				if (coursingOffset > 0)
				{
					x -= brickBBWidth + coursingBOffset;
					i -= 1;
				}
				while (x < width + 64)
				{
					var bw:Number = ((i % 2 == 0) ? brickBAWidth : brickBBWidth);
					if (!clip || x < clippingBounds.x + clippingBounds.width && x + bw > 0)
						markers.push(new Point(left + x, top + y));
					x += ((i % 2 == 0) ? brickBAWidth : brickBBWidth);
					i++;
				}
			}
			
			markers.sort(function(a:Point, b:Point):int
				{
					if (a.x < b.x)
						return -1;
					if (a.x > b.x)
						return 1;
					return 0;
				});
			
			x = 0;
			y = 0 - brickAHeight - brickBHeight;
			i = -2;
			j = -2;
			
			while (y < height + 64)
			{
				if (clip && y > height + 64)
					break;
				if (j % 2 == 0)
				{
					i = -2;
					x = 0 - brickAAWidth - brickABWidth;
					if (bricksA == 0)
						x = 0 - width * 0.25;
					while (x < width + 64)
					{
						if (!clip || x < clippingBounds.x + clippingBounds.width)
							regions.push(BrickGenerator.generateBrick(left + x, top + y, ((i % 2 == 0) ? brickAAWidth : brickABWidth), brickAHeight, ((clip) ? clippingBounds : null), ((perturbFactor > 0) ? markers : null)));
						x += ((i % 2 == 0) ? brickAAWidth : brickABWidth);
						i++;
					}
					y += brickAHeight;
				}
				else
				{
					i = -2;
					x = 0 - brickBAWidth - brickBBWidth;
					if (bricksB == 0)
						x = 0 - width * 0.25;
					if (coursingOffset > 0)
					{
						x -= brickBBWidth + coursingBOffset;
						i -= 1;
					}
					while (x < width + 64)
					{
						var bw1:Number = ((i % 2 == 0) ? brickBAWidth : brickBBWidth);
						if (!clip || x < clippingBounds.x + clippingBounds.width && x + bw1 > 0)
							regions.push(BrickGenerator.generateBrick(left + x, top + y, bw1, brickBHeight, ((clip) ? clippingBounds : null), ((perturbFactor > 0) ? markers : null)));
						x += ((i % 2 == 0) ? brickBAWidth : brickBBWidth);
						i++;
					}
					y += brickBHeight;
				}
				j++;
			}
			if (vertical)
			{
				var _g:int = 0;
				while (_g < regions.length)
				{
					var region:Array = regions[_g];
					++_g;
					{
						var _g1:int = 0;
						while (_g1 < region.length)
						{
							var pt:Point = region[_g1];
							++_g1;
							var tmp:Number = pt.x;
							pt.x = pt.y;
							pt.y = tmp;
						}
					}
					region.reverse();
				}
			}
			if (perturbFactor > 0)
			{
				if (vertical)
					perturbAngle += Math.PI * 0.5;
				regions = BrickGenerator.perturbBricks(regions, perturbFactor, perturbAngle, perturbSeed);
			}
			return regions;
		}
		
		protected static function generateBrick(x:Number, y:Number, width:Number, height:Number, clippingBounds:Rectangle = null, divisionMarkers:Array = null):Array
		{
			var region:Array = [];
			var c:Rectangle = clippingBounds;
			if (clippingBounds == null)
			{
				region.push(new Point(x, y));
				region.push(new Point(x + width, y));
				region.push(new Point(x + width, y + height));
				region.push(new Point(x, y + height));
			}
			else
			{
				region.push(new Point(Math.max(c.x, x), Math.max(c.y, y)));
				region.push(new Point(Math.min(c.x + c.width, x + width), Math.max(c.y, y)));
				region.push(new Point(Math.min(c.x + c.width, x + width), Math.min(c.y + c.height, y + height)));
				region.push(new Point(Math.max(c.x, x), Math.min(c.y + c.height, y + height)));
			}
			if (divisionMarkers != null)
			{
				var top_right:Point = region[1];
				var top_left:Point = region[0];
				var bottom_right:Point = region[2];
				var bottom_left:Point = region[3];
				var i:int = divisionMarkers.length;
				var marker:Point;
				while (i > 0)
				{
					i--;
					marker = divisionMarkers[i];
					if (marker.x > bottom_left.x && marker.x < bottom_right.x)
					{
						marker = marker.clone();
						marker.y = bottom_left.y;
						region.insert(3, marker);
					}
				}
				i = 0;
				while (i < divisionMarkers.length)
				{
					marker = divisionMarkers[i];
					if (marker.x > top_left.x && marker.x < top_right.x)
					{
						marker = marker.clone();
						marker.y = top_left.y;
						region.insert(1, marker);
					}
					i++;
				}
				PolygonTools.sortPolygonPoints(region);
			}
			return region;
		}
		
		protected static function perturbBricks(bricks:Array, perturbFactor:Number = 0.5, perturbAngle:Number = 0, seed:int = 1):Array
		{
			var noise:PerlinNoise = new PerlinNoise(seed, 3);
			var noiseMap:BitmapData = new BitmapData(64, 64);
			noise.fill(noiseMap, 1000, 1000, 1000, 0);
			var perturbDist:Number = 32 * perturbFactor;
			var perturb_vector:Point = new Point(0, perturbFactor);
			
			if (perturbAngle != 0)
				Geom.rotate(perturb_vector, perturbAngle);
			{
				var _g:int = 0;
				while (_g < bricks.length)
				{
					var brick:Array = bricks[_g];
					++_g;
					{
						var _g1:int = 0;
						while (_g1 < brick.length)
						{
							var pt:Point = brick[_g1];
							++_g1;
							var px:int = Math.floor(pt.x % 256 / 4) - 32;
							var py:int = Math.floor(pt.y % 256 / 4) - 32;
							if (px < 0)
								px = 64 + px;
							if (py < 0)
								py = 64 + py;
							var p_val:int = noiseMap.getPixel(px, py) >> 16;
							pt.x += (p_val - 138) * perturb_vector.x;
							pt.y += (p_val - 138) * perturb_vector.y;
						}
					}
				}
			}
			noiseMap.dispose();
			return bricks;
		}
	
	}
}
