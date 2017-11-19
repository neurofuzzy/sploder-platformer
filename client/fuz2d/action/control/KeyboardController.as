/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.control {
	
	import fuz2d.action.*;
	import fuz2d.screen.*;
	import fuz2d.util.*;
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.ui.Keyboard;

	public class KeyboardController extends Controller {
		
		private var _view:View;
		
		private var updater:MovieClip;
		
		private var keyCode:uint;
		
		private var currentLight:int;
		
		private var _dragging:Boolean = false;
		
		//
		//
		public function KeyboardController (view:View) {
			
			_view = view;
			currentLight = 0;
			
			_view.stage.addEventListener(KeyboardEvent.KEY_DOWN, updateOn, false, 0, true);
			_view.stage.addEventListener(KeyboardEvent.KEY_UP, updateOff, false, 0, true);
			_view.stage.addEventListener(MouseEvent.MOUSE_DOWN, startDrag, false, 0, true);
			_view.stage.addEventListener(MouseEvent.MOUSE_UP, stopDrag, false, 0, true);
			
			updater = new MovieClip();
			_view.stage.addChild(updater);
			
		}

		
		//
		//
		private function updateOn (e:KeyboardEvent):void {
			if (e.keyCode != keyCode) {
				keyCode = e.keyCode;
				updater.addEventListener(Event.ENTER_FRAME, updateView, false, 0, true);
			}
		}
		
		//
		//
		private function updateOff (e:KeyboardEvent):void {
			keyCode = 0;
			updater.removeEventListener(Event.ENTER_FRAME, updateView);
		}
		
		//
		//
		//
		private function startDrag (e:MouseEvent):void {

			updater.startDrag();
			_view.stage.addEventListener(MouseEvent.MOUSE_MOVE, move, false, 0, true);

		}
		
		//
		//
		//
		private function stopDrag (e:MouseEvent):void {
			updater.stopDrag();
			_view.stage.removeEventListener(MouseEvent.MOUSE_MOVE, move);
		}
		
		//
		//
		private function move (e:Event):void {
			
			var xo:Number = 0 - updater.x - _view.camera.worldX;
			var yo:Number = updater.y - _view.camera.worldY;
			_view.camera.x += xo;
			_view.camera.y += yo
			_view.camera.update();
			
			_view.update();
			
		}
		
		//
		//
		private function updateView (e:Event):void {

			var step:Number = 5;
			// CAMERA
			
			if (keyCode == Keyboard.DOWN) {
				_view.camera.y += step;	
				_view.stale = true;
			}
			
			if (keyCode == Keyboard.UP) {
				_view.camera.y -= step;	
				_view.stale = true;
			}
			
			if (keyCode == Keyboard.LEFT) {
				_view.camera.x -= step;	
				_view.stale = true;
			}
			
			if (keyCode == Keyboard.RIGHT) {
				_view.camera.x += step;	
				_view.stale = true;
			}
			
			if (keyCode == Keyboard.PAGE_UP) {
				_view.camera.z += step;	
				_view.stale = true;
			}
			
			if (keyCode == Keyboard.PAGE_DOWN) {
				_view.camera.z -= step;	
				_view.stale = true;
			}
			
			// LIGHT
			
			if (keyCode == Keyboard.TAB) {
				if (currentLight < _view.model.lights.length - 1) {
					currentLight++;
				} else {
					currentLight = 0;
				}
			}
			
			if (keyCode == 87) {
				_view.model.lights[currentLight].y += step;	
				_view.stale = true;
			}
			
			if (keyCode == 83) {
				_view.model.lights[currentLight].y -= step;	
				_view.stale = true;
			}
			
			if (keyCode == 65) {
				_view.model.lights[currentLight].x -= step;	
				_view.stale = true;
			}
			
			if (keyCode == 68) {
				_view.model.lights[currentLight].x += step;	
				_view.stale = true;
			}

			if (keyCode == 81) {
				_view.model.lights[currentLight].z += step;	
				_view.stale = true;
			}

			if (keyCode == 69) {
				_view.model.lights[currentLight].z -= step;	
				_view.stale = true;
			}

		}		
		
	}
	
}
