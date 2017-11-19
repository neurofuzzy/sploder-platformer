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
	import fuz2d.model.environment.OmniLight;
	import fuz2d.model.object.Symbol;
	import fuz2d.util.Geom2d;
	
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class LightController extends PlayObjectController {
		
		protected var _player:PlayObject;
		protected var _playerNear:Boolean = false;
		protected var _on:Boolean = true;
		
		//
		//
		public function LightController (object:PlayObjectControllable) {
		
			super(object);
			
		}
		
		//
		//
		override public function see(p:PlayObject):void {
			
			super.see(p);

			if (p.object.symbolName == "player") {
				
				_player = p;
				_playerNear = true;
				
			}
			
		}
		
		//
		//
		override public function update (e:Event):void {
			
			if (_ended || !_active) return;
			
			super.update(e);
			
			if (_player != null && _player.deleted) {
				
				_player = null;
				_playerNear = false;
				
				turnOff();
				
			} else if (_playerNear && !_on) {
				
				if (_object.playfield.map.canSee(_object as PlayObjectControllable, _player)) {
					
					if (Geom2d.squaredDistanceBetweenPoints(_object.object.point, _player.object.point) < 90000) {
						
						turnOn();
						
					}
					
				}
				
			} else if (_on) {
				
				if (_player != null) {
					
					if (Geom2d.squaredDistanceBetweenPoints(_object.object.point, _player.object.point) > 90000) {
						
						turnOff();
						
					}
				
				} else {
					
					turnOff();
					
				}
				
			}
				
		}
		
		public function turnOn ():void {
			
			if (!_on) {
				
				if (_object.object.attribs.light is OmniLight) {
					OmniLight(_object.object.attribs.light).enabled = true;
					_on = true;
					Symbol(_object.object).state = "on_stop";
					
				}
				
			}
			
		}
		
		public function turnOff ():void {
			
			if (_on) {
				
				if (_object.object.attribs.light is OmniLight) {
					OmniLight(_object.object.attribs.light).enabled = false;
					_on = false;
					Symbol(_object.object).state = "off_stop";
				}
				
			}
			
		}
		
		
		//
		//
		override public function end():void {
			
			_player = null;
			super.end();
			
		}
		
	}
	
}