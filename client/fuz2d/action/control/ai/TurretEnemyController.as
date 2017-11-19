package fuz2d.action.control.ai {
	
	import flash.events.Event;
	import flash.geom.Point;
	import fuz2d.action.control.PlayObjectController;
	import fuz2d.action.physics.*;
	import fuz2d.action.play.*;
	import fuz2d.model.object.TurretSymbol;
	import fuz2d.TimeStep;
	import fuz2d.util.Geom2d;
	
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class TurretEnemyController extends PlayObjectController {
		
		protected var _target:PlayObject;
		protected var _targetNear:Boolean = false;

		// int between 1 and 10;
		protected var _speed:int = 5;
		// int between 1 and 100;
		protected var _aggression:int = 50;
		protected var _weaponsRange:int = 0;
		
		protected var _projectile:String = "";
		protected var _fireDelay:int = 0;
		protected var _firePower:int = 100;
		protected var _lastFire:Number = 0;
		
		private var _lastSound:int;

		protected var _hasTurret:Boolean = false;
		protected var _turretObject:TurretSymbol;

		//
		//
		public function TurretEnemyController (object:PlayObjectControllable, speed:int = 5, aggression:int = 50, weaponsRange:int = 0, projectile:String = "", fireDelay:int = 0, firePower:int = 100) {
		
			super(object);
			
			_speed = speed;
			_aggression = aggression;
			_weaponsRange = weaponsRange * weaponsRange;
			_projectile = projectile;
			_fireDelay = fireDelay;
			_firePower = firePower;
			
			if (_object.object is TurretSymbol) {
				_hasTurret = true;
				_turretObject = TurretSymbol(_object.object);
			}
			
			_object.simObject.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);
			
		}
		
		//
		//
		override public function see(p:PlayObject):void {
			
			super.see(p);
			
			if (_object == null || _object.deleted) {
				end();
				return;
			}
			
			if (_target == null || _target.deleted)
			{
				_target = null;
				_targetNear = false;
			}
			
			if (_target == null && p.group == "good") {
				
				_object.eventSound("see");
				_target = p;
				_targetNear = true;
				
			}
			
		}
		
		//
		//
		override public function update (e:Event):void {
			
			if (_ended || !_active || _object.locked || _object.dying) return;
			
			super.update(e);
			
			if (_object.deleted) {
				end();
				return;
			}
			
			if (_targetNear && Math.floor(Math.random() * 20) == 10) _object.eventSound("random");
			
			if (_target != null && _target.deleted) {
				
				_target = null;
				_targetNear = false;
				
			} else if (_targetNear) {
				
				var sqdist:Number = Geom2d.squaredDistanceBetweenPoints(_object.object.point, _target.object.point);
				
				if (sqdist > 200000) {
							
					_target = null;
					_targetNear = false;

				} else {
					
					var targetPt:Point = _object.object.positionRelative(_target.object.point);
					var tang:Number = Geom2d.normalizeAngle(_turretObject.turretAngle);
					var pang:Number = Math.atan2(targetPt.x, targetPt.y);
					
					var dang:Number = pang - tang;
					var adang:Number = Math.abs(dang);
					
					if (adang > 0.1) {
						if (dang < 0 && tang > 0 - Geom2d.HALFPI * 0.5) {
							_turretObject.turretAngle -= 0.05;
						} else if (dang > 0 && tang < Geom2d.HALFPI * 0.5) {
							_turretObject.turretAngle += 0.05;
						}
					}
	
					if (sqdist < 1000 + _weaponsRange && _object.playfield.map.canSee(_object, _target)) {
						
						var amin:Number = 0.2;
						
						if (sqdist < 1600) amin = 1.2;
						else if (sqdist < 3600) amin = 0.6;
						else if (sqdist < 6400) amin = 0.4;
					
						if (adang < amin && TimeStep.realTime - _lastFire > _fireDelay && _weaponsRange > 0 && _projectile.length > 0) {
							
							PlayObject.launchNew(_projectile, _object, null, _firePower, null, false, _turretObject.positionWorld(_turretObject.launchPoint), _turretObject.rotation + _turretObject.turretAngle - Geom2d.HALFPI);
							_lastFire = TimeStep.realTime;
							
						}
						
					}

				}
				
			}
				
		}
		
		//
		//
		protected function onCollision (e:CollisionEvent):void {
			
			if (_target == null && e.collider.objectRef.symbolName == "player") {
				
				_target = _object.playfield.playObjects[e.collider];
				
			}
			
		}
		
		//
		//
		override public function end():void {
			
			if (_object != null && _object.simObject != null) _object.simObject.removeEventListener(CollisionEvent.COLLISION, onCollision);
			if (_turretObject != null) _turretObject.state = "f_die";
			
			_turretObject = null;
			_target = null;
			_object = null;
			
			super.end();
			
		}
		
	}
	
}