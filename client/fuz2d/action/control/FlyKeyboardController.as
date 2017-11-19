package fuz2d.action.control {
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.media.SoundChannel;
	import flash.ui.Keyboard;
	
	import fuz2d.action.physics.CollisionEvent;
	import fuz2d.action.physics.MotionObject;
	import fuz2d.action.physics.ReactionType;
	import fuz2d.action.physics.Vector2d;
	import fuz2d.action.play.*;
	import fuz2d.Fuz2d;
	import fuz2d.model.object.Biped;
	import fuz2d.model.object.Symbol;
	import fuz2d.screen.View;
	import fuz2d.TimeStep;
	import fuz2d.util.*;
	
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class FlyKeyboardController extends PlayObjectController {
		
		protected var _mot:MotionObject;
		protected var _left:Vector2d;
		protected var _right:Vector2d;
		protected var _up:Vector2d;
		protected var _down:Vector2d;
		protected var _hover:Vector2d;
		
		protected var _player:BipedObject;
		protected var _boarded:Boolean = false;
		public function get boarded():Boolean { return _boarded; }
		
		protected var _hasTurret:Boolean = false;
		protected var _ship:Symbol;
		
		protected var _projectile:String = "";
		protected var _fireDelay:Number = 0;
		protected var _lastFire:Number = 0;
		protected var _facing:int = 0;
		
		protected var _motorLoop:SoundChannel;
		
		//
		//
		public function FlyKeyboardController (object:PlayObjectControllable, projectile:String = "", fireDelay:Number = 0) {
			
			super(object);
			
			_projectile = projectile;
			_fireDelay = fireDelay;
			
			_object.object.attribs.showHealth = true;
			
		}
		
		override protected function init(object:PlayObjectControllable):void {
			
			super.init(object);
			
			_mot = MotionObject(object.simObject);
			_left = new Vector2d(null, -1000, 0);
			_right = new Vector2d(null, 1000, 0);
			_up = new Vector2d(null, 0, 1000);
			_down = new Vector2d(null, 0, -1000);
			_hover = new Vector2d(null, 0, 0);
			
			_object.simObject.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);
			
			_ship = Symbol(_object.object);
			_mot.bankAmount = 0.5;
			
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
				_hover.y =  Math.sin(TimeStep.realTime / 250) * 200;
				_mot.addForce(_hover);
				
				if (_player.deleted || _player.dying || _player.health == 0) {
					unBoard();
				}
				_player.object.point.x = _object.object.point.x;
				_player.object.point.y = _object.object.point.y + 10;
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
		
			if ((Key.isDown(Keyboard.LEFT) || Key.charIsDown("a"))) {
				
				_mot.addForce(_left);
				
				if (_player) {
					_player.faceLeft();
					_player.body.state = Biped.STATE_BOARDED;
					_facing = _player.body.facing;
				}
				
			}
			
			if ((Key.isDown(Keyboard.RIGHT) || Key.charIsDown("d"))) {
					
				_mot.addForce(_right);
				
				if (_player) {
					_player.faceRight();
					_player.body.state = Biped.STATE_BOARDED;
					_facing = _player.body.facing;
				}
				
			}
			
			if ((Key.isDown(Keyboard.UP) || Key.charIsDown("w"))) {
				
				_mot.addForce(_up);
				
				if (_player) _player.body.state = Biped.STATE_BOARDED;
				
			}
			
			if ((Key.isDown(Keyboard.DOWN) || Key.charIsDown("s"))) {
					
				_mot.addForce(_down);
				
				if (_player) _player.body.state = Biped.STATE_BOARDED;
				
			}
			
			if (Key.isDown(Keyboard.SPACE)) {
				
				if (TimeStep.realTime - _lastFire > _fireDelay && _object != null && _object.object != null) {
					
					var dir:Number = (_player.body.facing == Biped.FACING_LEFT) ? Math.PI : 0;
					var launchPoint:Point = _object.object.point.clone();
					launchPoint.x += (_player.body.facing == Biped.FACING_LEFT) ? 0 - _object.object.width * 1.6 : _object.object.width * 1.6;
					launchPoint.y -= 15;
					
					PlayObject.launchNew(_projectile, _object, null, 100, null, false, launchPoint, dir);
					_lastFire = TimeStep.realTime;
					
				}
				
			}
			
		}	
		
		//
		//
		public function onKeyDown (e:KeyboardEvent):void {
		
			if (!_boarded) return;
			
			if (Key.isDown(Keyboard.DOWN) || Key.charIsDown("s")) {
				
				if (_mot.onGround) unBoard();
				
			}
			
		}
		
		//
		//
		public function onKeyUp (e:KeyboardEvent):void {
		

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
				_player.object.attribs.padding = 160;
				_object.object.z = _player.object.z + 10;
				_facing = _player.body.facing;
				
				_mot.gravity = 0;
				_ship.state = "fly";
				
				View.mainStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
				View.mainStage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
				
				Fuz2d.mainInstance.view.updateObject(_player.object, false, true);
				
				_object.eventSound("board");
				
				if (_motorLoop != null) {
					_motorLoop.stop();
					_motorLoop = null;
				}
				
				_motorLoop = Fuz2d.sounds.addSoundLoop(_object, "aa_saucer");
				
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
				//_mech.boarded = false;
				//_mech.state = Mech.STATE_IDLE;
				
				_mot.gravity = 1;
				_ship.state = "idle";
				
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