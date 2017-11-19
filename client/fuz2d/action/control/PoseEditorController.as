/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.action.control {
	
	import fuz2d.Fuz2d;
	import fuz2d.action.*;
	import fuz2d.action.animation.PoseEditor;
	import fuz2d.action.control.Controller;
	import fuz2d.model.object.Bone;
	import fuz2d.util.*;
	
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	import flash.ui.Keyboard;
	

	public class PoseEditorController extends Controller {
		
		private var _parentClass:PoseEditor;
		
		public var power:Number;
		
		//
		//
		public function PoseEditorController (parentClass:PoseEditor) {
			
			super();
			init(parentClass);
			
		}
		
		//
		//
		private function init (parentClass:PoseEditor):void {
			
			Key.initialize();
			
			_parentClass = parentClass;
			
			Key.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed, false, 0, true);
			
			power = 5;
			
			View.mainStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
			View.mainStage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
			
			wake();
			
		}
		
		private function keyPressed (e:KeyboardEvent):void {
			checkKeys();
		}
		
		//
		//
		override public function update (e:Event):void {
			
			super.update(e);
			
			_parentClass.update();
			
		}

		//
		//
		private function checkMouse ():void {
			
			
		}
		
		//
		//
		private function checkKeys ():void {
			
			if (!_parentClass.playing) {

				if (Key.isDown(Keyboard.LEFT)) {
					if (Key.shiftKey) {
						_parentClass.rotateBone(_parentClass.currentBone.rotMin - _parentClass.currentBone.rotation);
					} else {
						_parentClass.rotateBone(0 - power * Geom2d.dtr);
					}
				}
				
				if (Key.isDown(Keyboard.RIGHT)) {
					if (Key.shiftKey) {
						_parentClass.rotateBone(_parentClass.currentBone.rotMax - _parentClass.currentBone.rotation);
					} else {
						_parentClass.rotateBone(power * Geom2d.dtr);
					}
				}
				
				if (Key.isDown(Keyboard.UP)) {
					if (Key.shiftKey) {
						_parentClass.prevPose();
					} else {
						_parentClass.prevBone();
					}
				}
				
				if (Key.isDown(Keyboard.DOWN)) {
					if (Key.shiftKey) {
						_parentClass.nextPose();
					} else {
						_parentClass.nextBone();
					}
				}
				
				if (Key.isDown(Keyboard.INSERT)) {
					if (Key.shiftKey) {
						_parentClass.addPose();
					} else {
						_parentClass.addBone();
					}
				}
				
				if (Key.isDown(Keyboard.DELETE)) {
					if (Key.shiftKey) {
						_parentClass.clearPose();
					} else {
						_parentClass.clearBone();
					}
				}
				
				if (Key.isDown(Keyboard.PAGE_UP)) {
					if (Key.shiftKey) {
						_parentClass.changePoseTime(500);
					} else {
						_parentClass.changePoseTime(100);
					}
				}
				
				if (Key.isDown(Keyboard.PAGE_DOWN)) {
					if (Key.shiftKey) {
						_parentClass.changePoseTime(-500);
					} else {
						_parentClass.changePoseTime(-100);
					}
				}
				

				
				if (Key.isDown(Keyboard.HOME)) {
					if (Key.shiftKey) {
						_parentClass.firstPose();
					} else {
						_parentClass.firstBone();
					}
				}
				
				if (Key.isDown(Keyboard.END)) {
					if (Key.shiftKey) {
						_parentClass.lastPose();
					} else {
						_parentClass.lastBone();
					}
				}
				
				if (Key.isDown(Key.SPACE)) _parentClass.takeSnapShot();
				
				if (Key.isDown(Keyboard.ENTER)) _parentClass.play();
				
			}

		}
		
		//
		//
		public function onKeyDown (e:KeyboardEvent):void {
		
			if (Key.charIsDown("f")) _parentClass.switchFacing();
			
		}
		
		//
		//
		public function onKeyUp (e:KeyboardEvent):void {
		

		}
		
	}
	
}
