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
	
	import fuz2d.Fuz2d;
	
	import fuz2d.action.physics.*;
	import fuz2d.action.play.PlayObject;
	import fuz2d.model.material.Material;
	import fuz2d.model.object.Bone;
	import fuz2d.model.object.Handle;
	import fuz2d.model.object.Point2d;
	
	import fuz2d.model.object.Biped;
	import fuz2d.model.object.Object2d;
	
	import fuz2d.util.Geom2d;

	public class StandBehavior extends BipedBehavior {
				
		//
		//
		public function StandBehavior () {
			
			super();
			
		}
		
		//
		//
		override public function update(e:Event):void {
			
			super.update(e);
		
			_moving = (Math.abs(chi.relativeVelocity.x) > 100);
			
			if (!_moving && !chi.floating) {
					
				if (idle) idle = false;
			
				resolve();
				
			} else {
				
				if (!idle) idle = true;
				
			}			

		}

		//
		//
		override public function resolve():void {
			
			super.resolve();
			
			if (_handle_body.controller == this) {
			
				_handle_body.rotation = 0;

				_handle_body.pull(0.05);
			
			}
			
			if (_handle_head.controller == this) {
				_handle_head.rotation = 0 - _handle_body.rotation * 0.8;
				_handle_head.pull(0.05);
			}
			
			if (_handle_leg_lt.controller == this) {
				_handle_leg_lt.reset();
				_handle_leg_lt.pull(0.3);
			}
			
			if (_handle_leg_rt.controller == this) {
				_handle_leg_rt.reset();
				_handle_leg_rt.pull(0.3);
			}
			
			if (_handle_arm_lt.controller == this) {
				_handle_arm_lt.reset();
				_handle_arm_lt.pull(0.1);
			}
			
			if (_handle_arm_rt.controller == this) {
				_handle_arm_rt.reset();
				_handle_arm_rt.pull(0.1);
			}	
			
			if (_handle_hand_rt.controller == this) {
				_handle_hand_rt.reset();
				_handle_hand_rt.pull(0.1);	
			}	
			
		}
		
	}
	
}