/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

//
//
package fuz2d.action.play {
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import fuz2d.action.physics.BoundsBuilder;
	import fuz2d.action.physics.CompoundObject;
	import fuz2d.action.physics.Simulation;
	import fuz2d.Fuz2d;
	import fuz2d.library.*;
	import fuz2d.model.Model;
	import fuz2d.action.play.*;
	import fuz2d.model.ModelEvent;
	import fuz2d.TimeStep;
	import fuz2d.util.Map;
	import fuz2d.util.ProximityGrid;

	//
	//
	public class Playfield extends EventDispatcher {

		private var _main:Fuz2d;
		public function get main ():Fuz2d { return _main };
		
		private var _model:Model;
		public function get model ():Model { return _model; }
		
		private var _simulation:Simulation;
		public function get simulation ():Simulation { return _simulation; }
		
		private var _objects:Array;
		public var playObjects:Dictionary
		
		private var _map:PlayfieldMap;
		public function get map():PlayfieldMap { return _map; }
		
		private var _sightGrid:PlayfieldSightGrid
		public function get sightGrid():PlayfieldSightGrid { return _sightGrid; }
		
		private var _playing:Boolean = false;
		public function get playing ():Boolean { return _playing; }
		
		public function get objects():Array { return _objects; }
		
		private var _locked:Boolean = false;
		public function get locked():Boolean { return _locked; }
		public function set locked(value:Boolean):void 
		{
			_locked = value;
			_simulation.locked = value;
		}
		
		private var _pu:PlayfieldEvent;
		
		private var _timer:Timer;
		
		
		private var _debug:Boolean = false;
		
		//
		//
		public function Playfield (main:Fuz2d, model:Model, simulation:Simulation) {
			
			_main = main;
			_model = model;
			_simulation = simulation;
			
			_objects = [];
			
			_map = new PlayfieldMap(this);
			
			_sightGrid = new PlayfieldSightGrid(this, 200, 200);
			_sightGrid.sightDistX = 2;
			
			playObjects = new Dictionary(true);
			
			PlayObject.linkControllers = [];
			PlayObject.linkableObjects = [];
			
			_timer = new Timer(250);
			
			_pu = new PlayfieldEvent(PlayfieldEvent.UPDATE);
			
			_listeners = new Vector.<IPlayfieldUpdatable>();
			
		}
		
		//
		//
		public function play (e:Event):void {
		
			if (!_locked) {
				//dispatchEvent(_pu);
				
				var i:int = _listeners.length;
     			while (i--)	if (i < _listeners.length) _listeners[i].onPlayfieldUpdate();
				
				if (TimeStep.stepValue % 20 == 0) _sightGrid.update();
				
			} else {
				_model.dispatchEvent(new ModelEvent(ModelEvent.UPDATE));
			}
			
		}
		
		private var _listeners:Vector.<IPlayfieldUpdatable>;
		
		public function listen (obj:IPlayfieldUpdatable):void
		{
			if (_listeners.indexOf(obj) == -1) _listeners.push(obj);
		}
		
		public function unlisten (obj:IPlayfieldUpdatable):void
		{
			var idx:int = _listeners.indexOf(obj);
			if (idx != -1) _listeners.splice(idx, 1);
		}
		
		//
		//
		public function start ():void {
			
			if (!_playing) {
				//View.mainStage.addEventListener(Event.ENTER_FRAME, play, false, 0, true);
				_simulation.addEventListener(Simulation.CYCLE_END, play, false, 0, true);
				_simulation.start();
				if (BoundsBuilder.built && !_map.boundsAdded) {
					
					_map.addBounds();
					
					if (_debug) {
						
						for (var y:int = -100; y < 100; y++) {
						
							for (var x:int = -100; x < 100; x++) {
								
								if (!_map.isFree(x, y)) {
									
									var g:Graphics = Sprite(Fuz2d.mainInstance.view.viewport.dobj).graphics;
									g.lineStyle(1, 0xff00ff);
									g.drawRect(x * 60, -y * 60, 60, 60);
									
								}
								
							}
							
						}
					
					}
					
				}
				_playing = true;
			}
			
		}
		
		//
		//
		public function stop ():void {
			
			if (_playing) {
				//View.mainStage.removeEventListener(Event.ENTER_FRAME, play);
				_simulation.removeEventListener(Simulation.CYCLE_END, play);
				_simulation.stop();
				_playing = false;
			}
		
		}
		
		//
		//
		public function end ():void {
			
			stop();
			
			for each (var pobj:PlayObject in _objects) {
				if (pobj is PlayObjectControllable && PlayObjectControllable(pobj).controller != null) {
					PlayObjectControllable(pobj).endControl();
				}
				pobj.destroy();
			}
			
			if (_sightGrid) _sightGrid.end();
			if (_map) _map.end();
			
			_objects = null;
			playObjects = null;
			
			_model = null;
			_simulation = null;
			_map = null;
			_sightGrid = null;
			_main = null;

		}
		
		//
		//
		public function pauseToggle ():void {
			
			if (_locked) return;
			
			if (_playing) stop();
			else start();
			
			dispatchEvent(new PlayfieldEvent(PlayfieldEvent.PAUSE));
				
		}
	
		//
		//
		public function addObject (obj:PlayObject):void {
			
			if (_objects.indexOf(obj) == -1) {
				
				if (obj.main != _main) obj.main = _main;
				_objects.push(obj);
				playObjects[obj.simObject] = obj;
				if (obj.simObject is CompoundObject) {
					var cobj:CompoundObject = CompoundObject(obj.simObject);
					if (cobj.subSimObjects) {
						var i:int = cobj.subSimObjects.length;
						while (i--) {
							playObjects[cobj.subSimObjects[i]] = obj;
						}
					}
				}
				if (obj.map) _map.registerPlayObject(obj);
				if (obj.submap) _map.analyzeMapping(obj, obj.buttress);
			
				if (obj is PlayObjectControllable) _sightGrid.register(obj as PlayObjectControllable);

			}
			
		}
		
		//
		//
		public function removeObject (obj:PlayObject):Boolean {
			
			if (_objects.indexOf(obj) != -1) {
					
				_objects.splice(_objects.indexOf(obj), 1);
				_map.unRegisterPlayObject(obj);
				if (obj is PlayObjectControllable) _sightGrid.unregister(obj as PlayObjectControllable);
				
				if (obj.simObject != null) {
					playObjects[obj.simObject] = null;
					if (obj.simObject is CompoundObject) {
						var cobj:CompoundObject = CompoundObject(obj.simObject);
						if (cobj.subSimObjects) {
							var i:int = cobj.subSimObjects.length;
							while (i--) {
								playObjects[cobj.subSimObjects[i]] = null;
								delete playObjects[cobj.subSimObjects[i]];
							}
						}
					}
					delete playObjects[obj.simObject];
				}
				
				return true;
					
			}
			
			return false;
			
		}
		
		//
		//
		public function createNew (objID:String, creator:PlayObject):PlayObject {
			
			return ObjectFactory.createNew(objID, creator) as PlayObject;
			
		}
		
	}
	
}
