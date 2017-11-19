/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.play {
	
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.getQualifiedClassName;
	import fuz2d.library.ObjectDefinition;
	
	import fuz2d.Fuz2d;
	import fuz2d.action.behavior.*;
	import fuz2d.action.control.*;
	import fuz2d.action.physics.*;
	import fuz2d.model.*;
	import fuz2d.model.object.*;
	import fuz2d.util.Geom2d;
	

	public class PlayObjectMovable extends PlayObjectControllable {
		
		public static const MOVE:String = "move";
		public static const TURN:String = "turn";
		public static const STRAFE:String = "strafe";
		public static const JUMP:String = "jump";
		
		protected var sideVector2d:Vector2d;
		
		protected var _fwdPower:Number = 0;
		protected var _backPower:Number = 0;
		protected var _sidePower:Number = 0;
		protected var _risePower:Number = 0;
		protected var _turnPower:Number = 0;
		protected var _jumpPower:Number = 0;
		
			
		public function get fwdPower():Number { return _fwdPower; }
		
		public function set fwdPower(value:Number):void 
		{
			_fwdPower = value;
		}
		
		public function get backPower():Number { return _backPower; }
		
		public function set backPower(value:Number):void 
		{
			_backPower = value;
		}
		
		public function get sidePower():Number { return _sidePower; }
		
		public function set sidePower(value:Number):void 
		{
			_sidePower = value;
		}
		
		public function get turnPower():Number { return _turnPower; }
		
		public function set turnPower(value:Number):void 
		{
			_turnPower = value;
		}
		
		
		public function get jumpPower():Number { return _jumpPower; }
		public function set jumpPower(value:Number):void 
		{
			_jumpPower = value;
		}
		
		protected var _speedFactor:Number = 1;
		public function get speedFactor():Number { return _speedFactor; }
		
		protected var _standPoint:Point2d;
		public function get standPoint():Point2d { return _standPoint; }
		
		
		
		
		//
		//
		public function PlayObjectMovable (type:String, creator:Object, main:Fuz2d, def:ObjectDefinition, health:int = 1, strengthFactor:Number = 1, speedFactor:Number = 1) {
			
			super(type, creator, main, def, health, strengthFactor);
			
			_speedFactor = speedFactor;

		}
		
		//
		//
		override protected function init ():void { 
			
			super.init();
			
			sideVector2d = new Vector2d(null, 1, 0);
			
			_fwdPower = 1000;
			_backPower = 1000;
			_sidePower = _risePower = 500;
			_turnPower = 0.005;
			
		}
		
		//
		//
		override protected function initializeReferencePoints ():void {
			
			super.initializeReferencePoints();
			
			_standPoint = new Point2d(_modelObjectRef, 0, 0 - _modelObjectRef.height * 0.5 - Model.GRID_HEIGHT * 0.5);
			
		}
		
		
		/*
		 * --------------------------------------------------------
		 * OBJECT MOVEMENT
		 * --------------------------------------------------------
		 */
		
		//
		//
		public function move (v:Vector2d, p:Number):void {
			
			var force:Force = new Force(v.x * p, v.y * p);
			_simulation.addForce(force, _simObjectRef);				
			
		}
		
		//
		//
		public function turn (direction:Number, p:Number):void {
			
			var force:Force = new Force(direction * p, 0, true);
			_simulation.addForce(force, _simObjectRef);				
			
		}
		
		//
		//
		public function jump (x:int = 0, power:Number = 1):void {

			var v:Vector2d = _simObjectRef.orientation;
			if (x != 0) power *= 0.75;
			var force:Force = new Force(_jumpPower * 0.02 * x, v.y * _jumpPower * 0.2 + _jumpPower * power);

			_simulation.addForce(force, _simObjectRef);				
			
		}
		
		//
		
		public function moveDown (factor:Number = 1):void { move(_simObjectRef.orientation, _fwdPower * _controller.delta * factor); }

		public function moveUp (factor:Number = 1):void { move(_simObjectRef.orientation, -_backPower * _controller.delta * factor); }
		
		public function moveRight (factor:Number = 1):void { move(_simObjectRef.orientationRight, _sidePower * _controller.delta * factor); }

		public function moveLeft (factor:Number = 1):void { move(_simObjectRef.orientationRight, -_sidePower * _controller.delta * factor); }	
		
		public function clamp (speed:Number):void {
			
			MotionObject(_simObjectRef).velocity.clamp(speed);
			
		}
		
	}
	
}
