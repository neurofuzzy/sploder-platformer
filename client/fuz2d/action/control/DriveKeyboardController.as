package fuz2d.action.control {
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.media.SoundChannel;
	import flash.ui.Keyboard;
	
	import fuz2d.action.physics.CollisionEvent;
	import fuz2d.action.physics.CompoundObject;
	import fuz2d.action.physics.MotionObject;
	import fuz2d.action.physics.ReactionType;
	import fuz2d.action.physics.Vector2d;
	import fuz2d.action.play.*;
	import fuz2d.Fuz2d;
	import fuz2d.library.ObjectFactory;
	import fuz2d.model.object.Biped;
	import fuz2d.model.object.TurretSymbol;
	import fuz2d.screen.View;
	import fuz2d.TimeStep;
	import fuz2d.util.*;
	

	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class DriveKeyboardController extends PlayObjectController {
		
		protected var _com:CompoundObject;
		protected var _left:Vector2d;
		protected var _right:Vector2d;
		protected var _lastJump:Number = 0;
		protected var _jumpCount:Number = 10;
		
		protected var _player:BipedObject;
		protected var _boarded:Boolean = false;
		public function get boarded():Boolean { return _boarded; }
		
		protected var _hasTurret:Boolean = false;
		protected var _turretObject:TurretSymbol;
		
		protected var _projectile:String = "";
		protected var _fireDelay:Number = 0;
		protected var _lastFire:Number = 0;
		
		protected var _motorLoop:SoundChannel;
		protected var _revved:Boolean = false;
		protected var _lastJuice:int = 0;
		protected var _lastKeyDownTime:int = 0;
		protected var _lastKeyDown:int = 0;
		protected var _lastEffect:int = 0;
		
		//
		//
		public function DriveKeyboardController (object:PlayObjectControllable, projectile:String = "", fireDelay:Number = 0) {
			
			super(object);
			
			_projectile = projectile;
			_fireDelay = fireDelay;
			
		}
		
		override protected function init(object:PlayObjectControllable):void {
			
			super.init(object);
			
			_com = CompoundObject(object.simObject);
			_left = new Vector2d(null, -900, 0);
			_right = new Vector2d(null, 900, 0);
			
			_object.simObject.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);
			
			if (_object.object is TurretSymbol) {
				_hasTurret = true;
				_turretObject = TurretSymbol(_object.object);
			}
			
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
				_player.object.point.x = _object.object.point.x;
				_player.object.point.y = _object.object.point.y;
				_player.object.rotation = _object.object.rotation;
				_player.simObject.getPosition();
				_object.playfield.map.updatePlayObject(_object);
				_player.playfield.map.updatePlayObject(_player);
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
			
			if (_hasTurret) {
				
				if (Key.charIsDown("z")) {
					
					if (_turretObject.turretAngle > -2) _turretObject.turretAngle -= 0.05;
					
				} else if (Key.charIsDown("x")) {
					
					if (_turretObject.turretAngle < 2) _turretObject.turretAngle += 0.05;
					
				}
				
				if (Key.isDown(Keyboard.SPACE)) {
					
					if (TimeStep.realTime - _lastFire > _fireDelay) {
						
						PlayObject.launchNew(_projectile, _object, null, 100, null, false, _turretObject.positionWorld(_turretObject.launchPoint), _turretObject.rotation + _turretObject.turretAngle - Geom2d.HALFPI);
						_lastFire = TimeStep.realTime;
						
					}
					
				}
				
			}
			
			if ((Key.isDown(Keyboard.LEFT) || Key.charIsDown("a")) && _object.object.rotation > -0.6) {
			
				if (_com.hasContact) _com.addForce(_left);
				else if (_com.floating) {
					_com.addForce(_left, 0.25);
					_com.subRotate(-0.1);
				}
				
				if (_player) {
					_player.faceLeft();
					_player.body.state = Biped.STATE_BOARDED;
				}
				
			}
			
			if ((Key.isDown(Keyboard.RIGHT) || Key.charIsDown("d")) && _object.object.rotation < 0.6) {
				
				if (_com.hasContact) _com.addForce(_right);
				else if (_com.floating) {
					_com.addForce(_right, 0.25);
					_com.subRotate(0.1);
				}
				
				if (_player) {
					_player.faceRight();
					_player.body.state = Biped.STATE_BOARDED;
				}
				
			}
			
			if (!_revved && (Key.isDown(Keyboard.LEFT) || 
				Key.charIsDown("a") || 
				Key.isDown(Keyboard.RIGHT) || 
				Key.charIsDown("d"))) {
					
					if (TimeStep.realTime - _lastKeyDownTime > 250) {
						
						_object.eventSound("rev");
						_revved = true;
						
					}
					
				}
			
		}	
		
		//
		//
		public function onKeyDown (e:KeyboardEvent):void {
		
			if (!_boarded) return;
			
			if ((e.keyCode == Keyboard.UP || Key.charIsDown("w")) && TimeStep.realTime - _lastJump > 1000 && _com.hasContact) {
				
				_jumpCount = 0;
				_lastJump = TimeStep.realTime;
				
				applyJump();

			}
			
			if (Key.isDown(Keyboard.DOWN) || Key.charIsDown("s")) {
				
				unBoard();
				
			}
			
			if (e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.LEFT || String.fromCharCode(e.charCode) == "d" ||  String.fromCharCode(e.charCode) == "a") {
				
				if (e.keyCode != _lastKeyDown) {
					_lastKeyDown = e.keyCode;
					_lastKeyDownTime = TimeStep.realTime;
				}
			}
			
		}
		
		//
		//
		public function onKeyUp (e:KeyboardEvent):void {
		
			if (e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.LEFT || String.fromCharCode(e.charCode) == "d" ||  String.fromCharCode(e.charCode) == "a") {
				if (TimeStep.realTime - _lastKeyDownTime < 250 && TimeStep.realTime - _lastJuice > 1000) {
					_object.eventSound("juice");
					_lastJuice == TimeStep.realTime;
				}
				_revved = false;
			}
			
			if (e.keyCode == _lastKeyDown) {
				_lastKeyDown = 0;
			}

		}
		
		//
		//
		protected function applyJump ():void {
			
			

			if (Key.isDown(Keyboard.LEFT) || Key.charIsDown("a")) {
				_com.addForce(new Vector2d(null, -600, 1000));
			} else if (Key.isDown(Keyboard.RIGHT) || Key.charIsDown("d")) {
				_com.addForce(new Vector2d(null, 600, 1000));
			} else {
				_com.addForce(new Vector2d(null, 0, 1500));
			}
			
			_jumpCount++;
			
		}
		
		//
		//
		protected function board ():void {
			
			if (Math.abs(_object.object.rotation) > Geom2d.HALFPI) return;
			
			if (_player && !_player.dying && _player.body && _player.body.state == Biped.STATE_NORMAL) {
				
				_boarded = true;
				_player.controller.active = false;
				_player.simObject.collisionObject.reactionType = ReactionType.IGNORE;
				_player.simObject.simulation.removeObject(_player.simObject);
				_player.body.state = Biped.STATE_BOARDED;
				_player.object.attribs.padding = 80;
				_object.object.z = _player.object.z + 10;
		
				View.mainStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
				View.mainStage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
				
				Fuz2d.mainInstance.view.updateObject(_player.object, false, true);
				
				_object.eventSound("board");
				
				if (_motorLoop != null) {
					_motorLoop.stop();
					_motorLoop = null;
				}
				
				_motorLoop = Fuz2d.sounds.addSoundLoop(_object, "aa_motor");
				
			}			
			
		}
		
		//
		//
		protected function unBoard ():void {
			
			if (_player) {
				
				_boarded = false;
				_player.controller.active = true;
				_player.object.rotation = 0;
				_player.object.attribs.padding = 0;
				_player.body.state = Biped.STATE_NORMAL;
				_player.simObject.collisionObject.reactionType = ReactionType.BOUNCE;
				_player.simObject.position.alignToPoint(_player.object.point);
				_player.simObject.setPrevPosition();
				_player.simObject.simulation.addObject(_player.simObject);
				
				_object.object.z = _player.object.z - 10;
				
				View.mainStage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				View.mainStage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
				
				Fuz2d.mainInstance.view.updateObject(_player.object, false, true);
				
				_object.eventSound("unboard");
				
				if (_motorLoop) {
					_motorLoop.stop();
					_motorLoop = null;
				}
				
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
				
			} else if (e.collider.group == "evil") {
				var pobj:PlayObject = _object.playfield.playObjects[e.collider];	
				
				if (e.contactSpeed > 200) {
					
					if (pobj && pobj is PlayObjectControllable) {
						_object.harm(PlayObjectControllable(pobj), e.contactSpeed / 120);
						
						if (TimeStep.realTime - _lastEffect > 250) {
							ObjectFactory.effect(_object, "puncheffect", true, 1000, e.contactPoint);
							_object.eventSound("hit");
							_lastEffect = TimeStep.realTime;
							if (pobj is BipedObject && !BipedObject(pobj).falling && Math.random() < 0.3) BipedObject(pobj).fall();
						}
					}
				}
				
				if (pobj && pobj.simObject is MotionObject) {
					
					if (Key.isDown(Keyboard.LEFT) || Key.charIsDown("a")) {
						
						MotionObject(pobj.simObject).addForceScaled(_left, 0.5);
						
					}
					
					if (Key.isDown(Keyboard.RIGHT) || Key.charIsDown("d")) {
						
						MotionObject(pobj.simObject).addForceScaled(_right, 0.5);
						
					}
					
				}
				
			}
			
		}
		
		
		//
		//
		override public function end():void {
			
			if (_motorLoop != null) {
				_motorLoop.stop();
				_motorLoop = null;
			}

			if (_object != null && _object.simObject != null) _object.simObject.removeEventListener(CollisionEvent.COLLISION, onCollision);
			
			if (_boarded) unBoard();
			
			_boarded = false;
			_player = null;
			super.end();
			
		}

	}
	
}