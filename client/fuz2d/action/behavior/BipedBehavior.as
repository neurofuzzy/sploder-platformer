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

	public class BipedBehavior extends Behavior {
			
		protected var _handle_body:Handle;
		protected var _handle_head:Handle;
		
		protected var _handle_leg_lt:Handle;
		protected var _handle_leg_rt:Handle;
		
		protected var _handle_arm_lt:Handle;
		protected var _handle_arm_rt:Handle;

		protected var _handle_hand_lt:Handle;
		protected var _handle_hand_rt:Handle;
		
		public var body:Biped;
		public var chi:MotionObject;
		
		protected var _moving:Boolean = false;
		
		//
		//
		public function BipedBehavior (priority:int = 0) {

			_priority = priority;
			
		}
		
		//
		//
		override protected function init(parentClass:BehaviorManager):void {
			
			super.init(parentClass);

			if (_priority == 10) _priority = 20;
			
			body = Biped(_parentClass.modelObject);
			chi = MotionObject(_parentClass.simObject);

			_handle_body = body.handles.body;
			_handle_head = body.handles.head;
			
			_handle_leg_lt = body.handles.leg_lt;
			_handle_leg_rt = body.handles.leg_rt;

			_handle_arm_lt = body.handles.arm_lt;
			_handle_arm_rt = body.handles.arm_rt;
			
			_handle_hand_lt = body.handles.hand_lt;
			_handle_hand_rt = body.handles.hand_rt;
		
			assign();

		}
		
		//
		//
		override public function assign():void {
			
			super.assign();
			
			if (_handle_body.controller == null || _handle_body.controller.priority > _priority) _handle_body.controller = this;
			if (_handle_head.controller == null || _handle_head.controller.priority > _priority) _handle_head.controller = this;
			
			if (_handle_leg_lt.controller == null || _handle_leg_lt.controller.priority > _priority) _handle_leg_lt.controller = this;
			if (_handle_leg_rt.controller == null || _handle_leg_rt.controller.priority > _priority) _handle_leg_rt.controller = this;
			
			if (_handle_arm_lt.controller == null || _handle_arm_lt.controller.priority > _priority) _handle_arm_lt.controller = this;
			if (_handle_arm_rt.controller == null || _handle_arm_rt.controller.priority > _priority) _handle_arm_rt.controller = this;	
			
			if (_handle_hand_lt.controller == null || _handle_hand_lt.controller.priority > _priority) _handle_hand_lt.controller = this;
			if (_handle_hand_rt.controller == null || _handle_hand_rt.controller.priority > _priority) _handle_hand_rt.controller = this;		
			
		}
		
		
		
		//
		//
		override public function assumeControl(force:Boolean = false):void {
			
			super.assumeControl(force);
			
			if (!force) {
				
				if (_handle_body.controller == null) _handle_body.controller = this;
				if (_handle_head.controller == null) _handle_head.controller = this;
				
				if (_handle_leg_lt.controller == null) _handle_leg_lt.controller = this;
				if (_handle_leg_rt.controller == null) _handle_leg_rt.controller = this;
				
				if (_handle_arm_lt.controller == null) _handle_arm_lt.controller = this;
				if (_handle_arm_rt.controller == null) _handle_arm_rt.controller = this;
				
				if (_handle_hand_lt.controller == null) _handle_hand_lt.controller = this;
				if (_handle_hand_rt.controller == null) _handle_hand_rt.controller = this;
				
			}

		}
		
		//
		//
		override public function releaseControl():void {
			
			super.releaseControl();
			
			if (_handle_body.controller == this) _handle_body.controller = null;
			if (_handle_head.controller == this) _handle_head.controller = null;
			
			if (_handle_leg_lt.controller == this) _handle_leg_lt.controller = null;
			if (_handle_leg_rt.controller == this) _handle_leg_rt.controller = null;
			
			if (_handle_arm_lt.controller == this) _handle_arm_lt.controller = null;
			if (_handle_arm_rt.controller == this) _handle_arm_rt.controller = null;
			
			if (_handle_hand_lt.controller == this) _handle_hand_lt.controller = null;
			if (_handle_hand_rt.controller == this) _handle_hand_rt.controller = null;
			
		}

	}
	
}