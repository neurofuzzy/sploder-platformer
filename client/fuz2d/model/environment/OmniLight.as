/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.model.environment {

	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import fuz2d.model.*;
	import fuz2d.model.object.*;
	import fuz2d.util.Geom2d;
	
	public class OmniLight extends Object2d {
		
		protected var _enabled:Boolean = true;
		public function get enabled():Boolean { return _enabled; }
		
		public function set enabled(value:Boolean):void 
		{
			_enabled = value;
			if (!_enabled) uncast();
			else cast();

		}
		
		protected var _brightness:Number;
		protected var _color:uint;
		
		protected var _radius:Number;
		protected var _falloff:Number;
		
		public var environment:Environment;
		
		protected var _castedObjects:Array;
		
		//
		public function get brightness():Number {	
			return _brightness;	
		}
		public function set brightness (b:Number):void {
			_brightness = Math.max(b, 0);
			_brightness = Math.min(_brightness, 1);
			update();
		}

		//
		public function get color():uint {	
			return _color;
		}
		public function set color (c:uint):void {
			_color = c;
			update();
		}
		
		//
		public function get redComponent ():Number {
			return _color >> 16;
		}
		
		//
		public function get greenComponent ():Number {
			return _color >> 8 & 0xff;
		}
		
		//	
		public function get blueComponent ():Number {
			return _color & 0xff;
		}
		
		//
		public function get radius ():Number {
			return _radius;
		}
		public function set radius (b:Number):void {
			_radius = Math.abs(b);
			update();
		}
		
		//
		public function get falloff ():Number {
			return _falloff;
		}	
		public function set falloff (b:Number):void {
			_falloff = Math.abs(b);
			update();
		}
		
		override public function get width():Number { return _radius; }
		override public function set width(value:Number):void { super.width = value; }
		
		override public function get height():Number { return _radius; }
		override public function set height(value:Number):void { super.height = value; }
		
		
		//
		//
		public function OmniLight (parentObject:Point2d = null, x:Number = 0, y:Number = 0, brightness:Number = 1, color:uint = 0xffffff, radius:Number = 200, falloffRadius:Number = 100) {
			
			super(parentObject, x, y, 1);
			
			_castedObjects = [];
			
			_brightness = brightness;
			_color = color;
			
			_radius = radius;
			_falloff = falloffRadius;
			
			_renderable = false;
			
		}
		
		//
		//
		override public function update ():void {
			cast();
		}
		
		//
		//
		public function cast (objects:Array = null):void {
			
			uncast();
			
			if (!_enabled) return;
			
			if (objects == null) _castedObjects = objects = _model.getNearObjects(this, false);

			for each (var obj:Object2d in objects) castLightOn(obj);
			
			
		}
		
		protected function uncast ():void {
			
			if (_castedObjects != null) {
				
				var i:int = _castedObjects.length;
				
				while (i--) Object2d(_castedObjects[i]).unregisterLight(this);
				
			}
			
		}
		
		//
		//
		public function castLightOn (object:Object2d):void {
			
			object.registerLight(this, getLightLevel(object));
			
		}
		
		//
		//
		public function getLightLevel (object:Object2d):Number {

			var rad:Number = radius * radius + falloff * falloff;
			var dist:Number = Geom2d.squaredDistanceBetween(this, object);
			
			if (rad < dist) return 0;
			var m:Object = Math;
			
			var lightFalloff:Number = m.max(0, m.min(1, ((rad - dist) / m.max(1, falloff * falloff))));

			return m.min(1, brightness * lightFalloff);
			
		}
		
		//
		//
		public function getLightFactor (object:Object2d):Number {
			
			return brightness;
					
		}
		
		//
		//
		override public function destroy():void {

			if (_model && _model.objects) {
				var i:int = _model.objects.length;
				while (i--) Object2d(_model.objects[i]).unregisterLight(this);
			}

			if (environment != null) environment.removeLight(this);
			
			delete this;
			
		}
		
	}
	
}