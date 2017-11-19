/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.action.control {
	
	import flash.geom.Point;
	import fuz2d.action.physics.*;
	import fuz2d.action.play.*;
	import fuz2d.model.object.Symbol;
	
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class LinkController extends PlayObjectController {
		
		protected var _switched:Boolean = false;

		//
		//
		public function LinkController (object:PlayObjectControllable) {
		
			super(object);
			
			PlayObject.linkControllers.push(this);
			
			_object.simObject.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);
			
		}
		
		//
		//
		public function trigger (state:Boolean = true):void {
				
			var objs:Array = getLinkedObjects();
			
			var i:int = objs.length;
			
			while (i--) {
				
				PlayObjectControllable(objs[i]).controller.signal(this, "link");
				
			}
			
		}
		
		
		//
		//
		public function getLinkedObjects ():Array {
			
			var a:Array = [];
			
			var i:int = PlayObject.linkableObjects.length;
			var pt:Point = new Point();
			
			while (i--) {
				
				var p:PlayObject = PlayObject(PlayObject.linkableObjects[i]);
				
				if (p && !p.deleted && p.object) {
					
					pt.x = parseInt(p.data[1]);
					pt.y = parseInt(p.data[2]);
					
					pt = p.object.positionWorld(pt);
					
					if (p is PlayObjectControllable && 
						Math.abs(pt.x - _object.object.x) <= 30 && 
						Math.abs(pt.y - _object.object.y) <= 30) {
						a.push(p);
					}
				
				}
				
			}
			
			return a;
	
		}
		
		//
		//
		protected function onCollision (e:CollisionEvent):void {
	
			if (_object && _object.playfield && e) {
				
				var pobj:PlayObject = _object.playfield.playObjects[e.collider];
				
				var pobjc:Controller;
				var boarded:Boolean = false;
				
				if (pobj && pobj is PlayObjectControllable) {
					pobjc = PlayObjectControllable(pobj).controller;
					if (pobjc is DriveKeyboardController) {
						boarded = DriveKeyboardController(pobjc).boarded;
					} else if (pobjc is MechKeyboardController) {
						boarded = MechKeyboardController(pobjc).boarded;
					}
				}
				
				if (!_switched && 
					(e.collider.type == "player" || boarded)) {
					
					trigger();
					
					_switched = true;

					Symbol(_object.object).state = "f_switched";
					_object.eventSound("switch");
					//_object.eventSound("trigger");
					
				}
				
			}
			
		}
		
		//
		//
		override public function end():void {
			
			if (_object != null && _object.simObject != null) _object.simObject.removeEventListener(CollisionEvent.COLLISION, onCollision);
			super.end();
			
		}
		
	}
	
	
	
}