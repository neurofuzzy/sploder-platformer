/**
* ...
* @author Default
* @version 0.1
*/

package fuz2d.screen.shape {
	
	import com.sploder.data.DataLoader;
	import com.sploder.util.Textures;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import fuz2d.action.physics.Vector2d;
	import fuz2d.library.ObjectFactory;
	import fuz2d.screen.shape.ViewSprite;
	
	import fuz2d.action.physics.MotionObject;
	import fuz2d.model.*;
	import fuz2d.model.environment.*;
	import fuz2d.model.object.*;
	import fuz2d.screen.*;
	import fuz2d.util.*;

	
	public class BipedDisplay extends AssetDisplay {
		
		protected var _hasHeadGraphic:Boolean;
		protected var _hasTorsoGraphic:Boolean;
		
		protected var _biped:Biped;
		
		protected var _body:Sprite;
		protected var _head:MovieClip;
		protected var _torso:Sprite;
		protected var _backpack:MovieClip;
		protected var _tail:Sprite;
		protected var _arm_lt:MovieClip;
		protected var _arm_rt:MovieClip;
		protected var _hand_lt:MovieClip;
		protected var _hand_rt:MovieClip;
		protected var _leg_lt:MovieClip;
		protected var _leg_rt:MovieClip;
		protected var _healthDisplay:Sprite;
		protected var _healthBar:MovieClip;
		protected var _healthBarWidth:Number;

		protected var _lean:Number = 0;
		
		protected var _tools_lt:ToolsetDisplay;
		protected var _tools_rt:ToolsetDisplay;
		protected var _tools_back:ToolsetDisplay;
		protected var _tools_head:ToolsetDisplay;
		protected var _armor:ArmorDisplay;
		protected var _headAvatar:Number = 0;
		
		protected var _originalZ:Number;
		
		//
		//
		public function BipedDisplay (view:View, container:ViewSprite) {
			
			_biped = Biped(container.objectRef);
			
			super(view, container);
			
			_container.objectRef.zSortChildNodes = false;
			
			_headAvatar = _biped.avatar;
			
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
			_torso = _body["torso"];
			if (_torso["backpack"] != null) _backpack = _torso["backpack"];
			_head = _body["head"];
			_head["avatar"] = _headAvatar;
			_arm_lt = _body["arm_lt"];
			_arm_rt = _body["arm_rt"];
			_hand_lt = _arm_lt["hand_lt"];
			_hand_rt = _arm_rt["hand_rt"];
			_leg_lt = _body["leg_lt"];
			_leg_rt = _body["leg_rt"];
			_healthDisplay = _clip["healthmeter"];
			if (_healthDisplay != null) {
				_healthBar = _healthDisplay["bar"];
				if (_healthBar != null) _healthBarWidth = _healthBar.width;
			}
			
			if (_body["tail"] != null) _tail = _body["tail"];

			var i:int;
			
			if (_hand_lt != null && Biped(_container.objectRef).tools_lt != null && Biped(_container.objectRef).tools_lt.numTools > 0) _tools_lt = new ToolsetDisplay(_container, _hand_lt, Biped(_container.objectRef).tools_lt);
			if (_hand_rt != null && Biped(_container.objectRef).tools_rt != null && Biped(_container.objectRef).tools_rt.numTools > 0) _tools_rt = new ToolsetDisplay(_container, _hand_rt, Biped(_container.objectRef).tools_rt);
			if (_torso != null && Biped(_container.objectRef).tools_back != null && Biped(_container.objectRef).tools_back.numTools > 0) _tools_back = new ToolsetDisplay(_container, _torso, Biped(_container.objectRef).tools_back);
			if (_head != null && Biped(_container.objectRef).tools_head != null && Biped(_container.objectRef).tools_head.numTools > 0) _tools_head = new ToolsetDisplay(_container, _head, Biped(_container.objectRef).tools_head);					
			
			if (Biped(_container.objectRef).armor.max > 0) _armor = new ArmorDisplay(this);
			
			//_biped.facing = Biped.FACING_CENTER;
			
			if (_healthDisplay != null) {
				_healthDisplay.y = 0 - _clip.height / 2 - 30;
			}
			
			_originalZ = _container.objectRef.z;
			
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
						
			var rects:Object = Textures.getRectsFor(textureName);
			var isPlayer:Boolean = (_container.objectRef.symbolName == "player");
			
			var r:Rectangle;
			var s:Sprite;
			var s2:Sprite;
			
			for (var key:String in rects)
			{
				s = Sprite(clip).getChildByName("body") as Sprite;
				
				if (!(rects[key] is Rectangle)) continue;
				if (isPlayer && key != "head") continue;
				
				if (s != null)
				{
					r = rects[key];
					
					if (r.width <= 1 || r.height <= 1) continue;
					
					if (key == "hand_lt") s = s.getChildByName("arm_lt") as Sprite;
					if (key == "hand_rt") s = s.getChildByName("arm_rt") as Sprite;
					
					if (s != null)
					{
						s = s.getChildByName(key) as Sprite;
						
						if (key == "arm_lt") s = s.getChildByName("arm") as Sprite;
						if (key == "arm_rt") s = s.getChildByName("arm") as Sprite;
						if (key == "leg_lt") s = s.getChildByName("leg") as Sprite;
						if (key == "leg_rt") s = s.getChildByName("leg") as Sprite;
						
						if (s != null)
						{	
							if (s.getChildByName("g2c"))
							{
								s2 = s.getChildByName("g2c") as Sprite;
								bounds = s2.getBounds(s);
								s2.visible = false;
								s2.parent.removeChild(s2);
							} else {
								bounds = s.getBounds(s);
							}
							
							if (key == "hand_rt" && s.getChildByName("hand")) s.getChildByName("hand").alpha = 0;
							if (key == "hand_rt" && s.getChildByName("cannon")) s.getChildByName("cannon").alpha = 0;
							if ((key == "hand_rt" || key == "hand_lt") && s.getChildByName("claw")) s.getChildByName("claw").alpha = 0;
							
							var sw:Number = bounds.width / r.width / 8;
							var sh:Number = bounds.height / r.height / 8;
							
							if (key == "head")
							{
								var ss:Number = Math.min(sw, sh);
								sw = sh = ss;
								m.createBox(sw, sh, 0, 0 - r.x * sw * 8 + bounds.x - ((r.width - 1) * sw * 8 - bounds.width) * 0.5, 0 - r.y * sh * 8 + bounds.y - ((r.height - 1) * sh * 8 - bounds.height));
							}
							else if (key == "torso")
							{
								//m.createBox(sw, sh, 0, 0 - r.x * sw + bounds.x, 0 - r.y * sh + bounds.y);
								m.createBox(sw, sh, 0, 0 - r.x * sw * 8 + bounds.x, 0 - r.y * sh * 8 + bounds.y);
							} else {
								sw = bounds.width / r.height / 8;
								sh = bounds.height / r.width / 8;
								//m.createBox(sw, sh, 0 - Math.PI * 0.5, bounds.x - (r.y * sw), bounds.y + (r.x * sh) + r.width * sh);
								m.createBox(sw, sh, 0 - Math.PI * 0.5, bounds.x - (r.y * sw * 8), bounds.y + (r.x * sh * 8) + r.width * sh * 8);
							}
							
							g = s.graphics;
							
							if (key == "head") {
								_head.stop();
								_hasHeadGraphic = true;
								if (s.getChildByName("g")) g = Sprite(s.getChildByName("g")).graphics;
							}
							
							if (key == "torso") _hasTorsoGraphic = true;
							
							g.clear();
							//g.lineStyle(1, 0xff0000);
							g.beginBitmapFill(bd, m, false, true);
							if (key == "head") g.drawRect(bounds.x + (bounds.width - (r.width - 1) * sw * 8) * 0.5, bounds.y + (bounds.height - (r.height - 1) * sh * 8), bounds.width - (bounds.width - (r.width - 1) * sw * 8), bounds.height - (bounds.height - (r.height - 1) * sh * 8));
							else g.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
							g.endFill();
							
							if (!isPlayer && (key == "hand_rt" || key == "hand_lt"))
							{
								for (var k:int = 0; k < s.numChildren; k++)
								{
									var tool:DisplayObject = s.getChildAt(k);
									if (tool is MovieClip) MovieClip(tool).gotoAndStop(2);
								}
							}
							
							success = true;
						}
					}
				}
			}
			
			if (success)
			{
				if (_tail) _tail.visible = false;
			}
				
			return success;
		}
		
		
		//
		//
	    override protected function draw(g:Graphics, clear:Boolean = true):void {
		
			super.draw(g, clear);
			
			if (_container.objectRef == null) return;
			
			updateStance();
			
			if (MotionObject(_container.objectRef.simObject).floating) {
				_container.objectRef.z = 5;
			} else {
				_container.objectRef.z = _originalZ;
			}
			
			var bclip:Sprite;
			
			for each (var bone:Bone in _biped.bones) {
				
				bclip = bone.getClip(_clip as Sprite);
				
				if (bclip == null) return;

				bclip.x = bone.x / bclip.parent.scaleX;
				bclip.y = 0 - bone.y / bclip.parent.scaleY;

				bclip.rotation = bone.rotation * Geom2d.rtd;
				
				if (_graphic == 0 || (bone.name != "head" && bone.name != "torso"))
				{
					bclip.scaleX = Math.abs(bclip.scaleX) * bone.scaleX;
					bclip.scaleY = Math.abs(bclip.scaleY) * bone.scaleY;
				}

			}
			
			if (_healthBar != null && _container.objectRef.attribs.health != null) {
				var hw:Number = Math.floor(_container.objectRef.attribs.health * _healthBarWidth);
				if (hw <= 0) {
					_healthDisplay.visible = false;
				} else if (hw != _healthBar.width) {
					_healthBar.width = hw;
					_healthBar.play();
				}
			}
			
			if (_tools_lt != null) _tools_lt.update();
			if (_tools_rt != null) _tools_rt.update();
			if (_tools_back != null) _tools_back.update();
			if (_tools_head != null) _tools_head.update();
			
			if (_armor != null) _armor.update();

		}

		public function updateStance ():void {
			
			if (_tools_rt) _tools_rt.facing = _biped.facing;
			//trace(_container.objectRef.symbolName, _head.scaleX);
			
			switch (_biped.facing) {
					
				case Biped.FACING_RIGHT:
					
					_leg_lt["leg"].scaleY = 1;
					_leg_rt["leg"].scaleY = 1;
					_arm_lt["arm"].scaleY = 1;
					_arm_rt["arm"].scaleY = -1;
					
					if (_backpack != null) {
						_backpack.x = -60;
						_backpack.y = -10;
					}
					
					_body.setChildIndex(_arm_lt, 0);
					_body.setChildIndex(_leg_lt, 1);
					_body.setChildIndex(_leg_rt, 2);
					_body.setChildIndex(_torso, 3);
					_body.setChildIndex(_head, 4);
					_body.setChildIndex(_arm_rt, 5);
					
					if (_tail != null) {
						_body.setChildIndex(_tail, 0);
						if (_tail.scaleX > 0) _tail.scaleX = 0 - _tail.scaleX;
					}

					if (!_hasHeadGraphic) {
						_head.gotoAndStop("left");
						if (_head.getChildByName("g2c")) MovieClip(_head.getChildByName("g2c")).gotoAndStop(_headAvatar * 5 + _head.currentFrame);
					} else if (_head.scaleX < 0) {
						_head.scaleX = -_head.scaleX;
					}
					
					if (_hasTorsoGraphic && _torso.scaleX < 0) _torso.scaleX = -_torso.scaleX;
					
					break;
					
				case Biped.FACING_LEFT:
					
					_leg_lt["leg"].scaleY = -1;
					_leg_rt["leg"].scaleY = -1;
					_arm_lt["arm"].scaleY = -1;
					_arm_rt["arm"].scaleY = 1;
					
					if (_backpack != null) {
						_backpack.x = 60;
						_backpack.y = -10;
					}
					
					_body.setChildIndex(_arm_rt, 0);
					_body.setChildIndex(_leg_rt, 1);
					_body.setChildIndex(_leg_lt, 2);
					_body.setChildIndex(_torso, 3);
					_body.setChildIndex(_head, 4);
					_body.setChildIndex(_arm_lt, 5);
					
					if (_tail != null) {
						_body.setChildIndex(_tail, 0);
						if (_tail.scaleX < 0) _tail.scaleX = 0 - _tail.scaleX;
					}
					
					if (!_hasHeadGraphic) {
						_head.gotoAndStop("right");
						if (_head.getChildByName("g2c")) MovieClip(_head.getChildByName("g2c")).gotoAndStop(_headAvatar * 5 + _head.currentFrame);
						trace(_headAvatar * 5, _head.currentFrame);
					} else if (_head.scaleX > 0) {
						_head.scaleX = -_head.scaleX;
					}
					
					if (_hasTorsoGraphic && _torso.scaleX > 0) _torso.scaleX = -_torso.scaleX;

					break;
					
				case Biped.FACING_BACK:
					
					if (!_hasHeadGraphic) {
						_head.gotoAndStop("back");
						if (_head.getChildByName("g2c")) MovieClip(_head.getChildByName("g2c")).gotoAndStop(_headAvatar * 5 + _head.currentFrame);
					}
					_leg_lt["leg"].scaleY = 1;
					_leg_rt["leg"].scaleY = -1;
					_arm_lt["arm"].scaleY = -1;
					_arm_rt["arm"].scaleY = -1;
					
					if (_backpack != null) {
						_backpack.x = 0;
						_backpack.y = -30;
					}
					
					_body.setChildIndex(_leg_lt, 0);
					_body.setChildIndex(_leg_rt, 1);
					_body.setChildIndex(_torso, 2);
					_body.setChildIndex(_head, 3);
					_body.setChildIndex(_arm_lt, 4);
					_body.setChildIndex(_arm_rt, 5);
					
					if (_tail != null) {
						_body.setChildIndex(_tail, 0);
					}
					
					break;					
					
				case Biped.FACING_CENTER:
				default:
					
					if (!_hasHeadGraphic) {
						_head.gotoAndStop("center");
						if (_head.getChildByName("g2c")) MovieClip(_head.getChildByName("g2c")).gotoAndStop(_headAvatar * 5 + _head.currentFrame);
					}
					_leg_lt["leg"].scaleY = 1;
					_leg_rt["leg"].scaleY = -1;
					_arm_lt["arm"].scaleY = -1;
					_arm_rt["arm"].scaleY = -1;
					
					if (_backpack != null) {
						_backpack.x = 0;
						_backpack.y = -30;
					}
					
					_body.setChildIndex(_leg_lt, 0);
					_body.setChildIndex(_leg_rt, 1);
					_body.setChildIndex(_torso, 2);
					_body.setChildIndex(_head, 3);
					_body.setChildIndex(_arm_lt, 4);
					_body.setChildIndex(_arm_rt, 5);
					
					if (_tail != null) {
						_body.setChildIndex(_tail, 0);
					}
					
					break;				
				
			}

		}
	
	}
	
}
