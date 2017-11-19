/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.action.control {
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.media.SoundChannel;
	import fuz2d.action.behavior.WeakBlockBehavior;
	import fuz2d.action.physics.*;
	import fuz2d.action.play.*;
	import fuz2d.Fuz2d;
	import fuz2d.model.object.Biped;
	import fuz2d.model.object.Toolset;
	import fuz2d.TimeStep;
	import fuz2d.util.Geom2d;
	
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class SprayController extends PlayObjectController {
		
		protected var _strength:Number = 0;
		protected var _lifeSpan:int = 3;
		protected var _startTime:int = 0;
		protected var _forceFactor:Number = 0;
		
		protected var _toolset:Toolset;
		public function get toolset():Toolset { return _toolset; }
		public function set toolset(value:Toolset):void { _toolset = value; }	
		
		protected var _soundLoop:SoundChannel;
		protected var _eventSound:String;
		protected var _loopSound:Boolean;
		
		//
		//
		public function SprayController (object:PlayObjectControllable, strength:Number, forceFactor:Number = 0, lifeSpan:int = 3, eventSound:String = "", loopSound:Boolean = false) {
		
			super(object);
			
			_strength = strength;
			_forceFactor = forceFactor;
			_lifeSpan = (!isNaN(lifeSpan)) ? lifeSpan * 1000 : _lifeSpan;
			_eventSound = eventSound;
			_loopSound = loopSound;
			
			_startTime = TimeStep.realTime;
			
			_object.simObject.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);
			
			if (!_loopSound) {
				Fuz2d.sounds.addSound(_object, _eventSound);
			} else {
				_soundLoop = Fuz2d.sounds.addSoundLoop(_object, _eventSound);
			}

		}

		
		//
		//
		override public function update (e:Event):void {
			
			if (_ended || !_active) return;
			
			super.update(e);
			
			if (_toolset != null && _toolset.spawnType != "spray") {
				_object.destroy();
				end();
				return;
			}
			
			if (_toolset != null) {
				if (_toolset.tooltip != null) {
					_object.object.x = _toolset.tooltip.x;
					_object.object.y = _toolset.tooltip.y;
				}
				
				if (_object.creator is BipedObject) {
					var _biped:BipedObject = BipedObject(_object.creator);
					if (_biped.dying || _biped.deleted) {
						_object.destroy();
						end();
						return;
					}
					if (_biped.body.facing == Biped.FACING_LEFT && !_toolset.flip) {
						_object.object.rotation = _toolset.toolRotation + Math.PI;
					} else {
						_object.object.rotation = _toolset.toolRotation;
					}
					
				} else {
					_object.object.rotation = _toolset.toolRotation;
				}
				
			}

			if (TimeStep.realTime - _startTime > _lifeSpan || _object.playfield.map.inOccupiedCell(_object)) {
				_object.destroy();
				end();
			}
			
			if (_object != null && _object.simObject != null && 
				_biped != null && _biped.object != null && _biped.object.symbolName == "player") {
				
				var pt:Point = new Point(_toolset.tooltip.x, _toolset.tooltip.y);
				if (_biped.body.facing == Biped.FACING_LEFT) pt.x -= 100;
				else pt.x += 100;
				
				pt.x -= 60;
				pt.y -= 60;
				
				for (var j:int = -1; j <= 1; j++) {
					
					for (var i:int = -1; i <= 1; i++) {
						
						var hitObj:SimulationObject = _object.simObject.simulation.getObjectAtPoint(pt, _object.simObject);
					
						if (hitObj != null) {
							var pobj:PlayObject = _object.playfield.playObjects[hitObj];
							if (pobj is PlayObjectControllable && PlayObjectControllable(pobj).behaviors.containsClass(WeakBlockBehavior)) {
								_object.harm(pobj as PlayObjectControllable, (j == 0) ? 0.2 : 0.1);
							}
						}
						
						pt.x += 60;

					}
					
					pt.x -= 180;
					pt.y += 60;
				
				}
				
			}
			
			if (!_loopSound) {
				
				if (_soundLoop != null) Fuz2d.sounds.adjustSound(_object, _soundLoop);
				
			} else {
				
				var vol:Number = Fuz2d.sounds.getVolume(_object);
				
				if (vol > 0.1) {
					
					if (_soundLoop == null) _soundLoop = Fuz2d.sounds.addSoundLoop(_object, _eventSound);
					if (_soundLoop != null) Fuz2d.sounds.adjustSound(_object, _soundLoop);

				} else if (_soundLoop != null) {
					
					_soundLoop.soundTransform.volume = 0;
					_soundLoop.stop();
					_soundLoop = null;

				}	
				
			}
	
		}
		
		public function onCollision (e:CollisionEvent):void {

			if (_object == null || e.collider == null || e.collidee == null || _object.deleted || e.collider.deleted || e.collidee.deleted) return;
			
			if (!_object.isCreator(e.collider) && !_object.isCreator(e.collidee)) {
				
				var po:PlayObject;
				
				po = _object.playfield.playObjects[e.collider];
				if (po == null) po = _object.playfield.playObjects[e.collidee];
				
				if (po.group != _object.group) {
					
					if (po != null && po is PlayObjectControllable) {
						var dist:Number = Geom2d.distanceBetweenPoints(_object.object.point, po.object.point) / 10;
						var ang:Number = Geom2d.angleBetweenPoints(_object.object.point, po.object.point);
						ang += _object.object.rotation;
						ang = Math.abs(ang);
						
						if (ang < 0.45) {
							harm(po as PlayObjectControllable, _strength / (dist / 3));
							
							if (po.simObject is MotionObject) {
							
								var v:Vector2d = new Vector2d(null, _forceFactor * 150 / dist, 0);
								v.rotate(0 - _object.object.rotation);
								MotionObject(po.simObject).applyImpulse(v);
							}
							
						}
						
					}
					
				}
	
			}
			
		}
		
		//
		//
		public function harm (playObj:PlayObjectControllable, amount:Number = 0):void {
			
			if (playObj is BipedObject) {
				if (BipedObject.defendSuccess(_object as PlayObjectControllable, playObj as BipedObject)) {
					amount *= 1 - BipedObject(playObj).body.tools_lt.strength / 10;
				}
				if (amount <= 0) return;
			}

			if (playObj.health > 0) _object.harm(playObj, amount);

		}
		
		//
		//
		override public function end():void {
			
			if (_soundLoop != null) _soundLoop.stop();
			super.end();
			
		}
		
	}
	
}