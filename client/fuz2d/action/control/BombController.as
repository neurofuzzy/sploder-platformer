/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.action.control {
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import fuz2d.action.modifier.PushModifier;
	import fuz2d.action.physics.*;
	import fuz2d.action.play.*;
	import fuz2d.model.object.Object2d;
	import fuz2d.model.object.Symbol;
	import fuz2d.TimeStep;
	import fuz2d.util.Geom2d;
	
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class BombController extends PlayObjectController {
		
		protected var _strength:int = 10;
		protected var _radius:int = 200;
		protected var _lifeSpan:int = 3;
		protected var _startTime:int = 0;
		protected var _tickTimer:Timer;
		protected var _spent:Boolean = false;
		
		protected var _modelObj:Object2d;
		
		//
		//
		public function BombController (object:PlayObjectControllable, strength:int = 10, radius:int = 200, lifeSpan:int = 3) {
		
			super(object);
			
			_strength = strength;
			_radius = radius;
			_lifeSpan = (!isNaN(lifeSpan)) ? lifeSpan * 1000 : _lifeSpan;
			_startTime = TimeStep.realTime;
			_tickTimer = new Timer(500, lifeSpan * 2 - 1);
			_tickTimer.addEventListener(TimerEvent.TIMER, onTick); 
			_tickTimer.start();
			_modelObj = _object.object;
			
		}

		
		//
		//
		override public function update (e:Event):void {
			
			if (_ended || !_active) return;
			
			super.update(e);

			if (Symbol(_object.object).state == "f_explode") {
				harm();
				_active = false;
			}
			
		}
		
		protected function onTick (e:TimerEvent):void {
			_object.eventSound("tick");
		}
		
		//
		//
		public function harm ():void {

			if (_spent) return;
			if (_object.deleted) return;
			
			try {
				
				_object.object.ypos += 60;
				
				_object.playfield.sightGrid.update();
				
				var neighbors:Array = _object.playfield.sightGrid.getNeighborsOf(_object as PlayObjectControllable, false, true);
				var amount:int;
				var perc:Number = 0;
				var ang:Number;
				var v:Vector2d;


				for each (var playObj:PlayObjectControllable in neighbors) {

					if (!playObj.deleted && _object.playfield.map.canSee(_object, playObj)) {
						
						perc = 1 - Math.min(1, (Geom2d.distanceBetweenPoints(_object.object.point, playObj.object.point) - playObj.object.width) / (_radius));
						
						_object.harm(playObj, Math.floor(_strength * perc * 3));

						if (playObj.simObject != null && playObj.simObject is MotionObject) {
							
							if (!playObj.deleted && playObj.object != null && !playObj.object.deleted) {
								
								ang = Geom2d.angleBetweenPoints(_modelObj.point, playObj.object.point);
								v = new Vector2d(null, _strength * perc * 10, 0);
								
								v.rotate(ang);
								playObj.modifiers.add(new PushModifier(v.x, v.y));
								
								//MotionObject(playObj.simObject).addForce(v);
							
							}
							
						}
						
					}
					
				}
				
				_spent = true;
				
			} catch (e:Error) {
				
				trace("BombController explode:", e);
				
			}

		}
		
		//
		//
		override public function end():void {
			
			harm();
			_tickTimer.stop();
			super.end();
			
		}
		
	}
	
}