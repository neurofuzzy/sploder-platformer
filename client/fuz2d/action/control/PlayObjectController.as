/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.action.control {
	
	import flash.events.Event;
	import fuz2d.action.*;
	import fuz2d.action.control.Controller;
	import fuz2d.action.play.*;
	

	public class PlayObjectController extends Controller implements IPlayfieldUpdatable {
		
		protected var _object:PlayObjectControllable;
		
		//
		//
		public function PlayObjectController (object:PlayObjectControllable) {
			
			super();
			init(object);
			
		}
		
		//
		//
		protected function init (object:PlayObjectControllable):void {
			
			_object = object;
			
			wake();
			
		}
		
		override public function wake ():void {
			
			//if (!_ended && !_active) _object.playfield.addEventListener(PlayfieldEvent.UPDATE, update, false, 0, true);
			_object.playfield.listen(this);
			
			super.wake();
			
		}
		
		override public function sleep ():void {
			
			//if (!_active) _object.playfield.removeEventListener(PlayfieldEvent.UPDATE, update);
			_object.playfield.unlisten(this);
			
			super.sleep();
			
		}
		
		//
		//
		override public function see(p:PlayObject):void {
			
			super.see(p);
			
			//if (_object.playfield.map.canSee(_object as PlayObjectControllable, p)) {
				
				//trace(_object.object.symbolName, "sees", p.object.symbolName);
				
			//}
			
		}
		
		//
		//
		override public function update (e:Event):void {
			
			if (_ended || !_active) return;
			
			super.update(e);
			
		}
		
		//
		//
		override public function end ():void {
			
			super.end();
			
			_object = null;
			
		}
		
		/* INTERFACE fuz2d.action.play.IPlayfieldUpdatable */
		
		public function onPlayfieldUpdate():void 
		{
			update(null);
		}
		
	}
	
}
