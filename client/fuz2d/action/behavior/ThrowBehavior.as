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
	import fuz2d.action.modifier.PushModifier;
	import fuz2d.library.ObjectFactory;
	
	import fuz2d.Fuz2d;
	
	import fuz2d.action.physics.*;
	import fuz2d.action.play.*;
	import fuz2d.model.material.Material;
	import fuz2d.model.object.Bone;
	import fuz2d.model.object.Handle;
	import fuz2d.model.object.Point2d;
	
	import fuz2d.model.object.Biped;
	import fuz2d.model.object.Object2d;
	
	import fuz2d.util.Geom2d;

	public class ThrowBehavior extends BipedBehavior {
			
		protected var _power:Number = 1;
		protected var _wait:int = 3;
		
		protected var _markPoint:Point;
		protected var _releasePoint:Point;
		
		protected var _throwObject:PlayObject;
		protected var _throwObjectName:String;
		protected var _throwVelocity:Vector2d;
		protected var _throwSpin:Number;
		
		//
		//
		public function ThrowBehavior (power:Number = 1, throwObjectName:String = "grenade") {
			
			super();

			_power = power;
			_throwObjectName = throwObjectName;
			
		}
		
		//
		//
		override protected function init(parentClass:BehaviorManager):void {
			
			super.init(parentClass);

			_priority = 10;
			
			if (BipedObject(_parentClass.playObject).crouching) _wait += 3;
			
		}
		
		
		//
		//
		override public function update(e:Event):void {
			
			super.update(e);
			
			resolve();

		}


		//
		//
		override public function resolve():void {
			
			super.resolve();
			
			releaseControl();
			
			//if (_throwObject != null) ObjectFactory.effect(_throwObject, "smoke");
			
			_wait--;
			
			if (_wait == -1) {
				
				var z:int = 20;
				if (body.facing == Biped.FACING_LEFT) z = 0;
				
				_throwObject = ObjectFactory.createNew(_throwObjectName, _parentClass.playObject, body.tools_rt.tooltip.x, body.tools_rt.tooltip.y, z) as PlayObject;
				
				_throwVelocity = new Vector2d();
				_throwSpin = 0;
				
				if (body.facing == Biped.FACING_LEFT) {
				
					_throwVelocity.x = -80;
					_throwVelocity.y = 40;
					_throwSpin = -0.001;
					
				} else {
					
					_throwVelocity.x = 80;
					_throwVelocity.y = 40;
					_throwSpin = 0.001;
					
				}
				
				if (BipedObject(_parentClass.playObject).jumping) {
					if (_throwObject is PlayObjectControllable) {
						PlayObjectControllable(_throwObject).modifiers.add(new PushModifier(_throwVelocity.x, _throwVelocity.y));
					}

					_throwVelocity.scaleBy(_power * 100);
					
				} else if (BipedObject(_parentClass.playObject).crouching) {
					_throwVelocity.y *= 0.5;
					_throwVelocity.scaleBy(_power * 50);
				} else {
					_throwVelocity.scaleBy(_power * 60);
				}
				
				MotionObject(_throwObject.simObject).acceleration.addBy(_throwVelocity);
				MotionObject(_throwObject.simObject).angularAcceleration = _throwSpin;
				
			} else if (_wait < -1 && _wait > -4) {
				
				MotionObject(_throwObject.simObject).acceleration.addBy(_throwVelocity);
				
			} else if (_wait < -20) {

				end();
				
			}

		}
		
	}
	
}