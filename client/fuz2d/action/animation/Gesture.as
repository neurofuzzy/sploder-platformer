/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.animation {
	
	import com.adobe.serialization.json.JSON;
	import fuz2d.util.Geom2d;
	
	import fuz2d.Fuz2d;
	import fuz2d.model.object.Bone;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import fuz2d.action.animation.*;
	import fuz2d.action.animation.GestureEvent;
	import fuz2d.TimeStep;
	

	public class Gesture extends EventDispatcher {
		
		protected var _name:String;
		public function get name():String { return _name; }
		
		protected var _rootBone:Bone;
		
		protected var data:Object;
		
		protected var _startPose:Pose;
		public function get startPose():Pose { return _startPose; }
		
		private var _running:Boolean = false;
		
		protected var _midPoint:Boolean = false;
		
		protected var _poses:Array;
		protected var _poseTimes:Array;
		
		protected var _poseIndex:uint = 0;
		protected var _poseStartTime:int;
		protected var _poseEndTime:int;
		protected var _poseDuration:int;
		
		protected var _flip:Boolean = false;
		protected var _hold:uint = 0;
		protected var _yoyo:Boolean = false;
		protected var _reversing:Boolean = false;
		protected var _loop:Boolean = false;
		protected var _loops:uint = 0;
		protected var _currentLoop:uint = 0;
		protected var _relax:uint = 0;
		
		public function get poseIndex():uint { return _poseIndex; }
		public function set poseIndex(value:uint):void { _poseIndex = value; }
		
		public function get totalPoses ():uint { return _poses.length; }
		public function get lastPoseIndex ():uint { return _poses.length - 1; }
		
		protected var _playing:Boolean = false;
		public function get playing():Boolean { return _playing; }
		

		//
		//
		public function Gesture (name:String, rootBone:Bone, gestureData:Object = null, flip:Boolean = false, hold:uint = 0, yoyo:Boolean = false, loops:uint = 0, relax:uint = 0) {
			
			init(name, rootBone, gestureData, flip, hold, yoyo, loops, relax);
			
		}
		
		//
		//
		protected function init (name:String, rootBone:Bone, gestureData:Object = null, flip:Boolean = false, hold:uint = 0, yoyo:Boolean = false, loops:uint = 0, relax:uint = 0):void {
				
			_name = name;
			
			_rootBone = rootBone;
			
			_poses = [];
			_poseTimes = [];
			
			_startPose = new Pose(_rootBone);
			_startPose.record();

			_flip = flip;
			_hold = hold;
			_yoyo = yoyo;
			_loops = loops;
			_loop = (_loops > 0);
			_relax = relax;
			
			if (gestureData != null) parse(gestureData);
			else data = { };
			
		}
		
		//
		//
		public function parse (gestureData:Object):Boolean {
			
			//if (_flip) gestureData = flipDataString(gestureData);
			
			data = gestureData;
			
			_poses = [];
			_poseTimes = [];
			
			var nextPose:Pose;
			var poseNode:Object;
		
			if (data) {
				
				var plist:Array = [];
				
				for (var pname:String in data) plist.push(pname);
				
				plist.sort();
				
				for (var i:int = 0; i < plist.length; i++) {
					
					poseNode = data[plist[i]];
					if (_flip) flipNode(_rootBone, poseNode.data.body);
					nextPose = new Pose(_rootBone);
					nextPose.data = poseNode.data;
					_poses.push(nextPose);
					_poseTimes.push(parseInt(poseNode.time));
					
				}

				if (plist.length > 0 && _hold > 0) {
					
					nextPose = nextPose.clone();
					_poses.push(nextPose);
					_poseTimes.push(_hold);
					
				}
				
				if (_relax > 0) {
					
					_poses.push(new Pose(_rootBone, {}));
					_poseTimes.push(_relax);
					
				}
				
				return true;
				
			}
			
			return false;
			
		}
		
		//
		//
		public function flipDataString (data:String):String {
			
			return data.split("_rt").join("_tt").split("_lt").join("_rt").split("_tt").join("_lt");
			
		}
		
		//
		//
		public function flipNode (bone:Bone, node:Object):void {
			
			for (var param:String in node) {
				
				var offset:int = bone.homeRotation * Geom2d.rtd * 2;
				
				if (param == "r") node["r"] = offset - parseInt(node["r"]);
				
				if (param != "r" && param.length > 3) flipNode(bone.skinRef.getBoneByName(param), node[param]);
		
			}
			
		}
		
		//
		//
		public function clone ():Gesture {
			
			return new Gesture(_name, _rootBone, this.toString());
			
		}
		
		//
		//
		override public function toString ():String {
			
			var p:int = 0;
			
			data = { }
			
			for (var i:int = 0; i < _poses.length; i++) {
				
				data["p" + i] = { time: _poseTimes[i], data: Pose(_poses[i]).data };
				
			}
			
			return JSON.encode(data);
			
		}
		
		//
		//
		public function addPose (pose:Pose, time:uint):Pose {
			
			_poses.push(pose);
			_poseTimes.push(time);
			
			return pose;
			
		}
		
		//
		//
		public function removePose (pose:Pose = null, idx:int = -1):void {
			
			if (pose != null) {
				
				idx = _poses.indexOf(pose);
				
			}
			
			if (idx != -1) {
				
				_poses.splice(idx, 1);
				_poseTimes.splice(idx, 1);
				
			}
			
		}
		
		//
		//
		public function getPose (idx:int = -1):Pose {
			
			if (idx == -1) idx = _poseIndex;
			
			return _poses[idx];
			
		}
		
		//
		//
		public function getPoseTime (idx:int = -1):int {
			
			if (idx == -1) idx = _poseIndex;
			
			return _poseTimes[idx];
			
		}
		
		//
		//
		public function setPoseTime (time:uint, idx:int = -1):void {
			
			if (idx == -1) idx = _poseIndex;
			
			_poseTimes[idx] = time;
			
		}
		
		
		//
		//
		public function start ():void {
			
			_poseIndex = 0;
			_playing = true;
			
			nextPose(true);
			
		}
		
		//
		//
		public function stop ():void {
			
			_playing = false;
			_running = false;
			
		}
		
		//
		//
		protected function end ():void {
			
			stop();
			
			if (_hold == 0) dispatchEvent(new GestureEvent(GestureEvent.GESTURE_HOLD, false, false, this, _poses.length - 1));
			
			dispatchEvent(new GestureEvent(GestureEvent.GESTURE_END, false, false, this, _poses.length - 1));
		
		}
		
		//
		//
		public function update (e:Event):void {
			
			if (!_running) {
				dispatchEvent(new GestureEvent(GestureEvent.GESTURE_START, false, false, this, 0));
				_running = true;
			}
			
			var amount:Number = Math.min(1, (TimeStep.realTime - _poseStartTime) / _poseDuration);
			//var easeAmount:Number = Tween.getTweenClass(Tween.STYLE_BACK).easeOut(amount, 0, 1, 1);
			
			if (!_midPoint && amount >= 0.25) {
				_midPoint = true;
				dispatchEvent(new GestureEvent(GestureEvent.GESTURE_MID, false, false, this, _poseIndex));
			}
			
			var poseDataA:Object = _startPose.data.body;
			if (_poseIndex > 0) poseDataA = _poses[_poseIndex - 1].data.body;
			
			Pose.applyBlended(_rootBone, poseDataA, _poses[_poseIndex].data.body, amount);
			
			if (TimeStep.realTime - _poseStartTime > _poseDuration) nextPose();
			
			
		}
		
		//
		//
		protected function nextPose (starting:Boolean = false):void {
			
			_poseStartTime = TimeStep.realTime;
			_midPoint = false;
			
			if (!starting) {
				
				try {
					
					if ((_hold == 0 && _poseIndex < _poses.length - 1) || (_hold > 0 && _poseIndex < _poses.length - 2)) dispatchEvent(new GestureEvent(GestureEvent.GESTURE_KEYFRAME, false, false, this, _poseIndex));
					
					_poseIndex++;
					
					if (_hold > 0 && _poseIndex == _poses.length - 1) {
						dispatchEvent(new GestureEvent(GestureEvent.GESTURE_HOLD, false, false, this, _poses.length - 1));
					}
					
				} catch (e:Error) {
					trace("Gesture:", e);
				}
				
				if (_poseIndex >= _poses.length) {
					if (_yoyo && !_reversing) {
						_reversing = true;
						_poses.reverse();
						_poseTimes.reverse();
						_poseIndex = 1;
					} else {
						
						if (_currentLoop < _loops) {
							if (_yoyo) {
								_reversing = false;
								_poses.reverse();
								_poseTimes.reverse();	
							}
							_poseIndex = 0;
							_currentLoop++;
						} else {
							
							end();
							return;
						}
					}
					
				}
			}
			
			_poseEndTime = _poseStartTime + parseInt(_poseTimes[_poseIndex]);
			_poseDuration = _poseEndTime - _poseStartTime;
		
		}

		
	}
	
}