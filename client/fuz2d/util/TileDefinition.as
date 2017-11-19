/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.util {

	import com.adobe.serialization.json.*;

	public class TileDefinition {
		
		public static var ambientColor:Number = 0x000000;
		
		public static var grid_width:int = 60;
		public static var grid_height:int = 60;
		public static var scale:Number = 1;
		
		public var width:int = 0;
		public var height:int = 0;
		public var backgroundColor:Number = 0xff998844; 
		public var edgeColor:Number = 0xff660000; 
		public var edgeThickness:Number = 2;
		public var cellsX:int = 4;
		public var cellsY:int = 4; 
		public var perturbation:Number = 0.3; 
		public var randomSeed:int = 1;
		public var bond:Boolean = false;
		public var noiseLevel:int = 7;
		public var bevel:Boolean = false;
		public var cap:Boolean = false;
		public var edgeDepth:int = 1;
		public var recess:Boolean = false;
		public var smooth:Boolean = false;
		public var back:Boolean = false;
		
		public var tileMap:Array;
		
		public function TileDefinition (
			id:int = 0,
			back:Boolean = false,
			json:String = "",
			width:int = 0, 
			height:int = 0, 
			backgroundColor:Number = 0xff998844, 
			edgeColor:Number = 0xff660000, 
			edgeThickness:Number = 2,
			cellsX:int = 4, 
			cellsY:int = 4, 
			perturbation:Number = 0.3, 
			randomSeed:int = 1, 
			bond:Boolean = false, 
			noiseLevel:int = 7, 
			bevel:Boolean = false,
			cap:Boolean = false,
			edgeDepth:int = 1,
			recess:Boolean = false,
			smooth:Boolean = false,
			tileMap:Array = null
			) 
		{
			
			this.back = back;
			
			if (width == 0 || height == 0) {
				this.width = Math.floor(grid_width * scale);
				this.height = Math.floor(grid_height * scale);
			} else {
				this.width = width;
				this.height = height;
			}
			
			if (id > 0) {
				
				randomize(id);
				
			} else if (json != null && json.length > 0) {
				
				parse(json);
				
			} else {
				
				this.backgroundColor = backgroundColor;
				this.edgeColor = edgeColor;
				this.edgeThickness = edgeThickness;
				this.cellsX = cellsX;
				this.cellsY = cellsY;
				this.perturbation = perturbation;
				this.randomSeed = randomSeed;
				this.bond = bond;
				this.noiseLevel = noiseLevel;
				this.bevel = bevel;
				this.cap = cap;
				this.edgeDepth = edgeDepth;
				this.recess = recess;
				this.smooth = smooth;
				
				if (smooth) cap = true;
				if (smooth) recess = true;
			
			}
			
			if (tileMap != null) this.tileMap = tileMap;
			else {
				this.tileMap = [
					1, 1, 1,
					1, 1, 1,
					1, 1, 1
					];
			}
			
			if (width > grid_width) cap = true;
			
			if (backgroundColor < 0xff000000) backgroundColor += 0xff000000;
			if (edgeColor < 0xff000000) edgeColor += 0xff000000;
	
		}
		
		public function randomize (seed:int = 1):void {
			
			var sn:Number = seed;
			sn = 29475.967 * sn;
			sn = Math.sqrt(sn);
			sn = sn - Math.floor(sn);

			var ss:String = sn.toString().split("0.").join("") + sn.toString().split("0.").join("");

			backgroundColor = Math.min(0xffffffff, parseInt("0xff" + ss.substr(0, 6), 16) + ambientColor);
			
			if (back) {

				backgroundColor -= 0xff000000;
				backgroundColor = ColorTools.getTintedColor(backgroundColor, 0x000000, 0.7);
				backgroundColor += 0xff000000;	
				
			} else {

				backgroundColor -= 0xff000000;
				backgroundColor = ColorTools.getTintedColor(backgroundColor, 0xffffff, 0.4);
				backgroundColor += 0xff000000;					
				
			}
 
			
			edgeColor = parseInt("0xff" + ss.substr(6, 6), 16);
			edgeThickness = Math.max(3 - (TileGenerator.sampleScale - 1), Math.min(6, Math.floor(parseInt(ss.charAt(13)) / 2)));
			cellsX = 2 + Math.floor(parseInt(ss.charAt(14)) / 2);
			cellsY = 2 + Math.floor(parseInt(ss.charAt(15)) / 2);
			perturbation = Math.max(0, parseInt(ss.charAt(16)) / 10 - 0.1);
			randomSeed = seed;
			bond = parseInt(ss.charAt(17)) < 4;
			cap = (parseInt(ss.charAt(18)) > 5 || cellsX < 4 || cellsY < 4);
			noiseLevel = Math.floor(parseInt(ss.charAt(19)));
			edgeDepth = Math.floor(parseInt(ss.charAt(20)) / 2);
			recess = parseInt(ss.charAt(21)) > 3;
			smooth = parseInt(ss.charAt(22)) < 5;

			if (width == 0) width = Math.floor(grid_width * scale);
			if (height == 0) height = Math.floor(grid_height * scale);
			
			if (smooth) cap = true;
			if (smooth) recess = true;
			if (bond) perturbation *= 0.5;
			if (width > grid_width) cap = true;
			
		}
		
		public function toString ():String {
			
			return com.adobe.serialization.json.JSON.encode(this);
			
		}
		
		public function parse (jsonString:String):void {
			
			var def:Object = com.adobe.serialization.json.JSON.decode(jsonString);
			
			for (var param:String in def) {
				try {
					this[param] = def[param];
				} catch (e:Error) {
					trace("ERROR: Parameter " + param + " not defined in TileDefinition");
				}
			}
			
		}
		
		public function inject (parameters:Object):void {
			
			for (var param:String in parameters) {
				
				try {
					this[param] = parameters[param];
				} catch (e:Error) {
					trace("ERROR: Parameter " + param + " not defined in TileDefinition");	
				}
				
			}			
			
		}
		
		public function clone ():TileDefinition {
			
			return new TileDefinition(0, back, toString());
			
		}
		
	}
	
}