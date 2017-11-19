/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.action.control {
	
	import flash.events.Event;
	import flash.ui.Keyboard;
	import fuz2d.action.physics.MotionObject;
	import fuz2d.screen.View;
	
	import fuz2d.action.behavior.*;
	import fuz2d.action.play.*;
	
	import fuz2d.util.*;
	

	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class PlayObjectKeyboardController extends PlayObjectController {
		

		private var _mobject:PlayObjectMovable;
		
		//
		//
		public function PlayObjectKeyboardController (object:PlayObjectControllable) {
			
			super(object);
			
		}
		
		override protected function init(object:PlayObjectControllable):void {
			
			super.init(object);
			
			_mobject = object as PlayObjectMovable;
			
			Key.initialize(View.mainStage);
			
		}
		
		//
		//
		override public function update (e:Event):void {
			
			if (_ended || !_active) return;
			
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
			

			if (Key.isDown(Keyboard.LEFT) || Key.charIsDown("a")) {
				_mobject.moveLeft();
			}
			
			if (Key.isDown(Keyboard.RIGHT) || Key.charIsDown("d")) {
				_mobject.moveRight();
			}
			
			if (Key.isDown(Keyboard.DOWN) || Key.charIsDown("s")) {
				_mobject.moveDown();
			}
			
			if (Key.isDown(Keyboard.UP) || Key.charIsDown("w")) {
				_mobject.simObject.controllerActive = true;
				_mobject.moveUp();
			}

			if (Key.isDown(Keyboard.SPACE)) {
		
			}

		}		
		
	}
	
}