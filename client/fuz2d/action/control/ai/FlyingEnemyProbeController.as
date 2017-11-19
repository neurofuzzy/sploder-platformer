package fuz2d.action.control.ai {
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import fuz2d.action.control.PlayObjectController;
	import fuz2d.action.physics.*;
	import fuz2d.action.play.*;
	import fuz2d.TimeStep;
	import fuz2d.util.Geom2d;
	
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class FlyingEnemyProbeController extends PlayObjectController {
		
		protected var _body:PlayObjectMovable;
		protected var _player:PlayObject;
		
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
		
		private var _lastAttack:int = 0;
		private var _lastApproach:int = 0;
		private var _lastSound:int;
		
		private var _firstSight:int = 0;
		
		private var _homePoint:Point;

		//
		//
		public function FlyingEnemyProbeController (object:PlayObjectControllable, speed:int = 5, aggression:int = 50, weaponsRange:int = 0, projectile:String = "", fireDelay:int = 0, firePower:int = 100, bank:Boolean = true) {
		
			super(object);
			
			_body = object as PlayObjectMovable;

			_speed = speed;
			_aggression = aggression;
			_weaponsRange = weaponsRange * weaponsRange;
			_projectile = projectile;
			_fireDelay = fireDelay;
			_firePower = firePower;
	
			_homePoint = _object.object.point.clone();
			
			if (bank) MotionObject(_object.simObject).bankAmount = 0.5;
			
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
			
			
			if (p.object.symbolName == "player") {
				
				if (_player == null) _object.eventSound("see");
				_player = p;
				if (_firstSight == 0) _firstSight = TimeStep.realTime;
				
			}
			
			if (_target != null && _target.object != null && _target.object.attribs.health == 0) _target = null;
			if (_target == null)
			{
				var pobjs:Array = _object.playfield.sightGrid.getNeighborsOf(_object, true, true, null, 8, 8);
				
				for each (var pobj:PlayObject in pobjs)
				{
					if (pobj.group == "good" && _object.playfield.map.canSee(_object, pobj))
					{
						_target = pobj;
						_targetNear = true;
						break;
					}
				}
			}
			if (p == _target) _targetNear = true;
			
		}
		
		//
		//
		override public function update (e:Event):void {
			
			if (_ended || !_active || _body.locked || _body.dying) return;
			
			super.update(e);
			
			if (_body == null || _body.deleted) {
				end();
				return;
			}
			
			if (_player != null && !_player.deleted) {
				_homePoint.x = _player.object.point.x;
				_homePoint.y = _player.object.point.y + 180;
			}
			
			if (_target != null && _target.deleted) {
				_target = null;
				_targetNear = false;
			}
			
			if (_firstSight > 0 && TimeStep.realTime - _firstSight > 60000)
			{
				_object.harm(_object, 1);
				return;
			}
				
			
			if (_targetNear && Math.floor(Math.random() * 20) == 10) _object.eventSound("random");
			
			
			if (_target == null || _targetNear == false) {
				
				if (_homePoint.x < _object.object.x) _body.moveLeft(_speed / 40);
				else if (_homePoint.x > _object.object.x) _body.moveRight(_speed / 40);
				
				if (_homePoint.y > _object.object.y) _body.moveUp(_speed / 40);
				else if (_homePoint.y < _object.object.y) _body.moveDown(_speed / 40);				
				
			}

			if (_player != null && _player.deleted) {
				
				_player = null;
				_target = null;
				_targetNear = false;
				
			} else if (_target != null && _targetNear) {
				
				var sqdist:Number = Geom2d.squaredDistanceBetweenPoints(_object.object.point, _target.object.point);
				
				var xv:Number = Math.abs(MotionObject(_object.simObject).velocity.x);
				
				if (sqdist > 200000) {
							
					_target = null;
					_targetNear = false;
					_lastApproach = 0;
	
				} else {
					
					if (sqdist > 8000 + _weaponsRange * 0.5) {
						
						if (_object.playfield.map.canSee(_body, _target)) {
							
							if (_target.object.x - _target.object.width * 0.5 < _object.object.x) _body.moveLeft(_speed / 20);
							else if (_target.object.x + _target.object.width * 0.5 > _object.object.x) _body.moveRight(_speed / 20);
							
							if (_target.object.y + _target.object.height > _object.object.y) _body.moveUp(_speed / 40);
							else _body.moveDown(_speed / 40);
						
							_lastApproach = 0;
							
						}
						
					} else {
						
						if (_target.object.x - _target.object.width * 0.5 > _object.object.x) _body.moveLeft(_speed / 20);
						else if (_target.object.x + _target.object.width * 0.5 < _object.object.x) _body.moveRight(_speed / 20);
						
						if (_weaponsRange > 0 && canAttack && _projectile.length > 0) PlayObject.launchNew(_projectile, _object, null, _firePower, _target);

						if (_target.object.y + _target.object.height * 0.5 + 100 > _object.object.y) _body.moveUp(_speed / 40);
						else _body.moveDown(_speed / 40);
						
					}

				}
				
			}
				
		}
		
		//
		//
		public function get canAttack ():Boolean  {
			
			if (_fireDelay == 0 && (TimeStep.realTime - _lastAttack > (10 - _speed) * 200 && Math.random() * 100 < _aggression) ||
				_fireDelay > 0 && (TimeStep.realTime - _lastAttack > _fireDelay)) {
			
				_lastAttack = TimeStep.realTime;
				return true;
				
			}
			
			return false;
			
		}
		
		
		
		//
		//
		protected function onCollision (e:CollisionEvent):void {
			
			if (_target == null && e.collider.group == "good") {
				
				_target = _object.playfield.playObjects[e.collider];
				
			}
			
		}
		
		//
		//
		override public function end():void {
			
			_body = null;
			_player = null;
			_target = null;
			_targetNear = false;
			if (_object != null && _object.simObject != null) _object.simObject.removeEventListener(CollisionEvent.COLLISION, onCollision);
			_object = null;
			_homePoint = null;
			
			super.end();
			
		}
		
	}
	
}