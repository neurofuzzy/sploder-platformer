/**
* ...
* @author Default
* @version 0.1
*/

package fuz2d.action.play {
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import fuz2d.action.animation.GestureEvent;
	import fuz2d.action.behavior.GestureBehavior;
	import fuz2d.action.behavior.JumpBehavior;
	import fuz2d.action.behavior.ThrowBehavior;
	import fuz2d.action.control.*;
	import fuz2d.action.modifier.AtomicModifier;
	import fuz2d.action.modifier.LockModifier;
	import fuz2d.action.modifier.PushModifier;
	import fuz2d.action.modifier.RollModifier;
	import fuz2d.action.physics.*;
	import fuz2d.action.play.*;
	import fuz2d.Fuz2d;
	import fuz2d.library.GestureFactory;
	import fuz2d.library.ObjectDefinition;
	import fuz2d.library.ObjectFactory;
	import fuz2d.model.*;
	import fuz2d.model.object.*;
	import fuz2d.TimeStep;
	import fuz2d.util.Geom2d;

	
	

	public class BipedObject extends PlayObjectMovable {

		public static const EVENT_STAMINA:String = "stamina";
		
		protected static var symbolName:String;
		public static var skeletonXML:XML;
		
		public var scale:Number = 1;
		public static var jumpScale:Number = 1;
		
		protected var dimX:Number;
		protected var dimY:Number;
		
		public function get body ():Biped { return Biped(_modelObjectRef); }
		
		override public function set health(value:Number):void {
			var oldhealth:Number = _health;
			super.health = value;
			if (_health > 0 && _health < oldhealth && TimeStep.realTime - _lastHarm > 1000) {
				if (!_defending) eventSound("harm");
				else eventSound("defend");
				_lastHarm = TimeStep.realTime;
			}
		}
		
		protected var _stamina:Number = 100;
		public function get stamina():Number { return _stamina; }
		public function set stamina(value:Number):void 
		{
			_stamina = Math.max(0, Math.min(100, value));
			dispatchEvent(new Event(EVENT_STAMINA));
		}
		
		
		public var lastJump:JumpBehavior;
		
		public function get direction ():String {
			
			if (body) {
				
				switch (body.facing) {
					
					case Biped.FACING_CENTER: return "center";
					case Biped.FACING_LEFT: return "left";
					case Biped.FACING_RIGHT: return "right";
					
				}
			
			}
			
			return "center";
			
		}
		
		public function get standing ():Boolean { return (_simObjectRef.propped || (_simObjectRef.propped && _playfield.map.isStanding(this))); }
		public function get floating ():Boolean { return MotionObject(_simObjectRef).floating; }
		public function get climbing ():Boolean { return MotionObject(_simObjectRef).isClimbing; }
		public function set climbing (value:Boolean):void {
			if (value) {
				body.state = Biped.STATE_CLIMBING;
			} else {
				if (body.state == Biped.STATE_CLIMBING) body.state = Biped.STATE_NORMAL;
			}
		}
		
		protected var _jumping:Boolean = false;
		public function get jumping():Boolean { return _jumping; }
		public function set jumping(value:Boolean):void { 
			_jumping = value; 
			if (_jumping) {
				_landed = false;
				eventSound("jump"); 
			}
		}
		
		protected var _landed:Boolean = false;
		public function get landed():Boolean { return _landed; }
		public function set landed(value:Boolean):void 
		{
			_landed = value;
		}

		protected var _flipping:Boolean = false;
		public function get flipping():Boolean { return (_jumping && _flipping); }
		public function set flipping(value:Boolean):void { _flipping = (_jumping) ? value : false; }
		
		protected var _crouching:Boolean = false;
		public function get crouching():Boolean { return _crouching; }
		public function set crouching(value:Boolean):void { setCrouch(value); }
		
		protected var _falling:Boolean = false;
		public function get falling():Boolean { return _falling; }
		
		protected var _kneeling:Boolean = false;
		public function get kneeling():Boolean { return _kneeling; }
		
		protected var _rolling:Boolean = false;
		public function get rolling():Boolean { return _rolling; }
		public function set rolling(value:Boolean):void { _rolling = value; }
		
		protected var _gravityKicking:Boolean = false;
		public function get gravityKicking():Boolean { return _gravityKicking; }
		public function set gravityKicking(value:Boolean):void 
		{
			_gravityKicking = value;
		}
		
		protected var _attacking:Boolean = false;
		public function get attacking():Boolean { return _attacking; }
		public function set attacking(value:Boolean):void { _attacking = value; }
		
		protected var _defending:Boolean = false;
		public function get defending():Boolean { return _defending; }
		public function set defending(value:Boolean):void { _defending = value; }
		
		public function get attackType():String { return _attackType; }
		
		protected var _attackAction:String = "";
		protected var _attackType:String = "";
		protected var _attackStrong:Boolean = false;
		protected var _attackTool:Toolset;
		protected var _hitSuccess:Boolean = false;
		protected var _lastHitSound:Number = 0;
		
		protected var _lastHarm:int = 0;
		protected var _lastBoomerang:int = 0;
		protected var _regPt:Point;

		//
		//
		public function BipedObject (type:String, creator:Object, main:Fuz2d, def:ObjectDefinition, health:int = 100, strengthFactor:Number = 1, speedFactor:Number = 1, jumpPower:int = 1000) {
			
			super(type, creator, main, def, health, strengthFactor, speedFactor);
		
			_jumpPower = jumpPower * jumpScale;
			
			_regPt = new Point();
			
			invincible = false;
			
		}
		
		//
		//
		override protected function create():void {
			
			super.create();

			dimX = _simObjectRef.collisionObject.dimX;
			dimY = _simObjectRef.collisionObject.dimY;
			
			if (type == "player") {
				_playfield.addEventListener(PlayfieldEvent.POWERUP, onPowerUp, false, 0, true);
				_simObjectRef.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);
			}

		}
		
		override protected function initializeReferencePoints():void {
			
			super.initializeReferencePoints();

			_sightPoint = new Point2d(_modelObjectRef, 0, (_modelObjectRef.height * 0.5) - (_modelObjectRef.width * 0.25));

		}
		
		//
		//
		public function faceCenter ():void { body.facing = Biped.FACING_CENTER; if (_crouching) body.head.x = 0;  }
		public function faceLeft ():void { body.facing = Biped.FACING_LEFT; if (_crouching) body.head.x = -10; }
		public function faceRight ():void { body.facing = Biped.FACING_RIGHT; if (_crouching) body.head.x = 10; }
		
		//
		//
		public static function defendSuccess (attacker:PlayObjectControllable, defender:BipedObject):Boolean {
			
			if (!defender.defending || (attacker is BipedObject && BipedObject(attacker).attackType == "low" && !defender.crouching)) return false;
			
			return (defender.body.facing == Biped.FACING_LEFT && defender.object.x > attacker.object.x) || 
			
						(defender.body.facing == Biped.FACING_RIGHT && defender.object.x < attacker.object.x);
		}
		
		//
		//
		protected function setCrouch (crouch:Boolean):void {
			
			if (_crouching != crouch) {
				
				if (!_crouching) {
				
					_simObjectRef.collisionObject.dimY -= (dimY - dimX) * 0.5;
					
					body.head.y *= 0.5;
					
					switch (body.facing) {
						
						case Biped.FACING_CENTER:
						default:
						
							body.head.x = 0;
							break;
						
						case Biped.FACING_LEFT:
						
							body.head.x = -10;
							break;
						
						case Biped.FACING_RIGHT:
						
							body.head.x = 10;
							break;
						
					}
					
					body.arm_lt.y *= 0.5;
					body.arm_rt.y *= 0.5;
					body.leg_lt.y *= 0.5;
					body.leg_rt.y *= 0.5;
					
				} else {
						
					_simObjectRef.position.y -= dimY / 2 - _simObjectRef.collisionObject.dimY;
					_simObjectRef.collisionObject.dimY = dimY;
					_simObjectRef.updateObjectRef();
					
					body.head.reset();
					body.arm_lt.reset();
					body.arm_rt.reset();
					body.leg_lt.reset();
					body.leg_rt.reset();
	
				}
				
				_crouching = crouch;
				
			}
				
		}
		
		//
		//
		public function onPowerUp (e:PlayfieldEvent):void {
			
			var pc:PowerUpController = PowerUpController(PlayObjectControllable(e.playObject).controller);
			
			if (deleted || object == null || object.deleted) return;
			
			var attrib:String = pc.powerAttribName;
			
			if (pc.isModifier) {
				
				switch (attrib) {
					
					case "atomic":
						_modifiers.add(new AtomicModifier());
						break;
					
				}
				
			}
			
			var toolset:Toolset;
			
			if (attrib == "health") {
				
				health += pc.power;
				return;
				
			} else if (attrib == "extralife") {
				
				if (GameLevel.lives < 4) GameLevel.lives++;
				return;
				
			} else if (attrib == "checkpoint") {
				
				GameLevel.playerHome.x = e.playObject.object.x;
				GameLevel.playerHome.y = e.playObject.object.y + 20;
				return;
				
			} else if (attrib == "armor") {
				
				body.armor.level = Math.max(body.armor.level, pc.power);
				
			} else if (attrib == "roll" || attrib == "smash" || attrib == "stomp" || attrib == "doublejump") {
				
				body.attribs[attrib] = true;
				var sym:Symbol = ObjectFactory.effect(this, "blingeffect", true, -10);
				sym.point = _modelObjectRef.point;

			} else if (body.tools_rt.indexOf(attrib) != -1) {
				
				toolset = body.tools_rt;
				
			} else if (body.tools_lt.indexOf(attrib) != -1) {
				
				toolset = body.tools_lt;
				
			} else if (body.tools_back.indexOf(attrib) != -1) {
				
				toolset = body.tools_back;	
				
			} else {
				
				if (body.attribs[attrib] != null && !isNaN(body.attribs[attrib])) {
					
					body.attribs[attrib] += pc.power;
					
				} else {
					
					body.attribs[attrib] = pc.power;
					
				}
				
				return;
				
			}
			
			if (toolset == null) return;
			
			if (pc.addToBelt) {
				var switchTo:Boolean = (toolset.toolBelt[attrib] != true || (toolset.toolBelt[attrib] == true && toolset.getToolStatus(attrib) == false));
				toolset.addToBelt(attrib, switchTo);
				Fuz2d.sounds.addSound(this, "new_weapon2");
			}
			if (pc.power > 0) toolset.addToCount(attrib, pc.power);

		}
		
		//
		//
		public function fireWeapon ():Boolean {

			if (_attackTool == null) return false;
			
			var pobj:PlayObject;
			
			var isTriple:Boolean = false;
			
			if (_playfield.map.pointInOccupiedCell(_attackTool.tooltip)) {
				return false;
			}

			switch (_attackTool.spawnType) {
				
				case "ray":
				
					//var obj:Object = PlayObject.hitTestSegment(this, body.tools_rt, 300);
					
					//var v:Vector2d = new Vector2d(null, -10, 0);
					//v.rotate(0 - body.tools_rt.toolRotation);
					//MotionObject(simObject).applyImpulse(v);
					
					//var sX:Number = 3;
					//if (obj != null && obj.pt != null) sX = Geom2d.distanceBetweenPoints(obj.pt, body.tools_rt.tooltip) / 100;

					//ObjectFactory.createNew(body.tools_rt.spawn, this, body.tools_rt.tooltip.x, body.tools_rt.tooltip.y, 10, { scaleX: sX, rotation: body.tools_rt.toolRotation, result: obj } );
					break;
				
				case "triple":
				
					isTriple = true;
					
				case "launch":

					if (_attackTool.spawn == "bullet") ObjectFactory.effect(this, "gunblasteffect", true, 1000, _attackTool.tooltip);
					PlayObject.launchNew(_attackTool.spawn, this, _attackTool, 0, null, isTriple);	
					break;	
					
				case "spray":
				
					if (_attackTool.canSpawn) {
						pobj = PlayObject(PlayObject.launchNew(_attackTool.spawn, this, _attackTool, 0));
						if (pobj is PlayObjectControllable) {
							SprayController(PlayObjectControllable(pobj).controller).toolset = _attackTool;
						}
						_attackTool.setSpawnTime();
						if (body.tools_rt.countable) body.tools_rt.count--;
					}
					break;				
						
				}
				
			return true;
			
		}
		
		//
		//
		public function attack (type:String = "", tool:String = "rt", overrideAction:String = ""):void {
		
			var toolset:Toolset;
			
			toolset = body["tools_" + tool];
			
			if (type.length == 0) type = "middle";
			
			//if (toolset.action == "bash") type = "high";
			
			if (!_attacking && (tool == "back" || (!toolset.countable || toolset.count > 0))) {
				
				var computedAction:String = (overrideAction.length) ? overrideAction : toolset.action;
					
				var b:GestureBehavior = GestureFactory.createNew(this, "attack_" + type, direction, computedAction);
				
				if (b != null) {
					
					b.gesture.addEventListener(GestureEvent.GESTURE_START, onAttackStart);
					b.gesture.addEventListener(GestureEvent.GESTURE_KEYFRAME, onAttack);
					b.gesture.addEventListener(GestureEvent.GESTURE_MID, onAttackMid);
					b.gesture.addEventListener(GestureEvent.GESTURE_HOLD, onAttackHold);
					b.gesture.addEventListener(GestureEvent.GESTURE_END, onAttackComplete);
					
					_attacking = true;
					_attackAction = computedAction;
					_attackType = type;
					_attackTool = toolset;
					_hitSuccess = false;
					
					_attackStrong = ((_attackAction == "strike" || _attackAction == "bash") && flipping);
					
					if (!_attackStrong) {
						eventSound(_attackAction + "_" + _attackType);
					} else {
						eventSound("attackStrong");
					}
					
				}	
				
			}	
			
		}
		
		//
		//
		public function onAttackStart (e:GestureEvent):void {
			
			var success:Boolean = true;
			if (_attackAction == "kick") eventSound("kick");
			if (_attackTool.spawns && _attackTool.spawnAt == "start") success = fireWeapon();
			if (_attackTool.action == "throw") success = false;
			if (_attackTool.spawnType != "spray" && body.tools_rt.countable && success) body.tools_rt.count--;

		}
		
		//
		//
		public function onAttack (e:GestureEvent):void {
			
			try {
				
				
				switch (_attackAction) {
					
					case "strike":
					case "bash":
						if (flipping) _attackStrong = true;
						_modelObjectRef.attribs.swing = true;
						
					case "punch":
						if (e.gesture.poseIndex == 0) Fuz2d.sounds.addSound(this, "whoosh1,whoosh2,whoosh3");
						break;
						
					case "scratch":
						if (e.gesture.poseIndex == 0) Fuz2d.sounds.addSound(this, "whoosh1,whoosh2,whoosh3");
						if (e.gesture.poseIndex == 0) checkHit("start", 80);
						break;
						
					case "throw":
					
						if (e.gesture.poseIndex == 0) {
							behaviors.add(new ThrowBehavior(1, _attackTool.spawn));
							if (_attackTool.countable) _attackTool.count--;
						}
						
						// continue on to throwleft, both add sound
						
					case "throwleft":
					
						if (e.gesture.poseIndex == 0) Fuz2d.sounds.addSound(this, "whoosh4");
						break;
						
					case "whip":
					
						_modelObjectRef.attribs.whipping = true;
						eventSound("whip");
						break;
						
					default:
						break;
							
					
				}
			
			} catch (e:Error) {
				trace("BipedObject onAttack:", e);
			}

		}
		
		//
		//
		public function onAttackMid (e:GestureEvent):void {
			
			switch (_attackAction) {
				
				case "strike":
				
					if (flipping) _attackStrong = true;
					if (e.poseIndex > 0 && e.poseIndex != e.gesture.totalPoses - 1) checkHit("mid", 25);				
					break;
					
				case "bash":
					if (flipping) _attackStrong = true;
					
				case "scratch":
					if (e.poseIndex > 0 && e.poseIndex != e.gesture.totalPoses - 1) checkHit("mid", 80);				
					break;
				
				case "punch":
				
					if (e.poseIndex > 0 && e.poseIndex != e.gesture.totalPoses - 1) checkHit("mid", 100);				
					break;
					
				default:
					break;
					
			}
			
			if (_attackTool.spawns && _attackTool.spawnAt == "mid") fireWeapon();
			
		}
		
		//
		//
		public function onAttackHold (e:GestureEvent):void {
			
			switch (_attackAction) {
				
				case "strike":
				
					if (flipping) _attackStrong = true;
					if (e.poseIndex > 1) checkHit("hold", 25);
					break;
					
				case "bash":
				
					if (flipping) _attackStrong = true;
					if (e.poseIndex > 1) checkHit("hold", 50);
					break;
				
				case "punch":
				
					if (e.poseIndex > 1) checkHit("hold", 100);
					break;
					
				case "whip":
					
					_modelObjectRef.attribs.whipping = false;
					if (_modelObjectRef.attribs.snapPoint) {
						checkHit("hold", 50, _modelObjectRef.attribs.snapPoint);
						_modelObjectRef.attribs.snapPoint = null;
					}
					break;
					
				default:
					break;
							
			}
			
			if (_attackTool.spawns && _attackTool.spawnAt == "hold") fireWeapon();
			
		}
		
		//
		//
		public function onAttackComplete (e:GestureEvent):void {
			
			_attacking = false;
			_attackType = "";
			
			e.gesture.removeEventListener(GestureEvent.GESTURE_START, onAttackStart);
			e.gesture.removeEventListener(GestureEvent.GESTURE_KEYFRAME, onAttack);
			e.gesture.removeEventListener(GestureEvent.GESTURE_MID, onAttackMid);
			e.gesture.removeEventListener(GestureEvent.GESTURE_HOLD, onAttackHold);
			e.gesture.removeEventListener(GestureEvent.GESTURE_END, onAttackComplete);
			
			if (_attackTool.spawns && _attackTool.spawnAt == "complete") fireWeapon();
			
			if (_attackTool.countable) {
				
				_attackTool.update();
				
			}
			
			_attackTool = null;
					
		}
		
		
		//
		//
		protected function checkHit (gesturePhase:String = "hold", tolerance:Number = 0, overridePoint:Point = null):void {
			
			if (flipping) _attackStrong = true;
			
			if (!_hitSuccess) {
				
				var pt:Point = (overridePoint == null) ? _attackTool.tooltip : overridePoint;
				var hitObj:PlayObject = PlayObject.hitTestTool(this, _attackTool, -1, ReactionType.BOUNCE, tolerance, overridePoint);
				
				/*
				var s:Symbol;
				if (hitObj) s = ObjectFactory.effect(this, "circle", true, 2000, _attackTool.tooltip);
				else s = ObjectFactory.effect(this, "circlefalse", true, 2000, _attackTool.tooltip);
				if (s) s.scale = tolerance / 100;
				else trace("no symbol");
				
				trace("checked hit for", gesturePhase, "at", TimeStep.realTime, "res:", hitObj);
				*/

				if (hitObj is PlayObjectControllable) {
					hit(hitObj, gesturePhase, overridePoint);
					if (hitObj is PlayObjectMovable) repel(hitObj as PlayObjectMovable, 200 * _attackTool.strength);
				} else if (hitObj is PlayObject) {
					var f:int = 200;
					if (_attackType == "high") f = 600;
					MotionObject(simObject).applyImpulse(new Vector2d(null, 0, f));
					
					ObjectFactory.effect(this, "sparkeffect", true, 1000, pt);
					if (_attackAction == "strike" || _attackAction == "bash") {
						if (_attackType == "middle") {
							Fuz2d.sounds.addSound(this, "clash8", true, 0, 0.3);
						} else if (_attackType == "high") {
							Fuz2d.sounds.addSound(this, "clash6");
						}
					}
				}	
				
			}			
			
		}
		
		protected function onCollision (e:CollisionEvent):void {
			
			if (e.collidee == _simObjectRef) return;
			
			var pobj:PlayObjectControllable;
			
			var ts:int = TimeStep.realTime;
			
			if (flipping && (_striking || _attacking) && (_attackAction == "strike" || _attackAction == "bash" || _attackAction == "scratch") && _attackTool && !_attackTool.blunt) {
				
				if (_playfield.playObjects[e.collidee] != null && _playfield.playObjects[e.collidee] is PlayObjectControllable) {
					
					pobj = PlayObjectControllable(_playfield.playObjects[e.collidee]);
					
					if (pobj != null && (pobj.dying || pobj.deleted)) return;
					
					if (PlayObject.boundingTest(pobj, _attackTool.tooltip)) {
						
						harm(pobj, _attackTool.strength * 0.25);
						
						ObjectFactory.effect(this, "flipeffect", true, 1000, _attackTool.tooltip, _attackTool.toolRotation);
						
						if (ts - _lastHitSound > 250) {
							eventSound("strike_high_hit");
							ObjectFactory.effect(this, "slasheffect1", true, 1000, _attackTool.tooltip, _attackTool.toolRotation);
							_lastHitSound = TimeStep.realTime;
						}
						
					}
					
				}
				
			}
			
			if (_gravityKicking) {
				if ((!lastJump.rotate && stamina < 50) || (lastJump.rotate && stamina < 25)) _gravityKicking = false;
			}
			
			if (!_landed && _gravityKicking && !(e.collidee is VelocityObject) && e.contactNormal.x == 0 && e.contactNormal.y < 0) {
				
				_gravityKicking = false;
				_landed = true;
				
				if (lastJump != null && lastJump.rotate && body.attribs.roll == true) {
					_regPt.x = object.x;
					_regPt.y = object.y - object.height * 0.5 + 10;
					if (lastJump.direction == JumpBehavior.LEFT) {
						ObjectFactory.effect(this, "rollinglanding_left", false, 1000, _regPt);
					} else {
						ObjectFactory.effect(this, "rollinglanding_right", false, 1000, _regPt);
					}
					roll();
					stamina -= 25;
				} else if (e.contactSpeed > 400 && body.attribs.stomp == true) {
					_regPt.x = object.x;
					_regPt.y = object.y - object.height * 0.5 + 60;
					ObjectFactory.effect(this, "powerlanding", false, 1000, _regPt);
					eventSound("stomp");
					GameLevel.gameEngine.view.camera.shake();
					body.attribs.pouncing = true;
					kneel();
					stamina -= 50;
				}

			}
			
			if (_rolling && e.contactSpeed > 300) {
				
				if (_playfield.playObjects[e.collidee] != null && _playfield.playObjects[e.collidee] is PlayObjectControllable) {
					
					pobj = PlayObjectControllable(_playfield.playObjects[e.collidee]);
					
					ObjectFactory.effect(this, "puncheffect", true, 1000, e.contactPoint, 0);
					harm(pobj, 15);
					
				}
					
			}
			
			// boomerang 
			
			if (flipping && ts - _lastBoomerang > 1000 && e.collidee.collisionObject.reactionType == ReactionType.BOUNCE) {
				
				if (lastJump && !lastJump.doubleJumped) {
					_lastBoomerang = ts;
					return;
				}
				
				if ((MotionObject(_simObjectRef).velocity.x > 160 && e.contactPoint.x > _modelObjectRef.x) ||
					(MotionObject(_simObjectRef).velocity.x < -160 && e.contactPoint.x < _modelObjectRef.x)) {

					modifiers.add(new PushModifier(0, 30));
				}
				
				_lastBoomerang = ts;
				
				ObjectFactory.effect(this, "doublejumpeffect", true, 1000, e.contactPoint, e.contactNormal.rotation - Geom2d.HALFPI);
				
			}
			
		}
		
		//
		//
		protected function hit (hitObj:PlayObject, gesturePhase:String = "hold", overridePoint:Point = null):void {
			
			_hitSuccess = true;
			
			var pt:Point = (overridePoint == null) ? _attackTool.tooltip : overridePoint;
			
			var mult:Number = 1;
			if (_attackType == "high") mult = 2;
			if (_attackType == "low") mult = 0.5;
			
			if (_attackStrong) {
				if (body.attribs.smash && stamina > 25) {
					mult = 4;
					stamina -= 25;
				}
				else _attackStrong = false;
			}
			
			if (hitObj is BipedObject && BipedObject(hitObj).falling) mult *= 2;
			
			harm(hitObj as PlayObjectControllable, _attackTool.strength * mult);
			
			if (hitObj is BipedObject &&
				BipedObject.defendSuccess(this, hitObj as BipedObject) && 
				BipedObject(hitObj).body != null && 
				BipedObject(hitObj).body.tools_lt != null && 
				BipedObject(hitObj).body.tools_lt.tooltip != null && 
				body.tools_rt.action != "whip") {
					
				ObjectFactory.effect(this, "clasheffect3", true, 1000, BipedObject(hitObj).body.tools_lt.tooltip, BipedObject(hitObj).body.tools_lt.toolRotation);
				BipedObject(hitObj).eventSound(_attackAction + "_" + gesturePhase + "_defend");
				
			} else {
				
				var effectName:String = "clasheffect1";
				var trot:Number = _attackTool.toolRotation;
				
				if (_attackAction == "punch") effectName = "puncheffect";
				else if (_attackType == "high") effectName = "clasheffect4";
				else if (_attackType == "low") effectName = "clasheffect5";
				
				if (_jumping && mult > 2) {
					if (body.facing == Biped.FACING_LEFT) effectName = "slasheffect2";
					else effectName = "slasheffect1";
				}
				
				if (_attackAction == "scratch") {
					if (body.facing == Biped.FACING_LEFT) effectName = "slasheffect1";
					else effectName = "slasheffect2";					
				}
				
				if (_attackStrong) {
					effectName = "hiteffectstrong";
					if (body.facing == Biped.FACING_LEFT) trot -= Geom2d.PI;
				}
				
				ObjectFactory.effect(this, effectName, true, 1000, pt, trot);
				
				if (!_attackStrong) {
					eventSound(_attackAction + "_" + _attackType + "_hit");
				} else {
					Fuz2d.sounds.addSound(this, "strong_hit");
				}
				
				// add force
				if (mult > 1 && hitObj.simObject is MotionObject) MotionObject(hitObj.simObject).addForce(new Vector2d(null, hitObj.object.x - _modelObjectRef.x, 0), 100); 
				
				// double effect if power is high
				if (mult > 2) ObjectFactory.effect(this, effectName, true, 1000, _attackTool.tooltip, trot);
				
				_attackStrong = false;
				
			}
			
		}
		
		//
		//
		public function prevToolRight ():void {
			
			body.tools_rt.prevEnabledTool();
					
		}
		
		//
		//
		public function nextToolRight ():void {
			
			body.tools_rt.nextEnabledTool();
					
		}
		
		//
		//
		public function prevToolLeft ():void {
			
			body.tools_lt.prevEnabledTool();
					
		}
		
		//
		//
		public function nextToolLeft ():void {
			
			body.tools_lt.nextEnabledTool();
		
		}
		
		public function startJump (direction:int = JumpBehavior.CENTER, power:Number = 1, rotate:Boolean = false):void {
			
			if (!behaviors.containsClass(JumpBehavior)) {
				if (rotate) {
					if (stamina > 25) stamina -= 25;
					else rotate = false;
				}
				lastJump = _behaviors.add(new JumpBehavior(direction, power, rotate)) as JumpBehavior;
				eventSound("startjump");
			}
			
		}
		
		//
		//
		public function fall ():void {
			
			if (!_falling && !_rolling && !_kneeling) {
				body.state = Biped.STATE_NORMAL;
				var b:GestureBehavior = GestureFactory.createNew(this, "fall", direction, "fall");
				if (b != null) {
					b.gesture.addEventListener(GestureEvent.GESTURE_END, onFallComplete);
					var s:Symbol = ObjectFactory.effect(this, "dizzyeffect", false, 1000);
					s.point = _modelObjectRef.point;
				}
				_falling = true;
				_modifiers.add(new LockModifier(2000));
				_kneeling = false;
				setCrouch(true);
				
				eventSound("fall");
				
			}
			
		}
		//
		//
		protected function onFallComplete (e:GestureEvent):void {
			
			eventSound("recover");
			_falling = false;
			setCrouch(false);
			
		}
		
		//
		//
		public function kneel ():void {
			
			if (!_falling && !_kneeling && !_rolling) {
				faceCenter();
				var b:GestureBehavior = GestureFactory.createNew(this, "kneel", direction, "kneel");
				if (b != null) {
					b.gesture.addEventListener(GestureEvent.GESTURE_END, onKneelComplete);
				}
				_kneeling = true;
				_modifiers.add(new LockModifier(650));
				body.state = Biped.STATE_KNEELING;
				setCrouch(true);
			}
			
		}
		//
		//
		protected function onKneelComplete (e:GestureEvent):void {
			
			_kneeling = false;
			body.state = Biped.STATE_NORMAL;
			setCrouch(false);
			
		}
		
		//
		//
		public function roll ():void {
			
			if (!_falling && !_kneeling && !_rolling) {
				setCrouch(true);
				_modifiers.add(new RollModifier());
			}
			
		}

		
		//
		//
		override protected function die():void {
			
			behaviors.add(new JumpBehavior(JumpBehavior.CENTER, 0.5))
			super.die();
			
			var b:GestureBehavior = GestureFactory.createNew(this, "die", direction, "die");
			if (b != null) b.gesture.addEventListener(GestureEvent.GESTURE_END, onDeathComplete);
			
			//simObject.collisionObject.reactionType = ReactionType.PASSTHROUGH;
	
		}
		
		//
		//
		protected function onDeathComplete (e:GestureEvent):void {
			
			destroy();
			
		}
		
	}
	
}
