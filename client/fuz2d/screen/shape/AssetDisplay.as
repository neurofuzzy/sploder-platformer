/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.screen.shape {
	
	import com.sploder.util.Textures;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.FrameLabel;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import fuz2d.action.physics.Simulation;
	import fuz2d.library.ObjectFactory;
	import fuz2d.model.*;
	import fuz2d.model.environment.*;
	import fuz2d.model.object.*;
	import fuz2d.screen.*;
	import fuz2d.screen.effect.EffectManager;
	import fuz2d.screen.shape.ViewSprite;
	import fuz2d.TimeStep;
	import fuz2d.util.*;

	
	public class AssetDisplay extends Polygon {
		
		protected var _clipAdded:Boolean = false;
		protected var _clip:DisplayObject;
		public function get clip():DisplayObject { return _clip; }
		
		protected var _graphic:int = 0;
		protected var _graphics:Graphics;
		protected var _graphic_version:int = 0;
		protected var _graphic_animation:int = 0;
		protected var _graphic_currentFrame:int = 0;
		protected var _graphic_currentDrawnFrame:int = 0;
		protected var _graphic_totalFrames:int = 0;

		protected var _colorTransform:ColorTransform;
		protected var _cachedTintColor:int = -1;
		
		protected var _effects:EffectManager;
		
		protected var _state:String = "";
		
		protected var _isPlaying:Boolean = true;
		protected var _isSymbol:Boolean = false;
		
		private var _wrapped:Boolean;
		
		private var _action:String;
		
		private var _stopped:Boolean = false;
		
		private var _lastSmoke:Number = 0;
		
		public function set playing (value:Boolean):void {
			
			if (_clip is MovieClip) {
				
				if (value && !_isPlaying) {
					
					if (!_stopped && MovieClip(_clip)["stopped"] != true) {
						_isPlaying = true;
						MovieClip(_clip).play();
					}
		
				} else if (!value && _isPlaying) {

					_isPlaying = false;
					MovieClip(_clip).stop();
					
				}
				
			}
			
		}
		
		//
		//
		public function AssetDisplay (view:View, container:ViewSprite) {
			
			super(view, container);
			
			var co:Object2d = _container.objectRef;
			
			if (co != null)
			{
				co.zSortChildNodes = false;
				
				if (co != null && co.graphic > 0) {
					
					_graphic = co.graphic;
					_graphic_version = co.graphic_version;
					_graphic_animation = co.graphic_animation;
					
				}
				
				if (co is Symbol) addAsset();
			}
			
		}
		
		override protected function init(view:View, container:ViewSprite):void {
			
			_view = view;
			_container = container;
			
		}

		//
		//
		public function addAsset ():void {
			
			var symbol:Symbol = Symbol(_container.objectRef);
			
			_isSymbol = true;
			
			if (!_clipAdded) {
							
				if (symbol.cacheAsBitmap) {
					
					if (_graphic > 0) {
						
						_clipAdded = drawGraphic();
						
					} else {
					
						_clip = symbol.clipAsBitmap;
						_clip.x -= _clip.width * 0.5 / View.scale;
						_clip.y -= _clip.height * 0.5 / View.scale;
						_clip.cacheAsBitmap = false;
						
						_cacheAsBitmap = true;
					}
						
				} else {
					
					_clip = symbol.clip;
					if (_container.objectRef.scale != 1 && _container.objectRef.scale != 0) {
						_clip.scaleX = _clip.scaleY = _container.objectRef.scale;
						trace("scaling", _container.objectRef.scale);
					}
					
					if (_graphic > 0 && _clip is Sprite)
					{
						var s:Sprite = _clip as Sprite;
						
						var success:Boolean;
						
						if (s.numChildren > 0)
						{
							if (s.getChildByName("g") != null) 
							{
								success = drawGraphic(Sprite(s.getChildByName("g")));
								if (s.getChildByName("g2") != null) success = drawGraphic(Sprite(s.getChildByName("g2")));
							}
							else if (s.getChildByName("matte") != null) 
							{
								var sm:Sprite = s.getChildByName("matte") as Sprite;
								var sm2:Sprite = new Sprite();
								s.addChildAt(sm2, 0);
								sm2.x = sm.x;
								sm2.y = sm.y;
								success = drawGraphic(sm2);
								sm.parent.removeChild(sm);
								sm2.name = "matte";
							}
							
							if (success && s.getChildByName("g2c") != null) {
								if (s is MovieClip && MovieClip(s).totalFrames > 0)
								{
									s.getChildByName("g2c").visible = false;
								} else {
									s.removeChild(s.getChildByName("g2c"));
								}
							}
						}
					}
					
					if (_clip is Sprite &&
						_container.objectRef.attribs.message != null &&
						Sprite(_clip).getChildByName("message") != null) {
							
						var tf:TextField = TextField(Sprite(_clip).getChildByName("message"));
						
						if (tf) {
							if (GameLevel.gameEngine.viewClass == BitView) {
								tf.embedFonts = true;
								tf.defaultTextFormat = new TextFormat("PhinsterExtraBold", 20, null, null, null, null, null, null, null, 0, 0, 0, -3);
								tf.height += 5;
								tf.filters = [];
								tf.sharpness = 500;
								tf.cacheAsBitmap = true;
								tf.antiAliasType = AntiAliasType.ADVANCED;
							}
							tf.text = _container.objectRef.attribs.message.toUpperCase();
						}
							
						
					}
					
				}

				if (_clip != null) _clipAdded = true;
				else return;
				
				if (!_clipAdded) return;
				
				if (_container.objectRef is Tile || (_container.objectRef is Symbol && Symbol(_container.objectRef).cacheAsBitmap)) {
					
					_clip.scaleX = _clip.scaleY = 1 / View.scale;
					
				}else if (_container.objectRef is Symbol) {
					
					_clip.scaleX = Symbol(_container.objectRef).scaleX;
					_clip.scaleY = Symbol(_container.objectRef).scaleY;
					
				}
				
				_clip.name = "clip";
				Sprite(_container.dobj).addChild(_clip);
				
				_clipAdded = true;	
				if (_clip is MovieClip) {
					MovieClip(_clip)["app"] = this;
					MovieClip(_clip)["init"] = function ():void { this.stop(); this.stopped = true; }
					MovieClip(_clip)["init"]();
				}
				
				if (_clip is MovieClip) addFrameActions(_clip as MovieClip);
				
				if (_container.objectRef.material.flicker) {
						
					View.mainStage.addEventListener(Event.ENTER_FRAME, update);
						
				}
				
				if (!(_clip is Bitmap) && !(_clip is Shape) && _container.objectRef.symbolName.length > 0 && _clip["bounds"] != null) Sprite(_clip["bounds"]).visible = false;

				if (_effects == null && _container.objectRef.controlled && _container.objectRef.material.allowEffects) {
					_effects = new EffectManager(this);
				}
				
				// TESTING
				/*
				var gg:Sprite = new Sprite();
				_container.addChild(gg);
				var g:Graphics = gg.graphics;
				g.moveTo(0, -40);
				g.lineStyle(1,0xff0000, 0.5);
				g.lineTo(0, 40);
				g.moveTo( -40, 0);
				g.lineTo(40, 0);
				*/
				
			}
			
		}
		
		//
		//
		protected function addFrameActions (clip:MovieClip):void {
			
			for each (var lbl:FrameLabel in clip.currentLabels) if (lbl.name.charAt(0) != "f") clip.addFrameScript(lbl.frame - 1, onLabel);
	
		}
		
		//
		//
		protected function onLabel ():void {
			
			if (_container == null || _container.objectRef == null || _container.objectRef.deleted) return;

			var labelName:String = MovieClip(_clip).currentLabel;
			
			if (labelName.indexOf("action:") != -1 ) {
				
				_action = labelName.split(":")[1];
	
			} else {
				
				switch (labelName) {
					
					case "play":
						if (_clip is MovieClip) MovieClip(_clip).play();
						_stopped = false;
						break;
					case "reset":	
						Symbol(_container.objectRef).state = "";
						break;
					case "idle":
					case "sleep":
					case "wait":
						if (_clip is MovieClip) MovieClip(_clip).stop();
						_stopped = true;
						break;
						
					case "activate":
						Symbol(_container.objectRef).state = "z_active";
						break;
						
					case "deactivate":
						Symbol(_container.objectRef).state = "z_inactive";					
						break;
						
					case "end":
						_container.destroy();
						break;
						
					case "explode":
						_container.add("explosion", true);
						break;
						
					case "explodebig":
						_container.add("explosionbig", true);
						break;
				}
				
			}
			
		}
		
		//
		//
		public function update (e:Event):void {
			
			if (!_container.dobj.visible) return;
			
			if (_container.objectRef.material.flicker) _clip.alpha = 0.8 + Math.random() * 0.2;
			
		}
		
		public function get textureName ():String {
			if (_graphic > 0 && _graphic_version > 0) return _graphic + "_" + _graphic_version;
			return "";	
		}
		
		protected function getGraphicContainer ():void
		{
			
		}
		
		protected function drawGraphic (clip:Sprite = null):Boolean
		{
			var bd:BitmapData;
			
			if (_container.objectRef.graphic > 0) {
				
				bd = Textures.getScaledBitmapData(textureName, 8, _graphic_animation ? _graphic_currentFrame : 0, this);
				
				if (bd) {
					
					var symbol:Symbol = Symbol(_container.objectRef);
					
					var m:Matrix = new Matrix();
					var g:Graphics = _graphics;
					
					if (_graphics == null)
					{
						if (clip == null) 
						{
							_clip = new Shape();
							if (_container.objectRef.scale != 1 && _container.objectRef.scale != 0) _clip.scaleX = _clip.scaleY = _container.objectRef.scale;
							_graphics = g = Shape(_clip).graphics;
						} else {
							_graphics = g = clip.graphics;
						}
						
						if (_graphic_animation)
						{
							var abd:BitmapData = Textures.getOriginal(textureName);
							if (abd) _graphic_totalFrames = abd.width / abd.height;
						}
					}
					

					
					if (g != null)
					{
						g.clear();
						
						var w:Number = (clip != null && clip.width > 0) ? clip.getBounds(clip).width : symbol.width;
						var h:Number = (clip != null && clip.height > 0) ? clip.getBounds(clip).height : symbol.height;
						
						if (w / h <= 0.75)
						{
							m.createBox(h / (bd.height), h / (bd.height), 0, 0 - h / 2, 0 -  h / 2);
						} else if (w / h >= 1.49) {
							m.createBox(w / (bd.width), w / (bd.width), 0, 0 - w / 2, 0 - w / 2);
						} else {
							m.createBox(w / (bd.width), h / (bd.height), 0, 0 - w / 2,0 -  h / 2);
						}
						
						if (_container.objectRef.graphic_rectnames != null)
						{
							var rects:Object = Textures.getRectsFor(textureName);
							if (rects)
							{
								var rect:Rectangle = rects[_container.objectRef.graphic_rectnames[0]];
								if (rect)
								{
									if (rect.width <= 1 || rect.height <= 1) return false;
									
									var sw:Number = w / (rect.width * 8);
									var sh:Number = h / (rect.height * 8);
									
									m.createBox(sw, sh, 0, 0 - w / 2 - (rect.x * 8 * sw), 0 - h / 2 - (rect.y * 8 * sh));
								}
							}
						}
						
						g.beginBitmapFill(bd, m, false, true);
						g.drawRect(0 - w / 2, 0 - h / 2, w, h);
						g.endFill();
						
						_graphic_currentDrawnFrame = _graphic_currentFrame;
						
						
						return true;
					} else {
						trace("graphic is null");
					}
				} else {
					trace("graphic must not be loaded yet");
					
				}
			}
			
			return false;
		}
		
		//
		//
	    override protected function draw(g:Graphics, clear:Boolean = true):void {
			
			if (_clipAdded && _container.objectRef != null) {
				
				var ts:int = TimeStep.realTime;
				var co:Object2d = _container.objectRef;
				
				if (_effects != null && !_effects.initialized) _effects.initialize();
				
				if (_graphic_animation)
				{
					_graphic_currentFrame = Math.floor(ts / 250) % _graphic_totalFrames;
					if (_graphic_currentFrame != _graphic_currentDrawnFrame) drawGraphic();
				}
				
				if (!_view.fastDraw && co.material.self_illuminate != true &&
					!(_effects != null && _effects.affectsColor)) {
					
					var oc:Number = co.tintColor;
					
					if (true || oc != _cachedTintColor) {
					
						_cachedTintColor = oc;

						_colorTransform = _clip.transform.colorTransform;
						
						var ocolor:uint = _cachedTintColor;
						_colorTransform.redOffset = (ocolor >> 16) - 255;
						_colorTransform.greenOffset = (ocolor >> 8 & 0xff) - 255;
						_colorTransform.blueOffset = (ocolor & 0xff) - 255;

						if (_clip is Sprite && _clip["matte"] != null) _clip["matte"].transform.colorTransform = _colorTransform;
						else _clip.transform.colorTransform = _colorTransform;
					
					}
					
				}
				
				if (_clip is MovieClip) {
					if (_clip["onDraw"] != null && _clip["onDraw"] is Function) {
						_clip["onDraw"].apply(this);
					}
					if (co.material.showDamage && co.attribs.damage != undefined) {
						var d:Number = co.attribs.damage;
						if (d < 100) {
							MovieClip(_clip).gotoAndStop(d);
						} else if (MovieClip(_clip).currentFrame < 100) {
							MovieClip(_clip).gotoAndPlay(100);
						}
						
						if (d > 20 && ts - _lastSmoke > 250) {
							if (Math.random() * 150 < d) {
								ObjectFactory.effect(co, "damagesmoke");
								_lastSmoke = ts;
							}
						}
					}
				}
	
				if (_action != null) {
					
					switch (_action) {
						
						case "hover":
						
							_clip.y = Simulation.sineTime * 5;
						
					}
					
				}
				
				if (_isSymbol && co.attribs.dieTime != null) {
					if (ts - co.attribs.dieTime > 3000) {
						_container.destroy();
						return;
					}	
				}
				
				/*
				if (co.simObject != null && co.simObject.collisionObject.type == 6) {
					
					if (!_wrapped && co.simObject.collisionObject.vertices != null) {
						
						_wrapped = true;
						
						if (_clip is Sprite) {
							
							var g:Graphics = Sprite(_clip).graphics;
							var b:Array = co.simObject.collisionObject.vertices
							
							g.beginFill(0x00ffff);
							g.moveTo(b[0].x, 0 - b[0].y);
							for (var i:int = 0; i < b.length; i++) g.lineTo(b[i].x, 0 - b[i].y);
							g.endFill();
							
						}
						
					}
					
				}
				*/
				//_clip.visible = true;
				
				//_clip.scaleX = _clip.scaleY = _container.screenPt.scale;
				
				if (_isSymbol && !_cacheAsBitmap) {
					
					var s:Symbol = Symbol(co);
					
					_clip.scaleX = s.scaleX;
					_clip.scaleY = s.scaleY;

					if (_state != s.state) {
						
						_state = s.state;

						try {
							if (_clip is MovieClip && s.state.indexOf("z_") != 0) {
								if (s.state.indexOf("_stop") != -1) MovieClip(_clip).gotoAndStop(_state);
								else MovieClip(_clip).gotoAndPlay(_state);
							}
						} catch (e:Error)
						{
							trace("AssetDisplay draw:", e); 
						}
						
						_stopped = false;

					}
					
					var facing:* = co.attribs.facing;
					
					if (facing) {
						
						if (facing == 1) _clip.scaleX = -1;
						else if (facing == 2) _clip.scaleX = 1;
						
					}
					
				}
				
				if (co.material.glow) {
					
					if (_clip.filters.length == 0) {
						
						_clip.filters = [new GlowFilter(co.material.glowColor, 1, 20, 20, 5, 2)];
						
					}
					
				} else if (_clip.filters.length > 0) _clip.filters = [];

			}
			
		}

		//
		//
		override public function clear():void 
		{
			super.clear();
			
			View.mainStage.removeEventListener(Event.ENTER_FRAME, update);
			
		}
		
		override public function destroy():void 
		{
			super.destroy();
			
			if (_effects) {
				_effects.end();
				_effects = null;
			}
			if (_clip) {
				if (_clip.parent) _clip.parent.removeChild(_clip);
				_clip = null;
			}
			_colorTransform = null;
		}
	
	}
	
}
