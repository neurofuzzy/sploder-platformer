/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.action.control {
	
	import flash.events.Event;
	import fuz2d.action.*;
	import fuz2d.action.control.Controller;
	import fuz2d.model.environment.Camera2d;
	import fuz2d.model.object.Object2d;
	import fuz2d.util.*;
	
	import flash.events.TimerEvent;
	
	import flash.ui.Keyboard;

	public class CameraOrbitController extends Controller {
		
		protected var _camera:Camera2d;
		protected var _object:Object2d;
		protected var _axis:Object2d;

		protected var _orbitDist:Number = 300;
		
		public function get orbitDist():Number { return _orbitDist; }
		public function set orbitDist(value:Number):void 
		{
			_orbitDist = (!isNaN(value)) ? value: _orbitDist;
			_camera.y = 0 - _orbitDist;
		}
		
		public function get object():Object2d { return _object; }
		public function set object(value:Object2d):void 
		{
			_object = value;
			_camera.startWatching(_object);
		}
		
		public function get axis():Object2d { return _axis; }
		
		
		//
		//
		public function CameraOrbitController (camera:Camera2d, object:Object2d) {
			
			super();
			init(camera, object);
			
		}
		
		//
		//
		private function init (camera:Camera2d, object:Object2d):void {
			
			Key.initialize();
			
			_camera = camera;
			_object = object;
			
			_axis = new Object2d(null, 0, 0, 0);
			
			_camera.parentObject = _axis;
			_axis.addChildObject(_camera);
			_camera.startWatching(_axis);
			
			wake();
			
		}
		
		//
		//
		override protected function update (e:TimerEvent):void {
			
			super.update(e);
			
			_axis.alignTo(_object, true, false);
			checkKeys();
			checkMouse();
			
		}

		//
		//
		private function checkMouse ():void {
			
			
		}
		
		//
		//
		private function checkKeys ():void {
			
			var speed:Number = 0.05;
			
			if (Key.isDown(Keyboard.LEFT) || Key.charIsDown("a")) _axis.zrot += speed;
			if (Key.isDown(Keyboard.RIGHT) || Key.charIsDown("d")) _axis.zrot -= speed;	
			if (Key.isDown(Keyboard.DOWN) || Key.charIsDown("s")) _axis.xrot += speed;
			if (Key.isDown(Keyboard.UP) || Key.charIsDown("w")) _axis.xrot -= speed;
			if (Key.isDown(Keyboard.PAGE_UP)) _camera.y += 20;
			if (Key.isDown(Keyboard.PAGE_DOWN)) _camera.y -= 20;
			
			dispatchEvent(new Event(Controller.UPDATE_COMPLETE));
				
		}		
		
	}
	
}
