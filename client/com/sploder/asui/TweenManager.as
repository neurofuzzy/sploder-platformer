
package com.sploder.asui {
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import com.sploder.asui.Tween;

	/**
	 * Class: TweenManager
	 * Processes a queue of tweens.  Handles adding, removing and updating of tweened parameters.
	 * @version 1.0
	 */
	public class TweenManager {

		private var _tweens:Array;
		private var _lastTweenID:int = 0;
		private var _lastTweenGroupID:int = 0;
		
		private var _currentTime:int = 0;
		
		// global timer so that all tweens sync
		public function get time ():int { return _currentTime };
		
		public function get newTweenID ():int {
			
			_lastTweenID++;
			return _lastTweenID;
			
		}
		
		public function get currentGroupID ():int {
			
			return _lastTweenGroupID;
			
		}
		
		//
		//
		//
		public function TweenManager (startNow:Boolean = false) {
			
			init(startNow);
			
		}
		
		//
		//
		//
		private function init (startNow:Boolean = false):void {
			
			_tweens = [];
			if (startNow) start();
			
		}
		
		//
		//
		public function update (e:Event):void {
		
			_currentTime = getTimer();
			
			for each (var tween:Tween in _tweens) tween.ease();

		}
		
		//
		//
		public function align (tweenObjects:Array, property:String, value:Number):void {
			
			for (var obj:Object in tweenObjects) obj[property] = value;
			
		}
		
		//
		//
		//
		public function createTween (tweenObject:Object, attribute:String, startVal:Number = NaN, endVal:Number = NaN, duration:Number = 1, loop:Boolean = false, yoyo:Boolean = false, loops:int = 0, delay:Number = 0, easeType:uint = 0, easeStyle:uint = 0, startHandler:Function = null, doneHandler:Function = null, groupID:int = 0):int {
			
			if (groupID == 0) advanceGroupID();
			
			if (delay == 0) removeTweenOnObjectWithAttribute(tweenObject, attribute);
			_tweens.push(new Tween(this, tweenObject, attribute, startVal, endVal, duration, loop, yoyo, loops, delay, easeType, easeStyle, startHandler, doneHandler));

			return _lastTweenGroupID;
			
		}
		
		//
		//
		//
		public function createTweens (tweenObjects:Array, startVals:Object, endVals:Object, duration:Number = 1, loop:Boolean = false, yoyo:Boolean = false, loops:int = 0, delay:Number = 0, easeType:uint = 0, easeStyle:uint = 0, startHandler:Function = null, doneHandler:Function = null):int {
			
			var a:Number;
			var i:int;
			var attrib:String;
			
			advanceGroupID();
			
			for each (var obj:Object in tweenObjects) {
				if (obj != null) {
					if (endVals is Array) {
						i = tweenObjects.indexOf(obj);
						if (endVals[i] != null) {
							for (attrib in endVals[i]) {
								a = (startVals[i] != null && !isNaN(startVals[i][attrib])) ? startVals[i][attrib] : (!isNaN(obj[attrib])) ? obj[attrib] : NaN;
								createTween(obj, attrib, a, endVals[i][attrib], duration, loop, yoyo, loops, delay, easeType, easeStyle, startHandler, doneHandler, _lastTweenGroupID);
							}	
						}
					} else {
						for (attrib in endVals) {
							a = (!isNaN(startVals[attrib])) ? startVals[attrib] : (!isNaN(obj[attrib])) ? obj[attrib] : NaN;
							createTween(obj, attrib, a, endVals[attrib], duration, loop, yoyo, loops, delay, easeType, easeStyle, startHandler, doneHandler, _lastTweenGroupID);
						}
					}
				}
			}
			
			return _lastTweenGroupID;
			
		}
		
		//
		//
		//
		private function advanceGroupID ():void {
			_lastTweenGroupID++;
		}
		
		//
		//
		//
		public function removeTween (tween:Tween):void {
			
			for each (var t:Tween in _tweens) {
				if (t.id == tween.id) { 
					_tweens.splice(_tweens.indexOf(t), 1);
					break;
				}
			}
			
		}
		
		//
		//
		public function removeTweenGroup (groupID:int):void {
			
			for each (var t:Tween in _tweens) if (t.groupID == groupID) _tweens.splice(_tweens.indexOf(t), 1); 
			
		}
		
		//
		//
		public function removeTweensOnObject (tweenObject:Object):void {
			
			for each (var t:Tween in _tweens) if (t.tweenObject == tweenObject) _tweens.splice(_tweens.indexOf(t), 1); 
			
		}
		
		//
		//
		public function removeTweenOnObjectWithAttribute(tweenObject:Object, attribute:String):void {
			
			for each (var t:Tween in _tweens) {
				if (t.tweenObject == tweenObject && t.attribute == attribute) { 
					_tweens.splice(_tweens.indexOf(t), 1);
					break;
				}
			}	
			
		}
		
		//
		//
		//
		public function clearAllTweens ():void {
		
			_tweens = [];
			
		}
		
		//
		//
		public function start ():void {
			Component.mainStage.addEventListener(Event.ENTER_FRAME, update, false, 2);
		}
		
		//
		//
		public function stop ():void {
			Component.mainStage.removeEventListener(Event.ENTER_FRAME, update);
		}
		
		//
		//
		public function end ():void {
			
			stop();
			clearAllTweens();

		}
		
		//
		//
		public function fadeOutObject (obj:DisplayObject, time:Number = 1):void {
			
			createTween(obj, "alpha", obj.alpha, 0, time, false, false, 0, 0, 0, 0, null, 
				function ():void { obj.visible = false; } );
			
		}
		
		//
		//
		public function fadeInObject (obj:DisplayObject, time:Number = 1):void {
			
			createTween(obj, "alpha", obj.alpha, 1, time, false, false, 0, 0, 0, 0, 
				function ():void { obj.visible = true; } );
			
		}
			
	}
	
}