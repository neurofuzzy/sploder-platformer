/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.model.object {

	import flash.display.*;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import fuz2d.action.physics.MotionObject;
	import fuz2d.library.EmbeddedLibrary;
	
	import fuz2d.model.Model;
	import fuz2d.model.material.*;
	import fuz2d.util.*;
	
	//
	//
	public dynamic class Biped extends Symbol {
		
		public static const FACING_CENTER:uint = 0;
		public static const FACING_RIGHT:uint = 1;
		public static const FACING_LEFT:uint = 2;
		public static const FACING_BACK:uint = 3;
		
		public static const STATE_NORMAL:String = "normal";
		public static const STATE_KNEELING:String = "kneeling";
		public static const STATE_CLIMBING:String = "climbing";
		public static const STATE_ROLLING:String = "rolling";
		public static const STATE_BOARDED:String = "boarded";
		
		public var avatar:int = 0;
		
		protected var _facing:uint = FACING_LEFT;
		public function get facing():uint { return _facing; }
		public function set facing(value:uint):void {  if (_facing != value) updateStance(value); }
		
		override public function get state():String { return super.state; }
		
		override public function set state(value:String):void 
		{
			super.state = value;
			if (_state == STATE_KNEELING) facing = FACING_CENTER;
			if (_state == STATE_CLIMBING) facing = FACING_BACK;
			else if (facing == FACING_BACK) {
				if (MotionObject(_simObject).velocity.x < 0) {
					facing = FACING_LEFT;
				} else {
					facing = FACING_RIGHT;
				}
			}
			
		}
		
		override public function set model(value:Model):void {
			super.model = value;
			if (body != null) body.model = value;
		}

		public var skin:Sprite;
		protected var skeleton:TreeNode;
		
		protected var _boneMap:Dictionary;
		protected var _bones:Array;
		public function get bones():Array { return _bones; }
		
		public var handles:Object;

		public var body:Bone;
		
		protected var _tools_lt:Toolset;
		public function get tools_lt():Toolset { return _tools_lt; }
		
		protected var _tools_rt:Toolset;
		public function get tools_rt():Toolset { return _tools_rt; }
		
		protected var _tools_head:Toolset;
		public function get tools_head():Toolset { return _tools_head; }
		
		protected var _tools_back:Toolset;
		public function get tools_back():Toolset { return _tools_back; }
		
		protected var _armor:Armor;
		public function get armor():Armor { return _armor; }


		//
		//
		public function Biped (symbolName:String, library:EmbeddedLibrary, skeletonXML:XML, parentObject:Point2d = null, x:Number = 0, y:Number = 0, z:Number = 0, scale:Number = 1, material:Material = null) {
			
			super(symbolName, library, material, null, x, y, z, 0, scale, scale);
		
			init(symbolName, skeletonXML, material);
		
		}
		
		//
		//
		//
		private function init (symbolName:String, skeletonXML:XML, material:Material = null, optimize:Boolean = false, tolerance:Number = 0.1):void {
			
			_bones = [];
			_boneMap = new Dictionary();
			handles = { };
			
			_scaleX = _scaleY = 1
			
			createSkeleton(skeletonXML);
			assign();
			rig();
			assignTools();
			
			_armor = new Armor(this);
			
			_state = STATE_NORMAL;
			
			if (_symbolName == "player") _facing = FACING_CENTER;
			
			updateStance(_facing);

		}
		
		//
		//
		override protected function initSymbol ():void {
			
			var sym:DisplayObject = clip;
			
			if (sym != null) {
				
				_symbolExists = true;
				
				if (sym["bounds"] != null) {

					_width = Sprite(sym["bounds"]).width * _scaleX;
					_height = Sprite(sym["bounds"]).height * _scaleY;
	
				} else {
					
					_width = sym.width * _scaleX;
					_height = sym.height * _scaleY;
					
				}

			} else {
				
				_width = _height = 0;
				
			}
			
		}
		
		//
		//
		protected function createSkeleton (skeletonXML:XML):void {
			
			var node:TreeNode;
			
			// define a tree data skeleton to describe bone layout
			//

			skeleton = new TreeNode(skeletonXML.bone.@name);
		
			for each (var boneXML:XML in skeletonXML.bone..bone) {
				
				if (skeleton.getNode(boneXML.parent().@name) == null) {
					
					node = skeleton.createChild(boneXML.@name);
					
				} else {

					node = skeleton.getNode(boneXML.parent().@name).createChild(boneXML.@name);
					
				}
				
				node.xmlRef = boneXML;
				
			}
			
			var nodes:Array = skeleton.getAllNodes();
			
			var bone:Bone;
			var nx:XML;
			
			for each (node in nodes) {
				
				bone = new Bone(this);

				bone.name = node.name;

				bone.skinRef = this;
				_bones.push(bone);
				
				if (this[node.name] == null) this[node.name] = bone;
				
				_boneMap[node] = bone;
				
				if (node.parentNode != null) {
					bone.parentObject = _boneMap[node.parentNode];
					Bone(_boneMap[node.parentNode]).addChildBone(bone);
				} else {
					bone.parentObject = this;
				}
				
				if (node.xmlRef != null) {
					
					nx = node.xmlRef;
					
					bone.rotMin = parseInt(nx.@a) * Geom2d.dtr;
					bone.rotMax = parseInt(nx.@b) * Geom2d.dtr;

					bone.jointed = (nx.@j == "1") ? true : false;
					bone.terminator = (nx.@t == "1") ? true : false;
					bone.pinned = (nx.@p == "1") ? true : false;

				}
				
			}
			
		}
	
		//
		//
		protected function assign ():void {
			
			skin = clip;
			
			for each (var bone:Bone in _bones) bone.align();
			
		}

		//
		//
		protected function rig ():void {

			var bone:Bone;
			
			// add handles
			handles.body = new Handle(body);
			body.pinned = true;
			
			for each (bone in _bones) if (bone.terminator) handles[bone.name] = new Handle(bone);
			
		}
		
		//
		//
		protected function assignTools ():void {
				
			var sym:DisplayObject = clip;
			
			try { 
				
				var hand_lt:Sprite = sym["body"]["arm_lt"]["hand_lt"];
				var hand_rt:Sprite = sym["body"]["arm_rt"]["hand_rt"];
				var torso:Sprite = sym["body"]["torso"];
				var head:Sprite = sym["body"]["head"];
				
				if (hand_lt != null) _tools_lt = new Toolset(body.arm_lt.hand_lt, hand_lt);
				if (hand_rt != null) _tools_rt = new Toolset(body.arm_rt.hand_rt, hand_rt);
				if (torso != null) {
					_tools_back = new Toolset(body.torso, torso);
					_tools_back.flip = false;
				}
				if (head != null) {
					_tools_head = new Toolset(body.head, head);
					_tools_head.flip = false;
				}
			
			} catch (e:Error) {
				
				trace("Biped " + symbolName + " malformed: " + e);
				
				trace("*",sym);
				
				for (var param:String in sym) {
					if (sym[param] is Sprite) {
						trace("->",param)
						for (var param2:String in sym[param]) if (sym[param][param2] is Sprite) trace("\t->", param2);
					}
				}
				
			}
			
			if (sym["bounds"] != null) {

				_width = Sprite(sym["bounds"]).width * _scaleX;
				_height = Sprite(sym["bounds"]).height * _scaleY;

			} else {
				
				_width = sym.width * _scaleX;
				_height = sym.height * _scaleY;
				
			}
				
		}
		
		//
		//
		public function getBoneByName (name:String):Bone {
			
			for each (var bone:Bone in _bones) if (bone.name == name) return bone;
			
			return null;
			
		}
		
		//
		//
		override public function update ():void {
			
			super.update();
			
			for each (var bone:Bone in _bones) bone.update();
			
		}
		
		//
		//
		public function updateStance (dir:uint):void {
			
			_facing = dir;

			switch (_facing) {
				
				case FACING_LEFT:
					
					body.arm_lt.hand_lt.scaleY = 1;
					body.arm_rt.hand_rt.scaleY = -1;
					_tools_lt.rotationOffset = 0;
					_tools_lt.rotationOffset = 0;
					break;
				
				case FACING_RIGHT:
					
					body.arm_lt.hand_lt.scaleY = -1;
					body.arm_rt.hand_rt.scaleY = 1;
					_tools_lt.rotationOffset = Math.PI;
					_tools_lt.rotationOffset = Math.PI;
					break;
				
				case FACING_CENTER:
				default:
				
					body.arm_rt.hand_rt.scaleY = 1
					body.arm_lt.hand_lt.scaleY = -1;
					break;
					
			}
			
		}
		
		//
		//
		override public function translate(dx:Number, dy:Number):void {
			
			super.translate(dx, dy);
			
			for each (var handle:Handle in handles) {
				handle.x += dx;
				handle.y += dy;
			}
			
		}
		
		//
		override public function clearRotatedPosition ():void {
			
			super.clearRotatedPosition();
			for each (var bone:Bone in _bones) bone.clearRotatedPosition();

		}
		
		//
		public function updateSkin ():void {
			lightLevelChanged = true;
		}

	}
	
}
