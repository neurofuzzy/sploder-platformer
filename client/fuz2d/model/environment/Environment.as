/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.model.environment {
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	import fuz2d.model.*;
	import fuz2d.model.object.*;
	import fuz2d.util.ColorTools;
	
	public class Environment {
		
		public static var ambientLevel:int = 1;
		
		private var _model:Model;
		private var _lights:Array;
		private var _cameras:Array;
		private var _distanceCue:Boolean = false;
		private var _groundFog:Boolean = false;
		
		private var _showSkyGradient:Boolean = false;
		private var _showGroundGradient:Boolean = false;
		private var _showMountains:Boolean = false;
		private var _showStars:Boolean = false;
		
		private var _skyColor:uint = 0x000033;
		private var _skyColor2:uint = 0x5588bb;
		private var _horizonColor:uint = 0x6699cc;
		private var _groundColorNear:uint = 0x666666;
		private var _groundColorFar:uint = 0x000000;
		private var _distanceCueColor:uint = 0x000000;
		private var _distanceCueAmount:Number = 1;
		private var _distanceCueDistance:Number = 300; 
		private var _groundFogColor:uint = 0x003366;
		private var _groundFogAmount:Number = 0.5;
		private var _groundFogDepth:Number = 100;
		
		public var skySymbol:String = "";
		public var midGroundSymbol:String = "";
		
		private var _defaultLight:OmniLight;
		public function get defaultLight():OmniLight { return _defaultLight; }
		
		//
		public function get model ():Model {
			return _model;
		}
		
		//
		public function get lights ():Array {
			return _lights;
		}
		
		//
		public function get cameras ():Array {
			return _cameras;
		}
		
		//
		public function get distanceCue ():Boolean {
			return _distanceCue;
		}
		public function set distanceCue (val:Boolean):void {
			_distanceCue = (val) ? true : false;
		}
		
		//
		public function get distanceCueColor ():uint {
			return _distanceCueColor
		}
		public function set distanceCueColor (val:uint):void {
			_distanceCueColor = (!isNaN(val)) ? val : _distanceCueColor;
		}
		
		//
		public function get distanceCueAmount ():Number {
			return _distanceCueAmount;
		}
		public function set distanceCueAmount (val:Number):void {
			_distanceCueAmount = (!isNaN(val)) ? val : _distanceCueAmount;
		}
		
		//
		public function get distanceCueDistance ():Number {
			return _distanceCueDistance;
		}
		public function set distanceCueDistance (val:Number):void {
			_distanceCueDistance = (!isNaN(val)) ? val : _distanceCueDistance;
		}	
		
		//
		public function get groundFog ():Boolean {
			return _groundFog;
		}
		public function set groundFog (val:Boolean):void {
			_groundFog = (val) ? true : false;
		}
		
		//
		public function set groundFogColor (val:uint):void {
			_groundFogColor = (!isNaN(val)) ? val : _groundFogColor;
		}
		
		//
		public function set groundFogAmount (val:Number):void {
			_groundFogAmount = (!isNaN(val)) ? val : _groundFogAmount;
		}
		
		//
		public function set groundFogDepth (val:Number):void {
			_groundFogDepth = (!isNaN(val)) ? val : _groundFogDepth;
		}
		
		//
		public function get skyColor ():uint {
			return _skyColor;
		}
		public function set skyColor (val:uint):void {
			_skyColor = (!isNaN(val)) ? val : _skyColor;
			_skyColor2 = ColorTools.getTintedColor(_skyColor, _horizonColor, 0.8);
		}
		
		//
		public function get skyColor2 ():uint {
			return _skyColor2;
		}
		
		
		//
		public function get horizonColor ():uint {
			return _horizonColor;
		}
		public function set horizonColor (val:uint):void {
			_horizonColor = (!isNaN(val)) ? val : _horizonColor;
			_skyColor2 = ColorTools.getTintedColor(_skyColor, _horizonColor, 0.7);
		}
		
		
		//
		public function get groundColorNear ():uint {
			return _groundColorNear;
		}
		public function set groundColorNear (val:uint):void {
			_groundColorNear = (!isNaN(val)) ? val : _groundColorNear;
		}

		//
		public function get groundColorFar ():uint {
			return _groundColorFar;
		}
		public function set groundColorFar (val:uint):void {
			_groundColorFar = (!isNaN(val)) ? val : _groundColorFar;
		}
		
		public function get showSkyGradient():Boolean { return _showSkyGradient; }
		
		public function set showSkyGradient(value:Boolean):void 
		{
			_showSkyGradient = value;
		}
		
		public function get showGroundGradient():Boolean { return _showGroundGradient; }
		
		public function set showGroundGradient(value:Boolean):void 
		{
			_showGroundGradient = value;
		}
		
		public function get showMountains():Boolean { return _showMountains; }
		
		public function set showMountains(value:Boolean):void 
		{
			_showMountains = value;
		}
		
		public function get showStars():Boolean { return _showStars; }
		
		public function set showStars(value:Boolean):void 
		{
			_showStars = value;
		}
		
		public function set show (val:Boolean):void {
			_showGroundGradient = _showMountains = _showSkyGradient = _showStars = (val) ? true : false;
		}
		
		//
		public function getAdjustedColor (origColor:uint, distance:Number, altitude:Number):uint {
			
			var fogAmount:Number;
			var distAmount:Number;
			var newColor:uint = origColor;
			
			if (_groundFog) {
				
				fogAmount = getGroundFogFactor(altitude);
				newColor = ColorTools.getTintedColor(newColor, _groundFogColor, fogAmount);
				
			}
			
			if (_distanceCue) {
				
				distAmount = getDistanceCueFactor(distance);
				newColor = ColorTools.getTintedColor(newColor, _distanceCueColor, distAmount);
				
			}
			
			return newColor;
			
		}
		
		//
		//
		public function getGroundFogFactor (altitude:Number):Number {
			return Math.max(0, Math.min(_groundFogAmount, (_groundFogDepth - altitude) / _groundFogDepth));
		}
		
		//
		//
		public function getDistanceCueFactor (distance:Number):Number {
			return Math.max(0, Math.min(_distanceCueAmount, distance / _distanceCueDistance));
		}
		
		protected var _shadowLight:ShadowLight;
		public function get shadowLight ():ShadowLight { return _shadowLight; }
		
		//
		//
		public function Environment (model:Model) {
			
			_model = model;
			_lights = [];
			_defaultLight = new AmbientLight();
			_defaultLight.model = model;
			_cameras = [];
			
		}
		
		//
		//
		public function addLight (light:OmniLight):OmniLight {
			
			if (_lights.length > 0 && _lights[0] == _defaultLight) removeLight(_defaultLight);
			
			light.model = model;
			light.environment = this;
			lights.push(light);
			light.cast(model.objects);
			
			if (light is ShadowLight) _shadowLight = light as ShadowLight;
			
			return light;
			
		}
		
		//
		//
		public function removeLight (light:OmniLight):Boolean {
			
			if (lights && lights.indexOf(light) != -1) {
				lights.splice(lights.indexOf(light), 1);
				light.deleted = true;
				light.destroy();
				return true;
			}
			
			return false;
			
		}
		
		//
		//
		public function castLightsOn (obj:Object2d):void {
			
			var i:uint = _lights.length;
			
			while (i--) {
				
				OmniLight(_lights[i]).castLightOn(obj);
				
			}
			
		}
		
		//
		//
		public function addCamera (camera:Camera2d):Camera2d {
			
			cameras.push(camera);
			return camera;
			
		}
		
		//
		//
		public function removeCamera (camera:Camera2d):void {
			
			cameras.splice(cameras.indexOf(camera), 1);
			camera.deleted = true;
			
		}	
		
		//
		//
		public function update ():void {
			
			for each (var light:OmniLight in _lights) if (light.moved) {

				light.cast();
				light.moved = false;
				
			}
			
		}
		
		//
		//
		public function end ():void {
			
			if (_lights) {
				for each (var light:OmniLight in _lights) {
					light.destroy();
				}
			}
			
			_lights = null;
			_cameras = null;
			_model = null;
			_defaultLight = null;
			
		}
		
		
	}
	
}
