/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.animation 
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	import fuz2d.action.behavior.Behavior;
	import fuz2d.action.behavior.GestureBehavior;
	import fuz2d.action.control.PoseEditorController;
	import fuz2d.action.play.*;
	import fuz2d.model.material.Material;
	import fuz2d.model.Model;
	import fuz2d.model.object.Biped;
	import fuz2d.model.object.Bone;
	import fuz2d.model.object.Marker;
	import fuz2d.model.object.Point2d;
	import fuz2d.util.Geom2d;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class PoseEditor {
		
		private var _rootBone:Bone;
		private var _playObj:PlayObjectControllable;
		
		public var currentBone:Bone;
		
		private var _controller:PoseEditorController;
		
		private var _bones:Array;
		
		private var _marker:Marker;
		
		private var _outline:Marker;
		
		private var _currentPose:Pose;
		
		private var _currentPoseIndex:int = 0;
		private var _currentPoseTime:int = 0;
		
		private var _gesture:Gesture;
		private var _gestureBehavior:GestureBehavior;
		
		protected var _playing:Boolean = false;
		public function get playing ():Boolean { return _playing; }
		
		private var _editedBones:Dictionary;
		
		//
		//
		public function PoseEditor (rootBone:Bone, playObj:PlayObjectControllable) {
			
			init(rootBone, playObj);
			
		}
		
		//
		//
		private function init (rootBone:Bone, playObj:PlayObjectControllable):void {
			
			currentBone = _rootBone = rootBone;
			_playObj = playObj;
			
			_playObj.behaviors.reset();
			if (_playObj.controller != null) _playObj.controller.end();
			
			_bones = [];
			_editedBones = new Dictionary(true);
			
			_controller = new PoseEditorController(this);
			
			_currentPose = new Pose(_rootBone);
			_currentPoseTime = 1000;
			
			_gesture = new Gesture("new", _rootBone);
			_gesture.addPose(_currentPose, _currentPoseTime);
			
			setBone(rootBone);
			
			_outline = new Marker(_playObj.object, NaN, "", 0, 0, 0, 1, new Material( { color: 0x00ff00 } ));
			_outline.alwaysOnTop = true;
			
			_playObj.model.addObject(_outline);
			
			_marker = new Marker(null, NaN, "", 0, 0, 0, 1, new Material( { color: 0x00ffff } ));
			_marker.alwaysOnTop = true;
			
			setMarker(_rootBone);
			
			_playObj.model.addObject(_marker);
			
		}
		
		//
		//
		public function loadGesture (gestureData:String):void {
			
			_gesture = new Gesture("new", _rootBone, gestureData);
			
			firstPose();
			
			setMarker(_bones[0]);
			
		}
		
		//
		//
		public function play ():void {
			
			if (!_playing) {
				
				recordPose();
				
				_gesture.startPose.apply();
				
				_playing = true;
				trace(_gesture.toString());
				_gestureBehavior = new GestureBehavior("new", _gesture.toString());
				_playObj.behaviors.add(_gestureBehavior);
				_gestureBehavior.addEventListener(Behavior.END, stop);

			}
			
		}
		
		//
		//
		public function stop (e:Event):void {
			
			_gestureBehavior.removeEventListener(Behavior.END, stop);
			_gestureBehavior = null;
			
			_playing = false;
			trace("stopping");
			applyPose();
			
		}
		
		//
		//
		private function setBone (bone:Bone):void {
			
			if (bone != null) {
				_bones.push(bone);
				for each (var childBone:Bone in bone.childBones) setBone(childBone);
			}
			
		}
		
		//
		//
		public function switchFacing ():void {
			
			if (_rootBone.parentObject is Biped) {
				
				var _biped:Biped = Biped(_rootBone.parentObject);
				
				_biped.facing += 1;
				
				if (_biped.facing > 2) _biped.facing = 0;
				
			}
			
		}
		
		//
		//
		public function prevBone ():void {
			
			var idx:int = _bones.indexOf(currentBone);
			idx--;
			if (idx < 0) idx = _bones.length - 1;
		
			setMarker(_bones[idx]);
			
			currentBone = Bone(_bones[idx]);
			
			trace("BONE:", currentBone.name);

		}
		
		//
		//
		public function nextBone ():void {
			
			var idx:int = _bones.indexOf(currentBone);
			idx++;
			if (idx >= _bones.length) idx = 0;
			
			setMarker(_bones[idx]);
			
			currentBone = Bone(_bones[idx]);
			
			trace("BONE:", currentBone.name);
			
		}
		
		//
		//
		public function firstBone ():void {
			
			setMarker(_bones[0]);
			
			currentBone = Bone(_bones[0]);
			
			trace("BONE:", currentBone.name);
			
		}
		
		//
		//
		public function lastBone ():void {
			
			setMarker(_bones[_bones.length - 1]);
			
			currentBone = Bone(_bones[_bones.length - 1]);
			
			trace("BONE:", currentBone.name);
			
		}
		
		//
		//
		public function rotateBone (amount:Number):void {
			
			currentBone.rotation += amount;
			addBone();
			
		}
		
		//
		//
		public function clearBone (bone:Bone = null):void {
			
			if (bone == null) bone = currentBone;
			
			bone.rotation = bone.homeRotation;
			delete _editedBones[bone];
			
			for each (var childBone:Bone in bone.childBones) clearBone(childBone);
			
		}
		
		//
		//
		public function addBone (bone:Bone = null):void {
			
			if (bone == null) bone = currentBone;
			
			_editedBones[bone] = 1;
			
			if (bone.parentObject is Bone) addBone(bone.parentObject as Bone);
			
		}
		
		//
		//
		public function prevPose ():void {
			
			recordPose();
			
			_currentPoseIndex--;
			
			if (_currentPoseIndex < 0) _currentPoseIndex = _gesture.lastPoseIndex;

			applyPose();
			
			trace("POSE:", _currentPoseIndex);
			
		}
		
		//
		//
		public function nextPose ():void {
			
			recordPose();
			
			_currentPoseIndex++;
			
			if (_currentPoseIndex > _gesture.lastPoseIndex) _currentPoseIndex = 0;
			
			applyPose();
			
			trace("POSE:", _currentPoseIndex);
			
		}
		
		//
		//
		public function firstPose ():void {
			
			recordPose();
			
			_currentPoseIndex = 0;
			
			applyPose();
			
			trace("POSE:", _currentPoseIndex);
			
		}
		
		//
		//
		public function lastPose ():void {
			
			recordPose();
			
			_currentPoseIndex = _gesture.lastPoseIndex;
			
			applyPose();
			
			trace("POSE:", _currentPoseIndex);
			
		}
		
		//
		//
		protected function applyPose ():void {
			
			_gesture.poseIndex = _currentPoseIndex;
			_currentPose = _gesture.getPose(_currentPoseIndex);
			_currentPoseTime = _gesture.getPoseTime(_currentPoseIndex);
			
			var bonesInPose:Array = _currentPose.getBonesInPose();
			trace(bonesInPose.length, _currentPose);
			
			_editedBones = new Dictionary(true);
			for each (var editedBone:Bone in bonesInPose) _editedBones[editedBone] = 1;
			
			_currentPose.apply();
			
			setMarker(currentBone);
			
		}
		
		//
		//
		protected function recordPose ():void {
			
			var data:Object = { };
			
			_currentPose.record(_editedBones);
			
		}
		
		
		//
		//
		public function addPose ():void {
			
			_gesture.addPose(_gesture.getPose(_gesture.lastPoseIndex).clone(), 1000);

		}
		
		//
		//
		public function clearPose ():void {
			
			if (_gesture.totalPoses > 1) {
				_gesture.removePose(_currentPose);
				prevPose();
			}
			
		}
		
		//
		//
		public function changePoseTime (timeOffset:int):void {
			
			_currentPoseTime += timeOffset;
			
			_currentPoseTime = Math.max(0, _currentPoseTime);
			
			_gesture.setPoseTime(_currentPoseTime);
			
		}
		
		//
		//
		private function setMarker (bone:Bone):void {
			
			_marker.alignToWorldCoords(bone);
			_marker.label = (bone.name + "\n" +
				"[r: " + Math.round(bone.rotation * Geom2d.rtd) + "]");
				
			_outline.label = ((_currentPoseIndex + 1) + " / " + _gesture.totalPoses + " | " + _currentPoseTime);
			
		}
		
		//
		//
		public function update ():void {
			
			setMarker(currentBone);
			
		}
		
		//
		//
		public function takeSnapShot ():void {
			
			_currentPose.record(_editedBones);
			trace(_gesture.toString());
			
		}
		
	}
	
}