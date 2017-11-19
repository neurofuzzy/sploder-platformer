/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.util {
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class Voronoi {
		
		protected var _clip:Sprite;
		protected var g:Graphics;
		
		protected var mapWidth:int = 100;
		protected var mapHeight:int = 100;
		protected var bgColor:Number = 0x000000;
		protected var fgColor:Number = 0xcccccc;
		protected var _thickness:Number = 1;
		protected var _alpha:Number = 1;
		protected var cellsX:int = 4;
		protected var cellsY:int = 4;
		protected var totalCells:int = 24;
		protected var perturb:Number = 0.3;
		protected var bond:Boolean = false;
		
		protected var _points:Array;
		
		protected var PI:Number;
		protected var PI2:Number;
		
		protected var distance:Array;
		protected var sx:Array;
		protected var sy:Array;
		protected var ex:Array;
		protected var ey:Array;
		protected var cache:int;
        protected var ox:Number;
        protected var oy:Number;
		
		protected var noiseMap:BitmapData;
		protected var randomSeed:int = 1;
		
		public var background:Boolean = true;
		
		public function get seed():int { return randomSeed; }
		
		public function get thickness():Number { return _thickness; }
		public function set thickness(value:Number):void { _thickness = value;	}
		
		public function get alpha():Number { return _alpha; }
		public function set alpha(value:Number):void { _alpha = value; }
		
		public function get points():Array { return _points; }
		
		public function get topPoints ():Array {
			
			var pts:Array = [];
	
			var ymax:Number = (cellsY >= 4) ? 1 : 0;
			
			for (var y:int = 0; y <= ymax; y++) {
				for (var x:int = 0; x <= cellsX + 1; x++) {
					pts.push(_points[y * (cellsX + 2) + x]);
				}
			}
			
			return pts;
			
		}
		
		public function get leftPoints ():Array {
			
			var pts:Array = [];
			
			var xmax:Number = (cellsX >= 4) ? 1 : 0;
	
			for (var y:int = 0; y <= cellsY + 1; y++) {
				for (var x:int = 0; x <= xmax; x++) {
					pts.push(_points[y * (cellsX + 2) + x]);
				}
			}
			
			return pts;
			
		}
		
		public function get bottomPoints ():Array {
			
			var pts:Array = [];
			
			var ymin:Number = (cellsY >= 4) ? cellsY : cellsY + 1;
	
			for (var y:int = ymin; y <= cellsY + 1; y++) {
				for (var x:int = 0; x <= cellsX + 1; x++) {
					pts.push(_points[y * (cellsX + 2) + x]);
				}
			}
			
			return pts;
			
		}
		
		public function get rightPoints ():Array {
			
			var pts:Array = [];
	
			var xmin:Number = (cellsX >= 4) ? cellsX : cellsX + 1;
			
			for (var y:int = 0; y <= cellsY + 1; y++) {
				for (var x:int = xmin; x <= cellsX + 1; x++) {
					pts.push(_points[y * (cellsX + 2) + x]);
				}
			}
			
			return pts;
			
		}
		
		public function get topLeftPoints ():Array {
			
			var pts:Array = [];
			
			var ymax:Number = (cellsY >= 4) ? 1 : 0;
			var xmax:Number = (cellsX >= 4) ? 1 : 0;
	
			for (var y:int = 0; y <= ymax; y++) {
				for (var x:int = 0; x <= xmax; x++) {
					pts.push(_points[y * (cellsX + 2) + x]);
				}
			}
			
			return pts;
			
		}
		
		public function get topRightPoints ():Array {
			
			var pts:Array = [];
			
			var ymax:Number = (cellsY >= 4) ? 1 : 0;
			var xmin:Number = (cellsX >= 4) ? cellsX : cellsX + 1;
	
			for (var y:int = 0; y <= ymax; y++) {
				for (var x:int = xmin; x <= cellsX + 1; x++) {
					pts.push(_points[y * (cellsX + 2) + x]);
				}
			}
			
			return pts;
			
		}
		
		public function get bottomLeftPoints ():Array {
			
			var pts:Array = [];
			
			var ymin:Number = (cellsY >= 4) ? cellsY : cellsY + 1;
			var xmax:Number = (cellsX >= 4) ? 1 : 0;
	
			for (var y:int = ymin; y <= cellsY + 1; y++) {
				for (var x:int = 0; x <= xmax; x++) {
					pts.push(_points[y * (cellsX + 2) + x]);
				}
			}
			
			return pts;
			
		}
		
		public function get bottomRightPoints ():Array {
			
			var pts:Array = [];
			
			var ymin:Number = (cellsY >= 4) ? cellsY : cellsY + 1;
			var xmin:Number = (cellsX >= 4) ? cellsX : cellsX + 1;
	
			for (var y:int = ymin; y <= cellsY + 1; y++) {
				for (var x:int = xmin; x <= cellsX + 1; x++) {
					pts.push(_points[y * (cellsX + 2) + x]);
				}
			}
			
			return pts;
			
		}
		
		
		public function get centerPoints ():Array {
			
			var pts:Array = [];
			
			var ymin:Number = (cellsY >= 4) ? 2 : 1;
			var xmin:Number = (cellsX >= 4) ? 2 : 1;
			var ymax:Number = (cellsY >= 4) ? cellsY - 1 : cellsY - 2;
			var xmax:Number = (cellsX >= 4) ? cellsX - 1 : cellsX - 2;
	
			for (var y:int = ymin; y <= ymax; y++) {
				for (var x:int = xmin; x <= xmax; x++) {
					pts.push(_points[y * (cellsX + 2) + x]);
				}
			}
			
			return pts;
			
		}
		
		public function get clip():Sprite { return _clip; }
		

		//
		//
		public function Voronoi (clip:Sprite, width:int = 100, height:int = 100, backgroundColor:Number = 0x33cccc, edgeColor:Number = 0xcccc33, edgeThickness:Number = 2, cellsX:int = 4, cellsY:int = 4, perturbation:Number = 0.3, randomSeed:int = 1, bond:Boolean = false) {
			
			init(clip, width, height, backgroundColor, edgeColor, edgeThickness, cellsX, cellsY, perturbation, randomSeed, bond);
			
		}
		
		//
		//
		protected function init (clip:Sprite, width:int = 100, height:int = 100, backgroundColor:Number = 0x33cccc, edgeColor:Number = 0xcccc33, edgeThickness:Number = 2, cellsX:int = 4, cellsY:int = 4, perturbation:Number = 0.3, randomSeed:int = 1, bond:Boolean = false):void {
			
			_clip = clip;
			g = _clip.graphics;
			bgColor = backgroundColor;
			fgColor = edgeColor;
			thickness = edgeThickness;
			this.cellsX = cellsX;
			this.cellsY = cellsY;
			totalCells = (cellsX + 2) * (cellsY + 2);
			perturb = Math.max(0, Math.min(1, perturbation));
			this.randomSeed = randomSeed;
			this.bond = bond
			mapWidth = width;
			mapHeight = height;
            
  			ox = Math.floor(mapWidth / (cellsX + 2));
			oy = Math.floor(mapHeight / (cellsY + 2));
			
			cache = totalCells + 4;

			_points = [];
			PI = Math.PI;
			PI2 = 2*PI;

			distance = [];
			
			sx = [];
			sy = [];
			ex = [];
			ey = [];

			noiseMap = new BitmapData(width, height, false);
			noiseMap.perlinNoise(width / 2, height / 2, 4, randomSeed, false, true, 7, true);
			
			initPoints();
			
		}
		
		public function create (seed:int = -1, offset:Boolean = true):void {
			
			if (seed != -1) {
				randomSeed = seed;
				noiseMap.perlinNoise(mapWidth / 2, mapHeight / 2, 4, randomSeed, false, true);
			}
			
			setPoints();
			setVoronoi();
			draw(0x000000, offset);
			
		}
		
		public function redraw (color:Number, offset:Boolean = true):void {
			
			g.clear();
			draw(color, offset);
			
		}
		
		//
		//
		protected function initPoints ():void {

			for (var i:int = 0; i < totalCells; i++) _points.push(new Point(0,0));

		}
		
		//
		//
		protected function setPoints ():void {

			var h:Number;
			var col:int;
			var row:int;
			var idx:int;
			var coreCells:int = cellsX * cellsY;
			
			var pr:Number = 0;
			var px:Number = 0;
			var py:Number = 0;
			
			for (var i:int = 0; i < coreCells; i++) {
				
				h = (bond) ? i % 2 - 0.5 : 1;

				col = i % cellsX;
				row = Math.floor(i / cellsX);
				idx = ((row + 1) * (cellsX + 2)) + (col + 1);
				
				_points[idx].x = (mapWidth / cellsX) * (0.5 + col + 0.5);
				_points[idx].y = (mapHeight / cellsY) * (0.5 + row + 0.5 * h);

				if (perturb > 0) {
					
					pr = noiseMap.getPixel(_points[idx].x - ox, _points[idx].y - oy) >> 16;
					pr -= 128;
					pr *= (360 / 128) * Math.PI / 180;

					px = Point.polar(1, pr).x;
					py = Point.polar(1, pr).y;
					
					_points[idx].x += (mapWidth / cellsX) * px * perturb;
					_points[idx].y += (mapHeight / cellsY) * py * perturb;
				
				}
				
				if (row == 0) {

					_points[idx + (cellsX + 2) * cellsY].x = _points[idx].x;
					_points[idx + (cellsX + 2) * cellsY].y = _points[idx].y + mapHeight;
					
				} else if (row == cellsY - 1) {

					_points[col + 1].x = _points[idx].x;
					_points[col + 1].y = _points[idx].y - mapHeight;
	
				}
				
				if (col == 0) {
		
					_points[idx + cellsX].x = _points[idx].x + mapWidth;
					_points[idx + cellsX].y = _points[idx].y;
						
				} else if (col == cellsX - 1) {
			
					_points[idx - cellsX].x = _points[idx].x - mapWidth;
					_points[idx - cellsX].y = _points[idx].y;	
	
				}
				
			}
			
			// top left wrapped tile point
			_points[(cellsY) * (cellsX + 2) + (cellsX)].x - mapWidth;
			_points[0].y = _points[(cellsY) * (cellsX + 2) + (cellsX)].y - mapHeight;
			
			// top right wrapped tile point
			_points[cellsX + 1].x = _points[(cellsY) * (cellsX + 2) + 1].x + mapWidth;
			_points[cellsX + 1].y = _points[(cellsY) * (cellsX + 2) + 1].y - mapHeight;
			
			// bottom left wrapped tile point
			_points[(cellsX + 2) * (cellsY + 1)].x = _points[2 * (cellsX + 2) - 2].x - mapWidth;
			_points[(cellsX + 2) * (cellsY + 1)].y = _points[2 * (cellsX + 2) - 2].y + mapHeight;
			
			// bottom right wrapped tile point
			_points[(cellsX + 2) * (cellsY + 2) - 1].x = _points[(cellsX + 2) + 1].x + mapWidth;
			_points[(cellsX + 2) * (cellsY + 2) - 1].y = _points[(cellsX + 2) + 1].y + mapHeight;
				
		}
		
		//
		//
		protected function setVoronoi ():void {
			
			var i:int, j:int, k:int, m:int, n:int;
			var a:Number, b:Number, a0:Number, b0:Number, a1:Number, b1:Number, x:Number, y:Number, x0:Number, y0:Number, x1:Number, y1:Number;
				
			for (i = 0; i < totalCells; i++) {

				x0 = _points[i].x;
				y0 = _points[i].y;
				n = i * cache + i + 1;
				
				for (j = i + 1; j < totalCells; j++) {
					
					x1 = _points[j].x;
					y1 = _points[j].y;
					
					if (x1 == x0) {
						a = 0;
					} else if (y1 == y0) {
						a = 10000;
					} else {
						a = -1 / ((y1 - y0) / (x1 - x0));
					}
					
					b = (y0 + y1) / 2-a * (x0 + x1) / 2;

					if (a > -1 && a <= 1) {
						
						sx[n] = 0 - ox;
						sy[n] = a * sx[n] + b;
						ex[n] = mapWidth + ox + ox - 1;
						ey[n] = a * ex[n] + b;
						
					} else {
						
						sy[n] = 0 - oy;
						sx[n] = (sy[n] - b) / a;
						ey[n] = mapHeight + oy + oy  - 1;
						ex[n] = (ey[n] - b) / a;
						
					}
					
					n++;
					
				}
	

				
			}
			
			for (i = 0; i < totalCells; i++) {
				
				x0 = _points[i].x;
				y0 = _points[i].y;
				
				for (j = 0; j < totalCells + 4; j++) {
					
					if (j != i) {
						
						if (j > i) {
							n = i * cache + j;
						} else {
							n = j * cache + i;
						}
						
						if (sx[n] > -Number.MAX_VALUE) {
							
							a0 = (ey[n] - sy[n]) / (ex[n] - sx[n]);
							b0 = sy[n] - a0 * sx[n];
											
							for (k = i + 1; k < totalCells + 4; k++) {
								
								if (k != j) {
									
									m = i * cache + k;
									
									if (sx[m] > -Number.MAX_VALUE) {
										
										a1 = (ey[m] - sy[m]) / (ex[m] - sx[m]);
										b1 = sy[m] - a1 * sx[m];	
										x = -(b1 - b0) / (a1 - a0);
										y = a0 * x + b0;
										
										if ((a0 * x0 + b0 - y0) * (a0 * sx[m] + b0 - sy[m]) < 0) {
											sx[m] = x;
											sy[m] = y;
										}
										
										if ((a0 * x0 + b0 - y0) * (a0 * ex[m] + b0 - ey[m]) < 0) {
											if (sx[m] == x) {
												sx[m] = -Number.MAX_VALUE;
											} else {
												ex[m] = x;
												ey[m] = y;
											}
										}
										
									}
									
								}
								
							}
							
						}
						
					}
					
				}
				
			}
			
		}
		
		//
		//
		protected function draw (c:Number, offset:Boolean = true):void {
			
			var i:int, j:int, n:int;
			
			g.clear();
			g.lineStyle(2, 0x000000, 1);
			g.beginFill(bgColor, 1);
			if (background) g.drawRect(0, 0, mapWidth + ox + ox, mapHeight + oy + oy);
			g.endFill();
			
			g.lineStyle(thickness, fgColor, _alpha);
			
			for (i = 0; i < totalCells; i++) {
				
				n = i * cache + i + 1;
				
				for (j = i + 1; j < totalCells + 4; j++) {
					
					if (sx[n] > -Number.MAX_VALUE) {
						
						if (offset) {
							
							g.moveTo(sx[n] - ox, sy[n] - oy);
							g.lineTo(ex[n] - ox, ey[n] - oy);
						
						} else {
							
							g.moveTo(sx[n], sy[n]);
							g.lineTo(ex[n], ey[n]);
							
						}
						
						
					}
					
					n++;
					
				}
				
			}
			
		}
		
	}
	
}