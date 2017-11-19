
package com.sploder.asui {

	import flash.display.DisplayObject;
	import flash.events.Event;

	import com.sploder.asui.TweenManager;
	import com.robertpenner.easing.*;

	/**
	 * Class: TweenManager
	 * Describes a single tween of one parameter of a single MovietweenObject
	 * Must be used in a TweenManager instance to function
	 * @version 1.0
	 */
	public class Tween {

		public static var EASE_IN:uint = 0;
		public static var EASE_OUT:uint = 1;
		public static var EASE_INOUT:uint = 2;
		
		public static var STYLE_LINEAR:uint = 0;
		public static var STYLE_CUBIC:uint = 1;
		public static var STYLE_QUAD:uint = 2;
		public static var STYLE_QUART:uint = 3;
		public static var STYLE_QUINT:uint = 4;
		public static var STYLE_SINE:uint = 5;
		public static var STYLE_EXPO:uint = 6;
		public static var STYLE_CIRC:uint = 7;
		public static var STYLE_ELASTIC:uint = 8;
		public static var STYLE_BACK:uint = 9;
		public static var STYLE_BOUNCE:uint = 10;
		
		public var priority:int = 1;
		
		private var _id:int;
		private var _groupID:int;
		private var _parentClass:TweenManager;
		
		private var tweenClassRef:Object;
		private var easeMethod:String = "easeIn";
		
		private var _tweenObject:Object;
		private var _attribute:String;
		private var _startVal:Number;
		private var _endVal:Number;
		private var _delta:Number;
		private var _duration:Number;
		
		private var _easeType:uint = 0;
		private var _easeStyle:uint = 0;
		
		private var _startTime:Number;
		private var _delay:Number;
		private var _time:Number;
		
		private var _loop:Boolean = false;
		private var _yoyo:Boolean = false;
		
		private var _loops:int = 0;
		private var _loopsCompleted:int = 0;
		
		private var _started:Boolean = false;
		private var _done:Boolean = false;
		
		private var _startHandler:Function;
		private var _doneHandler:Function;
		
		public function get id ():int { return _id; }
		public function get groupID ():int { return _groupID; }
		public function get tweenObject ():Object { return _tweenObject; }
		public function get attribute ():String { return _attribute; }

		//
		//
		public function Tween (parentClass:TweenManager, tweenObject:Object, attribute:String, startVal:Number = NaN, endVal:Number = NaN, duration:Number = 1, loop:Boolean = false, yoyo:Boolean = false, loops:int = 0, delay:Number = 0, easeType:uint = 0, easeStyle:uint = 0, startHandler:Function = null, doneHandler:Function = null) {
			
			init(parentClass, tweenObject, attribute, startVal, endVal, duration, loop, yoyo, loops, delay, easeType, easeStyle, startHandler, doneHandler);
			
		}
		
		//
		//
		private function init (parentClass:TweenManager, tweenObject:Object, attribute:String, startVal:Number = NaN, endVal:Number = NaN, duration:Number = 1, loop:Boolean = false, yoyo:Boolean = false, loops:int = 0, delay:Number = 0, easeType:uint = 0, easeStyle:uint = 0, startHandler:Function = null, doneHandler:Function = null):void {
			
			_parentClass = parentClass;
			_id = _parentClass.newTweenID;
			_groupID = _parentClass.currentGroupID;
			
			_tweenObject = tweenObject;
			_attribute = attribute;
			
			_startVal = (!isNaN(startVal)) ? startVal : tweenObject[attribute];
			
			if (isNaN(_startVal)) { 
				_parentClass.removeTween(this);
				return;
			}

			_endVal = endVal;
			_delta = _endVal - _startVal;
			
			_duration = duration;
			_loop = loop;
			_yoyo = yoyo;
			_loops = loops;
			_delay = delay;

			if (_duration < 100) _duration *= 1000;
			if (_delay < 100) _delay *= 1000;
			
			_easeType = easeType;
			_easeStyle = easeStyle;
			
			_startHandler = startHandler;
			_doneHandler = doneHandler;
			
			tweenClassRef = getTweenClass(_easeStyle);
			getEaseMethod();
			
		}
		
		//
		//
		public static function getTweenClass (easeStyle:int):Class {
				
			switch (easeStyle) {
				
				case Tween.STYLE_LINEAR: return Linear;

				case Tween.STYLE_CUBIC: return Cubic;
					
				case Tween.STYLE_QUAD: return Quad;
					
				case Tween.STYLE_QUART: return Quart;
					
				case Tween.STYLE_QUINT: return Quint;
					
				case Tween.STYLE_SINE: return Sine;

				case Tween.STYLE_EXPO: return Expo;
						
				case Tween.STYLE_CIRC: return Circ;
					
				case Tween.STYLE_ELASTIC: return Elastic;
					
				case Tween.STYLE_BACK: return Back;
					
				case Tween.STYLE_BOUNCE: return Bounce;
				
			}
			
			return Linear;
			
		}
		
		//
		//
		private function getEaseMethod ():void {
			
			switch (_easeType) {
				
				case Tween.EASE_IN:
				
					easeMethod = "easeIn";
					break;
					
				case Tween.EASE_OUT:
				
					easeMethod = "easeOut";
					break;
					
				case Tween.EASE_INOUT:
				
					easeMethod = "easeInOut";
					break;
				
			}
			
		}
		
		//
		//
		public function ease ():void {

			var tweenVal:Number;
			
			if (isNaN(_startTime)) {
				_startTime = _parentClass.time + _delay;
			}
			
			_time = _parentClass.time - _startTime;

			if (_time < 0) return;
			
			if (!_started) onStart();
			_started = true;
			
			var t:Number = 0;
			
			if (_done || _tweenObject == null) {
				clear();
				return;
			}
			
			if (_time <= _duration) {
				
				t = _time;
				
			} else {
				
				t = _duration;
				_done = true;
				
			}

			if (tweenClassRef == null) return;
			tweenVal = tweenClassRef[easeMethod](t, _startVal, _delta, _duration);

			if (_tweenObject != null) _tweenObject[attribute] = tweenVal;
			
			if (_done) {
				
				if (_loop) {
					
					_loopsCompleted++;
					
					if (_loops == 0 || _loopsCompleted < _loops) {
		
						_done = false;
						_startTime = _parentClass.time;
						
						if (_yoyo) {

							var v:Number = _endVal;
							_endVal = _startVal;
							_startVal = v;
							_delta = _endVal - _startVal;
							if (_easeType == EASE_IN) _easeType = EASE_OUT;
							else if (_easeType == EASE_OUT) _easeType = EASE_IN;
						}
						
					}
					
				}	
				
			}
			
			if (_done) onDone();
			
		}
		
		//
		//
		private function onStart ():void {
			
			if (_startHandler != null) _startHandler(this);
			
		}
		
		//
		//
		private function onDone ():void {

			if (_doneHandler != null) _doneHandler(this);
			clear();

		}
		
		//
		//
		public function clear ():void {
			_parentClass.removeTween(this);
		}
		
	}
	
}