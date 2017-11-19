/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.model.material {

	import flash.display.BitmapData;
	
	public class Material {
		
		protected var _color:uint;
		protected var _emissivity:uint = 0x000000;
		protected var _redEmissivity:uint = 0;
		protected var _greenEmissivity:uint = 0;
		protected var _blueEmissivity:uint = 0;
		protected var _self_illuminate:Boolean = false;
		protected var _opacity:Number = 1;
		protected var _falloff:Number = 0;
		protected var _falloffRatio:Number = 0.5;
		protected var _twoSided:Boolean;
		protected var _glow:Boolean;
		protected var _glowColor:Number = 0xffffff;
		protected var _flicker:Boolean = false;
		protected var _blur:int = 0;
		protected var _showDamage:Boolean = false;

		//
		public function get color ():uint {
			return _color;
		}
		public function set color (val:uint):void {
			_color = (!isNaN(val)) ? val : _color;
		}
		
		//
		public function get redComponent ():int {
			return _color >> 16;
		}
		
		//
		public function get greenComponent ():int {
			return _color >> 8 & 0xff;
		}
		
		//	
		public function get blueComponent ():int {
			return _color & 0xff;
		} 

		//
		public function get emissivity ():uint {
			return _emissivity;
		}
		public function set emissivity (val:uint):void {
			_emissivity = (!isNaN(val)) ? val : _emissivity;
			_redEmissivity = _emissivity >> 16;
			_greenEmissivity = _emissivity >> 8 & 0xff;
			_blueEmissivity = _emissivity & 0xff;
		}
		
		//
		public function get redEmissivity ():int {
			return _redEmissivity;
		}
		
		//
		public function get greenEmissivity ():int {
			return _greenEmissivity;
		}
		
		//	
		public function get blueEmissivity ():int {
			return _blueEmissivity;
		}
		
		//
		public function get opacity ():Number {
			return _opacity;
		}
		public function set opacity (val:Number):void {
			_opacity = (val >= 0 && val <= 1) ? val : _opacity;
		}
		
		//
		public function get falloff():Number { return _falloff; }
		
		public function set falloff(value:Number):void 
		{
			_falloff = Math.max(-1, Math.min(1, value));
		}
		
		//
		public function get glow():Boolean { return _glow; }
		
		public function set glow(value:Boolean):void 
		{
			_glow = value;
		}
		
		public function get glowColor():Number { return _glowColor; }
		
		public function set glowColor(value:Number):void 
		{
			_glowColor = value;
		}
		
				
		protected var _allowEffects:Boolean = true;

		public function get allowEffects():Boolean { return _allowEffects; }
		
		public function set allowEffects(value:Boolean):void 
		{
			_allowEffects = value;
		}
		
		
		
		public function get self_illuminate():Boolean { return _self_illuminate; }
		
		public function set self_illuminate(value:Boolean):void 
		{
			_self_illuminate = value;
		}
		
		public function get falloffRatio():Number { return _falloffRatio; }
		
		public function set falloffRatio(value:Number):void 
		{
			_falloffRatio = value;
		}
		
		protected var _cor:Number = 0.5;
		public function get cor():Number { return _cor; }
		public function set cor(value:Number):void { _cor = value; }
		
		protected var _cof:Number = 0.5;
		public function get cof():Number { return _cof; }
		public function set cof(value:Number):void { _cof = value; }
		
		public function get flicker():Boolean { return _flicker; }
		
		public function set flicker(value:Boolean):void 
		{
			_flicker = value;
		}
		
		public function get showDamage():Boolean { return _showDamage; }
		
		public function set showDamage(value:Boolean):void 
		{
			_showDamage = value;
		}

	
		//
		// color:uint = 0xffffff
		// emissivity:uint = 0x000000
		// opacity:Number = 1
		// texturemap:TextureMap = null
		// glow:Boolean = false
		// self_illuminate:Boolean = false
		// blur:int = 0
		public function Material(options:Object = null) {
			
			if (options != null) {
				
				if (options.color != null) _color = parseInt(options.color, 16);
				if (options.emissivity != null) emissivity = parseInt(options.emissivity);
				if (options.opacity != null) _opacity = Math.min(1, Math.max(0, parseFloat(options.opacity)));
				if (options.glow != null) _glow = (options.glow == "1");
				if (options.self_illuminate != null) _self_illuminate = true;
				if (options.flicker != null) _flicker = true;
				if (options.effects != null && (options.effects == "false" || options.effects == "0")) _allowEffects = false;
				if (options.cor != null) _cor = parseFloat(options.cor);
				if (options.cof != null) _cof = parseFloat(options.cof);
				if (options.damage != null) _showDamage = (options.damage == "1");
			
			}
			
			

		}
		
	}
	
}
