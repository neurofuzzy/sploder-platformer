/**
* GameKit: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.behavior {
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import fuz2d.action.play.PlayfieldEvent;
	import fuz2d.library.ObjectFactory;
	import fuz2d.model.object.Symbol;
	import fuz2d.screen.morph.*;
	import fuz2d.screen.shape.ViewObject;
	import fuz2d.screen.shape.ViewSprite;
	import fuz2d.util.Geom2d;
	
	import fuz2d.action.physics.*;
	import fuz2d.action.play.PlayObject;

	public class DeathBehavior extends Behavior {
		
		public static const STYLE_REMOVE:String = "remove";
		public static const STYLE_PASSTHROUGH:String = "passthrough";
		public static const STYLE_BLOOM:String = "bloom";
		public static const STYLE_SHATTER:String = "shatter";
		public static const STYLE_EXPLODE:String = "explode";
		
		protected var _style:String;
		protected var _strength:int;
		protected var _radius:int;
		protected var _effectsSymbol:String;
		
		//
		//
		public function DeathBehavior (style:String = "remove", strength:int = 10, radius:int = 100, effectSymbol:String = "") {
			
			super();
			
			_style = style;
			_strength = strength;
			_radius = radius;
			_effectsSymbol = effectSymbol;
			
		}
		
		//
		//
		override protected function init(parentClass:BehaviorManager):void {
			
			super.init(parentClass);
			
			if (_parentClass.playObject != null) {
				_parentClass.playObject.addEventListener(PlayfieldEvent.DEATH, onDeath);
			}
			
		}
		
		//
		//
		public function onDeath (e:PlayfieldEvent):void {
			
			if (_parentClass.playObject != null && 
				_parentClass.playObject.object != null &&
				_parentClass.playObject.object.viewObject != null) {
					
				var vo:ViewObject = _parentClass.playObject.object.viewObject;
				
				if (_effectsSymbol.length > 0) {
					ObjectFactory.effect(_parentClass.playObject, _effectsSymbol, true);
				}
				
				if (_parentClass.playObject.simObject != null) {
					_parentClass.playObject.simObject.collisionObject.reactionType = ReactionType.PASSTHROUGH;
					if (_parentClass.playObject.simObject is MotionObject) {
						MotionObject(_parentClass.playObject.simObject).gravity = 0.35;
					}
				}
				
				var morph:Morph;
				
				switch (_style) {
					
					case STYLE_REMOVE:
						
						// no visual 
						_parentClass.playObject.destroy();
						break;
						
					case STYLE_PASSTHROUGH:
						
						break;
						
					case STYLE_BLOOM:

						if (vo is ViewSprite) {
							morph = new Bloom(ViewSprite(vo));
						}
						break;
						
					case STYLE_SHATTER:
						
						if (vo is ViewSprite) {
							if (e.contactPoint != null) e.contactPoint.y = 0 - e.contactPoint.y;
							var pt:Point = new Point(0, 0 - Math.max(vo.dobj.width, vo.dobj.height) / 3);
							morph = new Shatter(ViewSprite(vo), true, 2, pt, e.contactPoint, _parentClass.playObject.object.material.color);
						}
						break;
						
					case STYLE_EXPLODE:
					
						// explode();
						break;
					
				}
				
			}

		}
		
		override public function end():void 
		{
			if (_parentClass != null && _parentClass.playObject != null) {
				_parentClass.playObject.removeEventListener(PlayfieldEvent.DEATH, onDeath);
			}

			super.end();
		}
		
	}
	
}