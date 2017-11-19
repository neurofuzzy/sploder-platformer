package com.sploder.texturegen_internal
{
	import flash.geom.Point;
	import com.nodename.Delaunay.Voronoi;
	import com.sploder.texturegen_internal.util.PM_PRNG;
	import com.sploder.texturegen_internal.util.Geom;
	import flash.geom.Rectangle;
	
	public class StoneGenerator
	{
		public static function generateFrom(attribs:TextureAttributes, clippingBounds:Rectangle = null):Array
		{
			var regions:Array = StoneGenerator.generateStoneTiles(clippingBounds, attribs.isVertical, attribs.tilesU, attribs.tilesV, attribs.perturbFactor, attribs.perturbAngle * Math.PI / 180, attribs.interleave, attribs.skipFactor, attribs.seed, attribs.offsetU, attribs.offsetV);
			if (attribs.get_spliceThreshold() > 0)
			{
				var t:int = attribs.get_spliceThreshold();
				var i:int = regions.length;
				var region:Array;
				var r:Rectangle;
				while (i > 0)
				{
					i--;
					region = regions[i];
					r = Geom.boundingBox(region);
					if (r.width < t)
						regions.splice(i, 1);
				}
			}
			return regions;
		}
		
		public static function generateStoneTiles(clippingBounds:Rectangle = null, vertical:Boolean = false, tilesU:int = 4, tilesV:int = 4, perturbFactor:Number = 0.5, perturbAngle:Number = 0, interleave:Boolean = false, skipFactor:Number = 0, seed:int = 1, offsetU:int = 0, offsetV:int = 0):Array
		{
			tilesU = Math.floor(Math.max(2, tilesU));
			tilesV = Math.floor(Math.max(2, tilesV));
			if (clippingBounds == null)
				clippingBounds = new Rectangle(128, 128, 512, 512);
			var points:Vector.<Point> = StoneGenerator.getSiteCoords(vertical, tilesU, tilesV, perturbFactor, perturbAngle, interleave, skipFactor, seed, offsetU, offsetV);
			
			var voro:Voronoi = new Voronoi(points, null, clippingBounds);
			
			var regions:Vector.<Vector.<Point>> = voro.regions();
			var regions_array:Array = [];
			for (var j:int = 0; j < regions.length; j++)
			{
				var region:Vector.<Point> = regions[j];
				var region_points:Array = [];
				for (var i:int = 0; i < region.length; i++)
					region_points.push(region[i]);
				regions_array.push(region_points);
			}
			return regions_array;
		}
		
		protected static function getSiteCoords(vertical:Boolean = false, tilesU:int = 4, tilesV:int = 4, perturbFactor:Number = 0.5, perturbAngle:Number = 0, interleave:Boolean = false, skipFactor:Number = 0, seed:int = 1, offsetU:int = 0, offsetV:int = 0):Vector.<Point>
		{
			var rand:PM_PRNG = new PM_PRNG().initWithSeed(seed);
			var points:Vector.<Point> = new Vector.<Point>();
			var tile_width:Number = 256 / tilesU;
			var tile_height:Number = 256 / tilesV;
			var perturb_width:Number = tile_width * 0.5 * perturbFactor;
			var perturb_height:Number = tile_height * 0.5 * perturbFactor;
			var skip:Boolean = false;
			var pt:Point;
			var perturb:Point = new Point();
			{
				var _g:int = 0;
				while (_g < tilesV)
				{
					var y:int = _g++;
					{
						var _g1:int = 0;
						while (_g1 < tilesU)
						{
							var x:int = _g1++;
							skip = rand.nextDouble() > 1.0 - skipFactor;
							if (!skip)
							{
								pt = new Point(x * tile_width - tile_width * 0.5 - 128, y * tile_height - tile_height * 0.5 - 128);
								perturb.x = rand.nextDouble() * perturb_width - perturb_width * 0.5;
								perturb.y = rand.nextDouble() * perturb_height - perturb_height * 0.5;
								if (perturbAngle > 0)
									Geom.rotate(perturb, perturbAngle);
								pt.x += perturb.x;
								pt.y += perturb.y;
								if (interleave && y % 2 == 0)
									pt.x += tile_width * 0.5;
								points.push(pt);
							}
							else
								points.push(new Point());
						}
					}
				}
			}
			var ang:Number = ((rand.nextDouble() < 0.75) ? 0 : rand.nextDoubleRange(0, Math.PI / 2) - Math.PI / 4);
			if (tilesU <= 3 || tilesV <= 3)
				ang = 0;
			if (vertical)
				ang += Math.PI * 0.5;
			{
				var _g2:int = 0;
				while (_g2 < points.length)
				{
					var pt1:Point = points[_g2];
					++_g2;
					if (!(pt1.x == 0 && pt1.y == 0))
					{
						if (ang != 0)
							Geom.rotate(pt1, ang);
						pt1.x += offsetU * 4;
						pt1.y -= offsetV * 4;
						pt1.x += 128;
						pt1.y += 128;
						pt1.x %= 256;
						pt1.y %= 256;
					}
				}
			}
			{
				var _g3:int = 0;
				while (_g3 < 3)
				{
					var j:int = _g3++;
					{
						var _g11:int = 0;
						while (_g11 < 3)
						{
							var i:int = _g11++;
							if (i == 0 && j == 0)
								continue;
							{
								var _g21:int = 0;
								while (_g21 < tilesV)
								{
									var y1:int = _g21++;
									{
										var _g31:int = 0;
										while (_g31 < tilesU)
										{
											var x1:int = _g31++;
											var pt2:Point = points[y1 * tilesU + x1];
											if (pt2 != null && pt2.x > 0 && pt2.y > 0)
											{
												pt2 = pt2.clone();
												pt2.x += i * 256;
												pt2.y += j * 256;
												points.push(pt2);
											}
										}
									}
								}
							}
						}
					}
				}
			}
			var i1:int = points.length;
			while (i1 > 0)
			{
				i1--;
				pt = points[i1];
				if (pt.x == 0 && pt.y == 0)
					points.splice(i1, 1);
			}
			return points;
		}
	
	}
}
