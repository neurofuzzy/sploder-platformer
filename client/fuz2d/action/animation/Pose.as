/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.animation 
{
	
	import com.adobe.serialization.json.JSON;
	import fuz2d.model.object.Bone;
	import fuz2d.util.Geom2d;
	
	import flash.utils.Dictionary;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class Pose {
		
		private var _rootBone:Bone;
		
		private var _data:Object;
		public function get data():Object { return _data; }
		public function set data(value:Object):void { _data = value; }

		//
		//
		public function Pose (rootBone:Bone, poseData:Object = null) {
			
			init(rootBone, poseData);

		}
		
		//
		//
		protected function init (rootBone:Bone, poseData:Object = null):void {
			
			_rootBone = rootBone;
			if (poseData != null) parse(poseData);
			else _data = { };			
			
		}
		
		//
		//
		public function parse (poseData:Object):Boolean {

			_data = poseData;

			if (_data) return true;
			
			return false;
			
		}
		
		//
		//
		public function record (filter:Dictionary = null):void {
			
			_data = recordBone(_rootBone, null, filter);
			
		}
		
		private function recordBone (bone:Bone, dataNode:Object = null, filter:Dictionary = null):Object {
			
			if (dataNode == null) dataNode = { };
			
			if (filter == null || filter[bone] != null) {
				dataNode[bone.name] = { r: Math.round(bone.rotation * Geom2d.rtd) };
			}
			
			for each (var childBone:Bone in bone.childBones) recordBone(childBone, dataNode[bone.name], filter);
			
			return dataNode;
			
		}
		
		public function getBonesInPose (bone:Bone = null, dataNode:Object = null):Array {
			
			if (bone == null) bone = _rootBone;
			
			var bonesInPose:Array = [];
			
			if (dataNode == null && bone == _rootBone) dataNode = data;

			if (bone == null || dataNode == null || dataNode[bone.name] == undefined) return bonesInPose;
			
			bonesInPose.push(bone);
			
			for each (var childBone:Bone in bone.childBones) {
				if (dataNode[bone.name][childBone.name] != undefined) {
					bonesInPose = bonesInPose.concat(getBonesInPose(childBone, dataNode[bone.name]));
				}
			}

			return bonesInPose;
			
		}
		
		//
		//
		public function apply (amount:Number = 1):void {
			
			if (_data != null && _data[_rootBone.name] != null) applyToBone(_rootBone, _data[_rootBone.name], amount);
			
		}
		
		//
		//
		private function applyToBone (bone:Bone, dataNode:Object = null, amount:Number = 1):void {
			
			if (dataNode != null) {

				if (amount == 1) {

					bone.rotation = (dataNode.r != null) ? parseFloat(dataNode.r) * Geom2d.dtr : bone.rotation;
					
				} else {
					
					amount = Math.min(1, Math.max(0, amount));
					
					bone.rotation = (dataNode.r != null) ? bone.rotation + (parseFloat(dataNode.r) * Geom2d.dtr - bone.rotation) * amount : bone.rotation;
					
				}
				
				for each (var childBone:Bone in bone.childBones) applyToBone(childBone, dataNode[childBone.name], amount);

			}
			
		}
		
		//
		//
		public static function applyBlended (bone:Bone, dataNodeA:Object, dataNodeB:Object, amount:Number = 1):void {
			
			if (dataNodeA != null && dataNodeB != null) {

				amount = Math.min(1, Math.max(0, amount));
					
				if (dataNodeA.r != null && dataNodeB.r != null) {
					
					var a:Number = parseFloat(dataNodeA.r) * Geom2d.dtr;
					var b:Number = parseFloat(dataNodeB.r) * Geom2d.dtr;
					
					if (bone.handle == null || 
						bone.handle.controller == null ||
						bone.handle.controller.priority > 0) {
							bone.rotation = a + (b - a) * amount;
						}
					
				}

				for each (var childBone:Bone in bone.childBones) Pose.applyBlended(childBone, dataNodeA[childBone.name], dataNodeB[childBone.name], amount);

			}
			
		}
		
		//
		//
		public function clone ():Pose {
			
			return new Pose(_rootBone, _data);
			
		}
		
		//
		//
		public function toString ():String {
			
			return JSON.encode(_data);
		}
		
	}
	
}