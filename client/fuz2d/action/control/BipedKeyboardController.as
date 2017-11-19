package fuz2d.action.control {
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.media.SoundChannel;
	import flash.ui.Keyboard;
	
	import fuz2d.action.animation.GestureEvent;
	import fuz2d.action.behavior.*;
	import fuz2d.action.modifier.PushModifier;
	import fuz2d.action.physics.CollisionEvent;
	import fuz2d.action.physics.MotionObject;
	import fuz2d.action.physics.Vector2d;
	import fuz2d.action.play.*;
	import fuz2d.Fuz2d;
	import fuz2d.library.ObjectFactory;
	import fuz2d.model.object.Biped;
	import fuz2d.model.object.Symbol;
	import fuz2d.screen.View;
	import fuz2d.TimeStep;
	import fuz2d.util.*;
	
	
	
	

	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class BipedKeyboardController extends PlayObjectController {
		
		private var _biped:BipedObject;
		protected var _mot:MotionObject;
		
		private var _pointer_rt:Behavior;
		private var _pointer_lt:Behavior;
		private var _force_lt:ForceBehavior;
		private var _grapple_lt:GrappleBehavior;
		private var _raygun_rt:RaygunBehavior;
		
		public function get grapple_lt():GrappleBehavior { return _grapple_lt; }
		
		protected var _canDoubleJump:Boolean = false;

		private var _lastSound:int;
		
		private var _jetpackSound:SoundChannel;
		
		override public function get active():Boolean { return super.active; }
		
		override public function set active(value:Boolean):void 
		{
			super.active = value;
			
			if (!value) {
				if (_grapple_lt && !_grapple_lt.idle) _grapple_lt.idle = true;
				if (_force_lt && !_force_lt.idle) _force_lt.idle = true;
				if (_pointer_lt && !_pointer_lt.idle) _pointer_lt.idle = true;
				if (_pointer_rt && !_pointer_rt.idle) _pointer_rt.idle = true;
				if (_raygun_rt && !_raygun_rt.idle) _raygun_rt.idle = true;
			}
		}
		
		//
		//
		public function BipedKeyboardController (object:PlayObjectControllable) {
			
			super(object);
			
		}
		
		override protected function init(object:PlayObjectControllable):void {
			
			super.init(object);
			
			_biped = object as BipedObject;
			_mot = MotionObject(_biped.simObject);
			
			_force_lt = ForceBehavior(_biped.behaviors.add(new ForceBehavior([_biped.body.handles.arm_lt], Biped(_biped.object).tools_lt, "powerglove", 0)));
			_grapple_lt = GrappleBehavior(_biped.behaviors.add(new GrappleBehavior([_biped.body.handles.arm_lt], Biped(_biped.object).tools_lt, "grapple", 0)));
			
			_pointer_rt = _biped.behaviors.add(new PointBehavior(0, [_biped.body.handles.arm_rt], 0));
			_pointer_lt = _biped.behaviors.add(new PointBehavior(0, [_biped.body.handles.arm_lt], 0));
			
			_raygun_rt = RaygunBehavior(_biped.behaviors.add(new RaygunBehavior([_biped.body.handles.arm_rt], Biped(_biped.object).tools_rt)));
			_raygun_rt.idle = true;
			
			Key.initialize(View.mainStage);
			View.mainStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
			View.mainStage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
			
			View.mainStage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			_object.simObject.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);
			
		}
		
		//
		//
		override public function update (e:Event):void {
			
			if (_ended || !_active) return;
			
			if (_biped && _biped.body) {
				
				if (_biped.body.attribs.pouncing) {
					pounce();
					_biped.body.attribs.pouncing = false;
				}
				
				if (_biped.stamina < 100) {
					_biped.stamina += 0.0625;
				}
				
			}
			
			if (_biped.locked) return;
			
			super.update(e);
			
			checkKeys();
			checkMouse();
			
			if (_biped.simObject.inContact && !_biped.rolling && MotionObject(_biped.simObject).contactObjFriction > 0 && !Key.isDown(Keyboard.LEFT) && !Key.isDown(Keyboard.RIGHT) && !Key.charIsDown("a") && !Key.charIsDown("d")) {
				if (MotionObject(_biped.simObject).contactObjVelocity == MotionObject.zeroVelocity) {
					MotionObject(_biped.simObject).velocity.x *= 0.6;
				} else {
					MotionObject(_biped.simObject).velocity.x += (MotionObject(_biped.simObject).contactObjVelocity.x - MotionObject(_biped.simObject).velocity.x) * 0.2; 
				}
			}
			
		}

		//
		//
		private function checkMouse ():void {
			
		}
		
		//
		//
		private function onMouseDown (e:MouseEvent):void {
			
			if (!_pointer_rt.idle && PointBehavior(_pointer_rt).pointAtMouse) {
				
				_biped.attack("middle");
				
			}

		}
		
		//
		//
		private function checkKeys ():void {
			
			var power:Number = 1;
			
			if (_biped.crouching) power = 0.2;
			
			if (!_biped.jumping && !_biped.rolling && (_biped.standing || _biped.floating) && _force_lt.idle) {
				
				var pfactor:Number = 1;
				
				if (Key.isDown(Keyboard.LEFT) || Key.isDown(Keyboard.RIGHT)) {
					if (Math.abs(_mot.velocity.x) < 10) pfactor = 5;
				}
				
				if (_mot.contactObjFriction == 0) power = 0.25;
					
				if (Key.isDown(Keyboard.LEFT) || Key.charIsDown("a")) {
					if (_mot.velocity.x > -250) {
						if (Key.shiftKey || _biped.attacking) {
							_biped.moveLeft(0.25 * power);
						} else {
							_biped.faceLeft();
							_biped.moveLeft(power * pfactor);
						}
					}
				}
				
				if (Key.isDown(Keyboard.RIGHT) || Key.charIsDown("d")) {
					if (_mot.velocity.x < 250) {
						if (Key.shiftKey || _biped.attacking) {
							_biped.moveRight(0.25 * power);
						} else {
							_biped.faceRight();
							_biped.moveRight(power * pfactor);
						}
					}
				}
				
			} else if (!_biped.standing && !_biped.rolling && _force_lt.idle) {
				
				var jumpvel:Number = 200;
				if (Key.shiftKey) jumpvel *= 1.25;

				if (Key.isDown(Keyboard.LEFT) || Key.charIsDown("a")) {
					
					if (_biped.jumping) {
						if (_biped.body.facing == Biped.FACING_LEFT) {
							_mot.velocity.x = 0 - jumpvel;
						} else {
							if (!Key.shiftKey && _mot.velocity.x > 1) _mot.velocity.x *= 0.5;
							else _biped.moveLeft(0.35 * power);
						}
					} else {
						_biped.moveLeft(0.35 * power);
					}
				}
				if (Key.isDown(Keyboard.RIGHT) || Key.charIsDown("d")) {
					if (_biped.jumping) {
						if (_biped.body.facing == Biped.FACING_RIGHT) {
							_mot.velocity.x = jumpvel;
						} else {
							if (!Key.shiftKey && _mot.velocity.x < -1) _mot.velocity.x *= 0.5;
							else _biped.moveRight(0.35 * power);
						}
					} else {
						_biped.moveRight(0.35 * power);
					}
				}
				
			}

			if (_force_lt.idle) {
					
				if (Key.isDown(Keyboard.UP) || Key.charIsDown("w")) {
					
					if (_mot.canBoard && _grapple_lt.idle) {
						
					} else if (_biped.floating) {
						
						_biped.moveUp();
						
					} else if (_mot.canClimb && !_biped.rolling && _grapple_lt.idle) {
						
						if (!_mot.isClimbing) {
							_mot.climbEngaged = true;
							_biped.crouching = false;
							if (_biped.jumping && _biped.lastJump) _biped.lastJump.end();
						}
						
						_biped.moveUp();
						
					} else if (!_biped.crouching && !_biped.jumping && !_biped.attacking && _biped.standing) {
						
						var x:int = JumpBehavior.CENTER;
						var jp:Number = 1;
						
						if (Key.isDown(Keyboard.LEFT) || Key.charIsDown("a")) x = JumpBehavior.LEFT;
						else if (Key.isDown(Keyboard.RIGHT) || Key.charIsDown("d")) x = JumpBehavior.RIGHT;	
					
						if (!Key.shiftKey) {
							if (Key.isDown(Keyboard.LEFT) || Key.charIsDown("a")) _biped.faceLeft();
							else if (Key.isDown(Keyboard.RIGHT) || Key.charIsDown("d")) _biped.faceRight();
						} else {
							if (Key.isDown(Keyboard.LEFT) || Key.isDown(Keyboard.RIGHT)) jp = 1.2;
						}
						
						var rotate:Boolean = Key.shiftKey;
						
						if (!(_biped.body.tools_lt.toolname == "grapple" && rotate)) {
					
							if (_force_lt.forceObject == null) {
								_biped.startJump(x, jp, rotate);
								_canDoubleJump = false;
							}
							
							if (_force_lt.forceObject == null && rotate && x != JumpBehavior.CENTER) {
								
								var s:Symbol;
								
								if (x == JumpBehavior.LEFT) {
									s = ObjectFactory.effect(_object, "swingeffectleft", true, 1000);
									s.point = _object.object.point;
								} else {
									s = ObjectFactory.effect(_object, "swingeffectright", true, 1000);
									s.point = _object.object.point;
								}
				
							}
						
						}
						
					} else if (_canDoubleJump && _biped.jumping && _biped.lastJump && !_biped.lastJump.ended) {
						
						_biped.lastJump.doubleJump();
						
					}
					
				}
				
				if (Key.isDown(Keyboard.DOWN) || Key.charIsDown("s")) {
					
					if (_biped.floating) {
						
						_biped.moveDown();
						
					} else if (_mot.canClimb && !_biped.jumping && !_biped.rolling && !_mot.inContact) {
						
						if (!_mot.isClimbing) {
							_mot.climbEngaged = true;
							_biped.crouching = false;
						}
						_biped.moveDown();
						
					} else if (!_biped.jumping) {
						
						_biped.crouching = true;
						
					} else {
						
						_biped.gravityKicking = true;
						
					}
					
				} else {
					
					_biped.gravityKicking = false;
					
				}
		
			}
				
			if (_biped.crouching && !(Key.isDown(Keyboard.DOWN) || Key.charIsDown("s"))) _biped.crouching = false;
			
			if (Key.isDown(Keyboard.SPACE)) {
				
				if (_biped.climbing) _mot.climbEngaged = false;
				
				_object.striking = true;
				
				if (_biped.jumping && _mot.velocity.y > 0) {
					_biped.attack("high");
				} else if (_biped.crouching) {
					_biped.attack("low");
				} else {
					_biped.attack("middle");
				}
				
			} else {
				
				_object.striking = false;
				
			}
			
			if (_biped.body.tools_back.toolname == "backpack") {
				if (Key.charIsDown("c") && _biped.body.tools_back.count > 0) {
					_biped.jump(0,2);
					_biped.body.tools_back.active = true;
					_biped.body.tools_back.count--;
					if (_jetpackSound == null) {
						_jetpackSound = Fuz2d.sounds.addSoundLoop(_object, "jetpack1");
					}
					if (_biped.body.facing == Biped.FACING_CENTER) {
						if (Key.isDown(Keyboard.RIGHT) || Key.charIsDown("a")) {
							_biped.faceRight();
						} else if (Key.isDown(Keyboard.LEFT) || Key.charIsDown("d")) {
							_biped.faceLeft();
						}
					}
					if (_biped.climbing) {
						_mot.climbEngaged = false;
						_biped.climbing = false;
					}
				} else {
					_biped.body.tools_back.active = false;
					if (_jetpackSound != null) {
						_jetpackSound.stop();
						_jetpackSound = null;
					}
				}
			} else if (_jetpackSound != null) {
				_jetpackSound.stop();
				_jetpackSound = null;
			}
			
			_pointer_rt.idle = !(_biped.body.tools_rt.action == "point" && _biped.body.tools_rt.toolname != "blaster");
			
			if (_pointer_rt.idle && _biped.body.tools_rt.action == "mousepoint") {
				_pointer_rt.idle = false;
			}
			
			if (!_pointer_rt.idle) PointBehavior(_pointer_rt).pointAtMouse = (_biped.body.tools_rt.action == "mousepoint");
			
			if (_biped.body.tools_rt.toolname == "blaster") {
				
				_raygun_rt.idle = false;

				if (Key.isDown(Keyboard.SPACE) && _biped.body.tools_rt.count > 0) {
					_raygun_rt.fire();
					//if (_raygun_rt.fire()); //_biped.body.tools_rt.count--;
				}

				
			} else {
				
				_raygun_rt.idle = true;
				_raygun_rt.targetObject = null;
				
			}
			
			if (_biped.body.tools_lt.toolname == "torch") {
				
				_pointer_lt.idle = _biped.defending = false;
				_force_lt.idle = _grapple_lt.idle = true;
				PointBehavior(_pointer_lt).pointCenter = true;
				
				if (_biped.floating) _biped.body.tools_lt.nextEnabledTool();
				
			} else if (_biped.body.tools_lt.toolname == "powerglove") {
				
				_pointer_lt.idle = true;
				
				if (Key.shiftKey) {
					
					if (_force_lt.forceObject == null) {
						
						_force_lt.findObject();
	
					} else {
						
						if (Key.isDown(Keyboard.UP) || Key.charIsDown("w")) _force_lt.force.y = 500;
						if (Key.isDown(Keyboard.DOWN) || Key.charIsDown("s")) _force_lt.force.y = -500;
						if (Key.isDown(Keyboard.LEFT) || Key.charIsDown("a")) _force_lt.force.x = -500;
						if (Key.isDown(Keyboard.RIGHT) || Key.charIsDown("d")) _force_lt.force.x = 500;
						
						_biped.body.tools_lt.count--;
	
					}
					
				} else {
					
					_force_lt.forceObject = null;
					
				}
				
				
				
			} else if (_biped.body.tools_lt.toolname == "grapple") {
				
				_pointer_lt.idle = true;
				
				if (Key.shiftKey && _biped.body.facing != Biped.FACING_BACK) {
					
					if (_grapple_lt.targetObject == null) {
						
						_grapple_lt.findObject();

					} else {
						
						if (Key.isDown(Keyboard.UP) || Key.charIsDown("w")) _grapple_lt.climb();
						if (Key.isDown(Keyboard.DOWN) || Key.charIsDown("s")) _grapple_lt.repel();
						
						_biped.body.tools_lt.count--;

					}
					
				} else {
					
					if (_grapple_lt.targetObject && !_mot.inContact) {
						
						// give a little push when letting go of grapple
						
						var sx:Number = _mot.position.x - _mot.swingPoint.x;
						var sy:Number = _mot.position.y - _mot.swingPoint.y;
						var sv:Vector2d = new Vector2d(null, sx, sy);
						if (sx > 0) sv.rotate(Geom2d.HALFPI);
						else sv.rotate(0 - Geom2d.HALFPI);
						var spdx:Number = (_mot.position.x - _mot.preIntegratePosition.x);
						var spdy:Number = (_mot.position.y - _mot.preIntegratePosition.y);
						var svv:Number = Math.sqrt(spdx * spdx + spdy * spdy) * 0.005;
						
						if (Key.isDown(Keyboard.UP) || Key.charIsDown("w")) {
							_biped.startJump((_mot.position.x > _mot.swingPoint.x) ? JumpBehavior.LEFT : JumpBehavior.RIGHT, 0.5, true);
							_canDoubleJump = false;
						}
						
						_object.modifiers.add(new PushModifier(sv.x * svv, sv.y * svv));
						
					}
					_grapple_lt.targetObject = null;
					
				}
				
			} else if (Key.shiftKey && _biped.body.tools_lt.action == "point") {
				
				_force_lt.idle = _grapple_lt.idle = true;
				_pointer_lt.idle = false;
				_biped.defending = true;
				PointBehavior(_pointer_lt).pointCenter = false;
				
			} else {
				
				_force_lt.idle = _grapple_lt.idle = _pointer_lt.idle = true;
				_biped.defending = false;
				
			}
			
		}	
		
		//
		//
		public function onKeyDown (e:KeyboardEvent):void {
		
			if (Key.charIsDown("r")) {
				_object.dispatchEvent(new Event("radar_show"));
			}
			
			if (_ended || !_active || _biped.locked) return;
			
			if (Key.match(e.charCode, "z")) {	
				_biped.nextToolRight();
			} else if (Key.match(e.charCode, "x")) {
				_biped.nextToolLeft();
			}
			
		}
		
		//
		//
		public function onKeyUp (e:KeyboardEvent):void {
		
			if (_ended || !_active || _biped.locked) return;
			
			if (e.keyCode == Keyboard.UP) {
				_canDoubleJump = true;
			}

			if (_biped.crouching && !Key.isDown(Keyboard.DOWN) && !Key.charIsDown("s")) _biped.crouching = false;
			
			if (Key.match(e.charCode, "r")) {
				_object.dispatchEvent(new Event("radar_hide"));
			}
			
			if (!_biped.jumping && _biped.simObject.inContact && (e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.RIGHT)) {
				_mot.velocity.x *= Math.max(0, Math.min(1, 1 - _mot.contactObjFriction));
			}
			
		}
		
		//
		//
		public function onGestureEnd (e:GestureEvent):void {
			
			//trace("attack end");
				
		}
		
		//
		//
		protected function onCollision (e:CollisionEvent):void {
			
			if (e.collider.objectRef is Biped && e.collider.objectRef != _biped.object) {
				if (e.contactSpeed > 250 && 
					e.contactPoint.y >= _biped.object.y + _biped.object.height * 0.5 - _biped.object.width * 0.25) {
					
					_biped.fall();
				
					ObjectFactory.effect(null, "headbounceeffect", true, 1000, e.contactPoint, 0);

				}
			}
			
			if (TimeStep.realTime - _lastSound > 1500 && e.collidee.objectRef != _biped.object) {
				
				if (e.contactSpeed > 500 && 
					e.contactPoint.y <= _biped.object.y - _biped.object.height * 0.5 + _biped.object.width * 0.25) {
					
					_object.eventSound("hard_landing");
					_lastSound = TimeStep.realTime;

				}
				
			}
			
			if (_mot.isClimbing || Biped(_biped.object).state == Biped.STATE_CLIMBING) {
				_biped.climbing = (_mot.isClimbing);
			}
			
		}

		//
		//
		public function pounce ():void {

			if (_object.deleted) return;
			
			try {
				
				_object.playfield.sightGrid.update();
				
				var neighbors:Array = _object.playfield.sightGrid.getNeighborsOf(_object as PlayObjectControllable, false, true);
				var amount:int;
				var perc:Number = 0;
				var ang:Number;
				var v:Vector2d;
				var strength:Number = 50;
				var radius:Number = 300;

				for each (var playObj:PlayObjectControllable in neighbors) {

					if (!playObj.deleted && _object.playfield.map.canSee(_object, playObj) && Math.abs(playObj.object.ypos - _object.object.ypos) < 60) {
						
						perc = 1 - Math.min(1, (Geom2d.distanceBetweenPoints(_object.object.point, playObj.object.point) - playObj.object.width) / (radius));
						
						_object.harm(playObj, Math.floor(strength * perc));

						if (playObj.simObject != null && playObj.simObject is MotionObject) {
							
							if (!playObj.deleted && playObj.object != null && !playObj.object.deleted) {
								
								ang = Geom2d.angleBetweenPoints(_object.object.point, playObj.object.point);
								v = new Vector2d(null, strength * perc * 100, 0);
								v.rotate(ang);
								
								MotionObject(playObj.simObject).addForce(v);
							
							}
							
						}
						
					}
					
				}
				
			} catch (e:Error) {
				
				//trace("ERROR: BOMB IS A DUD");
				
			}

		}
		
		//
		//
		override public function end():void {
			
			if (_object != null && _object.simObject != null) _object.simObject.removeEventListener(CollisionEvent.COLLISION, onCollision);

			if (_jetpackSound != null) {
				_jetpackSound.stop();
				_jetpackSound = null;
			}
			
			View.mainStage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			View.mainStage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			super.end();
			
		}

	}
	
}