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
	
	import flash.events.TimerEvent;
	import flash.ui.Keyboard;

	public class FirstPersonController extends Controller {
		
		private var _view:View;
		
		private var _x:Number;
		private var _y:Number;
		private var _z:Number;
		
		private var _heading:Number;
		private var _lookHeading:Number;
		private var _pitch:Number;
		private var _lookPitch:Number;
		
		private var _sa:Number = 0;
		private var _ca:Number = 0;
		private var _sb:Number = 0;
		private var _cb:Number = 0;
		
		private var _prevXmouse:Number;
		private var _prevYmouse:Number;		
		private var _viewChanged:Boolean = true;
		
		//
		//
		public function FirstPersonController (view:View) {
			
			init(view);
			
		}
		
		//
		//
		private function init (view:View):void {
			
			Key.initialize();
			
			_view = view;
			
			_x = _view.camera.x;
			_y = _view.camera.y;
			_z = _view.camera.z;
			
			_heading = _view.camera.heading;
			_lookHeading = 0;
			_pitch = _view.camera.pitch;
			_lookPitch = 0;
			
			setWalkAngles();
			
			_prevXmouse = _view.viewport.mouseX;
			_prevYmouse = _view.viewport.mouseY;
			
			wake();

		}
		
		//
		//
		override protected function update (e:TimerEvent):void {
			
			checkKeys();
			checkMouse();

			if (_viewChanged) {
			
				_view.camera.x = _x;
				_view.camera.y = _y;
				_view.camera.z = _z;
				
				_view.camera.heading = _heading + _lookHeading;
				_view.camera.pitch = _pitch + _lookPitch;
				
			}
			
		}


		//
		//
		private function checkMouse ():void {
			
			if (_view.viewport.mouseX != _prevXmouse || _view.viewport.mouseY != _prevYmouse) {
				
				_lookHeading = Math.max(-5, Math.min(5, (0 - _view.viewport.mouseX) / 400));
				_lookPitch = Math.max(-1, Math.min(1, (0 - _view.viewport.mouseY) / 200));
				
				_viewChanged = true;
				
			}
			
			_prevXmouse = _view.viewport.mouseX;
			_prevYmouse = _view.viewport.mouseY;
			
		}
		
		//
		//
		private function setWalkAngles ():void {
			
			_sa = Faster.sin(_heading + (90 * Geom2d.dtr));
			_ca = Faster.cos(_heading + (90 * Geom2d.dtr));
			_sb = Faster.sin(_heading);
			_cb = Faster.cos(_heading);
			
			_view.camera.moved = true;
			
		}
		
		//
		//
		private function reset ():void {
			
			_view.camera.pitch = 0;
			
		}
		
		//
		//
		private function checkKeys ():void {

			var step:Number = 10;
			
			if (Key.shiftKey) {
			
				if (Key.isDown(Keyboard.LEFT) || Key.charIsDown("a")) {
					_x -= step * _cb;	
					_y -= step * _sb;
					_viewChanged = true;
				}
				
				if (Key.isDown(Keyboard.RIGHT) || Key.charIsDown("d")) {
					_x += step * _cb;	
					_y += step * _sb;
					_viewChanged = true;
				}
				
			} else {
				
				if (Key.isDown(Keyboard.LEFT) || Key.charIsDown("a")) {
					_heading += 0.1;
					_viewChanged = true;
					setWalkAngles();
				}
				
				if (Key.isDown(Keyboard.RIGHT) || Key.charIsDown("d")) {
					_heading -= 0.1;
					_viewChanged = true;
					setWalkAngles();
				}
			
			}
			
			if (Key.isDown(Keyboard.DOWN) || Key.charIsDown("s")) {
				_x -= step * _ca;	
				_y -= step * _sa;
				_viewChanged = true;
			}
			
			if (Key.isDown(Keyboard.UP) || Key.charIsDown("w")) {
				_x += step * _ca;	
				_y += step * _sa;
				_viewChanged = true;
			}

			if (Key.isDown(Keyboard.PAGE_UP)) {
				_z += step;
				_viewChanged = true;
			}
			
			if (Key.isDown(Keyboard.PAGE_DOWN)) {
				_z -= step;
				_viewChanged = true;
			}

		}		
		
	}
	
}
