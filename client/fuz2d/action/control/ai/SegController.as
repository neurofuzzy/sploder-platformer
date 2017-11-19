package fuz2d.action.control.ai 
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import fuz2d.action.control.PlayObjectController;
	import fuz2d.action.modifier.LockModifier;
	import fuz2d.action.physics.CollisionEvent;
	import fuz2d.action.physics.MotionObject;
	import fuz2d.action.physics.SimulationObject;
	import fuz2d.action.physics.Vector2d;
	import fuz2d.action.play.PlayfieldMap;
	import fuz2d.action.play.PlayObject;
	import fuz2d.action.play.PlayObjectControllable;
	import fuz2d.action.play.PlayObjectMovable;
	import fuz2d.library.ObjectFactory;
	import fuz2d.model.object.SegSymbol;
	import fuz2d.model.object.Symbol;
	import fuz2d.TimeStep;
	import fuz2d.util.Geom2d;
	
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class SegController extends PlayObjectController
	{
		protected var _seg:SegSymbol;
		protected var _movable:PlayObjectMovable;
		
		protected var _bearingBlock:SimulationObject;
		protected var _destBlock:SimulationObject;
		
		protected var _anchorPoint:Point;
		protected var _anchorAngle:Number;
		protected var _lastPos:Point;
		
		protected var _distLeft:Number = 0;
		protected var _distRight:Number = 0;
		protected var _lastSwitch:Number = 0;
		protected var _lastReverse:Number = 0;
		protected var _lastCheck:Number = 0;
		protected var _lastDisengage:Number = -5000;
		protected var _clampVal:Number = 100;
		protected var _moveDir:uint;
		protected var _floorDir:uint;
		protected var _dirs:Array;
		protected var _map:PlayfieldMap;
		
		protected var _player:PlayObject;
		protected var _playerNear:Boolean = false;
		
		protected var _weaponsRange:int = 0;
		
		private var _lastSound:int;
		
		
		public function SegController(object:PlayObjectControllable) 
		{
			super(object);
			
			_seg = SegSymbol(_object.object);
			_movable = _object as PlayObjectMovable;
			_dirs = [PlayfieldMap.UP, PlayfieldMap.RIGHT, PlayfieldMap.DOWN, PlayfieldMap.LEFT];
			_moveDir = PlayfieldMap.DOWN;
			_floorDir = PlayfieldMap.DOWN;
			
			_map = _object.playfield.map;
			
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
				_playerNear = true;
				
			}
			
		}
		
		override public function update(e:Event):void 
		{
			if (_ended || !_active || _movable.locked) return;
			
			super.update(e);
			
			MotionObject(_movable.simObject).gravity = 0.01;
			
			var sqdist:Number;
			
			if (_player != null && _player.deleted) {
				
				_player = null;
				_playerNear = false;
				
			} else if (_playerNear) {
				
				sqdist = Geom2d.squaredDistanceBetweenPoints(_object.object.point, _player.object.point);
				
				var rangePadding:Number = 0;
				
				if (_player.object.attribs.padding > 0) {
					rangePadding += _player.object.attribs.padding;
					sqdist -= (rangePadding * rangePadding);
				}

				var xv:Number = MotionObject(_object.simObject).velocity.x;
				_seg.attribs.xv = xv;
				if (xv < 0) xv = 0 - xv;
							
				if (sqdist > 200000) {
						
					if (_player) {
						
						if (_destBlock == _player.simObject) _destBlock = null;
						if (_bearingBlock == _player.simObject) _bearingBlock = null;
						
						_player = null;
						
					}
					
					_playerNear = false;
					
				} else if (sqdist < 60000) {
					
					if (_destBlock != _player.simObject) {
						_destBlock = _player.simObject;
						_seg.attribs.leftSnap = _seg.attribs.rightSnap = false;
					}
					
				} else if (_destBlock == _player.simObject) {
					
					_destBlock = null;
					
				} else if (_bearingBlock == _player.simObject) {
					
					_bearingBlock = null;
					
				}
						
				
			}
			
			if (TimeStep.realTime - _lastCheck < 600 || TimeStep.realTime - _lastDisengage < 5000) {
				
				moveInDirection();
				if (TimeStep.realTime - _lastDisengage < 5000) _movable.moveDown(0.25);
				
			} else {
				
				_lastCheck = TimeStep.realTime;
					
				var changedDir:Boolean = false;
				
				if (!_map.canMove(_object, _moveDir)) {
					
					var nd:uint = _moveDir;
					
					while (nd == _moveDir) {
						
						nd = _dirs[Math.floor(Math.random() * _dirs.length)];
						
					}
					
					_moveDir = nd;
					
					changedDir = true;
					
					switch (_moveDir) {
						
						case PlayfieldMap.LEFT:
						case PlayfieldMap.RIGHT:
						
							if (!_map.canMove(_object, PlayfieldMap.DOWN)) _floorDir = PlayfieldMap.DOWN;
							else if (!_map.canMove(_object, PlayfieldMap.UP)) _floorDir = PlayfieldMap.UP;
							else _floorDir = _moveDir;
							break;
							
						case PlayfieldMap.UP:
						case PlayfieldMap.DOWN:
						
							if (!_map.canMove(_object, PlayfieldMap.LEFT)) _floorDir = PlayfieldMap.LEFT;
							else if (!_map.canMove(_object, PlayfieldMap.RIGHT)) _floorDir = PlayfieldMap.RIGHT;
							else _floorDir = _moveDir;
							break;
						
					}
					
				}
				
				if ((changedDir || TimeStep.realTime - _lastSwitch > 500) && _destBlock != null && 
					Geom2d.squaredDistanceBetweenPoints(_lastPos, _seg.point) > 50) { 
					_bearingBlock = _destBlock;
					_seg.switchFeet();
					_destBlock = null;
					_lastSwitch = TimeStep.realTime;
				} else if (_bearingBlock != null && TimeStep.realTime - _lastSwitch > 5000) {
					_bearingBlock = _destBlock = null;
					_lastDisengage = TimeStep.realTime;
					_moveDir = (_floorDir % 2 == 0) ? _floorDir - 1 : _floorDir + 1;
					moveInDirection();
				}
				
				_lastPos = _seg.point.clone();
				
				if (_destBlock == null) {
					
					var src:Point = _object.object.point.clone();
					var dest:Point = src.clone();
					
					switch (_floorDir) {
						
						case PlayfieldMap.LEFT:
							dest.x -= 200;
							if (_moveDir == PlayfieldMap.UP) dest.y += 200;
							else dest.y -= 200;
							break;
						case PlayfieldMap.RIGHT:
							dest.x += 200;
							if (_moveDir == PlayfieldMap.UP) dest.y += 200;
							else dest.y -= 180;
							break;
						case PlayfieldMap.UP:
							dest.y += 200;
							if (_moveDir == PlayfieldMap.RIGHT) dest.x += 200;
							else dest.x -= 200;
							break;
						case PlayfieldMap.DOWN:
							dest.y -= 200;
							if (_moveDir == PlayfieldMap.RIGHT) dest.x += 200;
							else dest.x -= 200;
							break;
						
					}
					
					var res:Object;
					
					res = _object.simObject.simulation.getObjectAtSegment(src, dest, _bearingBlock, true);

					if (res) {
						
						_destBlock = SimulationObject(res.obj);
						_anchorPoint = res.pt;
						_anchorAngle = Geom2d.angleBetweenPoints(_object.object.point, _anchorPoint);
						
					} else {
						
						switch (_floorDir) {
							
							case PlayfieldMap.LEFT:
							case PlayfieldMap.RIGHT:
								if (_bearingBlock) src.y = _bearingBlock.position.y;
								dest.y = _object.object.y;
								break;
								
							case PlayfieldMap.UP:
							case PlayfieldMap.DOWN:
								if (_bearingBlock) src.x = _bearingBlock.position.x;
								dest.x = _object.object.x;
								break;
							
						}
						
						res = _object.simObject.simulation.getObjectAtSegment(dest, src, _bearingBlock, true);
						
						if (res == null) {
							dest.x = _object.object.x;
							dest.y = _object.object.y;
							dest.x += Math.random() * 360 - 180;
							dest.y += Math.random() * 360 - 180;
							res = _object.simObject.simulation.getObjectAtSegment(dest, src, _bearingBlock, true);
						}
						
						if (res) {
							
							if (_destBlock != null) _bearingBlock = _destBlock;
							_seg.switchFeet();
							_destBlock = null;
							_lastSwitch = TimeStep.realTime;
							
							_destBlock = SimulationObject(res.obj);
							_anchorPoint = res.pt;
							_anchorAngle = Geom2d.angleBetweenPoints(_object.object.point, _anchorPoint);

							switch (_floorDir) {
							
								case PlayfieldMap.LEFT:
										_moveDir = PlayfieldMap.LEFT;
										if (_moveDir == PlayfieldMap.UP) _floorDir = PlayfieldMap.DOWN;
										else _floorDir = PlayfieldMap.UP;
									break;
									
								case PlayfieldMap.RIGHT:
										_moveDir = PlayfieldMap.RIGHT;
										if (_moveDir == PlayfieldMap.UP) _floorDir = PlayfieldMap.DOWN;
										else _floorDir = PlayfieldMap.UP;
									break;
									
								case PlayfieldMap.UP:
										_moveDir = PlayfieldMap.UP;
										if (_moveDir == PlayfieldMap.LEFT) _floorDir = PlayfieldMap.RIGHT;
										else _floorDir = PlayfieldMap.LEFT;
									break;
									
								case PlayfieldMap.DOWN:
										_moveDir = PlayfieldMap.DOWN;
										if (_moveDir == PlayfieldMap.LEFT) _floorDir = PlayfieldMap.RIGHT;
										else _floorDir = PlayfieldMap.LEFT;
									break;
								
							}
							
						}
					
					}
					
				}
				
			}
			
			if (_destBlock) {
				_seg.nonBearingFoot.x = _destBlock.position.x - _seg.x;
				_seg.nonBearingFoot.y = _destBlock.position.y - _seg.y;
			}
			
			if (_bearingBlock) {
				_seg.bearingFoot.x = _bearingBlock.position.x - _seg.x;
				_seg.bearingFoot.y = _bearingBlock.position.y - _seg.y;
			}			
			
			moveInDirection();
				
			if (!_destBlock && TimeStep.realTime - _lastReverse > 1000) {
				
				_moveDir = (_moveDir % 2 == 0) ? _moveDir - 1 : _moveDir + 1;
				
				_lastReverse = TimeStep.realTime;
				
			}
			
			if (_bearingBlock) {
				
				sqdist = Geom2d.squaredDistanceBetweenPoints(_object.object.point, _bearingBlock.position);
				
				if (sqdist > 40000) {
					
					var ang:Number = Geom2d.angleBetweenPoints(_object.object.point, _bearingBlock.position) - Geom2d.HALFPI;
					
					var cv:Vector2d = new Vector2d(null, 0, 400);
					cv.rotate(ang);
					_movable.move(cv, 1);
					
				}
			
			}
			
			_movable.clamp(_clampVal);
			
			if (_destBlock == null) {
				_seg.nonBearingFoot.x = 0;
				_seg.nonBearingFoot.y = 0;
			}
			
			if (_bearingBlock == null) {
				_seg.bearingFoot.x = 0;
				_seg.bearingFoot.y = 0;
			}
			
			if (_playerNear && _player) {
				var hit:Boolean = checkHit();
				if (hit) {
					_movable.harm(_player as PlayObjectControllable, 0.5, _player.object.point);
					if (TimeStep.realTime - _lastSound > 500) {
						_lastSound = TimeStep.realTime;
						_object.eventSound("harm");
					}
				}
			} else {
				_seg.attribs.leftHit = _seg.attribs.rightHit = false;
			}

		}
		
		protected function moveInDirection ():void {
			
			var nv:Vector2d = new Vector2d(_map.getDirectionPoint(_moveDir));
			nv.scaleBy(50);
			
			if (MotionObject(_movable.simObject).buoyant) {
				nv.scaleBy(2);
				_clampVal = 200;
			} else {
				_clampVal = 100;
			}
			
			_movable.move(nv, 1);	
			
			if (_bearingBlock) {
				
				var d:Number;
				var rv:Vector2d = new Vector2d();
				
				if (_floorDir == PlayfieldMap.UP || _floorDir == PlayfieldMap.DOWN) {
					
					d = Math.abs(_bearingBlock.position.y - _object.object.y);
					if (_floorDir == PlayfieldMap.UP) rv.y = -120 + d;
					else rv.y = 120 - d;
					
				} else {
					
					d = Math.abs(_bearingBlock.position.x - _object.object.x);
					if (_floorDir == PlayfieldMap.UP) rv.x = -120 + d;
					else rv.x = 120 - d;
					
				}
				
				if (d < 240) {
					//rv.scaleBy(4);
					_movable.move(rv, 1);
				}
				
			}
			
		}
		
		protected function checkHit ():Boolean {
			
			var hit:Boolean = false;
			
			_seg.attribs.leftHit = _seg.attribs.rightHit = false;
			
			if (_destBlock == _player.simObject) {
			
				if (_seg.nonBearingFoot == _seg.footPointLeft && _seg.attribs.leftSnap) {
					hit = _seg.attribs.leftHit = true;
				} else if (_seg.nonBearingFoot == _seg.footPointRight && _seg.attribs.rightSnap) {
					hit = _seg.attribs.rightHit = true;
				}
				
			}
			
			if (_bearingBlock == _player.simObject) {
				
				if (_seg.bearingFoot == _seg.footPointLeft && _seg.attribs.leftSnap) {
					hit = _seg.attribs.leftHit = true;
				} else if (_seg.bearingFoot == _seg.footPointRight && _seg.attribs.rightSnap) {
					hit = _seg.attribs.rightHit = true;
				}				
				
			}
			
			return hit;
			
		}
		
//
		//
		protected function onCollision (e:CollisionEvent):void {
			
			if (_player == null && e.collider.objectRef.symbolName == "player") {
				
				_player = _object.playfield.playObjects[e.collider];

			}
			if (e.collider.objectRef.symbolName == "player") {
				if (e.contactSpeed > 350 && 
					e.contactPoint.y >= _movable.object.y + _movable.object.height * 0.5 - _movable.object.width * 0.25) {
					
					_movable.modifiers.add(new LockModifier(3000));
					var s:Symbol = ObjectFactory.effect(_movable, "dizzyeffect", false, 1000);
					s.point = _movable.object.point;
					_movable.moveDown();
					MotionObject(_movable.simObject).gravity = 1;
					MotionObject(_movable.simObject).sleeping = false;
					_bearingBlock = _destBlock = null;
					_seg.bearingFoot.x = _seg.bearingFoot.y = _seg.nonBearingFoot.x = _seg.nonBearingFoot.y = 0;
					
				}
			}
			
			if (TimeStep.realTime - _lastSound > 1500 && e.collidee.objectRef != _movable.object) {
				if (e.contactSpeed > 500 && 
					e.contactPoint.y <= _movable.object.y - _movable.object.height * 0.5 + _movable.object.width * 0.25) {
					
					_object.eventSound("hard_landing");
					_lastSound = TimeStep.realTime;

				}
				
			}
			
		}
		
		override public function end():void 
		{
			_movable = null;
			_seg = null;
			_map = null;
			_bearingBlock = null;
			_destBlock = null;
			_anchorPoint = null;
			_player = null;
			
			if (_object != null && _object.simObject != null) _object.simObject.removeEventListener(CollisionEvent.COLLISION, onCollision);
			
			_object = null;
			
			super.end();
		}
		
	}

}