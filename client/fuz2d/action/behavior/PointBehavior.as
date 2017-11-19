/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.behavior {
	
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Point;
	import fuz2d.action.physics.*;
	import fuz2d.action.play.PlayObject;
	import fuz2d.model.material.Material;
	import fuz2d.model.object.Bone;
	import fuz2d.model.object.Circle2d;
	import fuz2d.model.object.Handle;
	import fuz2d.model.object.Symbol;
	import fuz2d.model.object.Point2d;
	import fuz2d.screen.BitView;
	import fuz2d.screen.BitViewPlus;
	import fuz2d.screen.shape.Circle;
	import fuz2d.screen.View;
	
	import fuz2d.model.object.Biped;
	import fuz2d.model.object.Object2d;
	
	import fuz2d.util.Geom2d;

	public class PointBehavior extends BipedBehavior {
		
		public static const UP:uint = 0;
		public static const SIDE:uint = 1;
		
		protected var _direction:uint;
		protected var _handles:Array;
		
		public var pointCenter:Boolean = true;
		
		public var pointAtMouse:Boolean = false
		protected var _mousePoint:Point;
		
		override public function set idle(value:Boolean):void {
			
			if (idle && value == false) assumeControl(true);
			super.idle = value;
		}
		
		//
		//
		public function PointBehavior (direction:uint, handles:Array, priority:int) {
			
			super(priority);
			
			_direction = direction;
			_handles = [];
			
			_mousePoint = new Point();
			
			if (handles != null) {
				for (var i:int = 0; i < handles.length; i++) {
					if (handles[i] is Handle) addHandle(Handle(handles[i]));
				}
			}	
			
		}
		
		
		//
		//
		override protected function init(parentClass:BehaviorManager):void {
			
			super.init(parentClass);
			
			assign();

		}
		
		//
		//
		public function addHandle (handle:Handle):void {
			if (_handles.indexOf(handle) == -1) _handles.push(handle);
		}
		
		//
		//
		public function removeHandle (handle:Handle):void {
			if (_handles.indexOf(handle) != -1) _handles.splice(_handles.indexOf(handle), 1);
		}
		
		//
		//
		override public function assign():void {
				
			for each (var handle:Handle in _handles) handle.controller = this;
			
		}
		
		//
		//
		override public function update(e:Event):void {
			
			super.update(e);
			if (!_idle) resolve();
			
		}
		
		//
		//
		override public function assumeControl(force:Boolean = false):void {
			
			for each (var handle:Handle in _handles) if (handle.controller == null || force) handle.controller = this;
			
		}
		
		//
		//
		override public function releaseControl():void {
			
			for each (var handle:Handle in _handles) if (handle.controller == this) handle.controller = null;
			
		}
		
		//
		//
		override public function resolve():void {
			
			super.resolve();

			var body:Biped = Biped(_parentClass.modelObject);
			var handle:Handle;
			
			if (!pointAtMouse) {
				
				for each (handle in _handles) if (handle.controller == this) {
					
					handle.center();
					
					if (body.facing == Biped.FACING_LEFT) handle.x -= 100;
					else if (body.facing == Biped.FACING_RIGHT) handle.x += 100;
					else {
						if (pointCenter) {
							handle.x += 100;
						}
						else handle.y -= 100;
					}
					handle.y -= 2;
					
					handle.pull(0.3);
					
				}
			
			} else {
				
				_mousePoint.x = Main.mainStage.mouseX;
				_mousePoint.y = Main.mainStage.mouseY;
				
				if (GameLevel.gameEngine.camera) {
					
					_mousePoint.x = GameLevel.gameEngine.camera.x + ((_mousePoint.x - Main.mainStage.width * 0.5) / View.scale);
					_mousePoint.y = GameLevel.gameEngine.camera.y - ((_mousePoint.y - Main.mainStage.height * 0.5) / View.scale);
				
					if (body.facing == Biped.FACING_LEFT && _mousePoint.x > _parentClass.modelObject.x + 20) body.facing = Biped.FACING_RIGHT;
					if (body.facing == Biped.FACING_RIGHT && _mousePoint.x < _parentClass.modelObject.x - 20) body.facing = Biped.FACING_LEFT;
					
					for each (handle in _handles) if (handle.controller == this) {
						
						handle.alignToPoint(_mousePoint);
						handle.pull(10);
						
					}
					
				}
				
			}
		
			
		}
		
	}
	
}