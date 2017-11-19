/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.action.behavior {
	
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Point;
	import fuz2d.action.behavior.BehaviorManager;
	import fuz2d.action.play.BipedObject;
	import fuz2d.action.play.PlayObjectControllable;
	import fuz2d.model.object.Biped;
	import fuz2d.model.object.Symbol;
	import fuz2d.util.Geom2d;
	
	import fuz2d.Fuz2d;
	import fuz2d.action.physics.*;
	import fuz2d.action.play.PlayObject;
	import fuz2d.action.play.PlayfieldEvent;

	public class WeakBlockBehavior extends Behavior {
			
		public static const WEIGHT_DAMAGE:String = "weight";
		public static const HIT_DAMAGE:String = "hit";
		public static const HEAT_DAMAGE:String = "heat";
		
		
		private var _strength:int = 10;
		private var _damageType:String = "weight";
		private var _explode:Boolean = false;
		private var _exploded:Boolean = false;
		private var _radius:int = 0;
		private var _resilience:int = 0;
		private var _damageOnlyBy:String = "";
		private var _fubar:Boolean = false;
		private var _damaged:Boolean = false;

		//
		//
		public function WeakBlockBehavior (strength:int = 10, damageType:String = "weight", explode:Boolean = false, radius:int = 0, resilience:int = 0, damagedOnlyBy:String = "") {
			
			super();
			
			_strength = strength;
			_damageType = damageType;
			_explode = explode;
			_radius = radius;
			_resilience = resilience;
			_damageOnlyBy = damagedOnlyBy;
			
		}
		
		//
		//
		override protected function init(parentClass:BehaviorManager):void {
			
			super.init(parentClass);
			
			if (_parentClass.playObject != null && _parentClass.playObject.simObject != null) {
				_parentClass.playObject.simObject.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);
			}
			
			if (_parentClass.playObject != null && _parentClass.playObject.object != null) {
				_parentClass.playObject.object.attribs.strength = _strength;
			}
			
			if (_parentClass.playObject != null) {
				_parentClass.playObject.addEventListener(PlayfieldEvent.HARM, onHarm, false, 0, true);
			}
			
		}
		
		override public function update(e:Event):void 
		{
			super.update(e);
			
			if (_explode && _fubar && !_exploded) damage(2);

			_damaged = false;
			
			if (_explode) {
				
				var s:String = Symbol(_parentClass.playObject.object).state;
				
				if (s == "f5" || s == "f6" && !_exploded) {
					explode();
				}
			
			}
			
		}
		
		//
		//
		public function onCollision (e:CollisionEvent):void {		
			
			if (_damageType == WEIGHT_DAMAGE && e.contactNormal.y < 0 && e.contactSpeed > 50) {
				
				var a:Object = _parentClass.playObject.object.attribs;
				
				a.strength -= 0.5;
				
				if (a.strength < 0) end();
				else if (a.strength < 8) Symbol(_parentClass.playObject.object).state = "f" + (5 - Math.floor(a.strength / 2));

			}
			
			if (_parentClass.playObject.object.attribs.strength <= 0) {
				
				_parentClass.simObject.collisionObject.reactionType = ReactionType.PASSTHROUGH;
				
			}	
			
		}
		
		//
		//
		public function onHarm (e:PlayfieldEvent):void {
			
			if (e.playObject == null || e.playObject.object == null) return;
			
			if (_damageOnlyBy != "") {
				if (e.playObject.object.symbolName == "player") {
					if (e.playObject.object is Biped) {
						if (Biped(e.playObject.object).tools_rt.toolname != _damageOnlyBy) {
							return;
						}
					} else {
						return;
					}
				} else if (e.playObject.object.symbolName != _damageOnlyBy) {
					return;
				}
			}
			
			if (_damageType == HIT_DAMAGE || 
				(_damageType == HEAT_DAMAGE && e.playObject.object.symbolName == "flameshoot") ) {
				
				damage(e.amount);
				
				if (_explode && e.amount > 10) _fubar = true;
				
			}
			
			if (_parentClass.playObject.object.attribs.strength <= 0) {
				
				_parentClass.simObject.collisionObject.reactionType = ReactionType.PASSTHROUGH;
				
			}	
			
		}
		
		//
		//
		protected function damage (amount:Number):void {
			
			if (amount < _resilience) return;
			
			var a:Object = _parentClass.playObject.object.attribs;
			
			a.strength -= Math.min(1, amount);

			if (_explode) {
				if (a.strength == 0) {
					explode();
					_fubar = true;
				}
			}
			
			if (amount >= 20 && a.strength > 0) {
				a.strength -= Math.min(1, amount);
			}
			if (amount >= 30 && a.strength > 0) {
				a.strength -= Math.min(1, amount);
			}

			if (a.strength < 0) end();
			else if (a.strength < 8) Symbol(_parentClass.playObject.object).state = "f" + (5 - Math.floor(a.strength / 2));
		
			_damaged = true;
			
			if (_resilience > 40) Symbol(_parentClass.playObject.object).state = "f_explode";
			
		}
		
		//
		//
		public function explode ():void {

			if (_exploded) return;
			if (_parentClass.playObject.deleted) return;
			
			try {

				_parentClass.playObject.eventSound("explode");
				_parentClass.playObject.playfield.sightGrid.update();
				
				var neighbors:Array = _parentClass.playObject.playfield.sightGrid.getNeighborsOf(_parentClass.playObject as PlayObjectControllable, false, true);
				var amount:int;
				var perc:Number = 0;
				var ang:Number;
				var v:Vector2d;

				for each (var playObj:PlayObjectControllable in neighbors) {

					if (!playObj.deleted) {
						
						perc = 1 - Math.min(1, (Geom2d.distanceBetweenPoints(_parentClass.playObject.object.point, playObj.object.point) - playObj.object.width) / (_radius));
						
						PlayObjectControllable(_parentClass.playObject).harm(playObj, Math.floor(_strength * perc * 3));

						if (playObj.simObject != null && playObj.simObject is MotionObject) {
							
							if (!playObj.deleted && playObj.object != null && !playObj.object.deleted) {
								
								ang = Geom2d.angleBetweenPoints(_parentClass.modelObject.point, playObj.object.point);
								v = new Vector2d(null, _strength * perc * 100, 0);
								v.rotate(ang);

								MotionObject(playObj.simObject).velocity.x += v.x;
								MotionObject(playObj.simObject).velocity.y += v.y;
							
							}
							
						}
						
					}
					
				}
				
				_exploded = true;
				
			} catch (e:Error) {
				
				trace("WeakBlockBehavior explode:", e);
				
			}

		}
		
		override public function end():void {
			
			if (_parentClass.playObject != null && _parentClass.playObject.simObject != null) _parentClass.playObject.simObject.removeEventListener(CollisionEvent.COLLISION, onCollision);
			super.end();
			
		}
		
	}
	
}