/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.behavior {
	
	import com.adobe.utils.StringUtil;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Point;
	import fuz2d.action.animation.Gesture;
	import fuz2d.action.animation.GestureEvent;
	
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

	public class GestureBehavior extends BipedBehavior {
			
		protected var _name:String;
		public function get name():String { return _name; }
		
		protected var _rootBone:Bone;
		protected var _gestureData:Object;
		
		protected var _gesture:Gesture;
		public function get gesture():Gesture { return _gesture; }
		
		protected var _flip:Boolean = false;
		protected var _hold:uint = 0;
		protected var _relax:uint = 0;
		protected var _yoyo:Boolean = false;
		protected var _loops:uint = 0;
		
		
		//
		//
		override public function set idle(value:Boolean):void {
			super.idle = value;
		}
				
		//
		//
		public function GestureBehavior (name:String, gestureData:Object, flip:Boolean = false, hold:uint = 0, relax:uint = 0, yoyo:Boolean = false, loops:uint = 0) {
			
			super();
			
			_name = name;
			_gestureData = gestureData;

			_flip = flip;
			_hold = hold;
			_relax = relax;
			_yoyo = yoyo;
			_loops = loops;
			
		}
		
		//
		//
		override protected function init(parentClass:BehaviorManager):void {
			
			super.init(parentClass);

			_priority = 1;
			
			body = Biped(_parentClass.modelObject);
			_handle_body = body.handles.body;
			
			assign();

		}
		
		//
		//
		override public function assign():void {
			
			_handle_body.controller = null;

			_handle_body.controller = this;
			
			_rootBone = Biped(_parentClass.modelObject).body;

			_gesture = new Gesture(_name, _rootBone, _gestureData, _flip, _hold, _yoyo, _loops, _relax);
			_gesture.addEventListener(GestureEvent.GESTURE_KEYFRAME, onGesture, false, 0, true);
			_gesture.addEventListener(GestureEvent.GESTURE_END, onGestureComplete, false, 0, true);
			_gesture.start();
			
		}
		
		//
		//
		override public function update(e:Event):void {
			
			super.update(e);
			//if (_parentClass.modelObject.symbolName == "player") trace("yo");
			_gesture.update(e);

		}
		
		//
		//
		override public function assumeControl(force:Boolean = false):void {
			
			if (!force) {
				
				if (_handle_body.controller == null) _handle_body.controller = this;
				
			}

		}
		
		//
		//
		override public function releaseControl():void {
			
			if (_handle_body.controller == this) _handle_body.controller = null;

		}
		
		//
		//
		override public function resolve():void {
			
			super.resolve();
			
			if (_handle_body.controller == this) {
				//_handle_body.rotation = 0;
			}
			
			
		}
		
		//
		//
		protected function onGesture (e:GestureEvent):void {

		}
		
		//
		//
		protected function onGestureComplete (e:GestureEvent):void {
			if (e.gesture.name == "fall") trace("DONE");
			end();
			
		}
		
		//
		//
		override public function end():void {

			_gesture.removeEventListener(GestureEvent.GESTURE_END, end);
			_gesture = null;

			super.end();
			
		}
		
	}
	
}