package fuz2d.action.control {
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	import fuz2d.action.physics.CollisionEvent;
	import fuz2d.action.physics.MotionObject;
	import fuz2d.action.physics.ReactionType;
	import fuz2d.action.physics.SimulationObject;
	import fuz2d.action.physics.Vector2d;
	import fuz2d.action.play.*;
	import fuz2d.Fuz2d;
	import fuz2d.library.ObjectFactory;
	import fuz2d.model.object.Biped;
	import fuz2d.model.object.Mech;
	import fuz2d.screen.View;
	import fuz2d.TimeStep;
	import fuz2d.util.*;
	
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class MechKeyboardController extends PlayObjectController {
		
		protected var _mot:MotionObject;
		protected var _left:Vector2d;
		protected var _right:Vector2d;
		protected var _lastJump:Number = 0;
		protected var _jumpCount:Number = 10;
		
		protected var _player:BipedObject;
		protected var _boarded:Boolean = false;
		public function get boarded():Boolean { return _boarded; }
		
		protected var _hasTurret:Boolean = false;
		protected var _mech:Mech;
		
		protected var _projectile:String = "";
		protected var _fireDelay:Number = 0;
		protected var _lastFire:Number = 0;
		
		//
		//
		public function MechKeyboardController (object:PlayObjectControllable, projectile:String = "", fireDelay:Number = 0) {
			
			super(object);
			
			_projectile = projectile;
			_fireDelay = fireDelay;
			
		}
		
		override protected function init(object:PlayObjectControllable):void {
			
			super.init(object);
			
			_mot = MotionObject(object.simObject);
			_left = new Vector2d(null, -3600, 0);
			_right = new Vector2d(null, 3600, 0);
			
			_object.simObject.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);
			
			_mech = Mech(_object.object);
			
			Key.initialize(View.mainStage);
			
		}
		
		//
		//
		override public function update (e:Event):void {
			
			if (_ended || !_active || _object.locked) return;
			
			super.update(e);
			
			checkKeys();
			checkMouse();
			
			if (_boarded && _player) {
				if (_player.deleted || _player.dying || _player.health == 0) {
					unBoard();
				}
				if (_jumpCount < 10) applyJump();
				else {
					_mot.gravity = 1;
				}
				
				_player.object.rotation = _object.object.rotation;
				_object.playfield.map.updatePlayObject(_object);
				_player.playfield.map.updatePlayObject(_player);
				if (_mot.inContact) _mot.velocity.clamp(200);
				
				updateStance();
				
				if (_mech.attribs.punchPoint) {
					
					var pt:Point = _mech.attribs.punchPoint;
					
					punch(pt);
					
					_mech.attribs.punchPoint = null;
					
				}
				
				if (_object && _object.object) {
					
					if (_object.object.attribs.stepped) {
						_object.eventSound("step");
						_object.object.attribs.stepped = false;
					}
					
					if (_object.object.attribs.switchedfeet) {
						_object.eventSound("walk");
						_object.object.attribs.switchedfeet = false;
					}
					
				}
				
			}

		}
		
		protected function updateStance ():void {
			
			if (_mech.facing == Mech.FACING_LEFT) {
				_player.object.point.x = _object.object.point.x - 20;
			} else {
				_player.object.point.x = _object.object.point.x + 20;
			}
							
			_player.object.point.y = _object.object.point.y + 30;
			_player.simObject.getPosition();
			
			_mech.updateStance();			
			
		}
		
		protected function punch (pt:Point):void {
			
			var obj:SimulationObject = _object.simObject.simulation.getObjectAtPoint(pt, _object.simObject, -1, ReactionType.BOUNCE, 60);
					
			if (obj) {
				
				var pobj:PlayObject = _object.playfield.playObjects[obj];
				
				if (pobj is PlayObjectControllable) {

					if (obj is MotionObject) {
					
						var pv:Vector2d = new Vector2d();
						pv.x = (_mech.facing == Mech.FACING_LEFT) ? -10000 : 10000;
						if (MotionObject(obj).inverseMass > 0) pv.x /= MotionObject(obj).inverseMass;
						
						MotionObject(obj).addForce(pv);
						
					}
					
					_object.harm(PlayObjectControllable(pobj), 25, pt);
					ObjectFactory.effect(null, "puncheffect", true, 1000, pt);
					_object.eventSound("punch");
					
				} else {
					
					if (pobj.simObject && pobj.simObject.collisionObject.reactionType == ReactionType.BOUNCE) {
						_object.eventSound("punch");
					} else {
						_object.eventSound("miss");
					}
					
				}
				
			} else {
				
				_object.eventSound("miss");
				
			}			
			
		}

		//
		//
		private function checkMouse ():void {
			
			
		}
		
		//
		//
		private function checkKeys ():void {
			
			if (!_boarded) return;
			
			if (Key.isDown(Keyboard.SPACE)) {
				
				_mech.state = Mech.STATE_PUNCHING;
			
			} else {
				
				_mech.state = Mech.STATE_IDLE;
				
				if ((Key.isDown(Keyboard.LEFT) || Key.charIsDown("a")) && _object.object.rotation > -0.6) {
			
					_mech.facing = Mech.FACING_LEFT;
					
					if (_mot.inContact) _mot.addForce(_left);
					
					if (_player) {
						_player.faceLeft();
						_player.body.state = Biped.STATE_BOARDED;
					}
					
				}
				
				if ((Key.isDown(Keyboard.RIGHT) || Key.charIsDown("d")) && _object.object.rotation < 0.6) {
					
					_mech.facing = Mech.FACING_RIGHT;
					
					if (_mot.inContact) _mot.addForce(_right);
					
					if (_player) {
						_player.faceRight();
						_player.body.state = Biped.STATE_BOARDED;
					}
					
				}
			
			}
			
		}	
		
		//
		//
		public function onKeyDown (e:KeyboardEvent):void {
		
			if (!_boarded) return;
			
			if ((e.keyCode == Keyboard.UP || Key.charIsDown("w")) && TimeStep.realTime - _lastJump > 1000 && _mot.inContact) {
				
				_jumpCount = 0;
				_lastJump = TimeStep.realTime;
				_object.eventSound("jump");
				
				applyJump();

			}
			
			if (Key.isDown(Keyboard.DOWN) || Key.charIsDown("s")) {
				
				unBoard();
				
			}
			
		}
		
		//
		//
		public function onKeyUp (e:KeyboardEvent):void {
		

		}
		
		//
		//
		protected function applyJump ():void {
			
			if (_mech.facing == Mech.FACING_LEFT) {
				_mot.addForce(new Vector2d(null, -1500, 4500));
			} else {
				_mot.addForce(new Vector2d(null, 1500, 4500));
			}
			_mot.gravity = 0.5;
			
			_jumpCount++;	
			
		}
		
		//
		//
		protected function board ():void {
			
			if (_player && !_player.dying && _player.body && _player.body.state == Biped.STATE_NORMAL) {
				
				_boarded = true;
				_player.controller.active = false;
				_player.simObject.collisionObject.reactionType = ReactionType.IGNORE;
				_player.simObject.simulation.removeObject(_player.simObject);
				_player.body.state = Biped.STATE_BOARDED;
				_player.body.facing = _mech.facing;
				_player.object.attribs.padding = 160;
				_object.object.z = _player.object.z + 10;
				_mech.boarded = true;
				
				updateStance();
		
				View.mainStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
				View.mainStage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
				
				Fuz2d.mainInstance.view.updateObject(_player.object, false, true);
				
				_object.eventSound("board");
				
			}			
			
		}
		
		//
		//
		protected function unBoard ():void {
			
			if (_player) {
				
				_boarded = false;
				_player.controller.active = true;
				_player.object.rotation = 0;
				_player.body.state = Biped.STATE_NORMAL;
				_player.simObject.collisionObject.reactionType = ReactionType.BOUNCE;
				_player.simObject.position.alignToPoint(_player.object.point);
				_player.simObject.setPrevPosition();
				_player.simObject.simulation.addObject(_player.simObject);
				_player.object.attribs.padding = 0;
				_object.object.z = _player.object.z - 10;
				_mech.boarded = false;
				_mech.state = Mech.STATE_IDLE;
				
				View.mainStage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				View.mainStage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
				
				Fuz2d.mainInstance.view.updateObject(_player.object, false, true);
				
			}	
			
			
		}
		
		//
		//
		protected function onCollision (e:CollisionEvent):void {
			
			if (!_boarded) {
				
				if (e.collider.type == "player") {
					
					if (!Key.isDown(Keyboard.SHIFT) && (Key.isDown(Keyboard.UP) || Key.charIsDown("w"))) {
						
						_player = _object.playfield.playObjects[e.collider];
						if (_player) board();
						
					}
					
				}
				
			}
			
		}
		
		
		//
		//
		override public function end():void {
			
			if (_object != null && _object.simObject != null) _object.simObject.removeEventListener(CollisionEvent.COLLISION, onCollision);
			
			if (_boarded) unBoard();
			
			_boarded = false;
			_mech = null;
			_player = null;
			
			super.end();
			
		}

	}
	
}