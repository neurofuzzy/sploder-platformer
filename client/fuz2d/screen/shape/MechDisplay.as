/**
* ...
* @author Default
* @version 0.1
*/

package fuz2d.screen.shape {

	import com.sploder.util.Textures;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import fuz2d.library.ObjectFactory;
	import fuz2d.screen.shape.ViewSprite;
	
	import fuz2d.model.*;
	import fuz2d.model.environment.*;
	import fuz2d.model.object.*;
	import fuz2d.screen.*;
	import fuz2d.util.*;

	
	public class MechDisplay extends AssetDisplay {
		
		protected var _mech:Mech;
		
		protected var _body:Sprite;
		protected var _head:MovieClip;
		protected var _windshield:MovieClip;
		protected var _arm_lt:MovieClip;
		protected var _arm_rt:MovieClip;
		protected var _leg_lt:MovieClip;
		protected var _leg_rt:MovieClip;
		protected var _healthDisplay:Sprite;
		protected var _healthBar:MovieClip;
		protected var _healthBarWidth:Number;

		protected var _lean:Number = 0;
		protected var _legX:Number = 0;
		protected var _legY:Number = 0;
		
		//
		//
		public function MechDisplay (view:View, container:ViewSprite) {
			
			_mech = Mech(container.objectRef);
			
			super(view, container);
			
			_container.objectRef.zSortChildNodes = false;
			
			assign();

		}
		
		//
		//
		override protected function init(view:View, container:ViewSprite):void {
			
			super.init(view, container);
			
		}
		
		//
		//
		protected function assign ():void {
			
			_body = _clip["body"];
			_head = _body["head"];
			_windshield = _head["windshield"];
			_arm_lt = _body["arm_lt"];
			_arm_rt = _body["arm_rt"];
			_leg_lt = _body["leg_lt"];
			_leg_rt = _body["leg_rt"];
			_healthDisplay = _clip["healthmeter"];
			
			_legX = _leg_rt.x;
			_legY = _leg_rt.y;
			
			if (_healthDisplay != null) {
				_healthBar = _healthDisplay["bar"];
				if (_healthBar != null) _healthBarWidth = _healthBar.width;
			}
			
			var i:int;
			
			if (_healthDisplay != null) {
				_healthDisplay.y = 0 - _clip.height / 2 - 30;
			}
			
			if (_container != null && _container.objectRef != null && _container.objectRef.graphic > 0)
			{
				_graphic = _container.objectRef.graphic 
				_graphic_version = _container.objectRef.graphic_version;
				_graphic_animation = _container.objectRef.graphic_animation;
				drawGraphic(_clip as Sprite);
			}
		}
		
		
		override protected function drawGraphic(clip:Sprite = null):Boolean 
		{
			if (_graphic == 0) return false;
			
			var textureName:String = _graphic + "_" + _graphic_version;
			
			var bd:BitmapData = Textures.getScaledBitmapData(textureName, 8, 0, this);
			
			var m:Matrix = new Matrix();
			var bounds:Rectangle;
			var g:Graphics;
			var success:Boolean;
			
			var r:Rectangle;
			var s:Sprite;
			var s2:Sprite;
			
			var sw:Number;
			var sh:Number;
						
			var rects:Object = Textures.getRectsFor(textureName);
			
			var clips:Array = ["head", "arm_rt/upper", "arm_rt/punch", "arm_lt/upper", "arm_lt/punch", "leg_rt", "leg_lt"];
			var cliprects:Array = ["head", "upper", "punch", "upper", "punch", "leg", "leg"];
			
			for (var k:int = 0; k < clips.length; k++)
			{
				s = Sprite(clip).getChildByName("body") as Sprite;
				
				var clips_parts:Array = clips[k].split("/");
				s = s.getChildByName(clips_parts[0]) as Sprite;
				if (clips_parts.length > 1) s = s.getChildByName(clips_parts[1]) as Sprite;
				
				if (!(rects[cliprects[k]] is Rectangle)) continue;
				
				if (s != null)
				{
					r = rects[cliprects[k]];
					
					if (r.width <= 1 || r.height <= 1) continue;
					
					if (s != null)
					{
						if (s.getChildByName("g2c"))
						{
							s2 = s.getChildByName("g2c") as Sprite;
							bounds = s2.getBounds(s);
							s2.visible = false;
						} else {
							bounds = s.getBounds(s);
						}
						
						sw = bounds.width / r.width / 8;
						sh = bounds.height / r.height / 8;
						
						m.createBox(sw, sh, 0, 0 - r.x * sw * 8 + bounds.x, 0 - r.y * sh * 8 + bounds.y);
						
						g = s.graphics;
						g.clear();
						//g.lineStyle(1, 0xff0000);
						g.beginBitmapFill(bd, m, false, true);
						g.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
						g.endFill();
					}
				}
			}	
			
			return success;
		}
		
		
		//
		//
	    override protected function draw(g:Graphics, clear:Boolean = true):void {
		
			super.draw(g, clear);
			
			if (_container.objectRef == null) return;
			
			updateStance();
			
			if (_healthBar != null && _container.objectRef.attribs.health != null) {
				var hw:Number = Math.floor(_container.objectRef.attribs.health * _healthBarWidth);
				if (hw <= 0) {
					_healthDisplay.visible = false;
				} else if (hw != _healthBar.width) {
					_healthBar.width = hw;
					_healthBar.play();
				}
			}
			
			if (_mech.boarded) {
				
				if (_windshield && _windshield.rotation > 0) {
					
					_windshield.rotation -= 10;
					
				}
							
				
			} else {
				
				if (_windshield && _windshield.rotation < 90) {
					
					_windshield.rotation += 10;
					
				}
				
			}

		}

		public function updateStance ():void {
			
			switch (_mech.facing) {
					
				case Mech.FACING_RIGHT:
					
					_body.scaleX = -1;
					break;
					
				case Mech.FACING_LEFT:
					
					_body.scaleX = 1;
					break;
				
			}
			
			_leg_lt.x = _mech.footPointLeft.x + _legX;
			_leg_lt.y = _mech.footPointLeft.y + _legY;
			
			_leg_rt.x = _mech.footPointRight.x + _legX;
			_leg_rt.y = _mech.footPointRight.y + _legY;
			
			if (_mech.state == Mech.STATE_PUNCHING) {
				
				_arm_rt.rotation = _arm_lt.rotation = 0;
				
				if (_arm_rt.currentFrame == 10) {
					_arm_lt.play();
					_arm_rt.gotoAndStop(1);
				} else if (_arm_lt.currentFrame == 10) {
					_arm_rt.play();
					_arm_lt.gotoAndStop(1);
				} else if (_arm_rt.currentFrame == 1 && _arm_lt.currentFrame == 1) {
					_arm_lt.play();
				}
				
				var punch:Sprite;
				
				if (_arm_lt.currentFrame == 2 && _arm_lt["punch"]) punch = Sprite(_arm_lt["punch"]);
				if (_arm_rt.currentFrame == 2 && _arm_rt["punch"]) punch = Sprite(_arm_rt["punch"]);	
				
				if (punch) {
					var pt:Point = new Point();
					pt.x = punch.x + punch.parent.x + punch.parent.parent.x;
					pt.y = punch.y + punch.parent.y + punch.parent.parent.y;
					if (_mech.facing == Mech.FACING_RIGHT) pt.x = 0 - pt.x;
					pt.y = 0 - pt.y;
					pt = pt.add(_container.objectRef.point);
					_mech.attribs.punchPoint = pt;
				}
				
			} else {
				
				_arm_rt.rotation = _mech.footPointLeft.x * 0.5;
				_arm_lt.rotation = 0 - _arm_rt.rotation;
				_arm_lt.gotoAndStop(1);
				_arm_rt.gotoAndStop(1);
			
			}
			
			

		}
		
		override public function destroy():void {

			super.destroy();
			
		}
	
	}
	
}
