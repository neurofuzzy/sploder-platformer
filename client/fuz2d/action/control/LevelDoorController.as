package fuz2d.action.control {
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import fuz2d.action.physics.CollisionEvent;
	import fuz2d.action.physics.ReactionType;
	import fuz2d.action.play.*;
	import fuz2d.Fuz2d;
	import fuz2d.library.ObjectFactory;
	import fuz2d.model.object.Biped;
	import fuz2d.model.object.Object2d;
	import fuz2d.model.object.Symbol;
	import fuz2d.screen.morph.Bloom;
	import fuz2d.screen.shape.ViewSprite;
	import fuz2d.screen.View;
	import fuz2d.TimeStep;
	import fuz2d.util.*;
	
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class LevelDoorController extends PlayObjectController {
		
		protected var _player:BipedObject;
		protected var _entered:Boolean = false;
		protected var _locked:Boolean = true;
		
		protected var _lastKeyDownTime:int = 0;
		protected var _lastKeyDown:int = 0;
		protected var _lastEffect:int = 0;
		
		public static var doors:Array = [];
		
		protected var _enterTimer:Timer;
		protected var _unlockTimer:Timer;
		protected var _focusObj:Object2d;
		protected var _fade:Bloom;
		//
		//
		public function LevelDoorController (object:PlayObjectControllable) {
			
			super(object);
			
		}
		
		override protected function init(object:PlayObjectControllable):void {
			
			super.init(object);
			
			doors.push(this);
			
			_object.simObject.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);
			
			Key.initialize(View.mainStage);
			
		}
		
		//
		//
		override public function update (e:Event):void {
			
			if (_ended || !_active || _object.locked) return;
			
			super.update(e);
			
		}
		
		public function unlock ():void {
			
			if (_locked) {
				
				_locked = false;
				
				if (_object.object is Symbol) {
					Symbol(_object.object).state = "f_open";
					_object.eventSound("open");
					
					startCutScene();
					
				}
			
			}
			
		}
		
		protected function startCutScene ():void {
			
			_object.playfield.locked = true;
			GameLevel.gameEngine.view.camera.startWatching(_object.object, 3);
			_unlockTimer = new Timer(2000, 1);
			_unlockTimer.addEventListener(TimerEvent.TIMER_COMPLETE, stopCutScene);
			_unlockTimer.start();
			
		}
		
		protected function stopCutScene (e:TimerEvent):void {
			
			_object.playfield.locked = false;
			GameLevel.gameEngine.view.camera.startWatching(GameLevel.player.object, 5);
			_unlockTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, stopCutScene);
			_unlockTimer = null;
			
			
		}
		
		//
		//
		protected function enter ():void {
			
			if (!_entered && _player && !_player.dying && _player.body && _player.body.state == Biped.STATE_NORMAL) {
				
				_entered = true;
				_player.controller.active = false;
				_player.simObject.collisionObject.reactionType = ReactionType.IGNORE;
				_player.simObject.simulation.removeObject(_player.simObject);
				_player.body.facing = Biped.FACING_BACK;
		
				var sym:Symbol = ObjectFactory.effect(this, "blingeffect", true, -10);
				sym.point = _player.object.point;
				
				Fuz2d.mainInstance.view.updateObject(_player.object, false, true);
				
				_object.eventSound("enter");
				
				_enterTimer = new Timer(33, 30);
				_enterTimer.addEventListener(TimerEvent.TIMER, onEntering);
				_enterTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onEnterComplete);
				_enterTimer.start();
				
			}			
			
		}
		
		protected function onEntering (e:TimerEvent):void {
			
			if (_player && 
				_player.object && 
				_player.object.viewObject &&
				_player.object.viewObject.dobj &&
				_object &&
				_object.object) {
				
				var xDiff:Number = _object.object.x - _player.object.x;
				var yDiff:Number = _object.object.y - _player.object.y;
				
				_player.object.xpos += xDiff * 0.2;
				_player.object.ypos += yDiff * 0.2;
				
				if (_fade == null) {
					
					_fade = new Bloom(_player.object.viewObject as ViewSprite);
					_fade.colorChange = -20;
					_fade.scaleChange = -0.05;
					_fade.rotationChange = 0;	
					_fade.destroyParent = false;
					
				}
				
				//_player.object.viewObject.dobj.alpha -= 0.1;
				//_player.object.viewObject.dobj.scaleX -= 0.05;
				//_player.object.viewObject.dobj.scaleY -= 0.05;
				
			}
			
		}
		
		protected function onEnterComplete (e:TimerEvent):void {
			
			_enterTimer.removeEventListener(TimerEvent.TIMER, onEntering);
			_enterTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onEnterComplete);
			_enterTimer = null;
			if (_object) _object.eventSound("leave");
			_fade = null;
			
			Game.gameInstance.currentLevel.exitIfComplete();
			
			
		}
		
		//
		//
		protected function onCollision (e:CollisionEvent):void {
			
			if (!_entered) {
				
				if (e.collider.type == "player") {
					
					if (!_locked) {
						
						if (!Key.isDown(Keyboard.SHIFT) && (Key.isDown(Keyboard.UP) || Key.charIsDown("w"))) {
							
							_player = _object.playfield.playObjects[e.collider];
							if (_player) enter();
							
						}
						
					} else {
						
						if (TimeStep.realTime - _lastEffect > 2000) {
							_object.eventSound("locked");
							_lastEffect = TimeStep.realTime;
							Symbol(_object.object).state = "f_locked";
						}
						
					}
					
				}
				
			}
			
		}
		
		
		//
		//
		override public function end():void {
			
			if (_enterTimer && _enterTimer.running) {
				_enterTimer.removeEventListener(TimerEvent.TIMER, onEntering);
				_enterTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onEnterComplete);
				_enterTimer.stop();
			}
			if (_unlockTimer && _unlockTimer.running) {
				_unlockTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, stopCutScene);
				_unlockTimer.stop();
			}

			if (_object != null && _object.simObject != null) _object.simObject.removeEventListener(CollisionEvent.COLLISION, onCollision);
			
			doors = [];
			
			_enterTimer = null;
			_unlockTimer = null;
			_entered = false;
			_player = null;
			
			super.end();
			
		}

	}
	
}