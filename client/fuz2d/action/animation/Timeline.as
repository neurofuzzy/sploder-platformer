/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.animation {

	public class Timeline {
		
		private var _keyframes:Array;
		private var _index:Array;
		private var fps:uint = 30;
		
		//
		//
		public function Timeline (fps:uint) {
			
			_keyframes = [];
			_index = [];
			
		}
		
		//
		//
		public function keyframeAt (frame:uint, tween:Boolean = true):Keyframe {
			
			if (_keyframes.length > 0) {
				
				if (_keyframes[frame] != undefined) {
					
					return _keyframes[frame];
					
				}
				
				var i:uint;
				var prevKey:Keyframe = Keyframe(_keyframes[0]);
				var nextKey:Keyframe = Keyframe(_keyframes[0]);
				
				for (i = 1; i < _index.length; i++) {
					
					if (_index[i] < frame) {
						prevKey = nextKey = Keyframe(_keyframes[_index[i]]);
					}
					
					if (i < _index.length - 1) {
						if (_index[i + 1] > frame) {
							nextKey = Keyframe(_keyframes[_index[i + 1]]);
							break;
						}
					}
					
				}
				
				if (prevKey == nextKey) {
					
					return prevKey;
					
				} else if (tween) {
					
					var attribs:Object = {};
					var mid:Number = (frame - prevKey.frame) / (nextKey.frame - prevKey.frame);
					
					for (var attrib:String in prevKey.attributes) {
						attribs[attrib] = prevKey.attributes[attrib];
						if (nextKey.attributes[attrib] != undefined) {
							try {
								attribs[attrib] = prevKey.attributes[attrib] + (nextKey.attributes[attrib] * mid);
							}
						}
					}
					
					return new Keyframe(frame, attribs);
					
				}
			
			}
			
			return null;
			
		}
		
		//
		//
		public function addKeyframe (frame:uint, attribs:Object):Keyframe {
			
			var key:Keyframe = new Keyframe(frame, attribs);
			_keyframes[frame] = key;
			
			var indexIndex = _index.indexOf(frame);
			if (indexIndex != -1) {
				_index.push(frame);
				_index.sort();
			}
			
			return key;
			
		}
		
		//
		//
		public function removeKeyframe (frame:uint):void {
			
			delete _keyframes[frame];
			
			var indexIndex = _index.indexOf(frame);
			if (indexIndex != -1) {
				_index.splice(indexIndex, 1);
			}
			
		}
		
	}
	
}
