package {
		
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.filters.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import fuz2d.model.Model;
	
	import fuz2d.util.TileDefinition;
	import fuz2d.util.TileGenerator;
	import fuz2d.util.TileSet;
	import fuz2d.util.Voronoi;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class TextureGen extends Sprite {

		protected var def:TileDefinition;
		protected var map:Bitmap;
		protected var size:Number = Model.GRID_WIDTH;
		protected var seed:Number = 1;
		
		protected var mapGrid:Object;
		protected var tilemap:BitmapData;
		private var tileSet:TileSet;
		private var nMap:Array;
		
		private var _timer:Timer;
		private var container:Sprite;
		private var _text:TextField;
		
		public function TextureGen () {
			init();
		}
		
		public function init ():void {
	
			var x:int;
			var y:int;
			
			var gridClip:Sprite;
			
			for (y = 1; y < 11; y++) {
				
				for (x = 1; x < 10; x++) {

					gridClip = new Sprite();
					gridClip.graphics.lineStyle(2, 0xdddddd, 1, true);
					gridClip.graphics.drawRect(0, 0, size - 1, size - 1);
					gridClip.graphics.lineStyle(1, 0xbbbbbb, 0.5, true);
					gridClip.graphics.moveTo(0, size / 2 - 1);
					gridClip.graphics.lineTo(size - 1, size / 2 - 1);
					gridClip.graphics.moveTo(size / 2 - 1, 0);
					gridClip.graphics.lineTo(size / 2 - 1, size - 1);
					gridClip.x = x * size + 80;
					gridClip.y = y * size + 40;
					addChild(gridClip);

				}
				
			}
			
			container = new Sprite();
			addChild(container);
			
			mapGrid = { };
			TileGenerator.sampleScale = 2;
			TileGenerator.root = root as Sprite;
			
			seed = 32;
			
			def = new TileDefinition(0, null, size, size);
			def.randomize(seed);
	
			nMap = [
				0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
				0, 0, 0, 0, 1, 1, 1, 0, 0, 0,
				0, 0, 0, 0, 1, 1, 1, 0, 0, 0,
				0, 0, 0, 0, 1, 1, 1, 0, 0, 0,
			    0, 1, 1, 1, 1, 1, 1, 1, 1, 0,
				0, 1, 1, 1, 1, 1, 1, 1, 1, 0,
				0, 1, 1, 1, 1, 1, 1, 1, 1, 0,
				0, 0, 0, 0, 1, 1, 1, 0, 0, 0,
				0, 0, 0, 0, 1, 1, 1, 0, 1, 0,
				0, 0, 0, 0, 0, 0, 0, 0, 1, 0,
				0, 1, 1, 1, 0, 1, 0, 0, 1, 0,
				0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				];
				
			for (y = 1; y < 11; y++) {
				
				for (x = 1; x < 10; x++) {
					
					if (nMap[y * 10 + x] == 1 || (x == 5 && y == 5)) {
						mapGrid[x + "_" + y] = map = new Bitmap(new BitmapData(size, size, true));
						map.x = x * size + 80;
						map.y = y * size + 40;
						container.addChild(map);
					}
					
				}
				
			}	
			
			tileSet = new TileSet(def);

			var tileMap:Array = [];
			
			for (y = 1; y < 11; y++) {
				
				for (x = 1; x < 10; x++) {
					
					tileMap = [];
					
					for (var j:int = y - 1; j <= y + 1; j++) {
						for (var i:int = x - 1; i <= x + 1; i++) {
							tileMap.push(nMap[j * 10 + i]);
						}
					}

					if (x == 5 && y == 5) {
						mapGrid[x + "_" + y].bitmapData = tileSet.getTile([1, 1, 1, 1, 0, 1, 1, 1, 1]);
					} else if (tileMap[4] == 1) {
						mapGrid[x + "_" + y].bitmapData = tileSet.getTile(tileMap);
					}
					
				}
				
			}	
			
			_text = new TextField();
			_text.autoSize = "left";
			_text.x = 20;
			_text.y = 10;
			_text.defaultTextFormat = new TextFormat("Lucida Sans", 128, 0xcccccc, true);
			addChild(_text);
			
			_text.filters = [
				new BlurFilter(2, 2, 3),
				new DropShadowFilter(3, 90, 0, 0.15, 3, 3),
				new DropShadowFilter(4, 90, 0, 0.15, 4, 4),
				new DropShadowFilter(6, 90, 0, 0.15, 6, 6),
				new DropShadowFilter(9, 90, 0, 0.15, 9, 9),
				new DropShadowFilter(12, 90, 0, 0.15, 12, 12),
				new DropShadowFilter(24, 90, 0, 0.15, 24, 24),
				new DropShadowFilter(48, 90, 0, 0.15, 48, 48),
				new DropShadowFilter(12, -90, 0xffffff, 0.2, 36, 36)
				];
			
			_text.text = seed + "";
			
			_timer = new Timer(1000, 0);
			_timer.addEventListener(TimerEvent.TIMER, gen);
			_timer.start();
			
			container.filters = [
				new DropShadowFilter(3, 90, 0, 0.15, 3, 3),
				new DropShadowFilter(4, 90, 0, 0.15, 4, 4),
				new DropShadowFilter(6, 90, 0, 0.15, 6, 6),
				new DropShadowFilter(9, 90, 0, 0.15, 9, 9),
				new DropShadowFilter(12, 90, 0, 0.15, 12, 12),
				new DropShadowFilter(24, 90, 0, 0.15, 24, 24),
				new DropShadowFilter(48, 90, 0, 0.15, 48, 48),
				];
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);

		}
		
		public function gen (e:TimerEvent = null):void {
			
			if (e != null) seed++;
			_text.text = seed + "";
			
			def.randomize(seed);
			
			tileSet = new TileSet(def);

			var tileMap:Array = [];
			
			for (var y:int = 1; y < 11; y++) {
				
				for (var x:int = 1; x < 10; x++) {
					
					tileMap = [];
					
					for (var j:int = y - 1; j <= y + 1; j++) {
						for (var i:int = x - 1; i <= x + 1; i++) {
							tileMap.push(nMap[j * 10 + i]);
						}
					}

					if (x == 5 && y == 5) {
						mapGrid[x + "_" + y].bitmapData = tileSet.getTile([1, 1, 1, 1, 0, 1, 1, 1, 1]);
					} else if (tileMap[4] == 1) {
						mapGrid[x + "_" + y].bitmapData = tileSet.getTile(tileMap);
					}
					
				}
				
			}	

			return;

		}
		
		public function onKey (e:KeyboardEvent):void {
			
			if (e.keyCode == Keyboard.SPACE) {
				
				if (_timer.running) _timer.stop();
				else _timer.start();
			}
			
			if (e.keyCode == Keyboard.LEFT) {
				seed--;
				gen();
			}
			
			if (e.keyCode == Keyboard.RIGHT) {
				seed++;
				gen();
			}			
			
		}
		
	}
	
}