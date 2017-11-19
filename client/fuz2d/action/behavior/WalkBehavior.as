/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.behavior {
	
	import flash.events.Event;
	import fuz2d.action.physics.*;
	import fuz2d.model.object.Point2d;
	import fuz2d.TimeStep;

	public class WalkBehavior extends BipedBehavior {
			
		protected var _lt:Point2d;
		protected var _rt:Point2d;
		
		protected var _hand_lt:Point2d;
		protected var _hand_rt:Point2d;
		
		protected var _planted_lt:Boolean = true;
		protected var _planted_rt:Boolean = true;
			
		protected var _cog:Vector2d;
		
		protected var _useRightFoot:Boolean = true;
		
		public var lean:Boolean = true;
		protected var _leanAmount:Number = 0;
		
		public var soundEvents:Boolean = false;
		protected var _stepTime:Number = 0;
		protected var _lastStep:int = 0;
		
		//
		//
		override public function set idle(value:Boolean):void {
			super.idle = value;
			//_stepTime = _parentClass.simulation.time;
			_stepTime = TimeStep.realTime;
		}
		
		//
		//
		public function WalkBehavior () {
			
			super();
			
		}
		
		//
		//
		override protected function init(parentClass:BehaviorManager):void {
			
			super.init(parentClass);

			_lt = new Point2d();
			_rt = new Point2d();
			_lt.alignTo(_handle_leg_lt);
			_rt.alignTo(_handle_leg_rt);

			_hand_lt = new Point2d();
			_hand_rt = new Point2d();			
			_hand_lt.alignTo(_handle_arm_lt);
			_hand_rt.alignTo(_handle_arm_rt);
			
			setCog();
			
			setFootPoint(true, true);
			setFootPoint(false, true);
			
			assign();

		}
				
		//
		//
		override public function update(e:Event):void {
			
			super.update(e);
		
			_moving = (Math.abs(chi.relativeVelocity.x) > 10 || !chi.torqueNegligible);
			
			if ((_planted_lt && _planted_rt && !_moving) || (chi.floating && chi.defyGravity)) {
				idle = true;
				return;
			}

			if (!_planted_lt || !_planted_rt || _moving) {
					
				if (idle) idle = false;
				
				var stride:int = 200;
				
				if (_parentClass.modelObject != null) {
					stride += (_parentClass.modelObject.height - 130) * 2;
				}
				
				var swapFeet:Boolean = Math.floor((TimeStep.realTime - _stepTime) / stride) % 2 == 0;
				
				setCog();
				
				if (_planted_lt && _planted_rt || _useRightFoot != swapFeet) { // if both feet planted
					
					if (_useRightFoot) {
						setFootPoint(true);
						_planted_rt = false;
					} else {
						setFootPoint(false);
						_planted_lt = false;
					}
					
					_useRightFoot = !_useRightFoot;
					
				} 
				
				if (_useRightFoot) _rt.y -= 2;
				else _lt.y -= 2;
				
				resolve();
				
			} else {
				
				if (!idle) idle = true;

			}
			

			if (!_moving) {
				_planted_lt = _planted_rt = true;
			}
			
			

		}
		
		//
		//
		protected function setCog ():void {
			
			_cog = chi.position.copy;
			_cog.y += Math.max(_handle_leg_lt.yhome, _handle_leg_rt.yhome);
			
		}
		
		//
		//
		protected function setFootPoint (right:Boolean, plant:Boolean = false):void {
			
			if (right) {
				
				_cog.alignPoint(_rt);
				_rt.x += body.body.leg_rt.x;
				
				if (!plant) _rt.x += chi.velocity.x * 0.3;
				
				_rt.y -= _handle_leg_rt.length;
				
				_hand_lt.alignTo(_rt);
				
				if (soundEvents && chi.inContact && TimeStep.realTime - _lastStep > 250 && chi.collisionObject.reactionType == ReactionType.BOUNCE) {
					if (Math.abs(chi.velocity.x) < 250) {
						_parentClass.playObject.eventSound("rightstep");
					} else {
						_parentClass.playObject.eventSound("rightrun");
					}
					_lastStep = TimeStep.realTime;
				}
				
			} else {
				
				_cog.alignPoint(_lt);
				_lt.x += body.body.leg_lt.x;
				
				if (!plant) _lt.x += chi.velocity.x * 0.3;

				_lt.y -= _handle_leg_lt.length;
				
				_hand_rt.alignTo(_lt);
				
				if (soundEvents && chi.inContact && TimeStep.realTime - _lastStep > 250 && chi.collisionObject.reactionType == ReactionType.BOUNCE) {
					if (Math.abs(chi.velocity.x) < 250) {
						_parentClass.playObject.eventSound("leftstep");
					} else {
						_parentClass.playObject.eventSound("leftrun");
					}
					_lastStep = TimeStep.realTime;
				}
				
			}
			
		}
		
		//
		//
		override public function assumeControl(force:Boolean = false):void {
			
			if (!force) {
				
				if (_handle_body.controller == null) {
					_handle_body.controller = this;
					_handle_body.rotation = 0;
					_handle_body.pull(0.1);
				}
				
			}
				
			super.assumeControl(force);
			
			
		}
		
		//
		//
		override public function resolve():void {
			
			super.resolve();
			
			if (_handle_body.controller == this) {
			
				var xv:Vector2d = chi.relativeVelocity;

				if (Math.abs(xv.x) > 10) {
					_leanAmount += ((xv.x * 0.002) - _leanAmount) * 0.1;
					_leanAmount = Math.max( -0.5, Math.min(_leanAmount, 0.5));
					_handle_body.rotation = _leanAmount;
				} else {
					_handle_body.rotation = 0;
				}
				
				_handle_body.pull(0.03);

			}
			
			if (_handle_head.controller == this) {
				_handle_head.rotation = 0 - _handle_body.rotation * 0.8;
				_handle_head.pull(0.03);
			}
				
			if (_handle_leg_lt.controller == this) {
				_handle_leg_lt.alignTo(_lt, true, false);	
				_handle_leg_lt.pull(0.3);
			}
			
			if (_handle_leg_rt.controller == this) {
				_handle_leg_rt.alignTo(_rt, true, false);
				_handle_leg_rt.pull(0.3);
			}
			
			if (_handle_arm_lt.controller == this) {
				_handle_arm_lt.alignTo(_hand_lt, true, false);	
				_handle_arm_lt.pull(0.1);
			}
			
			if (_handle_arm_rt.controller == this) {
				_handle_arm_rt.alignTo(_hand_rt, true, false);
				_handle_arm_rt.pull(0.1);
			}	
			
			if (_handle_hand_lt.controller == this) {
				_handle_hand_lt.rotation = 0;
				_handle_hand_lt.pull(0.1);
			}
			
			if (_handle_hand_rt.controller == this) {
				_handle_hand_rt.rotation = 0;
				_handle_hand_rt.pull(1);
			}			
			
		}
		
	}
	
}