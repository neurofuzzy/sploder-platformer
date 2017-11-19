/**
* com.sploder: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.model.object {
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import fuz2d.action.physics.SimulationObject;
	import fuz2d.screen.shape.ViewObject;

	import fuz2d.model.*;
	import fuz2d.model.environment.*;
	import fuz2d.model.material.*;
	import fuz2d.model.object.*;
	import fuz2d.util.Geom2d;
	
	import flash.utils.Dictionary;

	public class Object2d extends Container2d {
		
		public var idx:Number = 0;
		public var cid:int;
		
		public var frozen:Boolean = false;
		
		override public function get model():Model { return super.model; }
		
		override public function set model(value:Model):void 
		{
			super.model = value;
			idx = _z + _model.objIdx;
		}
		
		public function get xpos ():Number { return super.x; }
		public function set xpos (val:Number):void { 
			var isNew:Boolean = (val != x);
			x = val;
			if (isNew) _moved = true;
		}
		
		public function get ypos ():Number { return super.y; }
		public function set ypos (val:Number):void { 
			var isNew:Boolean = (val != y);
			y = val;
			if (isNew) _moved = true;
		}
		
		public function get zDepth ():Number { return _z * 100000 + idx };
		
		protected var _width:Number;
		public function get width():Number { return _width; }
		public function set width(value:Number):void { _width = value; }
		
		protected var _height:Number;
		public function get height():Number { return _height; }
		public function set height(value:Number):void { _height = value; }
		
		protected var _scaleX:Number = 1;
		protected var _scaleY:Number = 1;
		
		public var graphic:Number = 0;
		public var graphic_version:Number = 0;
		public var graphic_animation:Number = 0;
		public var graphic_rectnames:Array;
		
		protected var _material:Material;
		public function get material ():Material { return _material; }
		
		protected var _lights:Dictionary;
		protected var _lightLevelChanged:Boolean = true;
		public function set lightLevelChanged (val:Boolean):void { _lightLevelChanged = val; }
		
		protected var _computedColor:Number;
		protected var _tintColor:Number;
		protected var _tintLevel:Number;
		
		public var tintRed:Number = 0;
		public var tintGreen:Number = 0;
		public var tintBlue:Number = 0;
		
		public var castShadow:Boolean = false;
		public var receiveShadow:Boolean = true;
		
		protected var _symbolName:String;
		public function get symbolName():String { return _symbolName; }
		public function set symbolName(value:String):void { _symbolName = value; }
		
		protected var _simObject:SimulationObject;
		public function get simObject():SimulationObject { return _simObject; }
		public function set simObject(value:SimulationObject):void { _simObject = value; }
		
		protected var _viewObject:ViewObject;	
		public function get viewObject():ViewObject { return _viewObject; }
		public function set viewObject(value:ViewObject):void { _viewObject = value; }
		
		public var controlled:Boolean = false;

		public var attribs:Object;
		
		// CHANGE
		// ------------------------------------------------

		//
		//
		public function get computedColor ():uint {
		
			if (!_lightLevelChanged && !isNaN(_computedColor)) {
				return _computedColor;
			}
			
			var currentLight:OmniLight;
			var currentLightPower:Number;
			
			var mt:Material = _material;

			var red:Number = mt.redComponent;
			var green:Number = mt.greenComponent;
			var blue:Number = mt.blueComponent;
			
			var redTotal:Number = 0;
			var greenTotal:Number = 0;
			var blueTotal:Number = 0;
			
			for each (var light:OmniLight in _lights) {
				
				if (light.enabled) {
					
					currentLight = light;
					currentLight.castLightOn(this);
					currentLightPower = _lights[light];

					if (!isNaN(currentLightPower)) {
						redTotal += currentLight.redComponent * currentLightPower;
						greenTotal += currentLight.greenComponent * currentLightPower;
						blueTotal += currentLight.blueComponent * currentLightPower;
					}
					
				}
				
			}

			if (mt.emissivity != 0x000000) {
				if (mt.self_illuminate) {
					redTotal += mt.redEmissivity;
					greenTotal += mt.greenEmissivity;
					blueTotal += mt.blueEmissivity;				
				} else {
					redTotal += (redTotal / 255) * mt.redEmissivity;
					greenTotal += (greenTotal / 255) * mt.greenEmissivity;
					blueTotal += (blueTotal / 255) * mt.blueEmissivity;
				}
			}
			
			var m:Object = Math;
			
			redTotal = m.max(0, m.min(255, redTotal));
			greenTotal = m.max(0, m.min(255, greenTotal));
			blueTotal = m.max(0, m.min(255, blueTotal));
			
			redTotal /= 255;
			greenTotal /= 255;
			blueTotal /= 255;
			
			red *= redTotal;
			green *= greenTotal;
			blue *= blueTotal;
			
			_computedColor = red << 16 | green << 8 | blue;
			
			_lightLevelChanged = false;
			
			return _computedColor;
			
		}
		
		//
		//
		public function get tintColor ():uint {
		
			if (!_lightLevelChanged && !isNaN(_tintColor)) return _tintColor;
			
			var currentLight:OmniLight;
			var currentLightPower:Number;
			
			var redTotal:Number = 0;
			var greenTotal:Number = 0;
			var blueTotal:Number = 0;
			
			for (var light:Object in _lights) {
				
				if (light is OmniLight && OmniLight(light).enabled) {
					
					currentLight = OmniLight(light);
					currentLight.castLightOn(this);
					currentLightPower = _lights[light];

					if (!isNaN(currentLightPower)) {
						redTotal += currentLight.redComponent * currentLightPower;
						greenTotal += currentLight.greenComponent * currentLightPower;
						blueTotal += currentLight.blueComponent * currentLightPower;
						if (redTotal == 255 && greenTotal == 255 && blueTotal == 255) {
							_tintLevel = 0;
							_tintColor = 0xffffff;
							return _tintColor;
						}
					}
					
				}
				
			}
			
			redTotal += _material.redEmissivity;
			greenTotal += _material.greenEmissivity;
			blueTotal += _material.blueEmissivity;
			
			var m:Object = Math;
			
			redTotal = m.max(0, m.min(255, redTotal));
			greenTotal = m.max(0, m.min(255, greenTotal));
			blueTotal = m.max(0, m.min(255, blueTotal));
			
			_tintLevel = 1 - m.min(redTotal, greenTotal, blueTotal) / 255;
			
			_tintColor = redTotal << 16 | greenTotal << 8 | blueTotal;
			
			tintRed = redTotal - 255;
			tintGreen = greenTotal - 255;
			tintBlue = blueTotal - 255;
			
			return _tintColor;
			
		}
		
		//
		public function get tintLevel ():Number {
			return _tintLevel;
		}
		
		//
		protected var _clickable:Boolean;
		protected var _onClick:Function;
		protected var _onPress:Function;
		protected var _onRelease:Function;
		protected var _onRollOver:Function;
		protected var _onRollOut:Function;
		
		public function get clickable():Boolean { return _clickable; }

		public function get onClick():Function { return _onClick; }
		public function set onClick(value:Function):void { 
			_onClick = value;
			_clickable = (onClick != null || onPress != null || onRelease != null);
		}
		
		public function get onPress():Function { return _onPress; }
		public function set onPress(value:Function):void { 
			_onPress = value;
			_clickable = (onClick != null || onPress != null || onRelease != null);
		}
		
		public function get onRelease():Function { return _onRelease; }
		public function set onRelease(value:Function):void { 
			_onRelease = value;
			_clickable = (onClick != null || onPress != null || onRelease != null);
		}
		
		public function get onRollOver():Function { return _onRollOver; }
		public function set onRollOver(value:Function):void { _onRollOver = value;}
		
		public function get onRollOut():Function { return _onRollOut; }
		public function set onRollOut(value:Function):void { _onRollOut = value; }
		
		public function get scaleX():Number { return _scaleX; }
		public function get scaleY():Number { return _scaleY; }
		
		
		public function handleClick (e:MouseEvent):void {
			if (clickable && onClick != null) {
				try {
					onClick(e);
				} catch (e:Error) {
					trace("Object2d handleClick:", e);
				}
			}
		}
		
		//
		//
		//
		public function Object2d (parentObject:Point2d, x:Number = 0, y:Number = 0, z:Number = 0, rotation:Number = 0, scale:Number = 1, material:Material = null, symbolName:String = "", controlled:Boolean = false) {

			super(parentObject, x, y, z);
			
			_rotation = rotation;
			_scale = scale;
			
			if (material != null) {
				_material = material;
			} else {
				_material = new Material();
			}
			
			_symbolName = symbolName;
			this.controlled = controlled;
			
			_lights = new Dictionary(true);
			_renderable = false;
			
			_computedColor = 0;
			
			attribs = { };
			
		}
		
		//
		//
		//
		public function translate (dx:Number, dy:Number):void {
			
			pt.offset(dx, dy);
			
			_lightLevelChanged = true;
			update();
			
		}
		
		
		
		//
		//
		//
		public function rotate (angle:Number):void {
			
			_rotation += angle;
			
			update();
			
		}
		
		//
		//
		public function positionRelative (obj:Point):Point {
			
			var pt:Point = new Point(obj.x - x, obj.y - y);
			var mag:Number = pt.length;
			var rot:Number = Math.atan2(pt.y, pt.x);
			
			return Point.polar(mag, rotation + rot);
			
		}
		
		//
		//
		public function positionWorld (pt:Point):Point {
			
			pt = pt.clone();
			var mag:Number = pt.length;
			var rot:Number = Math.atan2(pt.y, pt.x);
			
			pt = Point.polar(mag, rot - rotation);
			pt.x += x;
			pt.y += y;
			
			return pt;
			
		}
		
		//
		//
		public function registerLight (light:OmniLight, lightLevel:Number):void {
			
			_lights[light] = lightLevel;
			_lightLevelChanged = true;

		}
		
		//
		//
		public function unregisterLight (light:OmniLight):void {
			
			if (_lights && _lights[light] != null) {
				
				delete _lights[light];

				_lightLevelChanged = true;

			} 
			
		}
		
		public function clearLights ():void {
			
			_lights = new Dictionary(true);
			
		}
		
		override public function update():void {
			
			if (_model) _model.update(this);
			
		}
		
		override public function destroy():void {
			
			if (frozen) return;
			 
			if (simObject != null && !simObject.deleted) simObject.destroy();
			//_simObject = null;
			
			_viewObject = null;

			if (_model != null) {
				_model.removeObject(this);
				_model = null;
			}
			
			_material = null;
			_lights = null;
			
			attribs = null;
			
			super.destroy();
			
		}
		
	}
	
}
