package com.sploder.texturegen_internal
{
	import com.sploder.texturegen_internal.util.ColorTools;
	import com.sploder.texturegen_internal.util.PM_PRNG;
	import haxe.Serializer;
	import haxe.Unserializer;
	
	public class TextureAttributes
	{
		public static var TYPE_BRICK:String = "brick";
		public static var TYPE_STONE:String = "stone";
		public static var geometryAttribs:Array = ["seed", "type", "tilesU", "tilesV", "offsetU", "offsetV", "interleave", "skipFactor", "isVertical", "bricksA", "bricksB", "bricksFactorA", "bricksFactorB", "courses", "coursingOffset", "coursingABFactor", "bevelAmount", "mortarAmount", "perturbFactor", "perturbAngle"];
		public static var renderingAttribs:Array = ["rseed", "lightColor", "lightAngle", "shadowColor", "depthColor", "highlightColor", "gradientRadial", "bevelRatio", "lightFactor", "depthFactor", "roundFactor", "overExposure", "contrastPower", "blurAmount", "noiseFactor", "noiseScale", "reducedColors", "ditherMode"];
		
		public var ditherMode:int;
		public var reducedColors:int;
		public var noiseScale:Number;
		public var noiseFactor:Number;
		public var blurAmount:Number;
		public var contrastPower:Number;
		public var overExposure:Number;
		public var roundFactor:Number;
		public var depthFactor:Number;
		public var lightFactor:Number;
		public var bevelRatio:int;
		public var bevelAmount:Number;
		public var gradientRadial:Boolean;
		public var mortarColor:int;
		public var highlightColor:int;
		public var depthColor:int;
		public var shadowColor:int;
		public var lightAngle:int;
		public var lightColor:int;
		public var diffuseColor:int;
		public var rseed:int;
		public var perturbAngle:Number;
		public var perturbFactor:Number;
		public var mortarAmount:Number;
		public var coursingABFactor:Number;
		public var coursingOffset:Number;
		public var courses:int;
		public var bricksFactorB:Number;
		public var bricksFactorA:Number;
		public var bricksB:int;
		public var bricksA:int;
		public var isVertical:Boolean;
		public var skipFactor:Number;
		public var interleave:Boolean;
		public var offsetV:int;
		public var offsetU:int;
		public var tilesV:int;
		public var tilesU:int;
		public var type:String;
		public var seed:int;
		
		public function get spliceThreshold():int
		{
			return get_spliceThreshold();
		}
		
		protected function set spliceThreshold(__v:int):void
		{
			$spliceThreshold = __v;
		}
		protected var $spliceThreshold:int;
		
		public function TextureAttributes():void
		{
		}
		
		public function get_spliceThreshold():int
		{
			if (isNaN(tilesU))
				return 0;
			return Math.floor(Math.min(48, Math.floor(128 / tilesU)));
		}
		
		public function init():*
		{
			initFromSeed(1, 1);
			return this;
		}
		
		public function initWithData(data:String = null):*
		{
			if (data != null && data.length > 0)
				unserialize(data);
			else
				initFromSeed(1, 1);
			return this;
		}
		
		public function initFromSeed(geometrySeed:int = 0, renderingSeed:int = 1):*
		{
			var rand:PM_PRNG;
			if (geometrySeed > 0)
			{
				seed = geometrySeed;
				rand = new PM_PRNG().initWithSeed(seed);
				type = ((rand.nextDouble() < 0.5) ? "brick" : "stone");
				rand = new PM_PRNG().initWithSeed(seed);
				rand.nextDouble();
				tilesU = rand.nextIntRange(2, 5);
				tilesV = rand.nextIntRange(2, 5);
				offsetU = offsetV = 0;
				interleave = rand.nextDouble() > 0.5;
				skipFactor = ((rand.nextDouble() > 0.7) ? 0.1 : rand.nextDouble() * 0.4);
				rand = new PM_PRNG().initWithSeed(seed);
				isVertical = rand.nextDouble() > 0.4;
				bricksA = rand.nextIntRange(0, 6);
				bricksB = rand.nextIntRange(0, 6);
				bricksFactorA = ((rand.nextDouble() > 0.5) ? 0.5 : rand.nextIntRange(0, 2) * 0.25 + 0.25);
				bricksFactorB = ((rand.nextDouble() > 0.5) ? 0.5 : rand.nextIntRange(0, 2) * 0.25 + 0.25);
				courses = rand.nextIntRange(1, 8);
				coursingOffset = ((rand.nextDouble() > 0.5) ? 0.5 : ((rand.nextDouble() > 0.5) ? 0 : rand.nextIntRange(0, 3) * 0.25));
				coursingABFactor = ((rand.nextDouble() > 0.5) ? 0.5 : ((rand.nextDouble() > 0.5) ? 0.25 : 0.25 + rand.nextIntRange(0, 2) * 0.25));
				rand = new PM_PRNG().initWithSeed(seed);
				var p_threshold:Number = ((type == "brick") ? 0.75 : 0.25);
				perturbFactor = ((rand.nextDouble() > p_threshold) ? rand.nextDouble() * (1.5 - p_threshold) : 0);
				perturbAngle = ((perturbFactor > 0) ? rand.nextDoubleRange(0, Math.PI * 2) : 0);
				bevelAmount = Math.min(100, rand.nextIntRange(0, 120));
				mortarAmount = ((rand.nextDouble() > 0.5) ? 0 : rand.nextIntRange(0, 8));
			}
			if (renderingSeed == 1)
			{
				lightColor = 16777215;
				lightAngle = 315;
				shadowColor = 51;
				depthColor = 0;
				highlightColor = 0;
				bevelRatio = 255;
				lightFactor = 0.75;
				depthFactor = 0.25;
				roundFactor = 0;
				overExposure = 0;
				contrastPower = 0;
				blurAmount = 0;
				noiseFactor = 0;
				noiseScale = 1;
				reducedColors = 8;
				ditherMode = 0;
				diffuseColor = 6710886;
				mortarColor = 0;
			}
			else if (renderingSeed > 0)
			{
				rseed = renderingSeed;
				rand = new PM_PRNG().initWithSeed(rseed);
				lightColor = ColorTools.hsv2hex(rand.nextIntRange(0, 360), 20, 100);
				lightAngle = 315;
				shadowColor = ((rand.nextDouble() < 0.5) ? 0 : ColorTools.hsv2hex(rand.nextIntRange(0, 360), 80, 25));
				depthColor = ((rand.nextDouble() < 0.5) ? 0 : ColorTools.hsv2hex(rand.nextIntRange(0, 360), 80, 25));
				highlightColor = ((rand.nextDouble() < 0.5) ? 0 : ColorTools.hsv2hex(rand.nextIntRange(0, 360), 80, 50));
				gradientRadial = rand.nextDouble() < 0.5;
				bevelRatio = ((rand.nextDouble() < 0.5) ? 255 : rand.nextIntRange(1, 255));
				lightFactor = rand.nextDouble();
				depthFactor = rand.nextDouble();
				roundFactor = rand.nextDouble();
				overExposure = ((rand.nextDouble() < 0.5) ? 0 : rand.nextDouble());
				contrastPower = rand.nextIntRange(0, 10) / 5;
				blurAmount = ((rand.nextDouble() < 0.75) ? 0 : rand.nextIntRange(0, 36));
				noiseFactor = ((rand.nextDouble() < 0.5) ? 0 : rand.nextDouble() * 0.5);
				noiseScale = ((rand.nextDouble() < 0.5) ? 0 : rand.nextIntRange(1, 8));
				reducedColors = ((rand.nextDouble() < 0.25) ? 0 : rand.nextIntRange(1, 8) * 2);
				ditherMode = ((rand.nextDouble() < 0.5) ? 0 : rand.nextIntRange(1, 33));
				diffuseColor = ColorTools.hsv2hex(rand.nextIntRange(0, 360), rand.nextIntRange(0, 100), rand.nextIntRange(20, 75));
				mortarColor = ((rand.nextDouble() < 0.5) ? 0 : ColorTools.hsv2hex(rand.nextIntRange(0, 360), 0, 60));
			}
			return this;
		}
		
		public function randomize():void
		{
			initFromSeed(Math.floor(Math.random() * 100000), Math.floor(Math.random() * 100000));
		}
		
		public function unserialize(val:String):void
		{
			var obj:* = null;
			var attrib:String;
			var i:int;
			
			try
			{
				obj = haxe.Unserializer.run(val);
			}
			catch (e:*)
			{
				trace("Unserializer error: " + e);
			}
			if (obj != null)
			{
				var g_attribs:Array = obj["g"];
				var r_attribs:Array = obj["r"];
				var diffuse_color:int = obj["c"];
				var mortar_color:int = obj["c2"];
				
				if (g_attribs != null && r_attribs != null)
				{
					initFromSeed(g_attribs[0], r_attribs[0]);
					
					for (i = 0; i < g_attribs.length; i++)
					{
						attrib = TextureAttributes.geometryAttribs[i];
						this[attrib] = g_attribs[i];
					}
					
					for (i = 0; i < r_attribs.length; i++)
					{
						attrib = TextureAttributes.renderingAttribs[i];
						this[attrib] = r_attribs[i];
						
					}
					
					if (!isNaN(diffuse_color))
						diffuseColor = diffuse_color;
					if (!isNaN(mortar_color))
						mortarColor = mortar_color;
				}
			}
		}
		
		public function serialize():String
		{
			var g_attribs:Array = [];
			var r_attribs:Array = [];
			var attrib:String;
			var default_attribs:TextureAttributes = new TextureAttributes().initFromSeed(seed, rseed);
			var geometry_tweaked:Boolean = false;
			var rendering_tweaked:Boolean = false;
			var i:int;
			
			for (i = 0; i < geometryAttribs.length; i++)
			{
				attrib = geometryAttribs[i];
				g_attribs.push(this[attrib]);
				if (!geometry_tweaked && this[attrib] != default_attribs[attrib])
					geometry_tweaked = true;
			}
			
			for (i = 0; i < renderingAttribs.length; i++)
			{
				attrib = renderingAttribs[i];
				r_attribs.push(this[attrib]);
				if (!rendering_tweaked && this[attrib] != default_attribs[attrib])
					rendering_tweaked = true;
			}
				
			if (!geometry_tweaked)
				g_attribs = [seed];
			if (!rendering_tweaked)
				r_attribs = [rseed];
				
			var obj:* = {g: g_attribs, r: r_attribs, c: diffuseColor, c2: mortarColor}
			return haxe.Serializer.run(obj);
		}
		
		public function copy():TextureAttributes
		{
			var new_attribs:TextureAttributes = new TextureAttributes();
			var attrib:String;
			var i:int;
			
			for (i = 0; i < geometryAttribs.length; i++)
			{
				attrib = geometryAttribs[i];
				new_attribs[attrib] = this[attrib];
			}

			for (i = 0; i < renderingAttribs.length; i++)
			{
				attrib = renderingAttribs[i];
				new_attribs[attrib] = this[attrib];
			}
			
			new_attribs.diffuseColor = diffuseColor;
			new_attribs.mortarColor = mortarColor;
			return new_attribs;
		}
	}
}
