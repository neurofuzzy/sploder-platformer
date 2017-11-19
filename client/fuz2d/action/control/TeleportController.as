/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.action.control {
	
	import flash.events.Event;
	
	import fuz2d.action.physics.*;
	import fuz2d.action.play.*;
	import fuz2d.Fuz2d;
	import fuz2d.library.ObjectFactory;
	import fuz2d.model.object.Biped;
	import fuz2d.model.object.Symbol;
	import fuz2d.TimeStep;
	import fuz2d.util.Geom2d;
	
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class TeleportController extends PlayObjectController {
		
		protected var _groupName:String = "";
		protected var _group:Array;
		protected var _teleportTime:Number = 0;

		protected var _busy:Boolean = false;
		protected var _busyWait:Boolean = false;
		
		public function get busy ():Boolean { return (_busy && _busyWait); }
		
		public function get teleporter ():PlayObjectControllable {
			return _object;
		}
		
		public static var teleporters:Object;

		//
		//
		public function TeleportController (object:PlayObjectControllable, groupName:String = "") {
		
			super(object);
			
			if (teleporters == null) teleporters = [];
			if (teleporters[groupName] == null) teleporters[groupName] = [];
			
			_groupName = groupName;
			_group = teleporters[groupName];
			
			_group.push(this);
			
			_object.simObject.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);
			
		}
		
		//
		//
		override public function see(p:PlayObject):void {
			
		}
		
		//
		//
		override public function update (e:Event):void {
			
			if (_ended || !_active) return;
			
			super.update(e);
			
			if (TimeStep.realTime - _teleportTime > 3000) {
				
				if (!_busy) _busyWait = false;
				_busy = false;
			
			} else if (TimeStep.realTime - _teleportTime > 2500) {
				
				Symbol(_object.object).state = "z_idle";
				
			}
			
		}
		
		public function teleportPlayer (player:PlayObjectControllable):void {
			
			if (TimeStep.realTime - _teleportTime > 3000) {
			
				var ntc:TeleportController = nearestTeleport;
				
				if (ntc != null && !ntc.busy) {
					
					ntc.receivePlayer(player);
					setTeleport();
					ObjectFactory.effect(_object, "teleportaway", true, 400);
					Fuz2d.sounds.addSound(_object, "teleport");

				}
			
			}
			
		}
		
		public function receivePlayer (player:PlayObjectControllable):void {
			
			if (player.controller is BipedKeyboardController) {
				BipedKeyboardController(player.controller).grapple_lt.clearObject();
			}
			
			player.object.x = _object.object.x;
			player.object.y = _object.object.y;	
			if (player.simObject is MotionObject) MotionObject(player.simObject).velocity.reset();
			player.simObject.getPosition();
			
			if (player.object.symbolName == "player") Fuz2d.mainInstance.view.camera.alignTo(player.object);
			else Fuz2d.mainInstance.view.updateObject(player.object, false, true);
			
			setTeleport();
			ObjectFactory.effect(_object, "teleport", true, 400);
			
		}
		
		protected function setTeleport ():void {

			Symbol(_object.object).state = "f1";
			_teleportTime = TimeStep.realTime;
			_busy = _busyWait = true;
			
		}
		
		public function get nearestTeleport ():TeleportController {
			
			var tc:TeleportController;
			var ntc:TeleportController;
			var dist:Number;
			var newdist:Number;
			
			for (var i:int = 0; i < _group.length; i++) {
				
				tc = _group[i];
				
				if (tc != this) {
					
					if (ntc == null) {
						
						ntc = tc;
						dist = Geom2d.distanceBetweenPoints(_object.object.point, tc.teleporter.object.point);
						
					} else {
						
						newdist = Geom2d.distanceBetweenPoints(_object.object.point, tc.teleporter.object.point);
						if (newdist < dist) ntc = tc;
						
					}
					
				}
				
			}
			
			return ntc;
			
			
		}
		
		//
		//
		protected function onCollision (e:CollisionEvent):void {
			
			if (e.collider.collisionObject.reactionType == ReactionType.BOUNCE) {
				_busy = _busyWait = true;
			}
			
			if (e.collider.objectRef is Biped) {
				
				var pobj:PlayObjectControllable = _object.playfield.playObjects[e.collider];
				
				if (pobj != null) {
					
					if (pobj.object != null && !pobj.object.deleted) {
						
						teleportPlayer(pobj);
						
					}
					
				}
				
			}
			
		}
		
		//
		//
		override public function end():void {
			
			if (_group != null && _group.indexOf(this) != -1) _group.splice(_group.indexOf(this), 1);
			if (_object != null && _object.simObject != null) _object.simObject.removeEventListener(CollisionEvent.COLLISION, onCollision);
			super.end();
			
		}
		
	}
	
}