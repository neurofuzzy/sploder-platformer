/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.model.object {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import fuz2d.model.Model;
	import fuz2d.model.material.Material;
	import fuz2d.model.object.*;
	import fuz2d.util.Faster;
	import fuz2d.util.Geom2d;

	public dynamic class Bone extends Container2d {
	
		override public function set model(value:Model):void {
			super.model = value;
			for each (var childBone:Bone in childBones) childBone.model = value;
		}
		
		protected var _homeRotation:Number = 0;
		public function get homeRotation():Number { return _homeRotation; }
		
		protected var _homeX:Number;
		protected var _homeY:Number;

		public var name:String;
		public var child:Bone;
		public var childBones:Array;
		
		protected var _length:Number;
		public function get length():Number { return _length; }
		public function set length(value:Number):void { _length = value; }
		
		public var maxRotation:Number  = 0.05;
		
		public var skinRef:Biped;
		protected var _faces:Array;
		
		protected var _rotMin:Number = 0 - Geom2d.PI;
		protected var _rotMax:Number = Geom2d.PI;
		
		public function get rotMin ():Number { return _rotMin; }
		public function set rotMin (val:Number):void { _rotMin = (!isNaN(val)) ? val : _rotMin; }
		
		public function get rotMax ():Number { return _rotMax; }
		public function set rotMax (val:Number):void { _rotMax = (!isNaN(val)) ? val : _rotMax; }
		
		protected var _jointed:Boolean = false;
		public function get jointed():Boolean { return _jointed; }
		public function set jointed(value:Boolean):void { _jointed = value;	}
		
		public function get rootX ():Number {
			return (parentObject is Bone) ? Bone(parentObject).rootX : 0;
		}
		
		public function get rootY ():Number {
			return (parentObject is Bone) ? Bone(parentObject).rootY : 0;
		}
		
		public function get rootBone ():Bone {
			return (parentObject is Bone) ? Bone(parentObject).rootBone : this;
		}
		
		protected var _terminator:Boolean = false;
		public function get terminator():Boolean { return _terminator; }
		public function set terminator(value:Boolean):void { _terminator = value; }
		
		protected var _pinned:Boolean = false;
		public function get pinned():Boolean { return _pinned; }
		public function set pinned(value:Boolean):void { _pinned = value; }
			
		protected var _oldRot:Number;

		protected var _refPoint:Point2d;
		
		override public function set rotation (val:Number):void {
			
			super.rotation = val;
			_rotation -= _homeRotation;
			_rotation = Geom2d.constrainAngle(_rotation, _rotMin, _rotMax);
			_rotation = Geom2d.normalizeAngle(_rotation);
			_rotation += _homeRotation;

		}
		
		public function limitRotations (rot:Number = 0):void {

			if (rot == 0) rot = maxRotation;
			
			// limit rotation on single setting
			if (rotation - _oldRot > rot) {
				rotation = _oldRot + rot;
			} else if (_oldRot - rotation > rot) {
				rotation = _oldRot - rot;
			}
			
			_oldRot = rotation;						
			
		}
		
		protected var _scaleX:int = 1;
		public function get scaleX():int { return _scaleX; }
		public function set scaleX(value:int):void { _scaleX = (value == -1) ? -1 : 1; }
		
		protected var _scaleY:int = 1;
		public function get scaleY():int { return _scaleY; }
		public function set scaleY(value:int):void { _scaleY = (value == -1) ? -1 : 1; }
		
		public var handle:Handle;
		
		
		//
		//
		public function Bone (parentObject:Point2d = null, x:Number = 0, y:Number = 0) {
			
			super(parentObject, x, y, 1);
			
			childBones = [];
			_faces = [];
			
			_oldRot = rotation;
			
			_refPoint = new Point2d();

		}
		
		//
		//
		public function place (clip:Sprite):void {
			
			x = clip.x;
			y = 0 - clip.y;
			
			var scale:Number = 1;
			var pclip:DisplayObject = clip.parent;
			
			while (pclip != null) {
				
				scale *= pclip.scaleX;
				pclip = pclip.parent;
				
			}
			
			x *= scale;
			y *= scale;

			_homeX = x;
			_homeY = y;
			
			rotation = _homeRotation = clip.rotation * Geom2d.dtr;
			
			clip.rotation = 0;
			_length = clip.width;
			
			if (_parentObject is Bone && Bone(_parentObject).child == this) Bone(_parentObject).length = x;

			clip.rotation = _homeRotation * Geom2d.rtd;
			
		}
		
		//
		//
		public function getClip (instance:Sprite = null):Sprite {
			
			if (instance == null) instance = skinRef.skin;
			
			if (parentObject is Bone) {
				if (Bone(parentObject).getClip(instance)[name] != null) return Bone(parentObject).getClip(instance)[name];
				return rootBone.getClip(instance)[name];
			} else {
				return instance[name];
			}
			
		}
		
		//
		//
		public function align ():void {

			place(getClip());
			
		}
		
		//
		//
		public function assign (instance:Sprite):void {

			var boneClip:Sprite = getClip(instance);
			boneClip["bone"] = this;
			
		}
		
		//
		//
		public function addChildBone (bone:Bone):Bone {
			
			if (_childObjects.indexOf(bone) == -1) {
				_childObjects.unshift(bone);
				if (child == null) child = bone;
				childBones.unshift(bone);
				if (this[bone.name] == null || this[bone.name] is Bone) this[bone.name] = bone;
			}
	
			return bone;
			
		}
		
		//
		//
		public function removeChildBone (bone:Bone):void {
			
			if (_childObjects.indexOf(bone) != -1) {
				removeChildObject(bone);
				if (bone == child) child = null;
				childBones.splice(childBones.indexOf(bone), 1);
			}
			
		}
		
		//
		//
		override public function addChildObject (child:Point2d):Point2d {
			
			if (_childObjects.indexOf(child) == -1) {
				_childObjects.push(child);
			}
			
			return child;
			
		}
		
		//
		//
		override public function removeChildObject (child:Point2d):Point2d {
			
			if (_childObjects.indexOf(child) != -1) {
				if (child.parentObject == this) child.parentObject = null;
				_childObjects.splice(_childObjects.indexOf(child), 1);
			} else {
				//trace("remove child failed");
			}
			
			return child;
			
		}
		
		//
		//
		override public function update ():void {
			
			super.update();

		}
		
		//
		//
		public function reset (resetRotation:Boolean = false):void {
			
			x = _homeX;
			y = _homeY;
			
			if (resetRotation) rotation = _homeRotation;
			
		}
		
		//
		//
		public function pointAt (focalPoint:Point2d, relative:Boolean = false, maxRotation:Number = 0):void {
			
			worldRot = 0 - Geom2d.angleBetween(this, focalPoint);
			
			limitRotations(maxRotation);
			Geom2d.normalizeRotation(this);

		}
		
		//
		//
		public function reachTo (focalPoint:Point2d, relative:Boolean = false, maxRotation:Number = 0):Boolean {
		
			pointAt(focalPoint, relative, maxRotation);
			
			if (child == null) return false;
			
			Geom2d.clearRotation(child);
			
			var a:Number = Geom2d.distanceBetween(this, child);
			var b:Number = a;
			var c:Number = Geom2d.distanceBetween(this, focalPoint);
			
			if (child.child != null) b = Geom2d.distanceBetween(child, child.child);
			
			if (c > a + b) {
				child.pointAt(focalPoint, relative, maxRotation);
				return false;
			}
			
			var B:Number = Math.acos((b * b - a * a - c * c) / ( -2 * a * c));
			var C:Number = Math.acos((c * c - a * a - b * b) / ( -2 * a * b));
			
			if (!child.bendAxisPositive) {
				B = 0 - B;
				C = 0 - C;
			}
			
			rotation -= B;
			child.rotation += B - C - Geom2d.PI;

			limitRotations(maxRotation);
			child.limitRotations(maxRotation);
			
			Geom2d.normalizeRotation(this);
			Geom2d.normalizeRotation(child);

			return true;
			
		}		
		
	}
	
}
