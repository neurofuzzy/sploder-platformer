package fuz2d.model.object {
	
	import flash.geom.Point;
	
	import fuz2d.action.behavior.Behavior;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class Handle extends Point2d {

		public var name:String;
		protected var _parentBone:Bone;
		
		protected var _xhome:Number;
		protected var _yhome:Number;

		public function get xhome():Number { return _xhome; }
		public function get yhome():Number { return _yhome; }
		
		public function get length():Number { return _parentBone.length; }

		protected var _reachBone:Bone;
		protected var _reachRelative:Boolean = false;

		protected var _controller:Behavior;
		public function get controller ():Behavior { return _controller; }
		public function set controller (newController:Behavior):void {
			if (_controller == null || newController == null || _controller.priority > newController.priority || _controller.idle) {
				_controller = newController;
			}
		}
		public function get controlled ():Boolean { return (_controller != null); }
		
		override public function set x (val:Number):void {
			super.x = val;
		}

		override public function set y (val:Number):void {
			super.y = val;
		}
		
		public function get reachBone():Bone { return _reachBone; }
		

		//
		//
		//
		public function Handle (parentBone:Bone) {
			
			super(null);
			
			init(parentBone);
		
			
		}
		
		//
		//
		//
		private function init (parentBone:Bone):void {
			
			_parentBone = parentBone;
			_parentBone.handle = this;

			name = _parentBone.name;

			var pt:Point = new Point(0, 0);
			pt = Point.polar(_parentBone.length, _parentBone.homeRotation);
	
			x = _parentBone.worldX + pt.x;
			y = _parentBone.worldY - pt.y;
			
			_xhome = pt.x;
			_yhome = 0 - pt.y;

			if (_parentBone.jointed && _parentBone.parentObject != null && 
				_parentBone.parentObject is Bone) {
					
				_reachBone = Bone(_parentBone.parentObject);
				
			} else {
				
				_reachBone = _parentBone;
				
			}

		}
			
		//
		//
		//
		public function pull (maxRotation:Number = 0):Boolean {
			
			if (_parentBone.jointed) return _reachBone.reachTo(this, _reachRelative, maxRotation);
			else if (!_parentBone.pinned) _reachBone.pointAt(this, _reachRelative, maxRotation);
			else _reachBone.rotation += Math.min(maxRotation, Math.max(0 - maxRotation, this.rotation - _reachBone.rotation));
			
			return false;
			
		}

		//
		//
		//
		public function release ():void {
			
			_controller = null;
			
		}	
		
		//
		//
		//
		public function reset ():void {
			
			release();
			x = _parentBone.worldX + _xhome;
			y = _parentBone.worldY + _yhome;

		}
		
		//
		//
		//
		public function center ():void {
			
			x = _parentBone.worldX;
			y = _parentBone.worldY;

		}
		
	}
	
}