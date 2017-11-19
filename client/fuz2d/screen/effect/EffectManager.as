/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.screen.effect {

	import fuz2d.Fuz2d;
	import fuz2d.screen.effect.Effect;
	import fuz2d.action.modifier.ModifierEvent;
	import fuz2d.action.play.PlayObjectControllable;
	import fuz2d.screen.shape.AssetDisplay;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;
	
	public class EffectManager extends EventDispatcher {
		
		protected var _asset:AssetDisplay;
		public function get asset():AssetDisplay { return _asset; }
		
		protected var _initialized:Boolean = false;
		public function get initialized():Boolean { return _initialized; }
		
		protected var _effects:Array;
		
		//
		//
		public function EffectManager (asset:AssetDisplay) {
		
			init(asset);
			
		}
		
		//
		//
		protected function init (asset:AssetDisplay):void {
			
			_asset = asset;

			_effects = [];
			
			initialize();
			
		}
		
		//
		//
		public function initialize ():void {
			
			if (!_initialized && _asset.container.objectRef != null && _asset.container.objectRef.simObject != null) {

				var playObject:PlayObjectControllable = Fuz2d.mainInstance.playfield.playObjects[asset.container.objectRef.simObject];
			
				if (playObject != null) {
					
					playObject.modifiers.addEventListener(ModifierEvent.START, add);
					playObject.modifiers.addEventListener(ModifierEvent.UPDATE, update);
					playObject.modifiers.addEventListener(ModifierEvent.END, remove);
					playObject.modifiers.ping();

				}
				
				_initialized = true;
				
			}			
			
		}
		
		//
		//
		public function get affectsColor ():Boolean {
			
			for each (var effect:Effect in _effects) {
				if (effect.affectsColor) return true;
			}
			
			return false;
			
		}
		
		//
		//
		public function add (e:ModifierEvent):Effect {

			var effect:Effect;
			
			switch (e.modifier.type) {
				
				case "atomic":
					effect = new AtomicEffect(this);
					break;
				
			}
			
			if (effect != null) {
				
				_effects.push(effect);
				
			}
			
			return effect;
			
		}
		
		//
		//
		public function update (e:ModifierEvent):void {
			
			try {
				if (_asset == null || _asset.container == null || _asset.container.objectRef == null) end();
				else for each (var effect:Effect in _effects) {
					if (!effect.complete) effect.update();
					else removeEffect(effect);
				}
			} catch (e:Error) {
				trace("EffectManager update:", e);
			}
		}
		
		//
		//
		public function remove (e:ModifierEvent):Boolean {
			
			var found:Boolean = false;
			for each (var effect:Effect in _effects) {
				if (getQualifiedClassName(effect).toLowerCase().indexOf(e.modifier.type) != -1) {
					effect.deactivate(true);
					_effects.splice(_effects.indexOf(effect), 1);
					found = true;
				}
			}

			return found;
			
		}
		
		//
		//
		public function removeEffect (effect:Effect):Boolean {
			
			if (_effects.indexOf(effect) != -1) {
				_effects.splice(_effects.indexOf(effect), 1);
				return true;
			}
			
			return false;
		}
		
		//
		//
		public function reset ():void {
			_effects = [];
		}
		
		//
		//
		public function end ():void {
			
			for each (var effect:Effect in _effects) {
				effect.deactivate(true);
				removeEffect(effect);
			}

			reset();

		}
		
	}
	
}