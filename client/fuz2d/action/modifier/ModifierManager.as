/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.modifier {

	import flash.events.EventDispatcher;
	import fuz2d.action.physics.Simulation;
	import fuz2d.action.physics.SimulationObject;
	import fuz2d.action.play.IPlayfieldUpdatable;
	import fuz2d.action.play.Playfield;
	import fuz2d.action.play.PlayfieldEvent;
	import fuz2d.action.play.PlayObjectControllable;
	import fuz2d.model.object.Object2d;
	
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	
	public class ModifierManager extends EventDispatcher implements IPlayfieldUpdatable {
		
		protected var _simulation:Simulation;
		
		protected var _modelObject:Object2d;
		protected var _simObject:SimulationObject;
		protected var _playObject:PlayObjectControllable;
		
		public function get simulation():Simulation { return _simulation; }	
		public function get modelObject():Object2d { return _modelObject; }	
		public function get simObject():SimulationObject { return _simObject; }	
		public function get playObject():PlayObjectControllable { return _playObject; }
			
		protected var _modifiers:Array;
		
		//
		//
		public function ModifierManager (playObj:PlayObjectControllable = null) {
		
			init(playObj);
			
		}
		
		//
		//
		protected function init (playObj:PlayObjectControllable = null):void {
			
			_playObject = playObj;
			_simObject = playObj.simObject;
			_modelObject = playObj.object;
			_simulation = playObj.playfield.simulation;

			_modifiers = [];
			
			//_playObject.playfield.addEventListener(PlayfieldEvent.UPDATE, update, false, 0, true);
			_playObject.playfield.listen(this);
		}
		
		//
		//
		public function update (e:Event):void {
			
			if (_modifiers.length == 0) return;
			
			try {
				if (_playObject.object == null || _playObject.object.deleted) _playObject.destroy();
				else for each (var modifier:Modifier in _modifiers) {
					if (!modifier.complete) modifier.update(e);
					else remove(modifier);
				}
			} catch (e:Error) {
				
			}
			
			dispatchEvent(new ModifierEvent(ModifierEvent.UPDATE, false, false));
			
		}
		
		//
		//
		public function ping ():void {

			try {
				for each (var modifier:Modifier in _modifiers) {
					if (!modifier.complete) {
						dispatchEvent(new ModifierEvent(ModifierEvent.START, false, false, modifier));
					}
				}
			} catch (e:Error) {
				
			}

		}
		
		//
		//
		public function add (modifier:Modifier):Modifier {
			
			_modifiers.push(modifier);
			modifier.parentClass = this;
			modifier.addEventListener(ModifierEvent.END, ended, false, 0, true);
			
			dispatchEvent(new ModifierEvent(ModifierEvent.START, false, false, modifier));
			
			return modifier;
			
		}
		
		//
		//
		public function remove (modifier:Modifier):Boolean {
			
			if (_modifiers.indexOf(modifier) != -1) {
				_modifiers.splice(_modifiers.indexOf(modifier), 1);
				return true;
			}
			
			return false;
			
		}
		
		//
		//
		public function contains (modifierName:String):Boolean {
			
			for each (var modifier:Modifier in _modifiers) if (getQualifiedClassName(modifier).toLowerCase().indexOf(modifierName) != -1) return true;
			
			return false;
			
		}
		
		//
		//
		public function containsClass (c:Class):Boolean {
			
			for each (var modifier:Modifier in _modifiers) if (getQualifiedClassName(modifier) == getQualifiedClassName(c)) return true;
			
			return false;
			
		}
		
		//
		//
		public function removeAllOfClass (c:Class):Boolean {
			
			for each (var modifier:Modifier in _modifiers) if (getQualifiedClassName(modifier) == getQualifiedClassName(c)) remove(modifier);
			
			return false;
			
		}
		
		//
		//
		public function ended (e:ModifierEvent):void {
			
			dispatchEvent(new ModifierEvent(ModifierEvent.END, false, false, e.modifier));
	
		}
		
		//
		//
		public function reset ():void {
			_modifiers = [];
		}
		
		//
		//
		public function end ():void {
			
			for each (var modifier:Modifier in _modifiers) {
				modifier.end()
				remove(modifier);
			}

			reset();
			
			//_playObject.playfield.removeEventListener(PlayfieldEvent.UPDATE, update)
			_playObject.playfield.unlisten(this);
		}
		
		/* INTERFACE fuz2d.action.play.IPlayfieldUpdatable */
		
		public function onPlayfieldUpdate():void 
		{
			update(null);
		}
		
	}
	
}