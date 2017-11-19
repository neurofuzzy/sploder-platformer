/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.action.control {
	
	import fuz2d.action.*;
	import fuz2d.action.control.Controller;
	import fuz2d.model.object.Object2d;
	import fuz2d.util.*;
	
	import flash.events.TimerEvent;
	
	import flash.ui.Keyboard;

	public class ObjectController extends Controller {
		
		public var object:Object2d;
		
		//
		//
		public function ObjectController (object:Object2d) {
			
			super();
			init(object);
			
		}
		
		//
		//
		private function init (object:Object2d):void {
			
			Key.initialize();
			
			this.object = object;
			
			wake();
			
		}
		
		//
		//
		override protected function update (e:TimerEvent):void {
			
			super.update(e);
			
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
			
			var speed:uint = 5;
			
			if (Key.isDown(Keyboard.LEFT) || Key.charIsDown("a")) {
				if (Key.shiftKey) {
					object.zrot += speed / 20;
				} else {
					object.x -= speed;
				}
			}
			
			if (Key.isDown(Keyboard.RIGHT) || Key.charIsDown("d")) {
				if (Key.shiftKey) {
					object.zrot -= speed / 20;
				} else {
					object.x += speed;
				}
			}
			
			if (Key.isDown(Keyboard.DOWN) || Key.charIsDown("s")) {
				if (Key.shiftKey) {
					object.z -= speed;
				} else {
					object.y -= speed;
				}
			}
			
			if (Key.isDown(Keyboard.UP) || Key.charIsDown("w")) {
				if (Key.shiftKey) {
					object.z += speed;
				} else {
					object.y += speed;
				}
			}

		}		
		
	}
	
}
