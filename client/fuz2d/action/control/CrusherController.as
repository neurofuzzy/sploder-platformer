/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.action.control {
	
	import flash.events.Event;
	import fuz2d.action.control.Controller;
	import fuz2d.library.ObjectFactory;
	import fuz2d.model.object.Object2d;
	import fuz2d.model.object.Symbol;
	import fuz2d.util.Geom2d;
	
	import fuz2d.action.play.*;
	import fuz2d.action.physics.*;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class CrusherController extends PlayObjectController {
		
		protected var _velObject:VelocityObject;
		protected var _crushObject:Object2d;
		
		protected var _stickMax:int = 40;
		protected var _stickTimes:int = 0;
		
		protected var _speed:Number = 3;
		protected var _depth:Number = 0;
		protected var _maxDepth:Number = 0;
		protected var _depthFrame:int = 1;
		protected var _dir:int = 1;
		protected var _rot:int = 0;
		
		protected var _crushImpulse:Vector2d;
		protected var _crushPower:Number = 3000;
		protected var _started:Boolean = true;
		protected var _finished:Boolean = false;
		protected var _yoyo:Boolean = true;
		protected var _maxDepthReached:Number = 0;
		
		//
		//
		public function CrusherController (object:PlayObjectControllable, speed:Number = 3, started:Boolean = true, yoyo:Boolean = true) {
		
			super(object);
			
			_speed = speed;
			_started = started;
			_yoyo = yoyo;
			_dir = 1;
			_rot = Math.round(_object.object.rotation * Geom2d.rtd);
		
			_maxDepth = Math.max(_object.object.width, _object.object.height);
			
			_crushObject = new Object2d(null, _object.object.x, _object.object.y);
			_crushObject.width = _crushObject.height = 1;
			_crushImpulse = new Vector2d();
			
			switch(_rot) {
				
				case 0:
					_crushObject.width = _object.object.width;
					_crushObject.y -= _object.object.height * 0.5;
					_crushImpulse.y = 0 - _crushPower * 0.5;
					break;
				case 180:
					_crushObject.width = _object.object.width;
					_crushObject.y += _object.object.height * 0.5;
					_crushImpulse.y = _crushPower * 0.5;
					break;
				case 90:
					_crushObject.height = _object.object.height;
					_crushObject.x -= _object.object.width * 0.5;
					_crushImpulse.x = 0 - _crushPower;
					_crushImpulse.y = 200;
					break;
				case 270:
					_crushObject.height = _object.object.height;
					_crushObject.x += _object.object.width * 0.5;
					_crushImpulse.x = _crushPower;
					_crushImpulse.y = 200;
					break;
					
			}
			
			_velObject = new VelocityObject(_object.simObject.simulation, _crushObject, CollisionObject.OBB, ReactionType.BOUNCE, false, false, 5 * _speed);
			_velObject.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);
			
			switch(_rot) {
				
				case 0:
				case 180:
					_velObject.lockX = true;
					break;
				case 90:
				case 270:
					_velObject.lockY = true;
					break;
					
			}
			
			updateVelObject();
			
		}
		
		//
		//
		override public function update (e:Event):void {
			
			if (_ended || !_active || !_started || _finished) return;
			
			super.update(e);

			if (_velObject.sticking && _dir > 0) {
				
				_velObject.sticking = false;
				
				var oldFrame:int = parseInt(Symbol(_object.object).state);
				
				_depth -= _speed * 2;
				
				if (_depth < 0) {
					_depth = 0;
					_dir = 1;
				}
				
				if (!_yoyo) _depth = Math.max(_maxDepthReached, _depth);
				_depthFrame = Math.floor((_depth / _maxDepth) * 60);
				
				if (oldFrame == _depthFrame) {
					
					if (_depthFrame > 1) {
						_depthFrame -= 1;
					} else if (_depthFrame < 60) {
						_depthFrame += 1;
					}
					
				}

				Symbol(_object.object).state = "" + _depthFrame;

			} else {
				
				_depth += _dir * _speed;
				
				if (_depth > _maxDepth) {
					_depth = _maxDepth;
					_dir = -1;
					if (!_yoyo) {
						finish();
					}
				} else if (_depth < 0) {
					_depth = 0;
					_dir = 1;
				}
				
				if (!_yoyo) _depth = Math.max(_maxDepthReached, _depth);
				_depthFrame = Math.floor((_depth / _maxDepth) * 60);
				
				Symbol(_object.object).state = "" + _depthFrame;
				
				updateVelObject();
				
			}
			
			_maxDepthReached = Math.max(_maxDepthReached, _depth);
			
			/*
			var s:Symbol = ObjectFactory.effect(_object, "square", true, 10000, _velObject.position, 0);
			s.scale = _velObject.collisionObject.dimX / 60;
			s.x -= _velObject.collisionObject.halfX;
			s.y += _velObject.collisionObject.halfY;
			*/
			
		}
		
		protected function updateVelObject ():void {
			
			switch(_rot) {
			
				case 0:
					_crushObject.y = _object.object.y + _object.object.height * 0.5 - _depth * 0.5;
					_crushObject.height = _depth;
					_velObject.collisionObject.dimY = _depth;
					_velObject.collisionObject.halfY = _depth * 0.5;
					break;
				case 180:
					_crushObject.y = _object.object.y - _object.object.height * 0.5 + _depth * 0.5;
					_crushObject.height = _depth;
					_velObject.collisionObject.dimY = _depth;
					_velObject.collisionObject.halfY = _depth * 0.5;
					break;
				case 90:
					_crushObject.x = _object.object.x + _object.object.width * 0.5 - _depth * 0.5;
					_crushObject.width = _depth;
					_velObject.collisionObject.dimX = _depth;
					_velObject.collisionObject.halfX = _depth * 0.5;
					break;
				case 270:
					_crushObject.x = _object.object.x - _object.object.width * 0.5 + _depth * 0.5;
					_crushObject.width = _depth;
					_velObject.collisionObject.dimX = _depth;
					_velObject.collisionObject.halfX = _depth * 0.5;
					break;
					
			}
			
			_velObject.getPosition();			
			
		}
		
		override public function signal(signaler:Controller, message:String = ""):void 
		{
			super.signal(signaler, message);
			
			if (!_finished && message == "link") _started = true;
			
		}
		
		protected function finish ():void {
			
			_finished = true;
			
			if  (_velObject) {
				_velObject.lockX = _velObject.lockY = true;
				_object.playfield.map.register(_object, _object.object.x, _object.object.y);
			}
			
		}
		
		protected function onCollision (e:CollisionEvent):void {
			
			if (!_started || _finished) return;
			if (_dir != 1) return;
			
			if (e.collider is MotionObject) {
				
				switch (_rot) {
					
					case 0:
						
						if (e.contactNormal.x != 0) return;
						if (Math.round(e.contactPoint.y) >= Math.round(_velObject.position.y + _velObject.collisionObject.halfY) + 15) {
							return;
						}
						
						break;
						
					case 180:
					
						if (e.contactNormal.x != 0) return;
						if (Math.round(e.contactPoint.y) <= Math.round(_velObject.position.y - _velObject.collisionObject.halfY) - 15) {
							return;
						}
						break;
							
					case 90:
					
						if (e.contactNormal.y != 0) return;
						if (Math.round(e.contactPoint.y) >= Math.round(_velObject.position.y + _velObject.collisionObject.halfY) - 25) {
							return;
						}
						if (Math.round(e.contactPoint.x) >= Math.round(_velObject.position.x - _velObject.collisionObject.halfX) + 15) {
							return;
						}

						break;
					
					case 270:
					
						if (e.contactNormal.y != 0) return;
						if (Math.round(e.contactPoint.y) >= Math.round(_velObject.position.y + _velObject.collisionObject.halfY) - 25) {
							return;
						}
						if (Math.round(e.contactPoint.x) <= Math.round(_velObject.position.x + _velObject.collisionObject.halfX) - 15) {
							return;
						}									
						break;
							
					
				}
				
				MotionObject(e.collider).addForce(_crushImpulse);
				
				if (_velObject.sticking) {
					
					var pobj:PlayObject = _object.playfield.playObjects[e.collider];
					
					if (pobj && pobj is PlayObjectControllable) {
						
						_object.harm(PlayObjectControllable(pobj), 3, e.contactPoint);
						ObjectFactory.effect(_object, "puncheffect", true, 1000, e.contactPoint);
						
					}
					
				}
				
			}
			
		}
		
	}
	
}